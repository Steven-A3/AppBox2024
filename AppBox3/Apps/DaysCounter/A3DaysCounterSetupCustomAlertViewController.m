//
//  A3DaysCounterSetupCustomAlertViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 2014. 2. 4..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterSetupCustomAlertViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "A3NumberKeyboardViewController.h"
#import "A3DateHelper.h"


@interface A3DaysCounterSetupCustomAlertViewController ()
@property (strong, nonatomic) NSMutableArray *templateArray;
@property (strong, nonatomic) A3NumberKeyboardViewController* keyboardVC;
@property (assign, nonatomic) NSInteger days;
@property (assign, nonatomic) NSInteger hours;
@property (assign, nonatomic) NSInteger minutes;

- (void)timeChangedAction:(id)sender;

@end

@implementation A3DaysCounterSetupCustomAlertViewController

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

    self.title = @"Custom";
    self.templateArray = [NSMutableArray arrayWithArray:@[@{EventRowTitle : @"Days Before", EventRowType: @(CustomAlertCell_DaysBefore)},
                                                          @{EventRowTitle : @"Time", EventRowType : @(CustomAlertCell_Time)}]];
    self.keyboardVC = [self simpleNumberKeyboard];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    
//    if ([[_eventModel objectForKey:EventItem_AlertDateType] isEqualToNumber:@1]) {
//        _days = [A3DateHelper diffDaysFromDate:[_eventModel objectForKey:EventItem_EffectiveStartDate] toDate:[_eventModel objectForKey:EventItem_AlertDatetime]];
//        alertDate = [_eventModel objectForKey:EventItem_AlertDatetime];
//    }
//    
//    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:];
//    _hours = comp.hour;
//    _minutes = comp.minute;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_templateArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *cellIDs = @[@"inputCell", @"value1Cell", @"dateInputCell"];
    NSInteger cellType = [[[_templateArray objectAtIndex:indexPath.row] objectForKey:EventRowType] integerValue];
    
    NSString *CellIdentifier = [cellIDs objectAtIndex:cellType];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        if ( cellType == CustomAlertCell_TimeInput ) {
            NSArray *cellArray = [[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterAddEventCell" owner:nil options:nil];
            cell = [cellArray objectAtIndex:6];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIDatePicker *datePicker = (UIDatePicker*)[cell viewWithTag:10];
            datePicker.datePickerMode = UIDatePickerModeTime;
            [datePicker addTarget:self action:@selector(timeChangedAction:) forControlEvents:UIControlEventValueChanged];
        }
        else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if ( cellType == CustomAlertCell_DaysBefore ) {
                UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 80.0, cell.contentView.frame.size.height)];
                textField.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
                textField.textAlignment = NSTextAlignmentRight;
                textField.borderStyle = UITextBorderStyleNone;
                textField.delegate = self;
                cell.accessoryView = textField;
            }
        }
    }
    
    NSDictionary *item = [_templateArray objectAtIndex:indexPath.row];
    if ( cellType != CustomAlertCell_TimeInput ) {
        cell.textLabel.text = [item objectForKey:EventRowTitle];
        
        NSDate *alertDate;
        if ([[_eventModel objectForKey:EventItem_AlertDateType] isEqualToNumber:@1]) {
            alertDate = [_eventModel objectForKey:EventItem_AlertDatetime];
        }
        
        if ( cellType == CustomAlertCell_DaysBefore ) {
            NSDate *effectiveStartDate = [_eventModel objectForKey:EventItem_EffectiveStartDate];
            UITextField *textField = (UITextField*)cell.accessoryView;
            if ( alertDate == nil ) {
                textField.text = @"0";
            }
            else {
                textField.text = [NSString stringWithFormat:@"%ld", labs((long)[A3DateHelper diffDaysFromDate:alertDate toDate:effectiveStartDate])];
            }
        }
        else if ( cellType == CustomAlertCell_Time ) {
            cell.detailTextLabel.text = alertDate ? [A3DateHelper dateStringFromDate:alertDate withFormat:@"h:mm a"] : nil;
            
            if ( [_templateArray count] > 2 ) {
                cell.detailTextLabel.textColor = [UIColor colorWithRed:0.0 green:125.0/255.0 blue:248.0/255.0 alpha:1.0];
            }
            else {
                cell.detailTextLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
            }
        }
    }
    else if (cellType == CustomAlertCell_TimeInput) {
        UIDatePicker *datePicker = (UIDatePicker*)[cell viewWithTag:10];
        NSDate *alertDate;
        if ([[_eventModel objectForKey:EventItem_AlertDateType] isEqualToNumber:@1]) {
            alertDate = [_eventModel objectForKey:EventItem_AlertDatetime];
        }
        else {
            alertDate = [NSDate date];
        }

        datePicker.date = alertDate;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat retHeight = 44.0;
    
    NSDictionary *item = [_templateArray objectAtIndex:indexPath.row];
    if ( [[item objectForKey:EventRowType] integerValue] == CustomAlertCell_TimeInput ) {
        retHeight = 236.0;
    }
    
    return retHeight;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [_templateArray objectAtIndex:indexPath.row];
    NSInteger cellType = [[item objectForKey:EventRowType] integerValue];
    
    if ( cellType == CustomAlertCell_DaysBefore ) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UITextField *textField = (UITextField*)cell.accessoryView;
        [textField becomeFirstResponder];
    }
    else if ( cellType == CustomAlertCell_Time ) {
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [self.tableView reloadData];
        }];
        [tableView beginUpdates];
        if ( [_templateArray count] > 2 ) {
            // close
            [_templateArray removeObjectAtIndex:indexPath.row+1];
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationMiddle];
        }
        else {
            // open
            [_templateArray addObject:@{EventRowTitle : @"", EventRowType : @(CustomAlertCell_TimeInput)}];
            [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationMiddle];
        }
        [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [tableView endUpdates];
        [CATransaction commit];
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidChange:(NSNotification*)noti
{
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	self.keyboardVC.textInputTarget = textField;
	self.keyboardVC.delegate = self;
	textField.inputView = self.keyboardVC.view;
	textField.text = @"";
    
    if ( [_templateArray count] > 2 ) {
        // close
        [_templateArray removeObjectAtIndex:2];
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationMiddle];
        [CATransaction commit];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.text length] == 0) {
        
        NSDate *alertDate;
        if ([[_eventModel objectForKey:EventItem_AlertDateType] isEqualToNumber:@1]) {
            alertDate = [_eventModel objectForKey:EventItem_AlertDatetime];
        }
        
        if (alertDate) {
            NSDate *startDate = [_eventModel objectForKey:EventItem_EffectiveStartDate];
            textField.text = [NSString stringWithFormat:@"%ld", labs((long)[A3DateHelper diffDaysFromDate:alertDate toDate:startDate])];
        }
    }
    else {
        NSDate *effectiveStartDate = [_eventModel objectForKey:EventItem_EffectiveStartDate];
        NSDateComponents *alertTimeComp = [NSDateComponents new];
        _days = [textField.text integerValue];
        alertTimeComp.day = -_days;
        NSDate *alertDate = [[NSCalendar currentCalendar] dateByAddingComponents:alertTimeComp toDate:effectiveStartDate options:0];
        alertTimeComp = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:alertDate];
        alertTimeComp.hour = _hours;        // 지정된 시간으로 설정.
        alertTimeComp.minute = _minutes;
        alertDate = [[NSCalendar currentCalendar] dateFromComponents:alertTimeComp];
        [_eventModel setObject:alertDate forKey:EventItem_AlertDatetime];
        
        NSDateComponents *alertIntervalComp = [[NSCalendar currentCalendar] components:NSMinuteCalendarUnit fromDate:effectiveStartDate toDate:alertDate options:0];
        [_eventModel setObject:@(alertIntervalComp.minute) forKey:EventItem_AlertDatetimeInterval];
    }
    
    NSInteger alertType = [[A3DaysCounterModelManager sharedManager] alertTypeIndexFromDate:[_eventModel objectForKey:EventItem_EffectiveStartDate] alertDate:[_eventModel objectForKey:EventItem_AlertDatetime]];
    if (alertType == AlertType_Custom) {
        [_eventModel setObject:@(1) forKey:EventItem_AlertDateType];
    }
    else {
        [_eventModel setObject:@(0) forKey:EventItem_AlertDateType];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

#pragma mark - A3KeyboardDelegate
- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate;
{
    [keyInputDelegate resignFirstResponder];
}

#pragma mark - action method
- (void)timeChangedAction:(id)sender
{
    UIDatePicker *datePicker = (UIDatePicker*)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[datePicker.superview superview] superview]];

    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:datePicker.date];
    _hours = comp.hour;
    _minutes = comp.minute;
    
    // alert 저장 (Effective)
    NSDate *effectiveStartDate = [_eventModel objectForKey:EventItem_EffectiveStartDate];
	NSDateComponents *alertTimeComp = [NSDateComponents new];
    alertTimeComp.day = -_days;
    NSDate *alertDate = [[NSCalendar currentCalendar] dateByAddingComponents:alertTimeComp toDate:effectiveStartDate options:0];
    alertTimeComp = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:alertDate];
    alertTimeComp.hour = _hours;
    alertTimeComp.minute = _minutes;
    alertDate = [[NSCalendar currentCalendar] dateFromComponents:alertTimeComp];
    [_eventModel setObject:alertDate forKey:EventItem_AlertDatetime];
    
    // alert 간격 저장.
    NSDateComponents *alertIntervalComp = [[NSCalendar currentCalendar] components:NSMinuteCalendarUnit fromDate:effectiveStartDate toDate:alertDate options:0];
    [_eventModel setObject:@(alertIntervalComp.minute) forKey:EventItem_AlertDatetimeInterval];
    
    // alertType 저장.
    NSInteger alertType = [[A3DaysCounterModelManager sharedManager] alertTypeIndexFromDate:[_eventModel objectForKey:EventItem_EffectiveStartDate] alertDate:[_eventModel objectForKey:EventItem_AlertDatetime]];
    if (alertType == AlertType_Custom) {
        [_eventModel setObject:@(1) forKey:EventItem_AlertDateType];
    }
    else {
        [_eventModel setObject:@(0) forKey:EventItem_AlertDateType];
    }

    if ( indexPath ) {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
    }
}
@end
