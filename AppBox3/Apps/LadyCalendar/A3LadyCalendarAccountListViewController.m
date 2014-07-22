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
#import "A3LadyCalendarDefine.h"
#import "A3LadyCalendarModelManager.h"
#import "LadyCalendarAccount.h"
#import "A3LadyCalendarAddAccountViewController.h"
#import "SFKImage.h"
#import "A3DateHelper.h"
#import "A3UserDefaults.h"
#import "A3AppDelegate+appearance.h"
#import "UIViewController+tableViewStandardDimension.h"

@interface A3LadyCalendarAccountListViewController ()

@property (strong, nonatomic) NSMutableArray *itemArray;
@property (strong, nonatomic) UIImage *checkImage;

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
	if (IS_IPHONE) {
		[self rightBarButtonDoneButton];
	}

	self.checkImage = [[UIImage imageNamed:@"check_02"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

	[self.tableView setEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.itemArray = [NSMutableArray arrayWithArray:[_dataManager accountListSortedByOrderIsAscending:YES]];
    [self.tableView reloadData];

	if (IS_IPAD) {
		[A3AppDelegate instance].rootViewController.modalPresentedInRightNavigationViewController = nil;
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_itemArray count];
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
    
    LadyCalendarAccount *item = [_itemArray objectAtIndex:indexPath.row];
    UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
    UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:11];
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:12];
    
    textLabel.text = item.name;

	if (item.birthDay) {
		NSDateFormatter *dateFormatter = [NSDateFormatter new];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		detailTextLabel.text = [dateFormatter stringFromDate:item.birthDay];
	} else {
		detailTextLabel.text = @"";
	}

	UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[editButton setImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateNormal];
	editButton.bounds = CGRectMake(0, 0, 44, 44);
	editButton.tag = indexPath.row;
	[editButton addTarget:self action:@selector(editButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.editingAccessoryView = editButton;

    NSString *defaultID = [[NSUserDefaults standardUserDefaults] objectForKey:A3LadyCalendarCurrentAccountID];
    imageView.hidden = ![item.uniqueID isEqualToString:defaultID];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35.0;
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
    LadyCalendarAccount *item = [_itemArray objectAtIndex:fromIndexPath.row];
    [_itemArray removeObjectAtIndex:fromIndexPath.row];
    [_itemArray insertObject:item atIndex:toIndexPath.row];
    
    [self reorderingItems];

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
	LadyCalendarAccount *account = [_itemArray objectAtIndex:indexPath.row];
	[_dataManager setCurrentAccount:account];

	NSDate *updateDate = [NSDate date];
	[[NSUserDefaults standardUserDefaults] setObject:updateDate forKey:A3LadyCalendarUserDefaultsUpdateDate];
	[[NSUserDefaults standardUserDefaults] setObject:account.uniqueID forKey:A3LadyCalendarCurrentAccountID];
	[[NSUserDefaults standardUserDefaults] synchronize];

	if ([[A3AppDelegate instance].ubiquityStoreManager cloudEnabled]) {
		NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
		[store setObject:account.uniqueID forKey:A3LadyCalendarCurrentAccountID];
		[store setObject:updateDate forKey:A3LadyCalendarUserDefaultsCloudUpdateDate];
		[store synchronize];
	}

	[self.tableView reloadData];
}

#pragma mark - action method

- (void)editButtonAction:(UIButton *)button
{
	LadyCalendarAccount *item = [_itemArray objectAtIndex:button.tag];
	
    A3LadyCalendarAddAccountViewController *viewCtrl = [[A3LadyCalendarAddAccountViewController alloc] init];
	viewCtrl.dataManager = _dataManager;
	viewCtrl.isEditMode = YES;
	viewCtrl.accountItem = item;
    
	A3NavigationController *navCtrl = [[A3NavigationController alloc] initWithRootViewController:viewCtrl];
	navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
	[self presentViewController:navCtrl animated:YES completion:nil];

	if (IS_IPAD) {
		[A3AppDelegate instance].rootViewController.modalPresentedInRightNavigationViewController = navCtrl;
	}
}

- (void)doneButtonAction:(UIBarButtonItem *)button
{
	if ( IS_IPHONE ) {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

- (void)addAction:(id)sender
{
    A3LadyCalendarAddAccountViewController *viewCtrl = [[A3LadyCalendarAddAccountViewController alloc] init];
	viewCtrl.dataManager = _dataManager;
    A3NavigationController *navCtrl = [[A3NavigationController alloc] initWithRootViewController:viewCtrl];
    navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:navCtrl animated:YES completion:nil];

	if (IS_IPAD) {
		[A3AppDelegate instance].rootViewController.modalPresentedInRightNavigationViewController = navCtrl;
	}
}

- (void)reorderingItems
{
	for (NSInteger i=0; i < [_itemArray count]; i++) {
		LadyCalendarAccount *item = [_itemArray objectAtIndex:i];
		item.order = [NSNumber numberWithInteger:i+1];
	}

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
}

@end
