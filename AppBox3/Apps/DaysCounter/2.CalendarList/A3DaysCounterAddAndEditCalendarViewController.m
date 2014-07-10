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
#import "DaysCounterCalendar.h"
#import "UIViewController+tableViewStandardDimension.h"

@interface A3DaysCounterAddAndEditCalendarViewController ()
@property (strong, nonatomic) NSArray *colorArray;
@property (strong, nonatomic) NSString *colorID;

- (void)cancelAction:(id)sender;
- (NSInteger)indexOfCurrentColor:(UIColor*)color;
@end

@implementation A3DaysCounterAddAndEditCalendarViewController

- (id)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {

	}

	return self;
}


- (NSInteger)indexOfCurrentColor:(UIColor*)color
{
    NSInteger retIndex = NSNotFound;
    for(NSInteger i=0; i < [_colorArray count]; i++) {
        NSDictionary *item = [_colorArray objectAtIndex:i];
        if ( CGColorEqualToColor([[item objectForKey:CalendarItem_Color] CGColor], [color CGColor]) ) {
            retIndex = i;
            break;
        }
    }
    return retIndex;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = (_isEditMode ? NSLocalizedString(@"Edit Calendar", @"Edit Calendar") : NSLocalizedString(@"Add Calendar", @"Add Calendar"));

	self.tableView.showsVerticalScrollIndicator = NO;
	self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.separatorInset = A3UITableViewSeparatorInset;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    [self rightBarButtonDoneButton];
    
    self.colorArray = [_sharedManager calendarColorList];
    
    if ( !_isEditMode ) {
        self.calendarItem = [_sharedManager itemForNewUserCalendar];
    }

    _colorID = [self.calendarItem objectForKey:CalendarItem_ColorID];

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_isEditMode) {
        if ([DaysCounterCalendar MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"calendarType == %@", @(CalendarCellType_User)]] == 1) {
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
    else if ( section == 1 )
        rowCount = [_colorArray count];
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
    BOOL hasOneCalendar = [DaysCounterCalendar MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"calendarType == %@", @(CalendarCellType_User)]] == 1 ? YES : NO;

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
            if ( [[self.calendarItem objectForKey:CalendarItem_Name] length] > 0 ) {
                textField.text = [self.calendarItem objectForKey:CalendarItem_Name];
            }
            cell.imageView.tintColor = [_calendarItem objectForKey:CalendarItem_Color];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else if ( indexPath.section == 1 ) {
            NSDictionary *colorItem = [_colorArray objectAtIndex:indexPath.row];
            cell.textLabel.text = NSLocalizedString([colorItem objectForKey:CalendarItem_Name], nil);
            cell.textLabel.font = [UIFont systemFontOfSize:17];
            cell.imageView.tintColor = [colorItem objectForKey:CalendarItem_Color];

            if ([[colorItem objectForKey:CalendarItem_Name] isEqualToString:[_calendarItem objectForKey:CalendarItem_ColorID]]) {
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
        NSInteger index = [self indexOfCurrentColor:[_calendarItem objectForKey:CalendarItem_Color]];
        if ( index == indexPath.row )
            return;
        
        UIColor *color = [[_colorArray objectAtIndex:indexPath.row] objectForKey:CalendarItem_Color];
        [_calendarItem setObject:color forKey:CalendarItem_Color];
        _colorID = [[_colorArray objectAtIndex:indexPath.row] objectForKey:CalendarItem_Name];
        [_calendarItem setObject:_colorID forKey:CalendarItem_ColorID];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        UITableViewCell *prevCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:indexPath.section]];
        UITableViewCell *curCell = [tableView cellForRowAtIndexPath:indexPath];
        prevCell.accessoryType = UITableViewCellAccessoryNone;
        curCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        UITableViewCell *calendarNameCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        calendarNameCell.imageView.tintColor = [_calendarItem objectForKey:CalendarItem_Color];
    }
    else if ( indexPath.section == 2) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:NSLocalizedString(@"Delete Calendar", @"Delete Calendar") otherButtonTitles:nil];
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
    [_calendarItem setObject:str forKey:CalendarItem_Name];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [_calendarItem setObject:textField.text forKey:CalendarItem_Name];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_calendarItem setObject:textField.text forKey:CalendarItem_Name];
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
    [_sharedManager removeCalendarItem:_calendarItem];
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
    if ( [[_calendarItem objectForKey:CalendarItem_Name] length] < 1 ) {
		[_calendarItem setObject:NSLocalizedString(@"Untitled", @"Untitled") forKey:CalendarItem_Name];
    }
    
    if ( !_isEditMode ) {
//        [_sharedManager addCalendarItem:_calendarItem colorID:_colorID inContext:[[MagicalRecordStack defaultStack] context] ];
        [_sharedManager addCalendarToFirstItem:_calendarItem colorID:_colorID inContext:[[MagicalRecordStack defaultStack] context]];
    }
    else {
        [_sharedManager updateCalendarItem:_calendarItem colorID:_colorID];
    }
    
	[self dismissSelf];
}

@end
