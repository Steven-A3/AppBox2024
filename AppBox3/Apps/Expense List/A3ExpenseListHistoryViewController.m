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

@end

@implementation A3ExpenseListHistoryViewController

- (NSFetchedResultsController *)fetchedResultsController {
	if (super.fetchedResultsController != nil) {
		return super.fetchedResultsController;
	}

	NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_mainQueueContext];
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
	super.fetchedResultsController = theFetchedResultsController;

	return theFetchedResultsController;
}

#pragma mark - Table view data source

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

@end
