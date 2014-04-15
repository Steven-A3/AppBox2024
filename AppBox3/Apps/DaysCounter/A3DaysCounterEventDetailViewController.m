//
//  A3DaysCounterEventDetailViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterEventDetailViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "A3DateHelper.h"
#import "DaysCounterCalendar.h"
#import "DaysCounterEvent.h"
#import "DaysCounterEventLocation.h"
#import "FSVenue.h"
#import "A3DaysCounterEventDetailLocationViewController.h"
#import "A3DaysCounterAddEventViewController.h"
#import "NSDate+LunarConverter.h"
#import "A3DaysCounterEventInfoCell.h"
#import "SFKImage.h"

@interface A3DaysCounterEventDetailViewController ()
@property (strong, nonatomic) NSMutableArray *itemArray;
@property (strong, nonatomic) UIPopoverController *popoverVC;
@property (strong, nonatomic) NSString *initialCalendarID;
@property (strong, nonatomic) UIView *topWhitePaddingView;

- (void)editAction:(id)sender;
- (void)constructItemsFromEvent:(DaysCounterEvent*)event;
@end

@implementation A3DaysCounterEventDetailViewController

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
    
    self.title = @"Event Details";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction:)];
    [self.navigationController setToolbarHidden:YES];
    [self makeBackButtonEmptyArrow];
    [self registerContentSizeCategoryDidChangeNotification];
    
    self.tableView.separatorInset = UIEdgeInsetsMake(0, (IS_IPHONE ? 15.0 : 28.0), 0, 0);
    self.initialCalendarID = _eventItem.calendarId;
    
    [self setupTopWhitePaddingView];
}

- (void)setupTopWhitePaddingView
{
    _topWhitePaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.0)];
    _topWhitePaddingView.backgroundColor = [UIColor whiteColor];
    _topWhitePaddingView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    [self.tableView addSubview:_topWhitePaddingView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if ( [_eventItem.eventId length] > 0 ) {
        [self constructItemsFromEvent:_eventItem];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    if ( ![self.initialCalendarID isEqualToString:_eventItem.calendarId] ) {
        if ( self.delegate && [self.delegate respondsToSelector:@selector(didChangedCalendarEventDetailViewController:)]) {
            [self.delegate didChangedCalendarEventDetailViewController:self];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    self.itemArray = nil;
}

- (void)contentSizeDidChange:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (void)constructItemsFromEvent:(DaysCounterEvent*)event
{
    self.itemArray = [NSMutableArray array];
    [_itemArray addObject:@{ EventRowTitle : @"", EventRowType : @(EventCellType_Title)}];
    if ( event.alertDatetime ) {
        [_itemArray addObject:@{ EventRowTitle : @"Alert", EventRowType : @(EventCellType_Alert)}];
    }
    if ( [event.calendarId length] ) {
        [_itemArray addObject:@{ EventRowTitle : @"Calendar", EventRowType : @(EventCellType_Calendar)}];
    }
    if ( event.durationOption ) {
        [_itemArray addObject:@{ EventRowTitle : @"Duration Option", EventRowType : @(EventCellType_DurationOption)}];
    }
    [_itemArray addObject:@{ EventRowTitle : @"Location", EventRowType : @(EventCellType_Location)}];
    
    if ( [event.notes length] > 0 ) {
        [_itemArray addObject:@{ EventRowTitle : @"Notes", EventRowType : @(EventCellType_Notes)}];
    }
    [_itemArray addObject:@{ EventRowTitle : @"Share Event", EventRowType : @(EventCellType_Share)}];
    [_itemArray addObject:@{ EventRowTitle : @"", EventRowType : @(EventCellType_Favorites)}];
    [self.tableView reloadData];
}

#pragma mark - cell
- (UITableViewCell*)createCellWithType:(NSInteger)cellType cellIdentifier:(NSString*)cellID
{
    UITableViewCell *cell = nil;

    switch (cellType) {
        case EventCellType_Title:
        {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterAddEventEventInfoCell" owner:nil options:nil] lastObject];
            [self initializeEventInfoCell:(A3DaysCounterEventInfoCell *)cell];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
        case EventCellType_Alert:
        case EventCellType_DurationOption:
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:17.0];
            cell.detailTextLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
        case EventCellType_Calendar:
        {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterAddEventCalendarInfoCell" owner:nil options:nil] lastObject];
            UIImageView *imageView = (UIImageView*)[cell viewWithTag:11];
            imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
        case EventCellType_Location:
        {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterAddEventDefaultCell" owner:nil options:nil] lastObject];
            UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
            textLabel.font = [UIFont systemFontOfSize:17];
            textLabel.textColor = [UIColor colorWithRed:159/255.0 green:159/255.0 blue:159/255.0 alpha:1.0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
        case EventCellType_Notes:
        {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterAddEventNotesDisplayCell" owner:nil options:nil] lastObject];
            UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
            textLabel.font = [UIFont systemFontOfSize:17];
            textLabel.textColor = [UIColor colorWithRed:159/255.0 green:159/255.0 blue:159/255.0 alpha:1.0];
            textLabel.numberOfLines = 0;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
        case EventCellType_Share:
        case EventCellType_Favorites:
        {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterAddEventDefaultCell" owner:nil options:nil] lastObject];
            UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
            textLabel.textColor = [UIColor colorWithRed:0.0 green:122/255.0 blue:1.0 alpha:1.0];
        }
            break;
    }
    
    if ( cell && cellType != EventCellType_DateInput) {
        UIView *leftView = [cell viewWithTag:10];
        for (NSLayoutConstraint *layout in cell.contentView.constraints ) {
            if ( layout.firstAttribute == NSLayoutAttributeLeading && layout.firstItem == leftView ) {
                layout.constant = (IS_IPHONE ? 15.0 : 28.0);
                break;
            }
        }
    }
    
    return cell;
}


- (void)updateTableViewCell:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath
{
    NSDictionary *itemDict = [_itemArray objectAtIndex:indexPath.row];
    NSInteger cellType = [[itemDict objectForKey:EventRowType] integerValue];
    switch (cellType) {
        case EventCellType_Title:
        {
            [self updateEventInfoCell:(A3DaysCounterEventInfoCell *)cell withInfo:_eventItem];
        }
            break;
        case EventCellType_Alert:
        {
            cell.textLabel.text = [itemDict objectForKey:EventRowTitle];
            cell.detailTextLabel.text = [[A3DaysCounterModelManager sharedManager] alertDateStringFromDate:_eventItem.startDate
                                                                                            alertDate:_eventItem.alertDatetime];
        }
            break;
        case EventCellType_DurationOption:
        {
            cell.textLabel.text = [itemDict objectForKey:EventRowTitle];
            cell.detailTextLabel.text = [[A3DaysCounterModelManager sharedManager] durationOptionStringFromValue:[_eventItem.durationOption integerValue]];
        }
            break;
        case EventCellType_Calendar:
        {
            UILabel *nameLabel = (UILabel*)[cell viewWithTag:12];
            UIImageView *colorImageView = (UIImageView*)[cell viewWithTag:11];
            
            DaysCounterCalendar *calendar = _eventItem.calendar;
            if ( calendar ) {
                nameLabel.text = calendar.calendarName;
                colorImageView.tintColor = [calendar color];
            }
            else {
                nameLabel.text = @"";
            }
            colorImageView.hidden = ([nameLabel.text length] < 1 );
        }
            break;
        case EventCellType_Location:
        {
            UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
            DaysCounterEventLocation *location = _eventItem.location;
            if ( location ) {
                FSVenue *venue = [[FSVenue alloc] init];
                venue.location.country = location.country;
                venue.location.state = location.state;
                venue.location.city = location.city;
                venue.location.address = location.address;
                NSString *address = [[A3DaysCounterModelManager sharedManager] addressFromVenue:venue isDetail:NO];
                textLabel.text = ([location.locationName length] > 0 ? location.locationName : address);
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else {
                textLabel.text = @"No location";
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
            break;
        case EventCellType_Notes:
        {
            UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
            textLabel.text = _eventItem.notes;
        }
            break;
        case EventCellType_Share:
        {
            UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
            textLabel.text = @"Share Event";
            textLabel.textColor = [UIColor colorWithRed:0.0 green:122/255.0 blue:1.0 alpha:1.0];
        }
            break;
        case EventCellType_Favorites:
        {
            UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
            textLabel.text = ([_eventItem.isFavorite boolValue] ? @"Remove from Favorites" : @"Add to Favorites");
            textLabel.textColor = [UIColor colorWithRed:0.0 green:122/255.0 blue:1.0 alpha:1.0];
        }
            break;
    }
}

- (void)updateEventInfoCell:(A3DaysCounterEventInfoCell *)cell withInfo:(DaysCounterEvent*)info
{
    if ( IS_IPHONE ) {
        cell.eventTitleLabel.font = [UIFont systemFontOfSize:17.0];
    }
    else {
        cell.eventTitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    }
    
    if ( [info.imageFilename length] > 0 ) {
        cell.eventPhotoImageView.image = [A3DaysCounterModelManager circularScaleNCrop:[A3DaysCounterModelManager photoThumbnailFromFilename:info.imageFilename]
                                                                                  rect:CGRectMake(0, 0, 65, 65)];
        cell.titleLeftSpaceConst.constant = 8;
    }
    else {
        cell.eventPhotoImageView.image = nil;
        cell.titleLeftSpaceConst.constant = 0;
    }

    cell.eventTitleLabel.text = info.eventName;
    cell.favoriteStarImageView.hidden = ![info.isFavorite boolValue];
    
    if ( [info.repeatType integerValue] == RepeatType_Never ) {
        [self updateEventInfoCellToNoRepeatEventInfo:info cell:cell];
    }
    else {
        [self updateEventInfoCellToRepeatEventInfo:info cell:cell];
    }
}

- (void)updateEventInfoCellToNoRepeatEventInfo:(DaysCounterEvent*)info cell:(A3DaysCounterEventInfoCell *)cell
{
    NSDate *now = [NSDate date];
    NSInteger daysGap;
    daysGap = [A3DateHelper diffDaysFromDate:now
                                       toDate:info.startDate
                                     isAllDay:[info.isAllDay boolValue]];

    BOOL isSince = NO;
    if ( daysGap <= 0 ) {
        isSince = YES;
    }
    NSString *dateText1 = @"";
    NSString *dateText2 = @"";
    
    BOOL isLunar = [info.isLunar boolValue];
    NSDate *startDate = info.startDate;
    NSDate *endDate = info.endDate;
    
    if ( isLunar ) {
        NSDateComponents *dateComp = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:startDate];
        BOOL isResultLeapMonth = NO;
		NSDateComponents *resultComponents = [NSDate lunarCalcWithComponents:dateComp
                                                            gregorianToLunar:NO
                                                                   leapMonth:NO
                                                                      korean:[A3DateHelper isCurrentLocaleIsKorea]
                                                             resultLeapMonth:&isResultLeapMonth];
        NSDate *convertDate = [[NSCalendar currentCalendar] dateFromComponents:resultComponents];
        
        startDate = convertDate;
        
        if ( endDate ) {
            dateComp = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:endDate];
            dateComp = [NSDate lunarCalcWithComponents:dateComp
                                      gregorianToLunar:NO
                                             leapMonth:NO
                                                korean:[A3DateHelper isCurrentLocaleIsKorea]
                                       resultLeapMonth:&isResultLeapMonth];
			convertDate = [[NSCalendar currentCalendar] dateFromComponents:dateComp];
            endDate = convertDate;
        }
    }
    
    if ( [info.isPeriod boolValue] ) {
        dateText1 = [NSString stringWithFormat:@"from %@", [A3DateHelper dateStringFromDate:startDate
                                                                                 withFormat:[[A3DaysCounterModelManager sharedManager] dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
        dateText2 = [NSString stringWithFormat:@"to %@", [A3DateHelper dateStringFromDate:endDate
                                                                               withFormat:[[A3DaysCounterModelManager sharedManager] dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
    }
    else {
        dateText1 = [NSString stringWithFormat:@"%@", [A3DateHelper dateStringFromDate:startDate
                                                                            withFormat:[[A3DaysCounterModelManager sharedManager] dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
    }
    // AdjustLayout
    [self adjustLayoutForEventInfoCell:cell eventInfo:info];
    
    // Set Data
    [self updateEventInfoCell:cell
                      isSince:isSince
                     daysText:[[A3DaysCounterModelManager sharedManager] stringOfDurationOption:[info.durationOption integerValue]
                                                                                       fromDate:now
                                                                                         toDate:startDate
                                                                                       isAllDay:[info.isAllDay boolValue]
                                                                                   isShortStyle:NO]
                    dateText1:dateText1
                    dateText2:dateText2
                      isLunar:[info.isLunar boolValue]
                      isTypeA:YES
                    eventInfo:info];
}

- (void)updateEventInfoCellToRepeatEventInfo:(DaysCounterEvent*)info cell:(A3DaysCounterEventInfoCell *)cell
{
    NSDate *now = [NSDate date];
    
    BOOL isLunar = [info.isLunar boolValue];
    NSDate *startDate = info.startDate;
    
    if ( isLunar ) {
        NSDateComponents *dateComp = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:startDate];
        BOOL isResultLeapMonth = NO;
		dateComp = [NSDate lunarCalcWithComponents:dateComp gregorianToLunar:NO leapMonth:NO korean:[A3DateHelper isCurrentLocaleIsKorea] resultLeapMonth:&isResultLeapMonth];
        NSDate *convertDate = [[NSCalendar currentCalendar] dateFromComponents:dateComp];
        startDate = convertDate;
    }
    
    NSDate *nextDate = [[A3DaysCounterModelManager sharedManager] nextDateWithRepeatOption:[info.repeatType integerValue] firstDate:startDate fromDate:now];
    
    // AdjustLayout
    [self adjustLayoutForEventInfoCell:cell eventInfo:info];
    // Set Data (until or since or today/now)
    [self updateEventInfoCell:cell
                      isSince:NO
                     daysText:[[A3DaysCounterModelManager sharedManager] stringOfDurationOption:[info.durationOption integerValue]
                                                                                       fromDate:now
                                                                                         toDate:nextDate
                                                                                       isAllDay:[info.isAllDay boolValue]
                                                                                   isShortStyle:NO]
                    dateText1:[NSString stringWithFormat:@"%@",[A3DateHelper dateStringFromDate:nextDate
                                                                                     withFormat:[[A3DaysCounterModelManager sharedManager] dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]]
     
                    dateText2:[NSString stringWithFormat:@"repeats %@",[[A3DaysCounterModelManager sharedManager] repeatTypeStringForDetailValue:[info.repeatType integerValue]]]
                      isLunar:[info.isLunar boolValue]
                      isTypeA:YES
                    eventInfo:info];
    
    // Set Data (since)
    BOOL hasSince;
    if ([_eventItem.isAllDay boolValue]) {
        hasSince = [A3DateHelper diffDaysFromDate:[NSDate date] toDate:_eventItem.startDate isAllDay:[_eventItem.isAllDay boolValue]] < 0 ? YES : NO;
    }
    else {
        hasSince = [[NSDate date] timeIntervalSince1970] > [_eventItem.startDate timeIntervalSince1970] ? YES : NO;
    }
    if (hasSince) {
        [self updateEventInfoCell:cell
                          isSince:YES
                         daysText:[[A3DaysCounterModelManager sharedManager] stringOfDurationOption:[info.durationOption integerValue]
                                                                                           fromDate:startDate
                                                                                             toDate:now
                                                                                           isAllDay:[info.isAllDay boolValue]
                                                                                       isShortStyle:NO]
                        dateText1:[NSString stringWithFormat:@"%@",[A3DateHelper dateStringFromDate:info.startDate
                                                                                         withFormat:[[A3DaysCounterModelManager sharedManager] dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]]
                        dateText2:@"first date"
                          isLunar:[info.isLunar boolValue]
                          isTypeA:NO
                        eventInfo:info];
    }
}

- (void)adjustLayoutForEventInfoCell:(A3DaysCounterEventInfoCell *)cell eventInfo:(DaysCounterEvent *)eventInfo
{
    BOOL hasRepeat = [_eventItem.repeatType integerValue] != RepeatType_Never ? YES : NO;
    BOOL hasEndDate = [_eventItem.isPeriod boolValue];
    BOOL hasSince;
    if ([_eventItem.isAllDay boolValue]) {
        hasSince = [A3DateHelper diffDaysFromDate:[NSDate date] toDate:_eventItem.startDate isAllDay:[_eventItem.isAllDay boolValue]] < 0 ? YES : NO;
    }
    else {
        hasSince = [[NSDate date] timeIntervalSince1970] > [_eventItem.startDate timeIntervalSince1970] ? YES : NO;
    }
    
    CGFloat rowHeight;
    if (!hasRepeat) {
        if (hasEndDate) {
            //* case 2. 162pt  (start 안 지남, end있음)
            rowHeight = IS_RETINA ? 162.5 : 163;
            cell.untilRoundBottomConst.constant = rowHeight - 61;
        }
        else {
            //* case 1. 현재의 142pt (start 안 지나거나 지났고, end없음, 다음 start없음)
            rowHeight = IS_RETINA ? 142.5 : 143;
            cell.untilRoundBottomConst.constant = rowHeight - 61;
        }
        
        cell.sinceRoundLabel.hidden = YES;
        cell.durationBLabel.hidden = YES;
        cell.startEnd1BLabel.hidden = YES;
        cell.startEnd2BLabel.hidden = YES;
        cell.repeatBLabel.hidden = YES;
        cell.lunar1BImageView.hidden = YES;
    }
    else {
        cell.sinceRoundLabel.hidden = hasSince ? NO : YES;
        cell.durationBLabel.hidden = hasSince ? NO : YES;
        cell.startEnd1BLabel.hidden = hasSince ? NO : YES;
        cell.startEnd2BLabel.hidden = hasSince ? NO : YES;
        cell.repeatBLabel.hidden = hasSince ? NO : YES;
        cell.lunar1BImageView.hidden = hasSince ? NO : YES;
        
        if (hasEndDate) {
            if (hasSince) {
                //* case 4. 276pt  (start 지남, end있음, 다음 start있음)
                rowHeight = IS_RETINA ? 276.5 : 277;
                cell.untilRoundBottomConst.constant = rowHeight - 61;
                cell.sinceRoundBottomConst.constant = rowHeight - 185;
            }
            else {
                //* case 2. 162pt  (start 안 지남, end있음)
                rowHeight = IS_RETINA ? 162.5 : 163;
                cell.untilRoundBottomConst.constant = rowHeight - 61;
                cell.sinceRoundBottomConst.constant = rowHeight - 155;
            }
        }
        else {
            if (hasSince) {
                //* case 3. 현재의 236pt  (start 지남, end없음)
                rowHeight = IS_RETINA ? 236.5 : 237;
                cell.untilRoundBottomConst.constant = rowHeight - 61;
                cell.sinceRoundBottomConst.constant = rowHeight - 155;
            }
            else {
                //* case 1. 현재의 142pt (start 안 지나거나 지났고, end없음, 다음 start없음)
                rowHeight = IS_RETINA ? 142.5 : 143;
                cell.untilRoundBottomConst.constant = rowHeight - 61;
                cell.sinceRoundBottomConst.constant = rowHeight - 155;
            }
        }
    }
    cell.titleBottomSpaceConst.constant = rowHeight - 31;
}

- (void)updateEventInfoCell:(A3DaysCounterEventInfoCell *)cell isSince:(BOOL)isSince daysText:(NSString*)daysText dateText1:(NSString*)dateText1 dateText2:(NSString*)dateText2 isLunar:(BOOL)isLunasr isTypeA:(BOOL)isTypeA eventInfo:(DaysCounterEvent*)info
{
    UILabel *markLabel;
    UILabel *daysLabel;
    UILabel *dateLabel1;
    UILabel *dateLabel2;
    UILabel *dateLabel3;
    UIImageView *lunarImageView;
    
    if (isTypeA) {
        markLabel = cell.untilSinceRoundLabel;
        daysLabel = cell.durationALabel;
        dateLabel1 = cell.startEnd1ALabel;
        dateLabel2 = cell.startEnd2ALabel;
        dateLabel3 = cell.repeatALabel;
        lunarImageView = cell.lunar1AImageView;
    }
    else {
        markLabel = cell.sinceRoundLabel;
        daysLabel = cell.durationBLabel;
        dateLabel1 = cell.startEnd1BLabel;
        dateLabel2 = cell.startEnd2BLabel;
        dateLabel3 = cell.repeatBLabel;
        lunarImageView = cell.lunar1BImageView;
    }
    
    if ( IS_IPHONE ) {
        markLabel.font = [UIFont systemFontOfSize:11.0];
        daysLabel.font = [UIFont systemFontOfSize:15.0];
        dateLabel1.font = [UIFont systemFontOfSize:13.0];
        dateLabel2.font = [UIFont systemFontOfSize:13.0];
    }
    else {
        markLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
        daysLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        dateLabel1.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        dateLabel2.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        dateLabel3.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    }
    
    NSDate *now = [NSDate date];
    
    BOOL isLunar = [info.isLunar boolValue];
    BOOL hasRepeat = [_eventItem.repeatType integerValue] != RepeatType_Never ? YES : NO;
    BOOL hasEndDate = [_eventItem.isPeriod boolValue];
    BOOL hasSince;
    if ([_eventItem.isAllDay boolValue]) {
        hasSince = [A3DateHelper diffDaysFromDate:now toDate:_eventItem.startDate isAllDay:[_eventItem.isAllDay boolValue]] < 0 ? YES : NO;
    }
    else {
        hasSince = [now timeIntervalSince1970] > [_eventItem.startDate timeIntervalSince1970] ? YES : NO;
    }
    
    lunarImageView.hidden = !isLunar;
    
    if (!hasRepeat) {
        NSDate *startDate = info.startDate;
        NSDate *endDate = info.endDate;

        cell.untilSinceRoundLabel.text = [A3DateHelper untilSinceStringByFromDate:now
                                                                           toDate:[info startDate]
                                                                     allDayOption:[info.isAllDay boolValue]
                                                                           repeat:hasRepeat];
        cell.untilRoundWidthConst.constant = 42;
        
        if ( isLunar ) {
            NSDateComponents *dateComp = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:startDate];
            BOOL isResultLeapMonth = NO;
            NSDateComponents *resultComponents = [NSDate lunarCalcWithComponents:dateComp
                                                                gregorianToLunar:NO
                                                                       leapMonth:NO
                                                                          korean:[A3DateHelper isCurrentLocaleIsKorea]
                                                                 resultLeapMonth:&isResultLeapMonth];
            NSDate *convertDate = [[NSCalendar currentCalendar] dateFromComponents:resultComponents];
            
            startDate = convertDate;
            
            if ( endDate ) {
                dateComp = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:endDate];
                dateComp = [NSDate lunarCalcWithComponents:dateComp
                                          gregorianToLunar:NO
                                                 leapMonth:NO
                                                    korean:[A3DateHelper isCurrentLocaleIsKorea]
                                           resultLeapMonth:&isResultLeapMonth];
                convertDate = [[NSCalendar currentCalendar] dateFromComponents:dateComp];
                endDate = convertDate;
            }
        }

        if ([markLabel.text isEqualToString:@"today"] || [markLabel.text isEqualToString:@"Now"]) {
            daysLabel.text = @"";
            
            dateLabel1.text = [NSString stringWithFormat:@"%@", [A3DateHelper dateStringFromDate:[NSDate date]
                                                                                      withFormat:[[A3DaysCounterModelManager sharedManager] dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
            dateLabel2.text = [NSString stringWithFormat:@"repeats %@", [[A3DaysCounterModelManager sharedManager] repeatTypeStringForDetailValue:[info.repeatType integerValue]]];
            goto EXIT_FUCTION;
        }
        else {
            daysLabel.text = [[A3DaysCounterModelManager sharedManager] stringOfDurationOption:[info.durationOption integerValue]
                                                                                      fromDate:now
                                                                                        toDate:startDate
                                                                                      isAllDay:[info.isAllDay boolValue]
                                                                                  isShortStyle:NO];
        }
        
        if (hasEndDate) {
            //* case 2. 162pt  (start 안 지남, end있음)
            //            * case 2. 162pt
            //            Title
            //            until 계산값
            //            from 선택날짜/시간
            //            to 선택날짜/시간
            //            repeats 옵션
            dateLabel1.text = [NSString stringWithFormat:@"from %@", [A3DateHelper dateStringFromDate:startDate
                                                                                     withFormat:[[A3DaysCounterModelManager sharedManager] dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
            dateLabel2.text = [NSString stringWithFormat:@"to %@", [A3DateHelper dateStringFromDate:endDate
                                                                                     withFormat:[[A3DaysCounterModelManager sharedManager] dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
            dateLabel3.text = [NSString stringWithFormat:@"repeats %@", [[A3DaysCounterModelManager sharedManager] repeatTypeStringForDetailValue:[info.repeatType integerValue]]];
        }
        else {
            //* case 1. 현재의 142pt (start 안 지나거나 지났고, end없음, 다음 start없음)
            //            * case 1. 현재의 142pt
            //            Title
            //            until(since) 계산값
            //            date 선택날짜/시간 (since 일 경우 starts-ends on. from)
            //            (until일 경우 - repeats 옵션) (since 일 경우 to)
            dateLabel1.text = [NSString stringWithFormat:@"%@", [A3DateHelper dateStringFromDate:startDate
                                                                                      withFormat:[[A3DaysCounterModelManager sharedManager] dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
            dateLabel2.text = [NSString stringWithFormat:@"repeats %@", [[A3DaysCounterModelManager sharedManager] repeatTypeStringForDetailValue:[info.repeatType integerValue]]];
            dateLabel3.text = @"";
        }
    }

    else {
        // Has Repeat
        NSDate *startDate = info.startDate;
        
        if ( isLunar ) {
            NSDateComponents *dateComp = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:startDate];
            BOOL isResultLeapMonth = NO;
            dateComp = [NSDate lunarCalcWithComponents:dateComp gregorianToLunar:NO leapMonth:NO korean:[A3DateHelper isCurrentLocaleIsKorea] resultLeapMonth:&isResultLeapMonth];
            NSDate *convertDate = [[NSCalendar currentCalendar] dateFromComponents:dateComp];
            startDate = convertDate;
        }
        
        NSDate *nextDate = [[A3DaysCounterModelManager sharedManager] nextDateWithRepeatOption:[info.repeatType integerValue] firstDate:startDate fromDate:now];
        
        // until/since & durationOption string
        cell.untilSinceRoundLabel.text = [A3DateHelper untilSinceStringByFromDate:now
                                                                           toDate:nextDate
                                                                     allDayOption:[info.isAllDay boolValue]
                                                                           repeat:hasRepeat];
        cell.untilRoundWidthConst.constant = 42;
        
        if (isTypeA) {
            if ([markLabel.text isEqualToString:@"today"] || [markLabel.text isEqualToString:@"Now"]) {
                daysLabel.text = @"";
                dateLabel1.text = [NSString stringWithFormat:@"%@", [A3DateHelper dateStringFromDate:[NSDate date]
                                                                                          withFormat:[[A3DaysCounterModelManager sharedManager] dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
                dateLabel2.text = [NSString stringWithFormat:@"repeats %@",[[A3DaysCounterModelManager sharedManager] repeatTypeStringForDetailValue:[info.repeatType integerValue]]];
                goto EXIT_FUCTION;
            }
            else {
                daysLabel.text = [[A3DaysCounterModelManager sharedManager] stringOfDurationOption:[info.durationOption integerValue]
                                                                                          fromDate:now
                                                                                            toDate:hasSince ? nextDate : startDate
                                                                                          isAllDay:[info.isAllDay boolValue]
                                                                                      isShortStyle:NO];
            }
        }
        else {
            daysLabel.text = [[A3DaysCounterModelManager sharedManager] stringOfDurationOption:[info.durationOption integerValue]
                                                                                      fromDate:startDate
                                                                                        toDate:now
                                                                                      isAllDay:[info.isAllDay boolValue]
                                                                                  isShortStyle:NO];
        }
        
        // from / to string / repeat
        if (hasEndDate) {
            if (hasSince) {
                //* case 4. 276pt  (start 지남, end있음, 다음 start있음)
                //            * case 4. 276pt
                //            Title
                //            until 계산값
                //            from 계산된 날짜/시간
                //            to 계산된 날짜/시간
                //            repeats 옵션
                //
                //            since 계산값
                //            from 선택날짜/시간
                //            to 선택날짜/시간
                //            first date
                if (isTypeA) {
                    dateLabel1.text = [NSString stringWithFormat:@"from %@", [A3DateHelper dateStringFromDate:nextDate
                                                                                                   withFormat:[[A3DaysCounterModelManager sharedManager] dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
                    
                    NSTimeInterval diff = [info.endDate timeIntervalSince1970] - [info.startDate timeIntervalSince1970];
                    NSDate *nextEndDate = [NSDate dateWithTimeInterval:diff sinceDate:nextDate];
                    dateLabel2.text = [NSString stringWithFormat:@"to %@", [A3DateHelper dateStringFromDate:nextEndDate
                                                                                                   withFormat:[[A3DaysCounterModelManager sharedManager] dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
                    dateLabel3.text = [NSString stringWithFormat:@"repeats %@",[[A3DaysCounterModelManager sharedManager] repeatTypeStringForDetailValue:[info.repeatType integerValue]]];
                }
                else {
                    dateLabel1.text = [NSString stringWithFormat:@"from %@", [A3DateHelper dateStringFromDate:info.startDate
                                                                                                   withFormat:[[A3DaysCounterModelManager sharedManager] dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
                    dateLabel2.text = [NSString stringWithFormat:@"to %@", [A3DateHelper dateStringFromDate:info.endDate
                                                                                                   withFormat:[[A3DaysCounterModelManager sharedManager] dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
                    dateLabel3.text = [NSString stringWithFormat:@"first date"];
                }
            }
            else {
                //* case 2. 162pt  (start 안 지남, end있음)
                //            * case 2. 162pt
                //            Title
                //            until 계산값
                //            from 선택날짜/시간
                //            to 선택날짜/시간
                //            repeats 옵션
                
//                daysLabel.text = daysText;
                dateLabel1.text = [NSString stringWithFormat:@"from %@", [A3DateHelper dateStringFromDate:info.startDate
                                                                                               withFormat:[[A3DaysCounterModelManager sharedManager] dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
                dateLabel2.text = [NSString stringWithFormat:@"to %@", [A3DateHelper dateStringFromDate:info.endDate
                                                                                             withFormat:[[A3DaysCounterModelManager sharedManager] dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
                dateLabel3.text = [NSString stringWithFormat:@"repeats %@", [[A3DaysCounterModelManager sharedManager] repeatTypeStringForDetailValue:[info.repeatType integerValue]]];
            }
        }
        else {  // ! hasEnd
            if (hasSince) {
                //* case 3. 현재의 236pt  (start 지남, end없음)
                //            * case 3. 현재의 236pt
                //            Title
                //            until 계산값
                //            date 계산된 날짜/시간
                //            repeats 옵션
                //
                //            since 계산값
                //            date 선택날짜/시간
                //            first date
                
                dateLabel1.text = dateText1;
                if (isTypeA) {
                    dateLabel1.text = [NSString stringWithFormat:@"from %@", [A3DateHelper dateStringFromDate:nextDate
                                                                                                   withFormat:[[A3DaysCounterModelManager sharedManager] dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
                    dateLabel2.text = [NSString stringWithFormat:@"repeats %@", [[A3DaysCounterModelManager sharedManager] repeatTypeStringForDetailValue:[info.repeatType integerValue]]];
                    dateLabel3.text = @"";
                }
                else {
                    dateLabel1.text = [NSString stringWithFormat:@"%@", [A3DateHelper dateStringFromDate:info.startDate
                                                                                                   withFormat:[[A3DaysCounterModelManager sharedManager] dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
                    dateLabel2.text = [NSString stringWithFormat:@"first date"];
                    dateLabel3.text = @"";
                }
            }
            else {
                //* case 1. 현재의 142pt (start 안 지나거나 지났고, end없음, 다음 start없음)
                //            * case 1. 현재의 142pt
                //            Title
                //            until(since) 계산값
                //            date 선택날짜/시간 (since 일 경우 starts-ends on. from)
                //            (until일 경우 - repeats 옵션) (since 일 경우 to)
                //* case 1, repeat only until
                dateLabel1.text = [NSString stringWithFormat:@"from %@", [A3DateHelper dateStringFromDate:info.startDate
                                                                                               withFormat:[[A3DaysCounterModelManager sharedManager] dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
                dateLabel2.text = [NSString stringWithFormat:@"repeats %@", [[A3DaysCounterModelManager sharedManager] repeatTypeStringForDetailValue:[info.repeatType integerValue]]];
                dateLabel3.text = @"";
            }
        }
    }
    
EXIT_FUCTION:
    
    if ([markLabel.text isEqualToString:@"since"]) {
        markLabel.textColor = [UIColor colorWithRed:1.0 green:45.0/255.0 blue:85.0/255.0 alpha:1.0];
    }
    else {
        markLabel.textColor = [UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:100.0/255.0 alpha:1.0];
    }
    
    markLabel.layer.borderColor = [markLabel.textColor CGColor];
    markLabel.layer.borderWidth = IS_RETINA ? 0.5 : 1.0;
    markLabel.layer.masksToBounds = YES;
    markLabel.layer.cornerRadius = 9.0;
}

- (void)initializeEventInfoCell:(A3DaysCounterEventInfoCell *)eventInfoCell
{
    eventInfoCell.untilSinceRoundLabel.layer.masksToBounds = YES;
    eventInfoCell.untilSinceRoundLabel.layer.borderColor = [eventInfoCell.untilSinceRoundLabel.textColor CGColor];
    eventInfoCell.untilSinceRoundLabel.layer.borderWidth = IS_RETINA ? 0.5 : 1.0;
    eventInfoCell.untilSinceRoundLabel.layer.cornerRadius = 9.0;
    
    eventInfoCell.sinceRoundLabel.layer.masksToBounds = YES;
    eventInfoCell.sinceRoundLabel.layer.borderColor = [eventInfoCell.sinceRoundLabel.textColor CGColor];
    eventInfoCell.sinceRoundLabel.layer.borderWidth = IS_RETINA ? 0.5 : 1.0;
    eventInfoCell.sinceRoundLabel.layer.cornerRadius = 9.0;


    [SFKImage setDefaultFont:[UIFont fontWithName:@"appbox" size:24.0]];
	[SFKImage setDefaultColor:[UIColor colorWithRed:159/255.0 green:159/255.0 blue:159/255.0 alpha:1.0]];
    eventInfoCell.lunar1AImageView.image = [SFKImage imageNamed:@"f"];
    eventInfoCell.lunar1BImageView.image = [SFKImage imageNamed:@"f"];
    
    eventInfoCell.durationALabel.text = @"";
    eventInfoCell.startEnd1ALabel.text = @"";
    eventInfoCell.startEnd2ALabel.text = @"";
    eventInfoCell.repeatALabel.text = @"";
    
    eventInfoCell.durationBLabel.text = @"";
    eventInfoCell.startEnd1BLabel.text = @"";
    eventInfoCell.startEnd2BLabel.text = @"";
    eventInfoCell.repeatBLabel.text = @"";
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( section == 1 ) {
        return 1;
    }
    return [_itemArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if ( indexPath.section == 0 ) {
        NSDictionary *itemDict = [_itemArray objectAtIndex:indexPath.row];
        NSInteger cellType = [[itemDict objectForKey:EventRowType] integerValue];
        NSArray *cellIDs = @[@"eventInfoCell",@"",@"",@"",@"",@"",@"",@"value1Cell",@"value1Cell",@"value1Cell",@"calendarInfoCell",@"value1Cell",@"value1Cell",@"multilineCell",@"",@"defaultCell",@"defalutCell"];
        
        NSString *CellIdentifier = [cellIDs objectAtIndex:cellType];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [self createCellWithType:cellType cellIdentifier:CellIdentifier];
        }
        
        [self updateTableViewCell:cell indexPath:indexPath];
    }
    else {
        NSString *cellID = @"normalCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if ( cell == nil ) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        
        cell.textLabel.text = @"Delete Event";
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        cell.textLabel.textColor = [UIColor colorWithRed:1.0 green:59/255.0 blue:48.0/255.0 alpha:1.0];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return cell;
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section == 0 ) {
        NSDictionary *itemDict = [_itemArray objectAtIndex:indexPath.row];
        NSInteger cellType = [[itemDict objectForKey:EventRowType] integerValue];
        if ( cellType != EventCellType_Title ) {
            return;
        }
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:10];
        NSLayoutConstraint *widthConst = nil;
        for (NSLayoutConstraint *layout in imageView.constraints) {
            if ( layout.firstAttribute == NSLayoutAttributeWidth && layout.firstItem == imageView ) {
                widthConst = layout;
                break;
            }
        }
        if ( widthConst ) {
            widthConst.constant = (imageView.image ? 65.0 : 0.0);
            [cell layoutIfNeeded];
        }
        return;
    }
    else {
        cell.textLabel.frame = CGRectMake(cell.textLabel.frame.origin.x, cell.textLabel.frame.origin.y, cell.contentView.frame.size.width, cell.textLabel.frame.size.height);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat retHeight = 44.0;
    
    if ( indexPath.section == 1 ) {
        return retHeight;
    }
    
    BOOL isiPadFullMode = NO;
    if (IS_IPAD && (_eventItem.location == nil && [_eventItem.imageFilename length] < 1)) {
        isiPadFullMode = YES;
    }

    NSDictionary *itemDict = [_itemArray objectAtIndex:indexPath.row];
    NSInteger cellType = [[itemDict objectForKey:EventRowType] integerValue];
    
    switch (cellType) {
        case EventCellType_Title:
        {
//            iPhone/iPad
//            * case 1. 현재의 142pt
//            Title
//            until(since) 계산값
//            date 선택날짜/시간 (since 일 경우 starts-ends on. from)
//            (until일 경우 - repeats 옵션) (since 일 경우 to)
//            
//            * case 2. 162pt
//            Title
//            until 계산값
//            from 선택날짜/시간
//            to 선택날짜/시간
//            repeats 옵션
//            
//            * case 3. 현재의 236pt
//            Title
//            until 계산값
//            date 계산된 날짜/시간
//            repeats 옵션
//            
//            since 계산값
//            date 선택날짜/시간
//            first date
//            
//            * case 4. 276pt
//            Title
//            until 계산값
//            from 계산된 날짜/시간
//            to 계산된 날짜/시간
//            repeats 옵션
//            
//            since 계산값
//            from 선택날짜/시간
//            to 선택날짜/시간
//            first date
            
            BOOL hasRepeat = [_eventItem.repeatType integerValue] != RepeatType_Never ? YES : NO;
            BOOL hasEndDate = [_eventItem.isPeriod boolValue];
            //BOOL hasSince = [A3DateHelper diffDaysFromDate:[NSDate date] toDate:_eventItem.startDate] < 0 ? YES : NO;
            BOOL hasSince;
            if ([_eventItem.isAllDay boolValue]) {
                hasSince = [A3DateHelper diffDaysFromDate:[NSDate date] toDate:_eventItem.startDate isAllDay:[_eventItem.isAllDay boolValue]] < 0 ? YES : NO;
            }
            else {
                hasSince = [[NSDate date] timeIntervalSince1970] > [_eventItem.startDate timeIntervalSince1970] ? YES : NO;
            }
            
            if (!hasRepeat) {
                if (hasEndDate) {
                    //* case 2. 162pt  (start 안 지남, end있음)
                    retHeight = IS_RETINA ? 162.5 : 163;
                }
                else {
                    //* case 1. 현재의 142pt (start 안 지나거나 지났고, end없음, 다음 start없음)
                    retHeight = IS_RETINA ? 142.5 : 143;
                }
//                if (hasEndDate) {
//                    if (hasSince) {
//                        //* case 1. 현재의 142pt (start 안 지나거나 지났고, end없음, 다음 start없음)
//                        retHeight = IS_RETINA ? 142.5 : 143;
//                    }
//                    else {
//                        FNLOG(@"non-case");
//                    }
//                }
//                else {
//                    if (hasSince) {
//                        //* case 1. 현재의 142pt (start 안 지나거나 지났고, end없음, 다음 start없음)
//                        retHeight = IS_RETINA ? 142.5 : 143;
//                    }
//                    else {
//                        FNLOG(@"non-case");
//                    }
//                }
            }
            else {
                if (hasEndDate) {
                    if (hasSince) {
                        //* case 4. 276pt  (start 지남, end있음, 다음 start있음)
                        retHeight = IS_RETINA ? 276.5 : 277;
                    }
                    else {
                        //* case 2. 162pt  (start 안 지남, end있음)
                        retHeight = IS_RETINA ? 162.5 : 163;
                    }
                }
                else {
                    if (hasSince) {
                        //* case 3. 현재의 236pt  (start 지남, end없음)
                        retHeight = IS_RETINA ? 236.5 : 237;
                    }
                    else {
                        //* case 1. 현재의 142pt (start 안 지나거나 지났고, end없음, 다음 start없음)
                        retHeight = IS_RETINA ? 142.5 : 143;
                    }
                }
            }

//            if ( [_eventItem.repeatType integerValue] == RepeatType_Never ) {
//                if (IS_RETINA) {
//                     retHeight = 142.5;
//                }
//                else {
//                    retHeight = 142.0;
//                }
//                if (IS_RETINA) {
//                    retHeight = (isiPadFullMode ? 106.5 : 142.5);
//                }
//                else {
//                    retHeight = (isiPadFullMode ? 106.0 : 142.0);
//                }
//            }
//            else {
//                NSDate *date = [NSDate date];
//                NSInteger diffDays = [A3DateHelper diffDaysFromDate:date toDate:_eventItem.startDate];
//                if ( diffDays < 0 ) {
//                    if (IS_RETINA) {
//                        retHeight = (isiPadFullMode ? 195.5 : 236.5);
//                    }
//                    else {
//                        retHeight = (isiPadFullMode ? 195.0 : 236.0);
//                    }
//                }
//                else {
//                    if (IS_RETINA) {
//                        retHeight = (isiPadFullMode ? 106.5 : 142.5);
//                    }
//                    else {
//                        retHeight = (isiPadFullMode ? 106.0 : 142.0);
//                    }
//                }
//            }
        }
            break;
            
        case EventCellType_Notes:
        {
            CGSize textSize = [_eventItem.notes sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17.0]}];
            retHeight = ceilf(textSize.height) + 11.0 + 30.0;
        }
            break;
            
        default:
        {
            if ( isiPadFullMode && ((cellType != EventCellType_Share) && (cellType != EventCellType_Favorites)) ) {
                retHeight = 74.0;
            }
        }
            break;
    }
    
    return retHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1 ) {
        return 35.0;
    }
    
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ( section == 1 ) {
        return 35.0;
    }
    
    return 0.01;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ( section == 1 ) {
        UIView *retView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 36.0)];
        retView.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0];\
        return retView;
    }
    
    return nil;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if ( section == 1 ) {
        UIView *retView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 36.0)];
        retView.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0];\
        return retView;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section == 1 ) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self deleteEventAction:nil];
        return;
    }
    NSDictionary *itemDict = [_itemArray objectAtIndex:indexPath.row];
    NSInteger cellType = [[itemDict objectForKey:EventRowType] integerValue];

    if ( cellType == EventCellType_Location && _eventItem.location ) {
        A3DaysCounterEventDetailLocationViewController *viewCtrl = [[A3DaysCounterEventDetailLocationViewController alloc] initWithNibName:@"A3DaysCounterEventDetailLocationViewController" bundle:nil];
        viewCtrl.location = _eventItem.location;
        [self.navigationController pushViewController:viewCtrl animated:YES];
    }
    else if ( cellType == EventCellType_Share ) {
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[_eventItem.eventName] applicationActivities:nil];
        if (IS_IPHONE) {
            [self presentViewController:activityController animated:YES completion:NULL];
        } else {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            self.popoverVC = [[UIPopoverController alloc] initWithContentViewController:activityController];
            self.popoverVC.delegate = self;
            [_popoverVC presentPopoverFromRect:CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height) inView:self.tableView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else if ( cellType == EventCellType_Favorites ) {
        _eventItem.isFavorite = [NSNumber numberWithBool:![_eventItem.isFavorite boolValue]];
        [_eventItem.managedObjectContext MR_saveToPersistentStoreAndWait];
        [self.tableView reloadData];
        if ( self.delegate && [self.delegate respondsToSelector:@selector(willChangeEventDetailViewController:)]) {
            [self.delegate willChangeEventDetailViewController:self];
        }
    }
}

#pragma mark TableView ScrollView
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_topWhitePaddingView) {
        if (scrollView.contentOffset.y < -scrollView.contentInset.top ) {
            CGRect rect = _topWhitePaddingView.frame;
            rect.origin.y = -(fabs(scrollView.contentOffset.y) - scrollView.contentInset.top);
            rect.size.height = fabs(scrollView.contentOffset.y) - scrollView.contentInset.top + (IS_RETINA ? 0.5 : 1.0);
            _topWhitePaddingView.frame = rect;
        } else {
            CGRect rect = _topWhitePaddingView.frame;
            rect.origin.y = 0.0;
            rect.size.height = 0.0;
            _topWhitePaddingView.frame = rect;
        }
    }
}

#pragma mark - UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popoverVC = nil;
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex == alertView.firstOtherButtonIndex ) {
        if ( self.delegate && [self.delegate respondsToSelector:@selector(willDeleteEvent:daysCounterEventDetailViewController:)]) {
            [self.delegate willDeleteEvent:self.eventItem daysCounterEventDetailViewController:self];
        }
        else {
            [[A3DaysCounterModelManager sharedManager] removeEvent:_eventItem];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex == actionSheet.destructiveButtonIndex ) {
        if ( self.delegate && [self.delegate respondsToSelector:@selector(willDeleteEvent:daysCounterEventDetailViewController:)]) {
            [self.delegate willDeleteEvent:self.eventItem daysCounterEventDetailViewController:self];
        }
        else {
            [[A3DaysCounterModelManager sharedManager] removeEvent:_eventItem];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - action method
- (void)editAction:(id)sender
{
    self.initialCalendarID = _eventItem.calendarId;
    A3DaysCounterAddEventViewController *viewCtrl = [[A3DaysCounterAddEventViewController alloc] initWithNibName:@"A3DaysCounterAddEventViewController" bundle:nil];
    viewCtrl.eventItem = _eventItem;
    
    if (IS_IPHONE) {
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
        navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
        navCtrl.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:navCtrl animated:YES completion:nil];
    }
    else {
		A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController];
        A3NavigationController *nav = [[A3NavigationController alloc] initWithRootViewController:viewCtrl];
        nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [rootViewController presentCenterViewController:nav
                                     fromViewController:self
                                         withCompletion:^{
                                             
                                         }];
    }
}

- (IBAction)deleteEventAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Delete Event"
                                                    otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

@end
