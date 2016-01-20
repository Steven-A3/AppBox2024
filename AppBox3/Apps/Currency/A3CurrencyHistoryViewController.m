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
#import "A3CurrencyHistory3RowCell.h"
#import "CurrencyHistoryItem.h"
#import "UIViewController+NumberKeyboard.h"
#import "NSDate+TimeAgo.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+iPad_rightSideView.h"
#import "CurrencyHistory+handler.h"

@interface A3CurrencyHistoryViewController () <UIActionSheetDelegate>

@property (nonatomic, strong)	NSFetchedResultsController *fetchedResultsController;

@end

NSString *const A3CurrencyHistory3RowCellID = @"cell3Row";

@implementation A3CurrencyHistoryViewController {

}

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

	if (IS_IPHONE) {
		[self rightBarButtonDoneButton];
	}

	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear", @"Clear") style:UIBarButtonItemStylePlain target:self action:@selector(clearButtonAction:)];

	self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0];
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}

	UILabel *notice = [[UILabel alloc] init];
	notice.font = [UIFont systemFontOfSize:13];
	notice.textColor = [UIColor blackColor];
	notice.text = NSLocalizedString(@"Each history keeps max 4 currencies.", @"Each history keeps max 4 currencies.");
	notice.textAlignment = NSTextAlignmentCenter;

	CGRect frame = CGRectMake(0.0, 0.0, 320.0, 40.0);
	UIView *footerView = [[UIView alloc] initWithFrame:frame];
    footerView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];
	notice.frame = footerView.bounds;
	[footerView addSubview:notice];

	self.tableView.tableFooterView = footerView;

	[self.tableView registerClass:[A3CurrencyHistory3RowCell class] forCellReuseIdentifier:A3CurrencyHistory3RowCellID];
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

- (void)dealloc {
	[self removeObserver];
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
	// iPad has no Done button.
	if (IS_IPHONE) {
		[self.navigationController dismissViewControllerAnimated:YES completion:nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationChildViewControllerDidDismiss object:self];
		[self removeObserver];
	}
}

- (void)contentSizeDidChange:(NSNotification *)notification {
	[self.tableView reloadData];
}

- (void)clearButtonAction:(id)button {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
											   destructiveButtonTitle:NSLocalizedString(@"Clear History", @"Clear History")
													otherButtonTitles:nil];
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
		_fetchedResultsController = nil;
		[CurrencyHistory MR_truncateAll];
		[CurrencyHistoryItem MR_truncateAll];
		[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

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
			_fetchedResultsController = [CurrencyHistory MR_fetchAllSortedBy:@"updateDate" ascending:NO withPredicate:nil groupBy:nil delegate:nil];
		if (![_fetchedResultsController.fetchedObjects count]) {
			self.navigationItem.leftBarButtonItem = nil;
		}
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
	return 50.0 + [history targetCount] * 14.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CurrencyHistory *currencyHistory = [_fetchedResultsController objectAtIndexPath:indexPath];

	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	[nf setNumberStyle:NSNumberFormatterCurrencyStyle];

	A3CurrencyHistory3RowCell *cell = [tableView dequeueReusableCellWithIdentifier:A3CurrencyHistory3RowCellID forIndexPath:indexPath];
	if (!cell) {
		cell = [[A3CurrencyHistory3RowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:A3CurrencyHistory3RowCellID];
	}

	[nf setCurrencyCode:currencyHistory.currencyCode];

	NSArray *items = [currencyHistory targets];

	NSInteger numberOfLines = [currencyHistory targetCount] + 1;
	[cell setNumberOfLines:@(numberOfLines)];

	((UILabel *) cell.leftLabels[0]).text = [nf stringFromNumber:currencyHistory.value];
	((UILabel *) cell.rightLabels[0]).text = [currencyHistory.updateDate timeAgo];

	for (NSInteger index = 1; index < numberOfLines; index++) {
		CurrencyHistoryItem *item = items[index - 1];
		float rate = item.rate.floatValue / currencyHistory.rate.floatValue;
		[nf setCurrencyCode:item.currencyCode];

		((UILabel *) cell.leftLabels[index]).text = [nf stringFromNumber:@(currencyHistory.value.floatValue * rate)];
		((UILabel *) cell.rightLabels[index]).text = [NSString stringWithFormat:NSLocalizedString(@"%@ to %@ = %.4f", @"%@ to %@ = %.4f"), currencyHistory.currencyCode, item.currencyCode, rate];
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
		for (CurrencyHistoryItem *historyItem in history.targets) {
			[historyItem MR_deleteEntity];
		}
        [history MR_deleteEntity];
		[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
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
}

@end
