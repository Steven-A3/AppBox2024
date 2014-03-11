//
//  A3UnitConverterHistoryViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 13. 10. 16..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "UIViewController+A3AppCategory.h"
#import "NSDate+TimeAgo.h"
#import "UIViewController+A3Addition.h"
#import "UnitHistory.h"
#import "UnitHistoryItem.h"
#import "UnitItem.h"
#import "UnitType.h"
#import "UnitConvertItem.h"
#import "A3UnitConverterHistoryCell.h"
#import "A3UnitConverterHistory3RowCell.h"
#import "TemperatureConveter.h"
#import "A3UnitConverterHistoryViewController.h"

@interface A3UnitConverterHistoryViewController () <UIActionSheetDelegate>
{
    
}

@property (nonatomic, strong)	NSFetchedResultsController *fetchedResultsController;

@end

NSString *const A3UnitConverterHistory3RowCellID = @"cell3Row";

@implementation A3UnitConverterHistoryViewController

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = @"History";
    
	[self rightBarButtonDoneButton];
    
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(clearButtonAction:)];
    
	self.tableView.showsVerticalScrollIndicator = NO;
    
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
    
    [self.tableView registerClass:[A3UnitConverterHistory3RowCell class] forCellReuseIdentifier:A3UnitConverterHistory3RowCellID];
	[self registerContentSizeCategoryDidChangeNotification];
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

- (void)dealloc {
	[self removeObserver];
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
                UnitHistory *unitHistory = [_fetchedResultsController objectAtIndexPath:ip];
                [self deleteHistory:unitHistory];
            }
        }
		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
		_fetchedResultsController = nil;
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
        _fetchedResultsController = [UnitHistory MR_fetchAllSortedBy:@"date" ascending:NO withPredicate:nil groupBy:nil delegate:nil];
		if (![_fetchedResultsController.fetchedObjects count]) {
			self.navigationItem.leftBarButtonItem = nil;
		}
	}
	return _fetchedResultsController;
}

- (void)deleteHistory:(UnitHistory *)history
{
    [history.targets enumerateObjectsUsingBlock:^(UnitHistoryItem *obj, BOOL *stop) {
        [obj MR_deleteEntity];
    }];
    history.targets = nil;
    [history MR_deleteEntity];
}

- (NSMutableArray *)unitConverterItemsOfUnitType:(UnitType *)unitType
{
    return [NSMutableArray arrayWithArray:[UnitConvertItem MR_findAllSortedBy:@"order" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"item.type==%@", unitType]]];
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
    UnitHistory *unitHistory = [_fetchedResultsController objectAtIndexPath:indexPath];
    
	A3UnitConverterHistory3RowCell *cell = [tableView dequeueReusableCellWithIdentifier:A3UnitConverterHistory3RowCellID forIndexPath:indexPath];
	if (!cell) {
		cell = [[A3UnitConverterHistory3RowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:A3UnitConverterHistory3RowCellID];
	}
    
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
	NSArray *itemsTemp = [unitHistory.targets sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    // 현재 unitType 에 존재하는  unitConverterItem 들만 보이도록 다시 sort 한다.
    NSMutableArray *unitConverterItems = [self unitConverterItemsOfUnitType:unitHistory.source.type];
    NSMutableArray *items = [[NSMutableArray alloc] initWithArray:itemsTemp];
    NSMutableArray *toDeleteItems = [NSMutableArray new];
    for (UnitHistoryItem *historyItem in items) {
        for (int i=0; i<unitConverterItems.count; i++) {
            UnitConvertItem *converterItem  = unitConverterItems[i];
            if ([converterItem.item.unitName isEqualToString:historyItem.unit.unitName]) {
                break;
            }
            if (i == unitConverterItems.count-1) {
                // 현재의 unitConverterItem에는 없는 unitHistoryItem이므로 보여주지 않도록 리스트에서 삭제
                [toDeleteItems addObject:historyItem];
            }
        }
    }
    if (toDeleteItems.count > 0) {
        [items removeObjectsInArray:toDeleteItems];
    }

//	NSInteger numberOfLines = [unitHistory.targets count] + 1;
    NSInteger numberOfLines = [items count] + 1;
	[cell setNumberOfLines:@(numberOfLines)];
    
	((UILabel *) cell.leftLabels[0]).text = [self.decimalFormatter stringFromNumber:unitHistory.value];
    ((UILabel *) cell.rightLabels[0]).text = [unitHistory.date timeAgo];
    
    ((UILabel *) cell.leftLabels[0]).font = [UIFont systemFontOfSize:15.0];
    ((UILabel *) cell.leftLabels[0]).textColor = [UIColor blackColor];
    ((UILabel *) cell.rightLabels[0]).font = [UIFont systemFontOfSize:12.0];
    ((UILabel *) cell.rightLabels[0]).textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0];
    
    /*
     float celsiusValue = [TemperatureConveter convertToCelsiusFromUnit:sourceUnit.item.unitName andTemperature:fromValue];
     float targetValue = [TemperatureConveter convertCelsius:celsiusValue toUnit:targetUnit.item.unitName];
     targetTextField.text = [self.decimalFormatter stringFromNumber:@(targetValue)];
     */
    
	for (NSUInteger index = 1; index < numberOfLines; index++) {
		UnitHistoryItem *item = items[index - 1];
        
        ((UILabel *) cell.leftLabels[index]).font = [UIFont systemFontOfSize:13.0];
        ((UILabel *) cell.leftLabels[index]).textColor = [UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0];
        ((UILabel *) cell.rightLabels[index]).font = [UIFont systemFontOfSize:13.0];
        ((UILabel *) cell.rightLabels[index]).textColor = [UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0];
        
        float rate = unitHistory.source.conversionRate.floatValue / item.unit.conversionRate.floatValue;
        
        BOOL _isTemperatureMode = [unitHistory.source.type.unitTypeName isEqualToString:@"Temperature"];
        
        if (_isTemperatureMode) {
            float celsiusValue = [TemperatureConveter convertToCelsiusFromUnit:unitHistory.source.unitName andTemperature:unitHistory.value.floatValue];
            float targetValue = [TemperatureConveter convertCelsius:celsiusValue toUnit:item.unit.unitName];
            ((UILabel *) cell.leftLabels[index]).text = [self.decimalFormatter stringFromNumber:@(targetValue)];
        }
        else {
            ((UILabel *) cell.leftLabels[index]).text = [self.decimalFormatter stringFromNumber:@(unitHistory.value.floatValue * rate)];
        }
        
        // a to b = 40.469 표시 (right label)
        if (_isTemperatureMode) {
            ((UILabel *) cell.rightLabels[index]).text = [NSString stringWithFormat:@"%@ to %@", unitHistory.source.unitShortName, [TemperatureConveter rateStringFromTemperUnit:unitHistory.source.unitName toTemperUnit:item.unit.unitName]];
        }
        else {
            float convesionRate = unitHistory.source.conversionRate.floatValue / item.unit.conversionRate.floatValue;
            ((UILabel *) cell.rightLabels[index]).text = [NSString stringWithFormat:@"%@ to %@ = %@", unitHistory.source.unitShortName, item.unit.unitShortName, [self.decimalFormatter stringFromNumber:@(convesionRate)]];
        }
	}
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	UnitHistory *history = [self.fetchedResultsController objectAtIndexPath:indexPath];
	return 50.0 + [history.targets count] * 14.0;
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
        
        UnitHistory *history = [_fetchedResultsController objectAtIndexPath:indexPath];
        [self deleteHistory:history];
		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
		_fetchedResultsController = nil;
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
