//
//  A3DaysCounterAddEventViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <AddressBookUI/AddressBookUI.h>
#import "A3DaysCounterAddEventViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "A3Formatter.h"
#import "A3DaysCounterSetupRepeatViewController.h"
#import "A3DaysCounterSetupEndRepeatViewController.h"
#import "A3DaysCounterSetupAlertViewController.h"
#import "A3DaysCounterSetupCalendarViewController.h"
#import "A3DaysCounterSetupDurationViewController.h"
#import "A3DaysCounterSetupLocationViewController.h"
#import "DaysCounterCalendar.h"
#import "DaysCounterCalendar+Extension.h"
#import "DaysCounterEvent.h"
#import "DaysCounterEventLocation.h"
#import "DaysCounterDate.h"
#import "NSDate+LunarConverter.h"
#import "SFKImage.h"
#import "Reachability.h"
#import "A3DateHelper.h"
#import "A3WalletNoteCell.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "DaysCounterFavorite.h"
#import "DaysCounterEvent+management.h"
#import "A3JHTableViewExpandableHeaderCell.h"
#import "UITableView+utility.h"
#import "UIViewController+iPad_rightSideView.h"
#import "UIImage+Resizing.h"
#import "NSDateFormatter+A3Addition.h"


#define ActionTag_Location      100
#define ActionTag_Photo         101
#define ActionTag_DeleteEvent   102

@interface A3DaysCounterAddEventViewController () <UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, UIPopoverControllerDelegate, UIPopoverControllerDelegate, A3DateKeyboardDelegate, A3TableViewExpandableHeaderCellProtocol>
@property (strong, nonatomic) NSArray *cellIDArray;
@property (strong, nonatomic) NSMutableArray *sectionTitleArray;
@property (strong, nonatomic) NSString *inputDateKey;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UIPopoverController *imagePickerPopoverController;
@property (assign, nonatomic) BOOL isAdvancedCellOpen;
@property (assign, nonatomic) BOOL isDurationInitialized;//temp...
@property (weak, nonatomic) UITextView *textViewResponder;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@end

@implementation A3DaysCounterAddEventViewController {
	BOOL _isAddingEvent;
}

- (id)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {

	}

	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.cellIDArray = @[@"titleCell", @"photoCell", @"switchCell", @"switchCell", @"switchCell",       // 0 ~ 4
                         @"dateCell", @"dateCell", @"value1Cell", @"value1Cell", @"value1Cell",         // 5 ~ 9
                         @"calendarCell", @"value1Cell", @"value1Cell", @"notesCell", @"dateInputCell", // 10 ~ 14
                         @"", @"", @"advancedCell", @"", @"switchCell"];    // 15 ~ 19
    
    if (_eventItem) {
		_isAddingEvent = NO;
        self.title = NSLocalizedString(@"Edit Event", @"Edit Event");
        _isAdvancedCellOpen = [self hasAdvancedData];
        _isDurationInitialized = YES;

		[_eventItem copyImagesToTemporaryDirectory];
    }
    else {
		_isAddingEvent = YES;
        self.title = NSLocalizedString(@"Add Event", @"Add Event");
        _isAdvancedCellOpen = NO;
        _eventItem = [DaysCounterEvent MR_createEntity];

		// 사진 저장 및 기타 연관 정보 저장을 위해서
		// uniqueID가 필요합니다. 만약 추가인지 수정인지를 구분해야 한다면
		// _isAddingEvent 로 구분을 합니다.
		// 기존에 uniqueID로 구분하던 코드는 모두 _isAddingEvent 로 비교하도록 수정하였습니다.
		_eventItem.uniqueID = [[NSUUID UUID] UUIDString];

        [A3DaysCounterModelManager setDateModelObjectForDateComponents:[[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:[NSDate date]] withEventModel:_eventItem endDate:NO];
        [A3DaysCounterModelManager setDateModelObjectForDateComponents:[[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:[NSDate date]] withEventModel:_eventItem endDate:YES];

        _eventItem.isAllDay = @(YES);
        _eventItem.isLunar = @(NO);
        _eventItem.isPeriod = @(NO);
        _eventItem.durationOption = @(DurationOption_Day);
        _eventItem.repeatType = @(RepeatType_Never);
        _eventItem.repeatEndDate = nil;

        if (self.calendarId) {
            DaysCounterCalendar *selectedCalendar = [[[_sharedManager allUserCalendarList] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"calendarId == %@", self.calendarId]] lastObject];
            if (selectedCalendar) {
                _eventItem.calendar = selectedCalendar;
            }
        }
        else {
            DaysCounterCalendar *anniversaryCalendar = [_sharedManager calendarItemByID:@"1" inContext:[[MagicalRecordStack defaultStack] context] ];
            if (!anniversaryCalendar) {
                anniversaryCalendar = [[[_sharedManager allUserCalendarList] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isShow == %@", @(YES)]] firstObject];
            }
            if (!anniversaryCalendar) {
                anniversaryCalendar = [[_sharedManager allUserCalendarList] firstObject];
            }
            if (anniversaryCalendar) {
                _eventItem.calendar = anniversaryCalendar;
            }
        }
    }

    [self makeBackButtonEmptyArrow];

	[self leftBarButtonCancelButton];
    [self rightBarButtonDoneButton];
    
    if ( _eventItem ) {
        [self configureTableViewDataSourceForEventInfo:_eventItem];
    }
    else {
        if ( [_sharedManager isSupportLunar] ) {
            self.sectionTitleArray = [NSMutableArray arrayWithObjects:
                                      // section 0
                                      @{AddEventSectionName : @"", AddEventItems : [NSMutableArray arrayWithObjects:
                                                                                    @{EventRowTitle : NSLocalizedString(@"Title", @"Title"), EventRowType : @(EventCellType_Title)},
                                                                                    @{EventRowTitle : NSLocalizedString(@"Photo", @"Photo"), EventRowType : @(EventCellType_Photo)}, nil]},
                                      // section 1
                                      @{AddEventSectionName : @"",AddEventItems : [NSMutableArray arrayWithObjects:
                                                                                   @{EventRowTitle : NSLocalizedString(@"Lunar", @"Lunar"), EventRowType : @(EventCellType_IsLunar)},
//                                                                                   @{EventRowTitle : @"All-day", EventRowType : @(EventCellType_IsAllDay)},
                                                                                   @{EventRowTitle : NSLocalizedString(@"Starts-Ends", @"Starts-Ends"), EventRowType : @(EventCellType_IsPeriod)},
                                                                                   @{EventRowTitle : NSLocalizedString(@"Starts", @"Starts"), EventRowType : @(EventCellType_StartDate)},
                                                                                   @{EventRowTitle : NSLocalizedString(@"ADVANCED", @"ADVANCED"), EventRowType : @(EventCellType_Advanced)}, nil]}, nil];
        }
        else {
            self.sectionTitleArray = [NSMutableArray arrayWithObjects:
                                      // section 0
                                      @{AddEventSectionName : @"", AddEventItems : [NSMutableArray arrayWithObjects:
                                                                                    @{EventRowTitle : NSLocalizedString(@"Title", @"Title"), EventRowType : @(EventCellType_Title)},
                                                                                    @{EventRowTitle : NSLocalizedString(@"Photo", @"Photo"), EventRowType : @(EventCellType_Photo)}, nil]},
                                      // section 1
                                      @{AddEventSectionName : @"",AddEventItems : [NSMutableArray arrayWithObjects:
                                                                                   @{EventRowTitle : NSLocalizedString(@"All-day", @"All-day"), EventRowType : @(EventCellType_IsAllDay)},
                                                                                   @{EventRowTitle : NSLocalizedString(@"Starts-Ends", @"Starts-Ends"), EventRowType : @(EventCellType_IsPeriod)},
                                                                                   @{EventRowTitle : NSLocalizedString(@"Starts", @"Starts"), EventRowType : @(EventCellType_StartDate)},
                                                                                   @{EventRowTitle : NSLocalizedString(@"ADVANCED", @"ADVANCED"), EventRowType : @(EventCellType_Advanced)}, nil]}, nil];
        }
    }
        
    [self.navigationController setToolbarHidden:YES];
    isFirstAppear = YES;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, (IS_IPHONE ? 15.0 : 28.0), 0, 0);

	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewDidAppear) name:A3NotificationRightSideViewDidAppear object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewWillDismiss) name:A3NotificationRightSideViewWillDismiss object:nil];
	}
}

- (void)removeObserver {
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationRightSideViewDidAppear object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationRightSideViewWillDismiss object:nil];
	}
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

- (void)rightSideViewDidAppear {
	[self enableControls:NO];
}

- (void)rightSideViewWillDismiss {
	[self enableControls:YES];
}

- (void)enableControls:(BOOL)enable {
	[self.navigationItem.leftBarButtonItem setEnabled:enable];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ( !isFirstAppear ) {
        [self.tableView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    
    if ( isFirstAppear ) {
        [self.tableView reloadData];
        if ( self.eventItem ) {
            isFirstAppear = NO;
        }
    }
    
    if ( self.eventItem == nil && isFirstAppear) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        UITextField *textField = (UITextField*)[cell viewWithTag:10];
        [textField becomeFirstResponder];
        isFirstAppear = NO;
    }
}

- (BOOL)usesFullScreenInLandscape
{
    return (IS_IPAD && UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && _landscapeFullScreen);
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (self.imagePickerPopoverController) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        UIButton *button = (UIButton*)[cell viewWithTag:11];
        CGRect rect = [self.tableView convertRect:button.frame fromView:cell.contentView];
        [self.imagePickerPopoverController presentPopoverFromRect:rect inView:self.tableView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

#pragma mark -

- (BOOL)hasAdvancedData
{
    if ([_eventItem.repeatType integerValue] != 0) {
        return YES;
    }
    
    NSString *alertString = [_sharedManager alertDateStringFromDate:[_eventItem.startDate solarDate]
                                                          alertDate:[_eventItem alertDatetime]];
    if (alertString && ![alertString isEqualToString:NSLocalizedString(@"None", @"None")]) {
        return YES;
    }
    
    NSInteger durationType = [_eventItem.durationOption integerValue];
    if ([_eventItem.isAllDay boolValue] &&  durationType != DurationOption_Day) {
        return YES;
    }
    if (![_eventItem.isAllDay boolValue] &&  durationType != (DurationOption_Day|DurationOption_Hour|DurationOption_Minutes)) {
        return YES;
    }
    
    DaysCounterEventLocation *location = _eventItem.location;
    if ( location ) {
        return YES;
    }
    
    if ([_eventItem.notes length] > 0) {
        return YES;
    }
    
    return NO;
}

- (void)leapMonthCellEnable:(BOOL)isLeapMonth
{
    NSMutableArray *section1_items = [[self.sectionTitleArray objectAtIndex:AddSection_Section_1] objectForKey:AddEventItems];
    NSIndexPath *leapMonthIndexPath = [NSIndexPath indexPathForRow:[self indexOfRowForItemType:EventCellType_IsLeapMonth atSectionArray:section1_items]
                                                         inSection:AddSection_Section_1];
    [self.tableView reloadRowsAtIndexPaths:@[leapMonthIndexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)showKeyboard {
    UITableViewCell *aCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

    if (!aCell) {
        return;
    }
    if (!_isAddingEvent) {
        return;
    }
    
    UITextField *textField = (UITextField*)[aCell viewWithTag:10];
    [textField becomeFirstResponder];
}

#pragma mark -

- (void)alertMessage:(NSString*)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
    [alertView show];
}

- (BOOL)isExistsEndDateCellInItems:(NSArray*)items
{
    BOOL isExists = NO;
    
    for(NSInteger i=0; i < [items count]; i++) {
        NSDictionary *itemDict = [items objectAtIndex:i];
        if ( [[itemDict objectForKey:EventRowType] integerValue] == EventCellType_EndDate ) {
            isExists = YES;
            break;
        }
    }
    
    return isExists;
}

- (void)reloadItems:(NSArray*)items withType:(NSInteger)cellType section:(NSInteger)section
{
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    for(NSInteger i=0; i < [items count]; i++) {
        NSDictionary *itemDict = [items objectAtIndex:i];
        if ( [[itemDict objectForKey:EventRowType] integerValue] == cellType )
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

- (void)reloadItems:(NSArray*)items withType:(NSInteger)cellType section:(NSInteger)section animation:(UITableViewRowAnimation)animation
{
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    for(NSInteger i=0; i < [items count]; i++) {
        NSDictionary *itemDict = [items objectAtIndex:i];
        if ( [[itemDict objectForKey:EventRowType] integerValue] == cellType )
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
    
    if ([indexPaths count] == 0)
        return;
    
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)removeDateInputCellWithItems:(NSMutableArray*)items indexPath:(NSIndexPath*)indexPath
{
    NSInteger type = 0;
    
    if ( [self.inputDateKey isEqualToString:EventItem_StartDate] ) {
        type = EventCellType_StartDate;
    }
    else if ( [self.inputDateKey isEqualToString:EventItem_EndDate] ) {
        type = EventCellType_EndDate;
    }
    
    NSInteger index = 0;
    for (NSDictionary *item in items) {
        if ( [[item objectForKey:EventRowType] integerValue] == type ) {
            break;
        }
        index++;
    }
    NSIndexPath *removeIndexPath = [NSIndexPath indexPathForRow:index+1 inSection:indexPath.section];
    [items removeObjectAtIndex:removeIndexPath.row];
    [self.tableView beginUpdates];
    self.inputDateKey = nil;
    [self.tableView deleteRowsAtIndexPaths:@[removeIndexPath] withRowAnimation:UITableViewRowAnimationMiddle];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (void)configureTableViewDataSourceForEventInfo:(DaysCounterEvent*)info
{
    NSMutableArray *section1_Items = [NSMutableArray array];
    
    if ([_sharedManager isSupportLunar]) {
        [section1_Items addObject:@{ EventRowTitle : NSLocalizedString(@"Lunar", @"Lunar"), EventRowType : @(EventCellType_IsLunar)}];
        if ([info.isLunar boolValue]) {
            [section1_Items addObject:@{ EventRowTitle : NSLocalizedString(@"Leap Month", @"Leap Month"), EventRowType : @(EventCellType_IsLeapMonth)}];
        }
        else {
            [section1_Items addObject:@{ EventRowTitle : NSLocalizedString(@"All-day", @"All-day"), EventRowType : @(EventCellType_IsAllDay)}];
        }
    }
    else {
        [section1_Items addObject:@{ EventRowTitle : NSLocalizedString(@"All-day", @"All-day"), EventRowType : @(EventCellType_IsAllDay)}];
        _eventItem.isLunar = @(NO);
    }
    
    if (![info.isLunar boolValue]) {
        [section1_Items addObject:@{ EventRowTitle : NSLocalizedString(@"Starts-Ends", @"Starts-Ends"), EventRowType : @(EventCellType_IsPeriod)}];
    }
    
    [section1_Items addObject:@{ EventRowTitle : NSLocalizedString(@"Starts", @"Starts"), EventRowType : @(EventCellType_StartDate)}];
    
    if ( [info.isPeriod boolValue] ) {
        [section1_Items addObject:@{ EventRowTitle : NSLocalizedString(@"Ends", @"Ends"), EventRowType : @(EventCellType_EndDate) }];
    }
    
    [section1_Items addObject:@{ EventRowTitle : NSLocalizedString(@"ADVANCED", @"ADVANCED"), EventRowType : @(EventCellType_Advanced)}];
    if (_isAdvancedCellOpen) {
        [section1_Items addObject:@{ EventRowTitle : NSLocalizedString(@"Repeat", @"Repeat"), EventRowType : @(EventCellType_RepeatType)}];
        if ( [info.repeatType integerValue] != RepeatType_Never ) {
            [section1_Items addObject:@{ EventRowTitle : NSLocalizedString(@"End Repeat", @"End Repeat"), EventRowType : @(EventCellType_EndRepeatDate)}];
        }
        [section1_Items addObject:@{ EventRowTitle : NSLocalizedString(@"Alert", @"Alert"), EventRowType : @(EventCellType_Alert)}];
        [section1_Items addObject:@{ EventRowTitle : NSLocalizedString(@"Calendar", @"Calendar"), EventRowType : @(EventCellType_Calendar)}];
        [section1_Items addObject:@{ EventRowTitle : NSLocalizedString(@"Duration Option", @"Duration Option"), EventRowType : @(EventCellType_DurationOption)}];
        [section1_Items addObject:@{ EventRowTitle : NSLocalizedString(@"Location", @"Location"), EventRowType : @(EventCellType_Location)}];
        [section1_Items addObject:@{ EventRowTitle : NSLocalizedString(@"Notes", @"Notes"), EventRowType : @(EventCellType_Notes)}];
    }
    
    self.sectionTitleArray = [NSMutableArray arrayWithObjects:
                              // section 0
                              @{AddEventSectionName : @"",
                                AddEventItems : [NSMutableArray arrayWithObjects:@{EventRowTitle : NSLocalizedString(@"Title", @"Title"),
                                                                                   EventRowType : @(EventCellType_Title)},
                                                 @{EventRowTitle : NSLocalizedString(@"Photo", @"Photo"),
                                                   EventRowType : @(EventCellType_Photo)}, nil]},
                              // section 1
                              @{AddEventSectionName : @"", AddEventItems : section1_Items}, nil];
}

#pragma mark - Table view data source

- (NSString*)cellIdentifierAtIndexPath:(NSIndexPath*)indexPath
{
    if ( _eventItem && indexPath.section == [_sectionTitleArray count] )
        return @"normalCell";
    
    NSArray *items = [[_sectionTitleArray objectAtIndex:indexPath.section] objectForKey:AddEventItems];
    NSDictionary *itemDict = [items objectAtIndex:indexPath.row];
    NSInteger itemType = [[itemDict objectForKey:EventRowType] integerValue];
    
    return [self.cellIDArray objectAtIndex:itemType];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [self cellIdentifierAtIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [self createCellAtIndexPath:indexPath cellIdentifier:CellIdentifier];
    }
    if (!(_eventItem && indexPath.section == [_sectionTitleArray count])) {
        [self updateTableViewCell:cell atIndexPath:indexPath];
    }
    
    return cell;
}

- (UITableViewCell*)createCellAtIndexPath:(NSIndexPath*)indexPath cellIdentifier:(NSString*)cellIdentifier
{
    UITableViewCell *cell = nil;
    
    if ( _eventItem && indexPath.section == [_sectionTitleArray count] ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.text = NSLocalizedString(@"Delete Event", @"Delete Event");
        cell.textLabel.textColor = [UIColor colorWithRed:1.0 green:59.0/255.0 blue:48.0/255.0 alpha:1.0];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont systemFontOfSize:17];
    }
    else {
        NSArray *items = [[_sectionTitleArray objectAtIndex:indexPath.section] objectForKey:AddEventItems];
        NSDictionary *itemDict = [items objectAtIndex:indexPath.row];
        NSInteger itemType = [[itemDict objectForKey:EventRowType] integerValue];
        
        if ( itemType == EventCellType_RepeatType || itemType == EventCellType_EndRepeatDate || itemType == EventCellType_Alert || itemType == EventCellType_DurationOption || itemType == EventCellType_Location) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
            cell.textLabel.tag = 10;
            cell.detailTextLabel.tag = 11;
        }
        else {
            switch (itemType) {
                case EventCellType_Title :
                {
                    cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterAddEventTitleCell" owner:nil options:nil] lastObject];
                    UITextField *textField = (UITextField*)[cell viewWithTag:10];
                    UIButton *button = (UIButton*)[cell viewWithTag:11];
                    textField.delegate = self;
                    [button addTarget:self action:@selector(toggleFavorite:) forControlEvents:UIControlEventTouchUpInside];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
					break;
				}
                case EventCellType_Photo:
                {
                    cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterAddEventPhotoCell" owner:nil options:nil] lastObject];
                    UIButton *button = (UIButton*)[cell viewWithTag:11];
                    [button addTarget:self action:@selector(photoAction:) forControlEvents:UIControlEventTouchUpInside];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
					break;
				}
                case EventCellType_IsLunar:
                case EventCellType_IsAllDay:
                case EventCellType_IsPeriod:
                case EventCellType_IsLeapMonth:
                {
                    cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterAddEventSwitchCell" owner:nil options:nil] lastObject];
                    UISwitch *swButton = (UISwitch*)[cell viewWithTag:11];
                    [swButton addTarget:self action:@selector(toggleSwitchAction:) forControlEvents:UIControlEventValueChanged];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
					break;
				}
                case EventCellType_StartDate:
                case EventCellType_EndDate:{
                    cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterAddEventDateCell" owner:nil options:nil] lastObject];
                    UIImageView *imageView = (UIImageView*)[cell viewWithTag:11];
                    [SFKImage setDefaultFont:[UIFont fontWithName:@"appbox" size:46.0]];
                    [SFKImage setDefaultColor:[UIColor colorWithRed:159/255.0 green:159/255.0 blue:159/255.0 alpha:1.0]];
                    imageView.image = [SFKImage imageNamed:@"f"];
                    imageView.tintColor = [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1.0];
					break;
				}
                case EventCellType_Calendar:
                {
                    cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterAddEventCalendarCell" owner:nil options:nil] lastObject];
                    UIImageView *imageView = (UIImageView*)[cell viewWithTag:11];
                    imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
					break;
				}
                case EventCellType_Notes:{
					A3WalletNoteCell *noteCell = [A3WalletNoteCell new];
					[noteCell setupTextView];

					noteCell.textView.delegate = self;

					cell = noteCell;
					break;
				}
                case EventCellType_DateInput:{
                    cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterAddEventDateInputCell" owner:nil options:nil] lastObject];
                    UIDatePicker *datePicker = (UIDatePicker*)[cell viewWithTag:10];
                    [datePicker addTarget:self action:@selector(dateChangeAction:) forControlEvents:UIControlEventValueChanged];
					break;
				}
                case EventCellType_Advanced:{
					A3JHTableViewExpandableHeaderCell *expandableCell = [[A3JHTableViewExpandableHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
					expandableCell.expandButton.transform = CGAffineTransformRotate(CGAffineTransformIdentity, (CGFloat) DegreesToRadians(_isAdvancedCellOpen ? -179.9 : 0 ));
					expandableCell.delegate = self;
					expandableCell.titleLabel.text = @"ADVANCED";
					cell = expandableCell;
					break;
				}
            }
        }
        if ( cell && (itemType != EventCellType_DateInput) ) {
            UIView *leftView = [cell viewWithTag:10];
            for(NSLayoutConstraint *layout in cell.contentView.constraints ) {
                if ( layout.firstAttribute == NSLayoutAttributeLeading && layout.firstItem == leftView ) {
                    layout.constant = (IS_IPHONE ? 15.0 : 28.0);
                    break;
                }
            }
        }
    }
    
    return cell;
}

- (void)expandButtonPressed:(UIButton *)expandButton {
	[self advancedRowTouchedUp:[self.tableView indexPathForCellSubview:expandButton]];
}

- (void)updateTableViewCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    NSArray *items = [[_sectionTitleArray objectAtIndex:indexPath.section] objectForKey:AddEventItems];
    NSDictionary *itemDict = [items objectAtIndex:indexPath.row];
    NSInteger itemType = [[itemDict objectForKey:EventRowType] integerValue];
    
    cell.separatorInset = UIEdgeInsetsMake(0, IS_IPHONE ? 15 : 28, 0, 0);
    
    switch (itemType) {
        case EventCellType_Title :
        {
            UITextField *textField = (UITextField*)[cell viewWithTag:10];
            UIButton *button = (UIButton*)[cell viewWithTag:11];
            textField.text = _eventItem.eventName;
            
            BOOL isSelected = _eventItem.favorite != nil;
            [button setImage:[UIImage imageNamed:isSelected ? @"star02_on" : @"star02"] forState:UIControlStateNormal];
            button.tintColor = [A3AppDelegate instance].themeColor;
        }
            break;
        case EventCellType_Photo:
        {
            [self photoTableViewCell:cell itemType:itemType];
        }
            break;
        case EventCellType_IsLunar:
        {
            UILabel *titleLabel = (UILabel*)[cell viewWithTag:10];
            UISwitch *swButton = (UISwitch*)[cell viewWithTag:11];
            titleLabel.text = [itemDict objectForKey:EventRowTitle];
            swButton.on = [_eventItem.isLunar boolValue];
            swButton.enabled = YES;
            break;
        }
            break;
        case EventCellType_IsAllDay:
        {
            UILabel *titleLabel = (UILabel*)[cell viewWithTag:10];
            UISwitch *swButton = (UISwitch*)[cell viewWithTag:11];
            titleLabel.text = [itemDict objectForKey:EventRowTitle];
            swButton.on = [_eventItem.isAllDay boolValue];
            swButton.enabled = YES;
        }
            break;
        case EventCellType_IsPeriod:
        {
            UILabel *titleLabel = (UILabel*)[cell viewWithTag:10];
            UISwitch *swButton = (UISwitch*)[cell viewWithTag:11];
            titleLabel.text = [itemDict objectForKey:EventRowTitle];
            swButton.on = [_eventItem.isPeriod boolValue];
            swButton.enabled = YES;
        }
            break;
        case EventCellType_IsLeapMonth:
        {
            [self leapMonthTableViewCell:cell itemType:itemType title:[itemDict objectForKey:EventRowTitle]];
        }
            break;
        case EventCellType_StartDate:
        case EventCellType_EndDate:
        {
            [self startEndDateTableViewCell:cell itemType:itemType];
        }
            break;
        case EventCellType_RepeatType:
        {
            [self repeatTypeTableViewCell:cell itemType:itemType title:[itemDict objectForKey:EventRowTitle]];
        }
            break;
        case EventCellType_EndRepeatDate:
        {
            [self endRepeatDateTableViewCell:cell itemType:itemType title:[itemDict objectForKey:EventRowTitle]];
        }
            break;
        case EventCellType_Alert:
        {
            [self alertTableViewCell:cell itemType:itemType title:[itemDict objectForKey:EventRowTitle]];
        }
            break;
        case EventCellType_Calendar:
        {
            [self calendarTableViewCell:cell itemType:itemType];
        }
            break;
        case EventCellType_DurationOption:
        {
            [self durationOptionTableViewCell:cell itemType:itemType title:[itemDict objectForKey:EventRowTitle]];
        }
            break;
        case EventCellType_Location:
        {
            [self locationTableViewCell:cell itemType:itemType];
        }
            break;
        case EventCellType_Notes:
        {
            [self noteTableViewCell:cell itemType:itemType];
        }
            break;
        case EventCellType_DateInput:
        {
            [self dateInputTableViewCell:cell itemType:itemType];
        }
            break;
        case EventCellType_Advanced:
        {
            [self advancedTableViewCell:cell itemType:itemType];
        }
            break;
    }
}

#pragma mark Cells

- (void)photoTableViewCell:(UITableViewCell *)cell itemType:(NSInteger)itemType
{
    UIButton *button = (UIButton*)[cell viewWithTag:11];
	if ([_eventItem.hasPhoto boolValue]) {
		button.layer.cornerRadius = button.bounds.size.width / 2.0;
		button.layer.masksToBounds = YES;
		button.contentMode = UIViewContentModeScaleAspectFill;
		[button setImage:[_eventItem thumbnailImageInOriginalDirectory:NO] forState:UIControlStateNormal];
	} else {
		button.layer.masksToBounds = NO;
		[button setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
	}
}

- (void)leapMonthTableViewCell:(UITableViewCell *)cell itemType:(NSInteger)itemType title:(NSString *)title
{
    UILabel *titleLabel = (UILabel*)[cell viewWithTag:10];
    UISwitch *swButton = (UISwitch*)[cell viewWithTag:11];
    titleLabel.text = title;
    
    BOOL isStartDateLeapMonth = [NSDate isLunarLeapMonthAtDateComponents:[A3DaysCounterModelManager dateComponentsFromDateModelObject:_eventItem.startDate toLunar:YES]
                                                                isKorean:[A3DateHelper isCurrentLocaleIsKorea]];
    BOOL isEndDateLeapMonth = NO;
    if (_eventItem.endDate) {
        isEndDateLeapMonth = [NSDate isLunarLeapMonthAtDateComponents:[A3DaysCounterModelManager dateComponentsFromDateModelObject:_eventItem.endDate toLunar:YES]
                                                             isKorean:[A3DateHelper isCurrentLocaleIsKorea]];
    }
    
    if (isStartDateLeapMonth || isEndDateLeapMonth) {
        swButton.enabled = YES;
        swButton.on = YES;
    }
    else {
        swButton.enabled = NO;
        swButton.on = NO;
    }
}

- (void)startEndDateTableViewCell:(UITableViewCell *)cell itemType:(NSInteger)itemType
{
    NSString *keyName = itemType == EventCellType_StartDate ? EventItem_StartDate : EventItem_EndDate;
    UILabel *titleLabel = (UILabel*)[cell viewWithTag:10];
    UIImageView *lunarImageView = (UIImageView*)[cell viewWithTag:11];
    UILabel *dateLabel = (UILabel*)[cell viewWithTag:12];
    UITextField *dateTextField = (UITextField *)[cell viewWithTag:14];
    dateTextField.delegate = self;
    
    if ( [_eventItem.isPeriod boolValue] ) {
        titleLabel.text = itemType == EventCellType_StartDate ? NSLocalizedString(@"Starts", @"Starts") : NSLocalizedString(@"Ends", @"Ends");
    }
    else {
        titleLabel.text = NSLocalizedString(@"Date", @"Date");
    }
    
    lunarImageView.hidden = YES;
    NSDate *keyDate = itemType == EventCellType_StartDate ? [_eventItem.startDate solarDate] : [_eventItem.endDate solarDate];
    NSAssert(keyDate, @"start/end default date is not nil.");
    if ([_eventItem.isLunar boolValue]) {
        dateLabel.text = [A3DaysCounterModelManager dateStringOfLunarFromDateModel:itemType == EventCellType_StartDate ? _eventItem.startDate : _eventItem.endDate
                                                                       isLeapMonth:itemType == EventCellType_StartDate ? [_eventItem.startDate.isLeapMonth boolValue] : [_eventItem.endDate.isLeapMonth boolValue] ];
    }
    else {
        dateLabel.text = [A3DaysCounterModelManager dateStringFromDateModel:itemType == EventCellType_StartDate ? _eventItem.startDate : _eventItem.endDate isLunar:NO isAllDay:[_eventItem.isAllDay boolValue]];
    }
    
    NSInteger inputType;
    if ([self.inputDateKey isEqualToString:EventItem_StartDate]) {
        inputType = EventCellType_StartDate;
    }
    else {
        if ([self.inputDateKey isEqualToString:EventItem_EndDate]) {
            inputType = EventCellType_EndDate;
        }
        else {
            inputType = 0;
        }
    }
    
    if (self.inputDateKey) {
        if ([self.inputDateKey isEqualToString:EventItem_StartDate] && itemType == EventCellType_EndDate) {
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
        else if ([self.inputDateKey isEqualToString:EventItem_EndDate] && itemType == EventCellType_StartDate) {
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
        else {
            if (![_eventItem.isPeriod boolValue]) {
                NSMutableArray *sectionRow_items = [[_sectionTitleArray objectAtIndex:AddSection_Section_1] objectForKey:AddEventItems];
                NSInteger dateInputRowIndex = [self indexOfRowForItemType:EventCellType_DateInput atSectionArray:sectionRow_items];
                if (dateInputRowIndex == -1) {
                    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
                }
                else {
                    cell.separatorInset = UIEdgeInsetsMake(0, IS_IPHONE ? 15 : 28, 0, 0);
                }
            }
            else {
                cell.separatorInset = UIEdgeInsetsMake(0, IS_IPHONE ? 15 : 28, 0, 0);
            }
        }
    }
    else {
        if ([_eventItem.isPeriod boolValue] && itemType == EventCellType_StartDate) {
            cell.separatorInset = UIEdgeInsetsMake(0, IS_IPHONE ? 15 : 28, 0, 0);
        }
        else {
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
    }
    
    if ( [keyName isEqualToString:self.inputDateKey] && itemType == inputType ) {
        dateLabel.textColor = [A3AppDelegate instance].themeColor;
    }
    else {
        dateLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
    }
    
    if ( [_eventItem.isPeriod boolValue] && itemType == EventCellType_EndDate ) {
        NSDate *startDate = [_eventItem.startDate solarDate];
        if ( _eventItem.endDate ) {
            NSDate *endDate = [_eventItem.endDate solarDate];
            if ( [endDate timeIntervalSince1970] < [startDate timeIntervalSince1970] ) {
                NSDictionary *attr = @{NSFontAttributeName: dateLabel.font, NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle)};
                dateLabel.attributedText = [[NSAttributedString alloc] initWithString:dateLabel.text attributes:attr];
            }
            else {
                NSDictionary *attr = @{NSFontAttributeName: dateLabel.font, NSStrikethroughStyleAttributeName : @(NSUnderlineStyleNone)};
                dateLabel.attributedText = [[NSAttributedString alloc] initWithString:dateLabel.text attributes:attr];
            }
        }
    }
}

- (void)repeatTypeTableViewCell:(UITableViewCell *)cell itemType:(NSInteger)itemType title:(NSString *)title
{
    UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
    cell.textLabel.text = title;
    NSNumber *repeatType = _eventItem.repeatType;
    if (!repeatType || [repeatType isEqualToNumber:@(RepeatType_Never)]) {
        cell.detailTextLabel.text = [_sharedManager repeatTypeStringFromValue:RepeatType_Never];
    }
    else {
        cell.detailTextLabel.text = [_sharedManager repeatTypeStringFromValue:[repeatType integerValue]];
    }
    
    textLabel.textColor = [UIColor blackColor];
}

- (void)endRepeatDateTableViewCell:(UITableViewCell *)cell itemType:(NSInteger)itemType title:(NSString *)title
{
    cell.textLabel.text = title;
    //cell.detailTextLabel.text = [A3DateHelper dateStringFromDate:[_eventItem repeatEndDate] withFormat:[A3DaysCounterModelManager dateFormatForDetailIsAllDays:YES]];
    if (IS_IPAD) {
        cell.detailTextLabel.text = [self fullStyleDateStringFromDate:[_eventItem repeatEndDate] withShortTime:NO];
    }
    else {
        NSDateFormatter *formatter = [NSDateFormatter new];
        cell.detailTextLabel.text = [A3DateHelper dateStringFromDate:[_eventItem repeatEndDate] withFormat:[formatter customFullStyleFormat]];
    }
    
    cell.textLabel.textColor = [UIColor blackColor];
}

- (void)alertTableViewCell:(UITableViewCell *)cell itemType:(NSInteger)itemType title:(NSString *)title
{
    cell.textLabel.text = title;
    cell.detailTextLabel.text = [_sharedManager alertDateStringFromDate:_eventItem.effectiveStartDate
                                                                                         alertDate:_eventItem.alertDatetime];
    
    cell.textLabel.textColor = [UIColor blackColor];
}

- (void)calendarTableViewCell:(UITableViewCell *)cell itemType:(NSInteger)itemType
{
    UILabel *nameLabel = (UILabel*)[cell viewWithTag:12];
    UIImageView *colorImageView = (UIImageView*)[cell viewWithTag:11];
    
    DaysCounterCalendar *calendar = _eventItem.calendar;
    if (calendar) {
        nameLabel.text = calendar.calendarName;
        colorImageView.tintColor = [calendar color];
    }
    else {
        nameLabel.text = @"";
    }
    
    colorImageView.hidden = ([nameLabel.text length] < 1 );
}

- (void)durationOptionTableViewCell:(UITableViewCell *)cell itemType:(NSInteger)itemType title:(NSString *)title
{
    cell.textLabel.text = title;
    cell.detailTextLabel.text = [_sharedManager durationOptionStringFromValue:[_eventItem.durationOption integerValue]];
    cell.textLabel.textColor = [UIColor blackColor];
}

- (void)locationTableViewCell:(UITableViewCell *)cell itemType:(NSInteger)itemType
{
    UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
    UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:11];
    DaysCounterEventLocation *location = _eventItem.location;
    if ( location ) {
        FSVenue *venue = [[FSVenue alloc] init];
        venue.location.country = location.country;
        venue.location.state = location.state;
        venue.location.city = location.city;
        venue.location.address = location.address;
        textLabel.text = location.locationName;
        textLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
    }
    else {
        textLabel.text = NSLocalizedString(@"Location", @"Location");
        textLabel.textColor = [UIColor colorWithRed:199/255.0 green:199/255.0 blue:205/255.0 alpha:1.0];
    }
    
    detailTextLabel.text = @"";
}

- (void)noteTableViewCell:(UITableViewCell *)cell itemType:(NSInteger)itemType
{
	A3WalletNoteCell *noteCell = (A3WalletNoteCell *) cell;
	noteCell.textView.text = _eventItem.notes;
}

- (void)dateInputTableViewCell:(UITableViewCell *)cell itemType:(NSInteger)itemType
{
    UIDatePicker *datePicker = (UIDatePicker*)[cell viewWithTag:10];
    if ( [self.inputDateKey isEqualToString: EventItem_StartDate] ) {
        NSDate *date = [_eventItem.startDate solarDate];
        if (!date) {
            date = [_eventItem.endDate solarDate] ? [_eventItem.endDate solarDate] : [NSDate date];
        }
        
        datePicker.date = date;
        
        if ([_eventItem.isPeriod boolValue]) {
            cell.separatorInset = UIEdgeInsetsMake(0, IS_IPHONE ? 15 : 28, 0, 0);
        }
        else {
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
    }
    else if ( [self.inputDateKey isEqualToString: EventItem_EndDate] ) {
        NSDate *date = [_eventItem.endDate solarDate];
        if (!date) {
            date = [_eventItem.startDate solarDate] ? [_eventItem.startDate solarDate] : [NSDate date];
        }
        
        datePicker.date = date;
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    else {
        NSAssert(NO, @"why");
        //                datePicker.date = ([[_eventModel objectForKey:self.inputDateKey] isKindOfClass:[NSDate class]] ? [_eventModel objectForKey:self.inputDateKey] : [NSDate date]);
    }
    
    if ( [_eventItem.isAllDay boolValue] ) {
        datePicker.datePickerMode = UIDatePickerModeDate;
    }
    else {
        datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    }
}

- (void)advancedTableViewCell:(UITableViewCell *)cell itemType:(NSInteger)itemType
{
	A3JHTableViewExpandableHeaderCell *expandableCell = (A3JHTableViewExpandableHeaderCell *) cell;
    if (_isAdvancedCellOpen) {
        expandableCell.titleLabel.textColor = [A3AppDelegate instance].themeColor;
    }
    else {
        expandableCell.titleLabel.textColor = [UIColor colorWithRed:109.0/255.0 green:109.0/255.0 blue:114.0/255.0 alpha:1.0];
    }
    expandableCell.expandButton.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DegreesToRadians((_isAdvancedCellOpen ?  -179.9 : 0)));
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark TableView Data Source Related
- (NSInteger)indexOfRowForItemType:(A3DaysCounterAddEventCellType)itemType atSectionArray:(NSArray *)array {
    __block NSInteger rowIndex = -1;
    
    [array enumerateObjectsUsingBlock:^(NSDictionary *rowData, NSUInteger idx, BOOL *stop) {
        if ([[rowData objectForKey:EventRowType] isEqualToNumber:@(itemType)]) {
            rowIndex = (NSInteger)idx;
            *stop = YES;
        }
    }];
    
    return rowIndex;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self resignAllAction];
    if ( _eventItem && indexPath.section == [_sectionTitleArray count] ) {
        [self deleteEventAction:nil];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    NSArray *items = [[_sectionTitleArray objectAtIndex:indexPath.section] objectForKey:AddEventItems];
    NSDictionary *rowItemData = [items objectAtIndex:indexPath.row];
    NSInteger rowItemType = [[rowItemData objectForKey:EventRowType] integerValue];
    
    switch (rowItemType) {
        case EventCellType_Title:
        {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            UITextField *textField = (UITextField*)[cell viewWithTag:10];
            [textField becomeFirstResponder];
            [self closeDatePickerCell];
        }
            break;
        case EventCellType_Photo:
        {
            [self photoAction:nil];
            [self closeDatePickerCell];
        }
            break;
        case EventCellType_StartDate:
        case EventCellType_EndDate:
        {
            [self didSelectStartEndDateCellAtIndexPath:indexPath tableView:tableView rowItemType:rowItemType];
        }
            break;
        case EventCellType_RepeatType:
        {
            [self didSelectRepeatTypeRowAtIndexPath:indexPath tableView:tableView];
        }
            break;
        case EventCellType_EndRepeatDate:
        {
            [self didSelectEndRepeatDateCellAtTableView:tableView];
        }
            break;
        case EventCellType_Alert:
        {
            [self didSelectAlertCellAtIndexPath:indexPath tableView:tableView];
        }
            break;
        case EventCellType_Calendar:
        {
            [self didSelectCalendarCellAtIndexPath:indexPath tableView:tableView];
        }
            break;
        case EventCellType_DurationOption:
        {
            [self didSelectDurationOptionCellAtIndexPath:indexPath tableView:tableView];
        }
            break;
        case EventCellType_Location:
        {
            [self didSelectLocationCellAtIndexPath:indexPath tableView:tableView];
        }
            break;
        case EventCellType_Advanced:
        {
            [self advancedRowTouchedUp:indexPath];
        }
            break;
    }
}

#pragma mark didSelect specific row

- (void)didSelectStartEndDateCellAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView rowItemType:(NSInteger)rowItemType
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([_eventItem.isLunar boolValue]) {
        self.inputDateKey = rowItemType == EventCellType_StartDate ? EventItem_StartDate : EventItem_EndDate;
        
        UITextField *textField = (UITextField *)[cell viewWithTag:14];
        [textField becomeFirstResponder];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else {
        UIButton *button = (UIButton*)[cell viewWithTag:13];
        [self toggleDateInputAction:button];
    }
}

- (void)didSelectRepeatTypeRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
    A3DaysCounterSetupRepeatViewController *nextVC = [[A3DaysCounterSetupRepeatViewController alloc] initWithNibName:nil bundle:nil];
    nextVC.eventModel = _eventItem;
    nextVC.sharedManager = _sharedManager;
    nextVC.dismissCompletionBlock = ^{
        NSNumber *repeatType = _eventItem.repeatType;
        if (!repeatType) {
            return;
        }
        
        NSMutableArray *section1_items = [[self.sectionTitleArray objectAtIndex:AddSection_Section_1] objectForKey:AddEventItems];
        NSIndexPath *repeatIndexPath = [NSIndexPath indexPathForRow:[self indexOfRowForItemType:EventCellType_RepeatType atSectionArray:section1_items]
                                                          inSection:AddSection_Section_1];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:repeatIndexPath];
        cell.detailTextLabel.text = [_sharedManager repeatTypeStringFromValue:[repeatType integerValue]];
        
        if ([repeatType integerValue] == RepeatType_Never) {
            // EffectiveStartDate 갱신.
            _eventItem.effectiveStartDate =[_eventItem.startDate solarDate];
            _eventItem.repeatEndDate = nil;
            
            // EndRepeatRow 제거.
            NSMutableArray *section1_items = [[self.sectionTitleArray objectAtIndex:AddSection_Section_1] objectForKey:AddEventItems];
            
            NSInteger endRepeatRowIndex = [self indexOfRowForItemType:EventCellType_EndRepeatDate atSectionArray:section1_items];
            if (endRepeatRowIndex == -1) {
                return;
            }
            [section1_items removeObjectAtIndex:endRepeatRowIndex];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:endRepeatRowIndex inSection:AddSection_Section_1]] withRowAnimation:UITableViewRowAnimationMiddle];
            
            return;
        }
        
        // EffectiveStartDate & EffectiveAlertDate 갱신.
        [_sharedManager recalculateEventDatesForEvent:_eventItem];
        // AlertCell 갱신.
        NSIndexPath *alertIndexPath = [NSIndexPath indexPathForRow:[self indexOfRowForItemType:EventCellType_Alert atSectionArray:section1_items]
                                                         inSection:AddSection_Section_1];
        [tableView deselectRowAtIndexPath:alertIndexPath animated:YES];
        cell = [tableView cellForRowAtIndexPath:alertIndexPath];
        UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:11];
        detailTextLabel.text = [_sharedManager alertDateStringFromDate:_eventItem.effectiveStartDate
                                                             alertDate:_eventItem.alertDatetime];
        // EndRepeatDate 유무 확인.
        __block NSInteger endRepeatRowIndex = -1;
        [section1_items enumerateObjectsUsingBlock:^(NSDictionary *rowData, NSUInteger idx, BOOL *stop) {
            if ([[rowData objectForKey:EventRowType] isEqualToNumber:@(EventCellType_EndRepeatDate)]) {
                endRepeatRowIndex = (NSInteger)idx;
                *stop = YES;
            }
        }];
        
        if (endRepeatRowIndex == -1) {
            // EndRepeatDate 추가.
            __block NSInteger repeatTypeRowIndex = -1;
            [section1_items enumerateObjectsUsingBlock:^(NSDictionary *rowData, NSUInteger idx, BOOL *stop) {
                if ([[rowData objectForKey:EventRowType] isEqualToNumber:@(EventCellType_RepeatType)]) {
                    repeatTypeRowIndex = (NSInteger)idx;
                    *stop = YES;
                }
            }];
            
            // EndRepeat Row 추가 & Reload
            [section1_items insertObject:@{ EventRowTitle : NSLocalizedString(@"End Repeat", @"End Repeat"), EventRowType : @(EventCellType_EndRepeatDate)} atIndex:repeatTypeRowIndex + 1];
            NSMutableArray *indexPathsToReload = [NSMutableArray new];
            for (NSInteger row = repeatTypeRowIndex + 2; row < [section1_items count]; row++) {
                [indexPathsToReload addObject:[NSIndexPath indexPathForRow:row inSection:AddSection_Section_1]];
            }
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:repeatTypeRowIndex inSection:AddSection_Section_1]] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:repeatTypeRowIndex + 1 inSection:AddSection_Section_1]] withRowAnimation:UITableViewRowAnimationMiddle];
            [self.tableView endUpdates];
        }
    };
    
    if ( IS_IPHONE ) {
        [self.navigationController pushViewController:nextVC animated:YES];
    }
    else {
        [self.A3RootViewController presentRightSideViewController:nextVC];
    }
    
    [self closeDatePickerCell];
}

- (void)didSelectEndRepeatDateCellAtTableView:(UITableView *)tableView
{
    A3DaysCounterSetupEndRepeatViewController *nextVC = [[A3DaysCounterSetupEndRepeatViewController alloc] initWithNibName:@"A3DaysCounterSetupEndRepeatViewController" bundle:nil];
    nextVC.eventModel = self.eventItem;
    nextVC.sharedManager = _sharedManager;
    nextVC.dismissCompletionBlock = ^{
        NSMutableArray *section1_items = [[self.sectionTitleArray objectAtIndex:AddSection_Section_1] objectForKey:AddEventItems];
        NSIndexPath *endRepeatIndexPath = [NSIndexPath indexPathForRow:[self indexOfRowForItemType:EventCellType_EndRepeatDate atSectionArray:section1_items]
                                                             inSection:AddSection_Section_1];
        [tableView deselectRowAtIndexPath:endRepeatIndexPath animated:YES];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:endRepeatIndexPath];
        cell.detailTextLabel.text = [A3DateHelper dateStringFromDate:[_eventItem repeatEndDate] withFormat:[A3DaysCounterModelManager dateFormatForDetailIsAllDays:YES]];
    };
    
    if ( IS_IPHONE )
        [self.navigationController pushViewController:nextVC animated:YES];
    else
        [self.A3RootViewController presentRightSideViewController:nextVC];
    [self closeDatePickerCell];
}

- (void)didSelectAlertCellAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    A3DaysCounterSetupAlertViewController *nextVC = [[A3DaysCounterSetupAlertViewController alloc] initWithNibName:@"A3DaysCounterSetupAlertViewController" bundle:nil];
    [_sharedManager recalculateEventDatesForEvent:_eventItem];
    nextVC.eventModel = self.eventItem;
    nextVC.sharedManager = _sharedManager;
    nextVC.dismissCompletionBlock = ^{
        NSMutableArray *section1_items = [[self.sectionTitleArray objectAtIndex:AddSection_Section_1] objectForKey:AddEventItems];
        NSIndexPath *alertIndexPath = [NSIndexPath indexPathForRow:[self indexOfRowForItemType:EventCellType_Alert atSectionArray:section1_items]
                                                         inSection:AddSection_Section_1];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:alertIndexPath];
        cell.detailTextLabel.text = [_sharedManager alertDateStringFromDate:_eventItem.effectiveStartDate
                                                                  alertDate:_eventItem.alertDatetime];
    };
    
    if ( IS_IPHONE ) {
        [self.navigationController pushViewController:nextVC animated:YES];
    }
    else {
        [self.A3RootViewController presentRightSideViewController:nextVC];
    }
    [self closeDatePickerCell];
}

- (void)didSelectCalendarCellAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    A3DaysCounterSetupCalendarViewController *nextVC = [[A3DaysCounterSetupCalendarViewController alloc] initWithNibName:nil bundle:nil];
    nextVC.eventModel = self.eventItem;
    nextVC.sharedManager = _sharedManager;
    nextVC.dismissCompletionBlock = ^{
        NSMutableArray *section1_items = [[self.sectionTitleArray objectAtIndex:AddSection_Section_1] objectForKey:AddEventItems];
        NSIndexPath *calendarIndexPath = [NSIndexPath indexPathForRow:[self indexOfRowForItemType:EventCellType_Calendar atSectionArray:section1_items]
                                                            inSection:AddSection_Section_1];
        //                [tableView deselectRowAtIndexPath:calendarIndexPath animated:YES];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:calendarIndexPath];
        UILabel *nameLabel = (UILabel*)[cell viewWithTag:12];
        UIImageView *colorImageView = (UIImageView*)[cell viewWithTag:11];
        DaysCounterCalendar *calendar = _eventItem.calendar;
        if (calendar) {
            nameLabel.text = calendar.calendarName;
            colorImageView.tintColor = [calendar color];
        }
        else {
            nameLabel.text = @"";
        }
        
        colorImageView.hidden = ([nameLabel.text length] < 1 );
    };
    
    if ( IS_IPHONE ) {
        [self.navigationController pushViewController:nextVC animated:YES];
    }
    else {
        [self.A3RootViewController presentRightSideViewController:nextVC];
    }
    [self closeDatePickerCell];
}

- (void)didSelectDurationOptionCellAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    A3DaysCounterSetupDurationViewController *nextVC = [[A3DaysCounterSetupDurationViewController alloc] initWithNibName:@"A3DaysCounterSetupDurationViewController" bundle:nil];
    nextVC.eventModel = self.eventItem;
    nextVC.sharedManager = _sharedManager;
    nextVC.dismissCompletionBlock = ^{
        NSMutableArray *section1_items = [[self.sectionTitleArray objectAtIndex:AddSection_Section_1] objectForKey:AddEventItems];
        NSIndexPath *durationIndexPath = [NSIndexPath indexPathForRow:[self indexOfRowForItemType:EventCellType_DurationOption atSectionArray:section1_items]
                                                            inSection:AddSection_Section_1];
        self.isDurationInitialized = YES;
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:durationIndexPath];
        UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:11];
        detailTextLabel.text = [_sharedManager durationOptionStringFromValue:[_eventItem.durationOption integerValue]];
    };
    
    if ( IS_IPHONE )
        [self.navigationController pushViewController:nextVC animated:YES];
    else
        [self.A3RootViewController presentRightSideViewController:nextVC];
    [self closeDatePickerCell];
}

- (void)didSelectLocationCellAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
											   destructiveButtonTitle:_eventItem.location ? NSLocalizedString(@"Delete Location", @"Delete Location") : nil
													otherButtonTitles:NSLocalizedString(@"Use My Location", @"Use My Location"), NSLocalizedString(@"Search Location", @"Search Location"), nil];
    actionSheet.tag = ActionTag_Location;
    [actionSheet showInView:self.view];
    [self closeDatePickerCell];
}

#pragma mark etc
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    return [_sectionTitleArray count] + (_eventItem.uniqueID ? 1 : 0);
    if (!_isAddingEvent) {
        return [_sectionTitleArray count] + 1;
    }

    return [_sectionTitleArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( section == [_sectionTitleArray count] && _eventItem ) {
        return 1;
    }
    NSArray *items = [[_sectionTitleArray objectAtIndex:section] objectForKey:AddEventItems];
    return [items count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ( section == 2 ) {
        if (_isAddingEvent) {
            return IS_RETINA ? 35.5 : 35;
        }
        else {
            return IS_RETINA ? 37.5 : 37;
        }
    }
    else if ( section == 1 ) {
        return IS_RETINA ? 36.5 : 36;
    }
    else {
        return 35.0;
    }
    
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if (_isAddingEvent) {
		if (section >= [_sectionTitleArray count] - 1) {
			return 38.0;
		}
	} else {
		if (section >= [_sectionTitleArray count]) {
			return 38.0;
		}
	}

	return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat retHeight = 0.0;
    
    if ( _eventItem && indexPath.section == [_sectionTitleArray count] ) {
        retHeight = 44.0;
    }
    else {
        NSArray *items = [[_sectionTitleArray objectAtIndex:indexPath.section] objectForKey:AddEventItems];
        NSDictionary *itemDict = [items objectAtIndex:indexPath.row];
        
        NSInteger itemType = [[itemDict objectForKey:EventRowType] integerValue];
        switch (itemType) {
            case EventCellType_DateInput:
                retHeight = 236.0;
                break;

            case EventCellType_Notes:
				return [UIViewController noteCellHeight];

            case EventCellType_Advanced:
                retHeight = IS_RETINA ? 56.5 : 57.0;
                break;
            default:
                retHeight = 44.0;
                break;
        }
    }
    
    return retHeight;
}

#pragma mark - Action methods
- (void)resignAllAction
{
    [[self firstResponder] resignFirstResponder];
    [self.textViewResponder resignFirstResponder];
}

- (void)doneButtonAction:(UIBarButtonItem *)button
{
    [self resignAllAction];
    // 디비추가 처리
    // 입력값이 있어야 하는것들에 대한 체크
    if ( [_eventItem.eventName length] < 1 ) {
        _eventItem.eventName = NSLocalizedString(@"Untitled", @"Untitled");
    }
    if ( [_eventItem.isPeriod boolValue] && !_eventItem.endDate ) {
		[self alertMessage:NSLocalizedString(@"Please enter the end date.", @"Please enter the end date.")];
        return;
    }
    
    if ( [_eventItem.isPeriod boolValue] ) {
        NSDate *startDate = [_eventItem.startDate solarDate];
        NSDate *endDate = [_eventItem.endDate solarDate];
        
        if ( [endDate timeIntervalSince1970] < [startDate timeIntervalSince1970]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:NSLocalizedString(@"Cannot Save Event\nThe start date must be before the end date.", @"Cannot Save Event\nThe start date must be before the end date.")
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                      otherButtonTitles:nil];
            [alertView show];
            return;
        }
    }
    
    if ( [_eventItem.isLunar boolValue]) {
        BOOL isLunarStartDate = [NSDate isLunarDate:[_eventItem.startDate solarDate] isKorean:[A3DateHelper isCurrentLocaleIsKorea]];
        if (!isLunarStartDate) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Start date is not lunar date", @"Message in adding event.") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        
        if ( [_eventItem.isPeriod boolValue] ) {
            BOOL isLunarEndDate = [NSDate isLunarDate:[_eventItem.endDate solarDate] isKorean:[A3DateHelper isCurrentLocaleIsKorea]];
            if (!isLunarEndDate) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"End date is not lunar date", @"Message in adding event.") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                      otherButtonTitles:nil, nil] ;
                [alert show];
                return;
            }
        }
    }

    if ( _isAddingEvent ) {
        if (_eventItem.location) {
            _eventItem.location.eventId = _eventItem.uniqueID;
        }
        
        [_sharedManager addEvent:_eventItem];
    }
    else {
        [_sharedManager modifyEvent:_eventItem];
    }
	[_eventItem moveImagesToOriginalDirectory];
    
    [A3DaysCounterModelManager reloadAlertDateListForLocalNotification];
    
	if (IS_IPAD) {
		[self.A3RootViewController dismissCenterViewController];
	}
	else {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
	[self removeObserver];
}

- (void)cancelButtonAction:(UIBarButtonItem *)button
{
    [self resignAllAction];

	NSManagedObjectContext *context = [[MagicalRecordStack defaultStack] context];
	if ([context hasChanges]) {
		[context rollback];
	}

	if (IS_IPAD) {
		[self.A3RootViewController dismissCenterViewController];
	}
	else {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
	[self removeObserver];
}

- (void)toggleFavorite:(id)sender
{
	[_eventItem toggleFavorite];

    [((UIButton *)sender) setImage:[UIImage imageNamed:_eventItem.favorite != nil ? @"star02_on" : @"star02"] forState:UIControlStateNormal];
    ((UIButton *)sender).tintColor = [A3AppDelegate instance].themeColor;
}

- (void)photoAction:(id)sender
{
    [self resignAllAction];

	UIActionSheet *actionSheet = [self actionSheetAskingImagePickupWithDelete:[_eventItem.hasPhoto boolValue] delegate:self];
	actionSheet.tag = ActionTag_Photo;
	[actionSheet showInView:self.view];
}

- (void)updateEndDateDiffFromStartDate:(NSDate*)startDate
{
    NSMutableArray *items = [[_sectionTitleArray objectAtIndex:AddSection_Section_1] objectForKey:AddEventItems];
    if ( [_eventItem.isPeriod boolValue] ) {
        if ( _eventItem.endDate ) {
            NSDate *endDate = [_eventItem.endDate solarDate];
            NSTimeInterval diff = [endDate timeIntervalSince1970] - [startDate timeIntervalSince1970];
            endDate = [NSDate dateWithTimeInterval:diff sinceDate:[_eventItem.startDate solarDate]];
            _eventItem.endDate.solarDate = endDate;
        }
        else {
            _eventItem.endDate = _eventItem.startDate;
        }
    }
    [self.tableView beginUpdates];
    [self reloadItems:items withType:EventCellType_StartDate section:AddSection_Section_1 animation:UITableViewRowAnimationNone];
    [self reloadItems:items withType:EventCellType_EndDate section:AddSection_Section_1 animation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

#pragma mark Switch Button Toggle
- (void)toggleSwitchAction:(id)sender
{
    [self resignAllAction];
    UISwitch *swButton = (UISwitch*)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[[swButton superview] superview] superview]];
    if ( indexPath == nil ) {
        return;
    }
    
    NSMutableArray *sectionRow_items = [[_sectionTitleArray objectAtIndex:indexPath.section] objectForKey:AddEventItems];
    NSDictionary *rowItemData = [sectionRow_items objectAtIndex:indexPath.row];
    
    NSInteger rowItemType = [[rowItemData objectForKey:EventRowType] integerValue];
    if ( rowItemType == EventCellType_IsLunar ) {
        [self toggleLunarSwitchButton:swButton indexPath:indexPath];
    }
    else if ( rowItemType == EventCellType_IsLeapMonth ) {
        [self toggleLeapMonthSwitchButton:swButton indexPath:indexPath];
    }
    else if ( rowItemType == EventCellType_IsAllDay ) {
        [self toggleIsAllDaySwitchButton:swButton indexPath:indexPath sectionRow_items:sectionRow_items];
    }
    else if ( rowItemType == EventCellType_IsPeriod ) {
        [self toggleIsPeriodSwitchButton:swButton indexPath:indexPath sectionRow_items:sectionRow_items];
    }
}

- (void)toggleLunarSwitchButton:(UISwitch*)switchButton indexPath:(NSIndexPath *)indexPath
{
    _eventItem.isLunar = @(switchButton.on);
    NSMutableArray *sectionRow_items = [[_sectionTitleArray objectAtIndex:indexPath.section] objectForKey:AddEventItems];
    
    if ([switchButton isOn]) {
        [self closeDatePickerCell];

        
        [self.tableView beginUpdates];
        // 반복 종료 날짜 셀 제거.
        NSMutableArray *removalRows = [NSMutableArray new];
        if ([_eventItem.repeatType integerValue] != RepeatType_EveryYear) {
            _eventItem.repeatType = @(RepeatType_Never);
            NSInteger repeatTypeIndex = [self indexOfRowForItemType:EventCellType_RepeatType atSectionArray:sectionRow_items];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:repeatTypeIndex inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
            NSInteger endRepeatIndex = [self indexOfRowForItemType:EventCellType_EndRepeatDate atSectionArray:sectionRow_items];
            
            if (endRepeatIndex != -1) {
                [removalRows addObject:@(endRepeatIndex)];
            }
        }
        // start/end on 버튼 셀 제거.
        NSInteger startEndToggleCellIndex = [self indexOfRowForItemType:EventCellType_IsPeriod atSectionArray:sectionRow_items];
        if (startEndToggleCellIndex != -1) {
            [removalRows addObject:@(startEndToggleCellIndex)];
        }
        NSInteger endDateCellIndex = [self indexOfRowForItemType:EventCellType_EndDate atSectionArray:sectionRow_items];
        if (endDateCellIndex != -1) {
            [removalRows addObject:@(endDateCellIndex)];
        }
        
        // cell & dataSource 제거.
        removalRows = [[removalRows sortedArrayUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
            return [obj2 compare:obj1];
        }] mutableCopy];

        [removalRows enumerateObjectsUsingBlock:^(NSNumber *index, NSUInteger idx, BOOL *stop) {
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[index integerValue] inSection:[indexPath section]]] withRowAnimation:UITableViewRowAnimationMiddle];
        }];

        [removalRows enumerateObjectsUsingBlock:^(NSNumber *index, NSUInteger idx, BOOL *stop) {
            [sectionRow_items removeObjectAtIndex:[index integerValue]];
        }];
        [self.tableView endUpdates];
        
        

        NSInteger leapMonthRowIndex = [self indexOfRowForItemType:EventCellType_IsAllDay atSectionArray:sectionRow_items];
        [sectionRow_items replaceObjectAtIndex:leapMonthRowIndex withObject:@{EventRowTitle : NSLocalizedString(@"Leap Month", @"Leap Month"), EventRowType : @(EventCellType_IsLeapMonth)}];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:leapMonthRowIndex inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
        
        [A3DaysCounterModelManager setDateModelObjectForDateComponents:[A3DaysCounterModelManager dateComponentsFromDateModelObject:_eventItem.startDate toLunar:YES]
                                                        withEventModel:_eventItem
                                                               endDate:NO];
        if (_eventItem.endDate) {
            [A3DaysCounterModelManager setDateModelObjectForDateComponents:[A3DaysCounterModelManager dateComponentsFromDateModelObject:_eventItem.endDate toLunar:YES]
                                                            withEventModel:_eventItem
                                                                   endDate:YES];
        }
    }
    else {
        // Reload All-Day
        NSInteger reloadRowIndex = [self indexOfRowForItemType:EventCellType_IsLeapMonth atSectionArray:sectionRow_items];
        [sectionRow_items replaceObjectAtIndex:reloadRowIndex withObject:@{ EventRowTitle : NSLocalizedString(@"All-day", @"All-day"), EventRowType : @(EventCellType_IsAllDay) }];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:reloadRowIndex inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
        [sectionRow_items insertObject:@{EventRowTitle : NSLocalizedString(@"Starts-Ends", @"Starts-Ends"), EventRowType : @(EventCellType_IsPeriod)} atIndex:(reloadRowIndex + 1)];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(reloadRowIndex + 1) inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
        
        // Reload StartDate
        [A3DaysCounterModelManager setDateModelObjectForDateComponents:[A3DaysCounterModelManager dateComponentsFromDateModelObject:_eventItem.startDate toLunar:NO]
                                                        withEventModel:_eventItem
                                                               endDate:NO];
        reloadRowIndex = [self indexOfRowForItemType:EventCellType_StartDate atSectionArray:sectionRow_items];
        if (reloadRowIndex != -1) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:reloadRowIndex inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
        }

        // Reload EndDate
        if (_eventItem.endDate) {
            [A3DaysCounterModelManager setDateModelObjectForDateComponents:[A3DaysCounterModelManager dateComponentsFromDateModelObject:_eventItem.endDate toLunar:NO]
                                                            withEventModel:_eventItem
                                                                   endDate:YES];
            if (reloadRowIndex != -1) {
                reloadRowIndex = [self indexOfRowForItemType:EventCellType_EndDate atSectionArray:sectionRow_items];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:reloadRowIndex inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    }
    
    NSDate *startDate = [_eventItem.startDate solarDate];
    [self updateEndDateDiffFromStartDate:startDate];
}

- (void)toggleLeapMonthSwitchButton:(UISwitch*)switchButton indexPath:(NSIndexPath *)indexPath
{
    _eventItem.startDate.isLeapMonth = @(switchButton.on);
    NSMutableArray *sectionRow_items = [[_sectionTitleArray objectAtIndex:indexPath.section] objectForKey:AddEventItems];

    // Reload StartDate
    [A3DaysCounterModelManager setDateModelObjectForDateComponents:[A3DaysCounterModelManager dateComponentsFromDateModelObject:_eventItem.startDate toLunar:NO]
                                                    withEventModel:_eventItem
                                                           endDate:NO];
    NSInteger reloadRowIndex = [self indexOfRowForItemType:EventCellType_StartDate atSectionArray:sectionRow_items];
    if (reloadRowIndex != -1) {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:reloadRowIndex inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    // Reload EndDate
    if (_eventItem.endDate) {
        [A3DaysCounterModelManager setDateModelObjectForDateComponents:[A3DaysCounterModelManager dateComponentsFromDateModelObject:_eventItem.endDate toLunar:NO]
                                                        withEventModel:_eventItem
                                                               endDate:YES];
        if (reloadRowIndex != -1) {
            reloadRowIndex = [self indexOfRowForItemType:EventCellType_EndDate atSectionArray:sectionRow_items];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:reloadRowIndex inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

- (void)toggleIsAllDaySwitchButton:(UISwitch *)swButton indexPath:(NSIndexPath *)indexPath sectionRow_items:(NSMutableArray *)sectionRow_items
{
    _eventItem.isAllDay = @(swButton.on);
    
    if ([swButton isOn] == NO && !_isDurationInitialized) {
        _eventItem.durationOption = @(DurationOption_Day|DurationOption_Hour|DurationOption_Minutes);
    }
    else if ([swButton isOn] == NO && _isDurationInitialized ) {
        _eventItem.durationOption = @([_eventItem.durationOption integerValue] | DurationOption_Hour | DurationOption_Minutes);
    }
    else if ([swButton isOn]) {
        NSInteger durationFlag = [_eventItem.durationOption integerValue];
        durationFlag = durationFlag & ~(DurationOption_Hour|DurationOption_Minutes|DurationOption_Seconds);
        if (durationFlag == 0) {
            durationFlag = DurationOption_Day;
        }
        
        _eventItem.durationOption = @(durationFlag);
    }

    [self reloadItems:sectionRow_items withType:EventCellType_IsLunar section:indexPath.section animation:UITableViewRowAnimationNone];
    [self reloadItems:sectionRow_items withType:EventCellType_DateInput section:indexPath.section animation:UITableViewRowAnimationNone];
    [self reloadItems:sectionRow_items withType:EventCellType_StartDate section:indexPath.section animation:UITableViewRowAnimationNone];
    [self reloadItems:sectionRow_items withType:EventCellType_EndDate section:indexPath.section animation:UITableViewRowAnimationNone];
    [self reloadItems:sectionRow_items withType:EventCellType_DurationOption section:indexPath.section animation:UITableViewRowAnimationNone];
}

- (void)toggleIsPeriodSwitchButton:(UISwitch *)swButton indexPath:(NSIndexPath *)indexPath sectionRow_items:(NSMutableArray *)sectionRow_items
{
    _eventItem.isPeriod = @(swButton.on);
    
    NSInteger startEndSwitchRowIndex = [self indexOfRowForItemType:EventCellType_IsPeriod atSectionArray:sectionRow_items];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:startEndSwitchRowIndex inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:startEndSwitchRowIndex + 1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
    
    if ( swButton.on ) {
        if ( ![self isExistsEndDateCellInItems:sectionRow_items] ) {
            NSInteger startDateRowIndex = [self indexOfRowForItemType:EventCellType_StartDate atSectionArray:sectionRow_items];
            NSInteger datePickerRow = 0;
            NSInteger datePickerRowIndex = [self indexOfRowForItemType:EventCellType_DateInput atSectionArray:sectionRow_items];
            if ( datePickerRowIndex != -1 ) {
                datePickerRow = 1;
            }
            
            [sectionRow_items insertObject:@{EventRowTitle : NSLocalizedString(@"Ends", @"Ends"), EventRowType : @(EventCellType_EndDate)} atIndex:startDateRowIndex + 1 + datePickerRow];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:startDateRowIndex + 1 + datePickerRow inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationTop];
            if (datePickerRow) {
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:startDateRowIndex + datePickerRow inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
            }
            [self.tableView endUpdates];
        }
    }
    else {
        if ( [self isExistsEndDateCellInItems:sectionRow_items] ) {
            NSInteger endDateRowIndex = [self indexOfRowForItemType:EventCellType_EndDate atSectionArray:sectionRow_items];
            if (endDateRowIndex == -1) {
                return;
            }
            
            NSInteger dateInputRowIndex = -1;
            if ( [self.inputDateKey isEqualToString:EventItem_EndDate] ) {
                dateInputRowIndex = [self indexOfRowForItemType:EventCellType_DateInput atSectionArray:sectionRow_items];
            }
            else if ( [self.inputDateKey isEqualToString:EventItem_StartDate] ) {
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:startEndSwitchRowIndex + 2 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
            }
            
            if (dateInputRowIndex != -1) {
                [sectionRow_items removeObjectAtIndex:dateInputRowIndex];
                [sectionRow_items removeObjectAtIndex:endDateRowIndex];
                
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:endDateRowIndex inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:dateInputRowIndex inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
                self.inputDateKey = nil;
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:dateInputRowIndex + 1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
            }
            else {
                [sectionRow_items removeObjectAtIndex:endDateRowIndex];
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:endDateRowIndex inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationMiddle];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:endDateRowIndex + 1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
            }
        }
    }
}

#pragma mark DatePicker

- (void)dateChangeAction:(id)sender
{
    [self resignAllAction];
    UIDatePicker *datePicker = (UIDatePicker*)sender;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[[datePicker superview] superview] superview]];
    if ( indexPath == nil )
        return;
    
    NSMutableArray *items = [[_sectionTitleArray objectAtIndex:indexPath.section] objectForKey:AddEventItems];
    NSDate *prevDate = [_eventItem.startDate solarDate];
    NSCalendar *calendar = [[A3AppDelegate instance] calendar];
    NSDateComponents *dateComp;
    if ([_eventItem.isAllDay boolValue]) {
        dateComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[datePicker date]];
        dateComp.hour = 0;
        dateComp.minute = 0;
        dateComp.second = 0;
    }
    else {
        dateComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:[datePicker date]];
        dateComp.second = 0;
        DaysCounterDate *dateData = [self.inputDateKey isEqualToString:EventItem_StartDate] ? _eventItem.startDate : _eventItem.endDate;
        if ([dateData.hour integerValue] != dateComp.hour || [dateData.minute integerValue] != dateComp.minute) {
            NSInteger durationFlag = [_eventItem.durationOption integerValue];
            durationFlag |= DurationOption_Hour|DurationOption_Minutes;
            _eventItem.durationOption = @(durationFlag);
            NSMutableArray *section1_items = [[self.sectionTitleArray objectAtIndex:AddSection_Section_1] objectForKey:AddEventItems];
            [self reloadItems:section1_items withType:EventCellType_DurationOption section:indexPath.section animation:UITableViewRowAnimationNone];
        }
    }
    
    // 음력 날짜 유효성 체크.
    if ([_eventItem.isLunar boolValue]) {
        BOOL isLunarDate = [NSDate isLunarDate:[calendar dateFromComponents:dateComp] isKorean:[A3DateHelper isCurrentLocaleIsKorea]];
        [self leapMonthCellEnable:[NSDate isLunarLeapMonthAtDateComponents:dateComp isKorean:YES]];

        if (!isLunarDate) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"It's not a Lunar Date", @"It's not a Lunar Date") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil, nil] ;
            [alert show];
            if ([self.inputDateKey isEqualToString:EventItem_StartDate]) {
                datePicker.date = [_eventItem.startDate solarDate];
            }
            else {
                datePicker.date = [_eventItem.endDate solarDate];
            }

            return;
        }
    }
    
    if ([self.inputDateKey isEqualToString:EventItem_StartDate]) {
        [A3DaysCounterModelManager setDateModelObjectForDateComponents:dateComp withEventModel:_eventItem endDate:NO];
        FNLOG(@"\nStartSolarDate: %@\nStartLunarDate: %@.%@.%@", [_eventItem.startDate solarDate], _eventItem.startDate.year, _eventItem.startDate.month, _eventItem.startDate.day);
    }
    else {
        [A3DaysCounterModelManager setDateModelObjectForDateComponents:dateComp withEventModel:_eventItem endDate:YES];
        FNLOG(@"\nEndSolarDate: %@\nEndLunarDate: %@.%@.%@", [_eventItem.startDate solarDate], _eventItem.startDate.year, _eventItem.startDate.month, _eventItem.startDate.day);
    }
    
    // EffectiveStartDate & EffectiveAlertDate 갱신.
    [_sharedManager recalculateEventDatesForEvent:_eventItem];
    
    // AlertCell 갱신.
    NSMutableArray *section1_items = [[self.sectionTitleArray objectAtIndex:AddSection_Section_1] objectForKey:AddEventItems];
    NSIndexPath *alertIndexPath = [NSIndexPath indexPathForRow:[self indexOfRowForItemType:EventCellType_Alert atSectionArray:section1_items]
                                                     inSection:AddSection_Section_1];
    [self.tableView deselectRowAtIndexPath:alertIndexPath animated:YES];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:alertIndexPath];
    UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:11];
    detailTextLabel.text = [_sharedManager alertDateStringFromDate:_eventItem.effectiveStartDate
                                                         alertDate:_eventItem.alertDatetime];
    if ( [self.inputDateKey isEqualToString:EventItem_StartDate] ) {
        // Start DateInputCell 갱신, (LeapMonth 고려)
        [self updateEndDateDiffFromStartDate:prevDate]; // End Date 간격 갱신.
        
        if ( [_eventItem.isLunar boolValue] ) {
            NSIndexPath *leapMonthIndexPath = [NSIndexPath indexPathForRow:[self indexOfRowForItemType:EventCellType_IsLeapMonth atSectionArray:section1_items]
                                                                 inSection:AddSection_Section_1];
            [self.tableView reloadRowsAtIndexPaths:@[leapMonthIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    else if ( [self.inputDateKey isEqualToString:EventItem_EndDate] ) {
        // End DateInputCell 갱신.
        [self reloadItems:items withType:EventCellType_EndDate section:indexPath.section];
    }
}

- (void)closeDatePickerCell
{
    NSMutableArray *items = [[_sectionTitleArray objectAtIndex:1] objectForKey:AddEventItems];
    if ([self indexOfRowForItemType:EventCellType_DateInput atSectionArray:items] == -1) {
        self.inputDateKey = nil;
    }
    
    if ( self.inputDateKey ) {
        [self removeDateInputCellWithItems:items indexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    }
}

- (void)toggleDateInputAction:(id)sender
{
    [self resignAllAction];
    UIButton *button = (UIButton*)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[[button superview] superview] superview]];
    if ( indexPath == nil )
        return;
    
    NSMutableArray *items = [[_sectionTitleArray objectAtIndex:indexPath.section] objectForKey:AddEventItems];
    NSDictionary *itemDict = [items objectAtIndex:indexPath.row];
    NSInteger itemType = [[itemDict objectForKey:EventRowType] integerValue];
    
    if ([self indexOfRowForItemType:EventCellType_DateInput atSectionArray:items] == -1) {
        self.inputDateKey = nil;
    }

    // 입력대상이 셋팅 되어있으면 삭제한다.
    NSInteger removeType = 0;
    if ( [self.inputDateKey isEqualToString:EventItem_StartDate] ) {
        removeType = EventCellType_StartDate;
    }
    else if ( [self.inputDateKey isEqualToString:EventItem_EndDate] ) {
        removeType = EventCellType_EndDate;
    }

    if ( self.inputDateKey ) {
        [self removeDateInputCellWithItems:items indexPath:indexPath];
    }
    
    if ( removeType != itemType ) {
        if ( removeType == EventCellType_StartDate ) {
            indexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
        }
        self.inputDateKey = itemType == EventCellType_StartDate ? EventItem_StartDate : EventItem_EndDate;
        [items insertObject:@{ EventRowTitle : @"", EventRowType : @(EventCellType_DateInput)} atIndex:indexPath.row+1];
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationMiddle];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        [CATransaction commit];
    }
}

- (void)advancedRowTouchedUp:(NSIndexPath*)indexPath
{
    [self resignAllAction];
    
    A3JHTableViewExpandableHeaderCell *expandableCell = (A3JHTableViewExpandableHeaderCell *) [self.tableView cellForRowAtIndexPath:indexPath];

    NSMutableArray *section1_items = [[self.sectionTitleArray objectAtIndex:AddSection_Section_1] objectForKey:AddEventItems];
    
    _isAdvancedCellOpen = !_isAdvancedCellOpen;
    
    [UIView animateWithDuration:0.35 animations:^{
        expandableCell.expandButton.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DegreesToRadians((_isAdvancedCellOpen ?  0 : -179.9)));
    }];

    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
        if (_isAdvancedCellOpen) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
    }];

    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(indexPath.row - 1) inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
    
    if (!_isAdvancedCellOpen) {
        NSUInteger advancedCellRowIndex = [self indexOfRowForItemType:EventCellType_Advanced atSectionArray:section1_items];
        expandableCell.titleLabel.textColor = [UIColor colorWithRed:109.0/255.0 green:109.0/255.0 blue:114.0/255.0 alpha:1.0];
        // remove Advanced Rows
        NSMutableArray *indexPathsToRemove = [NSMutableArray array];
        for (NSInteger row = advancedCellRowIndex + 1; row < [section1_items count]; row++) {
            [indexPathsToRemove addObject:[NSIndexPath indexPathForRow:row inSection:AddSection_Section_1]];
        }
        [section1_items removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(advancedCellRowIndex + 1, [section1_items count] - (advancedCellRowIndex + 1))]];

        [self.tableView deleteRowsAtIndexPaths:indexPathsToRemove withRowAnimation:UITableViewRowAnimationMiddle];
    }
    else {
        NSMutableArray *advancedRows = [NSMutableArray new];
        [advancedRows addObject:@{ EventRowTitle : NSLocalizedString(@"Repeat", @"Repeat"), EventRowType : @(EventCellType_RepeatType)}];
        if ( [_eventItem.repeatType integerValue] != 0 ) {
            [advancedRows addObject:@{ EventRowTitle : NSLocalizedString(@"End Repeat", @"End Repeat"), EventRowType : @(EventCellType_EndRepeatDate)}];
        }
        [advancedRows addObject:@{ EventRowTitle : NSLocalizedString(@"Alert", @"Alert"), EventRowType : @(EventCellType_Alert)}];
        [advancedRows addObject:@{ EventRowTitle : NSLocalizedString(@"Calendar", @"Calendar"), EventRowType : @(EventCellType_Calendar)}];
        [advancedRows addObject:@{ EventRowTitle : NSLocalizedString(@"Duration Option", @"Duration Option"), EventRowType : @(EventCellType_DurationOption)}];
        [advancedRows addObject:@{ EventRowTitle : NSLocalizedString(@"Location", @"Location"), EventRowType : @(EventCellType_Location)}];
        [advancedRows addObject:@{ EventRowTitle : NSLocalizedString(@"Notes", @"Notes"), EventRowType : @(EventCellType_Notes)}];
        
        expandableCell.titleLabel.textColor = [A3AppDelegate instance].themeColor;
        NSMutableArray *indexPathsToAdd = [NSMutableArray array];
        for (NSInteger row = [section1_items count]; row < ([section1_items count] + [advancedRows count]); row++) {
            [indexPathsToAdd addObject:[NSIndexPath indexPathForRow:row inSection:AddSection_Section_1]];
        }
        
        [section1_items addObjectsFromArray:advancedRows];
        [self.tableView insertRowsAtIndexPaths:indexPathsToAdd withRowAnimation:UITableViewRowAnimationMiddle];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    [self.tableView endUpdates];
    [CATransaction commit];
}

#pragma mark - UITextField Related
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self setFirstResponder:textField];
    if (![_eventItem.isLunar boolValue]) {
        [self closeDatePickerCell];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:CGPointMake(100, [textField convertPoint:textField.center toView:self.tableView].y)];
    
    NSMutableArray *section1_items = [[self.sectionTitleArray objectAtIndex:AddSection_Section_1] objectForKey:AddEventItems];
    NSInteger startDateIndex = [self indexOfRowForItemType:EventCellType_StartDate atSectionArray:section1_items];
    NSInteger endDateIndex = [self indexOfRowForItemType:EventCellType_EndDate atSectionArray:section1_items];
    
    if ((indexPath.section == 1 && indexPath.row == startDateIndex) || (indexPath.section == 1 && indexPath.row == endDateIndex)) {    // start Date
        if (!self.dateKeyboardViewController) {
            self.dateKeyboardViewController = [self newDateKeyboardViewController];
            self.dateKeyboardViewController.dateComponents = [A3DaysCounterModelManager dateComponentsFromDateModelObject:indexPath.row == startDateIndex ? _eventItem.startDate : _eventItem.endDate
                                                                                                                  toLunar:YES];
        }
		self.dateKeyboardViewController.delegate = self;
        self.dateKeyboardViewController.isLunarDate = [_eventItem.isLunar boolValue];
        textField.inputView = self.dateKeyboardViewController.view;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:CGPointMake(100, [textField convertPoint:textField.center toView:self.tableView].y)];
    
    if (indexPath.section == 0 && indexPath.row == 0) {         // event Name
        _eventItem.eventName = textField.text;
    }
    else {
        
    }
    
    self.firstResponder = nil;
}

#pragma mark  A3KeyboardViewControllerDelegate
- (void)dateKeyboardValueChangedDate:(NSDate *)date
{
    FNLOG(@"%@", date);
}

- (void)dateKeyboardValueChangedDateComponents:(NSDateComponents *)dateComponents
{
    FNLOG(@"%@", dateComponents);
    dateComponents.hour = 0;
    dateComponents.minute = 0;
    dateComponents.second = 0;

    // 음력 날짜 유효성 체크.
    if ([_eventItem.isLunar boolValue]) {
        //BOOL isLunarDate = [NSDate isLunarDate:[calendar dateFromComponents:dateComponents] isKorean:[A3DateHelper isCurrentLocaleIsKorea]];
        [self leapMonthCellEnable:[NSDate isLunarLeapMonthAtDateComponents:dateComponents isKorean:YES]];
    }
    
    if ([self.inputDateKey isEqualToString:EventItem_StartDate]) {
        [A3DaysCounterModelManager setDateModelObjectForDateComponents:dateComponents withEventModel:_eventItem endDate:NO];
        FNLOG(@"\nStartSolarDate: %@\nStartLunarDate: %@.%@.%@", [_eventItem.startDate solarDate], _eventItem.startDate.year, _eventItem.startDate.month, _eventItem.startDate.day);
    }
    else {
        [A3DaysCounterModelManager setDateModelObjectForDateComponents:dateComponents withEventModel:_eventItem endDate:YES];
        FNLOG(@"\nEndSolarDate: %@\nEndLunarDate: %@.%@.%@", [_eventItem.startDate solarDate], _eventItem.startDate.year, _eventItem.startDate.month, _eventItem.startDate.day);
    }
    
    // EffectiveStartDate & EffectiveAlertDate 갱신.
    [_sharedManager recalculateEventDatesForEvent:_eventItem];
    
    // AlertCell 갱신.
    NSMutableArray *section1_items = [[self.sectionTitleArray objectAtIndex:AddSection_Section_1] objectForKey:AddEventItems];
    NSIndexPath *alertIndexPath = [NSIndexPath indexPathForRow:[self indexOfRowForItemType:EventCellType_Alert atSectionArray:section1_items]
                                                     inSection:AddSection_Section_1];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:alertIndexPath];
    UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:11];
    detailTextLabel.text = [_sharedManager alertDateStringFromDate:_eventItem.effectiveStartDate
                                                         alertDate:_eventItem.alertDatetime];
    if ( [self.inputDateKey isEqualToString:EventItem_StartDate] ) {
        NSIndexPath *startDateIndexPath = [NSIndexPath indexPathForRow:[self indexOfRowForItemType:EventCellType_StartDate atSectionArray:section1_items]
                                                             inSection:AddSection_Section_1];
        if (startDateIndexPath) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:startDateIndexPath];
            UILabel *dateLabel = (UILabel*)[cell viewWithTag:12];
            if ([_eventItem.isLunar boolValue]) {
                dateLabel.text = [A3DaysCounterModelManager dateStringOfLunarFromDateModel:_eventItem.startDate
                                                                               isLeapMonth:[_eventItem.startDate.isLeapMonth boolValue]];
            }
            else {
                dateLabel.text = [A3DaysCounterModelManager dateStringFromDateModel:_eventItem.startDate isLunar:NO isAllDay:[_eventItem.isAllDay boolValue]];
            }
        }
    }
    else if ( [self.inputDateKey isEqualToString:EventItem_EndDate] ) {
        // End DateInputCell 갱신.
        NSIndexPath *endDateIndexPath = [NSIndexPath indexPathForRow:[self indexOfRowForItemType:EventCellType_EndDate atSectionArray:section1_items]
                                                             inSection:AddSection_Section_1];
        if (endDateIndexPath) {
            //[self.tableView reloadRowsAtIndexPaths:@[endDateIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:endDateIndexPath];
            UILabel *dateLabel = (UILabel*)[cell viewWithTag:12];

            
            if ([_eventItem.isLunar boolValue]) {
                dateLabel.text = [A3DaysCounterModelManager dateStringOfLunarFromDateModel:_eventItem.endDate
                                                                               isLeapMonth:[_eventItem.endDate.isLeapMonth boolValue]];
            }
            else {
                dateLabel.text = [A3DaysCounterModelManager dateStringFromDateModel:_eventItem.endDate isLunar:NO isAllDay:[_eventItem.isAllDay boolValue]];
            }
        }
    }
}

- (BOOL)isPreviousEntryExists {
    return YES;
}

- (BOOL)isNextEntryExists {
    return YES;
}

- (void)nextButtonPressed{
}

- (void)prevButtonPressed{
}

- (void)dateKeyboardDoneButtonPressed:(A3DateKeyboardViewController *)keyboardViewController {
    [self.firstResponder resignFirstResponder];
}

- (void)updateOffsetDateCompWithTextField:(UITextField *)textField {
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate {
}

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
     if ( actionSheet.tag == ActionTag_Location ) {
//        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:2] animated:YES];

//         NSMutableArray *section1_items = [[self.sectionTitleArray objectAtIndex:AddSection_Section_1] objectForKey:AddEventItems];
//         NSIndexPath *locationIndexPath = [NSIndexPath indexPathForRow:[self indexOfRowForItemType:EventCellType_Location atSectionArray:section1_items]
//                                                             inSection:AddSection_Section_1];
//         [self.tableView deselectRowAtIndexPath:locationIndexPath animated:YES];
     }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ( actionSheet.tag == ActionTag_Photo ) {
		if (buttonIndex == actionSheet.cancelButtonIndex) return;

		if (buttonIndex == actionSheet.destructiveButtonIndex) {
			_eventItem.hasPhoto = @NO;
            [self.tableView reloadData];
			return;
		}

		NSInteger myButtonIndex = buttonIndex;
		_imagePickerController = [[UIImagePickerController alloc] init];
		if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
			myButtonIndex++;
		if (actionSheet.destructiveButtonIndex>=0)
			myButtonIndex--;
		switch (myButtonIndex) {
			case 0:
				_imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
				_imagePickerController.allowsEditing = NO;
				break;
			case 1:
				_imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
				_imagePickerController.allowsEditing = NO;
				break;
			case 2:
				_imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
				_imagePickerController.allowsEditing = YES;
				break;
		}

		_imagePickerController.mediaTypes = @[(NSString *) kUTTypeImage];
		_imagePickerController.navigationBar.barStyle = UIBarStyleDefault;
		_imagePickerController.delegate = self;

		if (IS_IPAD) {
			if (_imagePickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
				_imagePickerController.showsCameraControls = YES;
				[self presentViewController:_imagePickerController animated:YES completion:NULL];
			}
			else {
				self.imagePickerPopoverController = [[UIPopoverController alloc] initWithContentViewController:_imagePickerController];
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                UIButton *button = (UIButton*)[cell viewWithTag:11];
                CGRect rect = [self.tableView convertRect:button.frame fromView:cell.contentView];
				[_imagePickerPopoverController presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
			}
		}
		else {
			[self presentViewController:_imagePickerController animated:YES completion:NULL];
		}
    }
    else if ( actionSheet.tag == ActionTag_Location ) {
        if ( buttonIndex == actionSheet.destructiveButtonIndex ) {
            _eventItem.location = nil;
            [self.tableView reloadData];
        }
        else if ( buttonIndex == actionSheet.firstOtherButtonIndex ) {
            self.locationManager = [[CLLocationManager alloc] init];
            _locationManager.delegate = self;
            _locationManager.distanceFilter = kCLDistanceFilterNone;
            _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            [_locationManager startUpdatingLocation];
        }
        else if ( buttonIndex == (actionSheet.firstOtherButtonIndex + 1)) {
            if (![[A3AppDelegate instance].reachability isReachable]) {
				[self alertInternetConnectionIsNotAvailable];
                return;
            }
            
            A3DaysCounterSetupLocationViewController *nextVC = [[A3DaysCounterSetupLocationViewController alloc] initWithNibName:@"A3DaysCounterSetupLocationViewController" bundle:nil];
            nextVC.eventModel = self.eventItem;
            nextVC.sharedManager = _sharedManager;
            [self.navigationController pushViewController:nextVC animated:YES];
        }
    }
    else if ( actionSheet.tag == ActionTag_DeleteEvent ) {
        if ( buttonIndex == actionSheet.destructiveButtonIndex ) {
            [_sharedManager removeEvent:_eventItem];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (IBAction)deleteEventAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:NSLocalizedString(@"Delete Event", @"Delete Event") otherButtonTitles:nil];
    actionSheet.tag = ActionTag_DeleteEvent;
    [actionSheet showInView:self.view];
}


#pragma mark - UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.imagePickerPopoverController = nil;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [manager stopUpdatingLocation];

	[self alertInternetConnectionIsNotAvailable];

    self.locationManager = nil;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [manager stopUpdatingLocation];
    CLLocation *location = [locations lastObject];
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([error code] == kCLErrorNetwork) {
			[self alertInternetConnectionIsNotAvailable];
            return;
        }
        
        if ( error == nil ) {
            if ( [placemarks count] < 1 ) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
																	message:NSLocalizedString(@"Can not find current location information", @"Can not find current location information")
																   delegate:nil
														  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
														  otherButtonTitles:nil];
                [alertView show];
                return;
            }
            
            CLPlacemark *placeMark = [placemarks objectAtIndex:0];
            NSDictionary *addressDict = placeMark.addressDictionary;
            
            DaysCounterEventLocation *locItem = [DaysCounterEventLocation MR_createEntity];
            locItem.eventId = _eventItem.uniqueID;
            locItem.latitude = @(location.coordinate.latitude);
            locItem.longitude = @(location.coordinate.longitude);
            
            locItem.locationName = [addressDict objectForKey:(NSString*)kABPersonAddressStreetKey];
            locItem.country = ([[addressDict objectForKey:(NSString*)kABPersonAddressCountryKey] length] > 0 ? [addressDict objectForKey:(NSString*)kABPersonAddressCountryKey] : @"");
            locItem.state = ([[addressDict objectForKey:(NSString*)kABPersonAddressCountryKey] length] > 0 ? [addressDict objectForKey:(NSString*)kABPersonAddressCountryKey] : @"");
            locItem.city = ([[addressDict objectForKey:(NSString*)kABPersonAddressCityKey] length] > 0 ? [addressDict objectForKey:(NSString*)kABPersonAddressCityKey] : @"");
            locItem.address = ([[addressDict objectForKey:(NSString*)kABPersonAddressStreetKey] length] > 0 ? [addressDict objectForKey:(NSString*)kABPersonAddressStreetKey] : @"");
            locItem.contact = @"";
            self.eventItem.location = locItem;
            [self.tableView reloadData];
        }
    }];
    self.locationManager = nil;
    geoCoder = nil;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if ( IS_IPHONE || picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [_imagePickerPopoverController dismissPopoverAnimated:YES];
    }
	_imagePickerController = nil;
	_imagePickerPopoverController = nil;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if ( image == nil ) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }

	_eventItem.hasPhoto = @YES;
	[_eventItem setPhoto:image inOriginalDirectory:NO];
	[_eventItem saveThumbnailForImage:image inOriginalDirectory:NO ];

    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    if ( IS_IPHONE || picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [_imagePickerPopoverController dismissPopoverAnimated:YES];
    }
	_imagePickerController = nil;
	_imagePickerPopoverController = nil;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self resignAllAction];
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ( [_eventItem.notes length] < 1 ) {
        textView.text = @"";
    }
    
    self.textViewResponder = textView;
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    _eventItem.notes = textView.text;

    self.textViewResponder = nil;
}

@end
