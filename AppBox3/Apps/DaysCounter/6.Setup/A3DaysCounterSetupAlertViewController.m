//
//  A3DaysCounterSetupAlertViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 22..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterSetupAlertViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "A3DateHelper.h"
#import "A3NumberKeyboardViewController.h"
#import "A3DaysCounterRepeatCustomCell.h"
#import "A3AppDelegate+appearance.h"
#import "DaysCounterEvent.h"
#import "DaysCounterDate.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "DaysCounterEvent+extension.h"

@interface A3DaysCounterSetupAlertViewController () <A3KeyboardDelegate, UITextFieldDelegate>
@property (strong, nonatomic) NSArray *itemArray;
@property (strong, nonatomic) NSDate *originalValue;
@property (strong, nonatomic) A3NumberKeyboardViewController *numberKeyboardVC;
@property (copy, nonatomic) NSString *textBeforeEditingTextField;
@property (weak, nonatomic) UITextField *editingTextField;

@end

@implementation A3DaysCounterSetupAlertViewController

- (id)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {

	}

	return self;
}


- (void)showDatePicker
{
	NSDate *alarmDate = _eventModel.alertDatetime;
	_datePickerView.date = ( [alarmDate isKindOfClass:[NSDate class]] ? _eventModel.alertDatetime : [NSDate date] );

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

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.title = NSLocalizedString(@"Alert", @"Alert");

	self.tableView.showsVerticalScrollIndicator = NO;
	self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);

	self.itemArray = @[@{EventRowTitle : NSLocalizedString(@"Alert_None", @"None"), EventRowType : @(AlertType_None)},
			@{EventRowTitle : NSLocalizedString(@"At time of event", @"At time of event"), EventRowType : @(AlertType_AtTimeOfEvent)},
			@{EventRowTitle : NSLocalizedString(@"5 minutes before", @"5 minutes before"), EventRowType : @(AlertType_5MinutesBefore)},
			@{EventRowTitle : NSLocalizedString(@"15 minutes before", @"15 minutes before"), EventRowType : @(AlertType_15MinutesBefore)},
			@{EventRowTitle : NSLocalizedString(@"30 minutes before", @"30 minutes before"), EventRowType : @(AlertType_30MinutesBefore)},
			@{EventRowTitle : NSLocalizedString(@"1 hour before", @"1 hour before"), EventRowType : @(AlertType_1HourBefore)},
			@{EventRowTitle : NSLocalizedString(@"2 hours before", @"2 hours before"), EventRowType : @(AlertType_2HoursBefore)},
			@{EventRowTitle : NSLocalizedString(@"1 day before", @"1 day before"), EventRowType : @(AlertType_1DayBefore)},
			@{EventRowTitle : NSLocalizedString(@"2 days before", @"2 days before"), EventRowType : @(AlertType_2DaysBefore)},
			@{EventRowTitle : NSLocalizedString(@"1 week before", @"1 week before"), EventRowType : @(AlertType_1WeekBefore)},
			@{EventRowTitle : NSLocalizedString(@"Custom", @"Custom"), EventRowType : @(AlertType_Custom)}];

	self.originalValue = _eventModel.alertDatetime;
	self.numberKeyboardVC = [self simplePrevNextNumberKeyboard];
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

- (void)willDismissFromRightSide
{
	if (IS_IPAD && _dismissCompletionBlock) {
		_dismissCompletionBlock();
	}
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
	NSInteger alertType = [_sharedManager alertTypeIndexFromDate:_eventModel.effectiveStartDate
                                                      alertDate:_eventModel.alertDatetime];
	NSInteger rowType = [[item objectForKey:EventRowType] integerValue];
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
	if (cell == nil) {
		if ((indexPath.row == ([_itemArray count] - 1))) {
			cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterAddEventRepeatCell" owner:nil options:nil] lastObject];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			UILabel *label = (UILabel *)[cell viewWithTag:10];
			label.text = NSLocalizedString(@"Custom", nil);
			UITextField *textField = (UITextField*)[cell viewWithTag:12];
			textField.delegate = self;
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
        
		if ([_eventModel.alertType isEqualToNumber:@1]) {  // Custom Type
			NSInteger days = (long)[A3DateHelper diffDaysFromDate:_eventModel.alertDatetime
														   toDate:_eventModel.effectiveStartDate];
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
		UILabel *detailLabel = (UILabel*)[cell viewWithTag:11];
		detailLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld days before(NO NUMBER)", @"StringsDict", nil), (long)[textField.text integerValue]];
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (_editingTextField) {
		[_editingTextField resignFirstResponder];
	}

	id prevValue = _eventModel.alertDatetime;
	id value = nil;

	NSDate *startDate = [[_eventModel startDate] solarDate];
	NSInteger prevIndex = [_sharedManager alertTypeIndexFromDate:startDate alertDate:prevValue];
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


	if (indexPath.row == ([_itemArray count] - 1)) {
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		UITextField *textField = (UITextField *) [cell viewWithTag:12];
		[textField becomeFirstResponder];
	}
	else {
		if (alertTimeInterval == -1) {
			// none, 얼럿 제거.
			_eventModel.alertDatetime = nil;
			_eventModel.alertInterval = @(alertTimeInterval);
			_eventModel.alertType = @(0);
			[self doneButtonAction:nil];
			return;
		}

		UITableViewCell *prevCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:prevIndex inSection:0]];
		UITableViewCell *curCell = [self.tableView cellForRowAtIndexPath:indexPath];
		prevCell.accessoryType = UITableViewCellAccessoryNone;
		curCell.accessoryType = UITableViewCellAccessoryCheckmark;

		NSDate *effectiveStartDate = _eventModel.effectiveStartDate;
		NSCalendar *calendar = [NSCalendar currentCalendar];
		NSDateComponents *addComponent = [[NSDateComponents alloc] init];
		addComponent.minute = -alertTimeInterval;
		NSDate *effectiveAlertDate = [calendar dateByAddingComponents:addComponent toDate:effectiveStartDate options:0];
		_eventModel.alertDatetime = effectiveAlertDate;
		_eventModel.alertInterval = @(alertTimeInterval);

		// alertType 저장.
		NSInteger alertType = [_sharedManager alertTypeIndexFromDate:_eventModel.effectiveStartDate
                                                           alertDate:_eventModel.alertDatetime];
		if (alertType == AlertType_Custom) {
			_eventModel.alertType = @(1);
		}
		else {
			_eventModel.alertType = @(0);
		}

		[self doneButtonAction:nil];
	}
}

- (IBAction)dateChangedAction:(id)sender {
	UIDatePicker *datePicker = (UIDatePicker*)sender;

	NSDate *startDate = [[_eventModel startDate] solarDate];
	NSDate *today = [NSDate date];
    
	if ( [today timeIntervalSince1970] > [startDate timeIntervalSince1970] && [datePicker.date timeIntervalSince1970] < [today timeIntervalSince1970] ) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
															message:NSLocalizedString(@"Please enter your dates in the future.", @"Please enter your dates in the future.")
														   delegate:nil
												  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
												  otherButtonTitles:nil];
		[alertView show];
		return;
	}
    
	NSCalendar *calendar = [[A3AppDelegate instance] calendar];
	NSDateComponents *dateComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:datePicker.date];
	dateComp.second = 0;
	_eventModel.alertDatetime = [calendar dateFromComponents:dateComp];
	[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[_itemArray count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)cancelAction:(id)sender
{
	_eventModel.alertDatetime = self.originalValue;

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
        
		if (_dismissCompletionBlock) {
			_dismissCompletionBlock();
		}
	}
}
#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	self.editingTextField = textField;

	self.numberKeyboardVC.textInputTarget = textField;
	self.numberKeyboardVC.delegate = self;
	textField.inputView = self.numberKeyboardVC.view;
	self.textBeforeEditingTextField = textField.text;
	textField.text = @"";
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	self.editingTextField = nil;

	if (![textField.text length]) {
		textField.text = _textBeforeEditingTextField;
	}

	NSInteger days = [textField.text integerValue];
	if (days > 0) {
		NSDate *alertDate = [A3DateHelper dateByAddingDays:-days fromDate:_eventModel.effectiveStartDate];
		NSDateComponents *alertIntervalComp = [[NSCalendar currentCalendar] components:NSMinuteCalendarUnit fromDate:_eventModel.effectiveStartDate
																				toDate:alertDate
																			   options:0];
		_eventModel.alertDatetime = alertDate;
		_eventModel.alertInterval = @(labs([alertIntervalComp minute]));
	}
	else {
		_eventModel.alertDatetime = nil;
		_eventModel.alertInterval = nil;
	}
    
	NSInteger alertType = [_sharedManager alertTypeIndexFromDate:_eventModel.effectiveStartDate
                                                       alertDate:_eventModel.alertDatetime];
	if (alertType == AlertType_Custom) {
		_eventModel.alertType = @(1);
	}
	else {
		_eventModel.alertType = @(0);
	}
    
	[self.tableView reloadData];
}

#pragma mark - A3KeyboardDelegate

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate;
{
	[keyInputDelegate resignFirstResponder];
}

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
	UITextField *textField = (UITextField *) keyInputDelegate;
	textField.text = @"";
	_textBeforeEditingTextField = @"";
}

@end
