//
//  A3SalesCalcHistoryViewController.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 17..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3SalesCalcHistoryViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3SalesCalcData.h"
#import "A3SalesCalcHistoryCell.h"
#import "A3DefaultColorDefines.h"
#import "UIViewController+iPad_rightSideView.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3AppDelegate.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"
#import "A3SyncManager.h"
#import "A3UIDevice.h"

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
    self.title = NSLocalizedString(@"History", @"History");
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear", @"Clear") style:UIBarButtonItemStylePlain target:self action:@selector(clearButtonAction)];
    if (IS_IPHONE) {
		[self rightBarButtonDoneButton];
	}
    
	[self.tableView registerClass:[A3SalesCalcHistoryCell class] forCellReuseIdentifier:A3SalesCalcHistoryCellID];
    self.tableView.separatorInset = A3UITableViewSeparatorInset;
    self.tableView.separatorColor = A3UITableViewSeparatorColor;
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}

    [self registerContentSizeCategoryDidChangeNotification];
}

- (void)removeObserver {
	[self removeContentSizeCategoryDidChangeNotification];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([self.navigationController.navigationBar isHidden]) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
	}
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
    FNLOG(@"%@", notification);
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSFetchedResultsController *)fetchedResultsController {
	if (!_fetchedResultsController) {
        _fetchedResultsController = [SalesCalcHistory_ fetchAllSortedBy:@"updateDate" ascending:NO withPredicate:nil groupBy:nil delegate:nil];
		if (![_fetchedResultsController.fetchedObjects count]) {
			self.navigationItem.leftBarButtonItem = nil;
		}
	}

	return _fetchedResultsController;
}

#pragma mark - Actions

-(void)clearButtonAction
{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil
                                                                         message:nil
                                                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *clearAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Clear History", @"Clear History")
                                                          style:UIAlertActionStyleDestructive
                                                        handler:^(UIAlertAction * _Nonnull action) {
        // Clear history logic
        [SalesCalcHistory_ truncateAll];
        NSManagedObjectContext *context = CoreDataStack.shared.persistentContainer.viewContext;
        [context saveIfNeeded];
        self->_fetchedResultsController = nil;
        [self.tableView reloadData];
        
        if ([self->_delegate respondsToSelector:@selector(clearSelectHistoryData)]) {
            [self->_delegate clearSelectHistoryData];
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];

    [actionSheet addAction:clearAction];
    [actionSheet addAction:cancelAction];
    
    // For iPad, you need to specify a popover source
    if (IS_IPAD) {
        actionSheet.popoverPresentationController.sourceView = self.view;
        actionSheet.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0);
        actionSheet.popoverPresentationController.permittedArrowDirections = 0; // No arrow
    }

    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)doneButtonAction:(id)sender
{
	if (IS_IPAD) {
		[[[A3AppDelegate instance] rootViewController_iPad] dismissRightSideViewController];
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
    SalesCalcHistory_ *aData = [_fetchedResultsController objectAtIndexPath:indexPath];
    A3SalesCalcData *historyData = [A3SalesCalcData loadDataFromHistory:aData];
    FNLOG(@"%@", historyData);
    
    A3SalesCalcHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:A3SalesCalcHistoryCellID forIndexPath:indexPath];
    [cell setSalesCalcData:historyData];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([_delegate respondsToSelector:@selector(didSelectHistoryData:)]) {
        SalesCalcHistory_ *aData = [_fetchedResultsController objectAtIndexPath:indexPath];
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
        NSManagedObjectContext *context = CoreDataStack.shared.persistentContainer.viewContext;
        SalesCalcHistory_ *history = [_fetchedResultsController objectAtIndexPath:indexPath];
        [context deleteObject:history];
        [context saveIfNeeded];
        
        _fetchedResultsController = nil;
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if ([_delegate respondsToSelector:@selector(clearSelectHistoryData)]) {
            [_delegate clearSelectHistoryData];
        }
    }
}

@end
