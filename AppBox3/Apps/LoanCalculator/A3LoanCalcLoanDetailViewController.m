//
//  A3LoanCalcLoanDetailViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcLoanDetailViewController.h"
#import "A3LoanCalcSelectFrequencyViewController.h"
#import "A3LoanCalcExtraPaymentViewController.h"
#import "A3LoanCalcTextInputCell.h"
#import "LoanCalcData+Calculation.h"
#import "LoanCalcString.h"
#import "LoanCalcPreference.h"
#import "A3AppDelegate.h"
#import "UIViewController+LoanCalcAddtion.h"
#import "A3KeyboardDelegate.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3LoanCalcLoanGraphCell.h"
#import "A3NumberKeyboardViewController.h"
#import "UITableView+utility.h"
#import "UIViewController+iPad_rightSideView.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "A3UIDevice.h"
#import "A3UserDefaults+A3Addition.h"

@interface A3LoanCalcLoanDetailViewController ()
<LoanCalcSelectFrequencyDelegate,
LoanCalcExtraPaymentDelegate,
A3KeyboardDelegate,
UITextFieldDelegate,
A3ViewControllerProtocol>

@property (nonatomic, copy) NSString *textBeforeEditing;
@property (nonatomic, weak) UITextField *editingTextField;
@property (nonatomic, copy) UIColor *textColorBeforeEditing;

@end

@implementation A3LoanCalcLoanDetailViewController {
	BOOL _didPressClearKey;
	BOOL _didPressNumberKey;
	BOOL _isNumberKeyboardVisible;
	
	BOOL _isLoanCalcEdited;
}

NSString *const A3LoanCalcSelectCellID2 = @"A3LoanCalcSelectCell";
NSString *const A3LoanCalcTextInputCellID2 = @"A3LoanCalcTextInputCell";
NSString *const A3LoanCalcLoanGraphCellID2 = @"A3LoanCalcLoanGraphCell";

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.dataSectionStartIndex = 1;

    // init loan
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
//    self.tableView.contentInset = UIEdgeInsetsMake(-1, 0, 36, 0);
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 2)];
    line.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.tableView addSubview:line];
    
    // init
    self.totalMode = NO;
    [self.percentFormatter setMaximumFractionDigits:3];
    
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewWillHide) name:A3NotificationRightSideViewWillDismiss object:nil];
	}
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudKeyValueStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];

	[self registerContentSizeCategoryDidChangeNotification];
}

- (void)applicationWillResignActive {
	[self dismissNumberKeyboard];
}

- (void)cloudStoreDidImport {
	// 입력 중에 있다면, reload 하지 않는다.
	if (self.editingObject) {
		return;
	}
	self.calcItems = nil;

	NSString *key = _isLoanData_A ? A3LoanCalcUserDefaultsLoanDataKey_A : A3LoanCalcUserDefaultsLoanDataKey_B;
	NSData *loanData = [[A3SyncManager sharedSyncManager] objectForKey:key];
	if (loanData) {
		self.loanData = [NSKeyedUnarchiver unarchiveObjectWithData:loanData];
	}

	[self.tableView reloadData];
	[self enableControls:YES];
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
	[self removeContentSizeCategoryDidChangeNotification];

	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudKeyValueStoreDidImport object:nil];
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationRightSideViewWillDismiss object:nil];
	}
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([self.navigationController.navigationBar isHidden]) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[self dismissNumberKeyboard];
	
	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
}

- (void)dealloc {
	[self removeObserver];
}

- (void)rightSideViewWillHide {
	[self enableControls:YES];
}

- (void)enableControls:(BOOL)enable {
	if (!IS_IPAD) return;

	if (enable) {
		A3LoanCalcLoanGraphCell *cell = (A3LoanCalcLoanGraphCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
		cell.monthlyButton.enabled = YES;
		cell.totalButton.enabled = YES;
        if ([self.loanData calculated]) {
            cell.infoButton.enabled = YES;
        }

		[cell.monthlyButton setTitleColor:[[A3UserDefaults standardUserDefaults] themeColor] forState:UIControlStateNormal];
		[cell.totalButton setTitleColor:[[A3UserDefaults standardUserDefaults] themeColor] forState:UIControlStateNormal];
		if (cell.monthlyButton.layer.borderColor != [UIColor clearColor].CGColor) {
			cell.monthlyButton.layer.borderColor = cell.monthlyButton.currentTitleColor.CGColor;
		}
		if (cell.totalButton.layer.borderColor != [UIColor clearColor].CGColor) {
			cell.totalButton.layer.borderColor = cell.totalButton.currentTitleColor.CGColor;
		}
	} else {
		UIColor *disabledColor = [UIColor colorWithRed:201.0 / 255.0 green:201.0 / 255.0 blue:201.0 / 255.0 alpha:1.0];
		A3LoanCalcLoanGraphCell *cell = (A3LoanCalcLoanGraphCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
		cell.infoButton.enabled = NO;
		cell.monthlyButton.enabled = NO;
		cell.totalButton.enabled = NO;

		[cell.monthlyButton setTitleColor:disabledColor forState:UIControlStateDisabled];
		[cell.totalButton setTitleColor:disabledColor forState:UIControlStateDisabled];
		if (cell.monthlyButton.layer.borderColor != [UIColor clearColor].CGColor) {
			cell.monthlyButton.layer.borderColor = disabledColor.CGColor;
		}
		if (cell.totalButton.layer.borderColor != [UIColor clearColor].CGColor) {
			cell.totalButton.layer.borderColor = disabledColor.CGColor;
		}
	}
}

- (void)contentSizeDidChange:(NSNotification *) notification
{
    [self.tableView reloadData];
}

-(void)willMoveToParentViewController:(UIViewController *)parent {
	[super willMoveToParentViewController:parent];

    FNLOG(@"This VC has has been pushed popped OR covered");
    
    if (parent) {
        FNLOG(@"LoanCalc Detail -> pushed");
    }
    else {
        FNLOG(@"LoanCalc Detail -> pushed");
        
        if (_isLoanCalcEdited) {
            
            if (_delegate && [_delegate respondsToSelector:@selector(didEditedLoanData:)]) {
                [_delegate didEditedLoanData:self.loanData];
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)calcItems {
	if (!super.calcItems) {
		super.calcItems = [[NSMutableArray alloc] initWithArray:[LoanCalcMode compareCalculateItemsForDownPaymentEnabled:self.loanData.showDownPayment]];
	}

	return super.calcItems;
}

- (void)clearEverything {
	[self dismissNumberKeyboard];
}

- (void)presentSubViewController:(UIViewController *)viewController {
	if (IS_IPHONE) {
        [self.navigationController pushViewController:viewController animated:YES];
	} else {
		[[[A3AppDelegate instance] rootViewController_iPad] presentRightSideViewController:viewController toViewController:nil];
	}
}

- (void)configureInputCell:(A3LoanCalcTextInputCell *)inputCell withCalculationItem:(A3LoanCalcCalculationItem) calcItem
{
    inputCell.titleLabel.text = [LoanCalcString titleOfItem:calcItem];
    NSString *placeHolderText = @"";
    NSString *textFieldText = @"";
    switch (calcItem) {
        case A3LC_CalculationItemDownPayment:
        {
//            placeHolderText = [self.loanFormatter stringFromNumber:@(0)];
            textFieldText = [self.loanFormatter stringFromNumber:self.loanData.downPayment];
            break;
        }
        case A3LC_CalculationItemInterestRate:
        {
            placeHolderText = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Annual", @"Annual"), [self.percentFormatter stringFromNumber:@(0)]];
            textFieldText = [self.loanData interestRateString];
            break;
        }
        case A3LC_CalculationItemPrincipal:
        {
//            placeHolderText = [self.loanFormatter stringFromNumber:@(0)];
            textFieldText = [self.loanFormatter stringFromNumber:self.loanData.principal];
            break;
        }
        case A3LC_CalculationItemRepayment:
        {
            placeHolderText = [self.loanFormatter stringFromNumber:@(0)];
            textFieldText = [self.loanFormatter stringFromNumber:self.loanData.repayment];
            break;
        }
        case A3LC_CalculationItemTerm:
        {
            textFieldText = [self.loanData termValueString];
            break;
        }
        default:
            break;
	}
    inputCell.textField.text = textFieldText;
    inputCell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeHolderText
                                                                                attributes:@{NSForegroundColorAttributeName:inputCell.textField.textColor}];
}

- (UITextField *)previousTextField:(UITextField *) current
{
    NSUInteger section, row;
    section = self.currentIndexPath.section;
    row = self.currentIndexPath.row;
    NSIndexPath *selectedIP = nil;
    UITableViewCell *prevCell = nil;
    BOOL exit = false;
    do {
        if (row == 0) {
            if (section == 0) {
                return nil;
            }
            section--;
            row = [self.tableView numberOfRowsInSection:section]-1;
        }
        else {
            row--;
        }
        
        NSIndexPath *tmpIp = [NSIndexPath indexPathForRow:row inSection:section];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:tmpIp];
        
        if ([cell isKindOfClass:[A3LoanCalcTextInputCell class]]) {
            exit = true;
            prevCell = cell;
            selectedIP = tmpIp;
        }
        
    } while (!exit);
    
    if (prevCell && selectedIP && [prevCell isKindOfClass:[A3LoanCalcTextInputCell class]]) {
        return ((A3LoanCalcTextInputCell *)prevCell).textField;
    }
    else {
        return nil;
    }
}

- (UITextField *)nextTextField:(UITextField *) current
{
    NSUInteger section, row;
    section = self.currentIndexPath.section;
    row = self.currentIndexPath.row;
    NSIndexPath *selectedIP = nil;
    UITableViewCell *nextCell = nil;
    BOOL exit = false;
    do {
        row++;
        NSUInteger numRowOfSection = [self.tableView numberOfRowsInSection:section];
        if ((row+1) > numRowOfSection) {
            section++;
            row=0;
        }
        
        NSUInteger maxSection = [self.tableView numberOfSections];
        
        if (section > (maxSection-1)) {
            return nil;
        }
        
        NSIndexPath *tmpIp = [NSIndexPath indexPathForRow:row inSection:section];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:tmpIp];
        
        if ([cell isKindOfClass:[A3LoanCalcTextInputCell class]]) {
            exit = true;
            nextCell = cell;
            selectedIP = tmpIp;
        }
        
    } while (!exit);
    
    if (nextCell && selectedIP && [nextCell isKindOfClass:[A3LoanCalcTextInputCell class]]) {
        return ((A3LoanCalcTextInputCell *)nextCell).textField;
    }
    else {
        return nil;
    }
}

- (void)updateLoanCalculation
{
    [self.loanData calculateRepayment];
    [self displayLoanGraph];
    
    _isLoanCalcEdited = YES;
    
    if ([self.loanData calculated]) {
        // 계산이 되었으면, 상단 그래프가 보이도록 이동시킨다.
        //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
        [self scrollToTopOfTableView];
    }
	[self saveLoanData];
}

- (void)saveLoanData
{
	NSData *myLoanData = [NSKeyedArchiver archivedDataWithRootObject:self.loanData];
	NSString *key = _isLoanData_A ? A3LoanCalcUserDefaultsLoanDataKey_A : A3LoanCalcUserDefaultsLoanDataKey_B;

	[[A3SyncManager sharedSyncManager] setObject:myLoanData forKey:key state:A3DataObjectStateModified];
}

#pragma mark - LoanCalcSelectFrequencyDelegate

- (void)didSelectLoanCalcFrequency:(A3LoanCalcFrequencyType)frequencyType
{
    if (self.loanData.frequencyIndex != frequencyType) {
        self.loanData.frequencyIndex = frequencyType;
        
        [self.tableView reloadData];
        [self updateLoanCalculation];
    }
}

#pragma mark - LoanCalcExtraPaymentDelegate

- (void)didChangedLoanCalcExtraPayment:(LoanCalcData *)loanCalc {
	[self updateLoanCalculation];
    [self.tableView reloadData];
}

#pragma mark - TextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	FNLOG();
	if (IS_IPHONE && [UIWindow interfaceOrientationIsLandscape]) return NO;

	if (_isNumberKeyboardVisible) {
		if (textField != _editingTextField) {
			[self textFieldDidEndEditing:_editingTextField];
			[self textFieldDidBeginEditing:textField];
		}
	} else {
		self.scrollToIndexPath = [self.tableView indexPathForCellSubview:textField];
		[self presentNumberKeyboardForTextField:textField];
	}

	return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.editingObject = textField;
	_editingTextField = textField;
	_didPressClearKey = NO;
	_didPressNumberKey = NO;
	
	FNLOG(@"%@, %@", _editingTextField.text, _editingTextField);

	self.textBeforeEditing = textField.text;
	textField.text = [self.decimalFormatter stringFromNumber:@0];
	textField.placeholder = @"";
	
	self.textColorBeforeEditing = textField.textColor;
    textField.textColor = [[A3UserDefaults standardUserDefaults] themeColor];

	self.currentIndexPath = [self.tableView indexPathForCellSubview:textField];
	FNLOG(@"End IP : %ld - %ld", (long)self.currentIndexPath.section, (long)self.currentIndexPath.row);
	[self.tableView scrollToRowAtIndexPath:self.currentIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];

	A3NumberKeyboardViewController *keyboardVC = self.numberKeyboardViewController;

	if (self.currentIndexPath.section == 1) {
		// calculation items
		NSNumber *calcItemNum = self.calcItems[self.currentIndexPath.row];
		A3LoanCalcCalculationItem calcItem = calcItemNum.integerValue;

		switch (calcItem) {
			case A3LC_CalculationItemDownPayment:
			case A3LC_CalculationItemPrincipal:
			case A3LC_CalculationItemRepayment:
			{
				NSString *customCurrencyCode = [[A3SyncManager sharedSyncManager] objectForKey:A3LoanCalcUserDefaultsCustomCurrencyCode];
				if ([customCurrencyCode length]) {
					[self.numberKeyboardViewController setCurrencyCode:customCurrencyCode];
				}
				self.numberKeyboardViewController.keyboardType = A3NumberKeyboardTypeCurrency;
				break;
			}
			case A3LC_CalculationItemInterestRate:
			{
				self.numberKeyboardViewController.keyboardType = A3NumberKeyboardTypeInterestRate;
				if (!self.loanData.showsInterestInYearly || ![self.loanData.showsInterestInYearly boolValue]) {
					[keyboardVC.bigButton1 setSelected:NO];
					[keyboardVC.bigButton2 setSelected:YES];
				}
				break;
			}
			case A3LC_CalculationItemTerm:
			{
				self.numberKeyboardViewController.keyboardType = A3NumberKeyboardTypeMonthYear;
				if ([self.loanData.showsTermInMonths boolValue]) {
					[keyboardVC.bigButton1 setSelected:NO];
					[keyboardVC.bigButton2 setSelected:YES];
				}
				break;
			}
			default:
				break;
		}
	}
	else if (self.currentIndexPath.section == 2) {
		// extra payment
		NSNumber *exPaymentItemNum = self.extraPaymentItems[self.currentIndexPath.row];
		A3LoanCalcExtraPaymentType exPaymentItem = exPaymentItemNum.integerValue;

		if (exPaymentItem == A3LC_ExtraPaymentMonthly) {
			keyboardVC.currencyCode = [self defaultCurrencyCode];
            if (IS_IPAD) {
                self.numberKeyboardViewController.hidesLeftBigButtons = YES;
            }
			self.numberKeyboardViewController.keyboardType = A3NumberKeyboardTypeCurrency;
		}
	}

	keyboardVC.textInputTarget = textField;
	keyboardVC.delegate = self;
	[keyboardVC reloadPrevNextButtons];
	
	[self addNumberKeyboardNotificationObservers];
	
	FNLOGINSETS(self.tableView.contentInset);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	FNLOGINSETS(self.tableView.contentInset);
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	FNLOG(@"%@, %@", _editingTextField.text, _editingTextField);
	
	FNLOGINSETS(self.tableView.contentInset);

	if (_textColorBeforeEditing) {
		textField.textColor = _textColorBeforeEditing;
		_textColorBeforeEditing = nil;
	}

	if (!_didPressNumberKey && !_didPressClearKey) {
		textField.text = _textBeforeEditing;
		_textBeforeEditing = nil;
		return;
	}
	
    NSIndexPath *endIndexPath = self.currentIndexPath;
    
    FNLOG(@"End IP : %ld - %ld", (long)endIndexPath.section, (long)endIndexPath.row);

	[self setEditingObject:nil];

    // update
    if (endIndexPath.section == 1) {
        // calculation item
        NSNumber *calcItemNum = self.calcItems[endIndexPath.row];
        A3LoanCalcCalculationItem calcItem = calcItemNum.integerValue;
		NSNumber *inputNum = [self.decimalFormatter numberFromString:textField.text];
        double inputFloat = [inputNum doubleValue];

		switch (calcItem) {
            case A3LC_CalculationItemDownPayment:
            {
                if ([textField.text length] > 0) {
					self.loanData.downPayment = inputNum;
                }
				textField.text = [self.loanFormatter stringFromNumber:self.loanData.downPayment];

                break;
            }
            case A3LC_CalculationItemInterestRate: {
				if ([textField.text length]) {
					A3NumberKeyboardViewController *keyboardViewController = self.numberKeyboardViewController;
					self.loanData.showsInterestInYearly = @([keyboardViewController.bigButton1 isSelected]);
					if ([self.loanData.showsInterestInYearly boolValue]) {
						self.loanData.annualInterestRate = @(inputFloat / 100.0);
					} else {
						self.loanData.annualInterestRate = @(inputFloat / 100.0 * 12.0);
					}
				}
				textField.text = [self.loanData interestRateString];
				break;
			}
            case A3LC_CalculationItemPrincipal:
            {
                if ([textField.text length] > 0) {
					self.loanData.principal = inputNum;
                }
				textField.text = [self.loanFormatter stringFromNumber:self.loanData.principal];

                break;
            }
            case A3LC_CalculationItemRepayment:
            {
                if ([textField.text length] > 0) {
					self.loanData.repayment = inputNum;
                }
				textField.text = [self.loanFormatter stringFromNumber:self.loanData.repayment];

                break;
            }
            case A3LC_CalculationItemTerm: {
				if ([textField.text length]) {
					A3NumberKeyboardViewController *keyboardViewController = self.numberKeyboardViewController;
					self.loanData.showsTermInMonths = @([keyboardViewController.bigButton2 isSelected]);
					if ([self.loanData.showsTermInMonths boolValue]) {
						self.loanData.monthOfTerms = inputNum;
					} else {
						NSInteger years = [inputNum integerValue];
						self.loanData.monthOfTerms = @(years * 12);
					}
				}
				textField.text = [self.loanData termValueString];
				break;
			}
            default:
                break;
        }
    }
    else if (endIndexPath.section == 2) {
        // extra payment
        NSNumber *exPayItemNum = self.extraPaymentItems[endIndexPath.row];
        A3LoanCalcExtraPaymentType exPayType = exPayItemNum.integerValue;
		NSNumber *inputNum = [self.decimalFormatter numberFromString:textField.text];

		if (exPayType == A3LC_ExtraPaymentMonthly) {
            if ([textField.text length] > 0) {
				self.loanData.extraPaymentMonthly = inputNum;
            }
			textField.text = [self.loanFormatter stringFromNumber:self.loanData.extraPaymentMonthly];
        }
    }

	[self updateLoanCalculation];
}

#pragma mark - ScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self clearEverything];
}

#pragma mark - Number Keyboard

- (void)presentNumberKeyboardForTextField:(UITextField *)textField {
	if (_isNumberKeyboardVisible) {
		return;
	}
	_isNumberKeyboardVisible = YES;

	A3NumberKeyboardViewController *keyboardVC = [self normalNumberKeyboard];
	self.numberKeyboardViewController = keyboardVC;

	CGRect bounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	CGFloat keyboardHeight = keyboardVC.keyboardHeight;
	UIView *keyboardView = keyboardVC.view;
	[self.view.superview addSubview:keyboardView];

	[self textFieldDidBeginEditing:textField];

	_didPressClearKey = NO;
	_didPressNumberKey = NO;
	
	keyboardView.frame = CGRectMake(0, self.view.bounds.size.height, bounds.size.width, keyboardHeight);
	[UIView animateWithDuration:0.3 animations:^{
		CGRect frame = keyboardView.frame;
		frame.origin.y -= keyboardHeight;
		keyboardView.frame = frame;

		UIEdgeInsets contentInset = self.tableView.contentInset;
		contentInset.bottom = keyboardHeight;
		self.tableView.contentInset = contentInset;
		
		NSIndexPath *indexPath = [self.tableView indexPathForCellSubview:textField];
		[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
	} completion:^(BOOL finished) {
		[self addNumberKeyboardNotificationObservers];
	}];
	
}

- (void)dismissNumberKeyboard {
#ifdef DEBUG
	NSArray *symbols = [NSThread callStackSymbols];
	for (NSString *symbol in symbols) {
		NSLog(@"%@", symbol);
	}
#endif
	if (!_isNumberKeyboardVisible) {
		return;
	}
	[self removeNumberKeyboardNotificationObservers];
	
	[self textFieldDidEndEditing:_editingTextField];
	_editingTextField = nil;
	self.editingObject = nil;
	
	A3NumberKeyboardViewController *keyboardViewController = self.numberKeyboardViewController;
	UIView *keyboardView = keyboardViewController.view;
	[UIView animateWithDuration:0.3 animations:^{
		CGRect frame = keyboardView.frame;
		frame.origin.y += keyboardViewController.keyboardHeight;
		keyboardView.frame = frame;

		UIEdgeInsets contentInset = self.tableView.contentInset;
		contentInset.bottom = 0;
		self.tableView.contentInset = contentInset;

	} completion:^(BOOL finished) {
		[keyboardView removeFromSuperview];
		[keyboardViewController removeFromParentViewController];
		self.numberKeyboardViewController = nil;
		_isNumberKeyboardVisible = NO;
	}];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	if (_isNumberKeyboardVisible && self.numberKeyboardViewController.view.superview) {
		UIView *keyboardView = self.numberKeyboardViewController.view;
		CGFloat keyboardHeight = self.numberKeyboardViewController.keyboardHeight;
		
		FNLOGRECT(self.view.bounds);
		FNLOG(@"%f", keyboardHeight);
		keyboardView.frame = CGRectMake(0, self.view.bounds.size.height - keyboardHeight, self.view.bounds.size.width, keyboardHeight);
		[self.numberKeyboardViewController rotateToInterfaceOrientation:toInterfaceOrientation];
	}
}

#pragma mark - Number Keyboard Delegate

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
	[super A3KeyboardController:controller clearButtonPressedTo:keyInputDelegate];
	_didPressClearKey = YES;
	_didPressNumberKey = NO;
}

- (void)keyboardViewControllerDidValueChange:(A3NumberKeyboardViewController *)vc {
	_didPressNumberKey = YES;
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate {
	[self dismissNumberKeyboard];
}

- (void)currencySelectButtonAction:(NSNotification *)notification {
	[self dismissNumberKeyboard];

	[super currencySelectButtonAction:notification];
}

- (void)calculatorButtonAction {
	[super calculatorButtonAction];
	
	self.calculatorTargetTextField = _editingTextField;
	[self dismissNumberKeyboard];
}

- (void)calculatorDidDismissWithValue:(NSString *)value {
	_didPressNumberKey = YES;
	
	[super calculatorDidDismissWithValue:value];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
    if (indexPath.section == 0) {
        // graph
    }
    else if (indexPath.section == 1) {
        // calculation items
        NSNumber *calcItemNum = self.calcItems[indexPath.row];
        A3LoanCalcCalculationItem calcItem = calcItemNum.integerValue;
        
        if (calcItem == A3LC_CalculationItemFrequency) {
			[self dismissNumberKeyboard];
			
            A3LoanCalcSelectFrequencyViewController *viewController = [[A3LoanCalcSelectFrequencyViewController alloc] initWithStyle:UITableViewStyleGrouped];
            viewController.delegate = self;
            viewController.currentFrequency = self.loanData.frequencyIndex;

			[self enableControls:NO];
            [self presentSubViewController:viewController];
        }
        else {
            A3LoanCalcTextInputCell *inputCell = (A3LoanCalcTextInputCell *)[tableView cellForRowAtIndexPath:indexPath];
            [inputCell.textField becomeFirstResponder];
        }
    }
    if (indexPath.section == 2) {
        // extra payment
        NSNumber *exPaymentItemNum = self.extraPaymentItems[indexPath.row];
        A3LoanCalcExtraPaymentType exPaymentItem = exPaymentItemNum.integerValue;
        
        if ((exPaymentItem == A3LC_ExtraPaymentYearly) || (exPaymentItem == A3LC_ExtraPaymentOnetime)) {
			[self dismissNumberKeyboard];

            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"LoanCalculatorPhoneStoryBoard" bundle:nil];
            A3LoanCalcExtraPaymentViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3LoanCalcExtraPaymentViewController"];
            viewController.exPaymentType = exPaymentItem;
            viewController.loanCalcData = self.loanData;
            viewController.delegate = self;

			[self enableControls:NO];
            [self presentSubViewController:viewController];
        }
        else if (exPaymentItem == A3LC_ExtraPaymentMonthly) {
            A3LoanCalcTextInputCell *inputCell = (A3LoanCalcTextInputCell *)[tableView cellForRowAtIndexPath:indexPath];
            [inputCell.textField becomeFirstResponder];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [LoanCalcPreference showExtraPayment] && (self.loanData.frequencyIndex == A3LC_FrequencyMonthly) ? 3:2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;   // loan graph
    }
    else if (section == 1) {
        return self.calcItems.count;
    }
    else if (section == 2) {
        return self.extraPaymentItems.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;

	if (indexPath.section == 0) {
		// graph
		A3LoanCalcLoanGraphCell *graphCell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcLoanGraphCellID2 forIndexPath:indexPath];

		[graphCell.monthlyButton addTarget:self action:@selector(monthlyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
		[graphCell.totalButton addTarget:self action:@selector(totalButtonAction:) forControlEvents:UIControlEventTouchUpInside];
		[graphCell.infoButton addTarget:self action:@selector(infoButtonAction:) forControlEvents:UIControlEventTouchUpInside];

		if ([self.loanData calculated]) {
			[self displayGraphCell:graphCell];
		}
		else {
			[self makeGraphCellClear:graphCell];
		}

		[graphCell.monthlyButton setTitle:[LoanCalcString titleOfFrequency:self.loanData.frequencyIndex] forState:UIControlStateNormal];
        graphCell.monthlyButton.titleLabel.font = IS_IPHONE ? [UIFont systemFontOfSize:12] : [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        graphCell.totalButton.titleLabel.font = IS_IPHONE ? [UIFont systemFontOfSize:12] : [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];

		cell = graphCell;
	}
	else if (indexPath.section == 1) {
		// calculation items
		NSNumber *calcItemNum = self.calcItems[indexPath.row];
		A3LoanCalcCalculationItem calcItem = calcItemNum.integerValue;

		if (calcItem == A3LC_CalculationItemFrequency) {
			cell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcSelectCellID2 forIndexPath:indexPath];
			cell.textLabel.text = [LoanCalcString titleOfItem:calcItem];
			cell.detailTextLabel.text = [LoanCalcString titleOfFrequency:self.loanData.frequencyIndex];
			cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
			cell.detailTextLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
		}
		else {
			A3LoanCalcTextInputCell *inputCell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcTextInputCellID2 forIndexPath:indexPath];
			inputCell.selectionStyle = UITableViewCellSelectionStyleNone;
			inputCell.textField.delegate = self;
			inputCell.textField.font = [UIFont systemFontOfSize:17];
			inputCell.textField.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];

			[self configureInputCell:inputCell withCalculationItem:calcItem];

			cell = inputCell;
		}
	}
	else if (indexPath.section == 2) {
		// extra payment
		NSNumber *exPaymentItemNum = self.extraPaymentItems[indexPath.row];
		A3LoanCalcExtraPaymentType exPaymentItem = exPaymentItemNum.integerValue;

		if (exPaymentItem == A3LC_ExtraPaymentMonthly) {
			A3LoanCalcTextInputCell *inputCell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcTextInputCellID2 forIndexPath:indexPath];
			inputCell.selectionStyle = UITableViewCellSelectionStyleNone;
			inputCell.textField.font = [UIFont systemFontOfSize:17];
			inputCell.textField.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
			inputCell.textField.delegate = self;
			inputCell.titleLabel.text = [LoanCalcString titleOfExtraPayment:exPaymentItem];
			inputCell.textField.text = [self.loanFormatter stringFromNumber:self.loanData.extraPaymentMonthly];
			inputCell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@""
																						attributes:@{NSForegroundColorAttributeName:inputCell.textField.textColor}];
//                inputCell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[self.loanFormatter stringFromNumber:@(0)]
//                                                                                            attributes:@{NSForegroundColorAttributeName:inputCell.textField.textColor}];

			cell = inputCell;
		}
		else {
			cell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcSelectCellID2 forIndexPath:indexPath];
			cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
			cell.detailTextLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];

			if (exPaymentItem == A3LC_ExtraPaymentYearly) {
				[self configureExtraPaymentYearlyCell:cell];
			}
			else if (exPaymentItem == A3LC_ExtraPaymentOnetime) {
				[self configureExtraPaymentOneTimeCell:cell];
			}
		}
	}

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return (IS_IPHONE) ? 134 : 193;
    }
    else {
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    float nonTitleHeight = 35;
    float titleHeight = 55;
    
    if (section == 0) {
        return 1;
    }
    else {
        if (section == 2) {
            return titleHeight-1.0;
        }
        else {
            return nonTitleHeight -1.0;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == ([LoanCalcPreference showExtraPayment] && (self.loanData.frequencyIndex == A3LC_FrequencyMonthly) ? 2 : 1)) {
        return 38;
    }
    
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 2) {
        return [LoanCalcPreference showExtraPayment] && (self.loanData.frequencyIndex == A3LC_FrequencyMonthly) ? NSLocalizedString(@"EXTRA PAYMENTS", @"EXTRA PAYMENTS") : nil;
    }
    
    return nil;
}

- (void)scrollToTopOfTableView {
	[UIView beginAnimations:A3AnimationIDKeyboardWillShow context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationCurve:7];
	[UIView setAnimationDuration:0.35];
	if (self.tableView.contentInset.top == 0) {
		self.tableView.contentOffset = CGPointMake(0.0, 0.0);
	}
	else {
		self.tableView.contentOffset = CGPointMake(0.0, -(self.navigationController.navigationBar.bounds.size.height + [A3UIDevice statusBarHeight]));
	}
	[UIView commitAnimations];
}

@end
