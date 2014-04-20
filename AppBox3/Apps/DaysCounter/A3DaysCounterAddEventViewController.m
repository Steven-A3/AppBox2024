//
//  A3DaysCounterAddEventViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <AddressBookUI/AddressBookUI.h>
#import "A3DaysCounterAddEventViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "A3Formatter.h"
#import "A3DaysCounterSetupRepeatViewController.h"
#import "A3DaysCounterSetupEndRepeatViewController.h"
#import "A3DaysCounterSetupAlertViewController.h"
#import "A3DaysCounterSetupCalendarViewController.h"
#import "A3DaysCounterSetupDurationViewController.h"
#import "A3DaysCounterSetupLocationViewController.h"
#import "A3DaysCounterLocationDetailViewController.h"
#import "DaysCounterCalendar.h"
#import "DaysCounterEvent.h"
#import "DaysCounterEventLocation.h"
#import "NSDate+LunarConverter.h"
#import "SFKImage.h"
#import "A3AppDelegate.h"
#import "Reachability.h"
#import "A3AppDelegate+appearance.h"
#import "A3DateHelper.h"


#define ActionTag_Location      100
#define ActionTag_Photo         101
#define ActionTag_DeleteEvent   102

@interface A3DaysCounterAddEventViewController ()
@property (strong, nonatomic) NSArray *cellIDArray;
@property (strong, nonatomic) NSMutableArray *sectionTitleArray;
@property (strong, nonatomic) NSMutableDictionary *eventModel;
@property (strong, nonatomic) NSString *inputDateKey;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UIPopoverController *imagePopover;
@property (assign, nonatomic) BOOL isAdvancedCellOpen;
@property (assign, nonatomic) BOOL isDurationIntialized;//temp...
@property (weak, nonatomic) UITextView *textViewResponder;
@end

@implementation A3DaysCounterAddEventViewController
{
    NSIndexPath *_indexPathOfShownDatePickerCell;
}

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
    
    self.cellIDArray = @[@"titleCell", @"photoCell", @"switchCell", @"switchCell", @"switchCell",       // 0 ~ 4
                         @"dateCell", @"dateCell", @"value1Cell", @"value1Cell", @"value1Cell",         // 5 ~ 9
                         @"calendarCell", @"value1Cell", @"value1Cell", @"notesCell", @"dateInputCell", // 10 ~ 14
                         @"", @"", @"advancedCell", @"", @"switchCell"];    // 15 ~ 19
    
    if (_eventItem) {
        self.title = @"Edit Event";
        self.eventModel = [[A3DaysCounterModelManager sharedManager] dictionaryFromEventEntity:_eventItem];
        _isAdvancedCellOpen = [self hasAdvancedData];
        _isDurationIntialized = YES;
    }
    else {
        self.title = @"Add Event";
        _isAdvancedCellOpen = NO;
    }
    
    [self makeBackButtonEmptyArrow];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
    [self rightBarButtonDoneButton];
    
    if ( _eventItem ) {
        [self setupSectionTemplateWithInfo:_eventItem];
    }
    else {
        if ([[A3DaysCounterModelManager sharedManager] isSupportLunar]) {
            self.sectionTitleArray = [NSMutableArray arrayWithObjects:
                                      // section 0
                                      @{AddEventSectionName : @"", AddEventItems : [NSMutableArray arrayWithObjects:
                                                                                    @{EventRowTitle : @"Title", EventRowType : @(EventCellType_Title)},
                                                                                    @{EventRowTitle : @"Photo", EventRowType : @(EventCellType_Photo)}, nil]},
                                      // section 1
                                      @{AddEventSectionName : @"",AddEventItems : [NSMutableArray arrayWithObjects:
                                                                                   @{EventRowTitle : @"Lunar", EventRowType : @(EventCellType_IsLunar)},
                                                                                   @{EventRowTitle : @"All-day", EventRowType : @(EventCellType_IsAllDay)},
                                                                                   @{EventRowTitle : @"Starts-Ends", EventRowType : @(EventCellType_IsPeriod)},
                                                                                   @{EventRowTitle : @"Starts", EventRowType : @(EventCellType_StartDate)},
                                                                                   @{EventRowTitle : @"ADVANCED", EventRowType : @(EventCellType_Advanced)}, nil]}, nil];
        }
        else {
            self.sectionTitleArray = [NSMutableArray arrayWithObjects:
                                      // section 0
                                      @{AddEventSectionName : @"", AddEventItems : [NSMutableArray arrayWithObjects:
                                                                                    @{EventRowTitle : @"Title", EventRowType : @(EventCellType_Title)},
                                                                                    @{EventRowTitle : @"Photo", EventRowType : @(EventCellType_Photo)}, nil]},
                                      // section 1
                                      @{AddEventSectionName : @"",AddEventItems : [NSMutableArray arrayWithObjects:
                                                                                   @{EventRowTitle : @"All-day", EventRowType : @(EventCellType_IsAllDay)},
                                                                                   @{EventRowTitle : @"Starts-Ends", EventRowType : @(EventCellType_IsPeriod)},
                                                                                   @{EventRowTitle : @"Starts", EventRowType : @(EventCellType_StartDate)},
                                                                                   @{EventRowTitle : @"ADVANCED", EventRowType : @(EventCellType_Advanced)}, nil]}, nil];
        }
    }
        
    [self.navigationController setToolbarHidden:YES];
    isFirstAppear = YES;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, (IS_IPHONE ? 15.0 : 28.0), 0, 0);
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
        if ( _eventItem ) {
            self.eventModel = [[A3DaysCounterModelManager sharedManager] dictionaryFromEventEntity:_eventItem];
        }
        else {
            self.eventModel = [[A3DaysCounterModelManager sharedManager] emptyEventModel];
            if (self.calendarId) {
                DaysCounterCalendar *selectedCalendar = [[[[A3DaysCounterModelManager sharedManager] allUserCalendarList] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"calendarId == %@", self.calendarId]] lastObject];
                if (selectedCalendar) {
                    [self.eventModel setObject:self.calendarId forKey:EventItem_CalendarId];
                    [self.eventModel setObject:selectedCalendar forKey:EventItem_Calendar];
                }
            }
        }
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

#pragma mark -

- (BOOL)hasAdvancedData
{
    if ([[_eventModel objectForKey:EventItem_RepeatType] integerValue] != 0) {
        return YES;
    }
    
    NSString *alertString = [[A3DaysCounterModelManager sharedManager] alertDateStringFromDate:[_eventModel objectForKey:EventItem_StartDate]
                                                                                     alertDate:[_eventModel objectForKey:EventItem_AlertDatetime]];
    if (alertString && ![alertString isEqualToString:@"None"]) {
        return YES;
    }
    
    NSInteger durationType = [[_eventModel objectForKey:EventItem_DurationOption] integerValue];
    if ([[_eventModel objectForKey:EventItem_IsAllDay] boolValue] &&  durationType != DurationOption_Day) {
        return YES;
    }
    if (![[_eventModel objectForKey:EventItem_IsAllDay] boolValue] &&  durationType != (DurationOption_Day|DurationOption_Hour|DurationOption_Minutes)) {
        return YES;
    }

    NSMutableDictionary *location = [_eventModel objectForKey:EventItem_Location];
    if ( location ) {
        return YES;
    }
    
    if ([[_eventModel objectForKey:EventItem_Notes] length] > 0) {
        return YES;
    }
    
    return NO;
}

#pragma mark -

- (void)alertMessage:(NSString*)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
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

- (void)setupSectionTemplateWithInfo:(DaysCounterEvent*)info
{
    NSMutableArray *section1_Items = [NSMutableArray array];
    
    if ([[A3DaysCounterModelManager sharedManager] isSupportLunar]) {
        [section1_Items addObject:@{ EventRowTitle : @"Lunar", EventRowType : @(EventCellType_IsLunar)}];
        if ([info.isLunar boolValue]) {
            [section1_Items addObject:@{ EventRowTitle : @"Leap Month", EventRowType : @(EventCellType_IsLeapMonth)}];
        }
    }
    
    [section1_Items addObject:@{ EventRowTitle : @"All-day", EventRowType : @(EventCellType_IsAllDay)}];
    [section1_Items addObject:@{ EventRowTitle : @"Starts-Ends", EventRowType : @(EventCellType_IsPeriod)}];
    [section1_Items addObject:@{ EventRowTitle : @"Starts", EventRowType : @(EventCellType_StartDate)}];
    if ( [info.isPeriod boolValue] ) {
        [section1_Items addObject:@{ EventRowTitle : @"Ends", EventRowType : @(EventCellType_EndDate) }];
    }
    
    [section1_Items addObject:@{ EventRowTitle : @"ADVANCED", EventRowType : @(EventCellType_Advanced)}];
    if (_isAdvancedCellOpen) {
        [section1_Items addObject:@{ EventRowTitle : @"Repeat", EventRowType : @(EventCellType_RepeatType)}];
        if ( [info.repeatType integerValue] != RepeatType_Never ) {
            [section1_Items addObject:@{ EventRowTitle : @"End Repeat", EventRowType : @(EventCellType_EndRepeatDate)}];
        }
        [section1_Items addObject:@{ EventRowTitle : @"Alert", EventRowType : @(EventCellType_Alert)}];
        [section1_Items addObject:@{ EventRowTitle : @"Calendar", EventRowType : @(EventCellType_Calendar)}];
        [section1_Items addObject:@{ EventRowTitle : @"Duration Option", EventRowType : @(EventCellType_DurationOption)}];
        [section1_Items addObject:@{ EventRowTitle : @"Location", EventRowType : @(EventCellType_Location)}];
        [section1_Items addObject:@{ EventRowTitle : @"Notes", EventRowType : @(EventCellType_Notes)}];
    }
    
    self.sectionTitleArray = [NSMutableArray arrayWithObjects:
                              // section 0
                              @{AddEventSectionName : @"",
                                AddEventItems : [NSMutableArray arrayWithObjects:@{EventRowTitle : @"Title",
                                                                                   EventRowType : @(EventCellType_Title)},
                                                 @{EventRowTitle : @"Photo",
                                                   EventRowType : @(EventCellType_Photo)}, nil]},
                              // section 1
                              @{AddEventSectionName : @"", AddEventItems : section1_Items}, nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_sectionTitleArray count] + (_eventItem ? 1 : 0);
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
    if ( (_eventItem && section == [_sectionTitleArray count]) || (section < AddSection_Section_2) ) {
        return 35.0;
    }
    if ( section == 0 ) {
        return 36.0;
    }
    else if ( section == 1 ) {
        return 35.0;
    }

    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return (_eventItem && section == [_sectionTitleArray count]) ? 37.0 : 0.01;
}

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
        cell.textLabel.text = @"Delete Event";
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
                }
                    break;
                case EventCellType_Photo:
                {
                    cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterAddEventPhotoCell" owner:nil options:nil] lastObject];
                    UIButton *button = (UIButton*)[cell viewWithTag:11];
                    [button addTarget:self action:@selector(photoAction:) forControlEvents:UIControlEventTouchUpInside];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                    break;
                case EventCellType_IsLunar:
                case EventCellType_IsAllDay:
                case EventCellType_IsPeriod:
                case EventCellType_IsLeapMonth:
                {
                    cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterAddEventSwitchCell" owner:nil options:nil] lastObject];
                    UISwitch *swButton = (UISwitch*)[cell viewWithTag:11];
                    [swButton addTarget:self action:@selector(toggleSwitchAction:) forControlEvents:UIControlEventValueChanged];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                    break;
                case EventCellType_StartDate:
                case EventCellType_EndDate:{
                    cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterAddEventDateCell" owner:nil options:nil] lastObject];
                    UIImageView *imageView = (UIImageView*)[cell viewWithTag:11];
                    imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    imageView.tintColor = [UIColor lightGrayColor];
                }
                    break;
                case EventCellType_Calendar:
                {
                    cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterAddEventCalendarCell" owner:nil options:nil] lastObject];
                    UIImageView *imageView = (UIImageView*)[cell viewWithTag:11];
                    imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                }
                    break;
                case EventCellType_Notes:{
                    cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterAddEventNotesCell" owner:nil options:nil] lastObject];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    UITextView *textView = (UITextView*)[cell viewWithTag:10];
                    textView.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
                    textView.delegate = self;
                    textView.scrollEnabled = NO;
                }
                    break;
                case EventCellType_DateInput:{
                    cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterAddEventDateInputCell" owner:nil options:nil] lastObject];
                    UIDatePicker *datePicker = (UIDatePicker*)[cell viewWithTag:10];
                    [datePicker addTarget:self action:@selector(dateChangeAction:) forControlEvents:UIControlEventValueChanged];
                }
                    break;
                case EventCellType_Advanced:{
                    cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterAddEventAdvancedCell" owner:nil options:nil] lastObject];
                    cell.contentView.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    UIButton *button = (UIButton*)[cell viewWithTag:11];
                    button.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DegreesToRadians((_isAdvancedCellOpen ?  90 : 270)));
                }
                    break;
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
            textField.text = [_eventModel objectForKey:EventItem_Name];
            
            BOOL isSelected = [[_eventModel objectForKey:EventItem_IsFavorite] boolValue];
            [button setImage:[UIImage imageNamed:isSelected ? @"star02_on" : @"star02"] forState:UIControlStateNormal];
            button.tintColor = [A3AppDelegate instance].themeColor;
        }
            break;
        case EventCellType_Photo:
        {
            UIButton *button = (UIButton*)[cell viewWithTag:11];
            if ( [_eventModel objectForKey:EventItem_Thumbnail] ) {
                [button setImage:[_eventModel objectForKey:EventItem_Thumbnail] forState:UIControlStateNormal];
            }
            else {
                NSMutableArray *array = [NSMutableArray array];
                for(CALayer *layer in button.layer.sublayers ) {
                    if ( [layer isKindOfClass:[CAShapeLayer class]] )
                        [array addObject:layer];
                }
                for(CALayer *layer in array)
                    [layer removeFromSuperlayer];
                [button setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
            }
        }
            break;
        case EventCellType_IsLunar:
        {
            UILabel *titleLabel = (UILabel*)[cell viewWithTag:10];
            UISwitch *swButton = (UISwitch*)[cell viewWithTag:11];
            titleLabel.text = [itemDict objectForKey:EventRowTitle];
            swButton.on = [[_eventModel objectForKey:EventItem_IsLunar] boolValue];
            swButton.enabled = YES;
            break;
        }
            break;
        case EventCellType_IsAllDay:
        {
            UILabel *titleLabel = (UILabel*)[cell viewWithTag:10];
            UISwitch *swButton = (UISwitch*)[cell viewWithTag:11];
            titleLabel.text = [itemDict objectForKey:EventRowTitle];
            swButton.on = [[_eventModel objectForKey:EventItem_IsAllDay] boolValue];
            swButton.enabled = YES;
        }
            break;
        case EventCellType_IsPeriod:
        {
            UILabel *titleLabel = (UILabel*)[cell viewWithTag:10];
            UISwitch *swButton = (UISwitch*)[cell viewWithTag:11];
            titleLabel.text = [itemDict objectForKey:EventRowTitle];
            swButton.on = [[_eventModel objectForKey:EventItem_IsPeriod] boolValue];
            swButton.enabled = YES;
        }
            break;
        case EventCellType_IsLeapMonth:
        {
            UILabel *titleLabel = (UILabel*)[cell viewWithTag:10];
            UISwitch *swButton = (UISwitch*)[cell viewWithTag:11];
            titleLabel.text = [itemDict objectForKey:EventRowTitle];
            
            NSDate *startDate = [_eventModel objectForKey:EventItem_StartDate];
            NSDateComponents *startComp = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:startDate];
            BOOL isLeapMonth = [NSDate isLunarLeapMonthAtDate:startComp isKorean:[A3DateHelper isCurrentLocaleIsKorea]];
            if (isLeapMonth) {
                swButton.enabled = YES;
                swButton.on = [[_eventModel objectForKey:EventItem_IsLeapMonth] boolValue];
            }
            else {
                swButton.enabled = NO;
                swButton.on = NO;
                [_eventModel setObject:@(NO) forKey:EventItem_IsLeapMonth];
            }
        }
            break;
        case EventCellType_StartDate:
        case EventCellType_EndDate:
        {
            NSString *keyName = itemType == EventCellType_StartDate ? EventItem_StartDate : EventItem_EndDate;
            UILabel *titleLabel = (UILabel*)[cell viewWithTag:10];
            UIImageView *lunarImageView = (UIImageView*)[cell viewWithTag:11];
            UILabel *dateLabel = (UILabel*)[cell viewWithTag:12];
            
            if ( [[_eventModel objectForKey:EventItem_IsPeriod] boolValue] ) {
                titleLabel.text = itemType == EventCellType_StartDate ? @"Starts" : @"Ends";
            }
            else {
                titleLabel.text = @"Date";
            }
            
            lunarImageView.hidden = ![[_eventModel objectForKey:EventItem_IsLunar] boolValue];
            
            if ( [[_eventModel objectForKey:keyName] isKindOfClass:[NSDate class]] ) {
                dateLabel.text = [A3Formatter stringFromDate:[_eventModel objectForKey:keyName]
                                                      format:[[A3DaysCounterModelManager sharedManager] dateFormatForAddEditIsAllDays:[[_eventModel objectForKey:EventItem_IsAllDay] boolValue]]];
            }
            else {
                dateLabel.text = [A3Formatter stringFromDate:[NSDate date]
                                                      format:[[A3DaysCounterModelManager sharedManager] dateFormatForAddEditIsAllDays:[[_eventModel objectForKey:EventItem_IsAllDay] boolValue]]];
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
                    cell.separatorInset = UIEdgeInsetsMake(0, IS_IPHONE ? 15 : 28, 0, 0);
                }
            }
            else {
                if ([[_eventModel objectForKey:EventItem_IsPeriod] boolValue] && itemType == EventCellType_StartDate) {
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
            
            if ( [[_eventModel objectForKey:EventItem_IsPeriod] boolValue] && itemType == EventCellType_EndDate ) {
                NSDate *startDate = [_eventModel objectForKey:EventItem_StartDate];
                if ( ![[_eventModel objectForKey:EventItem_EndDate] isKindOfClass:[NSNull class]] ) {
                    NSDate *endDate = [_eventModel objectForKey:EventItem_EndDate];
                    
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
            break;
        case EventCellType_RepeatType:
        {
            UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
            textLabel.text = [itemDict objectForKey:EventRowTitle];
            NSNumber *repeatType = [_eventModel objectForKey:EventItem_RepeatType];
            if (repeatType) {
                cell.detailTextLabel.text = [[A3DaysCounterModelManager sharedManager] repeatTypeStringFromValue:[repeatType integerValue]];
            }
            else {
                cell.detailTextLabel.text = @"";
            }
            
            textLabel.textColor = [UIColor blackColor];
        }
            break;
        case EventCellType_EndRepeatDate:
        {
            UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
            UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:11];
            textLabel.text = [itemDict objectForKey:EventRowTitle];
            detailTextLabel.text = [[A3DaysCounterModelManager sharedManager] repeatEndDateStringFromDate:[_eventModel objectForKey:EventItem_RepeatEndDate]];
            textLabel.textColor = [UIColor blackColor];
        }
            break;
        case EventCellType_Alert:
        {
            cell.textLabel.text = [itemDict objectForKey:EventRowTitle];
            cell.detailTextLabel.text = [[A3DaysCounterModelManager sharedManager] alertDateStringFromDate:[_eventModel objectForKey:EventItem_EffectiveStartDate]
                                                                                            alertDate:[_eventModel objectForKey:EventItem_AlertDatetime]];

            cell.textLabel.textColor = [UIColor blackColor];
        }
            break;
        case EventCellType_Calendar:
        {
            UILabel *nameLabel = (UILabel*)[cell viewWithTag:12];
            UIImageView *colorImageView = (UIImageView*)[cell viewWithTag:11];
            
            DaysCounterCalendar *calendar = [_eventModel objectForKey:EventItem_Calendar];
            if (calendar) {
                nameLabel.text = calendar.calendarName;
                colorImageView.tintColor = [calendar color];
            }
            else {
                nameLabel.text = @"";
            }
            
            colorImageView.hidden = ([nameLabel.text length] < 1 );
        }
            break;
        case EventCellType_DurationOption:
        {
            cell.textLabel.text = [itemDict objectForKey:EventRowTitle];
            cell.detailTextLabel.text = [[A3DaysCounterModelManager sharedManager] durationOptionStringFromValue:[[_eventModel objectForKey:EventItem_DurationOption] integerValue]];
            cell.textLabel.textColor = [UIColor blackColor];
        }
            break;
        case EventCellType_Location:
        {
            UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
            UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:11];
            NSMutableDictionary *location = [_eventModel objectForKey:EventItem_Location];
            if ( location ) {
                FSVenue *venue = [[FSVenue alloc] init];
                venue.location.country = [location objectForKey:EventItem_Country];
                venue.location.state = [location objectForKey:EventItem_State];
                venue.location.city = [location objectForKey:EventItem_City];
                venue.location.address = [location objectForKey:EventItem_Address];
                textLabel.text = [location objectForKey:EventItem_LocationName];
                textLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
            }
            else {
                textLabel.text = @"Location";
                textLabel.textColor = [UIColor colorWithRed:199/255.0 green:199/255.0 blue:205/255.0 alpha:1.0];
            }

            detailTextLabel.text = @"";
        }
            break;
        case EventCellType_Notes:
        {
            UITextView *textView = (UITextView*)[cell viewWithTag:10];
            textView.text = ([[_eventModel objectForKey:EventItem_Notes] length] > 0 ? [_eventModel objectForKey:EventItem_Notes] : @"Notes");
            if ( [[_eventModel objectForKey:EventItem_Notes] length] > 0 ) {
                textView.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
            }
            else {
                textView.textColor = [UIColor colorWithRed:199/255.0 green:199/255.0 blue:205/255.0 alpha:1.0];
            }
        }
            break;
        case EventCellType_DateInput:
        {
            UIDatePicker *datePicker = (UIDatePicker*)[cell viewWithTag:10];
            if ( [self.inputDateKey isEqualToString: EventItem_StartDate] ) {
                NSDate *date = [_eventModel objectForKey:EventItem_StartDate];
                if (!date || [date isKindOfClass:[NSNull class]]) {
                    date = [_eventModel objectForKey:EventItem_EndDate];
                }
                if (!date || [date isKindOfClass:[NSNull class]]) {
                    date = [NSDate date];
                }
                
                datePicker.date = date;
                
                if ([[_eventModel objectForKey:EventItem_IsPeriod] boolValue]) {
                    cell.separatorInset = UIEdgeInsetsMake(0, IS_IPHONE ? 15 : 28, 0, 0);
                }
                else {
                    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
                }
            }
            else if ( [self.inputDateKey isEqualToString: EventItem_EndDate] ) {
                NSDate *date = [_eventModel objectForKey:EventItem_EndDate];
                if (!date || [date isKindOfClass:[NSNull class]]) {
                    date = [_eventModel objectForKey:EventItem_StartDate];
                }
                if (!date || [date isKindOfClass:[NSNull class]]) {
                    date = [NSDate date];
                }
                
                datePicker.date = date;
                cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
            }
            else {
                datePicker.date = ([[_eventModel objectForKey:self.inputDateKey] isKindOfClass:[NSDate class]] ? [_eventModel objectForKey:self.inputDateKey] : [NSDate date]);
            }
            if ( [[_eventModel objectForKey:EventItem_IsAllDay] boolValue] ) {
                datePicker.datePickerMode = UIDatePickerModeDate;
            }
            else {
                datePicker.datePickerMode = UIDatePickerModeDateAndTime;
            }
        }
            break;
        case EventCellType_Advanced:
        {
            UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
            UILabel *button = (UILabel*)[cell viewWithTag:11];
            if (_isAdvancedCellOpen) {
                textLabel.textColor = [A3AppDelegate instance].themeColor;
            }
            else {
                textLabel.textColor = [UIColor colorWithRed:109.0/255.0 green:109.0/255.0 blue:114.0/255.0 alpha:1.0];
            }
            button.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DegreesToRadians((_isAdvancedCellOpen ?  270 : 90)));
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
            break;
    }
}

#pragma mark TableView Data Source Related
- (NSInteger)indexOfRowItemType:(A3DaysCounterAddEventCellType)itemType atSectionArray:(NSArray *)array {
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
            {
                NSString *str = [_eventModel objectForKey:EventItem_Notes];
                NSDictionary *textAttributes = @{
                                                 NSFontAttributeName : [UIFont systemFontOfSize:17]
                                                 };
                
                NSString *testText = str ? str : @"";
                NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:testText attributes:textAttributes];
                UITextView *txtView = [[UITextView alloc] init];
                [txtView setAttributedText:attributedString];
                float margin = IS_IPAD ? 49:31;
                CGSize txtViewSize = [txtView sizeThatFits:CGSizeMake(self.view.frame.size.width-margin, CGFLOAT_MAX)];
                float cellHeight = txtViewSize.height;
                
                // memo카테고리에서는 화면의 가장 아래까지 노트필드가 채워진다.
                float defaultCellHeight = 180.0;
                
                if (cellHeight < defaultCellHeight) {
                    return defaultCellHeight;
                }
                else {
                    return cellHeight;
                }
            }
                break;
            case EventCellType_Advanced:
                retHeight = IS_RETINA ? 55.5 : 56.0;
                break;
            default:
                retHeight = 44.0;
                break;
        }
    }
    
    return retHeight;
}

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
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            UIButton *button = (UIButton*)[cell viewWithTag:13];
            [self toggleDateInputAction:button];
        }
            break;
        case EventCellType_RepeatType:
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
            A3DaysCounterSetupRepeatViewController *nextVC = [[A3DaysCounterSetupRepeatViewController alloc] initWithNibName:@"A3DaysCounterSetupRepeatViewController" bundle:nil];
            nextVC.eventModel = self.eventModel;
            nextVC.dismissCompletionBlock = ^{
                NSNumber *repeatType = [_eventModel objectForKey:EventItem_RepeatType];
                if (!repeatType) {
                    return;
                }
                
                NSMutableArray *section1_items = [[self.sectionTitleArray objectAtIndex:AddSection_Section_1] objectForKey:AddEventItems];
                NSIndexPath *repeatIndexPath = [NSIndexPath indexPathForRow:[self indexOfRowItemType:EventCellType_RepeatType atSectionArray:section1_items]
                                                                  inSection:AddSection_Section_1];
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:repeatIndexPath];
                cell.detailTextLabel.text = [[A3DaysCounterModelManager sharedManager] repeatTypeStringFromValue:[repeatType integerValue]];

                if ([repeatType integerValue] == RepeatType_Never) {
                    // EffectiveStartDate 갱신.
                    [_eventModel setObject:[_eventModel objectForKey:EventItem_StartDate] forKey:EventItem_EffectiveStartDate];
                    
                    // EndRepeatRow 제거.
                    NSMutableArray *section1_items = [[self.sectionTitleArray objectAtIndex:AddSection_Section_1] objectForKey:AddEventItems];
                    __block NSInteger endRepeatRowIndex = -1;
                    [section1_items enumerateObjectsUsingBlock:^(NSDictionary *rowData, NSUInteger idx, BOOL *stop) {
                        if ([[rowData objectForKey:EventRowType] isEqualToNumber:@(EventCellType_EndRepeatDate)]) {
                            endRepeatRowIndex = (NSInteger)idx;
                            *stop = YES;
                        }
                    }];
                    if (endRepeatRowIndex == -1) {
                        return;
                    }
                    [section1_items removeObjectAtIndex:endRepeatRowIndex];
                    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:endRepeatRowIndex inSection:AddSection_Section_1]] withRowAnimation:UITableViewRowAnimationMiddle];
                    
                    return;
                }
                
                // EffectiveStartDate & EffectiveAlertDate 갱신.
                [[A3DaysCounterModelManager sharedManager] reloadDatesOfEventModel:_eventModel];
                // AlertCell 갱신.
                NSIndexPath *alertIndexPath = [NSIndexPath indexPathForRow:[self indexOfRowItemType:EventCellType_Alert atSectionArray:section1_items]
                                                                 inSection:AddSection_Section_1];
                [tableView deselectRowAtIndexPath:alertIndexPath animated:YES];
                cell = [tableView cellForRowAtIndexPath:alertIndexPath];
                UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:11];
                detailTextLabel.text = [[A3DaysCounterModelManager sharedManager] alertDateStringFromDate:[_eventModel objectForKey:EventItem_EffectiveStartDate]
                                                                                                alertDate:[_eventModel objectForKey:EventItem_AlertDatetime]];
                

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
                    [section1_items insertObject:@{ EventRowTitle : @"End Repeat", EventRowType : @(EventCellType_EndRepeatDate)} atIndex:repeatTypeRowIndex + 1];
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
            break;
        case EventCellType_EndRepeatDate:
        {
            A3DaysCounterSetupEndRepeatViewController *nextVC = [[A3DaysCounterSetupEndRepeatViewController alloc] initWithNibName:@"A3DaysCounterSetupEndRepeatViewController" bundle:nil];
            nextVC.eventModel = self.eventModel;
            nextVC.dismissCompletionBlock = ^{
                NSMutableArray *section1_items = [[self.sectionTitleArray objectAtIndex:AddSection_Section_1] objectForKey:AddEventItems];
                NSIndexPath *endRepeatIndexPath = [NSIndexPath indexPathForRow:[self indexOfRowItemType:EventCellType_EndRepeatDate atSectionArray:section1_items]
                                                                     inSection:AddSection_Section_1];
                [tableView deselectRowAtIndexPath:endRepeatIndexPath animated:YES];
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:endRepeatIndexPath];
                UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:11];
                detailTextLabel.text = [[A3DaysCounterModelManager sharedManager] repeatEndDateStringFromDate:[_eventModel objectForKey:EventItem_RepeatEndDate]];
            };
            
            if ( IS_IPHONE )
                [self.navigationController pushViewController:nextVC animated:YES];
            else
                [self.A3RootViewController presentRightSideViewController:nextVC];
            [self closeDatePickerCell];
        }
            break;
        case EventCellType_Alert:
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            A3DaysCounterSetupAlertViewController *nextVC = [[A3DaysCounterSetupAlertViewController alloc] initWithNibName:@"A3DaysCounterSetupAlertViewController" bundle:nil];
            nextVC.eventModel = self.eventModel;

            nextVC.dismissCompletionBlock = ^{
                NSMutableArray *section1_items = [[self.sectionTitleArray objectAtIndex:AddSection_Section_1] objectForKey:AddEventItems];
                NSIndexPath *alertIndexPath = [NSIndexPath indexPathForRow:[self indexOfRowItemType:EventCellType_Alert atSectionArray:section1_items]
                                                                 inSection:AddSection_Section_1];

                UITableViewCell *cell = [tableView cellForRowAtIndexPath:alertIndexPath];
                cell.detailTextLabel.text = [[A3DaysCounterModelManager sharedManager] alertDateStringFromDate:[_eventModel objectForKey:EventItem_EffectiveStartDate]
                                                                                                alertDate:[_eventModel objectForKey:EventItem_AlertDatetime]];
                FNLOG(@"\ntoday: %@, \nFirstStartDate: %@, \nEffectiveDate: %@, \nAlertDate: %@", [NSDate date], [_eventModel objectForKey:EventItem_StartDate], [_eventModel objectForKey:EventItem_EffectiveStartDate], [_eventModel objectForKey:EventItem_AlertDatetime]);
            };
            
            if ( IS_IPHONE ) {
                [self.navigationController pushViewController:nextVC animated:YES];
            }
            else {
                [self.A3RootViewController presentRightSideViewController:nextVC];
            }
            [self closeDatePickerCell];
        }
            break;
        case EventCellType_Calendar:
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            A3DaysCounterSetupCalendarViewController *nextVC = [[A3DaysCounterSetupCalendarViewController alloc] initWithNibName:@"A3DaysCounterSetupCalendarViewController" bundle:nil];
            nextVC.eventModel = self.eventModel;
            nextVC.dismissCompletionBlock = ^{
                NSMutableArray *section1_items = [[self.sectionTitleArray objectAtIndex:AddSection_Section_1] objectForKey:AddEventItems];
                NSIndexPath *calendarIndexPath = [NSIndexPath indexPathForRow:[self indexOfRowItemType:EventCellType_Calendar atSectionArray:section1_items]
                                                                    inSection:AddSection_Section_1];
//                [tableView deselectRowAtIndexPath:calendarIndexPath animated:YES];
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:calendarIndexPath];
                UILabel *nameLabel = (UILabel*)[cell viewWithTag:12];
                UIImageView *colorImageView = (UIImageView*)[cell viewWithTag:11];
                DaysCounterCalendar *calendar = [_eventModel objectForKey:EventItem_Calendar];
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
            break;
        case EventCellType_DurationOption:
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            A3DaysCounterSetupDurationViewController *nextVC = [[A3DaysCounterSetupDurationViewController alloc] initWithNibName:@"A3DaysCounterSetupDurationViewController" bundle:nil];
            nextVC.eventModel = self.eventModel;
            nextVC.dismissCompletionBlock = ^{
                NSMutableArray *section1_items = [[self.sectionTitleArray objectAtIndex:AddSection_Section_1] objectForKey:AddEventItems];
                NSIndexPath *durationIndexPath = [NSIndexPath indexPathForRow:[self indexOfRowItemType:EventCellType_DurationOption atSectionArray:section1_items]
                                                                    inSection:AddSection_Section_1];
                self.isDurationIntialized = YES;
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:durationIndexPath];
                UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:11];
                detailTextLabel.text = [[A3DaysCounterModelManager sharedManager] durationOptionStringFromValue:[[_eventModel objectForKey:EventItem_DurationOption] integerValue]];
            };
            
            if ( IS_IPHONE )
                [self.navigationController pushViewController:nextVC animated:YES];
            else
                [self.A3RootViewController presentRightSideViewController:nextVC];
            [self closeDatePickerCell];
        }
            break;
        case EventCellType_Location:{
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:([_eventModel objectForKey:EventItem_Location] ? @"Delete Location" : nil)
                                                            otherButtonTitles:@"Use My Location", @"Search Location", nil];
            actionSheet.tag = ActionTag_Location;
            [actionSheet showInView:self.view];
            [self closeDatePickerCell];
        }
            break;
        case EventCellType_Advanced:
            [self advancedRowTouchedUp:indexPath];
            break;
    }
}

#pragma mark - action method
- (void)resignAllAction
{
    [[self firstResponder] resignFirstResponder];
    [self.textViewResponder resignFirstResponder];
}

- (void)doneButtonAction:(UIBarButtonItem *)button
{
    [self resignAllAction];
    // 디비추가 처리
    if ( self.eventModel ) {
        // 입력값이 있어야 하는것들에 대한 체크
        if ( [[_eventModel objectForKey:EventItem_Name] length] < 1 ) {
            [_eventModel setObject:@"Untitled" forKey:EventItem_Name];
        }
        if ( [[_eventModel objectForKey:EventItem_IsPeriod] boolValue] && [[_eventModel objectForKey:EventItem_EndDate] isKindOfClass:[NSNull class]] ) {
            [self alertMessage:@"Please enter the end date."];
            return;
        }
        
        if ( [[_eventModel objectForKey:EventItem_IsPeriod] boolValue] ) {
            NSDate *startDate = [_eventModel objectForKey:EventItem_StartDate];
            NSDate *endDate = [_eventModel objectForKey:EventItem_EndDate];
            
            if ( [endDate timeIntervalSince1970] < [startDate timeIntervalSince1970]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:@"Cannot Save Event\nThe start date must be before the end date."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];
                return;
            }
        }
        
        if ( _eventItem ) {
            [[A3DaysCounterModelManager sharedManager] modifyEvent:_eventItem withInfo:_eventModel];
        }
        else {
            [[A3DaysCounterModelManager sharedManager] addEvent:self.eventModel];
        }
        
        FNLOG(@"reloadAlertDateListForLocalNotification Start");
        [[A3DaysCounterModelManager sharedManager] reloadAlertDateListForLocalNotification];
        FNLOG(@"reloadAlertDateListForLocalNotification End");
    }
    // 창닫기
    [self cancelAction:nil];
}

- (void)cancelAction:(UIBarButtonItem *)button
{
    [self resignAllAction];

    if (IS_IPAD) {
        [self.A3RootViewController dismissCenterViewController];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)toggleFavorite:(id)sender
{
    BOOL isSelected = [[_eventModel objectForKey:EventItem_IsFavorite] boolValue];
    isSelected = !isSelected;
    [_eventModel setObject:@(isSelected) forKey:EventItem_IsFavorite];

    [((UIButton *)sender) setImage:[UIImage imageNamed:isSelected ? @"star02_on" : @"star02"] forState:UIControlStateNormal];
    ((UIButton *)sender).tintColor = [A3AppDelegate instance].themeColor;
}

- (void)photoAction:(id)sender
{
    [self resignAllAction];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:( [_eventModel objectForKey:EventItem_Image] ? @"Delete photo" : nil) otherButtonTitles:@"Take Photo", @"Choose Existing", nil];
    actionSheet.tag = ActionTag_Photo;
    [actionSheet showInView:self.view];
}

- (void)updateEndDateDiffFromStartDate:(NSDate*)startDate
{
    NSMutableArray *items = [[_sectionTitleArray objectAtIndex:AddSection_Section_1] objectForKey:AddEventItems];
    if ( [[_eventModel objectForKey:EventItem_IsPeriod] boolValue] ) {
        if ( [[_eventModel objectForKey:EventItem_EndDate] isKindOfClass:[NSDate class]] ) {
            NSDate *endDate = [_eventModel objectForKey:EventItem_EndDate];
            NSTimeInterval diff = [endDate timeIntervalSince1970] - [startDate timeIntervalSince1970];
            endDate = [NSDate dateWithTimeInterval:diff sinceDate:[_eventModel objectForKey:EventItem_StartDate]];
            [_eventModel setObject:endDate forKey:EventItem_EndDate];
        }
        else {
            [_eventModel setObject:[_eventModel objectForKey:EventItem_StartDate] forKey:EventItem_EndDate];
        }
    }
    [self.tableView beginUpdates];
    [self reloadItems:items withType:EventCellType_StartDate section:AddSection_Section_1];
    [self reloadItems:items withType:EventCellType_EndDate section:AddSection_Section_1];
    [self.tableView endUpdates];
}

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
        [_eventModel setObject:@(swButton.on) forKey:EventItem_IsLunar];
        if ([swButton isOn]) {
            NSInteger leapMonthRowIndex = [self indexOfRowItemType:EventCellType_IsLunar atSectionArray:sectionRow_items];
            [sectionRow_items insertObject:@{EventRowTitle : @"Leap Month", EventRowType : @(EventCellType_IsLeapMonth)} atIndex:leapMonthRowIndex + 1];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:leapMonthRowIndex + 1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationMiddle];
        }
        else {
            NSInteger leapMonthRowIndex = [self indexOfRowItemType:EventCellType_IsLeapMonth atSectionArray:sectionRow_items];
            [sectionRow_items removeObjectAtIndex:leapMonthRowIndex];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:leapMonthRowIndex inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationMiddle];
        }
        
        NSDate *startDate = [_eventModel objectForKey:EventItem_StartDate];
        [self updateEndDateDiffFromStartDate:startDate];
    }
    else if ( rowItemType == EventCellType_IsLeapMonth ) {
        [_eventModel setObject:@(swButton.on) forKey:EventItem_IsLeapMonth];
    }
    else if ( rowItemType == EventCellType_IsAllDay ) {
        [_eventModel setObject:@(swButton.on) forKey:EventItem_IsAllDay];
        
        if (!_eventItem && [swButton isOn] == NO && !_isDurationIntialized) {
            [_eventModel setObject:@(DurationOption_Day|DurationOption_Hour|DurationOption_Minutes) forKey:EventItem_DurationOption];
        }
        else if (!_eventItem && [swButton isOn]) {
            NSInteger durationFlag = [[_eventModel objectForKey:EventItem_DurationOption] integerValue];
            durationFlag = durationFlag & ~(DurationOption_Hour|DurationOption_Minutes|DurationOption_Seconds);
            if (durationFlag == 0) {
                durationFlag = DurationOption_Day;
            }
            
            [_eventModel setObject:@(durationFlag) forKey:EventItem_DurationOption];
        }
        
        [self reloadItems:sectionRow_items withType:EventCellType_DateInput section:indexPath.section animation:UITableViewRowAnimationNone];
        [self reloadItems:sectionRow_items withType:EventCellType_StartDate section:indexPath.section animation:UITableViewRowAnimationNone];
        [self reloadItems:sectionRow_items withType:EventCellType_EndDate section:indexPath.section animation:UITableViewRowAnimationNone];
        [self reloadItems:sectionRow_items withType:EventCellType_DurationOption section:indexPath.section animation:UITableViewRowAnimationNone];
    }
    else if ( rowItemType == EventCellType_IsPeriod ) {
        [_eventModel setObject:[NSNumber numberWithBool:swButton.on] forKey:EventItem_IsPeriod];
        NSInteger startEndSwitchRowIndex = [self indexOfRowItemType:EventCellType_IsPeriod atSectionArray:sectionRow_items];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:startEndSwitchRowIndex inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:startEndSwitchRowIndex + 1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
        
        if ( swButton.on ) {
            if ( ![self isExistsEndDateCellInItems:sectionRow_items] ) {
                NSInteger startDateRowIndex = [self indexOfRowItemType:EventCellType_StartDate atSectionArray:sectionRow_items];
                NSInteger datePickerRow = 0;
                if ( [self.inputDateKey isEqualToString:EventItem_StartDate] ) {
                    datePickerRow = 1;
                }
                
                [sectionRow_items insertObject:@{EventRowTitle : @"Ends", EventRowType : @(EventCellType_EndDate)} atIndex:startDateRowIndex + 1 + datePickerRow];
                
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
                NSInteger endDateRowIndex = [self indexOfRowItemType:EventCellType_EndDate atSectionArray:sectionRow_items];
                if (endDateRowIndex == -1) {
                    return;
                }
                
                NSInteger dateInputRowIndex = -1;
                if ( [self.inputDateKey isEqualToString:EventItem_EndDate] ) {
                    dateInputRowIndex = [self indexOfRowItemType:EventCellType_DateInput atSectionArray:sectionRow_items];
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
    NSDate *prevDate = [_eventModel objectForKey:EventItem_StartDate];
    
    if ([[_eventModel objectForKey:EventItem_IsAllDay] boolValue]) {
        [_eventModel setObject:datePicker.date forKey:self.inputDateKey];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *dateComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[datePicker date]];
        dateComp.hour = 0;
        dateComp.minute = 0;
        dateComp.second = 0;
        [_eventModel setObject:[calendar dateFromComponents:dateComp] forKey:self.inputDateKey];
    }
    else {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *dateComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:[datePicker date]];
        dateComp.second = 0;
        [_eventModel setObject:[calendar dateFromComponents:dateComp] forKey:self.inputDateKey];
    }
    
    // EffectiveStartDate & EffectiveAlertDate 갱신.
    [[A3DaysCounterModelManager sharedManager] reloadDatesOfEventModel:_eventModel];
    // AlertCell 갱신.
    NSMutableArray *section1_items = [[self.sectionTitleArray objectAtIndex:AddSection_Section_1] objectForKey:AddEventItems];
    NSIndexPath *alertIndexPath = [NSIndexPath indexPathForRow:[self indexOfRowItemType:EventCellType_Alert atSectionArray:section1_items]
                                                     inSection:AddSection_Section_1];
    [self.tableView deselectRowAtIndexPath:alertIndexPath animated:YES];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:alertIndexPath];
    UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:11];
    detailTextLabel.text = [[A3DaysCounterModelManager sharedManager] alertDateStringFromDate:[_eventModel objectForKey:EventItem_EffectiveStartDate]
                                                                                    alertDate:[_eventModel objectForKey:EventItem_AlertDatetime]];

    if ( [self.inputDateKey isEqualToString:EventItem_StartDate] ) {
        [self updateEndDateDiffFromStartDate:prevDate];
        
        if ([[_eventModel objectForKey:EventItem_IsLunar] boolValue]) {
            NSIndexPath *leapMonthIndexPath = [NSIndexPath indexPathForRow:[self indexOfRowItemType:EventCellType_IsLeapMonth atSectionArray:section1_items]
                                                             inSection:AddSection_Section_1];
            [self.tableView reloadRowsAtIndexPaths:@[leapMonthIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    else if ( [self.inputDateKey isEqualToString:EventItem_EndDate] ) {
        [self reloadItems:items withType:EventCellType_EndDate section:indexPath.section];
    }
}

- (void)closeDatePickerCell
{
    NSMutableArray *items = [[_sectionTitleArray objectAtIndex:1] objectForKey:AddEventItems];
    NSInteger removeType = 0;
    if ( [self.inputDateKey isEqualToString:EventItem_StartDate] )
        removeType = EventCellType_StartDate;
    else if ( [self.inputDateKey isEqualToString:EventItem_EndDate] )
        removeType = EventCellType_EndDate;
    
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
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
    UIButton *button = (UIButton*)[cell viewWithTag:11];
    NSMutableArray *section1_items = [[self.sectionTitleArray objectAtIndex:AddSection_Section_1] objectForKey:AddEventItems];
    
    _isAdvancedCellOpen = !_isAdvancedCellOpen;
    
    [UIView animateWithDuration:0.35 animations:^{
        button.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DegreesToRadians((_isAdvancedCellOpen ?  270 : 90)));
    }];

    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
    }];

    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(indexPath.row - 1) inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
    
    if (!_isAdvancedCellOpen) {
        NSUInteger advancedCellRowIndex = [self indexOfRowItemType:EventCellType_Advanced atSectionArray:section1_items];
        textLabel.textColor = [UIColor colorWithRed:109.0/255.0 green:109.0/255.0 blue:114.0/255.0 alpha:1.0];
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
        [advancedRows addObject:@{ EventRowTitle : @"Repeat", EventRowType : @(EventCellType_RepeatType)}];
        if ( [[_eventModel objectForKey:EventItem_RepeatType] integerValue] != 0 ) {
            [advancedRows addObject:@{ EventRowTitle : @"End Repeat", EventRowType : @(EventCellType_EndRepeatDate)}];
        }
        [advancedRows addObject:@{ EventRowTitle : @"Alert", EventRowType : @(EventCellType_Alert)}];
        [advancedRows addObject:@{ EventRowTitle : @"Calendar", EventRowType : @(EventCellType_Calendar)}];
        [advancedRows addObject:@{ EventRowTitle : @"Duration Option", EventRowType : @(EventCellType_DurationOption)}];
        [advancedRows addObject:@{ EventRowTitle : @"Location", EventRowType : @(EventCellType_Location)}];
        [advancedRows addObject:@{ EventRowTitle : @"Notes", EventRowType : @(EventCellType_Notes)}];
        
        textLabel.textColor = [A3AppDelegate instance].themeColor;
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

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
     if ( actionSheet.tag == ActionTag_Location ) {
//        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:2] animated:YES];

//         NSMutableArray *section1_items = [[self.sectionTitleArray objectAtIndex:AddSection_Section_1] objectForKey:AddEventItems];
//         NSIndexPath *locationIndexPath = [NSIndexPath indexPathForRow:[self indexOfRowItemType:EventCellType_Location atSectionArray:section1_items]
//                                                             inSection:AddSection_Section_1];
//         [self.tableView deselectRowAtIndexPath:locationIndexPath animated:YES];
     }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ( actionSheet.tag == ActionTag_Photo ) {
        if ( buttonIndex == actionSheet.destructiveButtonIndex ) {
            [_eventModel removeObjectForKey:EventItem_Image];
            [_eventModel removeObjectForKey:EventItem_Thumbnail];
            [_eventModel removeObjectForKey:EventItem_ImageFilename];
            [self.tableView reloadData];
        }
        else if ( buttonIndex != actionSheet.cancelButtonIndex ) {
            UIImagePickerController *pickerCtrl = [[UIImagePickerController alloc] init];
            pickerCtrl.delegate = self;
            if ( buttonIndex == actionSheet.firstOtherButtonIndex )
                pickerCtrl.sourceType = UIImagePickerControllerSourceTypeCamera;
            else if ( buttonIndex == actionSheet.firstOtherButtonIndex+1 )
                pickerCtrl.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            pickerCtrl.allowsEditing = YES;
            pickerCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
            if ( IS_IPHONE || pickerCtrl.sourceType == UIImagePickerControllerSourceTypeCamera )
                [self presentViewController:pickerCtrl animated:YES completion:nil];
            else {
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                UIButton *button = (UIButton*)[cell viewWithTag:11];
                CGRect rect = [self.tableView convertRect:button.frame fromView:cell.contentView];
                self.imagePopover = [[UIPopoverController alloc] initWithContentViewController:pickerCtrl];
                self.imagePopover.delegate = self;
                [self.imagePopover presentPopoverFromRect:rect inView:self.tableView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            }
        }
    }
    else if ( actionSheet.tag == ActionTag_Location ) {
        if ( buttonIndex == actionSheet.destructiveButtonIndex ) {
            [_eventModel removeObjectForKey:EventItem_Location];
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
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:@"Internet Connection is not avaiable."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];
                return;
            }
            
            A3DaysCounterSetupLocationViewController *nextVC = [[A3DaysCounterSetupLocationViewController alloc] initWithNibName:@"A3DaysCounterSetupLocationViewController" bundle:nil];
            nextVC.eventModel = self.eventModel;
            [self.navigationController pushViewController:nextVC animated:YES];
        }
    }
    else if ( actionSheet.tag == ActionTag_DeleteEvent ) {
        if ( buttonIndex == actionSheet.destructiveButtonIndex ) {
            [[A3DaysCounterModelManager sharedManager] removeEvent:_eventItem];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (IBAction)deleteEventAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Event" otherButtonTitles: nil];
    actionSheet.tag = ActionTag_DeleteEvent;
    [actionSheet showInView:self.view];
}


#pragma mark - UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.imagePopover = nil;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [manager stopUpdatingLocation];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Internet Connection is not avaiable." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    self.locationManager = nil;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [manager stopUpdatingLocation];
    CLLocation *location = [locations lastObject];
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([error code] == kCLErrorNetwork) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Internet Connection is not avaiable." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            return;
        }
        
        if ( error == nil ) {
            if ( [placemarks count] < 1 ) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Can not find current location information" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                return;
            }
            
            CLPlacemark *placeMark = [placemarks objectAtIndex:0];
            NSDictionary *addressDict = placeMark.addressDictionary;
            
            NSMutableDictionary *locItem = [[A3DaysCounterModelManager sharedManager] emptyEventLocationModel];
            [locItem setObject:[_eventModel objectForKey:EventItem_ID] forKey:EventItem_ID];
            [locItem setObject:@(location.coordinate.latitude) forKey:EventItem_Latitude];
            [locItem setObject:@(location.coordinate.longitude) forKey:EventItem_Longitude];
            [locItem setObject:[addressDict objectForKey:(NSString*)kABPersonAddressStreetKey] forKey:EventItem_LocationName];
            [locItem setObject:([[addressDict objectForKey:(NSString*)kABPersonAddressCountryKey] length] > 0 ? [addressDict objectForKey:(NSString*)kABPersonAddressCountryKey] : @"") forKey:EventItem_Country];
            [locItem setObject:([[addressDict objectForKey:(NSString*)kABPersonAddressStateKey] length] > 0 ? [addressDict objectForKey:(NSString*)kABPersonAddressStateKey] : @"") forKey:EventItem_State];
            [locItem setObject:([[addressDict objectForKey:(NSString*)kABPersonAddressCityKey] length] > 0 ? [addressDict objectForKey:(NSString*)kABPersonAddressCityKey] : @"") forKey:EventItem_City];
            [locItem setObject:([[addressDict objectForKey:(NSString*)kABPersonAddressStreetKey] length] > 0 ? [addressDict objectForKey:(NSString*)kABPersonAddressStreetKey] : @"") forKey:EventItem_Address];
            [locItem setObject:@"" forKey:EventItem_Contact];
            [_eventModel setObject:locItem forKey:EventItem_Location];
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
        [self.imagePopover dismissPopoverAnimated:YES];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if ( image == nil ) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    UIImage *circleImage = [A3DaysCounterModelManager circularScaleNCrop:image rect:CGRectMake(0, 0, 64.0, 64.0)];
    [_eventModel setObject:circleImage forKey:EventItem_Thumbnail];
    [_eventModel setObject:image forKey:EventItem_Image];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    if ( IS_IPHONE || picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.imagePopover dismissPopoverAnimated:YES];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self resignAllAction];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self setFirstResponder:textField];
    [self closeDatePickerCell];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [_eventModel setObject:text forKey:EventItem_Name];
    NSLog(@"%s %@",__FUNCTION__,text);
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_eventModel setObject:textField.text forKey:EventItem_Name];
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [_eventModel setObject:textField.text forKey:EventItem_Name];
    self.firstResponder = nil;
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ( [[_eventModel objectForKey:EventItem_Notes] length] < 1 ) {
        textView.text = @"";
    }
    
    self.textViewResponder = textView;
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [_eventModel setObject:textView.text forKey:EventItem_Notes];
    if ( [[_eventModel objectForKey:EventItem_Notes] length] < 1 ) {
        textView.text = @"Notes";
    }
    else {
        UITableViewCell *cell = (UITableViewCell*)[[[textView superview] superview] superview];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    self.textViewResponder = nil;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [_eventModel setObject:textView.text forKey:EventItem_Notes];
    
    if ( [textView.text length] > 0 ) {
        textView.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
    }
    else {
        textView.textColor = [UIColor colorWithRed:178.0/255.0 green:178.0/255.0 blue:178.0/255.0 alpha:1.0];
    }

    CGSize newSize = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, MAXFLOAT)];
    if (newSize.height < 180) {
        return;
    }
    UITableViewCell *currentCell = (UITableViewCell *)[[[textView superview] superview] superview];
    CGFloat diffHeight = newSize.height - currentCell.frame.size.height;
    
    currentCell.frame = CGRectMake(currentCell.frame.origin.x,
                                   currentCell.frame.origin.y,
                                   currentCell.frame.size.width,
                                   newSize.height);

    [UIView beginAnimations:@"cellExpand" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationCurve:7];
    [UIView setAnimationDuration:0.25];
    self.tableView.contentOffset = CGPointMake(0.0, self.tableView.contentOffset.y + diffHeight);
    [UIView commitAnimations];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
}

@end
