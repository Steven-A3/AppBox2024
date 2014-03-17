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
#import "LoanCalcData.h"
#import "LoanCalcMode.h"
#import "LoanCalcString.h"
#import "A3NumberKeyboardViewController.h"
#import "common.h"
#import "A3AppDelegate.h"
#import "UIViewController+A3AppCategory.h"
#import "NSMutableArray+A3Sort.h"
#import "NSManagedObject+MagicalFinders.h"
#import "NSManagedObjectContext+MagicalSaves.h"
#import "NSManagedObject+MagicalRecord.h"
#import "NSUserDefaults+A3Defaults.h"
#import "A3UIDevice.h"
#import "UIViewController+MMDrawerController.h"
#import "A3RootViewController_iPad.h"
#import "NSString+conversion.h"
#import "NSDateFormatter+A3Addition.h"

@interface A3LoanCalcExtraPaymentViewController () <A3KeyboardDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
    NSIndexPath *currentIndexPath;
    
    BOOL _isExtraPaymentEdited;
}

@property (nonatomic, strong) UITextField *firstResponder;
@property (nonatomic, strong) UITextField *dateTextField;
@property (nonatomic, strong) NSMutableArray *years;
@property (nonatomic, strong) NSMutableArray *months;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableDictionary *amountItem;
@property (nonatomic, strong) NSMutableDictionary *dateItem;
@property (nonatomic, strong) NSMutableDictionary *dateInputItem;

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

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (_exPaymentType == A3LC_ExtraPaymentYearly) {
        self.navigationItem.title = @"Yearly";
        
        if (_loanCalcData.extraPaymentYearlyDate == nil) {
            _loanCalcData.extraPaymentYearlyDate = [NSDate date];
        }
        
    }
    else if (_exPaymentType == A3LC_ExtraPaymentOnetime) {
        self.navigationItem.title = @"One-Time";
        
        if (_loanCalcData.extraPaymentOneTimeDate == nil) {
            _loanCalcData.extraPaymentOneTimeDate = [NSDate date];
        }
    }
    
    self.tableView.separatorColor = [self tableViewSeparatorColor];
    
    [self registerContentSizeCategoryDidChangeNotification];
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
	@autoreleasepool {
        [_firstResponder resignFirstResponder];
		[self.A3RootViewController dismissRightSideViewController];
	}
}

- (UITextField *)previousTextField:(UITextField *) current
{
    NSUInteger section, row;
    section = currentIndexPath.section;
    row = currentIndexPath.row;
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
    section = currentIndexPath.section;
    row = currentIndexPath.row;
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
    _firstResponder = textField;
    
    textField.text = @"";
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _firstResponder = nil;
    
    // update
    _isExtraPaymentEdited = YES;
    
    double inputFloat = [textField.text doubleValue];
    NSNumber *inputNum = @(inputFloat);
    
    if (currentIndexPath.row == 0) {
        if (_exPaymentType == A3LC_ExtraPaymentYearly) {
            self.loanCalcData.extraPaymentYearly = inputNum;
        }
        else if (_exPaymentType == A3LC_ExtraPaymentOnetime) {
            self.loanCalcData.extraPaymentOneTime = inputNum;
        }
        
        textField.text = [self.currencyFormatter stringFromNumber:inputNum];
    }
    else if (currentIndexPath.row == 1) {
        // 날짜는 datepicker에서 처리함
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
    
    
    UITableViewCell *cell;
    UIView *testView = textField;
    while (testView.superview) {
        if ([testView.superview isKindOfClass:[UITableViewCell class]]) {
            cell = (UITableViewCell *)testView.superview;
            break;
        }
        else {
            testView = testView.superview;
        }
    }
    
    currentIndexPath = [self.tableView indexPathForCell:cell];
    
    if (currentIndexPath.row == 0) {
        // amount
        A3NumberKeyboardViewController *keyboardVC = [self normalNumberKeyboard];
        textField.inputView = [keyboardVC view];
        self.numberKeyboardViewController = keyboardVC;
        self.numberKeyboardViewController.keyboardType = A3NumberKeyboardTypeCurrency;
        keyboardVC.textInputTarget = textField;
        keyboardVC.delegate = self;
        self.numberKeyboardViewController = keyboardVC;
    }
    /*
     else if (currentIndexPath.row == 1) {
     // date
     textField.inputView = self.picker;
     
     // 해당 날짜가 선택되어지도록 (loan데이타에 날짜가 있으면 그날짜를, 없으면 오늘 날짜를)
     if (_exPaymentType == A3LC_ExtraPaymentOnetime) {
     NSDate *pickDate = _loanCalcData.extraPaymentOneTimeDate ? _loanCalcData.extraPaymentOneTimeDate : [NSDate date];
     NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:pickDate];
     NSUInteger month = [components month];
     NSUInteger year = [components year];
     
     [_picker selectRow:month-1 inComponent:0 animated:NO];
     NSUInteger yearIdx = 0;
     for (int i=0; i<_years.count; i++) {
     NSString *yearString = _years[i];
     NSUInteger tmp = yearString.integerValue;
     
     if (tmp == year) {
     yearIdx = i;
     break;
     }
     }
     [_picker selectRow:yearIdx inComponent:1 animated:NO];
     
     }
     else if (_exPaymentType == A3LC_ExtraPaymentYearly) {
     NSDate *pickDate = _loanCalcData.extraPaymentYearlyDate ? _loanCalcData.extraPaymentYearlyDate : [NSDate date];
     NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:pickDate];
     NSUInteger month = [components month];
     
     [_picker selectRow:month-1 inComponent:0 animated:NO];
     }
     }
     */
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_firstResponder resignFirstResponder];
    
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
        
        [_firstResponder resignFirstResponder];
        
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
        inputCell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[self.currencyFormatter stringFromNumber:@(0)]
                                                                                    attributes:@{NSForegroundColorAttributeName:inputCell.textField.textColor}];
        if (_exPaymentType == A3LC_ExtraPaymentYearly) {
            if (_loanCalcData.extraPaymentYearly) {
                inputCell.textField.text = [self.currencyFormatter stringFromNumber:_loanCalcData.extraPaymentYearly];
            }
            else {
                inputCell.textField.text = @"";
            }
        }
        else if (_exPaymentType == A3LC_ExtraPaymentOnetime) {
            if (_loanCalcData.extraPaymentOneTime) {
                inputCell.textField.text = [self.currencyFormatter stringFromNumber:_loanCalcData.extraPaymentOneTime];
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
            if (_loanCalcData.extraPaymentYearlyDate) {
                
                NSDate *pickDate = _loanCalcData.extraPaymentYearlyDate;
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
            else {
                inputCell.textField.text = @"";
            }
        }
        else if (_exPaymentType == A3LC_ExtraPaymentOnetime) {
            if (_loanCalcData.extraPaymentOneTimeDate) {
                NSDate *pickDate = _loanCalcData.extraPaymentOneTimeDate;
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
            else {
                inputCell.textField.text = @"";
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma mark - A3KeyboardDelegate

- (BOOL)isPreviousEntryExists
{
    if ([self previousTextField:_firstResponder]) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)isNextEntryExists{
    if ([self nextTextField:_firstResponder]) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void)prevButtonPressed{
    if (_firstResponder) {
        UITextField *prevTxtField = [self previousTextField:_firstResponder];
        if (prevTxtField) {
            [prevTxtField becomeFirstResponder];
        }
    }
}

- (void)nextButtonPressed{
    if (_firstResponder) {
        UITextField *nextTxtField = [self nextTextField:_firstResponder];
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
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate {
    
    [self.numberKeyboardViewController.textInputTarget resignFirstResponder];
}

@end
