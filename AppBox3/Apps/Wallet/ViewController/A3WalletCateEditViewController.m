//
//  A3WalletCateEditViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 15..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletCateEditViewController.h"
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

@interface A3WalletCateEditViewController () <UIActionSheetDelegate, WalletIconSelectDelegate, WalletEditFieldDelegate,  UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray *fields;
@property (nonatomic, strong) NSMutableDictionary *plusItem;
@property (nonatomic, assign) UITextField *firstResponder;
@property (nonatomic, strong) WalletField *toAddField;
@property (nonatomic, strong) NSMutableArray *addedFieldArray;

@end

@implementation A3WalletCateEditViewController

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = @"Edit Category";
    
    [self makeBackButtonEmptyArrow];
    [self rightBarButtonDoneButton];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonAction:)];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:A3WalletCateEditPlusCellID];
    
    self.tableView.separatorColor = [self tableViewSeperatorColor];
    self.tableView.allowsSelectionDuringEditing = YES;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.tableView setEditing:YES animated:NO];
    
    [self registerContentSizeCategoryDidChangeNotification];
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

- (NSMutableArray *)addedFieldArray
{
    if (!_addedFieldArray) {
        _addedFieldArray = [[NSMutableArray alloc] init];
    }
    
    return _addedFieldArray;
}

- (void)doneButtonAction:(id)sender
{
    if (_firstResponder) {
        [_firstResponder resignFirstResponder];
    }
    
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
    
    // managed object 변화를 저장하기
	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    
    if (_delegate && [_delegate respondsToSelector:@selector(walletCategoryEdited:)]) {
        [_delegate walletCategoryEdited:_category];
    }
    
    if (IS_IPAD) {
        
        // custom cross dissolve animation
        self.view.alpha = 1.0;
        [UIView animateWithDuration: 0.3
                         animations:^{
                             self.view.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             [self.navigationController popViewControllerAnimated:NO];
                         }];
    }
    else {
        [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)cancelButtonAction:(id)sender
{
    // managed object 변화를 원상태로 돌리기
    if ([_category hasChanges]) {
        [_category.managedObjectContext refreshObject:_category mergeChanges:NO];
    }
    
    // wallet field 변경된것도 초기화하기
    NSArray *walletFields = [_category fieldsArray];
    for (int i=0; i<walletFields.count; i++) {
        WalletField *walletField = walletFields[i];
        if ([walletField hasChanges]) {
            [walletField.managedObjectContext refreshObject:walletField mergeChanges:NO];
        }
    }
    
    // 추가된 filed는 삭제하기
    for (int i=0; i<self.addedFieldArray.count; i++) {
        WalletField *addField = _addedFieldArray[i];
        [addField MR_deleteEntity];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(walletCateEditCanceled)]) {
        [_delegate walletCateEditCanceled];
    }
    
    if (IS_IPAD) {
        // custom cross dissolve animation
        self.view.alpha = 1.0;
        [UIView animateWithDuration: 0.3
                         animations:^{
                             self.view.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             [self.navigationController popViewControllerAnimated:NO];
                         }];
    }
    else {
        [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
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
    _toAddField.category = self.category;
    [_toAddField initTypeAndStyle];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"WalletPhoneStoryBoard" bundle:nil];
    A3WalletEditFieldViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletEditFieldViewController"];
    viewController.isAddMode = YES;
    viewController.field = _toAddField;
    viewController.delegate = self;
    
    [self presentSubViewController:viewController];
}

- (void)presentSubViewController:(UIViewController *)viewController {
    
    if (_firstResponder) {
        [_firstResponder resignFirstResponder];
    }
    
	if (IS_IPHONE) {
		[self.navigationController pushViewController:viewController animated:YES];
	} else {
		A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController];
		[rootViewController presentRightSideViewController:viewController];
	}
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
        
        NSUInteger index = [_fields indexOfObject:self.plusItem];
        [self.fields insertObjectToSortedArray:field atIndex:index];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        
        [_category addFieldsObject:field];
        
        [self.addedFieldArray addObject:field];
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
    _firstResponder = nil;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _firstResponder = textField;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *tobe = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (tobe.length>0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    return YES;
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if (section == 0) {
        return 2;
    }
    else if (section == 2) {
        return 1;
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
                titleCell = [tableView dequeueReusableCellWithIdentifier:A3WalletCateEditTitleCellID forIndexPath:indexPath];
                
                titleCell.selectionStyle = UITableViewCellSelectionStyleNone;
                titleCell.textField.text = _category.name;
                titleCell.textField.delegate = self;
                titleCell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                
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
                
                cell.textLabel.font = [UIFont systemFontOfSize:17.0];
                WalletField *field = _fields[indexPath.row];
                cell.textLabel.text = field.name;
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
    @autoreleasepool {
        [self.fields moveItemInSortedArrayFromIndex:fromIndexPath.row toIndex:toIndexPath.row];
	}
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
    if (sourceIndexPath.section != proposedDestinationIndexPath.section) {
        NSInteger row = 0;
        if (sourceIndexPath.section < proposedDestinationIndexPath.section) {
            row = [tableView numberOfRowsInSection:sourceIndexPath.section] - 2;
        }
        return [NSIndexPath indexPathForRow:row inSection:sourceIndexPath.section];
    }
    else {
        NSInteger row = 0;
        if (proposedDestinationIndexPath.row == ([tableView numberOfRowsInSection:proposedDestinationIndexPath.section]-1)) {
            row = proposedDestinationIndexPath.row-1;
            
            return [NSIndexPath indexPathForRow:row inSection:sourceIndexPath.section];
        }
    }
    
    
    return proposedDestinationIndexPath;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_firstResponder) {
        [_firstResponder resignFirstResponder];
    }
    
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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
        
        [self.category deleteAndClearRelated];
        
        [self dismissViewControllerAnimated:YES completion:NULL];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CategoryDeleted" object:nil];
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
