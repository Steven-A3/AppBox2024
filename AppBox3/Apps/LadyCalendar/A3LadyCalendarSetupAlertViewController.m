//
//  A3LadyCalendarSetupAlertViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LadyCalendarSetupAlertViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3LadyCalendarDefine.h"
#import "A3LadyCalendarModelManager.h"
#import "A3NumberKeyboardViewController.h"
#import "A3UserDefaults.h"
#import "UIColor+A3Addition.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"

@interface A3LadyCalendarSetupAlertViewController () <UITextFieldDelegate, A3KeyboardDelegate>

@property (strong, nonatomic) NSArray *itemArray;
@property (strong, nonatomic) UITextField *customTextField;
@property (copy, nonatomic) NSString *textBeforeEditingTextField;

@end

@implementation A3LadyCalendarSetupAlertViewController

- (id)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {

	}

	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Alert", @"Alert");
    [self makeBackButtonEmptyArrow];
    
    self.itemArray = @[@(AlertType_None),@(AlertType_OnDay),@(AlertType_OneDayBefore),@(AlertType_TwoDaysBefore),@(AlertType_OneWeekBefore),@(AlertType_Custom)];
    
    if( [_settingDict objectForKey:SettingItem_CustomAlertTime] == nil )
        [_settingDict setObject:[NSDate date] forKey:SettingItem_CustomAlertTime];
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

    return [_itemArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [self standardHeightForHeaderInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:17.0];
        cell.textLabel.textColor = [UIColor colorWithRGBRed:0 green:0 blue:0 alpha:255];
		cell.detailTextLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSInteger type = [[_itemArray objectAtIndex:indexPath.row] integerValue];
    cell.textLabel.text = [self.dataManager stringForAlertType:type];

	NSInteger currentType = [[_settingDict objectForKey:SettingItem_AlertType] integerValue];
	FNLOG(@"%ld, %ld", (long)type, (long)currentType);
    if( type == AlertType_Custom ) {
		[_customTextField removeFromSuperview];
		[cell addSubview:self.customTextField];
		[_customTextField makeConstraints:^(MASConstraintMaker *make) {
			make.centerY.equalTo(cell.centerY);
			make.height.equalTo(cell.height);
			make.width.equalTo(@120);
			make.right.equalTo(cell.contentView.right).with.offset(type == currentType ? 0 : -15);
		}];
		NSInteger customAlertDay = [[_settingDict objectForKey:SettingItem_CustomAlertDays] integerValue];
		_customTextField.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld days before", @"StringsDict", @"Lady Calendar Custome Alert"), (long) customAlertDay];
	}
    else{
        cell.detailTextLabel.text = nil;
    }
	cell.accessoryType = ( type == [[_settingDict objectForKey:SettingItem_AlertType] integerValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger type = [[_itemArray objectAtIndex:indexPath.row] integerValue];
    
    NSIndexPath *prevIndexPath = [NSIndexPath indexPathForRow:ABS(type) inSection:indexPath.section];
    
    [_settingDict setObject:@(type) forKey:SettingItem_AlertType];
	[[A3SyncManager sharedSyncManager] setObject:self.settingDict forKey:A3LadyCalendarUserDefaultsSettings state:A3DataObjectStateModified];

	[A3LadyCalendarModelManager setupLocalNotification];

    [tableView reloadData];
    if( prevIndexPath.row != indexPath.row )
        [tableView reloadRowsAtIndexPaths:@[prevIndexPath,indexPath] withRowAnimation:UITableViewRowAnimationNone];
    else
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UITextField and delegate

- (UITextField *)customTextField {
	if (!_customTextField) {
		_customTextField = [UITextField new];
		_customTextField.delegate = self;
		_customTextField.textAlignment = NSTextAlignmentRight;
		_customTextField.textColor = [UIColor colorWithRGBRed:128 green:128 blue:128 alpha:255];
	}
	return _customTextField;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	self.textBeforeEditingTextField = textField.text;
	textField.text = @"";

	A3NumberKeyboardViewController *keyboardViewController = [self simplePrevNextNumberKeyboard];
	[keyboardViewController setUseDotAsClearButton:YES];
	[keyboardViewController setTextInputTarget:textField];
	[keyboardViewController setDelegate:self];
	[keyboardViewController setKeyboardType:A3NumberKeyboardTypeInteger];
	[keyboardViewController reloadPrevNextButtons];
	self.numberKeyboardViewController = keyboardViewController;
	textField.inputView = self.numberKeyboardViewController.view;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	self.numberKeyboardViewController = nil;
	if (![textField.text length] && [_textBeforeEditingTextField length]) {
		textField.text = _textBeforeEditingTextField;
		return;
	}
	NSInteger customDay = [textField.text integerValue];
	[_settingDict setObject:@(AlertType_Custom) forKey:SettingItem_AlertType];
	[_settingDict setObject:@(customDay) forKey:SettingItem_CustomAlertDays];

	[[A3SyncManager sharedSyncManager] setObject:self.settingDict forKey:A3LadyCalendarUserDefaultsSettings state:A3DataObjectStateModified];

	[A3LadyCalendarModelManager setupLocalNotification];

	[self.tableView reloadData];
}

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
	_customTextField.text = @"";
	_textBeforeEditingTextField = @"";
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate {
	[_customTextField resignFirstResponder];
}

@end
