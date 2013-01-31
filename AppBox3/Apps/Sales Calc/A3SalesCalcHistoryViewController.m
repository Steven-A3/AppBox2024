//
//  A3SalesCalcHistoryViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 1/29/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3SalesCalcHistoryViewController.h"
#import "A3AppDelegate.h"
#import "common.h"
#import "A3UIKit.h"
#import "A3SalesCalcHistoryTableViewCell.h"
#import "SalesCalcHistory.h"
#import "A3Categories.h"
#import "A3CalcExpressionView.h"

@interface A3SalesCalcHistoryViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSNumberFormatter *currencyNumberFormatter;
@property (nonatomic, strong) UITableView *myTableView;

@end

@implementation A3SalesCalcHistoryViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
		self.title = @"History";
    }
    return self;
}

- (NSFetchedResultsController *)fetchedResultsController {
	if (_fetchedResultsController != nil) {
		return _fetchedResultsController;
	}

	NSManagedObjectContext *managedObjectContext = [[A3AppDelegate instance] managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription
			entityForName:@"SalesCalcHistory" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];

	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"createdDate" ascending:NO];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];

	[fetchRequest setFetchBatchSize:20];

	NSFetchedResultsController *theFetchedResultsController =
			[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
												managedObjectContext:managedObjectContext
												  sectionNameKeyPath:nil
														   cacheName:@"SalesCalcHistory"];
	self.fetchedResultsController = theFetchedResultsController;

	return _fetchedResultsController;
}

- (NSDateFormatter *)dateFormatter {
	if (nil == _dateFormatter) {
		_dateFormatter = [[NSDateFormatter alloc] init];
		[_dateFormatter setDateStyle:NSDateFormatterShortStyle];
		[_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	}
	return _dateFormatter;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		FNLOG(@"failed to load data.");
	}

	self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
	UIView *coverView = [[UIView alloc] initWithFrame:self.view.bounds];
	coverView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.9];
	[self.view addSubview:coverView];

	_myTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
	_myTableView.dataSource = self;
	_myTableView.delegate = self;

	_myTableView.rowHeight = 68.0;
	_myTableView.separatorColor = [A3UIKit colorForDashLineColor];
	_myTableView.backgroundView = nil;
	_myTableView.backgroundColor = [UIColor clearColor];

	[self.view addSubview:_myTableView];
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
	return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section.
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SalesCalcHistory";
    A3SalesCalcHistoryTableViewCell *cell = (A3SalesCalcHistoryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
	if (cell == nil) {
		cell = [[A3SalesCalcHistoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}

	SalesCalcHistory *history = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.dateLabel.text = [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:history.createdDate]];

	cell.salePriceLabel.text = history.salePrice;
	cell.notesLabel.text = history.notes;

	NSString *discountString;
	discountString = [NSString stringWithFormat:@"%@(%.3f%%)", history.amountSaved, [history.amountSaved floatValueEx] / [history.originalPrice floatValueEx] * 100.0];
	NSArray *expressionArray = @[history.originalPrice, @"-", discountString, @"="];

	NSArray *expressionAttributeArray = @[
			@{A3ExpressionAttributeFont:[UIFont boldSystemFontOfSize:18.0], A3ExpressionAttributeTextColor:[UIColor colorWithRed:73.0/255.0 green:74.0/255.0 blue:73.0/255.0 alpha:1.0]},
			@{},
			@{A3ExpressionAttributeFont:[UIFont boldSystemFontOfSize:18.0], A3ExpressionAttributeTextColor:[UIColor colorWithRed:42.0/255.0 green:125.0/255.0 blue:0.0 alpha:1.0]},
			@{}];
	cell.expressionView.expression = expressionArray;
	cell.expressionView.attributes = expressionAttributeArray;

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

@end
