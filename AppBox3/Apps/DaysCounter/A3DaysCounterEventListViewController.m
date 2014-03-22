//
//  A3DaysCounterEventListViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterEventListViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "SFKImage.h"
#import "DaysCounterCalendar.h"
#import "DaysCounterEvent.h"
#import "A3DateHelper.h"
#import "A3DaysCounterEventListEditViewController.h"
#import "A3DateHelper.h"
#import "A3RoundDateView.h"
#import "A3DaysCounterSlidershowMainViewController.h"
#import "A3DaysCounterCalendarListMainViewController.h"
#import "A3DaysCounterFavoriteListViewController.h"
#import "A3DaysCounterReminderListViewController.h"
#import "A3DaysCounterAddEventViewController.h"


@interface A3DaysCounterEventListViewController ()
@property (strong, nonatomic) NSMutableArray *itemArray;
@property (strong, nonatomic) NSArray *sourceArray;
@property (strong, nonatomic) NSArray *searchResultArray;
@property (strong, nonatomic) NSString *changedCalendarID;

- (NSMutableArray*)sortedArrayByDateAscending:(BOOL)ascending;
- (NSMutableArray*)sortedArrayByNameAscending:(BOOL)ascending;
@end

@implementation A3DaysCounterEventListViewController

- (NSMutableArray*)sortedArrayByDateAscending:(BOOL)ascending
{
    NSArray *array = [_sourceArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        DaysCounterEvent *item1 = (DaysCounterEvent*)obj1;
        DaysCounterEvent *item2 = (DaysCounterEvent*)obj2;
        
        return [item1.startDate compare:item2.startDate];
    }];
    
    if ( !ascending )
        array = [[array reverseObjectEnumerator] allObjects];
    
    NSMutableArray *sectionArray = [NSMutableArray array];
    NSMutableDictionary *sectionDict = [NSMutableDictionary dictionary];
    for(DaysCounterEvent *event in array) {
        NSString *sectionKey = [A3DateHelper dateStringFromDate:event.startDate withFormat:@"yyyy.MM"];
        NSMutableArray *items = [sectionDict objectForKey:sectionKey];
        if ( items == nil ) {
            items = [NSMutableArray arrayWithObject:event];
            [sectionDict setObject:items forKey:sectionKey];
            [sectionArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:event.startDate,EventKey_Date,items,EventKey_Items, nil]];
        }
        else {
            [items addObject:event];
        }
    }
    
    return sectionArray;
}

- (NSMutableArray*)sortedArrayByNameAscending:(BOOL)ascending
{
    NSArray *array = [_sourceArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        DaysCounterEvent *item1 = (DaysCounterEvent*)obj1;
        DaysCounterEvent *item2 = (DaysCounterEvent*)obj2;
        
        return [item1.eventName compare:item2.eventName];
    }];
    
    if ( !ascending )
        array = [[array reverseObjectEnumerator] allObjects];
    
    return [NSMutableArray arrayWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSMutableArray arrayWithArray:array],EventKey_Items, nil]];
}

- (void)loadEventDatas
{
    if ( [_calendarItem.calendarType integerValue] == CalendarCellType_User) {
        self.sourceArray = [_calendarItem.events array];
    }
    else {
        if ( [_calendarItem.calendarId isEqualToString:SystemCalendarID_All] ) {
            self.sourceArray = [[A3DaysCounterModelManager sharedManager] allEventsList];
        }
        else if ( [_calendarItem.calendarId isEqualToString:SystemCalendarID_Past] ) {
            self.sourceArray = [[A3DaysCounterModelManager sharedManager] pastEventsListWithDate:[NSDate date]];
        }
        else if ( [_calendarItem.calendarId isEqualToString:SystemCalendarID_Upcoming] ) {
            self.sourceArray = [[A3DaysCounterModelManager sharedManager] upcomingEventsListWithDate:[NSDate date]];
        }
    }
    
    if ( sortType == EventSortType_Name ) {
        self.itemArray = [self sortedArrayByNameAscending:isAscending];
    }
    else if ( sortType == EventSortType_Date ) {
        self.itemArray = [self sortedArrayByDateAscending:isAscending];
    }
    [self.tableView reloadData];
    
    _sortTypeSegmentCtrl.enabled = ([_sourceArray count] > 0);
    _sortTypeSegmentCtrl.tintColor =(_sortTypeSegmentCtrl.enabled ? nil : [UIColor colorWithRed:196.0/255.0 green:196.0/255.0 blue:196.0/255.0 alpha:1.0]);
    
    _searchButton.enabled = ([_sourceArray count] > 0);
    _editButton.enabled = ([_sourceArray count] > 0);
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

    self.title = [NSString stringWithFormat:@"%@%@",_calendarItem.calendarName,([_calendarItem.calendarType integerValue] == CalendarCellType_User ? @"" : @" Events")];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightButtonsView];
    [self makeBackButtonEmptyArrow];
    [self registerContentSizeCategoryDidChangeNotification];
    sortType = EventSortType_Name;
    _sortTypeSegmentCtrl.selectedSegmentIndex = sortType;
    isAscending = YES;
    self.toolbarItems = _bottomToolbar.items;
    [self.navigationController setToolbarHidden:NO];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, (IS_IPHONE ? 15.0 : 28.0), 0, 0);
    _headerSeperatorHeightConst.constant = (1.0 / [[UIScreen mainScreen] scale] );
    _segmentControlWidthConst.constant = ( IS_IPHONE ? 170.0 : 300.0);
    [self.view layoutIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO];
    if ( ![_addEventButton isDescendantOfView:self.view] ) {
        _addEventButton.frame = CGRectMake(self.view.frame.size.width*0.5 - _addEventButton.frame.size.width*0.5, self.view.frame.size.height - _bottomToolbar.frame.size.height - 20.0 - _addEventButton.frame.size.height, _addEventButton.frame.size.width, _addEventButton.frame.size.height);
        [self.view addSubview:_addEventButton];
    }
    if ( [self.changedCalendarID length] > 0 && ![self.changedCalendarID isEqualToString:_calendarItem.calendarId] ) {
        self.calendarItem = [[A3DaysCounterModelManager sharedManager] calendarItemByID:self.changedCalendarID];
        self.changedCalendarID = nil;
        if ( self.calendarItem )
            self.title = [NSString stringWithFormat:@"%@%@",_calendarItem.calendarName,([_calendarItem.calendarType integerValue] == CalendarCellType_User ? @"" : @" Events")];
    }
    [self loadEventDatas];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.sourceArray = nil;
    self.itemArray = nil;
}


- (void)contentSizeDidChange:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (void)adjustFontSizeOfCell:(UITableViewCell *)cell {
    UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
    UILabel *daysLabel = (UILabel*)[cell viewWithTag:11];
    UILabel *markLabel = (UILabel*)[cell viewWithTag:12];
    if ( IS_IPHONE ) {
        textLabel.font = [UIFont systemFontOfSize:15.0];
        markLabel.font = [UIFont systemFontOfSize:11.0];
        daysLabel.font = [UIFont systemFontOfSize:13.0];
    }
    else {
        textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        markLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
        daysLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if ( tableView != self.tableView )
        return 1;
    
    return ([_itemArray count] < 1 ? 1 : [_itemArray count]);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if ( tableView != self.tableView )
        return [_searchResultArray count];
    

    if ( sortType == EventSortType_Date ) {
        NSInteger retNumber = 0;
        if ( section+1 >= [_itemArray count] ) {
            CGFloat totalHeight = 0.0;
            for( NSDictionary *dict in _itemArray ) {
                totalHeight += 23.0;
                NSArray *items = [dict objectForKey:EventKey_Items];
                totalHeight += [items count] * 62.0;
            }
            
            CGFloat tableHeight = tableView.frame.size.height - _bottomToolbar.frame.size.height - _headerView.frame.size.height;
            if ( [_itemArray count] > 0 ) {
                NSDictionary *dict = [_itemArray objectAtIndex:section];
                NSArray *items = [dict objectForKey:EventKey_Items];
                retNumber = [items count];
            }
            
            if ( totalHeight < tableHeight ) {
                CGFloat remainHeight = tableHeight - totalHeight;
                NSInteger emptyNum = remainHeight / 62.0;
                retNumber += emptyNum;
            }
        }
        else {
            NSDictionary *dict = [_itemArray objectAtIndex:section];
            NSArray *items = [dict objectForKey:EventKey_Items];
            retNumber = [items count];
        }
        
        return retNumber;
    }
    
    NSInteger numberOfCellInPage = (NSInteger)((tableView.frame.size.height - _bottomToolbar.frame.size.height - _headerView.frame.size.height) / 62.0 );
  
    NSArray *items = nil;
    if ( section < [_itemArray count] ) {
        NSDictionary *dict = [_itemArray objectAtIndex:section];
        items = [dict objectForKey:EventKey_Items];
    }
    
    return ([items count] < numberOfCellInPage ? numberOfCellInPage : [items count]);
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ( tableView != self.tableView )
        return nil;
    
    if ( sortType != EventSortType_Date )
        return nil;
    
    NSDictionary *dict = [_itemArray objectAtIndex:section];
    NSArray *items = [dict objectForKey:EventKey_Items];
    if ( [items count] < 1 )
        return nil;
    
    NSArray *cellArray = [[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterEventListCell" owner:nil options:nil];
    UIView *headerView = [cellArray objectAtIndex:2];
    UILabel *monthLabel = (UILabel*)[headerView viewWithTag:10];
    UILabel *yearLabel = (UILabel*)[headerView viewWithTag:11];
    
    if ( IS_IPHONE ) {
        monthLabel.font = [UIFont systemFontOfSize:13.0];
        yearLabel.font = [UIFont systemFontOfSize:13.0];
    }
    else {
        monthLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        yearLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    }
    
    NSDate *date = [dict objectForKey:EventKey_Date];
    yearLabel.text = [NSString stringWithFormat:@"%ld", (long)[A3DateHelper yearFromDate:date]];
    monthLabel.text = [A3DateHelper dateStringFromDate:date withFormat:@"MMMM"];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ( tableView != self.tableView)
        return 0.01;
    
    NSDictionary *dict = [_itemArray objectAtIndex:section];
    NSArray *items = [dict objectForKey:EventKey_Items];
    if ( [items count] < 1 )
        return 0.01;
    
    return (sortType == EventSortType_Date ? 23.0 : 0.01);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = (sortType == EventSortType_Name ? @"eventListNameCell" : @"eventListDateCell");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *cellArray = [[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterEventListCell" owner:nil options:nil];
        cell = [cellArray objectAtIndex:(sortType == EventSortType_Name ? 0 : 3)];
        
        UIView *leftView = nil;
        if ( sortType == EventSortType_Name ) {
            leftView = [cell viewWithTag:13];
        }
        else {
            leftView = [cell viewWithTag:14];
        }
        NSLayoutConstraint *leftConst = nil;
        for(NSLayoutConstraint *layout in cell.contentView.constraints) {
            if ( layout.firstAttribute == NSLayoutAttributeLeading && layout.firstItem == leftView ) {
                leftConst = layout;
                break;
            }
        }
        
        if ( leftConst ) {
            leftConst.constant = ( IS_IPHONE ? 15.0 : 28.0 );
            [cell layoutIfNeeded];
        }
    }
    
    [self adjustFontSizeOfCell:cell];
    
    // Configure the cell...
    DaysCounterEvent *item = nil;
    if ( tableView == self.tableView ) {
        if ( indexPath.section < [_itemArray count] ) {
            NSDictionary *dict = [_itemArray objectAtIndex:indexPath.section];
            NSArray *items = [dict objectForKey:EventKey_Items];
            if ( indexPath.row < [items count] ) {
                item = [items objectAtIndex:indexPath.row];
            }
        }
    }
    else {
        item = [_searchResultArray objectAtIndex:indexPath.row];
    }
    
    UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
    UILabel *daysLabel = (UILabel*)[cell viewWithTag:11];
    UILabel *markLabel = (UILabel*)[cell viewWithTag:12];
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:13];
    
    if ( item ) {
        NSLog(@"%s %@/%@",__FUNCTION__,indexPath,item.imageFilename);
        markLabel.hidden = NO;
        imageView.hidden = NO;
        
        textLabel.text = item.eventName;
        UIImage *image = ([item.imageFilename length] > 0 ? [A3DaysCounterModelManager photoThumbnailFromFilename:item.imageFilename] : nil);
        imageView.image =  (image ? [A3DaysCounterModelManager circularScaleNCrop:image rect:CGRectMake(0, 0, 33.0, 33.0)]  : nil);
        NSDate *today = [NSDate date];
        NSDate *calcDate = item.startDate;
        NSInteger diffDays = 0;
        if ( [item.repeatType integerValue] != RepeatType_Never ) {
            NSDate *nextDate = [[A3DaysCounterModelManager sharedManager] nextDateWithRepeatOption:[item.repeatType integerValue] firstDate:item.startDate fromDate:today];
            calcDate = nextDate;
        }

        diffDays = [A3DateHelper diffDaysFromDate:today toDate:calcDate];
        
        NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit
                    fromDate:today
                      toDate:calcDate options:0];
        
        NSInteger day = ABS([comps day]);
        if ( ![[A3DateHelper dateStringFromDate:today withFormat:@"yyyyMMdd"] isEqualToString:[A3DateHelper dateStringFromDate:calcDate withFormat:@"yyyyMMdd"]] ) {
            if ( ABS([comps hour]) > 0 || ABS([comps minute]) > 0 || ABS([comps second]) > 0 )
                day++;
        }
        daysLabel.text = [NSString stringWithFormat:@"%ld day%@", (long)day, (day>1 ? @"s" : @"")];
        
//        daysLabel.text = [[A3DaysCounterModelManager sharedManager] stringOfDurationOption:[item.durationOption integerValue] fromDate:today toDate:calcDate isAllDay:[item.isAllDay boolValue]];//[NSString stringWithFormat:@"%d days",ABS(diffDays)];
        if ( diffDays > 0 ) {
            markLabel.text = @"Until";
            markLabel.textColor = [UIColor colorWithRed:78.0/255.0 green:217.0/255.0 blue:100.0/255.0 alpha:1.0];
        }
        else {
            markLabel.text = @"Since";
            markLabel.textColor = [UIColor colorWithRed:1.0 green:45.0/255.0 blue:85.0/255.0 alpha:1.0];
        }
        markLabel.layer.borderWidth = 1.0;
        markLabel.layer.masksToBounds = YES;
        markLabel.layer.cornerRadius = 9.0;
        markLabel.layer.borderColor = markLabel.textColor.CGColor;
        
        
        if ( sortType == EventSortType_Date ) {
            A3RoundDateView *dateView = (A3RoundDateView*)[cell viewWithTag:14];
            UIImageView *favoriteView = (UIImageView*)[cell viewWithTag:15];
            
            dateView.fillColor = [item.calendar color];
            dateView.strokColor = dateView.fillColor;
            dateView.date = calcDate;//item.startDate;
            dateView.hidden = NO;
            favoriteView.hidden = ![item.isFavorite boolValue];
            UILabel *dateLabel = (UILabel*)[cell viewWithTag:17];
            dateLabel.hidden = YES;
//            if ( IS_IPAD ) {
//                UILabel *dateLabel = (UILabel*)[cell viewWithTag:17];
//                dateLabel.text = [A3DateHelper dateStringFromDate:item.startDate withFormat:@"dd/MM/yy HH:mm a"];
//                dateLabel.hidden = NO;
//            }
        }
        else {
            if ( IS_IPAD ) {
                UILabel *dateLabel = (UILabel*)[cell viewWithTag:16];
                dateLabel.text = [A3DateHelper dateStringFromDate:calcDate withFormat:[[A3DaysCounterModelManager sharedManager] dateFormatForAddEditIsAllDays:[item.isAllDay boolValue]]];
                dateLabel.hidden = NO;
            }
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    else {
        NSLog(@"%s %@",__FUNCTION__,indexPath);
        textLabel.text = @"";
        daysLabel.text = @"";
        markLabel.text = @"";
        markLabel.hidden = YES;
        imageView.hidden = YES;
        
        if ( sortType == EventSortType_Date ) {
            A3RoundDateView *dateView = (A3RoundDateView*)[cell viewWithTag:14];
            UIImageView *favoriteView = (UIImageView*)[cell viewWithTag:15];
            dateView.hidden = YES;
            favoriteView.hidden = YES;
        }
        
        if ( IS_IPAD ) {
            UILabel *dateLabel = (UILabel*)[cell viewWithTag:17];
            dateLabel.text = @"";
            dateLabel.hidden = YES;
            dateLabel = (UILabel*)[cell viewWithTag:16];
            dateLabel.text = @"";
            dateLabel.hidden = YES;
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}


#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:13];
    NSLayoutConstraint *widthConst = nil;
    for(NSLayoutConstraint *layout in imageView.constraints ) {
        if ( layout.firstAttribute == NSLayoutAttributeWidth && layout.firstItem == imageView ) {
            widthConst = layout;
            break;
        }
    }
    
    if ( widthConst ) {
        widthConst.constant = (imageView.image ? 33.0 : 0.0);
        [cell layoutIfNeeded];
        NSLog(@"%s %@ %f",__FUNCTION__,indexPath,widthConst.constant);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DaysCounterEvent *item = nil;
    if ( tableView == self.tableView ) {
        if ( indexPath.section < [_itemArray count] ) {
            NSDictionary *dict = [_itemArray objectAtIndex:indexPath.section];
            NSArray *items = [dict objectForKey:EventKey_Items];
            if ( indexPath.row < [items count] ) {
                item = [items objectAtIndex:indexPath.row];
            }
        }
    }
    else {
        item = [_searchResultArray objectAtIndex:indexPath.row];
    }
    
    if ( item == nil )
        return;
    
    A3DaysCounterEventDetailViewController *viewCtrl = [[A3DaysCounterEventDetailViewController alloc] initWithNibName:@"A3DaysCounterEventDetailViewController" bundle:nil];
    viewCtrl.eventItem = item;
    viewCtrl.delegate = self;
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( editingStyle == UITableViewCellEditingStyleDelete ) {
        NSDictionary *dict = [_itemArray objectAtIndex:indexPath.section];
        NSArray *items = [dict objectForKey:EventKey_Items];
        DaysCounterEvent *item = nil;
        if ( [items count] > 0) {
            item = [items objectAtIndex:indexPath.row];
        }
        
        [[A3DaysCounterModelManager sharedManager] removeEvent:item];
        [self loadEventDatas];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [_sourceArray count] < 1 )
        return NO;
    
    return YES;
}

#pragma mark - A3DaysCounterEventDetailViewControllerDelegate
- (void)didChangedCalendarEventDetailViewController:(A3DaysCounterEventDetailViewController *)ctrl
{
    self.changedCalendarID = ctrl.eventItem.calendarId;
}

#pragma mark - UISearchDisplayDelegate
- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    self.searchResultArray = nil;
    self.tableView.tableHeaderView = _headerView;
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.searchResultArray = [_sourceArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"eventName contains[cd] %@",searchText]];
    NSLog(@"%s %@ : %ld",__FUNCTION__,searchText, (long)[_searchResultArray count]);
    [self.searchDisplayController.searchResultsTableView reloadData];
}

#pragma mark - action method
- (IBAction)changeSortAction:(id)sender {
    UISegmentedControl *segCtrl = (UISegmentedControl*)sender;
    sortType = segCtrl.selectedSegmentIndex;
    
    if ( sortType == EventSortType_Date ) {
        _headerSeperatorView.hidden = NO;
    }
    else {
        _headerSeperatorView.hidden = YES;
    }
    
    [self loadEventDatas];
}

- (IBAction)searchAction:(id)sender {
    self.tableView.tableHeaderView = self.searchDisplayController.searchBar;
    [self.searchDisplayController setActive:YES animated:YES];
}

- (IBAction)editAction:(id)sender {
    A3DaysCounterEventListEditViewController *viewCtrl = [[A3DaysCounterEventListEditViewController alloc] initWithNibName:@"A3DaysCounterEventListEditViewController" bundle:nil];
    viewCtrl.calendarItem = _calendarItem;
    if ( IS_IPHONE ) {
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
        navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:navCtrl animated:YES completion:nil];
    }
    else {
        [self.A3RootViewController presentRightSideViewController:viewCtrl];
    }
}

#pragma mark - action method
- (IBAction)photoViewAction:(id)sender {
    A3DaysCounterSlidershowMainViewController *viewCtrl = [[A3DaysCounterSlidershowMainViewController alloc] initWithNibName:@"A3DaysCounterSlidershowMainViewController" bundle:nil];
    [self popToRootAndPushViewController:viewCtrl animate:NO];
}

- (IBAction)reminderAction:(id)sender {
    A3DaysCounterReminderListViewController *viewCtrl = [[A3DaysCounterReminderListViewController alloc] initWithNibName:@"A3DaysCounterReminderListViewController" bundle:nil];
    [self popToRootAndPushViewController:viewCtrl animate:NO];
}

- (IBAction)favoriteAction:(id)sender {
    A3DaysCounterFavoriteListViewController *viewCtrl = [[A3DaysCounterFavoriteListViewController alloc] initWithNibName:@"A3DaysCounterFavoriteListViewController" bundle:nil];
    [self popToRootAndPushViewController:viewCtrl animate:NO];
}

- (IBAction)addEventAction:(id)sender {
    A3DaysCounterAddEventViewController *viewCtrl = [[A3DaysCounterAddEventViewController alloc] initWithNibName:@"A3DaysCounterAddEventViewController" bundle:nil];
    viewCtrl.landscapeFullScreen = NO;
    if ( IS_IPHONE ) {
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
        navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:navCtrl animated:YES completion:nil];
    }
    else {
		A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController];
        [rootViewController presentCenterViewController:[[A3NavigationController alloc] initWithRootViewController:viewCtrl]
                                     fromViewController:self
                                         withCompletion:^{
                                             
                                         }];
    }
}

@end
