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
#import "UnitItem.h"
#import "UnitPriceHistoryItem.h"
#import "A3UnitPriceHistoryCell.h"
#import "UIViewController+navigation.h"

@interface A3UnitPriceHistoryViewController () <UIActionSheetDelegate>

@property (nonatomic, strong)	NSFetchedResultsController *fetchedResultsController;

@end

NSString *const A3UnitPriceHistoryCellID = @"cell3Row";

@implementation A3UnitPriceHistoryViewController

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
    
	if (IS_IPHONE) {
		[self rightBarButtonDoneButton];
	}
    
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(clearButtonAction:)];
    
	self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorColor = [self tableViewSeparatorColor];
    
    /*
	UILabel *notice = [[UILabel alloc] init];
	notice.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
	notice.textColor = [UIColor blackColor];
	notice.text = @"Each history keeps max 4 units.";
	notice.textAlignment = NSTextAlignmentCenter;
    
	CGRect frame = CGRectMake(0.0, 0.0, 320.0, 40.0);
	UIView *footerView = [[UIView alloc] initWithFrame:frame];
    footerView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];
	notice.frame = footerView.bounds;
	[footerView addSubview:notice];
    
	self.tableView.tableFooterView = footerView;
     */
    
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

	FNLOG(@"%@", parent);
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
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:@"Clear History"
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
                [unitPriceHistory MR_deleteEntity];
            }
        }
		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
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
        _fetchedResultsController = [UnitPriceHistory MR_fetchAllSortedBy:@"date" ascending:NO withPredicate:nil groupBy:nil delegate:nil];
		if (![_fetchedResultsController.fetchedObjects count]) {
			self.navigationItem.leftBarButtonItem = nil;
		}
	}
	return _fetchedResultsController;
}

- (void)deleteHistory:(UnitPriceHistory *)history
{
    [history MR_deleteEntity];
	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
}

- (double)calcuUnitPriceOfHistoryItem:(UnitPriceHistoryItem *)item
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
    cell.unitPriceALabel.textColor = [UIColor blackColor];
    cell.unitPriceBLabel.textColor = [UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:100.0/255.0 alpha:1.0];
    cell.timeLabel.font = [UIFont systemFontOfSize:12.0];
    cell.timeLabel.textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0];

	UnitPriceHistoryItem *unitPriceAItem, *unitPriceBItem;
	for (UnitPriceHistoryItem *item in unitPriceHistory.unitPrices) {
		if ([item.orderInComparison isEqualToString:@"A"]) {
			unitPriceAItem = item;
		} else {
			unitPriceBItem = item;
		}
	}
    double unitPriceA = [self calcuUnitPriceOfHistoryItem:unitPriceAItem];
    double unitPriceB = [self calcuUnitPriceOfHistoryItem:unitPriceBItem];
    
    NSString *unitPrice1Txt, *unitPrice2Txt;
    if (unitPriceAItem.unit) {
        unitPrice1Txt = [NSString stringWithFormat:@"%@/%@", [self.currencyFormatter stringFromNumber:@(unitPriceA)], unitPriceAItem.unit.unitShortName];
    }
    else {
        unitPrice1Txt = [self.currencyFormatter stringFromNumber:@(unitPriceA)];
    }
    
    if (unitPriceBItem.unit) {
        unitPrice2Txt = [NSString stringWithFormat:@"%@/%@", [self.currencyFormatter stringFromNumber:@(unitPriceB)], unitPriceBItem.unit.unitShortName];
    }
    else {
        unitPrice2Txt = [self.currencyFormatter stringFromNumber:@(unitPriceB)];
    }

    // A,B값이 같으면, A만 보인다.
    if ((unitPriceAItem.unit == nil && unitPriceBItem.unit == nil) && (unitPriceA == unitPriceB)) {
        cell.historyBView.hidden = YES;
    }
    else if ((unitPriceAItem.unit && unitPriceBItem.unit) && ([unitPriceAItem.unit.unitName isEqualToString:unitPriceBItem.unit.unitName]) && (unitPriceA == unitPriceB)) {
        cell.historyBView.hidden = YES;
    }
    else {
        cell.historyBView.hidden = NO;
    }
    
    cell.unitPriceALabel.text = unitPrice1Txt;
    cell.unitPriceBLabel.text = unitPrice2Txt;
    cell.timeLabel.text = [unitPriceHistory.date timeAgo];
    
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

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

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

@end
