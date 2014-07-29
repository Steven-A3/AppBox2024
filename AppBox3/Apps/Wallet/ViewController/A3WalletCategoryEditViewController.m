//
//  A3WalletCategoryEditViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 15..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletCategoryEditViewController.h"
#import "A3WalletIconSelectViewController.h"
#import "A3WalletEditFieldViewController.h"
#import "A3WalletCateEditTitleCell.h"
#import "A3WalletCateEditIconCell.h"
#import "A3AppDelegate.h"
#import "UIViewController+NumberKeyboard.h"
#import "UIViewController+A3Addition.h"
#import "A3WalletMainTabBarController.h"
#import "NSString+conversion.h"
#import "UIViewController+iPad_rightSideView.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3WalletCategoryEditAddNewFieldCell.h"
#import "WalletItem.h"
#import "WalletItem+initialize.h"
#import "WalletData.h"
#import "A3UserDefaults.h"

@interface A3WalletCategoryEditViewController () <UIActionSheetDelegate, WalletIconSelectDelegate, WalletEditFieldDelegate,  UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray *fields;
@property (nonatomic, strong) NSMutableDictionary *plusItem;
@property (nonatomic, strong) NSMutableDictionary *toAddField;
@property (nonatomic, copy) NSString *originalCategoryName;
@property (nonatomic, strong) UIViewController *rightSideViewController;
@property (nonatomic, weak) UITextField *titleTextField;
@property (nonatomic, strong) MBProgressHUD *alertHUD;
@property (nonatomic, strong) NSMutableDictionary *category;
@property (nonatomic, strong) NSArray *allCategories;
@property (nonatomic, copy) NSDictionary *originalCategory;

@end

@implementation A3WalletCategoryEditViewController {
	BOOL _sameCategoryNameExists;
}

NSString *const A3WalletCateEditTitleCellID = @"A3WalletCateEditTitleCell";
NSString *const A3WalletCateEditIconCellID = @"A3WalletCateEditIconCell";
NSString *const A3WalletCateEditDeleteCellID = @"A3WalletCateEditDeleteCell";
NSString *const A3WalletCateEditFieldCellID = @"A3WalletCateEditFieldCell";
NSString *const A3WalletCateEditPlusCellID = @"A3WalletCateEditPlusCell";
NSString *const A3WalletCateEditNormalCellID = @"Cell";

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

	if (_isAddingCategory) {
		self.navigationItem.title = NSLocalizedString(@"Add Category", @"Add Category");
		_category = [NSMutableDictionary new];
		_category[W_ICON_KEY] = [WalletData iconList][0];
		_category[W_ID_KEY] = [[NSUUID UUID] UUIDString];
	} else {
		self.navigationItem.title = NSLocalizedString(@"Edit Category", @"Edit Category");
		_category = [[WalletData categoryItemWithID:_categoryID] mutableCopy];
	}
	self.originalCategory = _category;
	self.originalCategoryName = _category[W_NAME_KEY];
    
    [self makeBackButtonEmptyArrow];
    [self rightBarButtonDoneButton];
	self.navigationItem.rightBarButtonItem.enabled = NO;

	[self leftBarButtonCancelButton];

    [self.tableView registerClass:[A3WalletCategoryEditAddNewFieldCell class] forCellReuseIdentifier:A3WalletCateEditPlusCellID];
    
    self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.separatorInset = A3UITableViewSeparatorInset;
    self.tableView.allowsSelectionDuringEditing = YES;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.tableView setEditing:YES animated:NO];
    
    [self registerContentSizeCategoryDidChangeNotification];

	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewWillDismiss) name:A3NotificationRightSideViewWillDismiss object:nil];
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

- (void)rightSideViewWillDismiss {
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    if (IS_IPAD) {
        self.navigationItem.leftBarButtonItem.enabled = YES;
        [self setupDoneButtonEnabled];
    }
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[self setupDoneButtonEnabled];

	if (_isAddingCategory && [self isMovingToParentViewController]) {
		double delayInSeconds = 0.1;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			[_titleTextField becomeFirstResponder];
		});
	}
}

- (void)contentSizeDidChange:(NSNotification *) notification
{
    [self.tableView reloadData];
}

- (NSArray *)allCategories {
	if (!_allCategories) {
		_allCategories = [WalletData walletCategoriesFilterDoNotShow:NO];
	}
	return _allCategories;
}

- (NSMutableArray *)fields
{
    if (!_fields) {
        
        _fields = [[NSMutableArray alloc] initWithArray:_category[W_FIELDS_KEY]];
		[_fields addObject:self.plusItem];
	}
    
    return _fields;
}

- (NSMutableDictionary *)plusItem
{
    if (!_plusItem) {
		_plusItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"+", @"order":@""}];
    }
    
    return _plusItem;
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

    // 입력값 유효성 체크
    if ([_category[W_NAME_KEY] length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
                                                        message:NSLocalizedString(@"Enter category name", @"Enter category name")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

	[WalletData saveCategory:_category];

	if (_delegate && [_delegate respondsToSelector:@selector(walletCategoryEdited:)]) {
		[_delegate walletCategoryEdited:_category];
	}

	if (_isAddingCategory) {
		[[NSNotificationCenter defaultCenter] postNotificationName:A3WalletNotificationCategoryAdded object:nil];
	}
    else {
		[self.navigationController popToRootViewControllerAnimated:NO];

		NSNotification *notification = [[NSNotification alloc] initWithName:A3WalletNotificationCategoryChanged
																	 object:self
																   userInfo:@{@"uniqueID":_category[W_ID_KEY]}];
		[[NSNotificationCenter defaultCenter] postNotification:notification];
	}
	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)cancelButtonAction:(id)sender
{
	[self.firstResponder resignFirstResponder];
	[self setFirstResponder:nil];

	NSManagedObjectContext *context = [NSManagedObjectContext MR_rootSavingContext];
	if ([context hasChanges]) {
		[context rollback];
	}

	[self dismissViewController];
}

- (void)dismissViewController {
	if (_isAddingCategory) {
		[self dismissViewControllerAnimated:YES completion:NULL];
		return;
	}
	if (IS_IPAD) {
		// custom cross dissolve animation
		self.view.alpha = 1.0;
		[UIView animateWithDuration:0.3
						 animations:^{
							 self.view.alpha = 0.0;
						 }
						 completion:^(BOOL finished) {
							 [self.navigationController popViewControllerAnimated:NO];
						 }];
	}
	else {
		[self dismissViewControllerAnimated:YES completion:NULL];
	}
}

- (UIViewController *)iconSelectViewController
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"WalletPhoneStoryBoard" bundle:nil];
    A3WalletIconSelectViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletIconSelectViewController"];
    viewController.selecteIconName = _category[W_ICON_KEY];
    viewController.delegate = self;
    
    return viewController;
}

- (UIViewController *)editFieldViewController:(NSInteger)index
{
    NSDictionary *field = _fields[index];

    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"WalletPhoneStoryBoard" bundle:nil];
    A3WalletEditFieldViewController *editFieldViewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletEditFieldViewController"];
    editFieldViewController.delegate = self;
	editFieldViewController.field = [field mutableCopy];
	editFieldViewController.fields = _fields;

    return editFieldViewController;
}

- (void)addWalletField
{
    self.toAddField = [NSMutableDictionary new];
	_toAddField[W_ID_KEY] = [[NSUUID UUID] UUIDString];
	_toAddField[W_TYPE_KEY] = WalletFieldTypeText;
	_toAddField[W_STYLE_KEY] = WalletFieldStyleNormal;

    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"WalletPhoneStoryBoard" bundle:nil];
    A3WalletEditFieldViewController *editFieldViewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletEditFieldViewController"];
    editFieldViewController.delegate = self;
    editFieldViewController.isAddMode = YES;
	editFieldViewController.field = _toAddField;
	editFieldViewController.fields = _fields;

    [self presentSubViewController:editFieldViewController];
}

- (void)presentSubViewController:(UIViewController *)viewController {
	[self.firstResponder resignFirstResponder];
	[self setFirstResponder:nil];

	if (IS_IPHONE) {
		[self.navigationController pushViewController:viewController animated:YES];
	} else {
		if (_isAddingCategory) {
			_rightSideViewController = [[A3NavigationController alloc] initWithRootViewController:viewController];
			[self presentRightSideView:_rightSideViewController.view];
			[self.navigationController addChildViewController:_rightSideViewController];
		} else {
			A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController];
			[rootViewController presentRightSideViewController:viewController];
		}
	}
}

- (void)disableBarItems
{
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

#pragma mark - WalletEditFieldDelegate

- (void)walletFieldEdited:(NSDictionary *)field
{
    NSUInteger index = [_fields indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		return [obj[W_ID_KEY] isEqualToString:field[W_ID_KEY]];
	}];
	_fields[index] = field;

	[self updateCategoryFields:[_fields mutableCopy]];

    NSIndexPath *ip = [NSIndexPath indexPathForRow:index inSection:1];
    [self.tableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationFade];
	[self setupDoneButtonEnabled];
}

- (void)walletFieldAdded:(NSDictionary *)field
{
    if (_toAddField == field) {
        NSUInteger index = [_fields indexOfObject:self.plusItem];
		[_fields insertObject:field atIndex:index];

		[self updateCategoryFields:[_fields mutableCopy]];

        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    }
	[self setupDoneButtonEnabled];
}

- (void)updateCategoryFields:(NSMutableArray *)fields {
	[fields removeLastObject];
	_category[W_FIELDS_KEY] = fields;
}

- (void)dismissedViewController:(UIViewController *)viewController
{
    NSIndexPath *sip = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:sip animated:YES];
    
	[self setupDoneButtonEnabled];
}

#pragma mark - WalletIconSelectDelegate

- (void)walletIconSelected:(NSString *)iconName
{
    self.category[W_ICON_KEY] = iconName;
    
    NSIndexPath *ip = [NSIndexPath indexPathForRow:1 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationFade];

	[self setupDoneButtonEnabled];
}

- (void)dismissedWalletIconController:(UIViewController *)viewController
{
    NSIndexPath *sip = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:sip animated:YES];
    
	[self setupDoneButtonEnabled];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _category[W_NAME_KEY] = textField.text;
	[self setFirstResponder:nil];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	[self setFirstResponder:textField];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	NSString *changed = [textField.text stringByReplacingCharactersInRange:range withString:string];
	changed = [changed stringByTrimmingSpaceCharacters];

	if (![_originalCategoryName isEqualToString:changed]) {
		if ([changed length]) {
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", W_NAME_KEY, changed];
			_sameCategoryNameExists = [[self.allCategories filteredArrayUsingPredicate:predicate] count] > 0;
		} else {
			_sameCategoryNameExists = NO;
		}
	} else {
		_sameCategoryNameExists = NO;
	}
	if (_sameCategoryNameExists) {
		[self.alertHUD show:YES];
	} else {
		[self.alertHUD hide:YES];
	}

	_category[W_NAME_KEY] = changed;

	[self setupDoneButtonEnabled];

    return YES;
}

- (void)setupDoneButtonEnabled {
	self.navigationItem.leftBarButtonItem.enabled = YES;
	BOOL enable = ![_originalCategory isEqualToDictionary:_category];
	if (_titleTextField) {
		enable = enable && [_titleTextField.text length] && !_sameCategoryNameExists;
	}
	self.navigationItem.rightBarButtonItem.enabled = enable;
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
    
    float lastFooterHeight = 38.0;
    
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
    return _isAddingCategory ? 2 : 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 2;
		case 1:
			return self.fields.count;
		case 2:
			return 1;
		default:
			return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=nil;

	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			A3WalletCateEditTitleCell *titleCell;
			titleCell = [tableView dequeueReusableCellWithIdentifier:A3WalletCateEditTitleCellID forIndexPath:indexPath];

			titleCell.selectionStyle = UITableViewCellSelectionStyleNone;
			titleCell.textField.text = _category[W_NAME_KEY];
			titleCell.textField.placeholder = NSLocalizedString(@"Category Name", @"Category Name");
			titleCell.textField.delegate = self;
			titleCell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
			titleCell.textField.font = [UIFont systemFontOfSize:17.0];
			titleCell.textField.returnKeyType = UIReturnKeyDefault;

			_titleTextField = titleCell.textField;
			cell = titleCell;
		}
		else if (indexPath.row == 1) {
			A3WalletCateEditIconCell *iconCell;
			iconCell = [tableView dequeueReusableCellWithIdentifier:A3WalletCateEditIconCellID forIndexPath:indexPath];
			UILabel *label = (UILabel *)[iconCell viewWithTag:10];
			label.text = NSLocalizedString(@"Icon", nil);

			iconCell.iconImageView.image = [UIImage imageNamed:_category[W_ICON_KEY]];

			cell = iconCell;
		}
	}
	else if (indexPath.section == 2) {
		cell = [tableView dequeueReusableCellWithIdentifier:A3WalletCateEditDeleteCellID forIndexPath:indexPath];
		UILabel *label = (UILabel *) [cell viewWithTag:10];
		label.text = NSLocalizedString(@"Delete Category", nil);
	}
	else if (indexPath.section == 1) {
		if (_fields[indexPath.row] == _plusItem) {
			cell = [tableView dequeueReusableCellWithIdentifier:A3WalletCateEditPlusCellID forIndexPath:indexPath];
			cell.textLabel.text = NSLocalizedString(@"add new field", @"add new field");
			cell.textLabel.font = [UIFont systemFontOfSize:17.0];
		}
		else {
			cell = [tableView dequeueReusableCellWithIdentifier:A3WalletCateEditFieldCellID forIndexPath:indexPath];

			NSDictionary *field = _fields[indexPath.row];
			cell.textLabel.font = [UIFont systemFontOfSize:17.0];
			cell.textLabel.text = field[W_NAME_KEY];
		}
	}

    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.section == 1) {
        return YES;
    }
    else {
        return NO;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source

        NSDictionary *field = [_fields objectAtIndex:indexPath.row];
        [_fields removeObject:field];

        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        
        [self addWalletField];
    }
	[self setupDoneButtonEnabled];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_fields[indexPath.row] == _plusItem) {
        return UITableViewCellEditingStyleInsert;
    }
    else {
        return UITableViewCellEditingStyleDelete;
    }
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	id fromObject = [_fields objectAtIndex:fromIndexPath.row];
	[_fields removeObjectAtIndex:fromIndexPath.row];
	[_fields insertObject:fromObject atIndex:toIndexPath.row];

	[self updateCategoryFields:[_fields mutableCopy]];

    [self setupDoneButtonEnabled];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    if (indexPath.section == 1) {
        if (_fields[indexPath.row] == _plusItem) {
            return NO;
        }
        else {
            return YES;
        }
    }
    else {
        return NO;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
	NSUInteger lastRowInSection1 = [tableView numberOfRowsInSection:1] - 2;
	if (proposedDestinationIndexPath.section == 0) {
		proposedDestinationIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
	} else if (proposedDestinationIndexPath.row > lastRowInSection1) {
		proposedDestinationIndexPath = [NSIndexPath indexPathForRow:lastRowInSection1 inSection:1];
	}
    return proposedDestinationIndexPath;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.firstResponder resignFirstResponder];
	[self setFirstResponder:nil];

    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            // icon
            UIViewController *viewController = [self iconSelectViewController];
            [self presentSubViewController:viewController];
            
            [self disableBarItems];
        }
    }
    else if (indexPath.section == 1) {
        if (_fields[indexPath.row] != _plusItem) {
            
            UIViewController *viewController = [self editFieldViewController:indexPath.row];
            [self presentSubViewController:viewController];
            
            [self disableBarItems];
        }
        else if (_fields[indexPath.row] == self.plusItem) {
            
            // add wallet field
            [self addWalletField];
            
            [self disableBarItems];
        }
    }
    else if (indexPath.section == 2) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                   destructiveButtonTitle:NSLocalizedString(@"Delete Category", @"Delete Category")
                                                        otherButtonTitles:nil];
        [actionSheet showInView:self.view];
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
		NSMutableArray *updatingCategories = [[WalletData walletCategoriesFilterDoNotShow:NO] mutableCopy];
		NSUInteger idx = [updatingCategories indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
			return [obj[W_ID_KEY] isEqualToString:_category[W_ID_KEY]];
		}];
		if (idx != NSNotFound) {
			NSManagedObjectContext *savingContext = [NSManagedObjectContext MR_rootSavingContext];
			NSArray *items = [WalletItem MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"categoryID == %@", self.category[W_ID_KEY]] inContext:savingContext];
			for (WalletItem *item in items) {
				[item deleteWalletItem];
			}

			[updatingCategories removeObjectAtIndex:idx];
			[WalletData saveWalletObject:updatingCategories forKey:A3WalletUserDefaultsCategoryInfo];
		}

		[self dismissViewControllerAnimated:YES completion:NULL];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:A3WalletNotificationCategoryDeleted object:nil];
	}
}

@end
