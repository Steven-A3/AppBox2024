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
#import "A3DaysCounterEventListDateCell.h"
#import "A3DaysCounterEventListNameCell.h"
#import "A3DaysCounterEventListSectionHeader.h"
#import "A3WalletSegmentedControl.h"
#import "NSDate+LunarConverter.h"
#import "A3AppDelegate+appearance.h"

@interface A3DaysCounterEventListViewController ()
@property (strong, nonatomic) NSMutableArray *itemArray;
@property (strong, nonatomic) NSArray *sourceArray;
@property (strong, nonatomic) NSArray *searchResultArray;
@property (strong, nonatomic) NSString *changedCalendarID;
@property (nonatomic, strong) UIImageView *sortArrowImgView;

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

    self.title = [NSString stringWithFormat:@"%@%@",_calendarItem.calendarName,([_calendarItem.calendarType integerValue] == CalendarCellType_User ? @"" : @" Events")];
    UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchAction:)];
    UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction:)];
    self.navigationItem.rightBarButtonItems = @[edit, search];
    [self makeBackButtonEmptyArrow];
    [self registerContentSizeCategoryDidChangeNotification];
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
        make.bottom.equalTo(self.view.bottom).with.offset(-(CGRectGetHeight(self.bottomToolbar.frame) + 21));
        make.width.equalTo(@44);
        make.height.equalTo(@44);
    }];
    if (![self.headerView.subviews containsObject:self.sortArrowImgView]) {
        [self.headerView addSubview:self.sortArrowImgView];
    }

    [self.view layoutIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO];

    if ( [self.changedCalendarID length] > 0 && ![self.changedCalendarID isEqualToString:_calendarItem.calendarId] ) {
        self.calendarItem = [[A3DaysCounterModelManager sharedManager] calendarItemByID:self.changedCalendarID];
        self.changedCalendarID = nil;
        if ( self.calendarItem ) {
            self.title = [NSString stringWithFormat:@"%@%@",_calendarItem.calendarName, [_calendarItem.calendarType integerValue] == CalendarCellType_User ? @"" : @" Events"];
        }
    }
    
    [self loadEventDatas];
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
    
    if ( _sortType == EventSortType_Name ) {
        self.itemArray = [self sortedArrayByNameAscending:_isNameAscending];
    }
    else if ( _sortType == EventSortType_Date ) {
        self.itemArray = [self sortedArrayByDateAscending:_isDateAscending];
    }
    [self.tableView reloadData];
    
    _sortTypeSegmentCtrl.enabled = ([_sourceArray count] > 0);
    _sortTypeSegmentCtrl.tintColor =(_sortTypeSegmentCtrl.enabled ? nil : [UIColor colorWithRed:196.0/255.0 green:196.0/255.0 blue:196.0/255.0 alpha:1.0]);
    
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
        return 0.01;
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
    return 0.01;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62.0;
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UIImageView *imageView = (UIImageView*)[cell viewWithTag:13];
//    NSLayoutConstraint *widthConst = nil;
//    for (NSLayoutConstraint *layout in imageView.constraints ) {
//        if ( layout.firstAttribute == NSLayoutAttributeWidth && layout.firstItem == imageView ) {
//            widthConst = layout;
//            break;
//        }
//    }
//    
//    if ( widthConst ) {
//        widthConst.constant = (imageView.image ? 32.0 : 0.0);
//        [cell layoutIfNeeded];
//    }
//}

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
        NSDate *startDate = [[A3DaysCounterModelManager sharedManager] nextDateWithRepeatOption:[item.repeatType integerValue]
                                                                                      firstDate:[item startDate]
                                                                                       fromDate:[NSDate date]];
        if ( [item.isLunar boolValue] ) {
            NSDateComponents *dateComp = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:startDate];
            BOOL isResultLeapMonth = NO;
            NSDateComponents *resultComponents = [NSDate lunarCalcWithComponents:dateComp
                                                                gregorianToLunar:NO
                                                                       leapMonth:NO
                                                                          korean:[A3DateHelper isCurrentLocaleIsKorea]
                                                                 resultLeapMonth:&isResultLeapMonth];
            NSDate *convertDate = [[NSCalendar currentCalendar] dateFromComponents:resultComponents];
            startDate = convertDate;
        }
        

        // textLabel
        textLabel.text = item.eventName;
        
        // until/since markLabel
        NSDate *now = [NSDate date];
        markLabel.text = [A3DateHelper untilSinceStringByFromDate:now
                                                           toDate:startDate
                                                     allDayOption:[item.isAllDay boolValue]
                                                           repeat:[item.repeatType integerValue] != RepeatType_Never ? YES : NO];
        ((A3DaysCounterEventListNameCell *)cell).untilRoundWidthConst.constant = 42;
        if ([markLabel.text isEqualToString:@"since"]) {
            markLabel.textColor = [UIColor colorWithRed:1.0 green:45.0/255.0 blue:85.0/255.0 alpha:1.0];
        }
        else {
            markLabel.textColor = [UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:100.0/255.0 alpha:1.0];
        }
        
        // daysLabel
        if ([markLabel.text isEqualToString:@"today"] || [markLabel.text isEqualToString:@"Now"]) {
            daysLabel.text = @" ";
        }
        else {
            daysLabel.text = [NSString stringWithFormat:@"%@", [[A3DaysCounterModelManager sharedManager] stringOfDurationOption:[item.durationOption integerValue]
                                                                                                                        fromDate:now
                                                                                                                          toDate:startDate //[item startDate]
                                                                                                                        isAllDay:[item.isAllDay boolValue]
                                                                                                                    isShortStyle:IS_IPHONE ? YES : NO]];
        }
        
        markLabel.layer.borderWidth = IS_RETINA ? 0.5 : 1.0;
        markLabel.layer.masksToBounds = YES;
        markLabel.layer.cornerRadius = 9.0;
        markLabel.layer.borderColor = markLabel.textColor.CGColor;
        markLabel.hidden = NO;
        
        // imageView
        UIImage *image = ([item.imageFilename length] > 0) ? [A3DaysCounterModelManager photoThumbnailFromFilename:item.imageFilename] : nil;
        [self showImageViewOfCell:cell withImage:image];
        imageView.hidden = NO;
        
        // RoundDateView
        if ( _sortType == EventSortType_Date ) {
            UIImageView *favoriteView = (UIImageView*)[cell viewWithTag:15];
            roundDateView.fillColor = [item.calendar color];
            roundDateView.strokColor = roundDateView.fillColor;
            roundDateView.date = startDate;
            roundDateView.hidden = NO;
            favoriteView.hidden = ![item.isFavorite boolValue];
            UILabel *dateLabel = (UILabel*)[cell viewWithTag:17];
            dateLabel.hidden = YES;
        }
        else {
            if ( IS_IPAD ) {
                UILabel *dateLabel = (UILabel*)[cell viewWithTag:16];
                
                if ([markLabel.text isEqualToString:@"today"] || [markLabel.text isEqualToString:@"Now"]) {
                    NSDate *repeatDate = [[A3DaysCounterModelManager sharedManager] repeatDateOfCurrentYearWithRepeatOption:[item.repeatType integerValue]
                                                                                                                  firstDate:item.startDate
                                                                                                                   fromDate:[NSDate date]];
                    dateLabel.text = [A3DateHelper dateStringFromDate:repeatDate
                                                           withFormat:[[A3DaysCounterModelManager sharedManager] dateFormatForAddEditIsAllDays:[item.isAllDay boolValue]]];
                }
                else {
                    dateLabel.text = [A3DateHelper dateStringFromDate:startDate
                                                           withFormat:[[A3DaysCounterModelManager sharedManager] dateFormatForAddEditIsAllDays:[item.isAllDay boolValue]]];
                }
                
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
    FNLOG(@"");
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
                                                toDate:[item startDate]
                                              isAllDay:[item.isAllDay boolValue]];
    }
    else {
        NSDate *nextRepeatStartDate = [[A3DaysCounterModelManager sharedManager] nextDateWithRepeatOption:[item.repeatType integerValue]
                                                                                                firstDate:item.startDate
                                                                                                 fromDate:today];
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
                                          toDate:[item startDate]
                                        isAllDay:[item.isAllDay boolValue]];
    }
    else {
        nextRepeatStartDate = [[A3DaysCounterModelManager sharedManager] nextDateWithRepeatOption:[item.repeatType integerValue]
                                                                                        firstDate:item.startDate
                                                                                         fromDate:today];
        daysGap = [A3DateHelper diffDaysFromDate:today
                                          toDate:nextRepeatStartDate
                                        isAllDay:[item.isAllDay boolValue]];
    }

    daysGap = labs(daysGap);
    result = [NSString stringWithFormat:@"%ld day%@", (long)daysGap, daysGap > 1 ? @"s" : @""];
    return result;
}

- (void)showImageViewOfCell:(UITableViewCell *)cell withImage:(UIImage *)image {
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:13];
    if (image) {
        imageView.image = [A3DaysCounterModelManager circularScaleNCrop:image rect:CGRectMake(0, 0, 32.0, 32.0)];
        
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
    
    [self loadEventDatas];
    [self setupSegmentSortArrow];
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
    viewCtrl.calendarId = _calendarItem.calendarId;

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
