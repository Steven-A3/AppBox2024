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
#import "UIViewController+A3AppCategory.h"
#import "NSDateFormatter+A3Addition.h"
#import "UIViewController+LoanCalcAddtion.h"
#import "A3SearchViewController.h"
#import "UITableView+utility.h"

@interface A3LoanCalcExtraPaymentViewController () <A3KeyboardDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, A3SearchViewControllerDelegate>
{
    NSIndexPath *_currentIndexPath;
    
    BOOL _isExtraPaymentEdited;
}

@property (nonatomic, strong) UITextField *dateTextField;
@property (nonatomic, strong) NSMutableArray *years;
@property (nonatomic, strong) NSMutableArray *months;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableDictionary *amountItem;
@property (nonatomic, strong) NSMutableDictionary *dateItem;
@property (nonatomic, strong) NSMutableDictionary *dateInputItem;
@property (nonatomic, weak) UITextField *calculatorOutputTargetTextField;

@end

@implementation A3LoanCalcExtraPaymentViewController

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (_exPaymentType == A3LC_ExtraPaymentYearly) {
        self.navigationItem.title = @"Yearly";
        
//        if (_loanCalcData.extraPaymentYearlyDate == nil) {
//            _loanCalcData.extraPaymentYearlyDate = [NSDate date];
//        }
        
    }
    else if (_exPaymentType == A3LC_ExtraPaymentOnetime) {
        self.navigationItem.title = @"One-Time";
        
//        if (_loanCalcData.extraPaymentOneTimeDate == nil) {
//            _loanCalcData.extraPaymentOneTimeDate = [NSDate date];
//        }
    }
    
    self.tableView.separatorColor = [self tableViewSeparatorColor];
    
    [self registerContentSizeCategoryDidChangeNotification];
}

- (void)removeObserver {
	[self removeContentSizeCategoryDidChangeNotification];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isBeingDismissed]) {
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

- (NSMutableArray *)years
{
    if (!_years) {
        
        // 1800 ~ 2200년까지
        //Create Years Array from 1960 to This year
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
	[self.firstResponder resignFirstResponder];
	[self setFirstResponder:nil];
	[self.A3RootViewController dismissRightSideViewController];
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
        NSDate *pickDate = [df dateFromString:_months[row]];
        _loanCalcData.extraPaymentYearlyDate = pickDate;
    }
    else if (_exPaymentType == A3LC_ExtraPaymentOnetime) {
        
        NSUInteger monthIdx = [pickerView selectedRowInComponent:0];
        NSString *month = _months[monthIdx];
        NSString *year = _years[[pickerView selectedRowInComponent:1]];
        _dateTextField.text = [NSString stringWithFormat:@"%@, %@", month, year];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateStyle = NSDateFormatterFullStyle;
        df.dateFormat = @"MMMM, yyyy";
        NSDate *pickDate = [df dateFromString:_dateTextField.text];
        _loanCalcData.extraPaymentOneTimeDate = pickDate;
    }
    
    if (IS_IPAD && _delegate && [_delegate respondsToSelector:@selector(didChangedLoanCalcExtraPayment:)]) {
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
        return self.months.count;
    }
    else if (_exPaymentType == A3LC_ExtraPaymentOnetime) {
        if (component == 0) {
            return self.months.count;
        }
        else if (component == 1) {
            return self.years.count;
        }
    }
    return 0;
}
- (NSString *)pickerView:(UIPickerView *)thePickerView
             titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (_exPaymentType == A3LC_ExtraPaymentYearly) {
        return self.months[row];
    }
    else if (_exPaymentType == A3LC_ExtraPaymentOnetime) {
        if (component == 0) {
            return self.months[row];
        }
        else if (component == 1) {
            return self.years[row];
        }
    }
    return nil;
}

#pragma mark - TextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.firstResponder = textField;

    textField.text = @"";
	textField.placeholder = @"";

	_currentIndexPath = [self.tableView indexPathForCellSubview:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.firstResponder = nil;
    
    // update
    _isExtraPaymentEdited = YES;

	NSNumber *inputNum = [self.decimalFormatter numberFromString:textField.text];

    if (_currentIndexPath.row == 0) {
        if (_exPaymentType == A3LC_ExtraPaymentYearly) {
			if ([textField.text length]) {
				self.loanCalcData.extraPaymentYearly = inputNum;
			}
			NSNumber *data = self.loanCalcData.extraPaymentYearly;
			textField.text = [self.loanFormatter stringFromNumber:data ? data : @0];
		}
        else if (_exPaymentType == A3LC_ExtraPaymentOnetime) {
			if ([textField.text length]) {
				self.loanCalcData.extraPaymentOneTime = inputNum;
			}
			NSNumber *data = self.loanCalcData.extraPaymentOneTime;
			textField.text = [self.loanFormatter stringFromNumber:data ? data : @0];
		}

		if (IS_IPAD && _delegate && [_delegate respondsToSelector:@selector(didChangedLoanCalcExtraPayment:)]) {
			[_delegate didChangedLoanCalcExtraPayment:_loanCalcData];
		}
	}
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
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
        A3NumberKeyboardViewController *keyboardVC = [self normalNumberKeyboard];
        textField.inputView = [keyboardVC view];
        self.numberKeyboardViewController = keyboardVC;
		self.numberKeyboardViewController.currencyCode = [self defaultCurrencyCode];
        self.numberKeyboardViewController.keyboardType = A3NumberKeyboardTypeCurrency;
        keyboardVC.textInputTarget = textField;
        keyboardVC.delegate = self;
        self.numberKeyboardViewController = keyboardVC;
    }

    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.firstResponder resignFirstResponder];
	[self setFirstResponder:nil];

	return YES;
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
        
        [self.firstResponder resignFirstResponder];
		[self setFirstResponder:nil];
        
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
        inputCell.selectionStyle = UITableViewCellSelectionStyleNone;
        inputCell.textField.font = [UIFont systemFontOfSize:17];
        inputCell.textField.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
        
        inputCell.titleLabel.text = @"Amounts";
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
        inputCell.selectionStyle = UITableViewCellSelectionStyleNone;
        inputCell.textField.font = [UIFont systemFontOfSize:17];
        
        if ([_items containsObject:self.dateInputItem]) {
            inputCell.textField.textColor = [UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0];
        }
        else {
            inputCell.textField.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
        }
        
        inputCell.titleLabel.text = @"Date";
        inputCell.textField.enabled = NO;
        inputCell.textField.placeholder = @"None";
        
        if (_exPaymentType == A3LC_ExtraPaymentYearly) {
//            if (_loanCalcData.extraPaymentYearlyDate) {
//                
//                NSDate *pickDate = _loanCalcData.extraPaymentYearlyDate;
//                NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:pickDate];
//                NSInteger month = [components month];
//                
//                NSDateFormatter *df = [[NSDateFormatter alloc] init];
//                
//                if (IS_IPAD) {
//                    NSArray *months = [df monthSymbols];
//                    NSString *monthText = months[month - 1];
//                    inputCell.textField.text = monthText;
//                }
//                else {
//                    NSArray *months = [df shortMonthSymbols];
//                    NSString *monthText = months[month - 1];
//                    inputCell.textField.text = monthText;
//                }
//            }
//            else {
//                inputCell.textField.text = @"";
//            }
            
            NSDate *pickDate = ![_loanCalcData extraPaymentYearlyDate] ? [NSDate date] : [_loanCalcData extraPaymentYearlyDate];
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:pickDate];
            NSInteger month = [components month];
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            
            if (IS_IPAD) {
                NSArray *months = [df monthSymbols];
                NSString *monthText = months[month - 1];
                inputCell.textField.text = monthText;
            }
            else {
                NSArray *months = [df shortMonthSymbols];
                NSString *monthText = months[month - 1];
                inputCell.textField.text = monthText;
            }
            
        }
        else if (_exPaymentType == A3LC_ExtraPaymentOnetime) {
//            if (_loanCalcData.extraPaymentOneTimeDate) {
//                NSDate *pickDate = _loanCalcData.extraPaymentOneTimeDate;
//                NSDateFormatter *df = [[NSDateFormatter alloc] init];
//
//                if (IS_IPAD) {
//                    inputCell.textField.text = [df localizedLongStyleYearMonthFromDate:pickDate];
//                }
//                else {
//                    // 한국만 예외적으로 long스타일 적용
//                    NSLocale *locale = [NSLocale currentLocale];
//                    if ([locale.localeIdentifier isEqualToString:@"ko_KR"]) {
//                        inputCell.textField.text = [df localizedLongStyleYearMonthFromDate:pickDate];
//                    }
//                    else {
//                        inputCell.textField.text = [df localizedMediumStyleYearMonthFromDate:pickDate];
//                    }
//                }
//            }
//            else {
//                inputCell.textField.text = @"";
//            }
            NSDate *pickDate = ![_loanCalcData extraPaymentOneTimeDate] ? [NSDate date] : [_loanCalcData extraPaymentOneTimeDate];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            
            if (IS_IPAD) {
                inputCell.textField.text = [df localizedLongStyleYearMonthFromDate:pickDate];
            }
            else {
                // 한국만 예외적으로 long스타일 적용
                NSLocale *locale = [NSLocale currentLocale];
                if ([locale.localeIdentifier isEqualToString:@"ko_KR"]) {
                    inputCell.textField.text = [df localizedLongStyleYearMonthFromDate:pickDate];
                }
                else {
                    inputCell.textField.text = [df localizedMediumStyleYearMonthFromDate:pickDate];
                }
            }
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
            NSDate *pickDate = _loanCalcData.extraPaymentOneTimeDate ? _loanCalcData.extraPaymentOneTimeDate : [NSDate date];
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:pickDate];
            NSUInteger month = [components month];
            NSUInteger year = [components year];
            
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
        else if (_exPaymentType == A3LC_ExtraPaymentYearly) {
            NSDate *pickDate = _loanCalcData.extraPaymentYearlyDate ? _loanCalcData.extraPaymentYearlyDate : [NSDate date];
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:pickDate];
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
    if (self.firstResponder) {
        UITextField *prevTxtField = [self previousTextField:(UITextField *) self.firstResponder];
        if (prevTxtField) {
            [prevTxtField becomeFirstResponder];
        }
    }
}

- (void)nextButtonPressed{
    if (self.firstResponder) {
        UITextField *nextTxtField = [self nextTextField:(UITextField *) self.firstResponder];
        if (nextTxtField) {
            [nextTxtField becomeFirstResponder];
        }
    }
}

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
	UITextField *textField = (UITextField *) self.numberKeyboardViewController.textInputTarget;
	if ([textField isKindOfClass:[UITextField class]]) {
		textField.text = @"";
	}
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
    
    [self.numberKeyboardViewController.textInputTarget resignFirstResponder];
}

- (UIViewController *)modalPresentingParentViewControllerForCalculator {
	_calculatorOutputTargetTextField = (UITextField *) self.firstResponder;
	return self;
}

- (void)calculatorViewController:(UIViewController *)viewController didDismissWithValue:(NSString *)value {
	_calculatorOutputTargetTextField.text = value;
	[self textFieldDidEndEditing:_calculatorOutputTargetTextField];
}

#pragma mark --- Response to Currency Select Button and result

- (void)searchViewController:(UIViewController *)viewController itemSelectedWithItem:(NSString *)selectedItem {
	if ([selectedItem length]) {
		[[NSUserDefaults standardUserDefaults] setObject:selectedItem forKey:A3LoanCalcCustomCurrencyCode];
		[[NSUserDefaults standardUserDefaults] synchronize];

		[[NSNotificationCenter defaultCenter] postNotificationName:A3LoanCalcCurrencyCodeChanged object:nil];

		[self.loanFormatter setCurrencyCode:selectedItem];

		[self.tableView reloadData];
	}
}

- (NSString *)defaultCurrencyCode {
	NSString *code = [[NSUserDefaults standardUserDefaults] objectForKey:A3LoanCalcCustomCurrencyCode];
	if (!code) {
		code = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
	}
	return code;
}

@end
