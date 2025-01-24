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
#import "DaysCounterEvent.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3StandardTableViewCell.h"
#import "UITableView+utility.h"
#import "A3UIDevice.h"
#import "A3UserDefaults+A3Addition.h"
#import "A3AppDelegate.h"

@interface A3DaysCounterSetupRepeatViewController () <A3ViewControllerProtocol>

@property (strong, nonatomic) NSArray *itemArray;
@property (strong, nonatomic) NSNumber *originalValue;
@property (weak, nonatomic) UITextField *editingTextField;
@property (copy, nonatomic) UIColor *textColorBeforeEditing;
@property (copy, nonatomic) NSString *textBeforeEditingTextField;

@end

@implementation A3DaysCounterSetupRepeatViewController {
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

    self.title = NSLocalizedString(@"Repeat", @"Repeat");

	self.tableView.showsVerticalScrollIndicator = NO;
	self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.separatorInset = A3UITableViewSeparatorInset;
	self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}

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

	self.originalValue = _eventModel.repeatType;
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

- (void)dealloc
{
}

- (void)willDismissFromRightSide
{
	[self dismissNumberKeyboard];

    if (IS_IPAD && _dismissCompletionBlock) {
        _dismissCompletionBlock();
    }
}

- (BOOL)resignFirstResponder {
	[self.editingTextField resignFirstResponder];
	[self dismissNumberKeyboard];

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
            cell = [[A3StandardTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
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
            [((A3DaysCounterRepeatCustomCell *)cell).checkImageView setTintColor:[[A3UserDefaults standardUserDefaults] themeColor]];
        }
        else {
            cell = [[A3StandardTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
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
    if ([_eventModel.isLunar boolValue]) {
        _eventModel.repeatType = indexPath.row == 0 ? @(RepeatType_Never) : @(RepeatType_EveryYear);
    }
    else {
		if (indexPath.row != [_itemArray count] - 1) {
			NSInteger value = indexPath.row * -1;
			_eventModel.repeatType = @(value);
		}
    }
    
    [self doneButtonAction:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	[self presentNumberKeyboardForTextField:textField];
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	self.editingTextField = textField;

	self.textBeforeEditingTextField = textField.text;
	self.textColorBeforeEditing = textField.textColor;

	textField.text = [self.decimalFormatter stringFromNumber:@0];
    textField.textColor = [[A3UserDefaults standardUserDefaults] themeColor];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	self.editingTextField = nil;

	if (!_didPressClearKey && !_didPressNumberKey) {
		textField.text = _textBeforeEditingTextField;
	}
	_eventModel.repeatType = @([textField.text integerValue]);

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[_itemArray count]-1 inSection:0]];
    [self setCheckmarkOnCustomInputCell:cell CheckShow:YES];

	if (_textColorBeforeEditing) {
		textField.textColor = _textColorBeforeEditing;
		_textColorBeforeEditing = nil;
	}

	[self.tableView reloadData];
}

- (void)presentNumberKeyboardForTextField:(UITextField *)textField {
	if (_isNumberKeyboardVisible) {
		return;
	}

	A3NumberKeyboardViewController *keyboardVC = [self simplePrevNextNumberKeyboard];
	self.numberKeyboardViewController = keyboardVC;

	keyboardVC.delegate = self;
	keyboardVC.textInputTarget = textField;

	CGRect bounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	CGFloat keyboardHeight = keyboardVC.keyboardHeight;
	UIView *keyboardView = keyboardVC.view;
	if (IS_IPHONE) {
		[self.view.superview addSubview:keyboardView];
	} else {
		[[A3AppDelegate instance].rootViewController_iPad.view addSubview:keyboardView];
	}

	_didPressClearKey = NO;
	_didPressNumberKey = NO;
	_isNumberKeyboardVisible = YES;

	keyboardVC.keyboardType = A3NumberKeyboardTypeInteger;

	[self textFieldDidBeginEditing:textField];

	keyboardView.frame = CGRectMake(0, self.view.bounds.size.height, bounds.size.width, keyboardHeight);
	[UIView animateWithDuration:0.3 animations:^{
		CGRect frame = keyboardView.frame;
		frame.origin.y -= keyboardHeight;
		keyboardView.frame = frame;

		UIEdgeInsets contentInset = self.tableView.contentInset;
		contentInset.bottom = keyboardHeight;
		self.tableView.contentInset = contentInset;

		NSIndexPath *indexPath = [self.tableView indexPathForCellSubview:textField];
		[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];

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
	[UIView animateWithDuration:0.3 animations:^{
		CGRect frame = keyboardView.frame;
		frame.origin.y += keyboardViewController.keyboardHeight;
		keyboardView.frame = frame;
	} completion:^(BOOL finished) {
		[keyboardView removeFromSuperview];
		self.numberKeyboardViewController = nil;
        self->_isNumberKeyboardVisible = NO;
	}];
}

#pragma mark - A3KeyboardDelegate

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
	UITextField *textField = (UITextField *)keyInputDelegate;
	textField.text = [self.decimalFormatter stringFromNumber:@0];
	self.textBeforeEditingTextField = textField.text;
	_didPressClearKey = YES;
	_didPressNumberKey = NO;
}

- (void)keyboardViewControllerDidValueChange:(A3NumberKeyboardViewController *)vc {
	_didPressClearKey = NO;
	_didPressNumberKey = YES;
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate;
{
	[self dismissNumberKeyboard];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

	if (_isNumberKeyboardVisible && self.numberKeyboardViewController.view.superview) {
		UIView *keyboardView = self.numberKeyboardViewController.view;
		CGFloat keyboardHeight = self.numberKeyboardViewController.keyboardHeight;

		UIEdgeInsets contentInset = self.tableView.contentInset;
		contentInset.bottom = keyboardHeight;
		self.tableView.contentInset = contentInset;

		NSIndexPath *indexPath = [self.tableView indexPathForCellSubview:_editingTextField];
		[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];

		CGRect bounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
		keyboardView.frame = CGRectMake(0, bounds.size.height - keyboardHeight, bounds.size.width, keyboardHeight);
		[self.numberKeyboardViewController rotateToInterfaceOrientation:toInterfaceOrientation];
	}
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[self dismissNumberKeyboard];
}

#pragma mark - action method

- (void)cancelAction:(id)sender
{
    _eventModel.repeatType = self.originalValue;
    
    if ( IS_IPAD ) {
        [[[A3AppDelegate instance] rootViewController_iPad] dismissRightSideViewController];
        [[[A3AppDelegate instance] rootViewController_iPad].centerNavigationController viewWillAppear:YES];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)doneButtonAction:(UIBarButtonItem *)button
{
    if ( IS_IPAD ) {
        [[[A3AppDelegate instance] rootViewController_iPad] dismissRightSideViewController];
        [[[A3AppDelegate instance] rootViewController_iPad].centerNavigationController viewWillAppear:YES];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];

        if (_dismissCompletionBlock) {
            _dismissCompletionBlock();
        }
    }
}

@end
