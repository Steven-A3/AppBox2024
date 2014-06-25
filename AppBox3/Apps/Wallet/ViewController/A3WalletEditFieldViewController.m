//
//  A3WalletEditFieldViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletEditFieldViewController.h"
#import "A3WalletFieldTypeSelectViewController.h"
#import "A3WalletFieldStyleSelectViewController.h"
#import "WalletData.h"
#import "WalletField.h"
#import "A3AppDelegate.h"
#import "UIViewController+NumberKeyboard.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+iPad_rightSideView.h"
#import "NSString+conversion.h"
#import "WalletCategory.h"
#import "A3WalletFieldEditTitleCell.h"

@interface A3WalletEditFieldViewController () <WalletFieldTypeSelectDelegate, WalletFieldStyleSelectDelegate, UITextFieldDelegate>
@property (nonatomic, strong) MBProgressHUD *alertHUD;
@property (nonatomic, copy) NSString *originalFieldName;
@end

@implementation A3WalletEditFieldViewController {
	BOOL _sameFieldNameExists;
}

NSString *const A3WalletFieldEditTitleCellID = @"A3WalletFieldEditTitleCell";
NSString *const A3WalletFieldEditTypeCellID = @"A3WalletFieldEditTypeCell";
NSString *const A3WalletFieldEditStyleCellID = @"A3WalletFieldEditStyleCell";

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

    self.navigationItem.title = _isAddMode ? NSLocalizedString(@"Add Field", @"Add Field") : NSLocalizedString(@"Edit Field", @"Edit Field");
	if (!_isAddMode) {
		self.originalFieldName = _field.name;
	}

    [self makeBackButtonEmptyArrow];
    
    self.tableView.separatorColor = [self tableViewSeparatorColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    [self registerContentSizeCategoryDidChangeNotification];

	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewWillDismiss) name:A3NotificationRightSideViewWillDismiss object:nil];
	}
}

- (void)removeObserver {
	[self removeContentSizeCategoryDidChangeNotification];
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationRightSideViewWillDismiss object:nil];
	}
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

- (void)viewWillDismiss {
	[self removeObserver];
	[self closeEditing];
}

- (void)contentSizeDidChange:(NSNotification *) notification
{
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[self titleKeyboardUp];
}

- (void)titleKeyboardUp
{
	double delayInSeconds = 0.1;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		A3WalletFieldEditTitleCell *titleCell = (A3WalletFieldEditTitleCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
		if (![titleCell.textField.text length]) {
			[titleCell.textField becomeFirstResponder];
		}
	});
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (![self.navigationController.viewControllers containsObject:self]) {
        if (IS_IPHONE) {
			[self closeEditing];
        }
    }
}

- (void)closeEditing {
	[self.firstResponder resignFirstResponder];

	if (_field.name.length > 0 && !_sameFieldNameExists) {
		[self updateEditedInfo];
	}
	else {
		[_field MR_deleteEntity];
	}

	if (_delegate && [_delegate respondsToSelector:@selector(dismissedViewController:)]) {
		[_delegate dismissedViewController:self];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doneButtonAction:(id)sender
{
	[self.firstResponder resignFirstResponder];
	[self setFirstResponder:nil];

    if (IS_IPAD) {
        
        if (_field.name.length > 0 && !_sameFieldNameExists) {
            [self updateEditedInfo];
        }
        else {
            [_field MR_deleteEntity];
        }
        
		[self.A3RootViewController dismissRightSideViewController];
        
        if (_delegate && [_delegate respondsToSelector:@selector(dismissedViewController:)]) {
            [_delegate dismissedViewController:self];
        }
	}
}

- (void)updateEditedInfo
{
    // 추가모드
    if (_isAddMode) {
        if ([_field hasChanges] && _delegate && [_delegate respondsToSelector:@selector(walletFieldAdded:)]) {
            [_delegate walletFieldAdded:_field];
        }
    }
    // 편집모드
    else {
        // 변화가 있으면 delegate호출
        if ([_field hasChanges] && _delegate && [_delegate respondsToSelector:@selector(walletFieldEdited:)]) {
            [_delegate walletFieldEdited:_field];
        }
    }
}

#pragma mark - WalletFieldStyleSelectDelegate

- (void)walletFieldStyleSelected:(NSString *)fieldStyle
{
    if (fieldStyle) {
        _field.style = fieldStyle;
        [self.tableView reloadData];
    }
}

#pragma mark - WalletFieldTypeSelectDelegate

- (void)walletFieldSelectedFieldType:(NSString *)fieldType
{
    if (fieldType) {
        _field.type = fieldType;
        [self.tableView reloadData];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	[self setFirstResponder:textField];
	textField.returnKeyType = UIReturnKeyDefault;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _field.name = textField.text;
	[self setFirstResponder:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	NSString *changed = [textField.text stringByReplacingCharactersInRange:range withString:string];
	changed = [changed stringByTrimmingSpaceCharacters];

	if (![_originalFieldName isEqualToString:changed]) {
		if ([changed length] && _field.category.uniqueID) {
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@ AND category.uniqueID == %@", changed, _field.category.uniqueID];
			_sameFieldNameExists = [[WalletField MR_findAllWithPredicate:predicate] count] > 0 ? YES : NO;
		} else {
			_sameFieldNameExists = NO;
		}
	} else {
		_sameFieldNameExists = NO;
	}
	if (_sameFieldNameExists) {
		[self.alertHUD show:YES];
	} else {
		[self.alertHUD hide:YES];
	}
	return YES;
}

- (MBProgressHUD *)alertHUD {
	if (!_alertHUD) {
		_alertHUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];

		// Configure for text only and offset down
		_alertHUD.mode = MBProgressHUDModeText;
		_alertHUD.margin = 2.0;
		_alertHUD.cornerRadius = 10.0;
		_alertHUD.labelText = [NSString stringWithFormat:@" %@ ", NSLocalizedString(@"Field name already exists.", nil)];
		_alertHUD.labelFont = [UIFont fontWithName:@"Avenir-Light" size:14.0];
		_alertHUD.labelColor = [UIColor whiteColor];
		_alertHUD.color = [UIColor colorWithRed:0.8f green:0.1f blue:0.2f alpha:1.000f];
		_alertHUD.userInteractionEnabled = NO;

		[self.navigationController.view addSubview:_alertHUD];
	}
	CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
	_alertHUD.yOffset = -(screenBounds.size.height/2.0 - 64 - 18.0);
	return _alertHUD;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.firstResponder resignFirstResponder];

    if (indexPath.section == 1) {
        // field type
        A3WalletFieldTypeSelectViewController *viewController = [[A3WalletFieldTypeSelectViewController alloc] initWithStyle:UITableViewStyleGrouped];
        viewController.delegate = self;
        viewController.selectedType = _field.type;
        
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else if (indexPath.section == 2) {
        // field style
        A3WalletFieldStyleSelectViewController *viewController = [[A3WalletFieldStyleSelectViewController alloc] initWithStyle:UITableViewStyleGrouped];
        viewController.delegate = self;
        viewController.typeName = _field.type;
        viewController.selectedStyle = _field.style;
        
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 35.0;
    }
    else {
        return 1.0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    NSUInteger numberSection = [tableView numberOfSections];
    
    float lastFooterHeight = 20.0;
    
    if (section == (numberSection-1)) {
        return lastFooterHeight;
    }
    else {
        return IS_RETINA ? 34.0 : 34.0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    // style section
    if (section == 2) {
        if ([_field.type isEqualToString:WalletFieldTypeImage] || [_field.type isEqualToString:WalletFieldTypeVideo]) {
            return 0;
        }
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=nil;

	if (indexPath.section == 0) {
		A3WalletFieldEditTitleCell *titleCell;
		titleCell = [tableView dequeueReusableCellWithIdentifier:A3WalletFieldEditTitleCellID forIndexPath:indexPath];

		titleCell.selectionStyle = UITableViewCellSelectionStyleNone;
		titleCell.textField.textColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
		titleCell.textField.font = [UIFont systemFontOfSize:17];
		titleCell.textField.text = _field.name;
		titleCell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		titleCell.textField.placeholder = NSLocalizedString(@"Field Name", @"Field Name");
		titleCell.textField.delegate = self;

		cell = titleCell;
	}
	else if (indexPath.section == 1) {
		cell = [tableView dequeueReusableCellWithIdentifier:A3WalletFieldEditTypeCellID];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:A3WalletFieldEditTypeCellID];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.detailTextLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
			cell.textLabel.font = [UIFont systemFontOfSize:17];
			cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
		}

		cell.textLabel.text = NSLocalizedString(@"Type", @"Type");
		cell.detailTextLabel.text = NSLocalizedString(_field.type, nil);
	}
	else if (indexPath.section == 2) {
		cell = [tableView dequeueReusableCellWithIdentifier:A3WalletFieldEditStyleCellID];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:A3WalletFieldEditStyleCellID];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.detailTextLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
			cell.textLabel.font = [UIFont systemFontOfSize:17];
			cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
		}

		cell.textLabel.text = NSLocalizedString(@"Style", @"Style");
		cell.detailTextLabel.text = NSLocalizedString(_field.style, nil);
	}

    return cell;
}

@end
