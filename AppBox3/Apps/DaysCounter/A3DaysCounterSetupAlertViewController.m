    //
//  A3DaysCounterSetupAlertViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 22..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterSetupAlertViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "A3Formatter.h"
#import "SFKImage.h"
#import "A3DaysCounterSetupCustomAlertViewController.h"
#import "A3DateHelper.h"
#import "A3NumberKeyboardViewController.h"
#import "A3DaysCounterRepeatCustomCell.h"
#import "A3AppDelegate+appearance.h"

@interface A3DaysCounterSetupAlertViewController () <A3KeyboardDelegate, UITextFieldDelegate>
@property (strong, nonatomic) NSArray *itemArray;
@property (strong, nonatomic) NSDate *originalValue;
@property (strong, nonatomic) A3NumberKeyboardViewController *numberKeyboardVC;

- (void)showDatePicker;
- (void)hideDatePicker;
- (NSDate*)alarmDateBeforeYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute fromDate:(NSDate*)date;
- (void)cancelAction:(id)sender;
@end

@implementation A3DaysCounterSetupAlertViewController
- (void)showDatePicker
{
    NSDate *alarmDate = [_eventModel objectForKey:EventItem_AlertDatetime];
    _datePickerView.date = ( [alarmDate isKindOfClass:[NSDate class]] ? [_eventModel objectForKey:EventItem_AlertDatetime] : [NSDate date] );

    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[_itemArray count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView setTableFooterView:self.datePickerView];
    [self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentSize.height - _datePickerView.frame.size.height, self.tableView.frame.size.width, _datePickerView.frame.size.height) animated:YES];
}
- (void)hideDatePicker
{
    [self.tableView setTableFooterView:nil];
}

- (NSDate*)alarmDateBeforeYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute fromDate:(NSDate*)date
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:-year];
    [comps setMonth:-month];
    [comps setDay:-day];
    [comps setHour:-hour];
    [comps setMinute:-minute];
    NSDate *diffDate = [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:date options:0];
    
    return diffDate;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Alert";
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    
    self.itemArray = @[@{EventRowTitle : @"None", EventRowType : @(AlertType_None)},
                       @{EventRowTitle : @"At time of event", EventRowType : @(AlertType_AtTimeOfEvent)},
                       @{EventRowTitle : @"5 minutes before", EventRowType : @(AlertType_5MinutesBefore)},
                       @{EventRowTitle : @"15 minutes before", EventRowType : @(AlertType_15MinutesBefore)},
                       @{EventRowTitle : @"30 minutes before", EventRowType : @(AlertType_30MinutesBefore)},
                       @{EventRowTitle : @"1 hour before", EventRowType : @(AlertType_1HourBefore)},
                       @{EventRowTitle : @"2 hours before", EventRowType : @(AlertType_2HoursBefore)},
                       @{EventRowTitle : @"1 day before", EventRowType : @(AlertType_1DayBefore)},
                       @{EventRowTitle : @"2 days before", EventRowType : @(AlertType_2DaysBefore)},
                       @{EventRowTitle : @"1 week before", EventRowType : @(AlertType_1WeekBefore)},
                       @{EventRowTitle : @"Custom", EventRowType : @(AlertType_Custom)}];

    self.originalValue = [_eventModel objectForKey:EventItem_AlertDatetime];
    self.numberKeyboardVC = [self simpleNumberKeyboard];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_itemArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 37.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = (indexPath.row == ([_itemArray count]-1) ? @"customInputCell" : @"Cell");
    
    NSDictionary *item = [_itemArray objectAtIndex:indexPath.row];
    NSInteger alertType = [[A3DaysCounterModelManager sharedManager] alertTypeIndexFromDate:[_eventModel objectForKey:EventItem_EffectiveStartDate]
                                                                                  alertDate:[_eventModel objectForKey:EventItem_AlertDatetime]];
    NSInteger rowType = [[item objectForKey:EventRowType] integerValue];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (cell == nil) {
        if ((indexPath.row == ([_itemArray count] - 1))) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterAddEventRepeatCell" owner:nil options:nil] lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UITextField *textField = (UITextField*)[cell viewWithTag:12];
            textField.delegate = self;
            UILabel *detailLabel = (UILabel*)[cell viewWithTag:11];
            detailLabel.text = @"day(s) before";
            ((A3DaysCounterRepeatCustomCell *)cell).daysLabelWidthConst.constant = 100;
            ((A3DaysCounterRepeatCustomCell *)cell).checkImageView.image = [[UIImage imageNamed:@"check_02"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [((A3DaysCounterRepeatCustomCell *)cell).checkImageView setTintColor:[A3AppDelegate instance].themeColor];
            [self setCheckmarkOnCustomInputCell:cell CheckShow:NO];
        }
        else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
    }
    
    // Configure the cell...
    if ((indexPath.row == ([_itemArray count]-1))) {
        UITextField *textField = (UITextField*)[cell viewWithTag:12];
        if ([[_eventModel objectForKey:EventItem_AlertDateType] isEqualToNumber:@1]) {  // Custom Type
            NSInteger days = (long)[A3DateHelper diffDaysFromDate:[_eventModel objectForKey:EventItem_AlertDatetime]
                                                           toDate:[_eventModel objectForKey:EventItem_EffectiveStartDate]];
            textField.text = [NSString stringWithFormat:@"%ld", (long)days];

            if (days > 1) {
                [self setCheckmarkOnCustomInputCell:cell CheckShow:YES];
            }
            else {
                [self setCheckmarkOnCustomInputCell:cell CheckShow:NO];
            }
        }
        else {
            textField.text = @"0";
            [self setCheckmarkOnCustomInputCell:cell CheckShow:NO];
        }
    }
    else {
        cell.textLabel.text = [item objectForKey:EventRowTitle];
        cell.detailTextLabel.text = @"";
        
        if (rowType == alertType) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}

- (void)setCheckmarkOnCustomInputCell:(UITableViewCell *)cell CheckShow:(BOOL)show
{
    if (show) {
        ((A3DaysCounterRepeatCustomCell *)cell).checkImageView.hidden = NO;
        ((A3DaysCounterRepeatCustomCell *)cell).daysLabelTrailingConst.constant = 33;
    }
    else {
        ((A3DaysCounterRepeatCustomCell *)cell).checkImageView.hidden = YES;
        ((A3DaysCounterRepeatCustomCell *)cell).daysLabelTrailingConst.constant = 15;
    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id prevValue = [_eventModel objectForKey:EventItem_AlertDatetime];
    id value = nil;
    
    NSDate *startDate = [_eventModel objectForKey:EventItem_StartDate];
    NSInteger prevIndex = [[A3DaysCounterModelManager sharedManager] alertTypeIndexFromDate:startDate alertDate:prevValue];
    double alertTimeInterval;
    
    switch (indexPath.row) {
        case 0:
            // None
            value = [NSNull null];
            alertTimeInterval = -1;
            break;
        case 1:
            // at time of event
            value = startDate;
            alertTimeInterval = 0;
            break;
        case 2:
            // 5 minutes before
            alertTimeInterval = 5;
            break;
        case 3:
            // 15 minutes before
            alertTimeInterval = 15;
            break;
        case 4:
            // 30 minutes before
            alertTimeInterval = 30;
            break;
        case 5:
            // 1 hour before
            alertTimeInterval = 60;
            break;
        case 6:
            // 2 hours before
            alertTimeInterval = 120;
            break;
        case 7:
            // 1 day before
            alertTimeInterval = 1440;
            break;
        case 8:
            // 2 days before
            alertTimeInterval = 2880;
            break;
        case 9:
            // 1 week before
            alertTimeInterval = 10080;
            break;
        case 10:
            //value = [NSDate date];
            alertTimeInterval = 999;
            break;
    }
    

    if ( indexPath.row == ([_itemArray count] -1) ) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UITextField *textField = (UITextField*)[cell viewWithTag:12];
        [textField becomeFirstResponder];
    }
    else {
        if (alertTimeInterval == -1) {
            // none, 얼럿 제거.
            [_eventModel setObject:[NSNull null] forKey:EventItem_AlertDatetime];
            [_eventModel setObject:@(alertTimeInterval) forKey:EventItem_AlertDatetimeInterval];
            [_eventModel setObject:@(0) forKey:EventItem_AlertDateType];
            [self doneButtonAction:nil];
            return;
        }
        
        UITableViewCell *prevCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:prevIndex inSection:0]];
        UITableViewCell *curCell = [self.tableView cellForRowAtIndexPath:indexPath];
        prevCell.accessoryType = UITableViewCellAccessoryNone;
        curCell.accessoryType = UITableViewCellAccessoryCheckmark;

        NSDate *effectiveStartDate = [_eventModel objectForKey:EventItem_EffectiveStartDate];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *addComponent = [[NSDateComponents alloc] init];
        addComponent.minute = -alertTimeInterval;
        NSDate *effectiveAlertDate = [calendar dateByAddingComponents:addComponent toDate:effectiveStartDate options:0];
        [_eventModel setObject:effectiveAlertDate forKey:EventItem_AlertDatetime];
        [_eventModel setObject:@(alertTimeInterval) forKey:EventItem_AlertDatetimeInterval];
        
        // alertType 저장.
        NSInteger alertType = [[A3DaysCounterModelManager sharedManager] alertTypeIndexFromDate:[_eventModel objectForKey:EventItem_EffectiveStartDate]
                                                                                      alertDate:[_eventModel objectForKey:EventItem_AlertDatetime]];
        if (alertType == AlertType_Custom) {
            [_eventModel setObject:@(1) forKey:EventItem_AlertDateType];
        }
        else {
            [_eventModel setObject:@(0) forKey:EventItem_AlertDateType];
        }
        
        [self doneButtonAction:nil];
    }
}

- (IBAction)dateChangedAction:(id)sender {
    UIDatePicker *datePicker = (UIDatePicker*)sender;
    
    NSDate *startDate = [_eventModel objectForKey:EventItem_StartDate];
    NSDate *today = [NSDate date];
    
    if ( [today timeIntervalSince1970] > [startDate timeIntervalSince1970] && [datePicker.date timeIntervalSince1970] < [today timeIntervalSince1970] ) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter your dates in the future." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:datePicker.date];
    dateComp.second = 0;
    [_eventModel setObject:[calendar dateFromComponents:dateComp] forKey:EventItem_AlertDatetime];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[_itemArray count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)cancelAction:(id)sender
{
    [_eventModel setObject:self.originalValue forKey:EventItem_AlertDatetime];
    if ( IS_IPAD ) {
        [self.A3RootViewController dismissRightSideViewController];
        [self.A3RootViewController.centerNavigationController viewWillAppear:YES];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)doneButtonAction:(UIBarButtonItem *)button
{
    if ( IS_IPAD ) {
        [self.A3RootViewController dismissRightSideViewController];
        [self.A3RootViewController.centerNavigationController viewWillAppear:YES];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    if (_dismissCompletionBlock) {
        _dismissCompletionBlock();
    }
}
#pragma mark - UITextFieldDelegate
- (void)textFieldDidChange:(NSNotification*)noti
{
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	self.numberKeyboardVC.textInputTarget = textField;
	self.numberKeyboardVC.delegate = self;
	textField.inputView = self.numberKeyboardVC.view;
	textField.text = @"";
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    
    NSInteger days = [textField.text integerValue];
    if (days > 0) {
        NSDate *alertDate = [A3DateHelper dateByAddingDays:-days fromDate:[_eventModel objectForKey:EventItem_EffectiveStartDate]];
        NSDateComponents *alertIntervalComp = [[NSCalendar currentCalendar] components:NSMinuteCalendarUnit fromDate:[_eventModel objectForKey:EventItem_EffectiveStartDate]
                                                                                toDate:alertDate
                                                                               options:0];
        [_eventModel setObject:alertDate forKey:EventItem_AlertDatetime];
        [_eventModel setObject:@(labs([alertIntervalComp minute])) forKey:EventItem_AlertDatetimeInterval];
    }
    else {
        [_eventModel removeObjectForKey:EventItem_AlertDatetime];
        [_eventModel removeObjectForKey:EventItem_AlertDatetimeInterval];
    }
    
    NSInteger alertType = [[A3DaysCounterModelManager sharedManager] alertTypeIndexFromDate:[_eventModel objectForKey:EventItem_EffectiveStartDate]
                                                                                  alertDate:[_eventModel objectForKey:EventItem_AlertDatetime]];
    if (alertType == AlertType_Custom) {
        [_eventModel setObject:@(1) forKey:EventItem_AlertDateType];
    }
    else {
        [_eventModel setObject:@(0) forKey:EventItem_AlertDateType];
    }
    
    [self.tableView reloadData];
}

#pragma mark - A3KeyboardDelegate
- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate;
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[_itemArray count]-1 inSection:0]];
    UITextField *textField = (UITextField*)[cell viewWithTag:12];
    [textField resignFirstResponder];
}

@end
