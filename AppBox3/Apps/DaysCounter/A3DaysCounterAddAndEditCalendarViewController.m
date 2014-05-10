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
#import "UIViewController+A3AppCategory.h"
#import "UIViewController+iPad_rightSideView.h"

@interface A3DaysCounterAddAndEditCalendarViewController ()
@property (strong, nonatomic) NSArray *colorArray;

- (void)cancelAction:(id)sender;
- (NSInteger)indexOfCurrentColor:(UIColor*)color;
@end

@implementation A3DaysCounterAddAndEditCalendarViewController

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

    self.title = (_isEditMode ? @"Edit Calendar" : @"Add Calendar");

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    [self rightBarButtonDoneButton];
    if ( !_isEditMode ) {
        self.calendarItem = [[A3DaysCounterModelManager sharedManager] itemForNewUserCalendar];
    }
    
    self.colorArray = [[A3DaysCounterModelManager sharedManager] calendarColorList];

	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willDismissRightSideView) name:A3NotificationRightSideViewWillDismiss object:nil];
	}
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

- (void)dealloc {
	[self removeObserver];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (_isEditMode ? 3 : 2);
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
        title = @"COLOR";
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
    if ( section == (_isEditMode ? 2 : 1) ) {
        return 38;//return IS_RETINA ? 35.5 : 35;
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
                UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(20, 6, 280, 32)];
                textField.placeholder = @"Calendar Name";
                textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                textField.delegate = self;
                textField.tag = 10;
                textField.borderStyle = UITextBorderStyleNone;
                textField.returnKeyType = UIReturnKeyDefault;
                [cell.contentView addSubview:textField];
                [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:textField.frame.size.height]];
                [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
                [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
                [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:20.0]];
                [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-20.0]];
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
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else if ( indexPath.section == 1 ) {
            NSDictionary *colorItem = [_colorArray objectAtIndex:indexPath.row];
            cell.textLabel.text = [colorItem objectForKey:CalendarItem_Name];
            cell.textLabel.font = [UIFont systemFontOfSize:17];
            cell.imageView.tintColor = [colorItem objectForKey:CalendarItem_Color];
            cell.accessoryType = ( CGColorEqualToColor([[colorItem objectForKey:CalendarItem_Color] CGColor], [[_calendarItem objectForKey:CalendarItem_Color] CGColor]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
        }
    }
    else {
        if ( cell == nil ) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.text = @"Delete Calendar";
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
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        UITableViewCell *prevCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:indexPath.section]];
        UITableViewCell *curCell = [tableView cellForRowAtIndexPath:indexPath];
        prevCell.accessoryType = UITableViewCellAccessoryNone;
        curCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else if ( indexPath.section == 2) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Calendar" otherButtonTitles:nil];
        [actionSheet showInView:self.view];
//        [self deleteCalendarAction:nil];
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
    [[A3DaysCounterModelManager sharedManager] removeCalendarItem:_calendarItem];
    // 창 닫기
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelAction:(id)sender
{
//    if ( IS_IPHONE || _isEditMode )
        [self dismissViewControllerAnimated:YES completion:nil];
//    else {
//        [self.A3RootViewController dismissRightSideViewController];
//        [self.A3RootViewController.centerNavigationController viewWillAppear:YES];
//    }
}

- (void)doneButtonAction:(UIBarButtonItem *)button
{
    [self resignAllAction];
    // 모델 업데이트 하고
    if ( [[_calendarItem objectForKey:CalendarItem_Name] length] < 1 ) {
        [_calendarItem setObject:@"Untitled" forKey:CalendarItem_Name];
    }
    
    if ( !_isEditMode ) {
        [[A3DaysCounterModelManager sharedManager] addCalendarItem:_calendarItem];
    }
    else {
        [[A3DaysCounterModelManager sharedManager] updateCalendarItem:_calendarItem];
    }
    
    [self cancelAction:nil];
}

@end
