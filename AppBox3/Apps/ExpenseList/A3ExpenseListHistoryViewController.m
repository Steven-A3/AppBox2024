//
//  A3ExpenseListHistoryViewController.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ExpenseListHistoryViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3ExpenseListMainViewController.h"
#import "A3ExpenseListHistoryCell.h"
#import "ExpenseListBudget.h"
#import "A3DefaultColorDefines.h"
#import "ExpenseListHistory.h"
#import "ExpenseListItem.h"
#import "ExpenseListBudgetLocation.h"
#import "UIViewController+iPad_rightSideView.h"
#import "ExpenseListHistory+extension.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"
#import "A3SyncManager.h"
#import "A3AppDelegate.h"
#import "A3UIDevice.h"

static NSString *CellIdentifier = @"Cell";

@interface A3ExpenseListHistoryViewController () <UIActionSheetDelegate>
@property (nonatomic, strong)	NSFetchedResultsController *fetchedResultsController;
@end

@implementation A3ExpenseListHistoryViewController

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

    self.title = NSLocalizedString(@"History", @"History");
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear", @"Clear") style:UIBarButtonItemStylePlain target:self action:@selector(clearButtonAction)];
	if (IS_IPHONE) {
		[self rightBarButtonDoneButton];
	}

    self.tableView.separatorInset = A3UITableViewSeparatorInset;
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}
    self.tableView.separatorColor = A3UITableViewSeparatorColor;
	[self.tableView registerClass:[A3ExpenseListHistoryCell class] forCellReuseIdentifier:CellIdentifier];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([self.navigationController.navigationBar isHidden]) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
	}
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
	[super didMoveToParentViewController:parent];

	FNLOG(@"%@", parent);
	if (!parent) {
		[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationChildViewControllerDidDismiss object:self];
	}
}

- (NSFetchedResultsController *)fetchedResultsController {
	if (!_fetchedResultsController) {
        _fetchedResultsController = [ExpenseListHistory fetchAllSortedBy:@"updateDate" ascending:NO withPredicate:nil groupBy:nil delegate:nil];
		if (![_fetchedResultsController.fetchedObjects count]) {
			self.navigationItem.leftBarButtonItem = nil;
		}
	}
	return _fetchedResultsController;
}

#pragma mark - Actions

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)clearButtonAction
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                               destructiveButtonTitle:NSLocalizedString(@"Clear History", @"Clear History")
                                                    otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [ExpenseListItem deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"budgetID != %@", A3ExpenseListCurrentBudgetID]];
        [ExpenseListBudgetLocation deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"budgetID != %@", A3ExpenseListCurrentBudgetID]];
        [ExpenseListBudget deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"uniqueID != %@", A3ExpenseListCurrentBudgetID]];
        [ExpenseListHistory truncateAll];
        
        FNLOG(@"History : %ld", (long)[ExpenseListHistory countOfEntities]);
        FNLOG(@"Budget : %ld", (long)[ExpenseListBudget countOfEntities]);
        FNLOG(@"Items : %ld", (long)[ExpenseListItem countOfEntities]);
        FNLOG(@"Location : %ld", (long)[ExpenseListBudgetLocation countOfEntities]);

        NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
        [context saveContext];
        _fetchedResultsController = nil;
        [self.tableView reloadData];
	}
}

- (void)doneButtonAction:(id)sender
{
	if (IS_IPAD) {
		[[[A3AppDelegate instance] rootViewController_iPad] dismissRightSideViewController];
	} else {
		[self dismissViewControllerAnimated:YES completion:nil];
	}

	if ([_delegate respondsToSelector:@selector(didDismissExpenseHistoryViewController)]) {
		[_delegate didDismissExpenseHistoryViewController];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    A3ExpenseListHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    ExpenseListHistory *aHistory = [_fetchedResultsController objectAtIndexPath:indexPath];
    ExpenseListBudget *aBudget = [aHistory budgetData];
    if (!aBudget) {
        return cell;
    }
    
    self.currencyFormatter.currencyCode = aBudget.currencyCode;
    [cell setExpenseBudgetData:aBudget currencyFormatter:self.currencyFormatter];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([_delegate respondsToSelector:@selector(didSelectBudgetHistory:)]) {
        ExpenseListHistory *aHistory = [_fetchedResultsController objectAtIndexPath:indexPath];
        ExpenseListBudget *aData = [aHistory budgetData];
        [_delegate didSelectBudgetHistory:aData];
        [self doneButtonAction:nil];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62.0;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ExpenseListHistory *aHistory = [_fetchedResultsController objectAtIndexPath:indexPath];
        ExpenseListBudget *aData = [aHistory budgetData];

        if ([_delegate respondsToSelector:@selector(willRemoveHistoryItemBudgetID:)]) {
            [_delegate willRemoveHistoryItemBudgetID:aData.uniqueID];
        }
        NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;

		[ExpenseListItem deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"budgetID == %@", aData.uniqueID]];
        [context deleteObject:aData];
        [context deleteObject:aHistory];

        [context saveContext];

        _fetchedResultsController = nil;
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        FNLOG(@"History : %ld", (long)[ExpenseListHistory countOfEntities]);
        FNLOG(@"Budget : %ld", (long)[ExpenseListBudget countOfEntities]);
        FNLOG(@"Items : %ld", (long)[ExpenseListItem countOfEntities]);
        FNLOG(@"Location : %ld", (long)[ExpenseListBudgetLocation countOfEntities]);
    }
}

@end
