//
//  A3TipCalcHistoryViewController.m
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 5..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3TipCalcHistoryViewController.h"
#import "A3TipCalcDataManager.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3TipCalcHistoryCell.h"
#import "A3DefaultColorDefines.h"
#import "UIViewController+iPad_rightSideView.h"

NSString* const A3TipCalcHistoryCellID = @"TipCalcHistoryCell";


@interface A3TipCalcHistoryViewController () <UIActionSheetDelegate>

@property (nonatomic, strong)	NSFetchedResultsController *fetchedResultsController;

@end

@implementation A3TipCalcHistoryViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"History", @"History");
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear", @"Clear") style:UIBarButtonItemStylePlain target:self action:@selector(clearButtonAction)];
    if (IS_IPHONE) {
		[self rightBarButtonDoneButton];
	}
    
	[self.tableView registerClass:[A3TipCalcHistoryCell class] forCellReuseIdentifier:A3TipCalcHistoryCellID];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 15.0, 0, 0);
    self.tableView.separatorColor = COLOR_TABLE_SEPARATOR;
    
    [self registerContentSizeCategoryDidChangeNotification];
}

- (void)removeObserver {
	[self removeContentSizeCategoryDidChangeNotification];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
	[super didMoveToParentViewController:parent];

	FNLOG(@"%@", parent);
	if (!parent) {
		[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationChildViewControllerDidDismiss object:self];
	}
}

- (void)dealloc {
	[self removeObserver];
}

-(void)contentSizeDidChange:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSFetchedResultsController *)fetchedResultsController {
	if (!_fetchedResultsController) {
        _fetchedResultsController = [TipCalcHistory MR_fetchAllSortedBy:@"updateDate" ascending:NO withPredicate:nil groupBy:nil delegate:nil];
		if (![_fetchedResultsController.fetchedObjects count]) {
			self.navigationItem.leftBarButtonItem = nil;
		}
	}
    
	return _fetchedResultsController;
}

#pragma mark - Actions

-(void)clearButtonAction
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                               destructiveButtonTitle:NSLocalizedString(@"Clear History", @"Clear History")
                                                    otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
		[TipCalcHistory MR_truncateAll];
		[TipCalcRecent MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"historyID != NULL"]];

        _fetchedResultsController = nil;
        [self.tableView reloadData];
        
        if ([_delegate respondsToSelector:@selector(clearSelectHistoryData)]) {
            [_delegate clearSelectHistoryData];
        }
	}
}

- (void)doneButtonAction:(id)sender
{
	if (IS_IPAD) {
		[self.A3RootViewController dismissRightSideViewController];
	} else {
		[self dismissViewControllerAnimated:YES completion:nil];
	}

	if ([_delegate respondsToSelector:@selector(dismissHistoryViewController)]) {
		[_delegate performSelector:@selector(dismissHistoryViewController)];

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
    TipCalcHistory *aHistory = [self.fetchedResultsController objectAtIndexPath:indexPath];

    A3TipCalcHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:A3TipCalcHistoryCellID forIndexPath:indexPath];
    [cell setHistoryData:aHistory];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([_delegate respondsToSelector:@selector(didSelectHistoryData:)]) {
        TipCalcHistory *aData = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [_delegate didSelectHistoryData:aData];
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
        TipCalcHistory *history = [self.fetchedResultsController objectAtIndexPath:indexPath];
		[TipCalcRecent MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"historyID != %@", history.uniqueID]];
        [history MR_deleteEntity];
		[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        _fetchedResultsController = nil;
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if ([_delegate respondsToSelector:@selector(clearSelectHistoryData)]) {
            [_delegate clearSelectHistoryData];
        }
    }
}

@end
