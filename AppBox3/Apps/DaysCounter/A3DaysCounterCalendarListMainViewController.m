//
//  A3DaysCounterCalendarListViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterCalendarListMainViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "A3DaysCounterViewController.h"
#import "A3DaysCounterAddEventViewController.h"
#import "A3DaysCounterEditCalendarListViewController.h"
#import "A3DaysCounterAddAndEditCalendarViewController.h"
#import "A3DaysCounterEventListViewController.h"
#import "A3DaysCounterReminderListViewController.h"
#import "A3DaysCounterFavoriteListViewController.h"
#import "DaysCounterCalendar.h"
#import "DaysCounterEvent.h"
#import "A3DateHelper.h"

@interface A3DaysCounterCalendarListMainViewController ()
@property (strong, nonatomic) NSArray *itemArray;
@property (strong, nonatomic) NSArray *searchResultArray;

- (void)setupHeaderInfo;
@end

@implementation A3DaysCounterCalendarListMainViewController

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

    self.navigationItem.title = @"Days Counter";
    if ( IS_IPHONE ) {
        [self leftBarButtonAppsButton];
    }
    [self makeBackButtonEmptyArrow];
    [self registerContentSizeCategoryDidChangeNotification];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightTopButtonView];
    [self setToolbarItems:_bottomToolbar.items];
    
    if ( IS_IPHONE ) {
        [self.tableView setTableHeaderView:_headerView];
    }
    else {
        [self.tableView setTableHeaderView:_headerView_iPad];
        self.numberOfCalendarLabel = self.numberOfCalendarLabeliPad;
        self.numberOfEventsLabel = self.numberOfEventsLabeliPad;
        self.updateDateLabel = self.updateDateLabeliPad;
    }
//    [self.tableView setTableFooterView:_footerView];
    
    for (NSLayoutConstraint *layout in _verticalSeperators) {
        layout.constant = 1.0 / [[UIScreen mainScreen] scale];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.delegate = nil;
    [self.navigationController setToolbarHidden:NO];
    if ( IS_IPAD ) {
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            [self leftBarButtonAppsButton];
        }
        else {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
        }
    }
    
    _searchButton.enabled = ([[A3DaysCounterModelManager sharedManager] numberOfAllEvents] > 0);
    self.itemArray = [[A3DaysCounterModelManager sharedManager] visibleCalendarList];
    [self setupHeaderInfo];
    [self.tableView reloadData];
    
    if (![_addEventButton isDescendantOfView:self.view]) {
        _addEventButton.frame = CGRectMake(self.view.frame.size.width * 0.5 - _addEventButton.frame.size.width * 0.5,
                                           self.view.frame.size.height - _bottomToolbar.frame.size.height - 20.0 - _addEventButton.frame.size.height,
                                           _addEventButton.frame.size.width,
                                           _addEventButton.frame.size.height);
        [self.view addSubview:_addEventButton];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    _addEventButton.hidden = YES;
    if ( IS_IPAD ) {
        CGFloat barWidth = (UIInterfaceOrientationIsPortrait(toInterfaceOrientation) ? self.view.frame.size.width : self.view.frame.size.height);
        _iPadHeaderCenterConstraints.constant = barWidth / 3.0;
        [UIView animateWithDuration:duration animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if ( IS_IPAD ) {
        if ( UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            [self leftBarButtonAppsButton];
        }
        else {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
        }
    }
    _addEventButton.frame = CGRectMake(self.view.frame.size.width * 0.5 - _addEventButton.frame.size.width * 0.5,
                                       self.view.frame.size.height - _bottomToolbar.frame.size.height - 20.0 - _addEventButton.frame.size.height,
                                       _addEventButton.frame.size.width,
                                       _addEventButton.frame.size.height);
    _addEventButton.hidden = NO;
}

- (void)setupHeaderInfo
{
    NSInteger eventNumber = [[A3DaysCounterModelManager sharedManager] numberOfAllEvents];
    NSDate *latestDate = [[A3DaysCounterModelManager sharedManager] dateOfLatestEvent];
    _numberOfCalendarLabel.text = [NSString stringWithFormat:@"%ld", (long)[[A3DaysCounterModelManager sharedManager] numberOfUserCalendarVisible]];
    _numberOfEventsLabel.text = [NSString stringWithFormat:@"%@",(eventNumber > 0 ? [NSString stringWithFormat:@"%ld", (long)eventNumber] : @"")];
    _updateDateLabel.text = ( latestDate ? [A3DateHelper dateStringFromDate:latestDate withFormat:@"dd/MM/yy"] : @"-/-/-");
    _headerEventLabel.text = (eventNumber > 0 ? @"EVENTS" : @"EVENT");
}

#pragma mark Initialize FontSize
- (void)contentSizeDidChange:(NSNotification*)noti
{
    [self adjustFontSizeOfHeaderView:IS_IPHONE ? _headerView : _headerView_iPad];
}

- (void)adjustFontSizeOfHeaderView:(UIView *)aView {
    if ([aView.subviews count] > 0) {
        [aView.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
            [self adjustFontSizeOfHeaderView:subview];
        }];
    }
    else {
//        if (![aView isKindOfClass:[UILabel class]]) {
//            return;
//        }
        
        switch ([aView tag]) {
            case 12:
                ((UILabel *)aView).font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
                [((UILabel *)aView) sizeToFit];
                break;
                
            case 13:
                ((UILabel *)aView).font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
                [((UILabel *)aView) sizeToFit];
                break;
                
            default:
                break;
        }
    }
    
    [self.tableView reloadData];
}

- (void)adjustFontSizeOfCell:(UITableViewCell *)cell withCellType:(A3DaysCounterCalendarCellType)cellType {
    // suffix is tag
    UILabel *eventNameLabel12 = (UILabel*)[cell viewWithTag:12];
    UILabel *periodLabel13 = (UILabel*)[cell viewWithTag:13];
    UILabel *periodLabel14 = (UILabel*)[cell viewWithTag:14];
    eventNameLabel12.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    periodLabel13.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
    periodLabel14.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
}

#pragma mark - action method
- (IBAction)photoViewAction:(id)sender {
    A3DaysCounterViewController *viewCtrl = [[A3DaysCounterViewController alloc] initWithNibName:@"A3DaysCounterViewController" bundle:nil];
    [self popToRootAndPushViewController:viewCtrl animate:NO];
}

- (IBAction)addEventAction:(id)sender {
    A3DaysCounterAddEventViewController *viewCtrl = [[A3DaysCounterAddEventViewController alloc] initWithNibName:@"A3DaysCounterAddEventViewController" bundle:nil];
    viewCtrl.landscapeFullScreen = NO;
    
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
    navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:navCtrl animated:YES completion:nil];
//    if ( IS_IPHONE ) {
//        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
//        navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
//        [self presentViewController:navCtrl animated:YES completion:nil];
//    }
//    else {
//        [self.navigationController pushViewController:viewCtrl animated:YES];
//    }
}

- (IBAction)reminderAction:(id)sender {
    A3DaysCounterReminderListViewController *viewCtrl = [[A3DaysCounterReminderListViewController alloc] initWithNibName:@"A3DaysCounterReminderListViewController" bundle:nil];
    [self popToRootAndPushViewController:viewCtrl animate:NO];
}

- (IBAction)favoriteAction:(id)sender {
    A3DaysCounterFavoriteListViewController *viewCtrl = [[A3DaysCounterFavoriteListViewController alloc] initWithNibName:@"A3DaysCounterFavoriteListViewController" bundle:nil];
    [self popToRootAndPushViewController:viewCtrl animate:NO];
}

- (IBAction)editAction:(id)sender {
    A3DaysCounterEditCalendarListViewController *viewCtrl = [[A3DaysCounterEditCalendarListViewController alloc] initWithNibName:@"A3DaysCounterEditCalendarListViewController" bundle:nil];
    
    if ( IS_IPHONE ) {
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
        [self presentViewController:navCtrl animated:YES completion:nil];
    }
    else
        [self.A3RootViewController presentRightSideViewController:viewCtrl];
}

- (IBAction)addCalendarAction:(id)sender {
    A3DaysCounterAddAndEditCalendarViewController *viewCtrl = [[A3DaysCounterAddAndEditCalendarViewController alloc] initWithNibName:@"A3DaysCounterAddAndEditCalendarViewController" bundle:nil];
    viewCtrl.isEditMode = NO;
    viewCtrl.calendarItem = nil;
    
    if ( IS_IPHONE ) {
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
        navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:navCtrl animated:YES completion:nil];
    }
    else {
        [self.A3RootViewController presentRightSideViewController:viewCtrl];
    }
}

- (IBAction)searchAction:(id)sender {
    self.tableView.tableHeaderView = self.searchDisplayController.searchBar;
    [self.searchDisplayController setActive:YES animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( tableView != self.tableView ) {
        return [_searchResultArray count];
    }
    
    NSInteger numberOfPage = (tableView.frame.size.height - _headerView.frame.size.height - _bottomToolbar.frame.size.height) / 84.0;
    
    return [_itemArray count] > numberOfPage ? [_itemArray count] + 1 : numberOfPage + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //DaysCounterCalendar *item = (tableView == self.tableView && (indexPath.row >= [_itemArray count])) ? nil : [(tableView == self.tableView ? _itemArray : _searchResultArray) objectAtIndex:indexPath.row];
    DaysCounterCalendar *item;
    if (tableView == self.tableView && (indexPath.row >= [_itemArray count])) {
        item = nil;
    }
    else {
        if (tableView == self.tableView) {
            item = [_itemArray objectAtIndex:[indexPath row]];
        }
        else {
            item = [_searchResultArray objectAtIndex:[indexPath row]];
        }
    }
    
    
    UITableViewCell *cell = nil;
    
    if (!item) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"emptyCell"];
        if ( cell == nil ) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:@"emptyCell"];
        }
        cell.textLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    
    NSInteger cellType = [item.calendarType integerValue];
    NSString *CellIdentifier = cellType == CalendarCellType_System ? @"systemCalendarListCell" : @"userCalendarListCell";
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *cellArray = [[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterCalendarCell" owner:nil options:nil];
        cell = [cellArray objectAtIndex:cellType];
    }
    
    UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
    UILabel *countLabel = (UILabel*)[cell viewWithTag:11];
    textLabel.textColor = [item color];
    countLabel.textColor = [item color];
    textLabel.text = item.calendarName;
    
    [self adjustFontSizeOfCell:cell withCellType:cellType];
    
    
    switch (cellType) {
        case CalendarCellType_User:
        {
            countLabel.text = [NSString stringWithFormat:@"%ld", (long)[item.events count]];
            UILabel *eventNameLabel = (UILabel*)[cell viewWithTag:12];
            UILabel *periodLabel = (UILabel*)[cell viewWithTag:13];
            
            if ( [item.events count] < 1 ) {
                eventNameLabel.text = @"";
                periodLabel.text = @"";
            }
            else {
                DaysCounterEvent *event = [item.events lastObject];
                eventNameLabel.text = event.eventName;
                NSDate *today = [NSDate date];
                NSDate *calcDate = event.startDate;
                NSInteger diffDay = 0;
                if ( [event.repeatType integerValue] != RepeatType_Never ) {
                    NSDate *nextDate = [[A3DaysCounterModelManager sharedManager] nextDateWithRepeatOption:[event.repeatType integerValue]
                                                                                                 firstDate:event.startDate
                                                                                                  fromDate:today];
                    diffDay = [A3DateHelper diffDaysFromDate:today toDate:nextDate];
                    calcDate = nextDate;
                }
                else {
                    diffDay = [A3DateHelper diffDaysFromDate:today toDate:event.startDate];
                }
                
                if ( diffDay == 0 ) {
                    periodLabel.text = @"Release 0 days";
                }
                else {
                    periodLabel.text = [NSString stringWithFormat:@"Release %@ %@", [[A3DaysCounterModelManager sharedManager] stringOfDurationOption:DurationOption_Day
                                                                                                                                             fromDate:today
                                                                                                                                               toDate:calcDate
                                                                                                                                             isAllDay:[event.isAllDay boolValue]],
                                        diffDay > 0 ? @"until" : @"since"];
                }
                
                if ( IS_IPAD ) {
                    UILabel *dateLabel = (UILabel*)[cell viewWithTag:14];
                    dateLabel.hidden = NO;
                    dateLabel.text = [A3DateHelper dateStringFromDate:calcDate
                                                           withFormat:[event.isAllDay boolValue] ? @"M/d/yy" : @"M/d/yy EEE h:m a"];
                }
            }
        }
            break;
            
        case CalendarCellType_System:
        {
            NSInteger numberOfEvents = 0;
            if ( [item.calendarId isEqualToString:SystemCalendarID_All] ) {
                numberOfEvents = [[A3DaysCounterModelManager sharedManager] numberOfAllEvents];
            }
            else if ( [item.calendarId isEqualToString:SystemCalendarID_Upcoming]) {
                numberOfEvents = [[A3DaysCounterModelManager sharedManager] numberOfUpcomingEventsWithDate:[NSDate date]];
            }
            else if ( [item.calendarId isEqualToString:SystemCalendarID_Past] ) {
                numberOfEvents = [[A3DaysCounterModelManager sharedManager] numberOfPastEventsWithDate:[NSDate date]];
            }
            
            countLabel.text = [NSString stringWithFormat:@"%ld", (long)numberOfEvents];
        }
            break;
        default:
            break;
    }
    
    
    return cell;
}


#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger numberOfPage = (tableView.frame.size.height - _headerView.frame.size.height - _bottomToolbar.frame.size.height) / 84.0;
    if ( tableView == self.tableView && ( indexPath.row >= [_itemArray count] && indexPath.row+1 >= numberOfPage) ) {
        return 42.0;
    }
    return 84.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( tableView == self.tableView && (indexPath.row >= [_itemArray count]) ) {
        return;
    }
    
    DaysCounterCalendar *item = [(tableView == self.tableView ?_itemArray : _searchResultArray) objectAtIndex:indexPath.row];
    
    A3DaysCounterEventListViewController *viewCtrl = [[A3DaysCounterEventListViewController alloc] initWithNibName:@"A3DaysCounterEventListViewController" bundle:nil];
    viewCtrl.calendarItem = item;
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( editingStyle == UITableViewCellEditingStyleDelete ) {
        DaysCounterCalendar *item = [_itemArray objectAtIndex:indexPath.row];
        if ( [item.calendarType integerValue] == CalendarCellType_System ) {
            return;
        }
        
        [[A3DaysCounterModelManager sharedManager] removeCalendarItemWithID:item.calendarId];
        self.itemArray = [[A3DaysCounterModelManager sharedManager] visibleCalendarList];
        [self setupHeaderInfo];
        [self.tableView reloadData];
    }
}

- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( tableView == self.tableView && (indexPath.row >= [_itemArray count]) )
        return NO;
    
    DaysCounterCalendar *item = [_itemArray objectAtIndex:indexPath.row];
    if ([item.events count] == 0) {
        return NO;
    }
    
    return ([item.calendarType integerValue] == CalendarCellType_User);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ( scrollView != self.tableView )
        return;
    if ( (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height && scrollView.contentSize.height > (scrollView.frame.size.height-_headerView.frame.size.height - _bottomToolbar.frame.size.height) )
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y-10.0);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ( scrollView != self.tableView )
        return;
    if ( !decelerate )
        [self scrollViewDidEndDecelerating:scrollView];
}

#pragma mark - UISearchDisplayDelegate
- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    self.searchResultArray = nil;
    if ( IS_IPHONE ) {
        self.tableView.tableHeaderView = _headerView;
    }
    else {
        self.tableView.tableHeaderView = _headerView_iPad;
    }
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.searchResultArray = [_itemArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"calendarName contains[cd] %@",searchText]];
    NSLog(@"%s %@ : %ld", __FUNCTION__, searchText, (long)[_searchResultArray count]);
    [self.searchDisplayController.searchResultsTableView reloadData];
}

@end
