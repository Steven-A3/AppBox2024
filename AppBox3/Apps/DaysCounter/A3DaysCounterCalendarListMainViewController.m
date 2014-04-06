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
#import "A3DaysCounterSlidershowMainViewController.h"
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

    [self leftBarButtonAppsButton];

    [self makeBackButtonEmptyArrow];
    [self registerContentSizeCategoryDidChangeNotification];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightTopButtonView];
    [self setToolbarItems:_bottomToolbar.items];
    
    if ( IS_IPHONE ) {
        if (IS_RETINA) {
            CGRect rect = _headerView.frame;
            rect.size.height += 0.5;
            _headerView.frame = rect;
        }
        [self.tableView setTableHeaderView:_headerView];
    }
    else {
        if (IS_RETINA) {
            CGRect rect = _iPadheaderView.frame;
            rect.size.height += 0.5;
            _iPadheaderView.frame = rect;
        }
        [self.tableView setTableHeaderView:_iPadheaderView];
        self.numberOfCalendarLabel = self.numberOfCalendarLabeliPad;
        self.numberOfEventsLabel = self.numberOfEventsLabeliPad;
        self.updateDateLabel = self.updateDateLabeliPad;
    }
    
    for (NSLayoutConstraint *layout in _verticalSeperators) {
        layout.constant = 1.0 / [[UIScreen mainScreen] scale];
    }
    
    if (IS_IPHONE) {
        _headerSeparator1_TopConst_iPhone.constant = 0.5;
        _headerSeparator2_TopConst_iPhone.constant = 0.5;
    }
    else {
        _headerSeparator1_TopConst_iPad.constant = 0.5;
        _headerSeparator2_TopConst_iPad.constant = 0.5;
    }
    
    [self.view addSubview:_addEventButton];
    [_addEventButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.centerX);
        make.bottom.equalTo(self.view.bottom).with.offset(-(CGRectGetHeight(self.bottomToolbar.frame) + 21));
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.delegate = nil;
    [self.navigationController setToolbarHidden:NO];
    
    _searchButton.enabled = ([[A3DaysCounterModelManager sharedManager] numberOfAllEvents] > 0);
    self.itemArray = [[A3DaysCounterModelManager sharedManager] visibleCalendarList];
    [self setupHeaderInfo];
    [self.tableView reloadData];
    
    [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"DaysCounterLastOpenedMainIndex"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    if ( IS_IPAD ) {
        CGFloat barWidth = (UIInterfaceOrientationIsPortrait(toInterfaceOrientation) ? self.view.frame.size.width : self.view.frame.size.height);
        _iPadHeaderCenterConstraints.constant = barWidth / 3.0;
        [UIView animateWithDuration:duration animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)setupHeaderInfo
{
    NSInteger eventNumber = [[A3DaysCounterModelManager sharedManager] numberOfAllEvents];
    NSDate *latestDate = [[A3DaysCounterModelManager sharedManager] dateOfLatestEvent];
    _numberOfCalendarLabel.text = [NSString stringWithFormat:@"%ld", (long)[[A3DaysCounterModelManager sharedManager] numberOfUserCalendarVisible]];
    //_numberOfEventsLabel.text = [NSString stringWithFormat:@"%@",(eventNumber > 0 ? [NSString stringWithFormat:@"%ld", (long)eventNumber] : @"")];
    _numberOfEventsLabel.text = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%ld", (long)eventNumber]];
    _updateDateLabel.text = ( latestDate ? [A3DateHelper dateStringFromDate:latestDate withFormat:@"dd/MM/yy"] : @"-/-/-");
    _headerEventLabel.text = (eventNumber > 0 ? @"EVENTS" : @"EVENT");
}

#pragma mark Initialize FontSize
- (void)contentSizeDidChange:(NSNotification*)noti
{
    if (IS_IPAD) {
        [self adjustFontSizeOfHeaderView:_iPadheaderView];
    }
}

- (void)adjustFontSizeOfHeaderView:(UIView *)aView {
    if ([aView.subviews count] > 0) {
        [aView.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
            [self adjustFontSizeOfHeaderView:subview];
        }];
    }
    else {
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
    UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
    UILabel *countLabel = (UILabel*)[cell viewWithTag:11];
//    UILabel *eventNameLabel12 = (UILabel*)[cell viewWithTag:12];
//    UILabel *periodLabel13 = (UILabel*)[cell viewWithTag:13];
//    UILabel *periodLabel14 = (UILabel*)[cell viewWithTag:14];
    
    textLabel.font = [UIFont systemFontOfSize:30];
    countLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-UltraLightP2" size:65];
//    if (IS_IPHONE) {
//        eventNameLabel12.font = [UIFont systemFontOfSize:13];
//        periodLabel13.font = [UIFont systemFontOfSize:11];
//        periodLabel14.font = [UIFont systemFontOfSize:11];
//    }
//    else {
//        eventNameLabel12.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
//        periodLabel13.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
//        periodLabel14.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
//    }
}

#pragma mark - action method
- (IBAction)photoViewAction:(id)sender {
    A3DaysCounterSlidershowMainViewController *viewCtrl = [[A3DaysCounterSlidershowMainViewController alloc] initWithNibName:@"A3DaysCounterSlidershowMainViewController" bundle:nil];
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
    
    if ([_itemArray count] > numberOfPage) {
        return [_itemArray count] + 1;
    }
    else {
        return numberOfPage + 1;;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (NSString *)periodStringForEvent:(DaysCounterEvent *)event
{
    NSString *result;
    NSDate *today = [NSDate date];
    NSDate *startDate = event.startDate;
    NSInteger daysGap = 0;
    NSString *untilSinceString = [A3DateHelper untilSinceStringByFromDate:today
                                                                   toDate:startDate
                                                             allDayOption:[event.isAllDay boolValue]
                                                                   repeat:[event.repeatType integerValue] != RepeatType_Never ? YES : NO];
    if ([untilSinceString isEqualToString:@"today"] || [untilSinceString isEqualToString:@"Now"]) {
        result = untilSinceString;
    }
    else {
        if ( [event.repeatType integerValue] != RepeatType_Never ) {
            NSDate *nextDate = [[A3DaysCounterModelManager sharedManager] nextDateWithRepeatOption:[event.repeatType integerValue]
                                                                                         firstDate:event.startDate
                                                                                          fromDate:today];
            untilSinceString = [A3DateHelper untilSinceStringByFromDate:today
                                                                 toDate:nextDate
                                                           allDayOption:[event.isAllDay boolValue]
                                                                 repeat:YES];
            
            daysGap = [A3DateHelper diffDaysFromDate:today toDate:nextDate];
            result = [NSString stringWithFormat:@"%@ %@", [[A3DaysCounterModelManager sharedManager] stringOfDurationOption:IS_IPHONE ? DurationOption_Day : [event.durationOption integerValue]
                                                                                                                   fromDate:today
                                                                                                                     toDate:nextDate
                                                                                                                   isAllDay:[event.isAllDay boolValue]], untilSinceString];
        }
        else {
            daysGap = [A3DateHelper diffDaysFromDate:today toDate:event.startDate isAllDay:[event.isAllDay boolValue]];
            result = [NSString stringWithFormat:@"%@ %@", [[A3DaysCounterModelManager sharedManager] stringOfDurationOption:IS_IPHONE ? DurationOption_Day : [event.durationOption integerValue]
                                                                                                                   fromDate:today
                                                                                                                     toDate:startDate
                                                                                                                   isAllDay:[event.isAllDay boolValue]], untilSinceString];
        }
    }

    return result;
}

- (NSString *)dateStringForEvent:(DaysCounterEvent *)event
{
    NSString *result;
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

    result = [A3DateHelper dateStringFromDate:calcDate
                                   withFormat:[event.isAllDay boolValue] ? @"M/d/yy" : @"M/d/yy EEE hh:mm a"];
    
    return result;
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
    NSString *CellIdentifier = (cellType == CalendarCellType_System) ? @"systemCalendarListCell" : @"userCalendarListCell";
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
    
//    [self adjustFontSizeOfCell:cell withCellType:cellType];
    
    switch (cellType) {
        case CalendarCellType_User:
        {
            countLabel.text = [NSString stringWithFormat:@"%ld", (long)[item.events count]];
            
            UILabel *eventDetailInfoLabel = (UILabel*)[cell viewWithTag:15];
            NSMutableAttributedString *eventDetailInfoString = [[NSMutableAttributedString alloc] initWithString:@""];
            if ([item.events count] > 0) {
                DaysCounterEvent *event = [item.events lastObject];
                
                NSAttributedString *eventName;
                NSAttributedString *period;
                NSAttributedString *date;
                NSDate *now = [NSDate date];
                NSDate *startDate = [event startDate];
                if ( [event.repeatType integerValue] != RepeatType_Never ) {
                    startDate = [[A3DaysCounterModelManager sharedManager] nextDateWithRepeatOption:[event.repeatType integerValue]
                                                                                          firstDate:[event startDate]
                                                                                           fromDate:now];
                }
                
                if (IS_IPHONE) {
                    eventName = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@, ", [event eventName]]
                                                                attributes:@{
                                                                             NSFontAttributeName : [UIFont systemFontOfSize:13],
                                                                             NSForegroundColorAttributeName : [UIColor blackColor]
                                                                             }];
                    
                    period = [[NSAttributedString alloc] initWithString:[self periodStringForEvent:event]
                                                             attributes:@{
                                                                          NSFontAttributeName : [UIFont systemFontOfSize:11],
                                                                          NSForegroundColorAttributeName : [UIColor colorWithRed:77/255.0 green:77/255.0 blue:77/255.0 alpha:1.0]
                                                                          }];
                    date = [[NSAttributedString alloc] initWithString:@""
                                                           attributes:@{
                                                                        NSFontAttributeName : [UIFont systemFontOfSize:11],
                                                                        NSForegroundColorAttributeName : [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1.0]
                                                                        }];
                }
                else {
                    eventName = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@, ", [event eventName]]
                                                                attributes:@{
                                                                             NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote],
                                                                             NSForegroundColorAttributeName : [UIColor blackColor]
                                                                             }];
                    period = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@, ", [self periodStringForEvent:event]]
                                                             attributes:@{
                                                                          NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1],
                                                                          NSForegroundColorAttributeName : [UIColor colorWithRed:77/255.0 green:77/255.0 blue:77/255.0 alpha:1.0]
                                                                          }];
                    date = [[NSAttributedString alloc] initWithString:[self dateStringForEvent:event]
                                                           attributes:@{
                                                                        NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1],
                                                                        NSForegroundColorAttributeName : [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1.0]
                                                                        }];
                }
                
                
                [eventDetailInfoString appendAttributedString:eventName];
                [eventDetailInfoString appendAttributedString:period];
                [eventDetailInfoString appendAttributedString:date];
                eventDetailInfoLabel.attributedText = eventDetailInfoString;
            }
            else {
                eventDetailInfoLabel.text = @"";
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
    
    [self adjustFontSizeOfCell:cell withCellType:cellType];
    
    
    return cell;
}




#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSInteger numberOfPage = (tableView.frame.size.height - _headerView.frame.size.height - _bottomToolbar.frame.size.height) / 84.0;
//    if ( tableView == self.tableView && ( indexPath.row >= [_itemArray count] && indexPath.row+1 >= numberOfPage) ) {
//        return 42.0;
//    }
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
//    if ([item.events count] == 0) {
//        return NO;
//    }
    
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
        self.tableView.tableHeaderView = _iPadheaderView;
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
