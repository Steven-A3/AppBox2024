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
#import "UIViewController+A3Addition.h"
#import "UIViewController+LoanCalcAddtion.h"
#import "A3KeyboardDelegate.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3LoanCalcLoanGraphCell.h"
#import "A3NumberKeyboardViewController.h"
#import "UITableView+utility.h"
#import "UIViewController+iPad_rightSideView.h"
#import "A3AppDelegate+appearance.h"

@interface A3LoanCalcLoanDetailViewController () <LoanCalcSelectFrequencyDelegate, LoanCalcExtraPaymentDelegate, A3KeyboardDelegate, UITextFieldDelegate>
{
    BOOL _isLoanCalcEdited;
}

@end

@implementation A3LoanCalcLoanDetailViewController

NSString *const A3LoanCalcSelectCellID2 = @"A3LoanCalcSelectCell";
NSString *const A3LoanCalcTextInputCellID2 = @"A3LoanCalcTextInputCell";
NSString *const A3LoanCalcLoanGraphCellID2 = @"A3LoanCalcLoanGraphCell";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.dataSectionStartIndex = 1;

    // init loan
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(-1, 0, 36, 0);
    
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

	[self registerContentSizeCategoryDidChangeNotification];
}

- (void)removeObserver {
	[self removeContentSizeCategoryDidChangeNotification];

	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationRightSideViewWillDismiss object:nil];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

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

		[cell.monthlyButton setTitleColor:[[A3AppDelegate instance] themeColor] forState:UIControlStateNormal];
		[cell.totalButton setTitleColor:[[A3AppDelegate instance] themeColor] forState:UIControlStateNormal];
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

    NSLog(@"This VC has has been pushed popped OR covered");
    
    if (parent) {
        NSLog(@"LoanCalc Detail -> pushed");
    }
    else {
        NSLog(@"LoanCalc Detail -> pushed");
        
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
	[self.firstResponder resignFirstResponder];
	[self setFirstResponder:nil];
}

- (void)presentSubViewController:(UIViewController *)viewController {
	if (IS_IPHONE) {
        [self.navigationController pushViewController:viewController animated:YES];
	} else {
		[self.A3RootViewController presentRightSideViewController:viewController];
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
            placeHolderText = [NSString stringWithFormat:@"Annual %@", [self.percentFormatter stringFromNumber:@(0)]];
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
            placeHolderText = @"0 years";
            int yearInt =  (int)round(self.loanData.monthOfTerms.doubleValue/12.0);
            textFieldText = [NSString stringWithFormat:@"%d years", yearInt];
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
}

#pragma mark - LoanCalcSelectFrequencyDelegate

- (void)didSelectLoanCalcFrequency:(A3LoanCalcFrequencyType)frequencyType
{
    if (self.loanData.frequencyIndex != frequencyType) {
        self.loanData.frequencyIndex = frequencyType;
        
        NSUInteger frequencyIndex = [self indexOfCalcItem:A3LC_CalculationItemFrequency];
        [self.tableView reloadRowsAtIndexPaths:@[
                                                 [NSIndexPath indexPathForRow:frequencyIndex inSection:1]
                                                 ]
                              withRowAnimation:UITableViewRowAnimationFade];
        
        [self updateLoanCalculation];
    }
}

#pragma mark - LoanCalcExtraPaymentDelegate

- (void)didChangedLoanCalcExtraPayment:(LoanCalcData *)loanCalc {
    [self.tableView reloadData];
}

#pragma mark - TextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.firstResponder = textField;
    
    textField.text = @"";
	textField.placeholder = @"";

	self.currentIndexPath = [self.tableView indexPathForCellSubview:textField];
	NSLog(@"End IP : %ld - %ld", (long)self.currentIndexPath.section, (long)self.currentIndexPath.row);

	A3NumberKeyboardViewController *keyboardVC = [self normalNumberKeyboard];
	textField.inputView = [keyboardVC view];
	self.numberKeyboardViewController = keyboardVC;

	if (self.currentIndexPath.section == 1) {
		// calculation items
		NSNumber *calcItemNum = self.calcItems[self.currentIndexPath.row];
		A3LoanCalcCalculationItem calcItem = calcItemNum.integerValue;

		switch (calcItem) {
			case A3LC_CalculationItemDownPayment:
			case A3LC_CalculationItemPrincipal:
			case A3LC_CalculationItemRepayment:
			{
				NSString *customCurrencyCode = [[NSUserDefaults standardUserDefaults] objectForKey:A3LoanCalcCustomCurrencyCode];
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
			self.numberKeyboardViewController.keyboardType = A3NumberKeyboardTypeCurrency;
		}
	}

	keyboardVC.textInputTarget = textField;
	keyboardVC.delegate = self;
	self.numberKeyboardViewController = keyboardVC;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextFieldTextDidChangeNotification object:nil];
	[self addNumberKeyboardNotificationObservers];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	[self removeNumberKeyboardNotificationObservers];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];

    NSIndexPath *endIndexPath = self.currentIndexPath;
    
    NSLog(@"End IP : %ld - %ld", (long)endIndexPath.section, (long)endIndexPath.row);

	[self setFirstResponder:nil];

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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	self.scrollToIndexPath = [self.tableView indexPathForCellSubview:textField];
    return YES;
}

- (void)textChanged:(NSNotification *)noti
{
	UITextField *textField = noti.object;
    NSString *testText = textField.text;
    
    if ([testText rangeOfString:@"."].location == NSNotFound) {
        return;
    }
    else {
        NSArray *textDivs = [testText componentsSeparatedByString:@"."];
        NSString *intString = textDivs[0];
        NSString *floatString = textDivs[1];
        
        if (floatString.length > 3) {
            floatString = [floatString substringWithRange:NSMakeRange(0, 3)];
        }
        
        NSString *reText = [NSString stringWithFormat:@"%@.%@", intString, floatString];
        textField.text = reText;
    }
}

/*
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *toBe = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([toBe rangeOfString:@"."].location == NSNotFound) {
        return YES;
    }
    else {
        NSArray *textDivs = [toBe componentsSeparatedByString:@"."];
        NSString *intString = textDivs[0];
        NSString *floatString = textDivs[1];
        
        if (floatString.length > 3) {
            return NO;
        }
        else {
            return YES;
        }
    }
}
 */

#pragma mark - ScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self clearEverything];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self clearEverything];
    
    if (indexPath.section == 0) {
        // graph
    }
    else if (indexPath.section == 1) {
        // calculation items
        NSNumber *calcItemNum = self.calcItems[indexPath.row];
        A3LoanCalcCalculationItem calcItem = calcItemNum.integerValue;
        
        if (calcItem == A3LC_CalculationItemFrequency) {
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
    return [LoanCalcPreference new].showExtraPayment ? 3:2;
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
        graphCell.monthlyButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
        graphCell.totalButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];

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
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 2) {
        return [LoanCalcPreference new].showExtraPayment ? @"EXTRA PAYMENTS" : nil;
    }
    
    return nil;
}

-(void)scrollToTopOfTableView {
    if (IS_LANDSCAPE) {
        [UIView beginAnimations:@"KeyboardWillShow" context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:7];
        [UIView setAnimationDuration:0.35];
        self.tableView.contentOffset = CGPointMake(0.0, -(self.navigationController.navigationBar.bounds.size.height + [[UIApplication sharedApplication] statusBarFrame].size.width));
        [UIView commitAnimations];
    } else {
        [UIView beginAnimations:@"KeyboardWillShow" context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:7];
        [UIView setAnimationDuration:0.35];
        self.tableView.contentOffset = CGPointMake(0.0, -(self.navigationController.navigationBar.bounds.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height));
        [UIView commitAnimations];
    }
}

@end
