//
//  A3WalletAddCateViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 23..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletAddCateViewController.h"
#import "A3WalletIconSelectViewController.h"
#import "A3WalletEditFieldViewController.h"
#import "A3WalletCateEditTitleCell.h"
#import "A3WalletCateEditIconCell.h"
#import "WalletCategory.h"
#import "WalletCategory+initialize.h"
#import "WalletField.h"
#import "A3AppDelegate.h"
#import "UIViewController+A3AppCategory.h"
#import "NSMutableArray+A3Sort.h"
#import "UIViewController+A3Addition.h"
#import "A3WalletMainTabBarController.h"
#import "UIViewController+iPad_rightSideView.h"
#import "NSString+conversion.h"

@interface A3WalletAddCateViewController () <WalletIconSelectDelegate, WalletEditFieldDelegate,  UITextFieldDelegate>

@property (nonatomic, strong) WalletCategory *category;
@property (nonatomic, strong) NSMutableArray *fields;
@property (nonatomic, strong) NSMutableDictionary *plusItem;
@property (nonatomic, strong) UIViewController *rightSideViewController;
@property (nonatomic, strong) WalletField *toAddField;
@property (nonatomic, strong) MBProgressHUD *alertHUD;

@end

@implementation A3WalletAddCateViewController {
	BOOL _sameCategoryNameExists;
}

NSString *const A3WalletAddCateTitleCellID = @"A3WalletCateEditTitleCell";
NSString *const A3WalletAddCateIconCellID = @"A3WalletCateEditIconCell";
NSString *const A3WalletAddCateFieldCellID = @"A3WalletCateEditFieldCell";
NSString *const A3WalletAddCatePlusCellID = @"A3WalletCateEditPlusCell";

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

	self.navigationItem.title = @"Add Category";

	[self makeBackButtonEmptyArrow];

	[self leftBarButtonCancelButton];
	[self rightBarButtonDoneButton];
    self.navigationItem.rightBarButtonItem.enabled = NO;

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:A3WalletAddCateFieldCellID];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:A3WalletAddCatePlusCellID];

    self.tableView.allowsSelectionDuringEditing = YES;
    [self setEditing:YES animated:NO];
    
    self.tableView.separatorColor = [self tableViewSeparatorColor];
	self.tableView.showsVerticalScrollIndicator = NO;
    
    [self registerContentSizeCategoryDidChangeNotification];
}

- (void)contentSizeDidChange:(NSNotification *) notification
{
    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    A3WalletCateEditTitleCell *titleCell = (A3WalletCateEditTitleCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	if (![titleCell.textField.text length]) {
		[titleCell.textField becomeFirstResponder];
	}
}

- (WalletCategory *)category
{
    if (!_category) {
        _category = [WalletCategory MR_createEntity];
        _category.icon = [WalletCategory iconList][0];
    }
    
    return _category;
}

- (NSMutableArray *)fields
{
    if (!_fields) {
        _fields = [[NSMutableArray alloc] initWithArray:[self.category fieldsArray]];
        
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

- (void)clearData
{
    _category = nil;
    _fields = nil;
    _toAddField = nil;
}

- (void)cancelButtonAction:(id)sender
{
    // category 만들었던것 취소하기
    [self cancelCreateCategory];
    [self clearData];

	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneButtonAction:(id)sender
{
	[self.firstResponder resignFirstResponder];
	[self setFirstResponder:nil];

    if (_category.name.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter category name"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"Confirm"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // category 저장하고, 탭바에 추가된 category를 반영하기
    // order set
    NSMutableArray *tmp = [[NSMutableArray alloc] initWithArray:[WalletCategory MR_findAllSortedBy:@"order" ascending:YES]];
    [tmp addObjectToSortedArray:_category];
    
	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];

    // 카테고리 추가 노티 날리기
    [[NSNotificationCenter defaultCenter] postNotificationName:A3WalletNotificationCategoryAdded object:nil];
	[self clearData];

	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelCreateCategory
{
    [_category.fields enumerateObjectsUsingBlock:^(WalletField *obj, BOOL *stop) {
        [obj MR_deleteEntity];
    }];
    _category.fields = nil;
    [_category MR_deleteEntity];
}

- (void)presentSubViewController:(UIViewController *)viewController {

	[self.firstResponder resignFirstResponder];
	[self setFirstResponder:nil];

	if (IS_IPHONE) {
		[self.navigationController pushViewController:viewController animated:YES];
	} else {
		_rightSideViewController = [[A3NavigationController alloc] initWithRootViewController:viewController];
		[self presentRightSideView:_rightSideViewController.view];
		[self.navigationController addChildViewController:_rightSideViewController];
	}
}

- (void)rightSideViewDidDismiss {
	[_rightSideViewController removeFromParentViewController];
	_rightSideViewController = nil;
}

- (void)addWalletField
{
    self.toAddField = [WalletField MR_createEntity];
	self.toAddField.category = _category;

    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"WalletPhoneStoryBoard" bundle:nil];
    A3WalletEditFieldViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletEditFieldViewController"];
    viewController.isAddMode = YES;
    viewController.field = _toAddField;
    viewController.delegate = self;
    
    [self presentSubViewController:viewController];
}

- (void)disableBarItems
{
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)enableBarItems
{
    self.navigationItem.leftBarButtonItem.enabled = YES;
    if (_category.name.length>0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

#pragma mark - WalletEditFieldDelegate

- (void)walletFieldEdited:(WalletField *)field
{
    NSUInteger index = [_fields indexOfObject:field];
    NSIndexPath *ip = [NSIndexPath indexPathForRow:index inSection:1];
    
    [self.tableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)walletFieldAdded:(WalletField *)field
{
    if (_toAddField == field) {
        
        [_category addFieldsObject:field];
        _fields = nil;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)dismissedViewController:(UIViewController *)viewController
{
    NSIndexPath *sip = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:sip animated:YES];
    
    [self enableBarItems];
}

#pragma mark - WalletIconSelectDelegate

- (void)walletIconSelected:(NSString *)iconName
{
    self.category.icon = iconName;
    
    NSIndexPath *ip = [NSIndexPath indexPathForRow:1 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)dismissedWalletIconController:(UIViewController *)viewController
{
    NSIndexPath *sip = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:sip animated:YES];
    
    [self enableBarItems];
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
	textField.returnKeyType = UIReturnKeyDefault;
	textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *changed = [textField.text stringByReplacingCharactersInRange:range withString:string];
	changed = [changed stringByTrimmingSpaceCharacters];

	if ([changed length]) {
		_sameCategoryNameExists = [[WalletCategory MR_findByAttribute:@"name" withValue:changed] count] > 0;
	} else {
		_sameCategoryNameExists = NO;
	}
	if (_sameCategoryNameExists) {
		[self.alertHUD show:YES];
	} else {
		[self.alertHUD hide:YES];
	}

	self.navigationItem.rightBarButtonItem.enabled = [changed length] > 0 && !_sameCategoryNameExists;

    return YES;
}

- (MBProgressHUD *)alertHUD {
	if (!_alertHUD) {
		_alertHUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];

		// Configure for text only and offset down
		_alertHUD.mode = MBProgressHUDModeText;
		_alertHUD.margin = 2.0;
		_alertHUD.cornerRadius = 10.0;
		_alertHUD.labelText = @" Category name already exists. ";
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

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            // icon
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"WalletPhoneStoryBoard" bundle:nil];
            A3WalletIconSelectViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletIconSelectViewController"];
            viewController.selecteIconName = _category.icon;
            viewController.delegate = self;
            
            [self presentSubViewController:viewController];
            
            [self disableBarItems];
        }
    }
    else if (indexPath.section == 1) {
        if ([_fields[indexPath.row] isKindOfClass:[WalletField class]]) {
            WalletField *field = _fields[indexPath.row];
            
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"WalletPhoneStoryBoard" bundle:nil];
            A3WalletEditFieldViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletEditFieldViewController"];
            viewController.field = field;
            viewController.delegate = self;
            
            [self presentSubViewController:viewController];
            
            [self disableBarItems];
        }
        else if (_fields[indexPath.row] == self.plusItem) {
            // add wallet field
            [self addWalletField];
            
            [self disableBarItems];
        }
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 2;
    }
    else {
        return self.fields.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=nil;
	@autoreleasepool {
		cell = nil;
        
		if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                A3WalletCateEditTitleCell *titleCell;
                titleCell = [tableView dequeueReusableCellWithIdentifier:A3WalletAddCateTitleCellID forIndexPath:indexPath];
                
                titleCell.selectionStyle = UITableViewCellSelectionStyleNone;
                titleCell.textField.text = _category.name;
                titleCell.textField.placeholder = @"Category Name";
                titleCell.textField.delegate = self;
                titleCell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                titleCell.textField.font = [UIFont systemFontOfSize:17.0];
                
                cell = titleCell;
            }
            else if (indexPath.row == 1) {
                A3WalletCateEditIconCell *iconCell;
                iconCell = [tableView dequeueReusableCellWithIdentifier:A3WalletAddCateIconCellID forIndexPath:indexPath];
                
                iconCell.iconImageView.image = [UIImage imageNamed:_category.icon];
                
                cell = iconCell;
            }
		}
        else if (indexPath.section == 1) {
            if (_fields[indexPath.row] == _plusItem) {
                cell = [tableView dequeueReusableCellWithIdentifier:A3WalletAddCatePlusCellID forIndexPath:indexPath];
                cell.textLabel.text = @"add new field";
                cell.textLabel.font = [UIFont systemFontOfSize:17.0];
            }
            else if ([_fields[indexPath.row] isKindOfClass:[WalletField class]]) {
                cell = [tableView dequeueReusableCellWithIdentifier:A3WalletAddCateFieldCellID forIndexPath:indexPath];
                
                WalletField *field = _fields[indexPath.row];
                cell.textLabel.text = field.name;
                cell.textLabel.font = [UIFont systemFontOfSize:17.0];
            }
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
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        
        [self addWalletField];
    }
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

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	NSUInteger lastRowInSection1 = [tableView numberOfRowsInSection:1] - 2;
	if (proposedDestinationIndexPath.section == 0) {
		proposedDestinationIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
	} else if (proposedDestinationIndexPath.row > lastRowInSection1) {
		proposedDestinationIndexPath = [NSIndexPath indexPathForRow:lastRowInSection1 inSection:1];
	}

	return proposedDestinationIndexPath;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
