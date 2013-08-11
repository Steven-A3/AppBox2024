//
//  A3CurrencyHistoryViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/8/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CurrencyHistoryViewController.h"
#import "A3CurrencyHistory2RowCell.h"
#import "CurrencyHistory.h"
#import "NSManagedObject+MagicalFinders.h"
#import "A3CurrencyHistory3RowCell.h"
#import "CurrencyHistoryItem.h"
#import "NSManagedObject+MagicalRecord.h"
#import "NSManagedObjectContext+MagicalThreading.h"
#import "NSManagedObjectContext+MagicalSaves.h"
#import "UIViewController+A3AppCategory.h"
#import "NSDate+TimeAgo.h"
#import "A3UIDevice.h"
#import "A3RootViewController.h"

@interface A3CurrencyHistoryViewController () <UIActionSheetDelegate>

@property (nonatomic, strong)	NSFetchedResultsController *fetchedResultsController;

@end

NSString *const A3CurrencyHistory2RowCellID = @"cell2Row";
NSString *const A3CurrencyHistory3RowCellID = @"cell3Row";

@implementation A3CurrencyHistoryViewController

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

	self.title = @"History";

	if (IS_IPAD) {
		[self leftBarButtonDoneButton];
	}

	// Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(clearButtonAction:)];

	[self.tableView registerNib:[UINib nibWithNibName:@"A3CurrencyHistory2RowCell" bundle:[NSBundle mainBundle]]
	 forCellReuseIdentifier:A3CurrencyHistory2RowCellID];
	[self.tableView registerNib:[UINib nibWithNibName:@"A3CurrencyHistory3RowCell" bundle:[NSBundle mainBundle]]
	 forCellReuseIdentifier:A3CurrencyHistory3RowCellID];

	[self registerContentSizeCategoryDidChangeNotification];
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
	[self.A3RootViewController dismissRightSideViewController];
}

- (void)contentSizeDidChange:(NSNotification *)notification {
	[self.tableView reloadData];
}

- (void)dealloc {
	[self removeObserver];
}

- (void)clearButtonAction:(id)button {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:@"Clear History"
													otherButtonTitles:nil];
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
		_fetchedResultsController = nil;
		[CurrencyHistory MR_truncateAll];
		[CurrencyHistoryItem MR_truncateAll];
		[[NSManagedObjectContext MR_contextForCurrentThread] MR_saveOnlySelfAndWait];

		[self.tableView reloadData];
	}
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSFetchedResultsController *)fetchedResultsController {
	if (!_fetchedResultsController) {
		_fetchedResultsController = [CurrencyHistory MR_fetchAllSortedBy:@"date" ascending:NO withPredicate:nil groupBy:nil delegate:nil];
	}
	return _fetchedResultsController;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CurrencyHistory *history = [self.fetchedResultsController objectAtIndexPath:indexPath];
	return  ([history.targets count] == 1) ? 60.0 : 74.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    // Configure the cell...
	CurrencyHistory *currencyHistory = [_fetchedResultsController objectAtIndexPath:indexPath];

	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	[nf setNumberStyle:NSNumberFormatterCurrencyStyle];

//	NSDateFormatter *df = [[NSDateFormatter alloc] init];
//	[df setDateStyle:NSDateFormatterShortStyle];
//	[df setTimeStyle:NSDateFormatterShortStyle];

	if ([currencyHistory.targets count] == 1) {
		A3CurrencyHistory2RowCell *cell2Row = [tableView dequeueReusableCellWithIdentifier:A3CurrencyHistory2RowCellID forIndexPath:indexPath];
		if (!cell2Row) {
			cell2Row = [[A3CurrencyHistory2RowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:A3CurrencyHistory2RowCellID];
		}

		[nf setCurrencyCode:currencyHistory.currencyCode];
		cell2Row.L1.text = [nf stringFromNumber:currencyHistory.value];
		cell2Row.R1.text = [currencyHistory.date timeAgo];

		CurrencyHistoryItem *item = currencyHistory.targets.allObjects[0];
		float rate = item.rate.floatValue / currencyHistory.rate.floatValue;
		[nf setCurrencyCode:item.currencyCode];
		cell2Row.L2.text = [nf stringFromNumber:@(currencyHistory.value.floatValue * rate)];

		cell2Row.R2.text = [NSString stringWithFormat:@"%@ to %@ = %.4f", currencyHistory.currencyCode, item.currencyCode, rate];

		cell = cell2Row;
	} else {
		A3CurrencyHistory3RowCell *cell3Row = [tableView dequeueReusableCellWithIdentifier:A3CurrencyHistory3RowCellID forIndexPath:indexPath];
		if (!cell3Row) {
			cell3Row = [[A3CurrencyHistory3RowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:A3CurrencyHistory3RowCellID];
        }
        
        [nf setCurrencyCode:currencyHistory.currencyCode];
        cell3Row.L1.text = [nf stringFromNumber:currencyHistory.value];
        
//        cell3Row.R1.text = [df stringFromDate:currencyHistory.date];
        cell3Row.R1.text = [currencyHistory.date timeAgo];

		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
        NSArray *items = [currencyHistory.targets sortedArrayUsingDescriptors:@[sortDescriptor]];
		CurrencyHistoryItem *item1 = items[0], *item2 = items[1];
        
        float rate = item1.rate.floatValue / currencyHistory.rate.floatValue;
        [nf setCurrencyCode:item1.currencyCode];
        cell3Row.L2.text = [nf stringFromNumber:@(currencyHistory.value.floatValue * rate)];
        
        cell3Row.R2.text = [NSString stringWithFormat:@"%@ to %@ = %.4f", currencyHistory.currencyCode, item1.currencyCode, rate];
        
        rate = item2.rate.floatValue / currencyHistory.rate.floatValue;
        [nf setCurrencyCode:item2.currencyCode];
        cell3Row.L3.text = [nf stringFromNumber:@(currencyHistory.value.floatValue * rate)];
        
        cell3Row.R3.text = [NSString stringWithFormat:@"%@ to %@ = %.4f", currencyHistory.currencyCode, item2.currencyCode, rate];

		cell = cell3Row;
	}
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        CurrencyHistory *history = [_fetchedResultsController objectAtIndexPath:indexPath];
		[history.targets enumerateObjectsUsingBlock:^(CurrencyHistoryItem *obj, BOOL *stop) {
			[obj MR_deleteEntity];
		}];
		history.targets = nil;
        [history MR_deleteEntity];
		[[NSManagedObjectContext MR_contextForCurrentThread] MR_saveOnlySelfAndWait];
		_fetchedResultsController = nil;
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
