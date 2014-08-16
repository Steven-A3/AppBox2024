//
//  A3DaysCounterAddAndEditCalendarViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 1..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterAddAndEditCalendarViewController.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "UIViewController+iPad_rightSideView.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3SyncManager.h"
#import "DaysCounterCalendar.h"
#import "NSManagedObject+extension.h"

@interface A3DaysCounterAddAndEditCalendarViewController ()
@property (strong, nonatomic) NSArray *colorArray;

@end

@implementation A3DaysCounterAddAndEditCalendarViewController

- (id)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {

	}

	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = (_isEditMode ? NSLocalizedString(@"Edit Calendar", @"Edit Calendar") : NSLocalizedString(@"Add Calendar", @"Add Calendar"));

	self.tableView.showsVerticalScrollIndicator = NO;
	self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.separatorInset = A3UITableViewSeparatorInset;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    [self rightBarButtonDoneButton];
    
    self.colorArray = [_sharedManager calendarColorArray];
    
    if ( !_isEditMode ) {
		self.calendar = [DaysCounterCalendar MR_createEntityInContext:self.savingContext];
		_calendar.uniqueID = [[NSUUID UUID] UUIDString];
		_calendar.isShow = @YES;
		_calendar.colorID = @6;
		_calendar.type = @(CalendarCellType_User);
    }

	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willDismissRightSideView) name:A3NotificationRightSideViewWillDismiss object:nil];
	}
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationRightSideViewWillDismiss object:nil];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ( !self.isEditMode ) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        if ( cell ) {
            UITextField *textField = (UITextField*)[cell viewWithTag:10];
            [textField becomeFirstResponder];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willDismissRightSideView {
	[self dismissViewControllerAnimated:NO completion:nil];
}

- (NSManagedObjectContext *)savingContext {
	if (!_savingContext) {
		_savingContext = [NSManagedObjectContext MR_newContext];
	}
	return _savingContext;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_isEditMode) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %@", @(CalendarCellType_User)];
		if ([[[A3DaysCounterModelManager calendars] filteredArrayUsingPredicate:predicate] count] == 1) {
            return 2;
        }
        
        return 3;
    }
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = 0;
    if ( section == 0 )
        rowCount = 1;
	else if ( section == 1 ) {
		// 사용자가 선택할 수 있는 색은 9개로 고정. 이하 세가지는 시스템 캘린더용으로 선택용으로 제공하지 않는다.
		rowCount = 9;
//		rowCount = [_colorArray count];
	}
    else if ( section == 2 )
        rowCount = 1;
    return rowCount;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"";
    if ( section == 1 )
        title = NSLocalizedString(@"COLOR", @"COLOR");
    return title;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ( section == 0 ) {
        return 35;
    }
    else if ( section ==1 ) {
        return 55;
    }
    
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %@", @(CalendarCellType_User)];
    BOOL hasOneCalendar = [[[A3DaysCounterModelManager calendars] filteredArrayUsingPredicate:predicate] count] == 1;

    if ( section == ((_isEditMode && !hasOneCalendar) ? 2 : 1) ) {
        return 38;
    }
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = (indexPath.section == 0 ? @"inputCell" : (indexPath.section > 1 ? @"deleteCell" : @"colorCell"));
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ( indexPath.section < 2 ) {
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            if ( indexPath.section == 0 ) {
                UITextField *textField = [UITextField new];
                textField.placeholder = NSLocalizedString(@"Calendar Name", @"Calendar Name");
                textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                textField.delegate = self;
                textField.tag = 10;
                textField.borderStyle = UITextBorderStyleNone;
                textField.returnKeyType = UIReturnKeyDefault;
                [cell.contentView addSubview:textField];
                [textField makeConstraints:^(MASConstraintMaker *make) {
                    make.leading.equalTo(@(42));
                    make.centerY.equalTo(cell.centerY);
                    make.trailing.equalTo(@(-15));
                }];
                cell.imageView.image = [[UIImage imageNamed:@"calendar_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            }
            else if ( indexPath.section == 1) {
                cell.imageView.image = [[UIImage imageNamed:@"calendar_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
            }
        }
        
        if ( indexPath.section == 0 ) {
            UITextField *textField = (UITextField*)[cell viewWithTag:10];
            if ([_calendar.name length] > 0 ) {
                textField.text = _calendar.name;
            }
            NSInteger colorID = [_calendar.colorID integerValue];
			cell.imageView.tintColor = [[_colorArray objectAtIndex:colorID] objectForKey:CalendarItem_Color];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else if ( indexPath.section == 1 ) {
            NSDictionary *colorItem = [_colorArray objectAtIndex:indexPath.row];
            cell.textLabel.text = NSLocalizedString([colorItem objectForKey:CalendarItem_Name], nil);
            cell.textLabel.font = [UIFont systemFontOfSize:17];
            cell.imageView.tintColor = [colorItem objectForKey:CalendarItem_Color];

            if ([_calendar.colorID unsignedIntegerValue] == indexPath.row) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    else {
        if ( cell == nil ) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.text = NSLocalizedString(@"Delete Calendar", @"Delete Calendar");
        cell.textLabel.textColor = [UIColor colorWithRed:1.0 green:59.0/255.0 blue:48.0/255.0 alpha:1.0];
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section < 2 )
        return;
    
    cell.textLabel.frame = CGRectMake(cell.textLabel.frame.origin.x, cell.textLabel.frame.origin.y, cell.contentView.frame.size.width, cell.textLabel.frame.size.height);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section == 1 )
    {
        NSInteger index = [_calendar.colorID unsignedIntegerValue];
		if ( index == indexPath.row )
            return;
        _calendar.colorID = @(indexPath.row);

        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        UITableViewCell *prevCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:indexPath.section]];
        UITableViewCell *curCell = [tableView cellForRowAtIndexPath:indexPath];
        prevCell.accessoryType = UITableViewCellAccessoryNone;
        curCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        UITableViewCell *calendarNameCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
		NSUInteger colorID = [_calendar.colorID unsignedIntegerValue];

		calendarNameCell.imageView.tintColor = self.colorArray[colorID][CalendarItem_Color];
    }
    else if ( indexPath.section == 2) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"DaysCalendar_CalendarDeleteConfirmMsg", nil)
																 delegate:self
														cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
												   destructiveButtonTitle:NSLocalizedString(@"Delete Calendar", nil)
														otherButtonTitles:nil];
        [actionSheet showInView:self.view];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex == actionSheet.destructiveButtonIndex ) {
        [self deleteCalendarAction:nil];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
	_calendar.name = str;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	_calendar.name = textField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	_calendar.name = textField.text;
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - action method
- (void)resignAllAction
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if ( cell ) {
        UITextField *textField = (UITextField*)[cell viewWithTag:10];
        [textField resignFirstResponder];
    }
}

- (IBAction)deleteCalendarAction:(id)sender {
    // 모델 삭제 하고
	[_sharedManager removeCalendar:_calendar];
    // 창 닫기
	[self dismissSelf];
}

- (void)cancelAction:(id)sender
{
	[self dismissSelf];
}

- (void)dismissSelf {
	[self dismissViewControllerAnimated:YES completion:nil];
	[self removeObserver];
}

- (void)doneButtonAction:(UIBarButtonItem *)button
{
    [self resignAllAction];

    // 모델 업데이트 하고
    if ( [_calendar.name length] < 1 ) {
		_calendar.name = NSLocalizedString(@"Untitled", @"Untitled");
    }

    if ( !_isEditMode ) {
		[_calendar assignOrderAsFirstInContext:self.savingContext];
    }
	[self.savingContext MR_saveToPersistentStoreAndWait];

	[self dismissSelf];
}

@end
