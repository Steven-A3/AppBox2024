//
//  A3WalletMoreTableViewController.m
//  AppBox3
//
//  Created by A3 on 4/13/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletMoreTableViewController.h"
#import "WalletCategory.h"
#import "WalletCategory+initialize.h"
#import "A3WalletMoreTableViewCell.h"
#import "UIViewController+A3Addition.h"
#import "A3WalletMainTabBarController.h"
#import "UITableViewController+standardDimension.h"

NSString *const A3WalletMoreTableViewCellIdentifier = @"Cell";

@interface A3WalletMoreTableViewController ()

@property (nonatomic, strong) NSMutableArray *categories;
@property (nonatomic, strong) NSArray *sections;

@end

@implementation A3WalletMoreTableViewController

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

	self.title = @"More";

	if (_isEditing) {
		[self rightBarButtonDoneButton];
	} else {
		[self leftBarButtonAppsButton];
		[self rightBarButtonEditButton];
	}

	[self.tableView registerClass:[A3WalletMoreTableViewCell class] forCellReuseIdentifier:A3WalletMoreTableViewCellIdentifier];
	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	self.tableView.showsVerticalScrollIndicator = NO;
}

- (void)rightBarButtonEditButton {
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonAction:)];
	self.navigationItem.rightBarButtonItem = editButton;
}

- (void)editButtonAction:(UIBarButtonItem *)editButton {
	A3WalletMoreTableViewController *editingViewController = [[A3WalletMoreTableViewController alloc] init];
	editingViewController.mainTabBarController = self.mainTabBarController;
	editingViewController.isEditing = YES;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:editingViewController];
	[self.mainTabBarController presentViewController:navigationController animated:YES completion:nil];
	return;
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
	[self.mainTabBarController setupTabBar];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Prepare Data

- (NSMutableArray *)categories {
	if (nil == _categories) {
		if ([[WalletCategory MR_numberOfEntities] isEqualToNumber:@0 ]) {
			[WalletCategory resetWalletCategory];
		}
		_categories = [NSMutableArray arrayWithArray:[WalletCategory MR_findAllSortedBy:@"order" ascending:YES]];
	}
	return _categories;
}

- (NSUInteger)numberOfItemsOnTapBar {
	return IS_IPHONE ? 4 : 7;
}

- (NSArray *)sections {
	if (!_sections) {
		NSUInteger numberOfItemsOnTapBar = [self numberOfItemsOnTapBar];
		NSUInteger idx = 0;

		NSMutableArray *sections = [NSMutableArray new];

		if (self.isEditing) {
			NSMutableArray *section0 = [NSMutableArray new];
			for (; idx < numberOfItemsOnTapBar; idx++) {
				[section0 addObject:self.categories[idx]];
			}
			[sections addObject:section0];
		} else {
			idx = numberOfItemsOnTapBar;
		}

		NSMutableArray *section1 = [NSMutableArray new];
		for (; idx < [self.categories count]; idx++) {
			[section1 addObject:self.categories[idx]];
		}
		[sections addObject:section1];
		_sections = sections;
	}

	return _sections;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.sections[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	A3WalletMoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:A3WalletMoreTableViewCellIdentifier forIndexPath:indexPath];

	WalletCategory *walletCategory = self.sections[indexPath.section][indexPath.row];
	cell.cellImageView.image = [UIImage imageNamed:walletCategory.icon];
	[cell.cellImageView sizeToFit];
	cell.cellTitleLabel.text = walletCategory.name;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.separatorInset = A3UITableViewSeparatorInset;
	[cell setShowCheckButton:indexPath.section == 1];

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
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
