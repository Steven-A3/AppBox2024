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
#import "A3CalcExpressionView.h"
#import "A3UIDevice.h"
#import "NSString+conversion.h"

@interface A3SalesCalcHistoryViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
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

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"editing == NO"];
	[fetchRequest setPredicate:predicate];

	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];

	[fetchRequest setFetchBatchSize:20];

	NSFetchedResultsController *theFetchedResultsController =
			[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
												managedObjectContext:managedObjectContext
												  sectionNameKeyPath:nil
														   cacheName:@"SalesCalcHistory"];
	theFetchedResultsController.delegate = self;
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

	[self setEditButton];

	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		FNLOG(@"failed to load data.");
	}

	self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
	UIView *coverView = [[UIView alloc] initWithFrame:self.view.bounds];
	coverView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.9];
	[self.view addSubview:coverView];

	CGRect frame = [A3UIDevice deviceOrientationIsPortrait] ? CGRectMake(0.0, 0.0, 320.0, 960) : CGRectMake(0.0, 0.0, 320.0, 704);

	_myTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
	_myTableView.dataSource = self;
	_myTableView.delegate = self;

	_myTableView.rowHeight = 68.0;
	_myTableView.separatorColor = [A3UIKit colorForDashLineColor];
	_myTableView.backgroundView = nil;
	_myTableView.backgroundColor = [UIColor clearColor];

	[self.view addSubview:_myTableView];
}

- (void)setEditButton {
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onEditButton)];
	self.navigationItem.rightBarButtonItem = editButton;
}

- (void)setDoneButton {
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDoneButton)];
	self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)onEditButton {
	[_myTableView setEditing:NO];
	[_myTableView setEditing:YES];
	[self setDoneButton];
}

- (void)onDoneButton {
	[_myTableView setEditing:NO];
	[self setEditButton];
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
	cell.dateLabel.text = [self.dateFormatter stringFromDate:history.created];

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

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	// If none of the above are returned, then return \"none\".
	return UITableViewCellEditingStyleDelete;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		SalesCalcHistory *salesCalcHistory = [self.fetchedResultsController objectAtIndexPath:indexPath];
		NSManagedObjectContext *managedObjectContext = salesCalcHistory.managedObjectContext;
		[managedObjectContext deleteObject:salesCalcHistory];
	}
}

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
	SalesCalcHistory *history = [self.fetchedResultsController objectAtIndexPath:indexPath];

	[_myTableView deselectRowAtIndexPath:indexPath animated:YES];
	id <A3SalesCalcQuickDialogDelegate> o = self.delegate;
	if ([o respondsToSelector:@selector(reloadContentsWithObject:)]) {
		[o reloadContentsWithObject:history];
	}
	if (!DEVICE_IPAD) {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

#pragma mark - NSFetchedResultController delegate

/*
 Assume self has a property 'tableView' -- as is the case for an instance of a UITableViewController
 subclass -- and a method configureCell:atIndexPath: which updates the contents of a given cell
 with information from a managed object at the given index path in the fetched results controller.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	FNLOG(@"Check");
	[_myTableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	FNLOG(@"Check");

	switch(type) {
		case NSFetchedResultsChangeInsert:
			[_myTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
						  withRowAnimation:UITableViewRowAnimationFade];
			break;

		case NSFetchedResultsChangeDelete:
			[_myTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
						  withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath {
	FNLOG(@"Check");

	UITableView *tableView = _myTableView;

	switch(type) {

		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
			break;

		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
			break;

		case NSFetchedResultsChangeUpdate:
//			[self configureCell:[tableView cellForRowAtIndexPath:indexPath]
//					atIndexPath:indexPath];
			break;

		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	FNLOG(@"Check");
	[_myTableView endUpdates];
}

@end
