//
//  A3DaysCounterEventListViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterEventListViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "SFKImage.h"
#import "DaysCounterCalendar.h"
#import "DaysCounterCalendar+Extension.h"
#import "DaysCounterEvent.h"
#import "DaysCounterDate.h"
#import "A3DateHelper.h"
#import "A3DaysCounterEventListEditViewController.h"
#import "A3DateHelper.h"
#import "A3RoundDateView.h"
#import "A3DaysCounterSlideShowMainViewController.h"
#import "A3DaysCounterCalendarListMainViewController.h"
#import "A3DaysCounterFavoriteListViewController.h"
#import "A3DaysCounterReminderListViewController.h"
#import "A3DaysCounterAddEventViewController.h"
#import "A3DaysCounterEventListDateCell.h"
#import "A3DaysCounterEventListNameCell.h"
#import "A3DaysCounterEventListSectionHeader.h"
#import "A3WalletSegmentedControl.h"
#import "NSDate+LunarConverter.h"
#import "A3AppDelegate+appearance.h"
#import "DaysCounterEvent+management.h"

@interface A3DaysCounterEventListViewController () <UINavigationControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, A3DaysCounterEventDetailViewControllerDelegate>
@property (strong, nonatomic) NSArray *itemArray;
@property (strong, nonatomic) NSArray *sourceArray;
@property (strong, nonatomic) NSArray *searchResultArray;
@property (strong, nonatomic) NSString *changedCalendarID;
@property (nonatomic, strong) UIImageView *sortArrowImgView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *mySearchDisplayController;

@end

@implementation A3DaysCounterEventListViewController

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

    self.title = [NSString stringWithFormat:@"%@%@",_calendarItem.calendarName,([_calendarItem.calendarType integerValue] == CalendarCellType_User ? @"" : NSLocalizedString(@" Events", @" Events"))];
    UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchAction:)];
    UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction:)];
    self.navigationItem.rightBarButtonItems = @[edit, search];
    [self makeBackButtonEmptyArrow];
    _sortType = EventSortType_Name;
    _sortTypeSegmentCtrl.selectedSegmentIndex = _sortType;
    _isDateAscending = YES;
    _isNameAscending = YES;
    self.toolbarItems = _bottomToolbar.items;
    [self.navigationController setToolbarHidden:NO];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, (IS_IPHONE ? 15.0 : 28.0), 0, 0);
    if (IS_RETINA) {
        CGRect rect = self.tableView.tableHeaderView.frame;
        //rect.size.height += 0.5;
        self.tableView.tableHeaderView.frame = rect;
        self.headerViewSeparatorHeightConst.constant = 0.5;
        //self.headerViewTopConst.constant += 0.5;
    }

    _segmentControlWidthConst.constant = ( IS_IPHONE ? 171 : 300.0);
    
    [self.view addSubview:_addEventButton];
    _addEventButton.tintColor = [A3AppDelegate instance].themeColor;
    [_addEventButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.centerX);
        make.bottom.equalTo(self.view.bottom).with.offset(-(CGRectGetHeight(self.bottomToolbar.frame) + 11));
        make.width.equalTo(@44);
        make.height.equalTo(@44);
    }];
    
    if (![self.headerView.subviews containsObject:self.sortArrowImgView]) {
        [self.headerView addSubview:self.sortArrowImgView];
    }
    
    [self.view addSubview:self.searchBar];
    [self mySearchDisplayController];

    [self.view layoutIfNeeded];

	[self registerContentSizeCategoryDidChangeNotification];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudDidImportChanges:) name:USMStoreDidImportChangesNotification object:nil];
}

- (void)cloudDidImportChanges:(NSNotification *)notification {
	[self loadEventData];
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:USMStoreDidImportChangesNotification object:nil];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO];

    if ( [self.changedCalendarID length] > 0 && ![self.changedCalendarID isEqualToString:_calendarItem.calendarId] ) {
        self.calendarItem = [_sharedManager calendarItemByID:self.changedCalendarID inContext:[[MagicalRecordStack defaultStack] context] ];
        self.changedCalendarID = nil;
        if ( self.calendarItem ) {
            self.title = [NSString stringWithFormat:@"%@%@", _calendarItem.calendarName, [_calendarItem.calendarType integerValue] == CalendarCellType_User ? @"" : NSLocalizedString(@" Events", @" Events")];
        }
    }

	[self loadEventData];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self setupSegmentSortArrow];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)dealloc
//{
//    self.sourceArray = nil;
//    self.itemArray = nil;
//}

- (void)contentSizeDidChange:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (void)adjustFontSizeOfCell:(UITableViewCell *)cell {
    UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
    UILabel *daysLabel = (UILabel*)[cell viewWithTag:11];
    UILabel *markLabel = (UILabel*)[cell viewWithTag:12];
    UILabel *dateLabel = (UILabel*)[cell viewWithTag:16];
    
    if ( IS_IPHONE ) {
        textLabel.font = [UIFont systemFontOfSize:15.0];
        markLabel.font = [UIFont systemFontOfSize:11.0];
        daysLabel.font = [UIFont systemFontOfSize:13.0];
    }
    else {
        textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        markLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
        daysLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    }
}

#pragma mark 
- (NSMutableArray*)sortedArrayByDateAscending:(BOOL)ascending
{
    NSArray *array = [_sourceArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        DaysCounterEvent *item1 = (DaysCounterEvent*)obj1;
        DaysCounterEvent *item2 = (DaysCounterEvent*)obj2;
        
        return [item1.effectiveStartDate compare:item2.effectiveStartDate];
    }];
    
    if ( !ascending ) {
        array = [[array reverseObjectEnumerator] allObjects];
    }
    
    NSMutableArray *sectionArray = [NSMutableArray array];
    NSMutableDictionary *sectionDict = [NSMutableDictionary dictionary];
    for (DaysCounterEvent *event in array) {
        NSString *sectionKey = [A3DateHelper dateStringFromDate:event.effectiveStartDate withFormat:@"yyyy.MM"];
        NSMutableArray *items = [sectionDict objectForKey:sectionKey];
        if ( items == nil ) {
            items = [NSMutableArray arrayWithObject:event];
            [sectionDict setObject:items forKey:sectionKey];
            [sectionArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:event.effectiveStartDate, EventKey_Date, items, EventKey_Items, nil]];
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
        
        return [item1.eventName compare:item2.eventName options:NSCaseInsensitiveSearch];
    }];
    
    if ( !ascending ) {
        array = [[array reverseObjectEnumerator] allObjects];
    }
    
    return [NSMutableArray arrayWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSMutableArray arrayWithArray:array],EventKey_Items, nil]];
}

- (void)loadEventData
{
    if ( [_calendarItem.calendarType integerValue] == CalendarCellType_User) {
        self.sourceArray = [_calendarItem.events array];
    }
    else {
        if ( [_calendarItem.calendarId isEqualToString:SystemCalendarID_All] ) {
            self.sourceArray = [_sharedManager allEventsList];
        }
        else if ( [_calendarItem.calendarId isEqualToString:SystemCalendarID_Past] ) {
            self.sourceArray = [_sharedManager pastEventsListWithDate:[NSDate date]];
        }
        else if ( [_calendarItem.calendarId isEqualToString:SystemCalendarID_Upcoming] ) {
            self.sourceArray = [_sharedManager upcomingEventsListWithDate:[NSDate date]];
        }
    }
    
    if ( _sortType == EventSortType_Name ) {
        self.itemArray = [self sortedArrayByNameAscending:_isNameAscending];
    }
    else if ( _sortType == EventSortType_Date ) {

        self.itemArray = [self sortedArrayByDateAscending:_isDateAscending];
    }
    [self.tableView reloadData];
    
    _sortTypeSegmentCtrl.enabled = ([_sourceArray count] > 0);
    _sortTypeSegmentCtrl.tintColor =(_sortTypeSegmentCtrl.enabled ? nil : [UIColor colorWithRed:147.0/255.0 green:147.0/255.0 blue:147.0/255.0 alpha:1.0]);
    
    UIBarButtonItem *edit = [self.navigationItem.rightBarButtonItems objectAtIndex:0];
    UIBarButtonItem *search = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
    edit.enabled = ([_sourceArray count] > 0);
    search.enabled = ([_sourceArray count] > 0);
}

- (UIImageView *)sortArrowImgView
{
    if (!_sortArrowImgView) {
        _sortArrowImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sort"]];
        _sortArrowImgView.frame = CGRectMake(0, 0, 9, 5);
    }
    
    return _sortArrowImgView;
}

- (void)setupSegmentSortArrow
{
    float topViewWidth = self.headerView.bounds.size.width;
    float segmentWidth = self.sortTypeSegmentCtrl.frame.size.width;
    float arrowRightMargin = IS_IPAD ? 30 : 15;
    
    switch (_sortType) {
        case EventSortType_Date:
        {
            self.sortArrowImgView.center = CGPointMake(topViewWidth / 2.0 - arrowRightMargin, self.sortTypeSegmentCtrl.center.y);
            
            if (_isDateAscending) {
                _sortArrowImgView.transform = CGAffineTransformIdentity;
            }
            else {
                _sortArrowImgView.transform = CGAffineTransformMakeRotation(DegreesToRadians(180));
            }
            break;
        }
        case EventSortType_Name:
        {
            self.sortArrowImgView.center = CGPointMake(topViewWidth / 2.0 + segmentWidth / 2.0 - arrowRightMargin, self.sortTypeSegmentCtrl.center.y);
            
            if (_isNameAscending) {
                _sortArrowImgView.transform = CGAffineTransformIdentity;
            }
            else {
                _sortArrowImgView.transform = CGAffineTransformMakeRotation(DegreesToRadians(180));
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - UINavigationController Delegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (!animated) {
        return;
    }
    
    if ([viewController isKindOfClass:[A3DaysCounterAddEventViewController class]]) {
        navigationController.delegate = nil;
        [((A3DaysCounterAddEventViewController *)viewController) showKeyboard];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if ( tableView != self.tableView ) {
        return 1;
    }
    
    return ([_itemArray count] < 1 ? 1 : [_itemArray count]);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if ( tableView != self.tableView )
        return [_searchResultArray count];
    

    if ( _sortType == EventSortType_Date ) {
        NSInteger retNumber = 0;
        if ( section+1 >= [_itemArray count] ) {
            CGFloat totalHeight = 0.0;
            for ( NSDictionary *dict in _itemArray ) {
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
    if ( tableView != self.tableView ) {
        return nil;
    }
    
    if ( _sortType != EventSortType_Date ) {
        return nil;
    }
    
    NSDictionary *dict = [_itemArray objectAtIndex:section];
    NSArray *items = [dict objectForKey:EventKey_Items];
    if ( [items count] < 1 ) {
        return nil;
    }
    
    UIView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterEventListSectionHeader" owner:nil options:nil] lastObject];
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
    
    ((A3DaysCounterEventListSectionHeader *)headerView).monthLeadingConst.constant = IS_IPHONE ? 15 : 28;
    
    NSDate *date = [dict objectForKey:EventKey_Date];
    yearLabel.text = [NSString stringWithFormat:@"%ld", (long)[A3DateHelper yearFromDate:date]];
    monthLabel.text = [A3DateHelper dateStringFromDate:date withFormat:@"MMMM"];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ( tableView != self.tableView) {
        return 0;
        //return 0.01;
    }
    
    NSDictionary *dict = [_itemArray objectAtIndex:section];
    NSArray *items = [dict objectForKey:EventKey_Items];
    if ( [items count] < 1 ) {
        return 0.01;
    }
    
    return (_sortType == EventSortType_Date ? 23.0 : 0.01);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if ( tableView != self.tableView) {
        return 0;
    }
    
    return 0.01;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62.0;
}

- (DaysCounterEvent *)itemForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
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

    
    return item;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FNLOG();
    NSString *CellIdentifier = (_sortType == EventSortType_Name ? @"eventListNameCell" : @"eventListDateCell");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        switch (_sortType) {
            case EventSortType_Name:
                cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterEventListNameCell" owner:nil options:nil] lastObject];
                break;
                
            case EventSortType_Date:
                cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterEventListDateCell" owner:nil options:nil] lastObject];
                break;
                
            default:
                break;
        }
    }
    
    [self adjustFontSizeOfCell:cell];
    
    DaysCounterEvent *item = [self itemForTableView:tableView atIndexPath:indexPath];
    
    UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
    UILabel *daysLabel = (UILabel*)[cell viewWithTag:11];
    UILabel *markLabel = (UILabel*)[cell viewWithTag:12];
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:13];
    A3RoundDateView *roundDateView = (A3RoundDateView*)[cell viewWithTag:14];
    
    if ( item ) {
        NSDate *startDate = item.effectiveStartDate;
//        if ( [item.isLunar boolValue] ) {
//            startDate = [[A3DaysCounterModelManager sharedManager] nextSolarDateFromLunarDateComponents:[A3DaysCounterModelManager dateComponentsFromDateModelObject:[item startDate] toLunar:[item.isLunar boolValue]]
//                                                                                              leapMonth:[item.startDate.isLeapMonth boolValue]
//                                                                                               fromDate:[NSDate date]];
//        }
//        else {
//            startDate = [[A3DaysCounterModelManager sharedManager] nextDateWithRepeatOption:[item.repeatType integerValue]
//                                                                                  firstDate:[item.startDate solarDate]
//                                                                                   fromDate:[NSDate date]
//                                                                                   isAllDay:[item.isAllDay boolValue]];
//        }

        // textLabel
        textLabel.text = item.eventName;
        
        // until/since markLabel
        NSDate *now = [NSDate date];
        markLabel.text = [A3DateHelper untilSinceStringByFromDate:now
                                                           toDate:startDate
                                                     allDayOption:[item.isAllDay boolValue]
                                                           repeat:[item.repeatType integerValue] != RepeatType_Never ? YES : NO
                                                           strict:[A3DaysCounterModelManager hasHourMinDurationOption:[item.durationOption integerValue]]];
        ((A3DaysCounterEventListNameCell *)cell).untilRoundWidthConst.constant = 42;
        if ([markLabel.text isEqualToString:NSLocalizedString(@"since", @"since")]) {
            markLabel.textColor = [UIColor colorWithRed:1.0 green:45.0/255.0 blue:85.0/255.0 alpha:1.0];
        }
        else {
            markLabel.textColor = [UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:100.0/255.0 alpha:1.0];
        }
        
        // daysLabel
        if ([markLabel.text isEqualToString:NSLocalizedString(@"today", @"today")] || [markLabel.text isEqualToString:NSLocalizedString(@"Now", @"Now")]) {
            daysLabel.text = @" ";
        }
        else {
            daysLabel.text = [NSString stringWithFormat:@"%@", [A3DaysCounterModelManager stringOfDurationOption:[item.durationOption integerValue]
                                                                                                        fromDate:now
                                                                                                          toDate:startDate //[item startDate]
                                                                                                        isAllDay:[item.isAllDay boolValue]
                                                                                                    isShortStyle:IS_IPHONE ? YES : NO
                                                                                               isStrictShortType:NO]];
        }
        
        markLabel.layer.borderWidth = IS_RETINA ? 0.5 : 1.0;
        markLabel.layer.masksToBounds = YES;
        markLabel.layer.cornerRadius = 9.0;
        markLabel.layer.borderColor = markLabel.textColor.CGColor;
        markLabel.hidden = NO;
        
        // imageView
        UIImage *image = [item.hasPhoto boolValue] ? [item thumbnailImageInOriginalDirectory:YES] : nil;
        [self showImageViewOfCell:cell withImage:image];
        imageView.hidden = NO;
        
        // RoundDateView
        if ( _sortType == EventSortType_Date ) {
            UIImageView *favoriteView = (UIImageView*)[cell viewWithTag:15];
            roundDateView.fillColor = [item.calendar color];
            roundDateView.strokColor = roundDateView.fillColor;
            roundDateView.date = item.effectiveStartDate;
            roundDateView.hidden = NO;
            favoriteView.hidden = YES;//favoriteView.hidden = ![item.isFavorite boolValue];
            UILabel *dateLabel = (UILabel*)[cell viewWithTag:17];
            dateLabel.hidden = YES;
        }
        else {
            if ( IS_IPAD ) {
                NSDateFormatter *formatter = [NSDateFormatter new];
                [formatter setDateStyle:NSDateFormatterFullStyle];
                if (![item.isLunar boolValue] && ![item.isAllDay boolValue]) {
                    [formatter setTimeStyle:NSDateFormatterShortStyle];
                }
                
                UILabel *dateLabel = (UILabel*)[cell viewWithTag:16];
                dateLabel.text = [A3DateHelper dateStringFromDate:item.effectiveStartDate
                                                       withFormat:[formatter dateFormat]];
                dateLabel.hidden = NO;
                ((A3DaysCounterEventListNameCell *)cell).titleRightSpaceConst.constant = [dateLabel sizeThatFits:CGSizeMake(500, 30)].width + 5;
            }
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    else {
        textLabel.text = @"";
        daysLabel.text = @"";
        markLabel.text = @"";
        markLabel.hidden = YES;
        imageView.hidden = YES;
        
        if ( _sortType == EventSortType_Date ) {
            UIImageView *favoriteView = (UIImageView*)[cell viewWithTag:15];
            roundDateView.hidden = YES;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DaysCounterEvent *item = [self itemForTableView:tableView atIndexPath:indexPath];
    
    if ( item == nil ) {
        return;
    }
    
    A3DaysCounterEventDetailViewController *viewCtrl = [[A3DaysCounterEventDetailViewController alloc] init];
    viewCtrl.eventItem = item;
    viewCtrl.sharedManager = _sharedManager;
    viewCtrl.delegate = self;
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    FNLOG();
    if ( editingStyle == UITableViewCellEditingStyleDelete ) {
        NSDictionary *dict = [_itemArray objectAtIndex:indexPath.section];
        NSArray *items = [dict objectForKey:EventKey_Items];
        DaysCounterEvent *item = nil;
        if ( [items count] > 0) {
            item = [items objectAtIndex:indexPath.row];
        }
        
        [_sharedManager removeEvent:item];
		[self loadEventData];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    FNLOG();
    if ([indexPath row] >= [_sourceArray count]) {
        return NO;
    }
    
    return YES;
}

#pragma mark Cell & Item Data Related
- (NSInteger)daysGapForItem:(DaysCounterEvent *)item {
    NSDate *today = [NSDate date];
    NSInteger resultDaysGap;
    
    if ( [item.repeatType integerValue] == RepeatType_Never ) {
        resultDaysGap = [A3DateHelper diffDaysFromDate:today
                                                toDate:[item.startDate solarDate]
                                              isAllDay:[item.isAllDay boolValue]];
    }
    else {
        NSDate *nextRepeatStartDate = [A3DaysCounterModelManager nextDateWithRepeatOption:[item.repeatType integerValue]
                                                                                firstDate:[item.startDate solarDate]
                                                                                 fromDate:today
                                                                                 isAllDay:[item.isAllDay boolValue]];
        resultDaysGap = [A3DateHelper diffDaysFromDate:today
                                                toDate:nextRepeatStartDate
                                              isAllDay:[item.isAllDay boolValue]];
    }
    
    return resultDaysGap;
}

- (NSString *)daysStringForItem:(DaysCounterEvent *)item {
    NSDate *today = [NSDate date];
    NSDate *nextRepeatStartDate;
    NSInteger daysGap;
    NSString *result;
    
    if ( [item.repeatType integerValue] == RepeatType_Never ) {
        daysGap = [A3DateHelper diffDaysFromDate:today
                                          toDate:[item.startDate solarDate]
                                        isAllDay:[item.isAllDay boolValue]];
    }
    else {
        nextRepeatStartDate = [A3DaysCounterModelManager nextDateWithRepeatOption:[item.repeatType integerValue]
                                                                        firstDate:[item.startDate solarDate]
                                                                         fromDate:today
                                                                         isAllDay:[item.isAllDay boolValue]];
        daysGap = [A3DateHelper diffDaysFromDate:today
                                          toDate:nextRepeatStartDate
                                        isAllDay:[item.isAllDay boolValue]];
    }

    daysGap = labs(daysGap);
    result = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld days", @"StringsDict", nil), (long)daysGap];
    return result;
}

- (void)showImageViewOfCell:(UITableViewCell *)cell withImage:(UIImage *)image {
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:13];
    if (image) {
		imageView.contentMode = UIViewContentModeScaleAspectFill;
		imageView.layer.cornerRadius = imageView.bounds.size.width / 2.0;
		imageView.layer.masksToBounds = YES;
        imageView.image = image;
        
        if ( _sortType == EventSortType_Name ) {
            ((A3DaysCounterEventListNameCell *)cell).photoLeadingConst.constant = IS_IPHONE ? 15 : 28;
            ((A3DaysCounterEventListNameCell *)cell).sinceLeadingConst.constant = IS_IPHONE ? 52 : 65;
            ((A3DaysCounterEventListNameCell *)cell).nameLeadingConst.constant = IS_IPHONE ? 52 : 65;
        }
        else {
            ((A3DaysCounterEventListDateCell *)cell).roundDateLeadingConst.constant = IS_IPHONE ? 15 : 28;
            ((A3DaysCounterEventListDateCell *)cell).photoLeadingConst.constant = IS_IPHONE ? 52 : 65;
            ((A3DaysCounterEventListDateCell *)cell).nameLeadingConst.constant = IS_IPHONE ? 89 : 102;
            ((A3DaysCounterEventListDateCell *)cell).sinceLeadingConst.constant = IS_IPHONE ? 89 : 102;
        }
    }
    else {
        imageView.image = nil;
        
        if ( _sortType == EventSortType_Name ) {
            ((A3DaysCounterEventListNameCell *)cell).sinceLeadingConst.constant = IS_IPHONE ? 15 : 28;
            ((A3DaysCounterEventListNameCell *)cell).nameLeadingConst.constant = IS_IPHONE ? 15 : 28;
        }
        else {
            ((A3DaysCounterEventListDateCell *)cell).roundDateLeadingConst.constant = IS_IPHONE ? 15 : 28;
            ((A3DaysCounterEventListDateCell *)cell).nameLeadingConst.constant = IS_IPHONE ? 52 : 65;
            ((A3DaysCounterEventListDateCell *)cell).sinceLeadingConst.constant = IS_IPHONE ? 52 : 65;
        }
    }
}

#pragma mark - A3DaysCounterEventDetailViewControllerDelegate
- (void)didChangedCalendarEventDetailViewController:(A3DaysCounterEventDetailViewController *)ctrl
{
    self.changedCalendarID = ctrl.eventItem.calendar.calendarId;
}

#pragma mark - UISearchDisplayDelegate
- (UISearchDisplayController *)mySearchDisplayController {
	if (!_mySearchDisplayController) {
		_mySearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
		_mySearchDisplayController.delegate = self;
		_mySearchDisplayController.searchBar.delegate = self;
		_mySearchDisplayController.searchResultsTableView.delegate = self;
		_mySearchDisplayController.searchResultsTableView.dataSource = self;
        //		_mySearchDisplayController.searchResultsTableView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2f];
		_mySearchDisplayController.searchResultsTableView.showsVerticalScrollIndicator = NO;
        _mySearchDisplayController.searchResultsTableView.tableFooterView = [UIView new];
        _mySearchDisplayController.searchResultsTableView.separatorInset = UIEdgeInsetsMake(0, (IS_IPHONE ? 15.0 : 28.0), 0, 0);
	}
	return _mySearchDisplayController;
}

- (UISearchBar *)searchBar {
	if (!_searchBar) {
		_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, kSearchBarHeight)];
		_searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_searchBar.backgroundColor = self.navigationController.navigationBar.backgroundColor;
		_searchBar.delegate = self;
	}
	return _searchBar;
}

#pragma mark- UISearchDisplayControllerDelegate

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
	[self.tableView setHidden:YES];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView {
	[self.tableView setHidden:NO];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView {
    
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
    
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
	CGRect frame = _searchBar.frame;
	frame.origin.y = 20.0;
	_searchBar.frame = frame;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
	CGRect frame = _searchBar.frame;
	frame.origin.y = 0.0;
	_searchBar.frame = frame;
}

#pragma mark - SearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	_searchBar.text = @"";
}

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
}

// called when Search (in our case "Done") button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.searchResultArray = [_sourceArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"eventName contains[cd] %@",searchText]];
    FNLOG(@"%s %@ : %ld",__FUNCTION__,searchText, (long)[_searchResultArray count]);
}

#pragma mark - action method
- (IBAction)changeSortAction:(id)sender
{
    UISegmentedControl *segCtrl = (UISegmentedControl*)sender;
    
    if ( _sortType == EventSortType_Date && _sortType == segCtrl.selectedSegmentIndex ) {
        _isDateAscending = !_isDateAscending;
    }
    else if ( _sortType == EventSortType_Name && _sortType == segCtrl.selectedSegmentIndex ) {
        _isNameAscending = !_isNameAscending;
    }
    
    _sortType = segCtrl.selectedSegmentIndex;

	[self loadEventData];
    [self setupSegmentSortArrow];
}

- (IBAction)searchAction:(id)sender
{
    [self.searchBar becomeFirstResponder];
}

- (IBAction)editAction:(id)sender {
    A3DaysCounterEventListEditViewController *viewCtrl = [[A3DaysCounterEventListEditViewController alloc] initWithNibName:@"A3DaysCounterEventListEditViewController" bundle:nil];
    viewCtrl.sharedManager = _sharedManager;
    viewCtrl.calendarItem = _calendarItem;

    if ( IS_IPHONE ) {
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
        navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
        navCtrl.delegate = self;
        [self presentViewController:navCtrl animated:YES completion:^{
        }];
    }
    else {
		A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController];
        [rootViewController presentCenterViewController:[[A3NavigationController alloc] initWithRootViewController:viewCtrl]
                                     fromViewController:self
                                         withCompletion:^{
                                         }];
    }
//    if ( IS_IPHONE ) {
//        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
//        navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
//        [self presentViewController:navCtrl animated:YES completion:nil];
//    }
//    else {
//        [self.A3RootViewController presentRightSideViewController:viewCtrl];
//    }
}

#pragma mark - action method
- (IBAction)photoViewAction:(id)sender {
    A3DaysCounterSlideShowMainViewController *viewCtrl = [[A3DaysCounterSlideShowMainViewController alloc] initWithNibName:@"A3DaysCounterSlideShowMainViewController" bundle:nil];
    viewCtrl.sharedManager = _sharedManager;
    [self popToRootAndPushViewController:viewCtrl animate:NO];
}

- (IBAction)reminderAction:(id)sender {
    A3DaysCounterReminderListViewController *viewCtrl = [[A3DaysCounterReminderListViewController alloc] initWithNibName:@"A3DaysCounterReminderListViewController" bundle:nil];
    viewCtrl.sharedManager = _sharedManager;
    [self popToRootAndPushViewController:viewCtrl animate:NO];
}

- (IBAction)favoriteAction:(id)sender {
    A3DaysCounterFavoriteListViewController *viewCtrl = [[A3DaysCounterFavoriteListViewController alloc] initWithNibName:@"A3DaysCounterFavoriteListViewController" bundle:nil];
    viewCtrl.sharedManager = _sharedManager;
    [self popToRootAndPushViewController:viewCtrl animate:NO];
}

- (IBAction)addEventAction:(id)sender {
    A3DaysCounterAddEventViewController *viewCtrl = [[A3DaysCounterAddEventViewController alloc] init];
    viewCtrl.calendarId = _calendarItem.calendarId;
    viewCtrl.sharedManager = _sharedManager;
    if ([_calendarItem.calendarType integerValue] == CalendarCellType_System) {
        viewCtrl.calendarId = nil;
    }

    viewCtrl.landscapeFullScreen = NO;
    if ( IS_IPHONE ) {
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
        navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
        navCtrl.delegate = self;
        [self presentViewController:navCtrl animated:YES completion:^{
            [viewCtrl showKeyboard];
        }];
    }
    else {
		A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController];
        [rootViewController presentCenterViewController:[[A3NavigationController alloc] initWithRootViewController:viewCtrl]
                                     fromViewController:self
                                         withCompletion:^{
                                             [viewCtrl showKeyboard];
                                         }];
    }
}

@end