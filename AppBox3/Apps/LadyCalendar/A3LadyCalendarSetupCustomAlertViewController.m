//
//  A3LadyCalendarSetupCustomAlertViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LadyCalendarSetupCustomAlertViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "A3LadyCalendarDefine.h"
#import "A3LadyCalendarModelManager.h"
#import "A3DateHelper.h"
#import "UIColor+A3Addition.h"
#import "A3NumberKeyboardViewController.h"
#import "A3AppDelegate+appearance.h"

@interface A3LadyCalendarSetupCustomAlertViewController ()

@property (strong, nonatomic) NSMutableArray *templateArray;
@property (strong, nonatomic) A3NumberKeyboardViewController* keyboardVC;

- (void)timeChangedAction:(id)sender;
- (void)resignAllAction;
@end

@implementation A3LadyCalendarSetupCustomAlertViewController
- (void)resignAllAction
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITextField *textField = (UITextField*)cell.accessoryView;
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

    self.title = @"Custom";
    self.templateArray = [NSMutableArray arrayWithArray:@[@{ItemKey_Title : @"Days Before",ItemKey_Type : @(CustomAlertCell_DaysBefore)},@{ItemKey_Title : @"Time",ItemKey_Type : @(CustomAlertCell_Time)}]];
    self.keyboardVC = [self simpleNumberKeyboard];
    self.keyboardVC.delegate = self;
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
    return 35.0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 36.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *cellIDs = @[@"inputCell",@"value1Cell",@"dateInputCell"];
    NSInteger cellType = [[[_templateArray objectAtIndex:indexPath.row] objectForKey:ItemKey_Type] integerValue];
    
    NSString *CellIdentifier = [cellIDs objectAtIndex:cellType];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        if( cellType == CustomAlertCell_TimeInput ){
            NSArray *cellArray = [[NSBundle mainBundle] loadNibNamed:@"A3LadyCalendarAddAccountCell" owner:nil options:nil];
            cell = [cellArray objectAtIndex:2];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIDatePicker *datePicker = (UIDatePicker*)[cell viewWithTag:10];
            datePicker.datePickerMode = UIDatePickerModeTime;
            [datePicker addTarget:self action:@selector(timeChangedAction:) forControlEvents:UIControlEventValueChanged];
        }
        else{
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            if( cellType == CustomAlertCell_DaysBefore ){
                UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 80.0, cell.contentView.frame.size.height)];
                textField.textColor = [UIColor colorWithRGBRed:123 green:123 blue:123 alpha:255];
                textField.textAlignment = NSTextAlignmentRight;
                textField.borderStyle = UITextBorderStyleNone;
                textField.delegate = self;
                cell.accessoryView = textField;
            }
        }
    }
    
    NSDictionary *item = [_templateArray objectAtIndex:indexPath.row];
    if( cellType != CustomAlertCell_TimeInput ){
        cell.textLabel.text = [item objectForKey:ItemKey_Title];
        if( cellType == CustomAlertCell_DaysBefore ){
            UITextField *textField = (UITextField*)cell.accessoryView;
            textField.text = [NSString stringWithFormat:@"%ld", (long)[[_settingDict objectForKey:SettingItem_CustomAlertDays] integerValue]];
        }
        else if( cellType == CustomAlertCell_Time ){
            cell.detailTextLabel.text = ( [_settingDict objectForKey:SettingItem_CustomAlertTime] ? [A3DateHelper dateStringFromDate:[_settingDict objectForKey:SettingItem_CustomAlertTime] withFormat:@"h:mm a"] : nil);
            if( [_templateArray count] > 2 )
                cell.detailTextLabel.textColor = [[A3AppDelegate instance] themeColor];
            else
                cell.detailTextLabel.textColor = [UIColor colorWithRGBRed:128.0 green:128.0 blue:128.0 alpha:255];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat retHeight = 44.0;
    
    NSDictionary *item = [_templateArray objectAtIndex:indexPath.row];
    if( [[item objectForKey:ItemKey_Type] integerValue] == CustomAlertCell_TimeInput )
        retHeight = 236.0;
    
    return retHeight;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [_templateArray objectAtIndex:indexPath.row];
    NSInteger cellType = [[item objectForKey:ItemKey_Type] integerValue];
    
    [self resignAllAction];
    if( cellType == CustomAlertCell_DaysBefore ){
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UITextField *textField = (UITextField*)cell.accessoryView;
        [textField becomeFirstResponder];
    }
    else if( cellType == CustomAlertCell_Time ){
        if( [_templateArray count] > 2 ){
            // close
            [_templateArray removeObjectAtIndex:indexPath.row+1];
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
        }
        else{
            // open
            [_templateArray addObject:@{ItemKey_Title : @"", ItemKey_Type : @(CustomAlertCell_TimeInput)}];
            [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
            if( [_settingDict objectForKey:SettingItem_CustomAlertTime] == nil ){
                [_settingDict setObject:[NSDate date] forKey:SettingItem_CustomAlertTime];
            }
        }
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self resignAllAction];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidChange:(NSNotification*)noti
{
    UITextField *textField = noti.object;
    NSInteger days = [textField.text integerValue];
    [_settingDict setObject:@(days) forKey:SettingItem_CustomAlertDays];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	self.keyboardVC.textInputTarget = textField;
	self.keyboardVC.delegate = self;
	textField.inputView = self.keyboardVC.view;
	textField.text = @"";
    
    if( [_templateArray count] > 2 ){
        [_templateArray removeObjectAtIndex:[_templateArray count]-1];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[_templateArray count] inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[_templateArray count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }

    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

#pragma mark - action method
- (void)timeChangedAction:(id)sender
{
    UIDatePicker *datePicker = (UIDatePicker*)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[datePicker.superview superview] superview]];
    
    [_settingDict setObject:[A3DateHelper dateMakeSecondZero:datePicker.date] forKey:SettingItem_CustomAlertTime];
    
    if( indexPath )
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - A3KeyboardDelegate
- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate
{
    [self resignAllAction];
}

@end
