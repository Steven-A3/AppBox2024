//
//  A3LoanCalcExtraPaymentViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 10..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcExtraPaymentViewController.h"
#import "A3LoanCalcTextInputCell.h"
#import "A3LoanCalcDateInputCell.h"
#import "A3NumberKeyboardViewController.h"
#import "A3AppDelegate.h"
#import "UIViewController+NumberKeyboard.h"
#import "NSDateFormatter+A3Addition.h"
#import "UIViewController+LoanCalcAddtion.h"
#import "A3SearchViewController.h"
#import "UITableView+utility.h"
#import "A3CurrencySelectViewController.h"
#import "A3CalculatorViewController.h"
#import "A3AppDelegate+appearance.h"
#import "UIImage+imageWithColor.h"
#import "A3DateHelper.h"
#import "A3UserDefaultsKeys.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "NSString+conversion.h"

@interface A3LoanCalcExtraPaymentViewController ()
		<A3KeyboardDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource,
		A3SearchViewControllerDelegate, A3CalculatorViewControllerDelegate,
		A3ViewControllerProtocol>
{
    NSIndexPath *_currentIndexPath;
    NSDate *_defaultYearlyMonthDate;
    NSDate *_defaultOnetimeYearMonthDate;
    
    BOOL _isExtraPaymentEdited;
}

@property (nonatomic, strong) UITextField *dateTextField;
@property (nonatomic, strong) NSMutableArray *years;
@property (nonatomic, strong) NSMutableArray *months;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableDictionary *amountItem;
@property (nonatomic, strong) NSMutableDictionary *dateItem;
@property (nonatomic, strong) NSMutableDictionary *dateInputItem;
@property (nonatomic, weak) UITextField *calculatortTargetTextField;
@property (nonatomic, weak) UITextField *editingTextField;

@property (nonatomic, strong) NSArray *pickerDataSource_0;
@property (nonatomic, strong) NSArray *pickerDataSource_1;

@property (nonatomic, copy) NSString *textBeforeEditing;
@property (nonatomic, copy) UIColor *textColorBeforeEditing;

@end

@implementation A3LoanCalcExtraPaymentViewController {
	BOOL _isNumberKeyboardVisible;
	BOOL _didPressClearKey;
	BOOL _didPressNumberKey;
}

NSString *const A3LoanCalcTextInputCellID1 = @"A3LoanCalcTextInputCell";
NSString *const A3LoanCalcDatePickerCellID1 = @"A3LoanCalcDateInputCell";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (_exPaymentType == A3LC_ExtraPaymentYearly) {
        self.navigationItem.title = NSLocalizedString(@"Yearly", @"Yearly");
    }
    else if (_exPaymentType == A3LC_ExtraPaymentOnetime) {
        self.navigationItem.title = NSLocalizedString(@"One-Time", @"One-Time");
    }
    

    [self configureDatePickerDataSource];
    
    NSCalendar *calendar = [[A3AppDelegate instance] calendar];
	NSDateComponents *firstDayComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    firstDayComp.day = 1;
    _defaultYearlyMonthDate = [A3DateHelper dateByAddingMonth:1 fromDate:[calendar dateFromComponents:firstDayComp]];
    _defaultOnetimeYearMonthDate = [A3DateHelper dateByAddingYears:1 fromDate:_defaultYearlyMonthDate];
    
    self.tableView.separatorColor = [self tableViewSeparatorColor];
    if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
        self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
    }

    [self registerContentSizeCategoryDidChangeNotification];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)applicationWillResignActive {
	[self dismissNumberKeyboard];
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
	[self removeContentSizeCategoryDidChangeNotification];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if ([self.navigationController.navigationBar isHidden]) {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
}

- (void)willDismissFromRightSide {
	[self dismissNumberKeyboard];
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

- (void)contentSizeDidChange:(NSNotification *) notification
{
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (_isExtraPaymentEdited) {
        
        if (_delegate && [_delegate respondsToSelector:@selector(didChangedLoanCalcExtraPayment:)]) {
            [_delegate didChangedLoanCalcExtraPayment:_loanCalcData];
        }
    }
}

- (void)configureDatePickerDataSource {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    NSString *dateFormat = [dateFormatter formatStringByRemovingDayComponent:[dateFormatter dateFormat]];
    NSRange monthRange = [dateFormat rangeOfString:@"m" options:NSCaseInsensitiveSearch];
    NSRange yearRange = [dateFormat rangeOfString:@"y" options:NSCaseInsensitiveSearch];
    if (monthRange.location < yearRange.location) {
        _pickerDataSource_0 = self.months;
        _pickerDataSource_1 = self.years;
    }
    else {
        _pickerDataSource_0 = self.years;
        _pickerDataSource_1 = self.months;
    }
}

- (NSMutableArray *)years
{
    if (!_years) {
        // 1800 ~ 2200년까지
        // Create Years Array from 1960 to This year
        _years = [[NSMutableArray alloc] init];
        for (int i=1800; i<=2200; i++) {
            [_years addObject:@(i).stringValue];
        }
    }
    
    return _years;
}

- (NSMutableArray *)months
{
    if (!_months) {
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        if (IS_IPAD) {
            [formatter setDateStyle:NSDateFormatterFullStyle];
        }
        _months = [[NSMutableArray alloc] initWithArray:formatter.monthSymbols];
    }
    
    return _months;
}

- (NSMutableArray *)items
{
    if (!_items) {
        _items = [[NSMutableArray alloc] init];
        
        [_items addObject:self.amountItem];
        [_items addObject:self.dateItem];
    }
    
    return _items;
}

- (NSMutableDictionary *)dateInputItem
{
    if (!_dateInputItem) {
        _dateInputItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"dateInput", @"order":@""}];
    }
    
    return _dateInputItem;
}

- (NSMutableDictionary *)amountItem
{
    if (!_amountItem) {
        _amountItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"amounts", @"order":@""}];
    }
    
    return _amountItem;
}

- (NSMutableDictionary *)dateItem
{
    if (!_dateItem) {
        _dateItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"date", @"order":@""}];
    }
    
    return _dateItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doneButtonAction:(id)button {
	[self.editingObject resignFirstResponder];
	[self setEditingObject:nil];
	[[[A3AppDelegate instance] rootViewController_iPad] dismissRightSideViewController];
}

- (UITextField *)previousTextField:(UITextField *) current
{
    NSUInteger section, row;
    section = _currentIndexPath.section;
    row = _currentIndexPath.row;
    UITableViewCell *prevCell;
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
        }
        
    } while (!exit);
    
    if ([prevCell isKindOfClass:[A3LoanCalcTextInputCell class]]) {
        return ((A3LoanCalcTextInputCell *)prevCell).textField;
    }
    else {
        return nil;
    }
}

- (UITextField *)nextTextField:(UITextField *) current
{
    NSUInteger section, row;
    section = _currentIndexPath.section;
    row = _currentIndexPath.row;
    UITableViewCell *nextCell;
    BOOL exit = false;
    do {
        row++;
        NSUInteger numRowOfSection = [self.tableView numberOfRowsInSection:section];
        if (row > (numRowOfSection-1)) {
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
        }
        
    } while (!exit);
    
    if ([nextCell isKindOfClass:[A3LoanCalcTextInputCell class]]) {
        return ((A3LoanCalcTextInputCell *)nextCell).textField;
    }
    else {
        return nil;
    }
}

#pragma mark - Picker delegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _isExtraPaymentEdited = YES;
    
    if (_exPaymentType == A3LC_ExtraPaymentYearly) {
        _dateTextField.text = _months[row];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateStyle = NSDateFormatterFullStyle;
        df.dateFormat = @"MMMM";
        NSDate *pickDate = [df dateFromString:_months[row]
                            ];
        _loanCalcData.extraPaymentYearlyDate = pickDate;
    }
    else if (_exPaymentType == A3LC_ExtraPaymentOnetime) {
        NSString *month;
        NSString *year;
        
        if ([_pickerDataSource_0 count] == 12) {
            month = _pickerDataSource_0[[pickerView selectedRowInComponent:0]];
            year = _pickerDataSource_1[[pickerView selectedRowInComponent:1]];
        }
        else {
            year = _pickerDataSource_0[[pickerView selectedRowInComponent:0]];
            month = _pickerDataSource_1[[pickerView selectedRowInComponent:1]];
        }

		// TODO: 년/월, 월/년, 지역 형식에 맞추기
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateStyle = NSDateFormatterFullStyle;
        df.dateFormat = @"MMMM, yyyy";
        NSDate *pickDate = [df dateFromString:[NSString stringWithFormat:@"%@, %@", month, year]];
        _loanCalcData.extraPaymentOneTimeDate = pickDate;
        
        _dateTextField.text = [df localizedLongStyleYearMonthFromDate:pickDate];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(didChangedLoanCalcExtraPayment:)]) {
        [_delegate didChangedLoanCalcExtraPayment:_loanCalcData];
    }
}

#pragma mark - Picker datasource

- (NSInteger)numberOfComponentsInPickerView: (UIPickerView*)thePickerView {
    
    if (_exPaymentType == A3LC_ExtraPaymentYearly) {
        return 1;
    }
    else if (_exPaymentType == A3LC_ExtraPaymentOnetime) {
        return 2;
    }
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component
{
    if (_exPaymentType == A3LC_ExtraPaymentYearly) {
        return [self.months count];
    }
    else if (_exPaymentType == A3LC_ExtraPaymentOnetime) {
        if (component == 0) {
            return [_pickerDataSource_0 count];
        }
        else if (component == 1) {
            return [_pickerDataSource_1 count];
        }
    }
    return 0;
}
- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (_exPaymentType == A3LC_ExtraPaymentYearly) {
        return self.months[row];
    }
    else if (_exPaymentType == A3LC_ExtraPaymentOnetime) {
        if (component == 0) {
            return _pickerDataSource_0[row];
        }
        else if (component == 1) {
            return _pickerDataSource_1[row];
        }
    }
    return nil;
}

#pragma mark - TextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	if (IS_IPHONE && IS_LANDSCAPE) return NO;
	
	if ([_items containsObject:self.dateInputItem]) {
		[_items removeObject:self.dateInputItem];
		
		[self.tableView beginUpdates];
		
		NSIndexPath *dateIP = [NSIndexPath indexPathForRow:1 inSection:0];
		NSIndexPath *pickerIP = [NSIndexPath indexPathForRow:2 inSection:0];
		
		[self.tableView reloadRowsAtIndexPaths:@[dateIP] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView deleteRowsAtIndexPaths:@[pickerIP] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView endUpdates];
		
		_dateTextField = nil;
	}
	
	NSIndexPath *indexPath = [self.tableView indexPathForCellSubview:textField];
	if (indexPath.row == 0) {
		// amount
		[self presentNumberKeyboardForTextField:textField];
	}
	
	return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.editingObject = textField;
	
	self.textBeforeEditing = textField.text;
	self.textColorBeforeEditing = textField.textColor;
	_didPressNumberKey = NO;
	_didPressClearKey = NO;

	textField.text = [self.decimalFormatter stringFromNumber:@0];
	textField.placeholder = @"";
	
	textField.textColor = [[A3AppDelegate instance] themeColor];

	_currentIndexPath = [self.tableView indexPathForCellSubview:textField];
	[self addNumberKeyboardNotificationObservers];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	self.editingObject = nil;
	[self removeNumberKeyboardNotificationObservers];

	if (_textColorBeforeEditing) {
		textField.textColor = _textColorBeforeEditing;
		_textColorBeforeEditing = nil;
	}

	if (_textBeforeEditing && !_didPressNumberKey && !_didPressClearKey) {
		textField.text = _textBeforeEditing;
		_textBeforeEditing = nil;
	}
	
    // update
    _isExtraPaymentEdited = YES;

	NSNumber *inputNum = @([textField.text floatValueEx]);

    if (_currentIndexPath.row == 0) {
        if (_exPaymentType == A3LC_ExtraPaymentYearly) {
			if ([textField.text length]) {
				self.loanCalcData.extraPaymentYearly = inputNum;
                
                if (![_loanCalcData extraPaymentYearlyDate]) {
                    _loanCalcData.extraPaymentYearlyDate = _defaultYearlyMonthDate;
                }
			}
			NSNumber *data = self.loanCalcData.extraPaymentYearly;
			textField.text = [self.loanFormatter stringFromNumber:data ? data : @0];
		}
        else if (_exPaymentType == A3LC_ExtraPaymentOnetime) {
			if ([textField.text length]) {
				self.loanCalcData.extraPaymentOneTime = inputNum;

                if (![_loanCalcData extraPaymentOneTimeDate]) {
                    _loanCalcData.extraPaymentOneTimeDate = _defaultOnetimeYearMonthDate;
                }
			}
			NSNumber *data = self.loanCalcData.extraPaymentOneTime;
			textField.text = [self.loanFormatter stringFromNumber:data ? data : @0];
		}

		if (_delegate && [_delegate respondsToSelector:@selector(didChangedLoanCalcExtraPayment:)]) {
			[_delegate didChangedLoanCalcExtraPayment:_loanCalcData];
		}
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.editingObject resignFirstResponder];
	[self setEditingObject:nil];

	return YES;
}

- (void)presentNumberKeyboardForTextField:(UITextField *)textField {
	if (_isNumberKeyboardVisible) {
		return;
	}
	_editingTextField = textField;

	[self textFieldDidBeginEditing:textField];
	
	A3NumberKeyboardViewController *keyboardVC = [self normalNumberKeyboard];
	self.numberKeyboardViewController = keyboardVC;
	
	CGRect bounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	CGFloat keyboardHeight = keyboardVC.keyboardHeight;
	UIView *keyboardView = keyboardVC.view;
	if (IS_IPHONE) {
		[self.view.superview addSubview:keyboardView];
	} else {
		[[A3AppDelegate instance].rootViewController_iPad.view addSubview:keyboardView];
	}

	keyboardVC.textInputTarget = textField;
	keyboardVC.delegate = self;
	
	self.numberKeyboardViewController.currencyCode = [self defaultCurrencyCode];
	self.numberKeyboardViewController.keyboardType = A3NumberKeyboardTypeCurrency;

	_didPressClearKey = NO;
	_didPressNumberKey = NO;

	FNLOGRECT(self.view.frame);

	keyboardView.frame = CGRectMake(0, self.view.bounds.size.height, bounds.size.width, keyboardHeight);
	[UIView animateWithDuration:0.3 animations:^{
		CGRect frame = keyboardView.frame;
		frame.origin.y -= keyboardHeight;
		keyboardView.frame = frame;
	} completion:^(BOOL finished) {
		[self addNumberKeyboardNotificationObservers];
		_isNumberKeyboardVisible = YES;
	}];
}

- (void)dismissNumberKeyboard {
	if (!_isNumberKeyboardVisible) {
		return;
	}
	[self textFieldDidEndEditing:_editingTextField];
	
	_editingTextField = nil;
	self.editingObject = nil;
	
	A3NumberKeyboardViewController *keyboardViewController = self.numberKeyboardViewController;
	UIView *keyboardView = keyboardViewController.view;
	[UIView animateWithDuration:0.3 animations:^{
		CGRect frame = keyboardView.frame;
		frame.origin.y += keyboardViewController.keyboardHeight;
		keyboardView.frame = frame;
	} completion:^(BOOL finished) {
		[keyboardView removeFromSuperview];
		[keyboardViewController removeFromParentViewController];
		self.numberKeyboardViewController = nil;
		_isNumberKeyboardVisible = NO;
	}];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_items[indexPath.row] == self.amountItem) {
        A3LoanCalcTextInputCell *inputCell = (A3LoanCalcTextInputCell *)[tableView cellForRowAtIndexPath:indexPath];
        [inputCell.textField becomeFirstResponder];
    }
    else if (_items[indexPath.row] == self.dateItem) {
        [self dismissNumberKeyboard];

        // toggle
        if ([_items containsObject:self.dateInputItem]) {
            [_items removeObject:self.dateInputItem];   
            
            [tableView beginUpdates];
            
            NSIndexPath *dateIP = [NSIndexPath indexPathForRow:1 inSection:0];
            NSIndexPath *pickerIP = [NSIndexPath indexPathForRow:2 inSection:0];
            
            [tableView reloadRowsAtIndexPaths:@[dateIP] withRowAnimation:UITableViewRowAnimationFade];
            [tableView deleteRowsAtIndexPaths:@[pickerIP] withRowAnimation:UITableViewRowAnimationFade];
            
            [tableView endUpdates];
            
            _dateTextField = nil;
        }
        else {
            [_items addObject:self.dateInputItem];
            
            [tableView beginUpdates];
            
            NSIndexPath *dateIP = [NSIndexPath indexPathForRow:1 inSection:0];
            NSIndexPath *pickerIP = [NSIndexPath indexPathForRow:2 inSection:0];
            
            [tableView reloadRowsAtIndexPaths:@[dateIP] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[pickerIP] withRowAnimation:UITableViewRowAnimationFade];
            
            [tableView endUpdates];
            
            A3LoanCalcTextInputCell *inputCell = (A3LoanCalcTextInputCell *)[tableView cellForRowAtIndexPath:indexPath];
            _dateTextField = inputCell.textField;
        }
    }
    else if (_items[indexPath.row] == self.dateInputItem) {
        
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_items[indexPath.row] == self.dateInputItem) {
        return 216.0;
    }
    else {
        return 44.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell=nil;

    if (_items[indexPath.row] == self.amountItem) {
        A3LoanCalcTextInputCell *inputCell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcTextInputCellID1 forIndexPath:indexPath];
		inputCell.textLabelOffset = 15;
		[inputCell setNeedsUpdateConstraints];
        inputCell.selectionStyle = UITableViewCellSelectionStyleNone;
        inputCell.textField.font = [UIFont systemFontOfSize:17];
        inputCell.textField.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
        
        inputCell.titleLabel.text = NSLocalizedString(@"Amounts", @"Amounts");
        inputCell.textField.delegate = self;
        inputCell.textField.enabled = YES;
        inputCell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[self.loanFormatter stringFromNumber:@(0)]
                                                                                    attributes:@{NSForegroundColorAttributeName:inputCell.textField.textColor}];
        if (_exPaymentType == A3LC_ExtraPaymentYearly) {
            if (_loanCalcData.extraPaymentYearly) {
                inputCell.textField.text = [self.loanFormatter stringFromNumber:_loanCalcData.extraPaymentYearly];
            }
            else {
                inputCell.textField.text = @"";
            }
        }
        else if (_exPaymentType == A3LC_ExtraPaymentOnetime) {
            if (_loanCalcData.extraPaymentOneTime) {
                inputCell.textField.text = [self.loanFormatter stringFromNumber:_loanCalcData.extraPaymentOneTime];
            }
            else {
                inputCell.textField.text = @"";
            }
        }
        cell = inputCell;
    }
    else if (_items[indexPath.row] == self.dateItem) {
        A3LoanCalcTextInputCell *inputCell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcTextInputCellID1 forIndexPath:indexPath];
		inputCell.textLabelOffset = 15;
		[inputCell setNeedsUpdateConstraints];
        inputCell.selectionStyle = UITableViewCellSelectionStyleNone;
        inputCell.textField.font = [UIFont systemFontOfSize:17];
        
        if ([_items containsObject:self.dateInputItem]) {
            inputCell.textField.textColor = [A3AppDelegate instance].themeColor;
        }
        else {
            inputCell.textField.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
        }
        
        inputCell.titleLabel.text = NSLocalizedString(@"Date", @"Date");
        inputCell.textField.enabled = NO;
        inputCell.textField.placeholder = NSLocalizedString(@"None", @"None");
        
        if (_exPaymentType == A3LC_ExtraPaymentYearly) {
            NSDate *pickDate = ![_loanCalcData extraPaymentYearlyDate] ? _defaultYearlyMonthDate : [_loanCalcData extraPaymentYearlyDate];
            NSDateComponents *components = [[[A3AppDelegate instance] calendar] components:NSCalendarUnitMonth fromDate:pickDate];
            NSInteger month = [components month];
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateStyle:NSDateFormatterFullStyle];
//            if (IS_IPAD) {
//                NSArray *months = [df monthSymbols];
//                NSString *monthText = months[month - 1];
//                inputCell.textField.text = monthText;
//            }
//            else {
//                NSArray *months = [df shortMonthSymbols];
//                NSString *monthText = months[month - 1];
//                inputCell.textField.text = monthText;
//            }
            NSArray *months = [df monthSymbols];
            NSString *monthText = months[month - 1];
            inputCell.textField.text = monthText;
        }
        else if (_exPaymentType == A3LC_ExtraPaymentOnetime) {
            NSDate *pickDate = ![_loanCalcData extraPaymentOneTimeDate] ? _defaultOnetimeYearMonthDate : [_loanCalcData extraPaymentOneTimeDate];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            
            inputCell.textField.text = [df localizedLongStyleYearMonthFromDate:pickDate];
        }
        cell = inputCell;
    }
    else if (_items[indexPath.row] == self.dateInputItem) {
        A3LoanCalcDateInputCell *pickerCell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcDatePickerCellID1 forIndexPath:indexPath];
		pickerCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        pickerCell.picker.delegate = self;
        pickerCell.picker.dataSource = self;
        
        // 해당 날짜가 선택되어지도록 (loan데이타에 날짜가 있으면 그날짜를, 없으면 오늘 날짜를)
        if (_exPaymentType == A3LC_ExtraPaymentOnetime) {
            NSDate *pickDate = _loanCalcData.extraPaymentOneTimeDate ? _loanCalcData.extraPaymentOneTimeDate : _defaultOnetimeYearMonthDate;
            NSDateComponents *components = [[[A3AppDelegate instance] calendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:pickDate];
            NSUInteger month = [components month];
            NSUInteger year = [components year];
            
            if ([_pickerDataSource_0 count] == 12) {
                [pickerCell.picker selectRow:month-1 inComponent:0 animated:NO];
                NSUInteger yearIdx = 0;
                for (int i=0; i<_years.count; i++) {
                    NSString *yearString = _years[i];
                    NSUInteger tmp = yearString.integerValue;
                    
                    if (tmp == year) {
                        yearIdx = i;
                        break;
                    }
                }
                [pickerCell.picker selectRow:yearIdx inComponent:1 animated:NO];
            }
            else {
                [pickerCell.picker selectRow:month-1 inComponent:1 animated:NO];
                NSUInteger yearIdx = 0;
                for (int i=0; i<_years.count; i++) {
                    NSString *yearString = _years[i];
                    NSUInteger tmp = yearString.integerValue;
                    
                    if (tmp == year) {
                        yearIdx = i;
                        break;
                    }
                }
                [pickerCell.picker selectRow:yearIdx inComponent:0 animated:NO];
            }
        }
        else if (_exPaymentType == A3LC_ExtraPaymentYearly) {
            NSDate *pickDate = _loanCalcData.extraPaymentYearlyDate ? _loanCalcData.extraPaymentYearlyDate : _defaultOnetimeYearMonthDate;
            NSDateComponents *components = [[[A3AppDelegate instance] calendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:pickDate];
            NSUInteger month = [components month];
            
            [pickerCell.picker selectRow:month-1 inComponent:0 animated:NO];
        }
        
        cell = pickerCell;
    }
    
    return cell;
}

#pragma mark - A3KeyboardDelegate

- (BOOL)isPreviousEntryExists
{
	return NO;
}

- (BOOL)isNextEntryExists{
	return NO;
}

- (void)prevButtonPressed{
    if (self.editingObject) {
        UITextField *prevTxtField = [self previousTextField:(UITextField *) self.editingObject];
        if (prevTxtField) {
            [prevTxtField becomeFirstResponder];
        }
    }
}

- (void)nextButtonPressed{
    if (self.editingObject) {
        UITextField *nextTxtField = [self nextTextField:(UITextField *) self.editingObject];
        if (nextTxtField) {
            [nextTxtField becomeFirstResponder];
        }
    }
}

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
	_didPressClearKey = YES;
	_didPressNumberKey = NO;
	UITextField *textField = self.numberKeyboardViewController.textInputTarget;
	textField.text = [self.decimalFormatter stringFromNumber:@0];
	if (_currentIndexPath.row == 0) {
		if (_exPaymentType == A3LC_ExtraPaymentYearly) {
			self.loanCalcData.extraPaymentYearly = @0;
		}
		else if (_exPaymentType == A3LC_ExtraPaymentOnetime) {
			self.loanCalcData.extraPaymentOneTime = @0;
		}
	}
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate {
	[self dismissNumberKeyboard];
}

- (void)keyboardViewControllerDidValueChange:(A3NumberKeyboardViewController *)vc {
	_didPressNumberKey = YES;
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

#pragma mark --- Response to Currency Select Button and result

- (void)currencySelectButtonAction:(NSNotification *)notification {
	[self dismissNumberKeyboard];
	
	A3CurrencySelectViewController *viewController = [self presentCurrencySelectViewControllerWithCurrencyCode:notification.object];
	viewController.delegate = self;
}

- (void)searchViewController:(UIViewController *)viewController itemSelectedWithItem:(NSString *)selectedItem {
	if ([selectedItem length]) {
		[[A3SyncManager sharedSyncManager] setObject:selectedItem forKey:A3LoanCalcUserDefaultsCustomCurrencyCode state:A3DataObjectStateModified];

		[[NSNotificationCenter defaultCenter] postNotificationName:A3LoanCalcCurrencyCodeChanged object:nil];

		[self.loanFormatter setCurrencyCode:selectedItem];

		[self.tableView reloadData];
	}
}

- (void)calculatorButtonAction {

	_calculatortTargetTextField = _editingTextField;
	[self dismissNumberKeyboard];

	A3CalculatorViewController *viewController = [self presentCalculatorViewController];
	viewController.delegate = self;
}

- (void)calculatorDidDismissWithValue:(NSString *)value {
	_calculatortTargetTextField.text = value;
	[self textFieldDidEndEditing:_calculatortTargetTextField];
}

- (NSString *)defaultCurrencyCode {
	NSString *code = [[A3SyncManager sharedSyncManager] objectForKey:A3LoanCalcUserDefaultsCustomCurrencyCode];
	if (!code) {
		code = [A3UIDevice systemCurrencyCode];
	}
	return code;
}

@end
