//
//  A3LadyCalendarAddAccountViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LadyCalendarAddAccountViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "A3LadyCalendarDefine.h"
#import "A3LadyCalendarModelManager.h"
#import "A3DateHelper.h"
#import "LadyCalendarAccount.h"
#import "A3UserDefaults.h"

@interface A3LadyCalendarAddAccountViewController ()
@property (strong, nonatomic) NSMutableArray *itemArray;
@property (strong, nonatomic) NSMutableDictionary *accountModel;

- (void)cancelAction:(id)sender;
- (void)dateChangeAction:(id)sender;
- (void)reloadItemAtCellType:(NSInteger)cellType;
- (void)closeDateInputCell;
@end

@implementation A3LadyCalendarAddAccountViewController

- (void)reloadItemAtCellType:(NSInteger)cellType
{
    NSMutableArray *array = [NSMutableArray array];
    for(NSInteger i=0; i < [_itemArray count]; i++){
        NSDictionary *item = [_itemArray objectAtIndex:i];
        if( [[item objectForKey:ItemKey_Type] integerValue] == cellType ){
            [array addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
    }
    if( [array count] > 0 )
        [self.tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationFade];
}


- (void)closeDateInputCell
{
    NSInteger index = NSNotFound;
    for(NSInteger i=0; i < [_itemArray count]; i++){
        NSDictionary *item = [_itemArray objectAtIndex:i];
        if( [[item objectForKey:ItemKey_Type] integerValue] == AccountCell_DateInput ){
            index = i;
            break;
        }
    }
    if( index == NSNotFound )
        return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.itemArray removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
}

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

    self.title = (_isEditMode ? @"Edit Account" : @"Add Account");
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    [self rightBarButtonDoneButton];
    
    self.itemArray = [NSMutableArray arrayWithArray:@[@{ ItemKey_Title : @"Name", ItemKey_Type : @( AccountCell_Name )},@{ ItemKey_Title : @"Birthday", ItemKey_Type : @( AccountCell_Birthday )},@{ ItemKey_Title : @"Notes", ItemKey_Type : @( AccountCell_Notes )}]];
    if( _isEditMode )
        self.accountModel = [[A3LadyCalendarModelManager sharedManager] dictionaryFromAccount:_accountItem];
    else
        self.accountModel = [[A3LadyCalendarModelManager sharedManager] emptyAccount];
    self.navigationItem.rightBarButtonItem.enabled = _isEditMode;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 15.0, 0, 0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:AccountCell_Name inSection:0]];
    if( cell ){
        UITextField *textField = (UITextField *)[cell viewWithTag:10];
        [textField becomeFirstResponder];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (_isEditMode ? 2 : 1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (section == 0 ? [_itemArray count] : 1);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if( section == 1 )
        return 36.0;
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.section == 1 ){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"removeCell"];
        if( cell == nil ){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"removeCell"];
            cell.textLabel.font = [UIFont systemFontOfSize:17.0];
            cell.textLabel.textColor = [UIColor colorWithRed:1.0 green:59.0/255.0 blue:48.0/255.0 alpha:1.0];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        }
        cell.textLabel.text = @"Delete Account";
        
        return cell;
    }
    NSArray *cellIDs = @[@"inputTitleCell",@"value1Cell",@"inputNotesCell",@"dateInputCell"];
    NSDictionary *item = [_itemArray objectAtIndex:indexPath.row];
    NSInteger cellType = [[item objectForKey:ItemKey_Type] integerValue];
    
    NSString *CellIdentifier = [cellIDs objectAtIndex:cellType];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *cellArray = [[NSBundle mainBundle] loadNibNamed:@"A3LadyCalendarAddAccountCell" owner:nil options:nil];
        if( cellType == AccountCell_Name ){
            cell = [cellArray objectAtIndex:0];
            UITextField *textField = (UITextField *)[cell viewWithTag:10];
            textField.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else if( cellType == AccountCell_Notes ){
            cell = [cellArray objectAtIndex:1];
            UITextView *textView = (UITextView*)[cell viewWithTag:10];
            textView.delegate = self;
        }
        else if( cellType == AccountCell_Birthday){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.detailTextLabel.font = [UIFont systemFontOfSize:17.0];
        }
        else if( cellType == AccountCell_DateInput ){
            cell = [cellArray objectAtIndex:2];
            UIDatePicker *datePicker = (UIDatePicker*)[cell viewWithTag:10];
            datePicker.datePickerMode = UIDatePickerModeDate;
            datePicker.maximumDate = [NSDate date];
            [datePicker addTarget:self action:@selector(dateChangeAction:) forControlEvents:UIControlEventValueChanged];
        }
        if( cellType == AccountCell_Name || cellType == AccountCell_Notes ){
            UIView *leftView = [cell viewWithTag:10];
            for(NSLayoutConstraint *layout in cell.contentView.constraints){
                if( layout.firstAttribute == NSLayoutAttributeLeading && layout.firstItem == leftView && layout.secondItem == cell.contentView )
                    layout.constant = 15.0 - (cellType == AccountCell_Notes ? 4 : 0);
            }
        }
    }
    
    if( cellType == AccountCell_Name ){
        UITextField *textField = (UITextField *)[cell viewWithTag:10];
        textField.text = [_accountModel objectForKey:AccountItem_Name];
    }
    else if( cellType == AccountCell_Birthday ){
        cell.textLabel.text = [item objectForKey:ItemKey_Title];
        NSDate *birthDay = [_accountModel objectForKey:AccountItem_Birthday];
        if( birthDay )
            cell.detailTextLabel.text = [A3DateHelper dateStringFromDate:birthDay withFormat:(IS_IPHONE ? @"EEE, MMM d, yyyy" : @"EEEE, MMMM d, yyyy")];
        else
            cell.detailTextLabel.text = @"Optional";
        if( [self.itemArray count] > 3 )
            cell.detailTextLabel.textColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        else
            cell.detailTextLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
        
    }
    else if( cellType == AccountCell_Notes){
        UITextView *textView = (UITextView*)[cell viewWithTag:10];
        textView.text = ([[_accountModel objectForKey:AccountItem_Notes] length] > 0 ? [_accountModel objectForKey:AccountItem_Notes] : [item objectForKey:ItemKey_Title]);
        textView.textColor = ([[_accountModel objectForKey:AccountItem_Notes] length] < 1 ? [UIColor colorWithWhite:0.8 alpha:1.0] : [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0]);
    
    }
    else if( cellType == AccountCell_DateInput ){
        UIDatePicker *datePicker = (UIDatePicker*)[cell viewWithTag:10];
        datePicker.datePickerMode = UIDatePickerModeDate;
        datePicker.date = ([_accountModel objectForKey:AccountItem_Birthday] ? [_accountModel objectForKey:AccountItem_Birthday] : [NSDate date]);
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self resignAllAction];
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat retHeight = 44.0;
    if( indexPath.section == 0 ){
        NSDictionary *item = [_itemArray objectAtIndex:indexPath.row];
        NSInteger cellType = [[item objectForKey:ItemKey_Type] integerValue];
        
        if( cellType == AccountCell_DateInput )
            retHeight = 236.0;
        else if( cellType == AccountCell_Notes ){
            NSString *str = [_accountModel objectForKey:AccountItem_Notes];
            CGRect strBounds = [str boundingRectWithSize:CGSizeMake(tableView.frame.size.width, 99999.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17.0]} context:nil];
            retHeight = (strBounds.size.height + 30.0 < 180.0 ? 180.0 : strBounds.size.height + 30.0);
        }
    }
    
    return retHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self resignAllAction];
    if( indexPath.section == 0 ){
        NSDictionary *item = [_itemArray objectAtIndex:indexPath.row];
        NSInteger cellType = [[item objectForKey:ItemKey_Type] integerValue];
        
        switch (cellType) {
            case AccountCell_Name:{
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                UITextField *textField = (UITextField*)[cell viewWithTag:10];
                [textField becomeFirstResponder];
            }
                break;
            case AccountCell_Birthday:{
                NSDictionary *nextItem = (indexPath.row+1 < [_itemArray count] ? [_itemArray objectAtIndex:indexPath.row+1] : nil);
                if( nextItem ){
                    NSInteger nextType = [[nextItem objectForKey:ItemKey_Type] integerValue];
                    if( nextType == AccountCell_DateInput ){
                        // close
                        [self closeDateInputCell];
                    }
                    else{
                        // open
                        [self.itemArray insertObject:@{ItemKey_Title : @"", ItemKey_Type : @(AccountCell_DateInput)} atIndex:indexPath.row+1];
                        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
                        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    }
                }
                
            }
                break;
            case AccountCell_Notes:{
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                UITextView *textView = (UITextView*)[cell viewWithTag:10];
                [textView becomeFirstResponder];
            }
                break;
        }
    }
    else{
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.selected = NO;
        
        if( [[[NSUserDefaults standardUserDefaults] objectForKey:A3LadyCalendarCurrentAccountID] isEqualToString:_accountItem.accountID]){
            [A3LadyCalendarModelManager alertMessage:@"Cannot remove current account" title:nil];
            return;
        }
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Account" otherButtonTitles:nil];
        [actionSheet showInView:self.view];
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if( buttonIndex == actionSheet.destructiveButtonIndex ){
        [[A3LadyCalendarModelManager sharedManager] removeAccount:_accountItem.accountID];
        [self cancelAction:nil];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self closeDateInputCell];
    UITableViewCell *cell = (UITableViewCell*)[[textField.superview superview] superview];
    cell.selected = YES;
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [_accountModel setObject:([text length] > 0 ? text : @"") forKey:AccountItem_Name];
    [self checkInputValues];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self closeDateInputCell];
    if( [[_accountModel objectForKey:AccountItem_Notes] length] < 1 )
        textView.text = @"";
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [_accountModel setObject:textView.text forKey:AccountItem_Notes];
    if( [[_accountModel objectForKey:AccountItem_Notes] length] < 1 ){
        textView.text = @"Notes";
    }
//    else{
        UITableViewCell *cell = (UITableViewCell*)[[[textView superview] superview] superview];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *str = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    [_accountModel setObject:([str length] > 0 ? str : @"") forKey:AccountItem_Notes];
    textView.textColor = ( [str length] > 0 ? [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0] : [UIColor colorWithWhite:0.8 alpha:1.0] );
    
    CGRect strBounds = [textView.text boundingRectWithSize:CGSizeMake(textView.frame.size.width, 99999.0) options:NSLineBreakByCharWrapping|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : textView.font} context:nil];
    
    UITableViewCell *cell = (UITableViewCell*)[[[textView superview] superview] superview];
    CGFloat diffHeight = (strBounds.size.height + 30.0 < 180.0 ? 0.0 : (strBounds.size.height + 30.0) - cell.frame.size.height);
    
    //    NSLog(@"%s %f, %@",__FUNCTION__,diffHeight,NSStringFromCGRect(strBounds));
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height + diffHeight);
    self.tableView.contentSize = CGSizeMake(self.tableView.contentSize.width, self.tableView.contentSize.height + diffHeight);
    [self.tableView scrollRectToVisible:cell.frame animated:YES];
    [self checkInputValues];
    
    return YES;
}


#pragma mark - action method
- (void)resignAllAction
{
    for(NSInteger i=0; i < [_itemArray count]; i++){
        NSDictionary *item = [_itemArray objectAtIndex:i];
        NSInteger cellType = [[item objectForKey:ItemKey_Type] integerValue];
        if( cellType == AccountCell_Name ){
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            UITextField *textField = (UITextField*)[cell viewWithTag:10];
            [textField resignFirstResponder];
        }
        else if( cellType == AccountCell_Notes ){
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            UITextView *textView = (UITextView*)[cell viewWithTag:10];
            [textView resignFirstResponder];
        }
    }
    [self checkInputValues];
}

- (void)cancelAction:(id)sender
{

//    if( IS_IPHONE )
        [self dismissViewControllerAnimated:YES completion:nil];
//    else{
//        if( !_isEditMode ){
//            [[self.A3RootViewController.centerNavigationController.viewControllers lastObject] viewWillAppear:YES];
//            [self.A3RootViewController dismissRightSideViewController];
//        }
//        else
//            [self dismissViewControllerAnimated:YES completion:nil];
//    }
}

- (void)doneButtonAction:(UIBarButtonItem *)button
{
    // 입력값 체크
    [self resignAllAction];
    if( [[_accountModel objectForKey:AccountItem_Name] length] < 1 ){
        NSInteger totalUser = [LadyCalendarAccount MR_countOfEntities];
        [_accountModel setObject:[NSString stringWithFormat:@"User%02ld", (long)totalUser+1] forKey:AccountItem_Name];
//        [A3LadyCalendarModelManager alertMessage:@"Please input name" title:nil];
//        return;
    }
//    if( [_accountModel objectForKey:AccountItem_Birthday] == nil ){
//        [A3LadyCalendarModelManager alertMessage:@"Please input birthday" title:nil];
//        return;
//    }
    
    if( _isEditMode ){
        [[A3LadyCalendarModelManager sharedManager] modifyAccount:_accountModel];
    }
    else{
        [[A3LadyCalendarModelManager sharedManager] addAccount:_accountModel];
    }
    [self cancelAction:nil];
}

- (void)dateChangeAction:(id)sender
{
    UIDatePicker *datePicker = (UIDatePicker*)sender;
    [_accountModel setObject:datePicker.date forKey:AccountItem_Birthday];
    [self reloadItemAtCellType:AccountCell_Birthday];
    [self checkInputValues];
}

- (void)checkInputValues
{
    BOOL inputEnable = NO;
    if( [[[_accountModel objectForKey:AccountItem_Name] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0 || [_accountModel objectForKey:AccountItem_Birthday] || [[[_accountModel objectForKey:AccountItem_Notes] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0 )
        inputEnable = YES;
    self.navigationItem.rightBarButtonItem.enabled = inputEnable;
}

@end
