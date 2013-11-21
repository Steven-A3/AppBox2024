//
//  A3MainMenuTableViewController_OLD.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/23/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3MainMenuTableViewController_OLD.h"
#import "A3UIDevice.h"
#import "A3CurrencyViewController.h"
#import "A3AppDelegate.h"
#import "A3TranslatorViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "A3HolidaysPageViewController.h"
#import "A3CalculatorViewController_iPhone.h"
#import "UIViewController+A3Addition.h"
#import "A3LoanCalc2ViewController.h"

@interface A3MainMenuTableViewController_OLD ()

@end

@implementation A3MainMenuTableViewController_OLD

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		self.tableView.allowsSelection = NO;
		self.tableView.showsVerticalScrollIndicator = NO;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
	
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
	UIViewController *targetViewController = nil;
	if (cell.tag == A3_MENU_TABLE_VIEW_SECTION_SHORTCUT) {
		switch (selectedIndex) {
			case 0:	// Home
			{
				if (IS_IPHONE) {
					UINavigationController *navigationController = (UINavigationController *) self.mm_drawerController.centerViewController;
					[navigationController popToRootViewControllerAnimated:YES];
				} else {
                    [self popToRootAndPushViewController:nil];
				}
				break;
			}
			case 2:	// Calculator
			{
				if (IS_IPHONE) {
					targetViewController = [[A3CalculatorViewController_iPhone alloc] initWithNibName:nil bundle:nil];
				}
				break;
			}
			default:
				break;
		}
	} else
	if (cell.tag == A3_MENU_TABLE_VIEW_SECTION_APPS) {
		switch (selectedIndex) {
			case 0: {
				break;
			}
			case 1: {
				break;
			}
			case 2: {
				if (![self isActiveViewController:[A3LoanCalc2ViewController class]]) {
					targetViewController = [[A3LoanCalc2ViewController alloc] init];
				}
				break;
			}
			case 3: {
				if (![self isActiveViewController:[A3CurrencyViewController class]]) {
						targetViewController = [[A3CurrencyViewController alloc] initWithStyle:UITableViewStylePlain];
				}
				break;
			}
			case 4: {
				if (![self isActiveViewController:[A3TranslatorViewController class]]) {
					targetViewController = [[A3TranslatorViewController alloc] initWithNibName:nil bundle:nil];
				}
				break;
			}
			case 5: {
				if (![self isActiveViewController:[A3HolidaysPageViewController class]]) {
					targetViewController = [[A3HolidaysPageViewController alloc] initWithNibName:nil bundle:nil];
				}
				break;
			}
		}
	}
	if (targetViewController) {
		[self popToRootAndPushViewController:targetViewController];
	}
}

- (BOOL)isActiveViewController:(Class)aClass {
	UINavigationController *navigationController;

	if (IS_IPHONE) {
		navigationController = (UINavigationController *) self.mm_drawerController.centerViewController;
		[self.mm_drawerController closeDrawerAnimated:YES completion:nil];
	} else {
		A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController];
		navigationController = [rootViewController centerNavigationController];
	}
	for (UIViewController *viewController in navigationController.viewControllers) {
		if ([viewController isMemberOfClass:aClass]) {
			return YES;
		}
	}
	return NO;
}

@end
