//
//  A3UnitConverterHistoryViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 13. 10. 16..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "UIViewController+NumberKeyboard.h"
#import "NSDate+TimeAgo.h"
#import "UIViewController+A3Addition.h"
#import "A3UnitDataManager.h"
#import "A3UnitConverterHistoryCell.h"
#import "A3UnitConverterHistory3RowCell.h"
#import "TemperatureConverter.h"
#import "A3UnitConverterHistoryViewController.h"
#import "UIViewController+iPad_rightSideView.h"
#import "UnitHistory+extension.h"
#import "A3AppDelegate.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"
#import "A3SyncManager.h"
#import "A3UIDevice.h"

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

    self.title = NSLocalizedString(@"History", @"History");

	if (IS_IPHONE) {
		[self rightBarButtonDoneButton];
	}
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear", @"Clear") style:UIBarButtonItemStylePlain target:self action:@selector(clearButtonAction:)];

	self.tableView.showsVerticalScrollIndicator = NO;
	self.tableView.separatorColor = [self tableViewSeparatorColor];
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}
	[self setupTableFooterView];

	[self.tableView registerClass:[A3UnitConverterHistory3RowCell class] forCellReuseIdentifier:A3UnitConverterHistory3RowCellID];
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

- (void)setupTableFooterView {
	UILabel *notice = [[UILabel alloc] init];
	notice.font = [UIFont systemFontOfSize:13];
	notice.textColor = [UIColor blackColor];
	notice.text = NSLocalizedString(@"Each history keeps max 4 units.", @"Each history keeps max 4 units.");
	notice.textAlignment = NSTextAlignmentCenter;

	CGRect frame = CGRectMake(0.0, 0.0, 320.0, 40.0);
	UIView *footerView = [[UIView alloc] initWithFrame:frame];
	footerView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];
	notice.frame = footerView.bounds;
	[footerView addSubview:notice];

	self.tableView.tableFooterView = footerView;
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
	if (IS_IPAD) {
		[[[A3AppDelegate instance] rootViewController_iPad] dismissRightSideViewController];
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
        
		[UnitHistory_ truncateAll];
        NSManagedObjectContext *context = CoreDataStack.shared.persistentContainer.viewContext;
        [context saveIfNeeded];
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
        _fetchedResultsController = [UnitHistory_ fetchAllSortedBy:@"updateDate" ascending:NO withPredicate:nil groupBy:nil delegate:nil];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UnitHistory_ *unitHistory = [_fetchedResultsController objectAtIndexPath:indexPath];
    
	A3UnitConverterHistory3RowCell *cell = [tableView dequeueReusableCellWithIdentifier:A3UnitConverterHistory3RowCellID forIndexPath:indexPath];
	if (!cell) {
		cell = [[A3UnitConverterHistory3RowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:A3UnitConverterHistory3RowCellID];
	}
    
	NSArray *items = [unitHistory targets];
    
    NSInteger numberOfLines = [items count] + 1;
	[cell setNumberOfLines:@(numberOfLines)];
    
    if ([unitHistory.categoryID isEqualToNumber:@(7)] && [unitHistory.unitID isEqualToNumber:@(31)]) {
        float value = [unitHistory.value floatValue];
        int feet = (int)value;
        float inch = (value - feet) * (0.3048/0.0254);
    
        ((UILabel *) cell.leftLabels[0]).text = [NSString stringWithFormat:@"%@ft %@in", [self.decimalFormatter stringFromNumber:@(feet)], [self.decimalFormatter stringFromNumber:@(inch)]];
    }
    else {
        ((UILabel *) cell.leftLabels[0]).text = [self.decimalFormatter stringFromNumber:unitHistory.value];
    }
	
    ((UILabel *) cell.rightLabels[0]).text = [unitHistory.updateDate timeAgo];
    
    ((UILabel *) cell.leftLabels[0]).font = [UIFont systemFontOfSize:15.0];
    ((UILabel *) cell.leftLabels[0]).textColor = [UIColor blackColor];
    ((UILabel *) cell.rightLabels[0]).font = [UIFont systemFontOfSize:12.0];
    ((UILabel *) cell.rightLabels[0]).textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0];
    
    /*
     float celsiusValue = [TemperatureConverter convertToCelsiusFromUnit:sourceUnit.item.unitName andTemperature:fromValue];
     float targetValue = [TemperatureConverter convertCelsius:celsiusValue toUnit:targetUnit.item.unitName];
     targetTextField.text = [self.decimalFormatter stringFromNumber:@(targetValue)];
     */
    
	for (NSUInteger index = 1; index < numberOfLines; index++) {
		UnitHistoryItem_ *item = items[index - 1];
        
        ((UILabel *) cell.leftLabels[index]).font = [UIFont systemFontOfSize:13.0];
        ((UILabel *) cell.leftLabels[index]).textColor = [UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0];
        ((UILabel *) cell.rightLabels[index]).font = [UIFont systemFontOfSize:13.0];
        ((UILabel *) cell.rightLabels[index]).textColor = [UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0];

		NSString *sourceUnitName = [_dataManager unitNameForUnitID:[unitHistory.unitID unsignedIntegerValue] categoryID:[unitHistory.categoryID unsignedIntegerValue] ];
		NSString *targetUnitName = [_dataManager unitNameForUnitID:[item.targetUnitItemID unsignedIntegerValue] categoryID:[unitHistory.categoryID unsignedIntegerValue] ];

        NSUInteger categoryID = [unitHistory.categoryID unsignedIntegerValue];
        NSUInteger sourceID = [unitHistory.unitID unsignedIntegerValue];
        NSUInteger targetID = [item.targetUnitItemID unsignedIntegerValue];
		float rate = (float) (conversionTable[categoryID][sourceID] / conversionTable[categoryID][targetID]);

        BOOL _isTemperatureMode = [unitHistory.categoryID isEqualToNumber:@(13)];

		if (_isTemperatureMode) {
            float celsiusValue = [TemperatureConverter convertToCelsiusFromUnit:sourceUnitName andTemperature:unitHistory.value.floatValue];
            float targetValue = [TemperatureConverter convertCelsius:celsiusValue toUnit:targetUnitName];
            ((UILabel *) cell.leftLabels[index]).text = [self.decimalFormatter stringFromNumber:@(targetValue)];
			((UILabel *) cell.rightLabels[index]).text = [NSString stringWithFormat:NSLocalizedString(@"%@ to %@", nil),
														  NSLocalizedStringFromTable(sourceUnitName, @"unitShort", nil),
														  NSLocalizedStringFromTable(targetUnitName, @"unitShort", nil)];
			FNLOG(@"%@, %@", sourceUnitName, NSLocalizedStringFromTable(sourceUnitName, @"unitShort", nil));
			FNLOG(@"%@, %@", targetUnitName, NSLocalizedStringFromTable(targetUnitName, @"unitShort", nil));
        }
        else if (categoryID == 8) {
            float targetValue = [self getFuelValue:sourceID value:unitHistory.value.floatValue];
            switch (targetID) {
                case 0:
                case 1:
                case 3:
                case 4:
                    targetValue = targetValue / conversionTable[categoryID][targetID];
                    break;
                case 2:
                case 5:
                case 6:
                    targetValue = conversionTable[categoryID][targetID] / targetValue;
                    break;
            }
            ((UILabel *) cell.leftLabels[index]).text = [self.decimalFormatter stringFromNumber:@(targetValue)];
            ((UILabel *) cell.rightLabels[index]).text = [NSString stringWithFormat:NSLocalizedString(@"%@ to %@", nil),
                                                                                    NSLocalizedStringFromTable(sourceUnitName, @"unitShort", nil),
                                                                                    NSLocalizedStringFromTable(targetUnitName, @"unitShort", nil)];
        }
        else
        {
            if ([unitHistory.categoryID isEqualToNumber:@9] && [item.targetUnitItemID isEqualToNumber:@31]) {
                float value = unitHistory.value.floatValue * rate;
                int feet = (int)value;
                float inch = (value - feet) * (0.3048/0.0254);

                ((UILabel *) cell.leftLabels[index]).text = [NSString stringWithFormat:@"%@ft %@in", [self.decimalFormatter stringFromNumber:@(feet)], [self.decimalFormatter stringFromNumber:@(inch)]];
            }
            else {
                ((UILabel *) cell.leftLabels[index]).text = [self.decimalFormatter stringFromNumber:@(unitHistory.value.floatValue * rate)];
            }
            // a to b = 40.469 표시 (right label)
            if (_isTemperatureMode) {
                ((UILabel *) cell.rightLabels[index]).text = [NSString stringWithFormat:NSLocalizedString(@"%@ to %@", @"%@ to %@"),
                                                                                        NSLocalizedStringFromTable(sourceUnitName, @"unitShort", nil),
                                                                                        [TemperatureConverter rateStringFromTemperUnit:sourceUnitName toTemperUnit:targetUnitName]];
            }
            else {
                ((UILabel *) cell.rightLabels[index]).text = [NSString stringWithFormat:NSLocalizedString(@"%@ to %@ = %@", @"%@ to %@ = %@"),
                                                                                        NSLocalizedStringFromTable(sourceUnitName, @"unitShort", nil),
                                                                                        NSLocalizedStringFromTable(targetUnitName, @"unitShort", nil),
                                                                                        [self.decimalFormatter stringFromNumber:@(rate)]];
            }
        }
	}
    
    return cell;
}

- (float)getFuelValue:(NSUInteger)type value:(float)value{
    double result = 0.0;
    switch (type) {
        case 0:
        case 1:
        case 3:
        case 4:
            result = conversionTable[8][type] * value;
            break;
        case 2:
        case 5:
        case 6:
            result = conversionTable[8][type] / value;
            break;
    }
    return result;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	UnitHistory_ *history = [self.fetchedResultsController objectAtIndexPath:indexPath];
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
        
        NSManagedObjectContext *context = CoreDataStack.shared.persistentContainer.viewContext;
        UnitHistory_ *history = [_fetchedResultsController objectAtIndexPath:indexPath];
        [context deleteObject:history];
        [context saveIfNeeded];
		_fetchedResultsController = nil;
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
