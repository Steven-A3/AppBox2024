//
//  A3SalesCalcHistoryViewController.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 17..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3SalesCalcHistoryViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "SalesCalcHistory.h"
#import "A3SalesCalcData.h"
#import "A3SalesCalcHistoryCell.h"
#import "A3DefaultColorDefines.h"
#import "UIViewController+navigation.h"

NSString *const A3SalesCalcHistoryCellID = @"cell1";

@interface A3SalesCalcHistoryViewController () <UIActionSheetDelegate>
@property (nonatomic, strong)	NSFetchedResultsController *fetchedResultsController;
@end

@implementation A3SalesCalcHistoryViewController

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
	// Do any additional setup after loading the view.
    self.title = @"History";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(clearButtonAction)];
    if (IS_IPHONE) {
		[self rightBarButtonDoneButton];
	}
    
	[self.tableView registerClass:[A3SalesCalcHistoryCell class] forCellReuseIdentifier:A3SalesCalcHistoryCellID];
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
    NSLog(@"%@", notification);
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSFetchedResultsController *)fetchedResultsController {
	if (!_fetchedResultsController) {
        _fetchedResultsController = [SalesCalcHistory MR_fetchAllSortedBy:@"historyDate" ascending:NO withPredicate:nil groupBy:nil delegate:nil];
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
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Clear History"
                                                    otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [SalesCalcHistory MR_truncateAll];
		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
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
    SalesCalcHistory *aData = [_fetchedResultsController objectAtIndexPath:indexPath];
    A3SalesCalcData *historyData = [A3SalesCalcData loadDataFromHistory:aData];
    NSLog(@"%@", historyData);
    
    A3SalesCalcHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:A3SalesCalcHistoryCellID forIndexPath:indexPath];
    [cell setSalesCalcData:historyData];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([_delegate respondsToSelector:@selector(didSelectHistoryData:)]) {
        SalesCalcHistory *aData = [_fetchedResultsController objectAtIndexPath:indexPath];
        A3SalesCalcData *historyData = [A3SalesCalcData loadDataFromHistory:aData];
        [_delegate didSelectHistoryData:historyData];
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
        SalesCalcHistory *history = [_fetchedResultsController objectAtIndexPath:indexPath];
        [history MR_deleteEntity];
		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
        _fetchedResultsController = nil;
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if ([_delegate respondsToSelector:@selector(clearSelectHistoryData)]) {
            [_delegate clearSelectHistoryData];
        }
    }
}

@end
