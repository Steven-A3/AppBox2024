//
//  A3LadyCalendarListViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LadyCalendarListViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3LadyCalendarAddPeriodViewController.h"
#import "A3LadyCalendarDetailViewController.h"
#import "A3LadyCalendarDefine.h"
#import "A3LadyCalendarModelManager.h"
#import "LadyCalendarPeriod.h"
#import "A3DateHelper.h"
#import "A3ColoredCircleView.h"
#import "NSDateFormatter+A3Addition.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"
#import "A3AppDelegate.h"
#import "A3SyncManager.h"

@interface A3LadyCalendarListViewController ()

@property (strong, nonatomic) NSMutableArray *itemArray;
@property (strong, nonatomic) NSArray *sourceArray;
@property (strong, nonatomic) NSArray *predictArray;
@property (strong, nonatomic) NSArray *fullArray;

@end

@implementation A3LadyCalendarListViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.title = NSLocalizedString(@"Periods", @"Periods");
	[self rightBarButtonDoneButton];
	[self makeBackButtonEmptyArrow];
	self.tableView.separatorInset = A3UITableViewSeparatorInset;
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setToolbarHidden:YES];
	self.sourceArray = [_dataManager periodListSortedByStartDateIsAscending:YES];
	self.predictArray = [_dataManager predictPeriodListSortedByStartDateIsAscending:YES];
	self.fullArray = [_sourceArray arrayByAddingObjectsFromArray:_predictArray];
	[self groupingPeriodByYearInArray:_fullArray];
	[self.tableView reloadData];

    if (self.isMovingToParentViewController) {
        // 최신 날짜가 보이도록 하단으로 스크롤.
        NSDictionary *dict = [_itemArray lastObject];
        NSArray *items = [dict objectForKey:ItemKey_Items];
        if (dict && [items count] > 0) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:items.count-1 inSection:_itemArray.count-1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
    
	[self setupAddButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if ([self.navigationController.navigationBar isHidden]) {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)groupingPeriodByYearInArray:(NSArray*)array
{
    NSMutableArray *groupedArray = [NSMutableArray array];
    NSMutableDictionary *groupInfo = [NSMutableDictionary dictionary];
    for (LadyCalendarPeriod *item in array) {
		NSDateComponents *components = [[[A3AppDelegate instance] calendar] components:NSCalendarUnitYear fromDate:item.startDate];
        NSInteger year = components.year;
        NSString *key = [NSString stringWithFormat:@"%ld", (long)year];
        NSMutableArray *items = [groupInfo objectForKey:key];
        if ( items == nil ) {
            items = [NSMutableArray array];
            [groupInfo setObject:items forKey:key];
            [groupedArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:items,ItemKey_Items,@(year),ItemKey_Type, nil]];
        }
        [items addObject:item];
    }
    
    self.itemArray = groupedArray;
}

- (LadyCalendarPeriod *)previousPeriodFromIndexPath:(NSIndexPath*)indexPath
{
    if ( indexPath.section == 0 && indexPath.row == 0 )
        return nil;
    
    NSInteger prevSection = ( indexPath.row == 0 ? indexPath.section-1 : indexPath.section );
    NSArray *items = [[_itemArray objectAtIndex:prevSection] objectForKey:ItemKey_Items];
    NSInteger prevRow = ( indexPath.row == 0 ? [items count] -1 : indexPath.row-1);
    
    return [items objectAtIndex:prevRow];
}

- (LadyCalendarPeriod *)nextPeriodFromIndexPath:(NSIndexPath*)indexPath
{
    NSArray *items = [[_itemArray objectAtIndex:indexPath.section] objectForKey:ItemKey_Items];
    if ( (indexPath.section+1 >= [_itemArray count]) && (indexPath.row+1 >= [items count]) )
        return nil;
    
    LadyCalendarPeriod *periodItem = nil;
    if ( (indexPath.row+1) >= [items count] ) {
        NSInteger nextSection = indexPath.section+1;
        periodItem = [[[_itemArray objectAtIndex:nextSection] objectForKey:ItemKey_Items] objectAtIndex:0];
    }
    else{
        periodItem = [items objectAtIndex:indexPath.row+1];
    }
    
    return periodItem;
}

- (NSMutableArray*)sameMonthItemFromIndexPath:(NSIndexPath*)indexPath
{
    NSArray *items = [[_itemArray objectAtIndex:indexPath.section] objectForKey:ItemKey_Items];
    LadyCalendarPeriod *prevItem = [self previousPeriodFromIndexPath:indexPath];
    LadyCalendarPeriod *item = [items objectAtIndex:indexPath.row];
    LadyCalendarPeriod *nextItem = [self nextPeriodFromIndexPath:indexPath];
    
    NSString *itemYearDate = [A3DateHelper dateStringFromDate:item.startDate withFormat:@"yyyyMM"];
    NSString *prevYearDate = ( prevItem ? [A3DateHelper dateStringFromDate:prevItem.startDate withFormat:@"yyyyMM"] : nil );
    NSString *nextYearDate = ( nextItem ? [A3DateHelper dateStringFromDate:nextItem.startDate withFormat:@"yyyyMM"] : nil );
    
    NSMutableArray *array = [NSMutableArray array];
    if ( [prevYearDate isEqualToString:itemYearDate] )
        [array addObject:prevItem];
    [array addObject:item];
    if ( [nextYearDate isEqualToString:itemYearDate] )
        [array addObject:nextItem];
    
    return array;
}

- (void)setupAddButton
{
	if ( ![_addButton isDescendantOfView:self.view] ) {
		[self.view addSubview:_addButton];
		[_addButton makeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(self.view.centerX);
			make.bottom.equalTo(self.view.bottom).with.offset(-10);
			make.width.equalTo(@44);
			make.height.equalTo(@44);
		}];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_itemArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *dict = [_itemArray objectAtIndex:section];
    NSArray *items = [dict objectForKey:ItemKey_Items];
    
    NSInteger dummyCounter = 0;
    if ( section == [_itemArray count]-1 ) {
        CGFloat totalHeight = 0.0;
        for (NSInteger i=0; i < [_itemArray count]; i++) {
            totalHeight += 23.0;
            totalHeight += (44.0 * [[[_itemArray objectAtIndex:i] objectForKey:ItemKey_Items] count]);
        }
        dummyCounter = ( totalHeight >= tableView.frame.size.height ? 0 : (tableView.frame.size.height - totalHeight)/44.0);
    }
    
    return [items count] + dummyCounter;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 23.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"A3LadyCalendarListCell" owner:nil options:nil] objectAtIndex:2];
    UILabel *textLabel = (UILabel*)[headerView viewWithTag:10];
    NSDictionary *dict = [_itemArray objectAtIndex:section];
    textLabel.text = [NSString stringWithFormat:@"%ld", (long)[[dict objectForKey:ItemKey_Type] integerValue]];
    for (NSLayoutConstraint *layout in headerView.constraints) {
        if ( layout.firstAttribute == NSLayoutAttributeLeading && layout.firstItem == textLabel )
            layout.constant = IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28.0;
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"calendarListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *cellArray = [[NSBundle mainBundle] loadNibNamed:@"A3LadyCalendarListCell" owner:nil options:nil];
        cell = [cellArray objectAtIndex:0];
        UIView *leftView = [cell viewWithTag:12];
        for (NSLayoutConstraint *layout in cell.contentView.constraints) {
            if ( layout.firstAttribute == NSLayoutAttributeLeading && layout.firstItem == leftView )
                layout.constant = IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28.0;
        }
    }
    
    NSArray *items = [[_itemArray objectAtIndex:indexPath.section] objectForKey:ItemKey_Items];
    LadyCalendarPeriod *item = (indexPath.row >= [items count] ? nil : [items objectAtIndex:indexPath.row]);

    UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
    UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:11];
    A3ColoredCircleView *circleView = (A3ColoredCircleView*)[cell viewWithTag:12];

    if ( item ) {
        FNLOG(@"%s %ld/%ld %@",__FUNCTION__, (long)indexPath.section, (long)indexPath.row,item);
        circleView.hidden = NO;
        
        if (IS_IPHONE) {
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            NSString *dateFormat = [dateFormatter customFullStyleFormat];
            dateFormat = [dateFormatter formatStringByRemovingYearComponent:dateFormat];
            [dateFormatter setDateFormat:dateFormat];
            textLabel.text = [dateFormatter stringFromDate:item.startDate];
        }
        else {
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            dateFormatter.dateStyle = NSDateFormatterFullStyle;
            NSString *dateFormat = [dateFormatter dateFormat];
            dateFormat = [dateFormatter formatStringByRemovingYearComponent:dateFormat];
            [dateFormatter setDateFormat:dateFormat];
            textLabel.text = [NSString stringWithFormat:@"%@ - %@", [dateFormatter stringFromDate:item.startDate], [dateFormatter stringFromDate:item.endDate]];
        }
        
        LadyCalendarPeriod *prevPeriod = [self previousPeriodFromIndexPath:indexPath];
        NSInteger cycleLength = 0;
        
        if ( prevPeriod ) {
            cycleLength = [A3DateHelper diffDaysFromDate:item.startDate toDate:prevPeriod.startDate];
        }
        else{
            cycleLength = [item.cycleLength integerValue];
        }
        cycleLength = labs(cycleLength);
        
        detailTextLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"During %ld days", @"StringsDict", nil), (long)cycleLength];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else{
        circleView.hidden = YES;
        textLabel.text = @"";
        detailTextLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *items = [[_itemArray objectAtIndex:indexPath.section] objectForKey:ItemKey_Items];
    LadyCalendarPeriod *item = (indexPath.row >= [items count] ? nil : [items objectAtIndex:indexPath.row]);
    if ( item ) {
        A3ColoredCircleView *circleView = (A3ColoredCircleView*)[cell viewWithTag:12];
        if ( [item.isPredict boolValue] )
            circleView.centerCircleColor = [UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:100.0/255.0 alpha:1.0];
        else
            circleView.centerCircleColor = [UIColor colorWithRed:1.0 green:45.0/255.0 blue:85.0/255.0 alpha:1.0];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    else{
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( editingStyle == UITableViewCellEditingStyleDelete ) {
        NSArray *items = [[_itemArray objectAtIndex:indexPath.section] objectForKey:ItemKey_Items];
        LadyCalendarPeriod *period = (indexPath.row >= [items count] ? nil : [items objectAtIndex:indexPath.row]);
        
        NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
        if (period) {
            [context deleteObject:period];
            [context saveContext];

			double delayInSeconds = 0.1;
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
				[self.dataManager recalculateDates];

				self.sourceArray = [self.dataManager periodListSortedByStartDateIsAscending:YES ];
				self.predictArray = [self.dataManager predictPeriodListSortedByStartDateIsAscending:YES ];
				self.fullArray = [self.sourceArray arrayByAddingObjectsFromArray:self.predictArray];
				[self groupingPeriodByYearInArray:self.fullArray];

				[self.tableView reloadData];
			});
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (![_itemArray count]) return NO;
    NSArray *items = [[_itemArray objectAtIndex:indexPath.section] objectForKey:ItemKey_Items];
    LadyCalendarPeriod *item = (indexPath.row >= [items count] ? nil : [items objectAtIndex:indexPath.row]);
    
    return ( item ? ![item.isPredict boolValue] : NO);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *items = [[_itemArray objectAtIndex:indexPath.section] objectForKey:ItemKey_Items];
    LadyCalendarPeriod *item = (indexPath.row >= [items count] ? nil : [items objectAtIndex:indexPath.row]);
    
    if ( item == nil )
        return;
    
    NSString *monthStr = [A3DateHelper dateStringFromDate:item.startDate withFormat:@"MMMM"];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:monthStr style:UIBarButtonItemStylePlain target:nil action:nil];
    A3LadyCalendarDetailViewController *viewCtrl = [[A3LadyCalendarDetailViewController alloc] init];
    viewCtrl.month = item.startDate;
    viewCtrl.periodItems = [self sameMonthItemFromIndexPath:indexPath];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:monthStr
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

#pragma mark - action method
- (IBAction)addPeriodAction:(id)sender
{
    A3LadyCalendarAddPeriodViewController *viewCtrl = [[A3LadyCalendarAddPeriodViewController alloc] init];
	viewCtrl.dataManager = _dataManager;
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
    navCtrl.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navCtrl animated:YES completion:nil];
}

- (void)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneButtonAction:(UIBarButtonItem *)button
{
    [self.tableView setEditing:NO];
    [self cancelAction:nil];
}

@end
