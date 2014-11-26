//
//  A3DaysCounterSetupRepeatViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterSetupRepeatViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "A3NumberKeyboardViewController_iPad.h"
#import "A3NumberKeyboardViewController_iPhone.h"
#import "SFKImage.h"
#import "A3DaysCounterRepeatCustomCell.h"
#import "A3AppDelegate+appearance.h"
#import "DaysCounterEvent.h"
#import "UIViewController+tableViewStandardDimension.h"

@interface A3DaysCounterSetupRepeatViewController () <A3ViewControllerProtocol>

@property (strong, nonatomic) NSArray *itemArray;
@property (strong, nonatomic) A3NumberKeyboardViewController *numberKeyboardVC;
@property (strong, nonatomic) NSNumber *originalValue;
@property (weak, nonatomic) UITextField *editingTextField;
@property (copy, nonatomic) NSString *textBeforeEditingTextField;

@end

@implementation A3DaysCounterSetupRepeatViewController

- (id)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {

	}

	return self;
}

- (void)showNumberKeyboard
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[_itemArray count]-1 inSection:0]];
    if ( cell == nil )
        return;
    
    UITextField *textField = (UITextField*)[cell viewWithTag:12];
    textField.delegate = self;
    [textField becomeFirstResponder];
}

- (void)hideNumberKeyboard
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[_itemArray count]-1 inSection:0]];
    if ( cell == nil )
        return;
    
    UITextField *textField = (UITextField*)[cell viewWithTag:12];
    [textField resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Repeat", @"Repeat");

	self.tableView.showsVerticalScrollIndicator = NO;
	self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

    if ([_eventModel.isLunar boolValue]) {
        self.itemArray = @[NSLocalizedString(@"Never", @"Never"), NSLocalizedString(@"Every Year", @"Every Year")];
    }
    else {
        self.itemArray = @[
				NSLocalizedString(@"Never", @"Never"),
				NSLocalizedString(@"Every Day", @"Every Day"),
				NSLocalizedString(@"Every Week", @"Every Week"),
				NSLocalizedString(@"Every 2 Weeks", @"Every 2 Weeks"),
				NSLocalizedString(@"Every Month", @"Every Month"),
				NSLocalizedString(@"Every Year", @"Every Year"),
				NSLocalizedString(@"Custom", @"Custom")];
    }
    self.numberKeyboardVC = [self simplePrevNextNumberKeyboard];
	self.originalValue = _eventModel.repeatType;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.numberKeyboardVC = nil;
}

- (void)willDismissFromRightSide
{
    if (IS_IPAD && _dismissCompletionBlock) {
        _dismissCompletionBlock();
    }
}

- (BOOL)resignFirstResponder {
	[self.editingTextField resignFirstResponder];

	return [super resignFirstResponder];
}

#pragma mark 
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
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_eventModel.isLunar boolValue]) {
        NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }

        cell.textLabel.text = self.itemArray[indexPath.row];
        if (indexPath.row == 0) {
            cell.accessoryType = (_eventModel.repeatType.integerValue == RepeatType_Never) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
        else {
            cell.accessoryType = (_eventModel.repeatType.integerValue == RepeatType_EveryYear) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
        
        return cell;
    }

	// Configure the cell...
	NSInteger value = [_eventModel.repeatType integerValue];
	NSInteger index = 0;
	if ( value < 0 ) {
		index = ABS(value);
	}
	else {
		if ( value > 0 ) {
			index = [_itemArray count] -1;
		}
		else {
			index = value;
		}
	}

	NSString *CellIdentifier = (indexPath.row == ([_itemArray count]-1) ? @"customInputCell" : @"Cell");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        if ( indexPath.row == ([_itemArray count] -1) ) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterAddEventRepeatCell" owner:nil options:nil] lastObject];
			UILabel *textLabel = (UILabel *)[cell viewWithTag:10];
			textLabel.text = NSLocalizedString(@"Custom", nil);
            UITextField *textField = (UITextField*)[cell viewWithTag:12];
            textField.delegate = self;
            ((A3DaysCounterRepeatCustomCell *)cell).checkImageView.image = [[UIImage imageNamed:@"check_02"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [((A3DaysCounterRepeatCustomCell *)cell).checkImageView setTintColor:[A3AppDelegate instance].themeColor];
        }
        else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
    }
    
    cell.selected = (indexPath.row == index);
    
    if ( indexPath.row != ([_itemArray count]-1) ) {
        // Custom Input Cell
        cell.textLabel.text = [_itemArray objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = @"";
        cell.accessoryType = cell.selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    else {
        UITextField *textField = (UITextField*)[cell viewWithTag:12];
        textField.text = [NSString stringWithFormat:@"%ld", (long)(value > 0 ? value : 0)];
		UILabel *daysLabel = (UILabel *)[cell viewWithTag:11];
		daysLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld days(NO NUMBER)", @"StringsDict", nil), (long)value];
        cell.accessoryType = UITableViewCellAccessoryNone;
        if ([cell isSelected]) {
            [self setCheckmarkOnCustomInputCell:cell CheckShow:YES];
        }
        else {
            [self setCheckmarkOnCustomInputCell:cell CheckShow:NO];
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ( ![_eventModel.isLunar boolValue] && indexPath.row == ([_itemArray count]-1) ) {
		// 키보드 보여주기
		[self showNumberKeyboard];
		return;
	}
	[self hideNumberKeyboard];

    if ([_eventModel.isLunar boolValue]) {
        _eventModel.repeatType = indexPath.row == 0 ? @(RepeatType_Never) : @(RepeatType_EveryYear);
    }
    else {
        NSInteger value = (indexPath.row == ([_itemArray count]-1)) ? 1 : indexPath.row * -1;
        _eventModel.repeatType = @(value);
    }
    
    [self doneButtonAction:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	self.editingTextField = textField;
	self.textBeforeEditingTextField = textField.text;
	self.numberKeyboardVC.textInputTarget = textField;
	self.numberKeyboardVC.delegate = self;
	textField.inputView = self.numberKeyboardVC.view;
	textField.text = @"";
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	self.editingTextField = nil;

	if (![textField.text length]) {
		textField.text = _textBeforeEditingTextField;
	}
	_eventModel.repeatType = @([textField.text integerValue]);

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[_itemArray count]-1 inSection:0]];
    [self setCheckmarkOnCustomInputCell:cell CheckShow:YES];
    [self.tableView reloadData];
    
    if (_dismissCompletionBlock) {
        _dismissCompletionBlock();
    }
}

#pragma mark - A3KeyboardDelegate

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
	UITextField *textField = (UITextField *)keyInputDelegate;
	textField.text = @"";
	self.textBeforeEditingTextField = @"";
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate;
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[_itemArray count]-1 inSection:0]];
    UITextField *textField = (UITextField*)[cell viewWithTag:12];
    [textField resignFirstResponder];
}

#pragma mark - action method
- (void)cancelAction:(id)sender
{
    _eventModel.repeatType = self.originalValue;
    
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

#pragma mark - A3ViewControllerProtocol

- (BOOL)shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier {
	return NO;
}

@end
