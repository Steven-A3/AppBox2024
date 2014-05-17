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
#import "WalletCategory.h"
#import "WalletCategory+initialize.h"
#import "WalletField.h"
#import "A3AppDelegate.h"
#import "UIViewController+A3AppCategory.h"
#import "UIViewController+A3Addition.h"
#import "NSMutableArray+A3Sort.h"
#import "WalletField+initialize.h"
#import "A3WalletMainTabBarController.h"
#import "NSString+conversion.h"
#import "UIViewController+iPad_rightSideView.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3WalletCategoryEditAddNewFieldCell.h"

@interface A3WalletCategoryEditViewController () <UIActionSheetDelegate, WalletIconSelectDelegate, WalletEditFieldDelegate,  UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray *fields;
@property (nonatomic, strong) NSMutableDictionary *plusItem;
@property (nonatomic, strong) WalletField *toAddField;
@property (nonatomic, copy) NSString *originalCategoryName;
@property (nonatomic, strong) UIViewController *rightSideViewController;
@property (nonatomic, weak) UITextField *titleTextField;
@property (nonatomic, strong) MBProgressHUD *alertHUD;

@end

@implementation A3WalletCategoryEditViewController {
	BOOL _sameCategoryNameExists;
}

NSString *const A3WalletCateEditTitleCellID = @"A3WalletCateEditTitleCell";
NSString *const A3WalletCateEditIconCellID = @"A3WalletCateEditIconCell";
NSString *const A3WalletCateEditDeleteCellID = @"A3WalletCateEditDeleteCell";
NSString *const A3WalletCateEditFieldCellID = @"A3WalletCateEditFieldCell";
NSString *const A3WalletCateEditPlusCellID = @"A3WalletCateEditPlusCell";


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
		self.navigationItem.title = @"Add Category";
		_category = [WalletCategory MR_createEntity];
		[_category initValues];
		[_category assignOrder];
		_category.icon = [WalletCategory iconList][0];
	} else {
		self.navigationItem.title = @"Edit Category";
	}
	self.originalCategoryName = _category.name;
    
    [self makeBackButtonEmptyArrow];
    [self rightBarButtonDoneButton];
	self.navigationItem.rightBarButtonItem.enabled = NO;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonAction:)];
    
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

- (void)rightSideViewWillDismiss {
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)dealloc {
	[self removeObserver];
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

- (NSMutableArray *)fields
{
    if (!_fields) {
        
        _fields = [[NSMutableArray alloc] initWithArray:[_category fieldsArray]];
        [_fields addObjectToSortedArray:self.plusItem];
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
    if (_category.name.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@""
                                                       delegate:nil
                                              cancelButtonTitle:@"Enter catergory name"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

	NSManagedObjectContext *context = [[MagicalRecordStack defaultStack] context];
	if ([context hasChanges]) {
		[context MR_saveToPersistentStoreAndWait];
	}

	if (_delegate && [_delegate respondsToSelector:@selector(walletCategoryEdited:)]) {
		[_delegate walletCategoryEdited:_category];
	}

	if (_isAddingCategory) {
		[[NSNotificationCenter defaultCenter] postNotificationName:A3WalletNotificationCategoryAdded object:nil];
	} else {
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

	NSManagedObjectContext *context = [[MagicalRecordStack defaultStack] context];
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
    A3WalletEditFieldViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletEditFieldViewController"];
    viewController.field = field;
    viewController.delegate = self;
    
    return viewController;
}

- (void)addWalletField
{
    self.toAddField = [WalletField MR_createEntity];
	[self.toAddField initValues];
    _toAddField.category = self.category;

    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"WalletPhoneStoryBoard" bundle:nil];
    A3WalletEditFieldViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletEditFieldViewController"];
    viewController.isAddMode = YES;
    viewController.field = _toAddField;
    viewController.delegate = self;
    
    [self presentSubViewController:viewController];
}

- (UIViewController *)presentSubViewController:(UIViewController *)viewController {

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
    NSUInteger index = [_fields indexOfObject:field];
    NSIndexPath *ip = [NSIndexPath indexPathForRow:index inSection:1];
    
    [self.tableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationFade];
	[self setupDoneButtonEnabled];
}

- (void)walletFieldAdded:(WalletField *)field
{
    if (_toAddField == field) {
        
        NSUInteger index = [_fields indexOfObject:self.plusItem];
        [self.fields insertObjectToSortedArray:field atIndex:index];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        
        [_category addFieldsObject:field];
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
			_sameCategoryNameExists = [[WalletCategory MR_findByAttribute:@"name" withValue:changed] count] > 0;
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
	BOOL enable = [[[MagicalRecordStack defaultStack] context] hasChanges];
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
			titleCell.textField.text = _category.name;
			titleCell.textField.placeholder = @"Category Name";
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

			iconCell.iconImageView.image = [UIImage imageNamed:_category.icon];

			cell = iconCell;
		}
	}
	else if (indexPath.section == 2) {
		cell = [tableView dequeueReusableCellWithIdentifier:A3WalletCateEditDeleteCellID forIndexPath:indexPath];
	}
	else if (indexPath.section == 1) {
		if (_fields[indexPath.row] == _plusItem) {
			cell = [tableView dequeueReusableCellWithIdentifier:A3WalletCateEditPlusCellID forIndexPath:indexPath];
			cell.textLabel.text = @"add new field";
			cell.textLabel.font = [UIFont systemFontOfSize:17.0];
		}
		else if ([_fields[indexPath.row] isKindOfClass:[WalletField class]]) {
			cell = [tableView dequeueReusableCellWithIdentifier:A3WalletCateEditFieldCellID forIndexPath:indexPath];

			if (IS_RETINA) {
				UIView *rightLine = [cell.contentView viewWithTag:100];
				CGRect rect = rightLine.frame;
				rect.size.width = 0.5f;
				rightLine.frame = rect;
			}

			UIView *arrow = [cell.contentView viewWithTag:1000];
			[cell.textLabel addSubview:arrow];
			arrow.center = CGPointMake(cell.textLabel.frame.size.width-10, 22);

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

        NSMutableSet *tmp = [[NSMutableSet alloc] initWithArray:[_category fieldsArray]];
        [tmp removeObject:field];
        _category.fields = tmp;
        [_fields removeObject:field];

		[field MR_deleteEntity];

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
	[self.fields moveItemInSortedArrayFromIndex:fromIndexPath.row toIndex:toIndexPath.row];
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
        if ([_fields[indexPath.row] isKindOfClass:[WalletField class]]) {
            
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
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:@"Delete Category"
                                                        otherButtonTitles:nil];
        [actionSheet showInView:self.view];
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
		[self.category MR_deleteEntity];

		[self dismissViewControllerAnimated:YES completion:NULL];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:A3WalletNotificationCategoryDeleted object:nil];
	}
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView *subview in actionSheet.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            if ([[button titleForState:UIControlStateNormal] isEqualToString:@"Delete Category"]) {
                
                [button setTitleColor:[UIColor colorWithRed:255.0/255.0 green:59.0/255.0 blue:48.0/255.0 alpha:1.0] forState:UIControlStateNormal];
                
            }
        }
    }
}

@end
