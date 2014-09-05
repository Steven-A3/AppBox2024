//
//  A3LadyCalendarAccountListViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LadyCalendarAccountListViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3LadyCalendarModelManager.h"
#import "A3LadyCalendarAddAccountViewController.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "NSMutableArray+A3Sort.h"
#import "LadyCalendarAccount.h"

@interface A3LadyCalendarAccountListViewController ()

@property (strong, nonatomic) NSMutableArray *ladyCalendarAccounts;
@property (strong, nonatomic) UIImage *checkImage;
@property (strong, nonatomic) NSManagedObjectContext *savingContext;

@end

@implementation A3LadyCalendarAccountListViewController

- (id)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {

	}

	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Edit Accounts", @"Edit Accounts");

	self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.allowsSelectionDuringEditing = YES;
	self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.separatorInset = A3UITableViewSeparatorInset;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction:)];
    [self rightBarButtonDoneButton];

	self.checkImage = [[UIImage imageNamed:@"check_02"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

	[self.tableView setEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

	[self.savingContext reset];
	_ladyCalendarAccounts = nil;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSManagedObjectContext *)savingContext {
	if (!_savingContext) {
		_savingContext = [NSManagedObjectContext MR_rootSavingContext];
	}
	return _savingContext;
}

- (NSMutableArray *)ladyCalendarAccounts {
	if (!_ladyCalendarAccounts) {
		NSArray *accounts = [LadyCalendarAccount MR_findAllInContext:self.savingContext];
		_ladyCalendarAccounts = [NSMutableArray arrayWithArray:accounts];
	}
	return _ladyCalendarAccounts;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.ladyCalendarAccounts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *cellArray = [[NSBundle mainBundle] loadNibNamed:@"A3LadyCalendarAccountListCell" owner:nil options:nil];
        cell = [cellArray objectAtIndex:2];
        UIImageView *imageView = (UIImageView*)[cell viewWithTag:12];
        imageView.image = self.checkImage;
		imageView.tintColor = [[A3AppDelegate instance] themeColor];
	}
    
    LadyCalendarAccount *account = [self.ladyCalendarAccounts objectAtIndex:indexPath.row];
    UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
    UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:11];
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:12];
    
    textLabel.text = account.name;

	if (account.birthday) {
		NSDateFormatter *dateFormatter = [NSDateFormatter new];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		detailTextLabel.text = [dateFormatter stringFromDate:account.birthday];
	} else {
		detailTextLabel.text = @"";
	}

	UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[editButton setImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateNormal];
	editButton.bounds = CGRectMake(0, 0, 44, 44);
	editButton.tag = indexPath.row;
	[editButton addTarget:self action:@selector(editButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.editingAccessoryView = editButton;

    NSString *defaultID = [[A3SyncManager sharedSyncManager] objectForKey:A3LadyCalendarCurrentAccountID];
    imageView.hidden = ![account.uniqueID isEqualToString:defaultID];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	[_ladyCalendarAccounts moveItemInSortedArrayFromIndex:fromIndexPath.row toIndex:toIndexPath.row];
	[self.savingContext MR_saveToPersistentStoreAndWait];
    
	double delayInSeconds = 0.15;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
		[self.tableView reloadData];
	});
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	LadyCalendarAccount *account = [_ladyCalendarAccounts objectAtIndex:indexPath.row];
	[_dataManager setCurrentAccount:account];

	[[A3SyncManager sharedSyncManager] setObject:account.uniqueID forKey:A3LadyCalendarCurrentAccountID state:A3DataObjectStateModified];

    [self.tableView reloadData];
}

#pragma mark - action method

- (void)editButtonAction:(UIButton *)button
{
	LadyCalendarAccount *account = [_ladyCalendarAccounts objectAtIndex:button.tag];
	
    A3LadyCalendarAddAccountViewController *viewCtrl = [[A3LadyCalendarAddAccountViewController alloc] init];
	viewCtrl.dataManager = _dataManager;
	viewCtrl.isEditMode = YES;
	viewCtrl.accountItem = [account MR_inContext:viewCtrl.savingContext];

	A3NavigationController *navCtrl = [[A3NavigationController alloc] initWithRootViewController:viewCtrl];
	navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
	[self presentViewController:navCtrl animated:YES completion:nil];
}

- (void)doneButtonAction:(UIBarButtonItem *)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addAction:(id)sender
{
    A3LadyCalendarAddAccountViewController *viewCtrl = [[A3LadyCalendarAddAccountViewController alloc] init];
	viewCtrl.dataManager = _dataManager;
	viewCtrl.isEditMode = NO;
    A3NavigationController *navCtrl = [[A3NavigationController alloc] initWithRootViewController:viewCtrl];
    navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:navCtrl animated:YES completion:nil];
}

@end
