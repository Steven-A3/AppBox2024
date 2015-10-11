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
#import "A3UserDefaultsKeys.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "WalletCategory.h"
#import "WalletField.h"
#import "NSMutableArray+A3Sort.h"
#import "NSManagedObject+extension.h"

@interface A3WalletCategoryEditViewController () <UIActionSheetDelegate, WalletIconSelectDelegate, WalletEditFieldDelegate,  UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray *fields;
@property (nonatomic, strong) NSMutableDictionary *plusItem;
@property (nonatomic, strong) WalletField *toAddField;
@property (nonatomic, copy) NSString *originalCategoryName;
@property (nonatomic, strong) UIViewController *rightSideViewController;
@property (nonatomic, weak) UITextField *titleTextField;
@property (nonatomic, strong) MBProgressHUD *alertHUD;
@property (nonatomic, strong) WalletCategory *category;
@property (nonatomic, strong) NSArray *allCategories;

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
		_category = [WalletCategory MR_createEntityInContext:self.savingContext];
		_category.icon = [WalletData iconList][0];
		_category.uniqueID = [[NSUUID UUID] UUIDString];
		_category.doNotShow = @NO;
		_category.isSystem = @NO;
		[_category assignOrderAsLastInContext:self.savingContext];
	} else {
		self.navigationItem.title = NSLocalizedString(@"Edit Category", @"Edit Category");
		_category = [WalletCategory MR_findFirstByAttribute:@"uniqueID" withValue:_categoryID inContext:self.savingContext];
	}
	self.originalCategoryName = _category.name;
    
    [self makeBackButtonEmptyArrow];
    [self rightBarButtonDoneButton];
	self.navigationItem.rightBarButtonItem.enabled = NO;

	[self leftBarButtonCancelButton];

    [self.tableView registerClass:[A3WalletCategoryEditAddNewFieldCell class] forCellReuseIdentifier:A3WalletCateEditPlusCellID];
    
    self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.separatorInset = A3UITableViewSeparatorInset;
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
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

- (NSManagedObjectContext *)savingContext {
	if (!_savingContext) {
		_savingContext = [NSManagedObjectContext MR_defaultContext];
	}
	return _savingContext;
}

- (NSArray *)allCategories {
	if (!_allCategories) {
		_allCategories = [WalletData walletCategoriesFilterDoNotShow:NO inContext:nil ];
	}
	return _allCategories;
}

- (NSMutableArray *)fields
{
    if (!_fields) {
        _fields = [NSMutableArray new];
		if (!_isAddingCategory) {
			[_fields addObjectsFromArray:[WalletField MR_findByAttribute:@"categoryID" withValue:_category.uniqueID andOrderBy:A3CommonPropertyOrder ascending:YES inContext:self.savingContext]];
		}
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
    if ([_category.name length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
                                                        message:NSLocalizedString(@"Enter category name", @"Enter category name")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

	[self.savingContext MR_saveToPersistentStoreAndWait];

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
																   userInfo:@{@"uniqueID":_category.uniqueID}];
		[[NSNotificationCenter defaultCenter] postNotification:notification];
	}
	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)cancelButtonAction:(id)sender
{
	[self.firstResponder resignFirstResponder];
	[self setFirstResponder:nil];

	NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
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
    viewController.selecteIconName = _category.icon;
    viewController.delegate = self;
    
    return viewController;
}

- (UIViewController *)editFieldViewController:(NSInteger)index
{
    WalletField *field = _fields[index];

    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"WalletPhoneStoryBoard" bundle:nil];
    A3WalletEditFieldViewController *editFieldViewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletEditFieldViewController"];
    editFieldViewController.delegate = self;
	editFieldViewController.field = field;
	editFieldViewController.fields = _fields;

    return editFieldViewController;
}

- (void)addWalletField
{
    self.toAddField = [WalletField MR_createEntityInContext:self.savingContext];
	_toAddField.uniqueID = [[NSUUID UUID] UUIDString];
	_toAddField.categoryID = _category.uniqueID;
	_toAddField.type = WalletFieldTypeText;
	_toAddField.style = WalletFieldStyleNormal;
	[_toAddField assignOrderAsLastInContext:self.savingContext];

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

- (void)walletFieldEdited:(WalletField *)field
{
    NSUInteger index = [_fields indexOfObjectPassingTest:^BOOL(WalletField *obj, NSUInteger idx, BOOL *stop) {
		return [obj.uniqueID isEqualToString:field.uniqueID];
	}];

    NSIndexPath *ip = [NSIndexPath indexPathForRow:index inSection:1];
    [self.tableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationFade];
	[self setupDoneButtonEnabled];
}

- (void)walletFieldAdded:(WalletField *)field
{
    if (_toAddField == field) {
        NSUInteger index = [_fields indexOfObject:self.plusItem];
		[_fields insertObject:field atIndex:index];

        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    }
	[self setupDoneButtonEnabled];
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
    self.category.icon = iconName;
    
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
    _category.name = textField.text;
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
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"name", changed];
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

	_category.name = changed;

	[self setupDoneButtonEnabled];

    return YES;
}

- (void)setupDoneButtonEnabled {
	self.navigationItem.leftBarButtonItem.enabled = YES;
	BOOL enable = [self.savingContext hasChanges];

	enable &= !_sameCategoryNameExists;

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
			titleCell.textField.text = _category.name;
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

			iconCell.iconImageView.image = [UIImage imageNamed:_category.icon];

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

			WalletField *field = _fields[indexPath.row];
			cell.textLabel.font = [UIFont systemFontOfSize:17.0];
			cell.textLabel.text = field.name;
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

        WalletField *field = [_fields objectAtIndex:indexPath.row];
        [_fields removeObject:field];
		[field MR_deleteEntityInContext:self.savingContext];

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
    
    WalletField *fromItem = [_fields objectAtIndex:fromIndexPath.row];
    WalletField *toItem = [_fields objectAtIndex:toIndexPath.row];
    NSString *temp = fromItem.order;
    fromItem.order = toItem.order;
    toItem.order = temp;
    
	[_fields removeObjectAtIndex:fromIndexPath.row];
	[_fields insertObject:fromObject atIndex:toIndexPath.row];

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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

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
#ifdef __IPHONE_8_0
        if (!IS_IOS7 && IS_IPAD) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:NULL]];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete Category", @"Delete Category") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                [self deleteCategoryByActionSheet];
            }]];
            
            alertController.modalPresentationStyle = UIModalPresentationPopover;
            
            UIPopoverPresentationController *popoverPresentation = [alertController popoverPresentationController];
            popoverPresentation.permittedArrowDirections = UIPopoverArrowDirectionDown | UIPopoverArrowDirectionUp;
            popoverPresentation.sourceView = self.view;
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            CGRect fromRect = [tableView convertRect:cell.bounds fromView:cell];
            fromRect.origin.x = self.view.center.x;
            fromRect.size = CGSizeZero;
            popoverPresentation.sourceRect = fromRect;
            
            [self presentViewController:alertController animated:YES completion:NULL];
        }
        else
#endif
		{
            [self showDeleteCategoryActionSheet];
        }
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)deleteCategoryByActionSheet {
    [_category MR_deleteEntityInContext:self.savingContext];
    
    NSArray *items = [WalletItem MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"categoryID == %@", self.category.uniqueID] inContext:self.savingContext];
    for (WalletItem *item in items) {
        [item deleteWalletItemInContext:self.savingContext];
    }
    [self.savingContext MR_saveToPersistentStoreAndWait];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:A3WalletNotificationCategoryDeleted object:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self setFirstActionSheet:nil];
    
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [self deleteCategoryByActionSheet];
	}
}

#pragma mark ActionSheet Rotation Related
- (void)rotateFirstActionSheet {
    NSInteger currentActionSheetTag = [self.firstActionSheet tag];
    [super rotateFirstActionSheet];
    [self setFirstActionSheet:nil];
    
    [self showActionSheetAdaptivelyInViewWithTag:currentActionSheetTag];
}

- (void)showActionSheetAdaptivelyInViewWithTag:(NSInteger)actionSheetTag {
    switch (actionSheetTag) {
        case 100:
            [self showDeleteCategoryActionSheet];
            break;
            
        default:
            break;
    }
}

- (void)showDeleteCategoryActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                               destructiveButtonTitle:NSLocalizedString(@"Delete Category", @"Delete Category")
                                                    otherButtonTitles:nil];
    [actionSheet showInView:self.view];
    actionSheet.tag = 100;
    [self setFirstActionSheet:actionSheet];
}

@end
