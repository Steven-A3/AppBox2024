//
//  A3LadyCalendarListViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LadyCalendarListViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "A3LadyCalendarAddPeriodViewController.h"
#import "A3LadyCalendarDetailViewController.h"
#import "A3LadyCalendarDefine.h"
#import "A3LadyCalendarModelManager.h"
#import "LadyCalendarAccount.h"
#import "LadyCalendarPeriod.h"
#import "A3DateHelper.h"
#import "A3ColoredCircleView.h"

@interface A3LadyCalendarListViewController ()

@property (strong, nonatomic) NSMutableArray *itemArray;
@property (strong, nonatomic) NSMutableDictionary *groupDict;
@property (strong, nonatomic) NSArray *sourceArray;
@property (strong, nonatomic) NSArray *predictArray;
@property (strong, nonatomic) NSArray *fullArray;
@property (strong, nonatomic) LadyCalendarAccount *currentAccount;

- (void)groupingPeriodByYearInArray:(NSArray*)array;
- (LadyCalendarPeriod *)previousPeriodFromIndexPath:(NSIndexPath*)indexPath;
- (LadyCalendarPeriod *)nextPeriodFromIndexPath:(NSIndexPath*)indexPath;
- (NSMutableArray*)sameMonthItemFromIndexPath:(NSIndexPath*)indexPath;
@end;

@implementation A3LadyCalendarListViewController

- (void)groupingPeriodByYearInArray:(NSArray*)array
{
    NSMutableArray *groupedArray = [NSMutableArray array];
    NSMutableDictionary *groupInfo = [NSMutableDictionary dictionary];
    for(LadyCalendarPeriod *item in array){
        NSInteger year = [A3DateHelper yearFromDate:item.startDate];
        NSString *key = [NSString stringWithFormat:@"%ld", (long)year];
        NSMutableArray *items = [groupInfo objectForKey:key];
        if( items == nil ){
            items = [NSMutableArray array];
            [groupInfo setObject:items forKey:key];
            [groupedArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:items,ItemKey_Items,@(year),ItemKey_Type, nil]];
        }
        [items addObject:item];
    }
    
    self.itemArray = groupedArray;
    self.groupDict = groupInfo;
}

- (LadyCalendarPeriod *)previousPeriodFromIndexPath:(NSIndexPath*)indexPath
{
    if( indexPath.section == 0 && indexPath.row == 0 )
        return nil;
    
    NSInteger prevSection = ( indexPath.row == 0 ? indexPath.section-1 : indexPath.section );
    NSArray *items = [[_itemArray objectAtIndex:prevSection] objectForKey:ItemKey_Items];
    NSInteger prevRow = ( indexPath.row == 0 ? [items count] -1 : indexPath.row-1);
    
    return [items objectAtIndex:prevRow];
}

- (LadyCalendarPeriod *)nextPeriodFromIndexPath:(NSIndexPath*)indexPath
{
    NSArray *items = [[_itemArray objectAtIndex:indexPath.section] objectForKey:ItemKey_Items];
    if( (indexPath.section+1 >= [_itemArray count]) && (indexPath.row+1 >= [items count]) )
        return nil;
    
    LadyCalendarPeriod *periodItem = nil;
    if( (indexPath.row+1) >= [items count] ){
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
    if( [prevYearDate isEqualToString:itemYearDate] )
        [array addObject:prevItem];
    [array addObject:item];
    if( [nextYearDate isEqualToString:itemYearDate] )
        [array addObject:nextItem];
    
    return array;
}

- (void)updateAddButton
{
    _addButton.frame = CGRectMake(self.view.frame.size.width*0.5 - _addButton.frame.size.width*0.5, self.view.frame.size.height - 20.0 - _addButton.frame.size.height, _addButton.frame.size.width, _addButton.frame.size.height);
    if( ![_addButton isDescendantOfView:self.view] ){
        [self.view addSubview:_addButton];
    }
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Periods";
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add03"] style:UIBarButtonItemStyleBordered target:self action:@selector(addPeriodAction:)];
    [self rightBarButtonDoneButton];
    [self makeBackButtonEmptyArrow];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, (IS_IPHONE ? 15.0 : 28.0), 0, 0);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES];
    self.currentAccount = [_dataManager currentAccount];
    self.sourceArray = [_dataManager periodListSortedByStartDateIsAscending:YES accountID:self.currentAccount.uniqueID];
    self.predictArray = [_dataManager predictPeriodListSortedByStartDateIsAscending:YES accountID:self.currentAccount.uniqueID];
    self.fullArray = [_sourceArray arrayByAddingObjectsFromArray:_predictArray];
    [self groupingPeriodByYearInArray:_fullArray];
    [self.tableView reloadData];
    
    [self updateAddButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateAddButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    _addButton.hidden = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self updateAddButton];
    _addButton.hidden = NO;
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
    if( section == [_itemArray count]-1 ){
        CGFloat totalHeight = 0.0;
        for(NSInteger i=0; i < [_itemArray count]; i++){
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

//- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    NSDictionary *dict = [_itemArray objectAtIndex:section];
//    return [NSString stringWithFormat:@"%d",[[dict objectForKey:ItemKey_Type] integerValue]];
//}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"A3LadyCalendarListCell" owner:nil options:nil] objectAtIndex:2];
    UILabel *textLabel = (UILabel*)[headerView viewWithTag:10];
    NSDictionary *dict = [_itemArray objectAtIndex:section];
    textLabel.text = [NSString stringWithFormat:@"%ld", (long)[[dict objectForKey:ItemKey_Type] integerValue]];
    for(NSLayoutConstraint *layout in headerView.constraints){
        if( layout.firstAttribute == NSLayoutAttributeLeading && layout.firstItem == textLabel )
            layout.constant = (IS_IPHONE ? 15.0 : 28.0);
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
//    if( (section+1) >= [_itemArray count] )
//        return 23.0;
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
        for(NSLayoutConstraint *layout in cell.contentView.constraints){
            if( layout.firstAttribute == NSLayoutAttributeLeading && layout.firstItem == leftView )
                layout.constant = (IS_IPHONE ? 15.0 : 28.0);
        }
    }
    
    NSArray *items = [[_itemArray objectAtIndex:indexPath.section] objectForKey:ItemKey_Items];
    LadyCalendarPeriod *item = (indexPath.row >= [items count] ? nil : [items objectAtIndex:indexPath.row]);

    UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
    UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:11];
    A3ColoredCircleView *circleView = (A3ColoredCircleView*)[cell viewWithTag:12];

    if( item ){
        NSLog(@"%s %ld/%ld %@",__FUNCTION__, (long)indexPath.section, (long)indexPath.row,item);
        circleView.hidden = NO;
        textLabel.text = (IS_IPHONE ? [_dataManager dateStringExceptYearForDate:item.startDate] : [NSString stringWithFormat:@"%@ - %@",[_dataManager dateStringExceptYearForDate:item.startDate],[_dataManager dateStringExceptYearForDate:item.endDate]]);
//        LadyCalendarPeriod *prevPeriod = [self previousPeriodFromIndexPath:indexPath];
        LadyCalendarPeriod *nextPeriod = [self nextPeriodFromIndexPath:indexPath];
//        BOOL isRealLast = ( (![item.isPredict boolValue] && nextPeriod == nil) || (nextPeriod && [nextPeriod.isPredict boolValue]) );
        NSInteger cycleLength = 0;
        
        if( nextPeriod ){
            cycleLength = [A3DateHelper diffDaysFromDate:item.startDate toDate:nextPeriod.startDate];
        }
        else{
            cycleLength = [item.cycleLength integerValue];
        }
        detailTextLabel.text = [NSString stringWithFormat:@"During %ld days", (long)cycleLength];
        
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
    if( item ){
        A3ColoredCircleView *circleView = (A3ColoredCircleView*)[cell viewWithTag:12];
        if( [item.isPredict boolValue] )
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
    if( editingStyle == UITableViewCellEditingStyleDelete ){
        NSArray *items = [[_itemArray objectAtIndex:indexPath.section] objectForKey:ItemKey_Items];
        LadyCalendarPeriod *item = (indexPath.row >= [items count] ? nil : [items objectAtIndex:indexPath.row]);
        
        if( item ){
            if([_dataManager removePeriod:item.uniqueID] ){
                [_dataManager recalculateDates];
                self.sourceArray = [_dataManager periodListSortedByStartDateIsAscending:YES accountID:self.currentAccount.uniqueID];
                self.predictArray = [_dataManager predictPeriodListSortedByStartDateIsAscending:YES accountID:self.currentAccount.uniqueID];
                self.fullArray = [_sourceArray arrayByAddingObjectsFromArray:_predictArray];
                [self groupingPeriodByYearInArray:_fullArray];
                [self.tableView reloadData];
            }
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *items = [[_itemArray objectAtIndex:indexPath.section] objectForKey:ItemKey_Items];
    LadyCalendarPeriod *item = (indexPath.row >= [items count] ? nil : [items objectAtIndex:indexPath.row]);
    
    return ( item ? ![item.isPredict boolValue] : NO);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *items = [[_itemArray objectAtIndex:indexPath.section] objectForKey:ItemKey_Items];
    LadyCalendarPeriod *item = (indexPath.row >= [items count] ? nil : [items objectAtIndex:indexPath.row]);
    
    if( item == nil )
        return;
    
    NSString *monthStr = [A3DateHelper dateStringFromDate:item.startDate withFormat:@"MMMM"];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:monthStr style:UIBarButtonItemStylePlain target:nil action:nil];
    A3LadyCalendarDetailViewController *viewCtrl = [[A3LadyCalendarDetailViewController alloc] initWithNibName:@"A3LadyCalendarDetailViewController" bundle:nil];
	viewCtrl.dataManager = _dataManager;
    viewCtrl.month = item.startDate;
    viewCtrl.periodItems = [self sameMonthItemFromIndexPath:indexPath];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:monthStr style:UIBarButtonItemStyleBordered target:nil action:nil];
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

#pragma mark - action method
- (IBAction)addPeriodAction:(id)sender
{
    A3LadyCalendarAddPeriodViewController *viewCtrl = [[A3LadyCalendarAddPeriodViewController alloc] initWithNibName:@"A3LadyCalendarAddPeriodViewController" bundle:nil];
	viewCtrl.dataManager = _dataManager;
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
    navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:navCtrl animated:YES completion:nil];
}

- (void)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneButtonAction:(UIBarButtonItem *)button
{
    [self cancelAction:nil];
}

@end
