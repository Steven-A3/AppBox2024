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
    return IS_RETINA ? 35.5 : 35;
}

//- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 35.0;
//}

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
        NSDate *alertDate = [_eventModel objectForKey:EventItem_AlertDatetime];
        if (!alertDate || [alertDate isKindOfClass:[NSNull class]]) {
            alertDate = [NSDate date];
        }
        
        if ( cellType == CustomAlertCell_DaysBefore ) {
            NSDate *startDate = [_eventModel objectForKey:EventItem_StartDate];

            UITextField *textField = (UITextField*)cell.accessoryView;
            if ( alertDate == nil ) {
                textField.text = @"";
            }
            else {
                textField.text = [NSString stringWithFormat:@"%ld", labs((long)[A3DateHelper diffDaysFromDate:alertDate toDate:startDate])];
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
    UITextField *textField = noti.object;
    NSInteger days = [textField.text integerValue];
    NSDate *startDate = [_eventModel objectForKey:EventItem_StartDate];
    [_eventModel setObject:[A3DateHelper dateByAddingDays:-days fromDate:startDate] forKey:EventItem_AlertDatetime];
//    [_settingDict setObject:@(days) forKey:SettingItem_CustomAlertDays];
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
        NSDate *alertDate = [_eventModel objectForKey:EventItem_AlertDatetime];
        NSDate *startDate = [_eventModel objectForKey:EventItem_StartDate];
        if (alertDate) {
            textField.text = [NSString stringWithFormat:@"%ld", labs((long)[A3DateHelper diffDaysFromDate:alertDate toDate:startDate])];
        }
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
  
    NSDate *alertDate = [_eventModel objectForKey:EventItem_AlertDatetime];
    if ( alertDate == nil ) {
        alertDate = [_eventModel objectForKey:EventItem_StartDate];
    }
    
    [_eventModel setObject:[A3DateHelper dateMakeDate:alertDate
                                                 Hour:[A3DateHelper hour24FromDate:datePicker.date]
                                               minute:[A3DateHelper minuteFromDate:datePicker.date]]
                    forKey:EventItem_AlertDatetime];

    if ( indexPath )
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
}
@end
