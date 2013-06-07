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
#import "A3YellowXButton.h"
#import "A3NotificationStockCell.h"
#import "CoolButton.h"

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

- (void)setTableHeaderView {

	CGFloat width = 320.0f;
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, 44.0f)];
	headerView.backgroundColor = [UIColor clearColor];
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, width - 68.0f, 44.0f)];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.font = [UIFont systemFontOfSize:26.0f];
	titleLabel.text = @"Notifications";
	[headerView addSubview:titleLabel];

	CoolButton *doneButton = [[CoolButton alloc] initWithFrame:CGRectMake(width - 58.0f, 44.0f/2.0f - 28.0f/2.0f, 48.0f, 28.0f)];
	doneButton.buttonColor = [UIColor lightGrayColor];
	doneButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
	[doneButton setTitleColor:[UIColor colorWithRed:66.0f/255.0f green:66.0f/255.0f blue:66.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
	[doneButton setTitle:@"Done" forState:UIControlStateNormal];
	[headerView addSubview:doneButton];

	self.tableView.tableHeaderView = headerView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.tableView.backgroundColor = [UIColor viewFlipsideBackgroundColor];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.sectionHeaderHeight = 40.0f;

	[self setTableHeaderView];
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

- (BOOL)isChartRowForIndexPath:(NSIndexPath *)indexPath
{
	return (([indexPath section]) == 2 || ([indexPath section] == 6));
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat height = 44.0f;
	if ([self isChartRowForIndexPath:indexPath]) {
		height = 80.0f;
	}
	return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self isChartRowForIndexPath:indexPath]) {
		A3NotificationStockCell *stockCell = [[A3NotificationStockCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
		switch ([indexPath section]) {
			case 2:
				stockCell.leftChart.changeLabel.text = @"+0.03000000";
				stockCell.leftChart.nameLabel.text = @"USD/KRW";
				stockCell.leftChart.valueLabel.text = @"1073.33";
				stockCell.rightChart.changeLabel.text = @"-4.07";
				stockCell.rightChart.nameLabel.text = @"EUR/KRW";
				stockCell.rightChart.valueLabel.text = @"1437.73";
				break;
			case 6:
				stockCell.leftChart.changeLabel.text = @"-3.7700000";
				stockCell.leftChart.nameLabel.text = @"GOOG";
				stockCell.leftChart.valueLabel.text = @"740.98";
				stockCell.rightChart.changeLabel.text = @"+55";
				stockCell.rightChart.nameLabel.text = @"0033630.KQ";
				stockCell.rightChart.valueLabel.text = @"3,935.00";
				break;
		}
		return stockCell;
	}

	A3NotificationCell *cell = [[A3NotificationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];

	NSArray *titleArray = @[@"Good Morning", @"Remaining", @"", @"Lovely Jane's Birthday", @"Halloween", @"Next Period", @""];
	cell.messageText.text = [titleArray objectAtIndex:[indexPath section]];

	NSArray *detailedTextArray = @[@"13m ago", @"19%", @"", @"Today", @"D-16", @"Oct 23, 2012", @""];
	cell.detailText.text = [detailedTextArray objectAtIndex:[indexPath section]];

	NSArray *detailedText2Array = @[@"", @"", @"", @"to 5:05", @"", @"D-7", @""];
	cell.detailText2.text = [detailedText2Array objectAtIndex:[indexPath section]];

	[cell layoutDetailTexts];

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

	if ([sectionTitle.text isEqualToString:@"Currency"] || [sectionTitle.text isEqualToString:@"Stocks"]) {
		CGFloat tableViewWidth = CGRectGetWidth(self.tableView.bounds);
		CGFloat labelWidth = 150.0f;
		CGFloat rightSpace = 10.0f * 2.0f + 30.0f;
		UILabel *updateDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(tableViewWidth - rightSpace - labelWidth, 15.0f, labelWidth, 15.0f)];
		updateDateLabel.backgroundColor = [UIColor clearColor];
		updateDateLabel.textColor = [UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
		updateDateLabel.textAlignment = NSTextAlignmentRight;
		updateDateLabel.font = [UIFont boldSystemFontOfSize:12.0f];
		[mySectionHeaderView addSubview:updateDateLabel];

		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		updateDateLabel.text = [dateFormatter stringFromDate:[NSDate date]];

		CGFloat buttonSize = 22.0f;
		A3YellowXButton *xButton = [[A3YellowXButton alloc] initWithFrame:CGRectMake(tableViewWidth - 20.0f - buttonSize, 7.0f, buttonSize, buttonSize)];
		[mySectionHeaderView addSubview:xButton];
	}
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
