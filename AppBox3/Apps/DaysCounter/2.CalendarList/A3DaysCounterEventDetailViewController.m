//
//  A3DaysCounterEventDetailViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterEventDetailViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "A3DateHelper.h"
#import "DaysCounterEvent.h"
#import "DaysCounterEventLocation.h"
#import "DaysCounterDate.h"
#import "FSVenue.h"
#import "A3DaysCounterEventDetailLocationViewController.h"
#import "A3DaysCounterAddEventViewController.h"
#import "NSDate+LunarConverter.h"
#import "A3DaysCounterEventInfoCell.h"
#import "SFKImage.h"
#import "A3AppDelegate+appearance.h"
#import "DaysCounterReminder.h"
#import "DaysCounterEvent+extension.h"
#import "NSDate+formatting.h"
#import "NSDateFormatter+A3Addition.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "DaysCounterCalendar.h"
#import "A3NavigationController.h"

@interface A3DaysCounterEventDetailViewController () <UIAlertViewDelegate, UIPopoverControllerDelegate, UIActionSheetDelegate, UIActivityItemSource, A3DaysCounterAddEventViewControllerDelegate>
@property (strong, nonatomic) NSMutableArray *itemArray;
@property (strong, nonatomic) UIPopoverController *popoverVC;
@property (strong, nonatomic) NSString *initialCalendarID;
@property (strong, nonatomic) UIView *topWhitePaddingView;
@property (strong, nonatomic) UILabel *heightCalculateLabel;

@end

@implementation A3DaysCounterEventDetailViewController

- (id)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {

	}

	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Event Details", @"Event Details");

	self.tableView.showsVerticalScrollIndicator = NO;
	self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.separatorInset = A3UITableViewSeparatorInset;
    if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
        self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
    }

	if (_isNotificationPopup) {
        [self removeBackAndEditButton];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction:)];
    }

    [self.navigationController setToolbarHidden:YES];
    [self makeBackButtonEmptyArrow];

    self.initialCalendarID = _eventItem.calendarID;
    
    [self setupTopWhitePaddingView];
    self.heightCalculateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.heightCalculateLabel.numberOfLines = 0;
    [self.view addSubview:_heightCalculateLabel];
    self.heightCalculateLabel.hidden = YES;

	[self registerContentSizeCategoryDidChangeNotification];
}

- (void)removeObserver {
	[self removeContentSizeCategoryDidChangeNotification];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		[self removeObserver];
	}
}

- (void)dealloc {
	self.itemArray = nil;
	[self removeObserver];
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

	FNLOG();

    if ( [_eventItem.uniqueID length] > 0 ) {
        [self constructItemsFromEvent:_eventItem];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    if ( ![self.initialCalendarID isEqualToString:_eventItem.calendarID] ) {
        if ( self.delegate && [self.delegate respondsToSelector:@selector(didChangedCalendarEventDetailViewController:)]) {
            [self.delegate didChangedCalendarEventDetailViewController:self];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if (![self isMovingToParentViewController]) {
		[self.tableView reloadData];
	}
    if ([self.navigationController.navigationBar isHidden]) {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)contentSizeDidChange:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (void)constructItemsFromEvent:(DaysCounterEvent*)event
{
    self.itemArray = [NSMutableArray array];
    [_itemArray addObject:@{ EventRowTitle : @"", EventRowType : @(EventCellType_Title)}];
    if ( event.alertDatetime ) {
        [_itemArray addObject:@{ EventRowTitle : NSLocalizedString(@"Alert", @"Alert"), EventRowType : @(EventCellType_Alert)}];
    }
    if ( [event.calendarID length] ) {
        [_itemArray addObject:@{ EventRowTitle : NSLocalizedString(@"Calendar", @"Calendar"), EventRowType : @(EventCellType_Calendar)}];
    }
    if ( event.durationOption ) {
        [_itemArray addObject:@{ EventRowTitle : NSLocalizedString(@"Duration Option", @"Duration Option"), EventRowType : @(EventCellType_DurationOption)}];
    }
    if ( event.location ) {
        [_itemArray addObject:@{ EventRowTitle : NSLocalizedString(@"Location", @"Location"), EventRowType : @(EventCellType_Location)}];
    }
    
    if ( [event.notes length] > 0 ) {
        [_itemArray addObject:@{ EventRowTitle : NSLocalizedString(@"Notes", @"Notes"), EventRowType : @(EventCellType_Notes)}];
    }
    [_itemArray addObject:@{ EventRowTitle : NSLocalizedString(@"Share Event", @"Share Event"), EventRowType : @(EventCellType_Share)}];
    [_itemArray addObject:@{ EventRowTitle : @"", EventRowType : @(EventCellType_Favorites)}];
    [self.tableView reloadData];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.tableView reloadData];
}

#pragma mark only modal
- (void)removeBackAndEditButton
{
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonAction:)];
}

- (void)doneButtonAction:(UIBarButtonItem *)button
{
	[self.eventItem reminderWithContext:[NSManagedObjectContext MR_rootSavingContext]].isUnread = @(NO);
    [[NSManagedObjectContext MR_rootSavingContext] MR_saveToPersistentStoreAndWait];

    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
			UILabel *label = (UILabel *)[cell viewWithTag:10];
			label.text = NSLocalizedString(@"Calendar", nil);
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
                layout.constant = (IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28.0);
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
            cell.detailTextLabel.text = [_sharedManager alertDateStringFromDate:_eventItem.effectiveStartDate
                                                                      alertDate:_eventItem.alertDatetime];
        }
            break;
            
        case EventCellType_DurationOption:
        {
            cell.textLabel.text = [itemDict objectForKey:EventRowTitle];
            cell.detailTextLabel.text = [_sharedManager durationOptionStringFromValue:[_eventItem.durationOption integerValue]];
        }
            break;
            
        case EventCellType_Calendar:
        {
            UILabel *nameLabel = (UILabel*)[cell viewWithTag:12];
            UIImageView *colorImageView = (UIImageView*)[cell viewWithTag:11];
            
            DaysCounterCalendar *calendar = [_sharedManager calendarItemByID:_eventItem.calendarID];
            if ( calendar ) {
                nameLabel.text = calendar.name;
                colorImageView.tintColor = [_sharedManager colorForCalendar:calendar];
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
                NSString *address = [_sharedManager addressFromVenue:venue isDetail:NO];
                textLabel.text = ([location.locationName length] > 0 ? location.locationName : address);
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else {
                textLabel.text = NSLocalizedString(@"No location", @"No location");
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
            textLabel.text = NSLocalizedString(@"Share Event", @"Share Event");
            textLabel.textColor = [A3AppDelegate instance].themeColor;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
            break;
            
        case EventCellType_Favorites:
        {
            UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
            textLabel.text = _eventItem.favorite != nil ? NSLocalizedString(@"Remove from Favorites", @"Remove from Favorites") : NSLocalizedString(@"Add to Favorites", @"Add to Favorites");
            textLabel.textColor = [A3AppDelegate instance].themeColor;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
            break;
    }
}

#pragma mark start of EventInfoCell

- (void)updateEventInfoCell:(A3DaysCounterEventInfoCell *)cell withInfo:(DaysCounterEvent*)event
{
    cell.favoriteStarImageView.image = [[UIImage imageNamed:@"star02_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.favoriteStarImageView.tintColor = [A3AppDelegate instance].themeColor;
    
    if ( IS_IPHONE ) {
        cell.eventTitleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    }
    else {
        cell.eventTitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    }
    
    if ([event.photoID length]) {
        cell.eventPhotoImageView.image = [event thumbnailImageInOriginalDirectory:YES];
		cell.eventPhotoImageView.layer.cornerRadius = cell.eventPhotoImageView.image.size.width / 2.0;
		cell.eventPhotoImageView.layer.masksToBounds = YES;
		cell.eventPhotoImageView.contentMode = UIViewContentModeScaleAspectFill;
        cell.titleLeftSpaceConst.constant = 8;
    }
    else {
        cell.eventPhotoImageView.image = nil;
        cell.titleLeftSpaceConst.constant = 0;
    }

    cell.eventTitleLabel.text = event.eventName;
    CGSize calculatedTitleSize = [cell.eventTitleLabel.text sizeWithAttributes:@{ NSFontAttributeName : cell.eventTitleLabel.font }];
    CGFloat titleMaxWidth = CGRectGetWidth(self.view.frame) - (event.favorite != nil ? 43 : 15) - ([event.photoID length] ? 73 : 0) - (IS_IPHONE ? 15 : 28);

    if (calculatedTitleSize.width > titleMaxWidth) {
        calculatedTitleSize = [cell.eventTitleLabel sizeThatFits:CGSizeMake(titleMaxWidth, CGFLOAT_MAX)];
        cell.titleWidthConst.constant = titleMaxWidth;
        cell.titleHeightConst.constant = calculatedTitleSize.height;
    }
    else {
        calculatedTitleSize = [cell.eventTitleLabel sizeThatFits:CGSizeMake(titleMaxWidth, CGFLOAT_MAX)];
        cell.titleWidthConst.constant = calculatedTitleSize.width;
        cell.titleHeightConst.constant = calculatedTitleSize.height;
    }

    cell.favoriteStarImageView.hidden = event.favorite == nil;
    
    if ( [event.repeatType integerValue] == RepeatType_Never ) {
		[self updateEventInfoCellToNoRepeatEventInfo:event cell:cell];
    }
    else {
		[self updateEventInfoCellToRepeatEventInfo:event cell:cell];
    }
}

- (void)updateEventInfoCellToNoRepeatEventInfo:(DaysCounterEvent*)info cell:(A3DaysCounterEventInfoCell *)cell
{
    NSDate *now = [NSDate date];
    NSInteger daysGap;
    daysGap = [A3DateHelper diffDaysFromDate:now
                                       toDate:[info.startDate solarDate]
                                     isAllDay:[info.isAllDay boolValue]];

    BOOL isSince = NO;
    if ( daysGap <= 0 ) {
        isSince = YES;
    }
    
    BOOL isLunar = [info.isLunar boolValue];
    NSDate *startDate = [info.startDate solarDate];
    NSDate *endDate = [[info endDateCreateIfNotExist:NO ] solarDate];
	NSCalendar *calendar = [[A3AppDelegate instance] calendar];
    
    if ( isLunar ) {
        NSDateComponents *dateComp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:startDate];
        BOOL isResultLeapMonth = NO;
		NSDateComponents *resultComponents = [NSDate lunarCalcWithComponents:dateComp
                                                            gregorianToLunar:YES
                                                                   leapMonth:NO
                                                                      korean:[A3UIDevice useKoreanLunarCalendar]
                                                             resultLeapMonth:&isResultLeapMonth];
        NSDate *convertDate = [calendar dateFromComponents:resultComponents];
        startDate = convertDate;
        
        if ( endDate ) {
            dateComp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:endDate];
            dateComp = [NSDate lunarCalcWithComponents:dateComp
                                      gregorianToLunar:YES
                                             leapMonth:NO
                                                korean:[A3UIDevice useKoreanLunarCalendar]
                                       resultLeapMonth:&isResultLeapMonth];
			convertDate = [calendar dateFromComponents:dateComp];
            endDate = convertDate;
        }
    }
    

    [self adjustLayoutForEventInfoCell:cell eventInfo:info];
    [self updateTitleCellCurrentPart:cell withEventInfo:info];
}

- (void)updateEventInfoCellToRepeatEventInfo:(DaysCounterEvent*)info cell:(A3DaysCounterEventInfoCell *)cell
{
    [self adjustLayoutForEventInfoCell:cell eventInfo:info];
    [self updateTitleCellCurrentPart:cell withEventInfo:info];  // Set Data (until or since or Today/now)
 

    BOOL isLunar = [info.isLunar boolValue];
    NSDate *startDate = [info.startDate solarDate];
    BOOL hasSince;
    if ([_eventItem.isAllDay boolValue]) {
        hasSince = [A3DateHelper diffDaysFromDate:[NSDate date] toDate:startDate isAllDay:[info.isAllDay boolValue]] < 0 ? YES : NO;
    }
    else {
        hasSince = [[NSDate date] timeIntervalSince1970] > [startDate timeIntervalSince1970] ? YES : NO;
    }
    
    if ( isLunar ) {
        NSDateComponents *startDateCompLunar = [A3DaysCounterModelManager dateComponentsFromDateModelObject:[info startDate] toLunar:YES];
        
        BOOL isLeapMonth = NO;
        if ([info.startDate.isLeapMonth boolValue]) {
            isLeapMonth = [NSDate isLunarLeapMonthAtDateComponents:startDateCompLunar isKorean:[A3UIDevice useKoreanLunarCalendar]];
        }
        
        NSDateComponents *startDateComp = [A3DaysCounterModelManager nextSolarDateComponentsFromLunarDateComponents:startDateCompLunar
                                                                                                          leapMonth:isLeapMonth
                                                                                                           fromDate:[NSDate date]];
        startDate = [[[A3AppDelegate instance] calendar] dateFromComponents:startDateComp];
    }
    
    
    if (hasSince) {
        [self updateTitleCellSincePart:cell withEventInfo:info];
    }
}

- (void)adjustLayoutForEventInfoCell:(A3DaysCounterEventInfoCell *)cell eventInfo:(DaysCounterEvent *)eventInfo
{
    BOOL hasRepeat = [_eventItem.repeatType integerValue] != RepeatType_Never ? YES : NO;
    BOOL hasEndDate = [_eventItem.isPeriod boolValue];
    BOOL hasSince;
    if ([_eventItem.isAllDay boolValue]) {
        hasSince = [A3DateHelper diffDaysFromDate:[NSDate date] toDate:[_eventItem.startDate solarDate] isAllDay:[_eventItem.isAllDay boolValue]] < 0 ? YES : NO;
    }
    else {
        hasSince = [[NSDate date] timeIntervalSince1970] > [_eventItem.startDate.solarDate timeIntervalSince1970] ? YES : NO;
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

    cell.titleBottomSpaceConst.constant = rowHeight - 37;
}

#pragma mark end of UpdateEventInfoCell
- (void)updateTitleCellCurrentPart:(A3DaysCounterEventInfoCell *)cell withEventInfo:(DaysCounterEvent *)info
{
    UILabel *markLabel;
    UILabel *daysLabel;
    UILabel *dateLabel1;
    UILabel *dateLabel2;
    UILabel *dateLabel3;
    UILabel *dateLabel4;
    UIImageView *lunarImageView;
    
    markLabel = cell.untilSinceRoundLabel;
    daysLabel = cell.durationALabel;
    dateLabel1 = cell.startEnd1ALabel;
    dateLabel2 = cell.startEnd2ALabel;
    dateLabel3 = cell.repeatALabel;
    dateLabel4 = cell.lunarALabel;
    lunarImageView = cell.lunar1AImageView;
    
    if ( IS_IPHONE ) {
        markLabel.font = [UIFont systemFontOfSize:11.0];
        daysLabel.font = [UIFont systemFontOfSize:15.0];
        dateLabel1.font = [UIFont systemFontOfSize:13.0];
        dateLabel2.font = [UIFont systemFontOfSize:13.0];
        dateLabel3.font = [UIFont systemFontOfSize:13.0];
    }
    else {
        markLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
        daysLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        dateLabel1.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        dateLabel2.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        dateLabel3.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    }
    
    NSDate *now = [NSDate date];
    BOOL hasRepeat = [_eventItem.repeatType integerValue] != RepeatType_Never ? YES : NO;
    BOOL hasEndDate = [_eventItem.isPeriod boolValue];
    BOOL hasSince;

    if ([_eventItem.isAllDay boolValue]) {
        hasSince = [A3DateHelper diffDaysFromDate:now toDate:_eventItem.startDate.solarDate isAllDay:[_eventItem.isAllDay boolValue]] < 0 ? YES : NO;
        //hasSince = [A3DateHelper diffDaysFromDate:now toDate:_eventItem.effectiveStartDate isAllDay:[_eventItem.isAllDay boolValue]] < 0 ? YES : NO;
    }
    else {
        hasSince = [now timeIntervalSince1970] > [_eventItem.startDate.solarDate timeIntervalSince1970] ? YES : NO;
        //hasSince = [now timeIntervalSince1970] > [_eventItem.effectiveStartDate timeIntervalSince1970] ? YES : NO;
    }
    
    lunarImageView.hidden = ![info.isLunar boolValue];
    
    if (!hasRepeat) {
        cell.untilSinceRoundLabel.text = [A3DateHelper untilSinceStringByFromDate:now toDate:[info.startDate solarDate] allDayOption:[info.isAllDay boolValue] repeat:hasRepeat strict:[A3DaysCounterModelManager hasHourMinDurationOption:[info.durationOption integerValue]]];
        cell.untilRoundWidthConst.constant = 42;
        
        if ([markLabel.text isEqualToString:NSLocalizedString(@"Today", @"Today")] || [markLabel.text isEqualToString:NSLocalizedString(@"Now", @"Now")]) {
            daysLabel.text = @"";

            if ([info.isLunar boolValue]) {
                dateLabel1.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"DaysCounter_from", nil), [A3DaysCounterModelManager dateStringFromDateModel:info.startDate isLunar:NO isAllDay:[info.isAllDay boolValue]]];
                dateLabel2.text = [NSString stringWithFormat:@"%@", [A3DaysCounterModelManager dateStringFromDateModel:info.startDate isLunar:YES isAllDay:[info.isAllDay boolValue]]];
                dateLabel3.text = @"";
                dateLabel4.text = @"";
            }
            else {
                if (hasEndDate) {
                    dateLabel1.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"DaysCounter_from", @"from"), [A3DaysCounterModelManager dateStringFromDateModel:info.startDate isLunar:[info.isLunar boolValue] isAllDay:[info.isAllDay boolValue]]];
                    dateLabel2.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"DaysCounter_to", @"to"), [A3DaysCounterModelManager dateStringFromDateModel:[info endDateCreateIfNotExist:NO ] isLunar:[info.isLunar boolValue] isAllDay:[info.isAllDay boolValue]]];
                }
                else {
                    dateLabel1.text = [A3DaysCounterModelManager dateStringFromDateModel:info.startDate isLunar:NO isAllDay:[info.isAllDay boolValue]];
                    dateLabel2.text = @"";
                }
                dateLabel3.text = @"";
                dateLabel4.text = @"";
            }
            
            goto EXIT_FUCTION;
        }
        else {
            daysLabel.text = [A3DaysCounterModelManager stringOfDurationOption:[info.durationOption integerValue]
                                                                      fromDate:now
                                                                        toDate:[info.startDate solarDate]
                                                                      isAllDay:[info.isAllDay boolValue]
                                                                  isShortStyle:NO
                                                             isStrictShortType:NO];
        }
        
        if (hasEndDate) {
            //* case 2. 162pt  (start 안 지남, end있음)
            //            * case 2. 162pt
            //            Title
            //            until 계산값
            //            from 선택날짜/시간
            //            to 선택날짜/시간
            //            repeats 옵션
            dateLabel1.text = [NSString stringWithFormat:NSLocalizedString(@"from %@", @"from %@"), [A3DaysCounterModelManager dateStringFromDateModel:info.startDate isLunar:[info.isLunar boolValue] isAllDay:[info.isAllDay boolValue]]];
            dateLabel2.text = [NSString stringWithFormat:NSLocalizedString(@"to %@", @"to %@"), [A3DaysCounterModelManager dateStringFromDateModel:[info endDateCreateIfNotExist:NO ] isLunar:[info.isLunar boolValue] isAllDay:[info.isAllDay boolValue]]];
            if (info.repeatType && ![info.repeatType isEqualToNumber:@(RepeatType_Never)]) {
                dateLabel3.text = [NSString stringWithFormat:NSLocalizedString(@"repeats %@", @"repeats %@"), [_sharedManager repeatTypeStringForDetailValue:[info.repeatType integerValue]]];
            }
            else {
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
            if (IS_IPAD || ![info.isLunar boolValue]) {
                dateLabel1.text = [A3DaysCounterModelManager dateStringFromDateModel:info.startDate isLunar:[info.isLunar boolValue] isAllDay:[info.isAllDay boolValue]];
                if (info.repeatType && ![info.repeatType isEqualToNumber:@(RepeatType_Never)]) {
                    dateLabel2.text = [NSString stringWithFormat:NSLocalizedString(@"repeats %@", @"repeats %@"), [_sharedManager repeatTypeStringForDetailValue:[info.repeatType integerValue]]];
                }
                else {
                    dateLabel2.text = @"";
                }
                dateLabel3.text = @"";
                dateLabel4.text = @"";
            }
            else {
                dateLabel1.text = [A3DaysCounterModelManager dateStringFromDateModel:info.startDate isLunar:NO isAllDay:[info.isAllDay boolValue]];
                dateLabel2.text = [A3DaysCounterModelManager dateStringFromDateModel:info.startDate isLunar:YES isAllDay:[info.isAllDay boolValue]];
                if (info.repeatType && ![info.repeatType isEqualToNumber:@(RepeatType_Never)]) {
                    dateLabel3.text = [NSString stringWithFormat:NSLocalizedString(@"repeats %@", @"repeats %@"), [_sharedManager repeatTypeStringForDetailValue:[info.repeatType integerValue]]];
                }
                else {
                    dateLabel3.text = @"";
                }
                dateLabel4.text = @"";
            }
        }
    }
    else {
        // Has Repeat
        NSDate *startDate = [info.startDate solarDate];
        NSDate *nextDate = [info effectiveStartDate];
        NSDate *endDate = [[info endDateCreateIfNotExist:NO ] solarDate];
        
        // until/since & durationOption string
        cell.untilSinceRoundLabel.text = [A3DateHelper untilSinceStringByFromDate:now
                                                                           toDate:nextDate
                                                                     allDayOption:[info.isAllDay boolValue]
                                                                           repeat:hasRepeat
                                                                           strict:[A3DaysCounterModelManager hasHourMinDurationOption:[info.durationOption integerValue]]];
        cell.untilRoundWidthConst.constant = 42;

        if ([markLabel.text isEqualToString:NSLocalizedString(@"Today", @"Today")] || [markLabel.text isEqualToString:NSLocalizedString(@"Now", @"Now")]) {
            if (hasEndDate) {
                daysLabel.text = @"";
                dateLabel1.text = [NSString stringWithFormat:NSLocalizedString(@"from %@", @"from %@"), [A3DateHelper dateStringFromDate:nextDate
																															  withFormat:[A3DaysCounterModelManager dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
                NSTimeInterval diff = [endDate timeIntervalSince1970] - [startDate timeIntervalSince1970];
                NSDate *nextEndDate;
                nextEndDate = [NSDate dateWithTimeInterval:diff sinceDate:nextDate];
                dateLabel2.text = [NSString stringWithFormat:NSLocalizedString(@"to %@", @"to %@"), [A3DateHelper dateStringFromDate:nextEndDate
																														  withFormat:[A3DaysCounterModelManager dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
                if (info.repeatType && ![info.repeatType isEqualToNumber:@(RepeatType_Never)]) {
                    dateLabel3.text = [NSString stringWithFormat:NSLocalizedString(@"repeats %@", @"repeats %@"), [_sharedManager repeatTypeStringForDetailValue:[info.repeatType integerValue]]];
                }
                dateLabel4.text = @"";
                goto EXIT_FUCTION;
            }
            else {
                daysLabel.text = @"";
                //dateLabel1.text = [A3DaysCounterModelManager dateStringFromDateModel:info.startDate isLunar:NO isAllDay:[info.isAllDay boolValue]];
                dateLabel1.text = [A3DateHelper dateStringFromDate:nextDate
                                                        withFormat:[A3DaysCounterModelManager dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]];
                if (info.repeatType && ![info.repeatType isEqualToNumber:@(RepeatType_Never)]) {
                    dateLabel2.text = [NSString stringWithFormat:NSLocalizedString(@"repeats %@", @"repeats %@"), [_sharedManager repeatTypeStringForDetailValue:[info.repeatType integerValue]]];
                }
                dateLabel3.text = @"";
                dateLabel4.text = @"";
                goto EXIT_FUCTION;
            }
        }
        else {
            daysLabel.text = [A3DaysCounterModelManager stringOfDurationOption:[info.durationOption integerValue]
                                                                      fromDate:now
                                                                        toDate:hasSince ? nextDate : startDate
                                                                      isAllDay:[info.isAllDay boolValue]
                                                                  isShortStyle:NO isStrictShortType:NO];
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
                dateLabel1.text = [NSString stringWithFormat:NSLocalizedString(@"from %@", @"from %@"), [A3DateHelper dateStringFromDate:nextDate
																															  withFormat:[A3DaysCounterModelManager dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
                NSTimeInterval diff = [endDate timeIntervalSince1970] - [startDate timeIntervalSince1970];
                NSDate *nextEndDate;
                nextEndDate = [NSDate dateWithTimeInterval:diff sinceDate:nextDate];
                dateLabel2.text = [NSString stringWithFormat:NSLocalizedString(@"to %@", @"to %@"), [A3DateHelper dateStringFromDate:nextEndDate
																														  withFormat:[A3DaysCounterModelManager dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
                if (info.repeatType && ![info.repeatType isEqualToNumber:@(RepeatType_Never)]) {
                    dateLabel3.text = [NSString stringWithFormat:NSLocalizedString(@"repeats %@", @"repeats %@"), [_sharedManager repeatTypeStringForDetailValue:[info.repeatType integerValue]]];
                }
                dateLabel4.text = @"";
            }
            else {
                //* case 2. 162pt  (start 안 지남, end있음)
                //            * case 2. 162pt
                //            Title
                //            until 계산값
                //            from 선택날짜/시간
                //            to 선택날짜/시간
                //            repeats 옵션
                dateLabel1.text = [NSString stringWithFormat:NSLocalizedString(@"from %@", @"from %@"), [A3DateHelper dateStringFromDate:startDate
																															  withFormat:[A3DaysCounterModelManager dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
                dateLabel2.text = [NSString stringWithFormat:NSLocalizedString(@"to %@", @"to %@"), [A3DateHelper dateStringFromDate:endDate
																														  withFormat:[A3DaysCounterModelManager dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
                if (info.repeatType && ![info.repeatType isEqualToNumber:@(RepeatType_Never)]) {
                    dateLabel3.text = [NSString stringWithFormat:NSLocalizedString(@"repeats %@", @"repeats %@"), [_sharedManager repeatTypeStringForDetailValue:[info.repeatType integerValue]]];
                }
                dateLabel4.text = @"";
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
                dateLabel1.text = [A3DaysCounterModelManager dateStringFromEffectiveDate:nextDate
                                                                                 isLunar:NO//[_eventItem.isLunar boolValue]
                                                                                isAllDay:[_eventItem.isAllDay boolValue]
                                                                             isLeapMonth:[_eventItem.startDate.isLeapMonth boolValue]];
                if (info.repeatType && ![info.repeatType isEqualToNumber:@(RepeatType_Never)]) {
                    dateLabel2.text = [NSString stringWithFormat:NSLocalizedString(@"repeats %@", @"repeats %@"), [_sharedManager repeatTypeStringForDetailValue:[info.repeatType integerValue]]];
                }
                
                dateLabel3.text = @"";
                dateLabel4.text = @"";
            }
            else {
                //* case 1. 현재의 142pt (start 안 지나거나 지났고, end없음, 다음 start없음)
                //            * case 1. 현재의 142pt
                //            Title
                //            until(since) 계산값
                //            date 선택날짜/시간 (since 일 경우 starts-ends on. from)
                //            (until일 경우 - repeats 옵션) (since 일 경우 to)
                //* case 1, repeat only until
                if (IS_IPAD || ![info.isLunar boolValue]) {
                    dateLabel1.text = [A3DaysCounterModelManager dateStringFromDateModel:info.startDate isLunar:[info.isLunar boolValue] isAllDay:[info.isAllDay boolValue]];
                    if (info.repeatType && ![info.repeatType isEqualToNumber:@(RepeatType_Never)]) {
                        dateLabel2.text = [NSString stringWithFormat:NSLocalizedString(@"repeats %@", @"repeats %@"), [_sharedManager repeatTypeStringForDetailValue:[info.repeatType integerValue]]];
                    }
                    
                    dateLabel3.text = @"";
                    dateLabel4.text = @"";
                }
                else {
                    dateLabel1.text = [A3DaysCounterModelManager dateStringFromDateModel:info.startDate isLunar:NO isAllDay:[info.isAllDay boolValue]];
                    dateLabel2.text = [A3DaysCounterModelManager dateStringFromDateModel:info.startDate isLunar:YES isAllDay:[info.isAllDay boolValue]];
                    if (info.repeatType && ![info.repeatType isEqualToNumber:@(RepeatType_Never)]) {
                        dateLabel3.text = [NSString stringWithFormat:NSLocalizedString(@"repeats %@", @"repeats %@"), [_sharedManager repeatTypeStringForDetailValue:[info.repeatType integerValue]]];
                    }
                    
                    dateLabel4.text = @"";
                }
            }
        }
    }
    
EXIT_FUCTION:
    
    if ([markLabel.text isEqualToString:NSLocalizedString(@"since", @"since")]) {
        markLabel.textColor = [UIColor colorWithRed:1.0 green:45.0/255.0 blue:85.0/255.0 alpha:1.0];
    }
    else {
        markLabel.textColor = [UIColor colorWithRed:73.0/255.0 green:191.0/255.0 blue:31.0/255.0 alpha:1.0];
    }
    
    markLabel.layer.borderColor = [markLabel.textColor CGColor];
    markLabel.layer.borderWidth = IS_RETINA ? 0.5 : 1.0;
    markLabel.layer.masksToBounds = YES;
    markLabel.layer.cornerRadius = 9.0;
}

- (void)updateTitleCellSincePart:(A3DaysCounterEventInfoCell *)cell withEventInfo:(DaysCounterEvent *)info
{
    UILabel *markLabel;
    UILabel *daysLabel;
    UILabel *dateLabel1;
    UILabel *dateLabel2;
    UILabel *dateLabel3;
    UILabel *dateLabel4;
    UIImageView *lunarImageView;
    
    markLabel = cell.sinceRoundLabel;
    daysLabel = cell.durationBLabel;
    dateLabel1 = cell.startEnd1BLabel;
    dateLabel2 = cell.startEnd2BLabel;
    dateLabel3 = cell.repeatBLabel;
    dateLabel4 = cell.lunarBLabel;
    lunarImageView = cell.lunar1BImageView;
    
    if ( IS_IPHONE ) {
        markLabel.font = [UIFont systemFontOfSize:11.0];
        daysLabel.font = [UIFont systemFontOfSize:15.0];
        dateLabel1.font = [UIFont systemFontOfSize:13.0];
        dateLabel2.font = [UIFont systemFontOfSize:13.0];
        dateLabel3.font = [UIFont systemFontOfSize:13.0];
    }
    else {
        markLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
        daysLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        dateLabel1.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        dateLabel2.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        dateLabel3.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    }
    
    NSDate *now = [NSDate date];
//    BOOL hasRepeat = [_eventItem.repeatType integerValue] != RepeatType_Never ? YES : NO;
    BOOL hasEndDate = [_eventItem.isPeriod boolValue];
    
    lunarImageView.hidden = ![info.isLunar boolValue];
    
    
    // Has Repeat
    NSDate *startDate = [info.startDate solarDate];
    //    NSDate *nextDate = [info effectiveStartDate];
    
    // until/since & durationOption string
//    markLabel.text = [A3DateHelper untilSinceStringByFromDate:now
//                                                       toDate:startDate
//                                                 allDayOption:[info.isAllDay boolValue]
//                                                       repeat:hasRepeat
//                                                       strict:[A3DaysCounterModelManager hasHourMinDurationOption:[info.durationOption integerValue]]];
    markLabel.text = NSLocalizedString(@"since", @"since");
    cell.sinceRoundWidthConst.constant = 42;
    daysLabel.text = [A3DaysCounterModelManager stringOfDurationOption:[info.durationOption integerValue]
                                                              fromDate:startDate
                                                                toDate:now
                                                              isAllDay:[info.isAllDay boolValue]
                                                          isShortStyle:NO isStrictShortType:NO];
    // from / to string / repeat
    if (hasEndDate) {
        //* case 2. 162pt  (start 안 지남, end있음)
        //            * case 2. 162pt
        //            Title
        //            until 계산값
        //            from 선택날짜/시간
        //            to 선택날짜/시간
        //            repeats 옵션
        dateLabel1.text = [NSString stringWithFormat:NSLocalizedString(@"from %@", @"from %@"), [A3DaysCounterModelManager dateStringFromDateModel:info.startDate isLunar:[info.isLunar boolValue] isAllDay:[info.isAllDay boolValue]]];
        dateLabel2.text = [NSString stringWithFormat:NSLocalizedString(@"to %@", @"to %@"), [A3DaysCounterModelManager dateStringFromDateModel:[info endDateCreateIfNotExist:NO ] isLunar:[info.isLunar boolValue] isAllDay:[info.isAllDay boolValue]]];
        dateLabel3.text = NSLocalizedString(@"first date", @"first date");
        dateLabel4.text = @"";
    }
    else {  // ! hasEnd
        //* case 1. 현재의 142pt (start 안 지나거나 지났고, end없음, 다음 start없음)
        //            * case 1. 현재의 142pt
        //            Title
        //            until(since) 계산값
        //            date 선택날짜/시간 (since 일 경우 starts-ends on. from)
        //            (until일 경우 - repeats 옵션) (since 일 경우 to)
        //* case 1, repeat only until
        if (IS_IPAD || ![info.isLunar boolValue]) {
            dateLabel1.text = [A3DaysCounterModelManager dateStringFromDateModel:info.startDate isLunar:[info.isLunar boolValue] isAllDay:[info.isAllDay boolValue]];
            dateLabel2.text = NSLocalizedString(@"first date", @"first date");
            dateLabel3.text = @"";
            dateLabel4.text = @"";
        }
        else {
            dateLabel1.text = [A3DaysCounterModelManager dateStringFromDateModel:info.startDate isLunar:NO isAllDay:YES ];
            dateLabel2.text = [A3DaysCounterModelManager dateStringFromDateModel:info.startDate isLunar:YES isAllDay:YES ];
            dateLabel3.text = NSLocalizedString(@"first date", @"first date");
            dateLabel4.text = @"";
        }
    }
    
EXIT_FUCTION:
    
    if ([markLabel.text isEqualToString:NSLocalizedString(@"since", @"since")]) {
        markLabel.textColor = [UIColor colorWithRed:1.0 green:45.0/255.0 blue:85.0/255.0 alpha:1.0];
    }
    else {
        markLabel.textColor = [UIColor colorWithRed:73.0/255.0 green:191.0/255.0 blue:31.0/255.0 alpha:1.0];
    }
    
    markLabel.layer.borderColor = [markLabel.textColor CGColor];
    markLabel.layer.borderWidth = IS_RETINA ? 0.5 : 1.0;
    markLabel.layer.masksToBounds = YES;
    markLabel.layer.cornerRadius = 9.0;
}

- (void)updateEventInfoCell:(A3DaysCounterEventInfoCell *)cell isSince:(BOOL)isSince isTypeA:(BOOL)isTypeA eventInfo:(DaysCounterEvent*)info
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
        dateLabel3.font = [UIFont systemFontOfSize:13.0];
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
        hasSince = [A3DateHelper diffDaysFromDate:now toDate:[_eventItem.startDate solarDate] isAllDay:[_eventItem.isAllDay boolValue]] < 0 ? YES : NO;
    }
    else {
        hasSince = [now timeIntervalSince1970] > [_eventItem.startDate.solarDate timeIntervalSince1970] ? YES : NO;
    }
    
    lunarImageView.hidden = !isLunar;

	NSCalendar *calendar = [[A3AppDelegate instance] calendar];
    if (!hasRepeat) {
        NSDate *startDate = [info.startDate solarDate];
        NSDate *endDate = [[info endDateCreateIfNotExist:NO ] solarDate];

        cell.untilSinceRoundLabel.text = [A3DateHelper untilSinceStringByFromDate:now
                                                                           toDate:[info.startDate solarDate]
                                                                     allDayOption:[info.isAllDay boolValue]
                                                                           repeat:hasRepeat
                                                                           strict:[A3DaysCounterModelManager hasHourMinDurationOption:[info.durationOption integerValue]]];
        cell.untilRoundWidthConst.constant = 42;
        
        if ( isLunar ) {
            NSDateComponents *dateComp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:startDate];
            BOOL isResultLeapMonth = NO;
            NSDateComponents *resultComponents = [NSDate lunarCalcWithComponents:dateComp
                                                                gregorianToLunar:YES
                                                                       leapMonth:NO
                                                                          korean:[A3UIDevice useKoreanLunarCalendar]
                                                                 resultLeapMonth:&isResultLeapMonth];
            NSDate *convertDate = [calendar dateFromComponents:resultComponents];
            
            startDate = convertDate;
            
            if ( endDate ) {
                dateComp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:endDate];
                dateComp = [NSDate lunarCalcWithComponents:dateComp
                                          gregorianToLunar:YES
                                                 leapMonth:NO
                                                    korean:[A3UIDevice useKoreanLunarCalendar]
                                           resultLeapMonth:&isResultLeapMonth];
                convertDate = [calendar dateFromComponents:dateComp];
                endDate = convertDate;
            }
        }

        if ([markLabel.text isEqualToString:NSLocalizedString(@"Today", @"Today")] || [markLabel.text isEqualToString:NSLocalizedString(@"Now", @"Now")]) {
            daysLabel.text = @"";

            dateLabel1.text = [NSString stringWithFormat:@"%@", [A3DateHelper dateStringFromDate:[A3DaysCounterModelManager repeatDateOfCurrentNotNextWithRepeatOption:[info.repeatType integerValue] firstDate:startDate fromDate:now]
                                                                                      withFormat:[A3DaysCounterModelManager dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
            if (info.repeatType && ![info.repeatType isEqualToNumber:@(RepeatType_Never)]) {
                dateLabel2.text = [NSString stringWithFormat:NSLocalizedString(@"repeats %@", @"repeats %@"), [_sharedManager repeatTypeStringForDetailValue:[info.repeatType integerValue]]];
            }

            goto EXIT_FUCTION;
        }
        else {
            daysLabel.text = [A3DaysCounterModelManager stringOfDurationOption:[info.durationOption integerValue]
                                                                      fromDate:now
                                                                        toDate:startDate
                                                                      isAllDay:[info.isAllDay boolValue]
                                                                  isShortStyle:NO isStrictShortType:NO];
        }
        
        if (hasEndDate) {
            //* case 2. 162pt  (start 안 지남, end있음)
            //            * case 2. 162pt
            //            Title
            //            until 계산값
            //            from 선택날짜/시간
            //            to 선택날짜/시간
            //            repeats 옵션
            dateLabel1.text = [NSString stringWithFormat:NSLocalizedString(@"from %@", @"from %@"), [A3DateHelper dateStringFromDate:startDate
																														  withFormat:[A3DaysCounterModelManager dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
            dateLabel2.text = [NSString stringWithFormat:NSLocalizedString(@"to %@", @"to %@"), [A3DateHelper dateStringFromDate:endDate
																													  withFormat:[A3DaysCounterModelManager dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
            if (info.repeatType && ![info.repeatType isEqualToNumber:@(RepeatType_Never)]) {
                dateLabel3.text = [NSString stringWithFormat:NSLocalizedString(@"repeats %@", @"repeats %@"), [_sharedManager repeatTypeStringForDetailValue:[info.repeatType integerValue]]];
            }
        }
        else {
            //* case 1. 현재의 142pt (start 안 지나거나 지났고, end없음, 다음 start없음)
            //            * case 1. 현재의 142pt
            //            Title
            //            until(since) 계산값
            //            date 선택날짜/시간 (since 일 경우 starts-ends on. from)
            //            (until일 경우 - repeats 옵션) (since 일 경우 to)
            dateLabel1.text = [NSString stringWithFormat:@"%@", [A3DateHelper dateStringFromDate:startDate
                                                                                      withFormat:[A3DaysCounterModelManager dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
            if (info.repeatType && ![info.repeatType isEqualToNumber:@(RepeatType_Never)]) {
                dateLabel2.text = [NSString stringWithFormat:NSLocalizedString(@"repeats %@", @"repeats %@"), [_sharedManager repeatTypeStringForDetailValue:[info.repeatType integerValue]]];
            }
            
            dateLabel3.text = @"";
        }
    }

    else {
        // Has Repeat
        NSDate *startDate = [info.startDate solarDate];
        
        if ( isLunar ) {
            NSDateComponents *dateComp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                                                         fromDate:startDate];
            BOOL isResultLeapMonth = NO;
            dateComp = [NSDate lunarCalcWithComponents:dateComp
                                      gregorianToLunar:YES
                                             leapMonth:NO
                                                korean:[A3UIDevice useKoreanLunarCalendar]
                                       resultLeapMonth:&isResultLeapMonth];
            NSDate *convertDate = [calendar dateFromComponents:dateComp];
            startDate = convertDate;
        }
        
        NSDate *nextDate = [A3DaysCounterModelManager nextDateWithRepeatOption:[info.repeatType integerValue] firstDate:startDate fromDate:now isAllDay:[info.isAllDay boolValue]];
        
        // until/since & durationOption string
        cell.untilSinceRoundLabel.text = [A3DateHelper untilSinceStringByFromDate:now
                                                                           toDate:nextDate
                                                                     allDayOption:[info.isAllDay boolValue]
                                                                           repeat:hasRepeat
                                                                           strict:[A3DaysCounterModelManager hasHourMinDurationOption:[info.durationOption integerValue]]];
        cell.untilRoundWidthConst.constant = 42;
        
        if (isTypeA) {
            if ([markLabel.text isEqualToString:NSLocalizedString(@"Today", @"Today")] || [markLabel.text isEqualToString:NSLocalizedString(@"Now", @"Now")]) {
                daysLabel.text = @"";
                dateLabel1.text = [NSString stringWithFormat:@"%@", [A3DateHelper dateStringFromDate:[A3DaysCounterModelManager repeatDateOfCurrentNotNextWithRepeatOption:[info.repeatType integerValue] firstDate:startDate fromDate:now]
                                                                                          withFormat:[A3DaysCounterModelManager dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];

                if (info.repeatType && ![info.repeatType isEqualToNumber:@(RepeatType_Never)]) {
                    dateLabel2.text = [NSString stringWithFormat:NSLocalizedString(@"repeats %@", @"repeats %@"), [_sharedManager repeatTypeStringForDetailValue:[info.repeatType integerValue]]];
                }

                goto EXIT_FUCTION;
            }
            else {
                daysLabel.text = [A3DaysCounterModelManager stringOfDurationOption:[info.durationOption integerValue]
                                                                          fromDate:now
                                                                            toDate:hasSince ? nextDate : startDate
                                                                          isAllDay:[info.isAllDay boolValue]
                                                                      isShortStyle:NO isStrictShortType:NO];
            }
        }
        else {
            daysLabel.text = [A3DaysCounterModelManager stringOfDurationOption:[info.durationOption integerValue]
                                                                      fromDate:startDate
                                                                        toDate:now
                                                                      isAllDay:[info.isAllDay boolValue]
                                                                  isShortStyle:NO isStrictShortType:NO];
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
                    dateLabel1.text = [NSString stringWithFormat:NSLocalizedString(@"from %@", @"from %@"), [A3DateHelper dateStringFromDate:nextDate
																																  withFormat:[A3DaysCounterModelManager dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
                    
                    NSTimeInterval diff = [[info endDateCreateIfNotExist:NO ].solarDate timeIntervalSince1970] - [info.startDate.solarDate timeIntervalSince1970];
                    NSDate *nextEndDate = [NSDate dateWithTimeInterval:diff sinceDate:nextDate];
                    dateLabel2.text = [NSString stringWithFormat:NSLocalizedString(@"to %@", @"to %@"), [A3DateHelper dateStringFromDate:nextEndDate
																															  withFormat:[A3DaysCounterModelManager dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
                    if (info.repeatType && ![info.repeatType isEqualToNumber:@(RepeatType_Never)]) {
                        dateLabel3.text = [NSString stringWithFormat:NSLocalizedString(@"repeats %@", @"repeats %@"), [_sharedManager repeatTypeStringForDetailValue:[info.repeatType integerValue]]];
                    }
                }
                else {
                    dateLabel1.text = [NSString stringWithFormat:NSLocalizedString(@"from %@", @"from %@"), [A3DateHelper dateStringFromDate:[info.startDate solarDate]
																																  withFormat:[A3DaysCounterModelManager dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
                    dateLabel2.text = [NSString stringWithFormat:NSLocalizedString(@"to %@", @"to %@"), [A3DateHelper dateStringFromDate:[[info endDateCreateIfNotExist:NO ] solarDate]
																															  withFormat:[A3DaysCounterModelManager dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
                    dateLabel3.text = [NSString stringWithFormat:NSLocalizedString(@"first date", @"first date")];
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
                dateLabel1.text = [NSString stringWithFormat:NSLocalizedString(@"from %@", @"from %@"), [A3DateHelper dateStringFromDate:[info.startDate solarDate]
																															  withFormat:[A3DaysCounterModelManager dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
                dateLabel2.text = [NSString stringWithFormat:NSLocalizedString(@"to %@", @"to %@"), [A3DateHelper dateStringFromDate:[[info endDateCreateIfNotExist:NO ] solarDate]
																														  withFormat:[A3DaysCounterModelManager dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
                if (info.repeatType && ![info.repeatType isEqualToNumber:@(RepeatType_Never)]) {
                    dateLabel3.text = [NSString stringWithFormat:NSLocalizedString(@"repeats %@", @"repeats %@"), [_sharedManager repeatTypeStringForDetailValue:[info.repeatType integerValue]]];
                }
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
                if (isTypeA) {
                    dateLabel1.text = [NSString stringWithFormat:@"%@", [A3DateHelper dateStringFromDate:nextDate
                                                                                              withFormat:[A3DaysCounterModelManager dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
                    if (info.repeatType && ![info.repeatType isEqualToNumber:@(RepeatType_Never)]) {
                        dateLabel2.text = [NSString stringWithFormat:NSLocalizedString(@"repeats %@", @"repeats %@"), [_sharedManager repeatTypeStringForDetailValue:[info.repeatType integerValue]]];
                    }
                    
                    dateLabel3.text = @"";
                }
                else {
                    dateLabel1.text = [NSString stringWithFormat:@"%@", [A3DateHelper dateStringFromDate:[info.startDate solarDate]
                                                                                                   withFormat:[A3DaysCounterModelManager dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
                    dateLabel2.text = [NSString stringWithFormat:NSLocalizedString(@"first date", @"first date")];
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
                dateLabel1.text = [NSString stringWithFormat:@"%@", [A3DateHelper dateStringFromDate:[info.startDate solarDate]
                                                                                          withFormat:[A3DaysCounterModelManager dateFormatForDetailIsAllDays:[info.isAllDay boolValue]]]];
                if (info.repeatType && ![info.repeatType isEqualToNumber:@(RepeatType_Never)]) {
                    dateLabel2.text = [NSString stringWithFormat:NSLocalizedString(@"repeats %@", @"repeats %@"), [_sharedManager repeatTypeStringForDetailValue:[info.repeatType integerValue]]];
                }
                
                dateLabel3.text = @"";
            }
        }
    }
    
EXIT_FUCTION:
    
    if ([markLabel.text isEqualToString:NSLocalizedString(@"since", @"since")]) {
        markLabel.textColor = [UIColor colorWithRed:1.0 green:45.0/255.0 blue:85.0/255.0 alpha:1.0];
    }
    else {
        markLabel.textColor = [UIColor colorWithRed:73.0/255.0 green:191.0/255.0 blue:31.0/255.0 alpha:1.0];
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

    eventInfoCell.lunar1AImageView.hidden = YES;
    eventInfoCell.lunar1BImageView.hidden = YES;
    
    eventInfoCell.durationALabel.text = @"";
    eventInfoCell.startEnd1ALabel.text = @"";
    eventInfoCell.startEnd2ALabel.text = @"";
    eventInfoCell.repeatALabel.text = @"";
    
    eventInfoCell.durationBLabel.text = @"";
    eventInfoCell.startEnd1BLabel.text = @"";
    eventInfoCell.startEnd2BLabel.text = @"";
    eventInfoCell.repeatBLabel.text = @"";


    eventInfoCell.lunarALabel = [UILabel new];
    [eventInfoCell.contentView addSubview:eventInfoCell.lunarALabel];
    [eventInfoCell.lunarALabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(eventInfoCell.eventTitleLabel.left);
        make.baseline.equalTo(eventInfoCell.repeatALabel.baseline).with.offset(20);
    }];
    
    eventInfoCell.lunarALabel.textColor = [UIColor colorWithRed:159/255.0 green:159/255.0 blue:159/255.0 alpha:1.0];
    eventInfoCell.lunarALabel.font = IS_IPHONE ? [UIFont systemFontOfSize:13.0] : [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    
    
    eventInfoCell.lunarBLabel = [UILabel new];
    [eventInfoCell.contentView addSubview:eventInfoCell.lunarBLabel];
    [eventInfoCell.lunarBLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(eventInfoCell.eventTitleLabel.left);
        make.baseline.equalTo(eventInfoCell.repeatBLabel.baseline).with.offset(20);
    }];
    
    eventInfoCell.lunarBLabel.text = @"eventInfoCell.lunarBLabel";
    eventInfoCell.lunarBLabel.textColor = [UIColor colorWithRed:159/255.0 green:159/255.0 blue:159/255.0 alpha:1.0];
    eventInfoCell.lunarBLabel.font = IS_IPHONE ? [UIFont systemFontOfSize:13.0] : [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_isNotificationPopup) {
        return 1;
    }
    
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
        NSArray *cellIDs = @[@"eventInfoCell", @"", @"", @"", @"",      // 0 ~ 4
                             @"", @"", @"value1Cell", @"value1Cell", @"value1Cell",     // 5 ~ 9
                             @"calendarInfoCell", @"value1Cell", @"value1Cell", @"multilineCell", @"",      // 10 ~ 14
                             @"defaultCell", @"defalutCell", @""];      // 15 ~ 17

        NSString *CellIdentifier = [cellIDs objectAtIndex:cellType];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [self createCellWithType:cellType cellIdentifier:CellIdentifier];
        }
        
        [self updateTableViewCell:cell indexPath:indexPath];
    }
    else {
        NSString *cellID = @"normalCell";       // 18
        cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if ( cell == nil ) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        
        cell.textLabel.text = NSLocalizedString(@"Delete Event", @"Delete Event");      // 19 (20)
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
//            if ([_eventItem.isAllDay boolValue]) {
//                hasSince = [A3DateHelper diffDaysFromDate:[NSDate date] toDate:[_eventItem.startDate solarDate] isAllDay:[_eventItem.isAllDay boolValue]] < 0 ? YES : NO;
//            }
//            else {
//                hasSince = [[NSDate date] timeIntervalSince1970] > [_eventItem.effectiveStartDate timeIntervalSince1970] ? YES : NO;
//            }
            
            if ([_eventItem.isAllDay boolValue]) {
                hasSince = [A3DateHelper diffDaysFromDate:[NSDate date] toDate:[_eventItem.startDate solarDate] isAllDay:[_eventItem.isAllDay boolValue]] < 0 ? YES : NO;
            } else {
                hasSince = [[NSDate date] timeIntervalSince1970] > [[_eventItem.startDate solarDate] timeIntervalSince1970] ? YES : NO;
            }

            
            if (hasRepeat) {
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
            else {
                if (hasEndDate) {
                    //* case 2. 162pt  (start 안 지남, end있음)
                    retHeight = IS_RETINA ? 162.5 : 163;
                }
                else {
                    //* case 1. 현재의 142pt (start 안 지나거나 지났고, end없음, 다음 start없음)
                    retHeight = IS_RETINA ? 142.5 : 143;
                }
            }

			UIFont *titleFont = IS_IPHONE ? [UIFont boldSystemFontOfSize:17.0] : [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
			CGSize calculatedTitleSize = [_eventItem.eventName sizeWithAttributes:@{ NSFontAttributeName : titleFont }];
			CGFloat titleMaxWidth = CGRectGetWidth(self.view.frame) - (_eventItem.favorite != nil ? 43 : 15) - ([_eventItem.photoID length] ? 73 : 0) - (IS_IPHONE ? 15 : 28);

			if (calculatedTitleSize.width > titleMaxWidth) {
////                    UILabel *label = [[UILabel alloc] init];
////                    label.font = titleFont;
////                    label.text = _eventItem.eventName;
////                    [label setNeedsLayout];
//                    CGRect calculatedTitleRect = [_eventItem.eventName boundingRectWithSize:CGSizeMake(titleMaxWidth, CGFLOAT_MAX)
//                                                                                    options:NSStringDrawingUsesLineFragmentOrigin
//                                                                                 attributes:@{ NSFontAttributeName : titleFont }
//                                                                                    context:nil];
////                    label.text = @"A";
//                    CGRect aLineRect = [@"A" boundingRectWithSize:CGSizeMake(titleMaxWidth, CGFLOAT_MAX)
//                                                          options:NSStringDrawingUsesLineFragmentOrigin
//                                                       attributes:@{ NSFontAttributeName : titleFont }
//                                                          context:nil];
//                    retHeight += calculatedTitleRect.size.height - aLineRect.size.height;


				self.heightCalculateLabel.font = titleFont;

				CGSize calculatedTitleSize;
				CGSize aLineSize;
				self.heightCalculateLabel.text = _eventItem.eventName;
				calculatedTitleSize = [self.heightCalculateLabel sizeThatFits:CGSizeMake(titleMaxWidth, CGFLOAT_MAX)];
				self.heightCalculateLabel.text = @"A";
				aLineSize = [self.heightCalculateLabel sizeThatFits:CGSizeMake(titleMaxWidth, CGFLOAT_MAX)];
				retHeight += calculatedTitleSize.height - aLineSize.height;
			}
			break;
		}

        case EventCellType_Notes:
        {
			if (![_eventItem.notes length]) return 74.0;
			CGRect strBounds = [_eventItem.notes boundingRectWithSize:CGSizeMake(tableView.frame.size.width - (IS_IPHONE ? 20.0 : 28.0 * 2), CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17.0]} context:nil];
			retHeight = MAX((strBounds.size.height + 31.0), 74.0);
			break;
		}

        case EventCellType_Alert:
        case EventCellType_Location:
        case EventCellType_DurationOption:
        case EventCellType_Calendar:
        {
            if (IS_IPAD) {
                retHeight = 74.0;
            }
        }
            break;
            
        case EventCellType_Share:
        case EventCellType_Favorites:
        default:
        {
//            if ( isiPadFullMode && ((cellType != EventCellType_Share) && (cellType != EventCellType_Favorites)) ) {
//                retHeight = 74.0;
//            }
        }
            break;
    }
    
    return retHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1 ) {
        return 38.0;
        //return 35.0;
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

#pragma mark Row Select Actions
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section == 1 ) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self deleteEventAction:cell];
        return;
    }
    NSDictionary *itemDict = [_itemArray objectAtIndex:indexPath.row];
    NSInteger cellType = [[itemDict objectForKey:EventRowType] integerValue];
    
    if ( cellType == EventCellType_Location && _eventItem.location ) {
        [self didSelectLocationRow];
    }
    else if ( cellType == EventCellType_Share ) {
		[self didSelectShareEventRowAtIndexPath:indexPath tableView:tableView];
    }
    else if ( cellType == EventCellType_Favorites ) {
        [self didSelectFavoriteRow];
    }
}

- (void)didSelectLocationRow
{
    A3DaysCounterEventDetailLocationViewController *viewCtrl = [[A3DaysCounterEventDetailLocationViewController alloc] initWithNibName:@"A3DaysCounterEventDetailLocationViewController" bundle:nil];
    viewCtrl.location = _eventItem.location;
    viewCtrl.sharedManager = _sharedManager;
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

- (void)didSelectShareEventRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[self] applicationActivities:nil];
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

- (void)didSelectFavoriteRow
{
	[_eventItem toggleFavorite];
    [_eventItem.managedObjectContext MR_saveToPersistentStoreAndWait];

    [self.tableView reloadData];

    if ( self.delegate && [self.delegate respondsToSelector:@selector(willChangeEventDetailViewController:)]) {
        [self.delegate willChangeEventDetailViewController:self];
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
	[self setFirstActionSheet:nil];
	
    if ( buttonIndex == alertView.firstOtherButtonIndex ) {
        if ( self.delegate && [self.delegate respondsToSelector:@selector(willDeleteEvent:daysCounterEventDetailViewController:)]) {
            [self.delegate willDeleteEvent:self.eventItem daysCounterEventDetailViewController:self];
        }
        else {
            [_sharedManager removeEvent:_eventItem inContext:[NSManagedObjectContext MR_rootSavingContext] ];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - UIActionSheetDelegate
- (void)rotateFirstActionSheet {
    [super rotateFirstActionSheet];
    [self setFirstActionSheet:nil];
    [self showActionSheetOfDeleteEventInViewAdaptively];
}

- (void)showActionSheetOfDeleteEventInViewAdaptively {
    //#ifdef __IPHONE_8_0
    //    if (!IS_IOS7 && IS_IPAD) {
    //        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    //        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    //            [alertController dismissViewControllerAnimated:YES completion:NULL];
    //        }]];
    //        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete Event", @"Delete Event") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
    //            if ( self.delegate && [self.delegate respondsToSelector:@selector(willDeleteEvent:daysCounterEventDetailViewController:)]) {
    //                [alertController dismissViewControllerAnimated:YES completion:^{
    //                    [self.delegate willDeleteEvent:self.eventItem daysCounterEventDetailViewController:self];
    //                }];
    //            }
    //            else {
    //                [_sharedManager removeEvent:_eventItem inContext:[NSManagedObjectContext MR_rootSavingContext] ];
    //                [alertController dismissViewControllerAnimated:YES completion:NULL];
    //                [self.navigationController popViewControllerAnimated:YES];
    //            }
    //        }]];
    //        UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    //        popover.sourceView = self.view;
    //        popover.sourceRect = CGRectMake(self.view.center.x, ((UITableViewCell *)sender).center.y + 22, 0, 0);
    //        popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
    //
    //        [self presentViewController:alertController animated:YES completion:NULL];
    //    }
    //    else {
    //        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
    //                                                                 delegate:self
    //                                                        cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
    //                                                   destructiveButtonTitle:NSLocalizedString(@"Delete Event", @"Delete Event")
    //                                                        otherButtonTitles:nil];
    //        [actionSheet showInView:self.view];
    //    }
    //#endif
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                               destructiveButtonTitle:NSLocalizedString(@"Delete Event", @"Delete Event")
                                                    otherButtonTitles:nil];
    [actionSheet showInView:self.view];
    [self setFirstActionSheet:actionSheet];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self setFirstActionSheet:nil];
    
    if ( buttonIndex == actionSheet.destructiveButtonIndex ) {
        if ( self.delegate && [self.delegate respondsToSelector:@selector(willDeleteEvent:daysCounterEventDetailViewController:)]) {
            [self.delegate willDeleteEvent:self.eventItem daysCounterEventDetailViewController:self];
        }
        else {
            [_sharedManager removeEvent:_eventItem inContext:[NSManagedObjectContext MR_rootSavingContext] ];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - action method

- (void)editAction:(id)sender
{
    self.initialCalendarID = _eventItem.calendarID;
    A3DaysCounterAddEventViewController *viewCtrl = [[A3DaysCounterAddEventViewController alloc] init];
	viewCtrl.delegate = self;
	viewCtrl.savingContext = [NSManagedObjectContext MR_rootSavingContext];
    viewCtrl.eventItem = [_eventItem MR_inContext:viewCtrl.savingContext];
    viewCtrl.sharedManager = _sharedManager;
    
    if (IS_IPHONE) {
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
        navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
        navCtrl.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:navCtrl animated:YES completion:nil];
    }
    else {
		A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController_iPad];
        A3NavigationController *nav = [[A3NavigationController alloc] initWithRootViewController:viewCtrl];
        nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [rootViewController presentCenterViewController:nav
                                     fromViewController:self
                                         withCompletion:^{
                                             
                                         }];
    }
}

- (IBAction)deleteEventAction:(id)sender {
    [self showActionSheetOfDeleteEventInViewAdaptively];
}

#pragma mark - UIActivityItemSource
- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
{
    
	if ([activityType isEqualToString:UIActivityTypeMail]) {
        return [NSString stringWithFormat:NSLocalizedString(@"%@ using AppBox Pro", @"%@ using AppBox Pro"), _eventItem.eventName];
	}
    
	return _eventItem.eventName;
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
	return NSLocalizedString(@"Share Days Counter Data", @"Share Days Counter Data");
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
	if ([activityType isEqualToString:UIActivityTypeMail]) {
        
		NSMutableString *txt = [NSMutableString new];

        // 7 days until (계산된 날짜)
        NSString *daysString = [A3DaysCounterModelManager stringOfDurationOption:[_eventItem.durationOption integerValue]
                                                                        fromDate:[NSDate date]
                                                                          toDate:_eventItem.effectiveStartDate
                                                                        isAllDay:[_eventItem.isAllDay boolValue]
                                                                    isShortStyle:NO isStrictShortType:NO];
        NSString *untilSinceString = [A3DateHelper untilSinceStringByFromDate:[NSDate date]
                                                                       toDate:_eventItem.effectiveStartDate
                                                                 allDayOption:[_eventItem.isAllDay boolValue]
                                                                       repeat:[_eventItem.repeatType integerValue] != RepeatType_Never ? YES : NO
                                                                       strict:[A3DaysCounterModelManager hasHourMinDurationOption:[_eventItem.durationOption integerValue]]];
        [txt appendFormat:@"%@<br/>", _eventItem.eventName];
        [txt appendFormat:@"%@ %@<br/>", daysString, untilSinceString];
        
        // Friday, April 11, 2014 (사용자가 입력한 날)
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateStyle:NSDateFormatterFullStyle];
        if (![_eventItem.isAllDay boolValue]) {
            [formatter setTimeStyle:NSDateFormatterShortStyle];
        }
        [txt appendFormat:@"%@<br/>", [A3DateHelper dateStringFromDate:[_eventItem effectiveStartDate]
                                                            withFormat:[formatter dateFormat]] ];

		return [self shareMailMessageWithHeader:NSLocalizedString(@"I'd like to share an event with you.", @"I'd like to share an event with you.")
									   contents:txt
										   tail:NSLocalizedString(@"You can manage your events in the AppBox Pro.", @"You can manage your events in the AppBox Pro.")];
	}
	else {
		NSMutableString *txt = [NSMutableString new];
        // 7 days until (계산된 날짜)
        NSString *daysString = [A3DaysCounterModelManager stringOfDurationOption:[_eventItem.durationOption integerValue]
                                                                        fromDate:[NSDate date]
                                                                          toDate:_eventItem.effectiveStartDate
                                                                        isAllDay:[_eventItem.isAllDay boolValue]
                                                                    isShortStyle:NO isStrictShortType:NO];
        NSString *untilSinceString = [A3DateHelper untilSinceStringByFromDate:[NSDate date]
                                                                       toDate:_eventItem.effectiveStartDate
                                                                 allDayOption:[_eventItem.isAllDay boolValue]
                                                                       repeat:[_eventItem.repeatType integerValue] != RepeatType_Never ? YES : NO
                                                                       strict:[A3DaysCounterModelManager hasHourMinDurationOption:[_eventItem.durationOption integerValue]]];
        [txt appendFormat:@"%@\n", _eventItem.eventName];
        [txt appendFormat:@"%@ %@\n", daysString, untilSinceString];
        
        // Friday, April 11, 2014 (사용자가 입력한 날)
        NSDateFormatter *formatter = [NSDateFormatter new];
		if ([NSDate isFullStyleLocale]) {
			[formatter setDateStyle:NSDateFormatterFullStyle];
			if (![_eventItem.isAllDay boolValue]) {
				[formatter setTimeStyle:NSDateFormatterShortStyle];
			}
		}
		else
		{
            if ([_eventItem.isAllDay boolValue]) {
                [formatter setDateFormat:[formatter customFullStyleFormat]];
            }
            else {
                [formatter setDateFormat:[formatter customFullWithTimeStyleFormat]];
            }
        }
        [txt appendFormat:@"%@\n", [A3DateHelper dateStringFromDate:[_eventItem effectiveStartDate]
                                                         withFormat:[formatter dateFormat]]];
        
		return txt;
	}
}

- (void)viewControllerWillDismissByDeletingEvent {
	[self.navigationController popViewControllerAnimated:NO];
}

@end
