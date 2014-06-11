//
//  A3DaysCounterSetupCustomAlertViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 2014. 2. 4..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterSetupCustomAlertViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "A3NumberKeyboardViewController.h"
#import "A3DateHelper.h"
#import "DaysCounterEvent.h"

@interface A3DaysCounterSetupCustomAlertViewController ()
@property (strong, nonatomic) NSMutableArray *tableRowArray;
@property (strong, nonatomic) A3NumberKeyboardViewController* keyboardVC;
@property (assign, nonatomic) NSInteger days;
@property (assign, nonatomic) NSInteger hours;
@property (assign, nonatomic) NSInteger minutes;
@property (strong, nonatomic) NSDate *customAlertDate;
@property (assign, nonatomic) NSInteger customAlertInterval;

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

    self.title = NSLocalizedString(@"Custom", @"Custom");
    self.tableRowArray = [NSMutableArray arrayWithArray:@[@{EventRowTitle : NSLocalizedString(@"Days Before", @"Days Before"), EventRowType: @(CustomAlertCell_DaysBefore)},
                                                          @{EventRowTitle : NSLocalizedString(@"Time", @"Time"), EventRowType : @(CustomAlertCell_Time)}]];
    self.keyboardVC = [self simpleNumberKeyboard];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    
    if ([self isCustomAlertType:_eventModel]) {
        _days = [A3DateHelper diffDaysFromDate:_eventModel.alertDatetime
                                        toDate:_eventModel.effectiveStartDate];
        _customAlertDate = _eventModel.alertDatetime;
        NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:_customAlertDate];
        _hours = comp.hour;
        _minutes = comp.minute;
    }
    else {
        _days = 0;
        _customAlertDate = [NSDate date];
        NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:_customAlertDate];
        _hours = comp.hour;
        _minutes = comp.minute;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)isCustomAlertType:(DaysCounterEvent *)eventModel
{
    if ([eventModel.alertType isEqualToNumber:@1]) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_tableRowArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *cellIDs = @[@"inputCell", @"value1Cell", @"dateInputCell"];
    NSInteger cellType = [[[_tableRowArray objectAtIndex:indexPath.row] objectForKey:EventRowType] integerValue];
    
    NSString *CellIdentifier = [cellIDs objectAtIndex:cellType];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        switch (cellType) {
            case CustomAlertCell_TimeInput:
            {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterAddEventDateInputCell" owner:nil options:nil] lastObject];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UIDatePicker *datePicker = (UIDatePicker*)[cell viewWithTag:10];
                datePicker.datePickerMode = UIDatePickerModeTime;
                [datePicker addTarget:self action:@selector(timeChangedAction:) forControlEvents:UIControlEventValueChanged];
            }
                break;
                
            default:
            {
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
                break;
        }
    }
    
    NSDictionary *item = [_tableRowArray objectAtIndex:indexPath.row];
    switch (cellType) {
        case CustomAlertCell_DaysBefore:
        {
            cell.textLabel.text = [item objectForKey:EventRowTitle];
            
            UITextField *textField = (UITextField*)cell.accessoryView;
            textField.text = [NSString stringWithFormat:@"%ld", (long)_days];
        }
            break;
            
        case CustomAlertCell_Time:
        {
            cell.textLabel.text = [item objectForKey:EventRowTitle];
            
            if (_customAlertDate) {
                cell.detailTextLabel.text = [A3DateHelper dateStringFromDate:_customAlertDate withFormat:@"h:mm a"];
            }
            else {
                cell.detailTextLabel.text = [A3DateHelper dateStringFromDate:[NSDate date] withFormat:@"h:mm a"];
            }
            
            if ( [_tableRowArray count] > 2 ) {
                cell.detailTextLabel.textColor = [UIColor colorWithRed:0.0 green:125.0/255.0 blue:248.0/255.0 alpha:1.0];
            }
            else {
                cell.detailTextLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
            }
        }
            break;
            
        case CustomAlertCell_TimeInput:
        {
            UIDatePicker *datePicker = (UIDatePicker*)[cell viewWithTag:10];
            NSDate *alertDate;
            if ( [self isCustomAlertType:_eventModel] ) {
                alertDate = _customAlertDate;   //[_eventModel objectForKey:EventItem_AlertDatetime];
            }
            else {
                alertDate = [NSDate date];
            }
            
            datePicker.date = alertDate;
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat retHeight = 44.0;
    
    NSDictionary *item = [_tableRowArray objectAtIndex:indexPath.row];
    if ( [[item objectForKey:EventRowType] integerValue] == CustomAlertCell_TimeInput ) {
        retHeight = 236.0;
    }
    
    return retHeight;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [_tableRowArray objectAtIndex:indexPath.row];
    NSInteger cellType = [[item objectForKey:EventRowType] integerValue];
    
    if ( cellType == CustomAlertCell_DaysBefore ) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UITextField *textField = (UITextField*)cell.accessoryView;
        [textField becomeFirstResponder];
    }
    else if ( cellType == CustomAlertCell_Time ) {
        [self.firstResponder resignFirstResponder];

        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [self.tableView reloadData];
        }];
        [tableView beginUpdates];
        if ( [_tableRowArray count] > 2 ) {
            // close
            [_tableRowArray removeObjectAtIndex:indexPath.row+1];
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationMiddle];
        }
        else {
            // open
            [_tableRowArray addObject:@{EventRowTitle : @"", EventRowType : @(CustomAlertCell_TimeInput)}];
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
    [self setFirstResponder:textField];
    
	self.keyboardVC.textInputTarget = textField;
	self.keyboardVC.delegate = self;
	textField.inputView = self.keyboardVC.view;
	textField.text = @"";
    
    if ( [_tableRowArray count] > 2 ) {
        // close
        [_tableRowArray removeObjectAtIndex:2];
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
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];

    if ([textField.text length] == 0) {
        NSDate *alertDate;
        if ([self isCustomAlertType:_eventModel]) {
            alertDate = _eventModel.alertDatetime;
        }
        if (!alertDate) {
            NSLog(@"alertTime이 없던 상황.");
        }
        
        NSDate *startDate = _eventModel.effectiveStartDate;
        _days = labs((long)[A3DateHelper diffDaysFromDate:alertDate toDate:startDate]);
        textField.text = [NSString stringWithFormat:@"%ld", (long)_days];
    }
    else {
        NSDate *effectiveStartDate = _eventModel.effectiveStartDate;
        // AlertTime 구하기. (days, hour, minute 반영)
        NSDateComponents *alertTimeComp = [NSDateComponents new];
        NSDate *alertDate;
        alertTimeComp.day = -[textField.text integerValue];
        
        alertDate = [[NSCalendar currentCalendar] dateByAddingComponents:alertTimeComp
                                                                  toDate:effectiveStartDate options:0];
        alertTimeComp = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit
                                                        fromDate:alertDate];
        alertTimeComp.hour = _hours;        // 지정된 시간으로 설정.
        alertTimeComp.minute = _minutes;
        
        alertDate = [[NSCalendar currentCalendar] dateFromComponents:alertTimeComp];
        self.customAlertDate = alertDate;

        // startTime - alertTime 간격.
        NSDateComponents *alertIntervalComp = [[NSCalendar currentCalendar] components:NSMinuteCalendarUnit
                                                                              fromDate:effectiveStartDate
                                                                                toDate:alertDate
                                                                               options:0];
        self.customAlertInterval = [alertIntervalComp minute];
        
        
        _days = labs((long)[A3DateHelper diffDaysFromDate:self.customAlertDate toDate:effectiveStartDate]);
        _eventModel.alertDatetime = self.customAlertDate;
        _eventModel.alertInterval = @(self.customAlertInterval);
    }
    
    // 커스텀 얼럿 여부 설정.
    NSInteger alertType = [_sharedManager alertTypeIndexFromDate:_eventModel.effectiveStartDate
                                                       alertDate:_eventModel.alertDatetime];
    if (alertType == AlertType_Custom) {
        _eventModel.alertType = @(1);
    }
    else {
        _eventModel.alertType = @(0);
    }
    
    self.firstResponder = nil;
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
    NSDate *effectiveStartDate = _eventModel.effectiveStartDate;
	NSDateComponents *alertTimeComp = [NSDateComponents new];
    alertTimeComp.day = -_days;
    NSDate *alertDate = [[NSCalendar currentCalendar] dateByAddingComponents:alertTimeComp
                                                                      toDate:effectiveStartDate
                                                                     options:0];
    alertTimeComp = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit
                                                    fromDate:alertDate];
    alertTimeComp.hour = _hours;
    alertTimeComp.minute = _minutes;
    alertTimeComp.second = 0;
    alertDate = [[NSCalendar currentCalendar] dateFromComponents:alertTimeComp];

    self.customAlertDate = alertDate;
    
    // alert 간격 저장.
    NSDateComponents *alertIntervalComp = [[NSCalendar currentCalendar] components:NSMinuteCalendarUnit fromDate:effectiveStartDate
                                                                            toDate:alertDate
                                                                           options:0];
    self.customAlertInterval = [alertIntervalComp minute];

    _eventModel.alertDatetime = self.customAlertDate;
    _eventModel.alertInterval = @(self.customAlertInterval);
    
    // alertType 저장.
    NSInteger alertType = [_sharedManager alertTypeIndexFromDate:_eventModel.effectiveStartDate
                                                       alertDate:_eventModel.alertDatetime];
    if (alertType == AlertType_Custom) {
        _eventModel.alertType = @(1);
    }
    else {
        _eventModel.alertType = @(0);
    }

    if ( indexPath ) {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
    }
}
@end
