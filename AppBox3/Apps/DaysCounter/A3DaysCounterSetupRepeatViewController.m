//
//  A3DaysCounterSetupRepeatViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterSetupRepeatViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "A3NumberKeyboardViewController_iPad.h"
#import "A3NumberKeyboardViewController_iPhone.h"
#import "SFKImage.h"
#import "A3DaysCounterRepeatCustomCell.h"

@interface A3DaysCounterSetupRepeatViewController ()
@property (strong, nonatomic) NSArray *itemArray;
@property (strong, nonatomic) A3NumberKeyboardViewController *numberKeyboardVC;
@property (strong, nonatomic) NSNumber *originalValue;

- (void)showNumberKeyboard;
- (void)hideNumberkeyboard;
- (void)cancelAction:(id)sender;
@end

@implementation A3DaysCounterSetupRepeatViewController

- (void)showNumberKeyboard
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[_itemArray count]-1 inSection:0]];
    if ( cell == nil )
        return;
    
    UITextField *textField = (UITextField*)[cell viewWithTag:12];
    textField.delegate = self;
    [textField becomeFirstResponder];
}

- (void)hideNumberkeyboard
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[_itemArray count]-1 inSection:0]];
    if ( cell == nil )
        return;
    
    UITextField *textField = (UITextField*)[cell viewWithTag:12];
    [textField resignFirstResponder];
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

    self.title = @"Repeat";
    self.itemArray = @[@"Never",@"Every Day",@"Every Week", @"Every 2 Weeks",@"Every Month",@"Every Year",@"Custom"];
    self.numberKeyboardVC = [self simpleNumberKeyboard];
    self.originalValue = [_eventModel objectForKey:EventItem_RepeatType];
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = (indexPath.row == ([_itemArray count]-1) ? @"customInputCell" : @"Cell");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        if ( indexPath.row == ([_itemArray count] -1) ) {
            NSArray *cellArray = [[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterAddEventCell" owner:nil options:nil];
            cell = [cellArray objectAtIndex:7];
            UITextField *textField = (UITextField*)[cell viewWithTag:12];
            textField.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
        else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    
    // Configure the cell...
    NSInteger value = [[_eventModel objectForKey:EventItem_RepeatType] integerValue];
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
    NSInteger prevValue = [[_eventModel objectForKey:EventItem_RepeatType] integerValue];
    NSInteger prevIndex = ( prevValue < 0 ? prevValue * -1 : (prevValue > 0 ? [_itemArray count]-1 : 0));
    NSInteger value = (prevValue <= 0 && (indexPath.row == ([_itemArray count]-1))) ? 1 : indexPath.row * -1;
    [_eventModel setObject:[NSNumber numberWithInteger:value] forKey:EventItem_RepeatType];
    [tableView beginUpdates];
    if ( prevIndex != indexPath.row ) {
        [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:prevIndex inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [tableView endUpdates];

    if ( indexPath.row == ([_itemArray count]-1) ) {
        // 키보드 보여주기
        [self showNumberKeyboard];
    }
    else {
        [self hideNumberkeyboard];
        [self doneButtonAction:nil];
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidChange:(NSNotification*)noti
{
    UITextField *textField = noti.object;
    [_eventModel setObject:[NSNumber numberWithInteger:[textField.text integerValue]] forKey:EventItem_RepeatType];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	self.numberKeyboardVC.textInputTarget = textField;
	self.numberKeyboardVC.delegate = self;
	textField.inputView = self.numberKeyboardVC.view;
	textField.text = @"";
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[_itemArray count]-1 inSection:0]];
    [self setCheckmarkOnCustomInputCell:cell CheckShow:YES];
    [self.tableView reloadData];
    
    if (_dismissCompletionBlock) {
        _dismissCompletionBlock();
    }
}

#pragma mark - A3KeyboardDelegate
- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate;
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[_itemArray count]-1 inSection:0]];
    UITextField *textField = (UITextField*)[cell viewWithTag:12];
    [textField resignFirstResponder];
}

#pragma mark - action method
- (void)cancelAction:(id)sender
{
    [_eventModel setObject:self.originalValue forKey:EventItem_RepeatType];
    
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
