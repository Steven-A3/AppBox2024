//
//  A3TimeLineTableViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 12/6/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3TimeLineTableViewController.h"
#import "A3TimeLineTableViewCell.h"
#import "A3SectionHeaderView.h"

@interface A3TimeLineTableViewController ()

@end

@implementation A3TimeLineTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    A3TimeLineTableViewCell *cell = [[A3TimeLineTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	switch ([indexPath row]) {
		case 0: {
			NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"jpg"];
			[cell setPhoto:[UIImage imageWithContentsOfFile:imagePath]];
			[cell setTitle:@"Hoya"];
			[cell setDatetimeText:@"9/17/12 6:36:31 PM"];
			break;
		}
		case 1:
			[cell setTitle:@"Rain"];
			[cell setSubtitle:@"Local"];
			[cell setDatetimeText:@"All-Day"];
			[cell setLocationText:@"📍 Seoul"];
			break;
	}
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch ([indexPath row]) {
		case 0:
			return 194.0f + 65.0f + 10.0f;
		case 1:
			return 80.0f;
	}
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 44.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	A3SectionHeaderView *sectionFooterView = [[A3SectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), 44.0f)];
	sectionFooterView.backgroundColor = [UIColor whiteColor];
	UILabel *sectionTitleLabel = [[UILabel alloc] initWithFrame:sectionFooterView.bounds];
	sectionTitleLabel.font = [UIFont boldSystemFontOfSize:24.0f];
	sectionTitleLabel.backgroundColor = [UIColor clearColor];
	sectionTitleLabel.textAlignment = UITextAlignmentCenter;
	sectionTitleLabel.text = @"2012";
	[sectionFooterView addSubview:sectionTitleLabel];
	return sectionFooterView;
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
