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
#import "A3WalletCateEditTitleCell.h"
#import "WalletData.h"
#import "WalletField.h"
#import "A3AppDelegate.h"
#import "UIViewController+A3AppCategory.h"
#import "UIViewController+A3Addition.h"

@interface A3WalletEditFieldViewController () <WalletFieldTypeSelectDelegate, WalletFieldStyleSelectDelegate, UITextFieldDelegate>

@property (nonatomic, assign) UITextField *firstResponder;

@end

@implementation A3WalletEditFieldViewController

NSString *const A3WalletFieldEditTitleCellID = @"A3WalletCateEditTitleCell";
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = _isAddMode ? @"Add Field" : @"Edit Field";
    
    [self makeBackButtonEmptyArrow];
    
    self.tableView.separatorColor = [self tableViewSeparatorColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    
    // keyboard up
    if (_isAddMode) {
        [self performSelector:@selector(titlekeyboardUp) withObject:nil afterDelay:0.8f];
    }
    
    [self registerContentSizeCategoryDidChangeNotification];
}

- (void)contentSizeDidChange:(NSNotification *) notification
{
    [self.tableView reloadData];
}

- (void)titlekeyboardUp
{
    A3WalletCateEditTitleCell *titleCell = (A3WalletCateEditTitleCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [titleCell.textField becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (![self.navigationController.viewControllers containsObject:self]) {
        if (IS_IPHONE) {
            if (_field.name.length > 0) {
                [self updateEditedInfo];
            }
            else {
                [_field MR_deleteEntity];
            }
            
            if (_delegate && [_delegate respondsToSelector:@selector(dismissedViewController:)]) {
                [_delegate dismissedViewController:self];
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doneButtonAction:(id)sender
{
    if (_firstResponder) {
        [_firstResponder resignFirstResponder];
    }
    
    if (IS_IPAD) {
        
        if (_field.name.length > 0) {
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

- (void)walletFieldTypeSelected:(NSString *)fieldType
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

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _field.name = textField.text;
    _firstResponder = nil;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _firstResponder = textField;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
	@autoreleasepool {
		cell = nil;
        
		if (indexPath.section == 0) {
            A3WalletCateEditTitleCell *titleCell;
            titleCell = [tableView dequeueReusableCellWithIdentifier:A3WalletFieldEditTitleCellID forIndexPath:indexPath];

            titleCell.selectionStyle = UITableViewCellSelectionStyleNone;
            titleCell.textField.textColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
            titleCell.textField.font = [UIFont systemFontOfSize:17];
            titleCell.textField.text = _field.name;
            titleCell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            titleCell.textField.placeholder = @"Field Name";
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
            
            cell.textLabel.text = @"Type";
            cell.detailTextLabel.text = _field.type;
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
            
            cell.textLabel.text = @"Style";
            cell.detailTextLabel.text = _field.style;
        }
	}
    
    return cell;
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
