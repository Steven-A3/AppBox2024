//
//  A3UnitPriceHistoryViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 6..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3UnitPriceHistoryViewController.h"
#import "UIViewController+NumberKeyboard.h"
#import "NSDate+TimeAgo.h"
#import "UIViewController+A3Addition.h"
#import "UnitPriceHistory.h"
#import "A3UnitPriceHistoryCell.h"
#import "UIViewController+iPad_rightSideView.h"
#import "UnitPriceHistory+extension.h"
#import "UnitPriceInfo.h"
#import "UnitPriceInfo+extension.h"
#import "A3DefaultColorDefines.h"

@interface A3UnitPriceHistoryViewController () <UIActionSheetDelegate>

@property (nonatomic, strong)	NSFetchedResultsController *fetchedResultsController;

@end

NSString *const A3UnitPriceHistoryCellID = @"cell3Row";

@implementation A3UnitPriceHistoryViewController {
	NSNumberFormatter *_historyNumberFormatter;
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
    
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear", @"Clear")
																			 style:UIBarButtonItemStylePlain
																			target:self
																			action:@selector(clearButtonAction:)];

	_historyNumberFormatter = [[NSNumberFormatter alloc] init];
    _historyNumberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;

	self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorColor = [self tableViewSeparatorColor];

    [self.tableView registerNib:[UINib nibWithNibName:@"A3UnitPriceHistoryCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:A3UnitPriceHistoryCellID];
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

	if (!parent) {
		[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationChildViewControllerDidDismiss object:self];
	}
}

- (void)dealloc {
	[self removeObserver];
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
	if (IS_IPAD) {
		[self.A3RootViewController dismissRightSideViewController];
	} else {
		[self dismissViewControllerAnimated:YES completion:nil];
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
        
        NSUInteger section = [self.tableView numberOfSections];
        for (int i=0; i<section; i++) {
            NSUInteger row = [self.tableView numberOfRowsInSection:i];
            for (int j=0; j<row; j++) {
                NSIndexPath *ip = [NSIndexPath indexPathForRow:j inSection:i];
                UnitPriceHistory *unitPriceHistory = [_fetchedResultsController objectAtIndexPath:ip];
				[UnitPriceInfo MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"historyID == %@", unitPriceHistory.uniqueID]];
                [unitPriceHistory MR_deleteEntity];
            }
        }
		[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
		_fetchedResultsController = nil;
		[self.tableView reloadData];
        
        if (_delegate && [_delegate respondsToSelector:@selector(didHistoryDeletedHistoryViewController:)]) {
            [_delegate didHistoryDeletedHistoryViewController:self];
        }
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSFetchedResultsController *)fetchedResultsController {
    
	if (!_fetchedResultsController) {
        _fetchedResultsController = [UnitPriceHistory MR_fetchAllSortedBy:@"updateDate" ascending:NO withPredicate:nil groupBy:nil delegate:nil];
		if (![_fetchedResultsController.fetchedObjects count]) {
			self.navigationItem.leftBarButtonItem = nil;
		}
	}
	return _fetchedResultsController;
}

- (void)deleteHistory:(UnitPriceHistory *)history
{
	[UnitPriceInfo MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"historyID == %@", history.uniqueID]];
    [history MR_deleteEntity];
	[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (double)calcuUnitPriceOfHistoryItem:(UnitPriceInfo *)item
{
    double unitPrice = 0;
    
    double priceValue = item.price.doubleValue;
    NSUInteger sizeValue = (item.size.integerValue <= 0) ? 1:item.size.integerValue;
    NSUInteger quantityValue = item.quantity.integerValue;
    
    // 할인값
    double discountValue = 0;
    if (!item.discountPercent && !item.discountPrice) {
        discountValue = 0;
    }
    else {
        if (item.discountPrice.doubleValue > 0) {
            discountValue = item.discountPrice.doubleValue;
            discountValue = MIN(discountValue, priceValue);
        }
        else if (item.discountPercent.floatValue > 0) {
            discountValue = priceValue * item.discountPercent.floatValue;
        }
    }
    
    if ((priceValue>0) && (sizeValue>0) && (quantityValue>0)) {
        unitPrice = (priceValue - discountValue) / (sizeValue * quantityValue);
    }
    else {
        unitPrice = 0;
    }
    
    return unitPrice;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UnitPriceHistory *unitPriceHistory = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    if (_delegate && [_delegate respondsToSelector:@selector(historyViewController:selectHistory:)]) {
        [_delegate historyViewController:self selectHistory:unitPriceHistory];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self doneButtonAction:nil];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UnitPriceHistory *unitPriceHistory = [_fetchedResultsController objectAtIndexPath:indexPath];
    
	A3UnitPriceHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:A3UnitPriceHistoryCellID forIndexPath:indexPath];
    
    // set font
    cell.unitPriceALabel.font = [UIFont systemFontOfSize:15.0];
    cell.unitPriceBLabel.font = [UIFont systemFontOfSize:15.0];
    cell.timeLabel.font = [UIFont systemFontOfSize:12.0];
    cell.timeLabel.textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0];

	UnitPriceInfo *unitPriceAItem, *unitPriceBItem;
	for (UnitPriceInfo *item in [unitPriceHistory unitPrices]) {
		if ([item.priceName isEqualToString:@"A"]) {
			unitPriceAItem = item;
		} else {
			unitPriceBItem = item;
		}
	}
	[_historyNumberFormatter setCurrencyCode:unitPriceHistory.currencyCode];

	double unitPriceA = [unitPriceAItem unitPrice];
    double unitPriceB = [unitPriceBItem unitPrice2WithPrice1:unitPriceAItem];

	UIColor *blackColor = [UIColor blackColor];
    UIColor *greenColor = A3DefaultColorHistoryPositiveText;

	cell.unitPriceALabel.textColor = unitPriceA < unitPriceB ? greenColor : blackColor;
	cell.unitPriceBLabel.textColor = unitPriceB < unitPriceA ? greenColor : blackColor;
	
    cell.unitPriceALabel.text = [unitPriceAItem unitPriceStringWithFormatter:_historyNumberFormatter showUnit:YES ];
    cell.unitPriceBLabel.text = [unitPriceBItem unitPrice2StringWithPrice1:unitPriceAItem formatter:_historyNumberFormatter showUnit:YES ];
    cell.timeLabel.text = [unitPriceHistory.updateDate timeAgo];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 62;
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
        
        UnitPriceHistory *history = [_fetchedResultsController objectAtIndexPath:indexPath];
        [self deleteHistory:history];
		_fetchedResultsController = nil;
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if (_delegate && [_delegate respondsToSelector:@selector(didHistoryDeletedHistoryViewController:)]) {
            [_delegate didHistoryDeletedHistoryViewController:self];
        }
    }
}


@end
