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
#import "A3UserDefaultsKeys.h"
#import "UIColor+A3Addition.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "A3AppDelegate.h"
#import "A3UIDevice.h"

@interface A3LadyCalendarSetupAlertViewController () <UITextFieldDelegate, A3KeyboardDelegate, A3ViewControllerProtocol>

@property (strong, nonatomic) NSArray *itemArray;
@property (strong, nonatomic) UITextField *customTextField;
@property (copy, nonatomic) NSString *textBeforeEditingTextField;
@property (copy, nonatomic) UIColor *textColorBeforeEditing;
@property (weak, nonatomic) UITextField *editingTextField;

@end

@implementation A3LadyCalendarSetupAlertViewController {
	BOOL _isNumberKeyboardVisible;
	BOOL _didPressClearKey;
	BOOL _didPressNumberKey;
}

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

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([self.navigationController.navigationBar isHidden]) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[self dismissNumberKeyboard];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)applicationWillResignActive {
	[self dismissNumberKeyboard];
}

- (void)willDismissFromRightSide
{
	[self dismissNumberKeyboard];
}

- (void)dealloc {
	[self removeObserver];
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
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
	[self dismissNumberKeyboard];
	
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

#pragma mark - UIScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[self dismissNumberKeyboard];
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	[self presentNumberKeyboardForTextField:textField];
	return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	self.textBeforeEditingTextField = textField.text;
	self.textColorBeforeEditing = textField.textColor;

	textField.textColor = [[A3AppDelegate instance] themeColor];
	textField.text = [self.decimalFormatter stringFromNumber:@0];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if (_textColorBeforeEditing) {
		textField.textColor = _textColorBeforeEditing;
		_textColorBeforeEditing = nil;
	}
	
	if (!_didPressNumberKey && !_didPressClearKey) {
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

- (void)presentNumberKeyboardForTextField:(UITextField *)textField {
	if (_isNumberKeyboardVisible) {
		return;
	}
	_editingTextField = textField;
	
	[self textFieldDidBeginEditing:textField];
	
	A3NumberKeyboardViewController *keyboardVC = [self simplePrevNextNumberKeyboard];
	self.numberKeyboardViewController = keyboardVC;
	keyboardVC.useDotAsClearButton = YES;
	keyboardVC.keyboardType = A3NumberKeyboardTypeInteger;
	keyboardVC.textInputTarget = textField;
	keyboardVC.delegate = self;

	CGRect bounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	CGFloat keyboardHeight = keyboardVC.keyboardHeight;
	UIView *keyboardView = keyboardVC.view;
	if (IS_IPAD) {
		[[A3AppDelegate instance].rootViewController_iPad.view addSubview:keyboardView];
	} else {
		[self.view.superview addSubview:keyboardView];
	}

	[keyboardVC reloadPrevNextButtons];

	_didPressClearKey = NO;
	_didPressNumberKey = NO;
	_isNumberKeyboardVisible = YES;

	keyboardView.frame = CGRectMake(0, self.view.bounds.size.height, bounds.size.width, keyboardHeight);
	[UIView animateWithDuration:0.3 animations:^{
		CGRect frame = keyboardView.frame;
		frame.origin.y -= keyboardHeight;
		keyboardView.frame = frame;
	} completion:^(BOOL finished) {
		[self addNumberKeyboardNotificationObservers];
	}];
}

- (void)dismissNumberKeyboard {
	if (!_isNumberKeyboardVisible) {
		return;
	}

	[self textFieldDidEndEditing:_editingTextField];
	
	A3NumberKeyboardViewController *keyboardViewController = self.numberKeyboardViewController;
	UIView *keyboardView = keyboardViewController.view;

	_isNumberKeyboardVisible = NO;

	[UIView animateWithDuration:0.3 animations:^{
		CGRect frame = keyboardView.frame;
		frame.origin.y += keyboardViewController.keyboardHeight;
		keyboardView.frame = frame;
	} completion:^(BOOL finished) {
		[keyboardView removeFromSuperview];
		self.numberKeyboardViewController = nil;
	}];
}

#pragma mark - Keyboard Delegate

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
	_customTextField.text = [self.decimalFormatter stringFromNumber:@0];
	_textBeforeEditingTextField = [self.decimalFormatter stringFromNumber:@0];
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate {
	[self dismissNumberKeyboard];
}

- (void)keyboardViewControllerDidValueChange:(A3NumberKeyboardViewController *)vc {
	_didPressClearKey = NO;
	_didPressNumberKey = YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

	if (_isNumberKeyboardVisible && self.numberKeyboardViewController.view.superview) {
		UIView *keyboardView = self.numberKeyboardViewController.view;
		CGFloat keyboardHeight = self.numberKeyboardViewController.keyboardHeight;

		FNLOGRECT(self.view.bounds);
		FNLOG(@"%f", keyboardHeight);
		CGRect bounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
		keyboardView.frame = CGRectMake(0, bounds.size.height - keyboardHeight, bounds.size.width, keyboardHeight);
		[self.numberKeyboardViewController rotateToInterfaceOrientation:toInterfaceOrientation];
	}
}

@end
