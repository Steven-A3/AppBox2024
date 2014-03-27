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

@interface A3DaysCounterSetupAlertViewController ()
@property (strong, nonatomic) NSArray *itemArray;
@property (strong, nonatomic) NSDate *originalValue;

- (void)showDatePicker;
- (void)hideDatePicker;
- (NSDate*)alarmDateBeforeYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute fromDate:(NSDate*)date;
- (void)cancelAction:(id)sender;
@end

@implementation A3DaysCounterSetupAlertViewController
- (void)showDatePicker
{
    id alarmDate = [_eventModel objectForKey:EventItem_AlertDatetime];
    _datePickerView.date = ( [alarmDate isKindOfClass:[NSDate class]] ? [_eventModel objectForKey:EventItem_AlertDatetime] : [NSDate date] );
    [_eventModel setObject:_datePickerView.date forKey:EventItem_AlertDatetime];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
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
    return [_itemArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return IS_RETINA ? 35.5 : 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 37.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // Configure the cell...
    NSDictionary *item = [_itemArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [item objectForKey:EventRowTitle];
    cell.detailTextLabel.text = @"";
    
    NSInteger alertType = [[A3DaysCounterModelManager sharedManager] alertTypeIndexFromDate:[_eventModel objectForKey:EventItem_StartDate]
                                                                                  alertDate:[_eventModel objectForKey:EventItem_AlertDatetime]];
    NSInteger rowType = [[item objectForKey:EventRowType] integerValue];
    
    if ( rowType  == AlertType_Custom ) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else {
        if (rowType == alertType) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    if ( alertType == AlertType_Custom && [[item objectForKey:EventRowType] integerValue] == alertType ) {
        NSDate *alertDate = [_eventModel objectForKey:EventItem_AlertDatetime];
        if ( alertDate ) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld days before %@",
                                         (long)[A3DateHelper diffDaysFromDate:alertDate
                                                                       toDate:[_eventModel objectForKey:EventItem_StartDate]],
                                         [A3DateHelper dateStringFromDate:alertDate withFormat:@"HH:mm a"] ];//[[A3DaysCounterModelManager sharedManager] alertDateStringFromDate:[_eventModel objectForKey:EventItem_StartDate] alertDate:[_eventModel objectForKey:EventItem_AlertDatetime]];
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id prevValue = [_eventModel objectForKey:EventItem_AlertDatetime];
    id value = nil;
    
    NSDate *startDate = [_eventModel objectForKey:EventItem_StartDate];
    NSInteger prevIndex = [[A3DaysCounterModelManager sharedManager] alertTypeIndexFromDate:startDate alertDate:prevValue];
    switch (indexPath.row) {
        case 0:
            // None
            value = [NSNull null];
            break;
        case 1:
            // at time of event
            value = startDate;
            break;
        case 2:
            // 5 minutes before
            value = [self alarmDateBeforeYear:0 month:0 day:0 hour:0 minute:5 fromDate:startDate];
            break;
        case 3:
            // 15 minutes before
            value = [self alarmDateBeforeYear:0 month:0 day:0 hour:0 minute:15 fromDate:startDate];
            break;
        case 4:
            // 30 minutes before
            value = [self alarmDateBeforeYear:0 month:0 day:0 hour:0 minute:30 fromDate:startDate];
            break;
        case 5:
            // 1 hour before
            value = [self alarmDateBeforeYear:0 month:0 day:0 hour:1 minute:0 fromDate:startDate];
            break;
        case 6:
            // 2 hours before
            value = [self alarmDateBeforeYear:0 month:0 day:0 hour:2 minute:0 fromDate:startDate];
            break;
        case 7:
            // 1 day before
            value = [self alarmDateBeforeYear:0 month:0 day:1 hour:0 minute:0 fromDate:startDate];
            break;
        case 8:
            // 2 days before
            value = [self alarmDateBeforeYear:0 month:0 day:2 hour:0 minute:0 fromDate:startDate];
            break;
        case 9:
            // 1 week before
            value = [self alarmDateBeforeYear:0 month:0 day:7 hour:0 minute:0 fromDate:startDate];
            break;
        case 10:
            value = [NSDate date];
            break;
    }
    
    [_eventModel setObject:value forKey:EventItem_AlertDatetime];
    UITableViewCell *prevCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:prevIndex inSection:0]];
    UITableViewCell *curCell = [self.tableView cellForRowAtIndexPath:indexPath];
    prevCell.accessoryType = UITableViewCellAccessoryNone;
    curCell.accessoryType = UITableViewCellAccessoryCheckmark;

    if ( indexPath.row == ([_itemArray count] -1) ) {
//        [self showDatePicker];
        A3DaysCounterSetupCustomAlertViewController *viewCtrl = [[A3DaysCounterSetupCustomAlertViewController alloc] initWithNibName:@"A3DaysCounterSetupCustomAlertViewController" bundle:nil];
        viewCtrl.eventModel = self.eventModel;
        [self.navigationController pushViewController:viewCtrl animated:YES];
    }
    else {
//        [self hideDatePicker];
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
    
    [_eventModel setObject:datePicker.date forKey:EventItem_AlertDatetime];
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

@end
