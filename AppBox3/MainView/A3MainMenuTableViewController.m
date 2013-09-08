//
//  A3MainMenuTableViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/23/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3MainMenuTableViewController.h"
#import "A3SectionHeaderViewInMenuTableView.h"
#import "CommonUIDefinitions.h"
#import "A3ExpenseListViewController.h"
#import "A3LoanCalcViewController.h"
#import "A3UIDevice.h"
#import "A3SalesCalcQuickDialogViewController_iPad.h"
#import "A3SalesCalcQuickDialogViewController_iPhone.h"
#import "UIViewController+navigation.h"
#import "A3CurrencyViewController.h"
#import "A3AppDelegate.h"
#import "A3RootViewController_iPad.h"
#import "A3TranslatorViewController.h"
#import "A3HolidaysViewController.h"
#import "UIViewController+MMDrawerController.h"

@interface A3MainMenuTableViewController ()

@property (nonatomic, retain)	NSMutableDictionary *gridStyleCells;

@end

@implementation A3MainMenuTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		self.tableView.allowsSelection = NO;
		self.tableView.showsVerticalScrollIndicator = NO;

//		self.tableView.layer.borderWidth = 1.0;
//		self.tableView.layer.borderColor = [UIColor grayColor].CGColor;
//		self.tableView.layer.cornerRadius = 4.0;
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableDictionary *)gridStyleCells {
	if (nil == _gridStyleCells) {
		_gridStyleCells = [[NSMutableDictionary alloc] initWithCapacity:3];
	}
	return _gridStyleCells;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
	// 1. Shortcut
	// 2. Favorite Apps
	// 3. Apps
	// 4. Settings
	// 5. Information
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [self gridViewControllerAtSection:[indexPath section]].heightForContents;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

	return A3_MENU_TABLE_VIEW_SECTION_HEIGHT;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Return the number of rows in the section.
	if (section >= 3) {
		return 0;
	}
	return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	A3SectionHeaderViewInMenuTableView *sectionHeaderView = [[A3SectionHeaderViewInMenuTableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, A3_MENU_TABLE_VIEW_WIDTH, A3_MENU_TABLE_VIEW_SECTION_HEIGHT)];
	UIImage *sectionImage = [UIImage imageNamed:@"weather_sun_32_on"];
	switch ((A3_MENU_TABLE_VIEW_SECTION_TYPE)section) {
		case A3_MENU_TABLE_VIEW_SECTION_SHORTCUT:
			sectionHeaderView.title = NSLocalizedString(@"Shortcut", nil);
			sectionHeaderView.collapsed = NO;
			sectionHeaderView.image = sectionImage;
			break;
		case A3_MENU_TABLE_VIEW_SECTION_FAVORITES:
			sectionHeaderView.title = NSLocalizedString(@"Favorite Apps", nil);
			sectionHeaderView.collapsed = NO;
			sectionHeaderView.image = sectionImage;
			break;
		case A3_MENU_TABLE_VIEW_SECTION_APPS:
			sectionHeaderView.title = NSLocalizedString(@"Apps", nil);
			sectionHeaderView.collapsed = YES;
			sectionHeaderView.image = sectionImage;
			break;
		case A3_MENU_TABLE_VIEW_SECTION_SETTINGS:
			sectionHeaderView.title = NSLocalizedString(@"Settings", nil);
			sectionHeaderView.collapsed = YES;
			sectionHeaderView.image = sectionImage;
			break;
		case A3_MENU_TABLE_VIEW_SECTION_INFORMATION:
			sectionHeaderView.title = NSLocalizedString(@"Information", nil);
			sectionHeaderView.collapsed = YES;
			sectionHeaderView.image = sectionImage;
			break;
	}
	return sectionHeaderView;
}

- (A3GridStyleTableViewCell *)gridViewControllerAtSection:(NSInteger)section {
	NSString *searchKey = [NSString stringWithFormat:@"grid%d", section];
	A3GridStyleTableViewCell *cell = [self.gridStyleCells objectForKey:searchKey];
	if (nil == cell) {
		A3GridStyleTableViewCell *newCell = [[A3GridStyleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
		newCell.tag = section;
		newCell.dataSource = self;
		newCell.delegate = self;
		[newCell reload];

		[self.gridStyleCells setObject:newCell forKey:searchKey];
		return newCell;
	}
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self gridViewControllerAtSection:[indexPath section]];
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - GridViewControllerDataSource

- (NSUInteger)numberOfColumnsInGridViewController:(A3GridStyleTableViewCell *)controller {
	return 3;
}

- (NSInteger)numberOfItemsInGridViewController:(A3GridStyleTableViewCell *)controller {
	NSInteger numberOfItems = 0;
	switch ((A3_MENU_TABLE_VIEW_SECTION_TYPE)controller.tag) {
		case A3_MENU_TABLE_VIEW_SECTION_SHORTCUT:
			numberOfItems = 3;
			break;
		case A3_MENU_TABLE_VIEW_SECTION_FAVORITES:
			numberOfItems = 3;
			break;
		case A3_MENU_TABLE_VIEW_SECTION_APPS:
			numberOfItems = 6;
			break;
		case A3_MENU_TABLE_VIEW_SECTION_SETTINGS:
		case A3_MENU_TABLE_VIEW_SECTION_INFORMATION:
			numberOfItems = 0;
			break;
	}
	return numberOfItems;
}

- (UIImage *)gridStyleTableViewCell:(A3GridStyleTableViewCell *)controller imageForIndex:(NSInteger)index {
	UIImage *returningImage = nil;
	switch ((A3_MENU_TABLE_VIEW_SECTION_TYPE)controller.tag) {
		case A3_MENU_TABLE_VIEW_SECTION_SHORTCUT:
			switch (index) {
				case 0:
					returningImage = [UIImage imageNamed:@"icon_aqua"];
					break;
				case 1:
					returningImage = [UIImage imageNamed:@"icon_blue"];
					break;
				case 2:
					returningImage = [UIImage imageNamed:@"icon_green"];
					break;
			}
			break;
		case A3_MENU_TABLE_VIEW_SECTION_FAVORITES:
			switch (index) {
				case 0:
					returningImage = [UIImage imageNamed:@"icon_purple"];
					break;
				case 1:
					returningImage = [UIImage imageNamed:@"icon_red"];
					break;
				case 2:
					returningImage = [UIImage imageNamed:@"icon_yellow"];
					break;
			}
			break;
		case A3_MENU_TABLE_VIEW_SECTION_APPS:
			switch (index) {
				case 0:
					returningImage = [UIImage imageNamed:@"icon_aqua"];
					break;
				case 1:
					returningImage = [UIImage imageNamed:@"icon_blue"];
					break;
				case 2:
					returningImage = [UIImage imageNamed:@"icon_green"];
					break;
				case 3:
					returningImage = [UIImage imageNamed:@"icon_purple"];
					break;
				case 4:
					returningImage = [UIImage imageNamed:@"icon_red"];
					break;
				case 5:
					returningImage = [UIImage imageNamed:@"icon_aqua"];
					break;
			}
			break;
		case A3_MENU_TABLE_VIEW_SECTION_SETTINGS:
			break;
		case A3_MENU_TABLE_VIEW_SECTION_INFORMATION:
			break;
	}
	return returningImage;
}

- (NSString *)gridStyleTableViewCell:(A3GridStyleTableViewCell *)controller titleForIndex:(NSInteger)index {
	NSString *title = nil;

	switch ((A3_MENU_TABLE_VIEW_SECTION_TYPE)controller.tag) {
		case A3_MENU_TABLE_VIEW_SECTION_SHORTCUT:
			switch (index) {
				case 0:
					title = @"Home";
					break;
				case 1:
					title = @"Calendar";
					break;
				case 2:
					title = @"Calculator";
					break;
			}
			break;
		case A3_MENU_TABLE_VIEW_SECTION_FAVORITES:
			switch (index) {
				case 0:
					title = @"Days Counter";
					break;
				case 1:
					title = @"Notes";
					break;
				case 2:
					title = @"Wallet";
					break;
			}
			break;
		case A3_MENU_TABLE_VIEW_SECTION_APPS:
			switch (index) {
				case 0:
					title = @"Sales Calc";
					break;
				case 1:
					title = @"Expense List";
					break;
				case 2:
					title = @"Loan Calc";
					break;
				case 3:
					title = @"Currency";
					break;
				case 4:
					title = @"Translator";
					break;
				case 5:
					title = @"Holidays";
					break;
			}
			break;
		case A3_MENU_TABLE_VIEW_SECTION_SETTINGS:
			break;
		case A3_MENU_TABLE_VIEW_SECTION_INFORMATION:
			break;
	}
	return title;
}

#pragma mark - GridViewControllerDelegate

- (void)gridStyleTableViewCell:(A3GridStyleTableViewCell *)cell didSelectItemAtIndex:(NSInteger)selectedIndex {
	if (cell.tag == A3_MENU_TABLE_VIEW_SECTION_SHORTCUT) {
		switch (selectedIndex) {
			case 0:	// Home
			{
				if (IS_IPHONE) {
					UINavigationController *navigationController = (UINavigationController *) self.mm_drawerController.centerViewController;
					[navigationController popToRootViewControllerAnimated:YES];
				} else {
					[[[[A3AppDelegate instance] rootViewController] centerNavigationController] popToRootViewControllerAnimated:YES ];
				}
				break;
			}
			default:
				break;
		}
	} else
	if (cell.tag == A3_MENU_TABLE_VIEW_SECTION_APPS) {
		UIViewController *targetViewController;
		switch (selectedIndex) {
			case 0: {
				UIViewController *viewController;
				if (IS_IPAD) {
					viewController = [[A3SalesCalcQuickDialogViewController_iPad alloc] initWithNibName:nil bundle:nil];
				} else {
					viewController = [[A3SalesCalcQuickDialogViewController_iPhone alloc] initWithNibName:nil bundle:nil];
				}
				targetViewController = viewController;
				break;
			}
			case 1: {
				NSString *nibName = [NSString stringWithFormat:@"A3ExpenseListViewController_%@", IS_IPAD ? @"iPad" : @"iPhone"];
				targetViewController = [[A3ExpenseListViewController alloc] initWithNibName:nibName bundle:nil];
				break;
			}
			case 2: {
				NSString *nibName;
				if (IS_IPAD) {
					nibName = @"A3LoanCalcViewController_iPad";
				} else {
					nibName = @"A3LoanCalcViewController_iPhone";
				}
				targetViewController = [[A3LoanCalcViewController alloc] initWithNibName:nibName bundle:nil];
				break;
			}
			case 3: {
				targetViewController = [[A3CurrencyViewController alloc] initWithStyle:UITableViewStylePlain];
				break;
			}
			case 4: {
				targetViewController = [[A3TranslatorViewController alloc] initWithNibName:nil bundle:nil];
				break;
			}
			case 5: {
				targetViewController = [[A3HolidaysViewController alloc] initWithNibName:nil bundle:nil];
				break;
			}
		}
		[self popToRootAndPushViewController:targetViewController];
	}
}

@end
