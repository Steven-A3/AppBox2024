//
//  A3ExpenseListHistoryViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 05/20/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3ExpenseListHistoryViewController.h"
#import "Expense.h"
#import "A3AppDelegate.h"
#import "A3UIKit.h"
#import "A3ExpenseListHistoryTableViewCell.h"
#import "common.h"
#import "UIViewController+A3AppCategory.h"
#import "A3UIDevice.h"

@interface A3ExpenseListHistoryViewController ()
<UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UITableView *myTableView;

@end

@implementation A3ExpenseListHistoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		// Custom initialization
		self.title = @"History";
	}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		FNLOG(@"failed to load data.");
	}

	[self.view addSubview:self.myTableView];
	[self addTopGradientLayerToView:self.view];
	[self setEditButton];
	[self setCloseButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setEditButton {
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onEditButton)];
	self.navigationItem.rightBarButtonItem = editButton;
}

- (void)setDoneButton {
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDoneButton)];
	self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)setCloseButton {
	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCloseButton)];
	self.navigationItem.leftBarButtonItem = closeButton;
}

- (void)onCloseButton {
	[self dismissViewControllerAnimated:YES completion:nil];
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

- (NSFetchedResultsController *)fetchedResultsController {
	if (_fetchedResultsController != nil) {
		return _fetchedResultsController;
	}

	NSManagedObjectContext *managedObjectContext = [[A3AppDelegate instance] managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription
			entityForName:@"Expense" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];

	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];

	[fetchRequest setFetchBatchSize:20];

	NSFetchedResultsController *theFetchedResultsController =
			[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
												managedObjectContext:managedObjectContext
												  sectionNameKeyPath:nil
														   cacheName:@"ExpenseCache"];
	theFetchedResultsController.delegate = self;
	self.fetchedResultsController = theFetchedResultsController;

	return _fetchedResultsController;
}

- (UITableView *)myTableView {
	if (nil == _myTableView) {
		_myTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
		_myTableView.delegate = self;
		_myTableView.dataSource = self;
		_myTableView.rowHeight = 68.0;
		_myTableView.separatorColor = [A3UIKit colorForDashLineColor];
		_myTableView.backgroundView = nil;
		_myTableView.backgroundColor = [UIColor whiteColor];
	}
	return _myTableView;
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
	static NSString *CellIdentifier = @"ExpenseListHistory";
	A3ExpenseListHistoryTableViewCell *cell = (A3ExpenseListHistoryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	// Configure the cell...
	if (cell == nil) {
		cell = [[A3ExpenseListHistoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}

	Expense *expenseObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
	[cell setExpenseObject:expenseObject];

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
		Expense *expenseObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
		NSManagedObjectContext *managedObjectContext = expenseObject.managedObjectContext;
		[managedObjectContext deleteObject:expenseObject];
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
	Expense *expenseObject = [self.fetchedResultsController objectAtIndexPath:indexPath];

	[_myTableView deselectRowAtIndexPath:indexPath animated:YES];

	if ([_delegate respondsToSelector:@selector(historySelected:)]) {
		[_delegate historySelected:expenseObject];
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
	[_myTableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {

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
	[_myTableView endUpdates];
}

@end
