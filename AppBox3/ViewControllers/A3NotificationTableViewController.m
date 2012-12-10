//
//  A3NotificationTableViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 12/7/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3NotificationTableViewController.h"
#import "A3NotificationCell.h"
#import "A3GradientView.h"
#import "A3UIKit.h"

@interface A3NotificationTableViewController ()

@end

@implementation A3NotificationTableViewController

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

	self.tableView.backgroundColor = [UIColor viewFlipsideBackgroundColor];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.sectionHeaderHeight = 40.0f;

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
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    A3NotificationCell *cell = [[A3NotificationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	CGFloat width = CGRectGetWidth(tableView.bounds);

	UIView *mySectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(tableView.bounds), 0.0f, width, 40.0f)];

	UIView *underlineView = [[UIView alloc] initWithFrame:CGRectMake(10.0f, 33.0f, width - 20.0f, 1.0f)];
	underlineView.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:202.0f/255.0f blue:39.0f/255.0f alpha:1.0f];
	[mySectionHeaderView addSubview:underlineView];

	UILabel *sectionTitle = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 5.0f, width - 20.0f, 30.0f)];
	sectionTitle.font = [UIFont boldSystemFontOfSize:24.0f];
	sectionTitle.textColor = [A3UIKit gradientColorRect:sectionTitle.bounds withColors:
			@[(__bridge id)[UIColor colorWithRed:254.0f/255.0f green:197.0f/255.0f blue:38.0f/255.0f alpha:1.0f].CGColor,
					(__bridge id)[UIColor colorWithRed:239.0f/255.0f green:143.0f/255.0f blue:28.0f/255.0f alpha:1.0f].CGColor]];
	sectionTitle.backgroundColor = [UIColor clearColor];
	[mySectionHeaderView addSubview:sectionTitle];

	NSArray *sectionTitles = @[@"Alarm Clock", @"Battery Life", @"Currency", @"Days Counter", @"Holidays", @"periodic Calendar", @"Stocks"];
	sectionTitle.text = [sectionTitles objectAtIndex:section];

	return mySectionHeaderView;
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

@end
