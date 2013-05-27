//
//  A3LoanCalcCompareHistoryViewController
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/27/13 1:57 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcCompareHistoryViewController.h"
#import "A3AppDelegate.h"
#import "A3LoanCalcCompareHistoryCell.h"
#import "LoanCalcHistory.h"
#import "common.h"


@implementation A3LoanCalcCompareHistoryViewController {

}

- (void)viewDidLoad {
	[super viewDidLoad];

	FNLOG(@"%f", self.myTableView.bounds.size.width);
	self.myTableView.rowHeight = 106.0;
	[self.myTableView registerNib:[UINib nibWithNibName:@"A3LoanCalcCompareHistoryCell"
												 bundle:[NSBundle mainBundle]]
		   forCellReuseIdentifier:@"Comparison"];
}

- (NSFetchedResultsController *)fetchedResultsController {
	if (super.fetchedResultsController != nil) {
		return super.fetchedResultsController;
	}

	NSManagedObjectContext *managedObjectContext = [[A3AppDelegate instance] managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription
			entityForName:@"LoanCalcHistory" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(editing == NO) and (location == 'A')"];
	[fetchRequest setPredicate:predicate];

	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];

	[fetchRequest setFetchBatchSize:20];

	NSFetchedResultsController *theFetchedResultsController =
			[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
												managedObjectContext:managedObjectContext
												  sectionNameKeyPath:nil
														   cacheName:@"LoanCalcCompareHistoryCache"];
	theFetchedResultsController.delegate = self;
	super.fetchedResultsController = theFetchedResultsController;

	return theFetchedResultsController;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Comparison";
	A3LoanCalcCompareHistoryCell *cell = (A3LoanCalcCompareHistoryCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	// Configure the cell...
	if (cell == nil) {
		cell = [[A3LoanCalcCompareHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}

	LoanCalcHistory *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
	[cell setObject:object];

	return cell;
}

@end
