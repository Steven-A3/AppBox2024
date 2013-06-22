//
//  A3LoanCalcHistoryViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/25/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcHistoryViewController.h"
#import "A3AppDelegate.h"
#import "A3LoanCalcHistoryCell.h"
#import "LoanCalcHistory.h"
#import "common.h"
#import "NSManagedObjectContext+MagicalThreading.h"

@interface A3LoanCalcHistoryViewController ()

@end

@implementation A3LoanCalcHistoryViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	FNLOG();
	[self.myTableView registerNib:[UINib nibWithNibName:@"A3LoanCalcHistoryCell"
											   bundle:[NSBundle mainBundle]]
		 forCellReuseIdentifier:@"Single"];
}

- (NSFetchedResultsController *)fetchedResultsController {
	if (super.fetchedResultsController != nil) {
		return super.fetchedResultsController;
	}

	NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription
			entityForName:@"LoanCalcHistory" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(editing == NO) and (location == 'S')"];
	[fetchRequest setPredicate:predicate];

	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];

	[fetchRequest setFetchBatchSize:20];

	NSFetchedResultsController *theFetchedResultsController =
			[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
												managedObjectContext:managedObjectContext
												  sectionNameKeyPath:nil
														   cacheName:@"LoanCalcHistoryCache"];
	theFetchedResultsController.delegate = self;
	super.fetchedResultsController = theFetchedResultsController;

	return theFetchedResultsController;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Single";
	A3LoanCalcHistoryCell *cell = (A3LoanCalcHistoryCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	// Configure the cell...
	if (cell == nil) {
		cell = [[A3LoanCalcHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}

	LoanCalcHistory *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
	[cell setObject:object];

	return cell;
}


@end
