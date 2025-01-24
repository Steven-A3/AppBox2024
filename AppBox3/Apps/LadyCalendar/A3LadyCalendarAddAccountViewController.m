//
//  A3LadyCalendarAddAccountViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LadyCalendarAddAccountViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3LadyCalendarDefine.h"
#import "A3LadyCalendarModelManager.h"
#import "A3DateHelper.h"
#import "LadyCalendarAccount.h"
#import "A3UserDefaultsKeys.h"
#import "GCPlaceholderTextView.h"
#import "NSString+conversion.h"
#import "UIViewController+iPad_rightSideView.h"
#import "A3WalletNoteCell.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "NSDate+formatting.h"
#import "NSDateFormatter+A3Addition.h"
#import "LadyCalendarPeriod+extension.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "UITableView+utility.h"
#import "A3StandardTableViewCell.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"
#import "A3AppDelegate.h"
#import "A3UIDevice.h"
#import "A3UserDefaults+A3Addition.h"

@interface A3LadyCalendarAddAccountViewController ()

@property (strong, nonatomic) NSMutableArray *itemArray;
@property (copy, nonatomic) NSString *textBeforeEditingTextField;
@property (nonatomic, strong) MBProgressHUD *alertHUD;

@end

extern NSString *const A3WalletItemFieldNoteCellID;

@implementation A3LadyCalendarAddAccountViewController {
	BOOL _sameNameExists;
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

	self.title = (_isEditMode ? NSLocalizedString(@"Edit Account", @"Edit Account") : NSLocalizedString(@"Add Account", @"Add Account"));

	self.tableView.showsVerticalScrollIndicator = NO;
	self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.separatorInset = A3UITableViewSeparatorInset;
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}

	[self leftBarButtonCancelButton];
	[self rightBarButtonDoneButton];

	self.itemArray = [NSMutableArray arrayWithArray:@[
			@{
					ItemKey_Title : NSLocalizedString(@"Name", @"Name"),
					ItemKey_Type : @( AccountCell_Name )
			},
			@{
					ItemKey_Title : NSLocalizedString(@"Birthday", @"Birthday"),
					ItemKey_Type : @( AccountCell_Birthday )
			},
			@{
					ItemKey_Title : NSLocalizedString(@"Notes", @"Notes"),
					ItemKey_Type : @( AccountCell_Notes )
			}
	]];
	if ( !_isEditMode ) {
        NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;

        _accountItem = [[LadyCalendarAccount alloc] initWithContext:context];
		_accountItem.uniqueID = [[NSUUID UUID] UUIDString];
	}

	self.navigationItem.rightBarButtonItem.enabled = _isEditMode;

	[self.tableView registerClass:[A3WalletNoteCell class] forCellReuseIdentifier:A3WalletItemFieldNoteCellID];
	[self registerContentSizeCategoryDidChangeNotification];

	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willDismissRightSideView) name:A3NotificationRightSideViewWillDismiss object:nil];
	}
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)applicationWillResignActive {
	[self cancelButtonAction:nil];
}

- (void)removeObserver
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
	[self removeContentSizeCategoryDidChangeNotification];
    
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationRightSideViewWillDismiss object:nil];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
}

- (void)dealloc {
	[self removeObserver];
}

- (void)willDismissRightSideView {
	[self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	if (!_isEditMode) {
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:AccountCell_Name inSection:0]];
		if( cell ){
			UITextField *textField = (UITextField *)[cell viewWithTag:10];
			[textField becomeFirstResponder];
		}
	}
	if ([self.navigationController.navigationBar isHidden]) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
	}
}

- (void)contentSizeDidChange:(NSNotification *)notification {
	[self.tableView reloadData];
}

- (void)reloadItemAtCellType:(NSInteger)cellType
{
    NSMutableArray *array = [NSMutableArray array];
    for(NSInteger i = 0; i < [_itemArray count]; i++){
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	BOOL canDeleteThisAccount = [self.dataManager numberOfAccount] > 1;
	if (canDeleteThisAccount) {
		NSString *currentUserID = [[A3SyncManager sharedSyncManager] objectForKey:A3LadyCalendarCurrentAccountID];
		canDeleteThisAccount = ![_accountItem.uniqueID isEqualToString:currentUserID];
	}

	return (_isEditMode && canDeleteThisAccount ? 2 : 1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (section == 0 ? [_itemArray count] : 1);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //return 35.0;
    return [self standardHeightForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	BOOL isLastSection = [self.tableView numberOfSections] - 1 == section;
	return [self standardHeightForFooterIsLastSection:isLastSection];
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
        cell.textLabel.text = NSLocalizedString(@"Delete Account", @"Delete Account");
        
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
			textField.textColor = [UIColor blackColor];
            textField.delegate = self;
			textField.placeholder = NSLocalizedString(@"Name", nil);
			textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else if( cellType == AccountCell_Notes ){
			A3WalletNoteCell *noteCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemFieldNoteCellID forIndexPath:indexPath];
			[noteCell setupTextView];
			noteCell.textView.delegate = self;
			noteCell.textView.text = _accountItem.notes;
			cell = noteCell;
        }
        else if( cellType == AccountCell_Birthday){
            cell = [[A3StandardTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.detailTextLabel.font = [UIFont systemFontOfSize:17.0];
        }
        else if( cellType == AccountCell_DateInput ){
            cell = [cellArray objectAtIndex:2];
            UIDatePicker *datePicker = (UIDatePicker*)[cell viewWithTag:10];
            if (@available(iOS 13.4, *)) {
                datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
            }
            datePicker.datePickerMode = UIDatePickerModeDate;
            datePicker.maximumDate = [NSDate date];
            [datePicker addTarget:self action:@selector(dateChangeAction:) forControlEvents:UIControlEventValueChanged];
        }
        if( cellType == AccountCell_Name){
            UIView *leftView = [cell viewWithTag:10];
            for(NSLayoutConstraint *layout in cell.contentView.constraints){
                if( layout.firstAttribute == NSLayoutAttributeLeading && layout.firstItem == leftView && layout.secondItem == cell.contentView )
                    layout.constant = IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28.0;
            }
        }
    }

    if( cellType == AccountCell_Name ){
        UITextField *textField = (UITextField *)[cell viewWithTag:10];
        textField.text = _accountItem.name;
    }
    else if( cellType == AccountCell_Birthday ){
        cell.textLabel.text = [item objectForKey:ItemKey_Title];
        NSDate *birthDay = _accountItem.birthday;
        if( birthDay ) {
            NSDateFormatter *formatter = [NSDateFormatter new];
            if ([NSDate isFullStyleLocale]) {
                [formatter setDateStyle:NSDateFormatterFullStyle];
            }
            else {
                [formatter setDateFormat:[formatter customFullStyleFormat]];
            }
            
			//cell.detailTextLabel.text = [A3DateHelper dateStringFromDate:birthDay withFormat:(IS_IPHONE ? @"EEE, MMM d, yyyy" : @"EEEE, MMMM d, yyyy")];
            cell.detailTextLabel.text = [A3DateHelper dateStringFromDate:birthDay withFormat:[formatter dateFormat]];
		} else {
			cell.detailTextLabel.text = NSLocalizedString(@"Optional", @"Optional");
		}
        if( [self.itemArray count] > 3 )
            cell.detailTextLabel.textColor = [[A3UserDefaults standardUserDefaults] themeColor];
        else {
			if (birthDay) {
				cell.detailTextLabel.textColor = [UIColor colorWithRed:128.0 / 255.0 green:128.0 / 255.0 blue:128.0 / 255.0 alpha:1.0];
			} else {
				cell.detailTextLabel.textColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:205.0/255.0 alpha:1.0];
			}
		}
    }
    else if( cellType == AccountCell_DateInput ){
        UIDatePicker *datePicker = (UIDatePicker*)[cell viewWithTag:10];
        if (@available(iOS 13.4, *)) {
            datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
        }
        datePicker.datePickerMode = UIDatePickerModeDate;
        datePicker.date = _accountItem.birthday ? _accountItem.birthday : [NSDate date];
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
			return [UIViewController noteCellHeight];
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
        
        if([[[A3SyncManager sharedSyncManager] objectForKey:A3LadyCalendarCurrentAccountID] isEqualToString:_accountItem.uniqueID]){
			[A3LadyCalendarModelManager alertMessage:NSLocalizedString(@"Cannot remove current account.", @"Cannot remove current account.") title:nil];
            return;
        }
        
        [self showDeleteAccountActionSheet];
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self setFirstActionSheet:nil];
    
    if( buttonIndex == actionSheet.destructiveButtonIndex ) {
		[self.dataManager deleteAccount:_accountItem];

		[self dismissViewControllerAnimated:YES completion:nil];
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
        case 0:
            [self showDeleteAccountActionSheet];
            break;
            
        default:
            break;
    }
}

- (void)showDeleteAccountActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                               destructiveButtonTitle:NSLocalizedString(@"Delete Account", @"Delete Account")
                                                    otherButtonTitles:nil];
    [actionSheet showInView:self.view];
    actionSheet.tag = 0;
    
    [self setFirstActionSheet:actionSheet];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self closeDateInputCell];
    UITableViewCell *cell = [self.tableView cellForCellSubview:textField];
    cell.selected = YES;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	_textBeforeEditingTextField = textField.text;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
	NSString *inputName = [text stringByTrimmingSpaceCharacters];

	_accountItem.name = inputName;
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"name", inputName];
	_sameNameExists = [LadyCalendarAccount countOfEntitiesWithPredicate:predicate] > 1;

	if (_sameNameExists) {
		[self.alertHUD showAnimated:YES];
	} else {
		[self.alertHUD hideAnimated:YES];
	}

	[self checkInputValues];
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if (![textField.text length]) {
		textField.text = _textBeforeEditingTextField;
	}
	_accountItem.name = [textField.text stringByTrimmingSpaceCharacters];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
	[self.navigationItem.rightBarButtonItem setEnabled:NO];
	_textBeforeEditingTextField = @"";
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (MBProgressHUD *)alertHUD {
	if (!_alertHUD) {
		_alertHUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];

		// Configure for text only and offset down
		_alertHUD.mode = MBProgressHUDModeText;
		_alertHUD.margin = 2.0;
		_alertHUD.bezelView.layer.cornerRadius = 10.0;
		_alertHUD.label.text = NSLocalizedString(@" Same name already exists. ", @" Same name already exists. ");
		_alertHUD.label.font = [UIFont fontWithName:@"Avenir-Light" size:14.0];
		_alertHUD.label.textColor = [UIColor whiteColor];
		_alertHUD.bezelView.color = [UIColor colorWithRed:0.8f green:0.1f blue:0.2f alpha:1.000f];
		_alertHUD.userInteractionEnabled = NO;

		[self.navigationController.view addSubview:_alertHUD];
	}
	CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
	_alertHUD.offset = CGPointMake(_alertHUD.offset.x, -(screenBounds.size.height/2.0 - 64 - 18.0));
	return _alertHUD;
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self closeDateInputCell];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	_accountItem.notes = [textView.text stringByTrimmingSpaceCharacters];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *str = [textView.text stringByReplacingCharactersInRange:range withString:text];

	_accountItem.notes = [str length] > 0 ? str : @"";
    [self checkInputValues];
    
    return YES;
}

#pragma mark - action method

- (void)resignAllAction
{
    for (NSInteger i=0; i < [_itemArray count]; i++) {
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

- (void)cancelButtonAction:(UIBarButtonItem *)barButtonItem {
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    [context reset];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneButtonAction:(UIBarButtonItem *)button
{
    // 입력값 체크
    [self resignAllAction];

    if( ![_accountItem.name length] ){
        NSInteger totalUser = [self.dataManager numberOfAccount];
		_accountItem.name = [NSString stringWithFormat:@"%@%02ld", NSLocalizedString(@"User", nil), (long) totalUser + 1];
    }
	if (!_accountItem.order) {
		[_accountItem assignOrderAsLast];
	}

    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    [context saveContext];

	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dateChangeAction:(id)sender
{
    UIDatePicker *datePicker = (UIDatePicker*)sender;
	_accountItem.birthday = datePicker.date;
    [self reloadItemAtCellType:AccountCell_Birthday];
    [self checkInputValues];
}

- (void)checkInputValues
{
    self.navigationItem.rightBarButtonItem.enabled = ([[_accountItem.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) && !_sameNameExists;
}

@end
