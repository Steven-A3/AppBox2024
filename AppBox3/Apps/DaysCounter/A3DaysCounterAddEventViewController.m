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

#define ActionTag_Location      100
#define ActionTag_Photo         101
#define ActionTag_DeleteEvent   102

@interface A3DaysCounterAddEventViewController ()
@property (strong, nonatomic) NSMutableArray *sectionTitleArray;
@property (strong, nonatomic) NSMutableDictionary *eventModel;
@property (strong, nonatomic) NSString *inputDateKey;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UIPopoverController *imagePopover;

- (void)alertMessage:(NSString*)message;
- (BOOL)isExistsEndDateCellInItems:(NSArray*)items;
- (void)reloadItems:(NSArray*)items withType:(NSInteger)cellType section:(NSInteger)section;
- (void)removeDateInputCellWithItems:(NSMutableArray*)items indexPath:(NSIndexPath*)indexPath;
- (void)showPhotoSelector;
- (void)updateEndDateDiffFromStartDate:(NSDate*)startDate;

- (void)resignAllAction;
- (void)cancelAction:(UIBarButtonItem *)button;
- (void)toggleFavorite:(id)sender;
- (void)photoAction:(id)sender;
- (void)toggleSwitchAction:(id)sender;
- (void)dateChangeAction:(id)sender;
- (void)toggleDateInputAction:(id)sender;
- (void)toggleSectionAction:(NSIndexPath*)indexPath;
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    self.title = (_eventItem ? @"Edit Event" : @"Add Event");
    [self makeBackButtonEmptyArrow];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
    [self rightBarButtonDoneButton];
    
    if ( _eventItem ) {
        [self setupSectionTemplateWithInfo:_eventItem];
    }
    else {
        self.sectionTitleArray = [NSMutableArray arrayWithObjects:
                                  // section 0
                                  @{AddEventSectionName : @"", AddEventItems : [NSMutableArray arrayWithObjects:@{EventRowTitle : @"Title", EventRowType : @(EventCellType_Title)},
                                                                                                                @{EventRowTitle : @"Photo", EventRowType : @(EventCellType_Photo)}, nil]},
                                  // section 1
                                  @{AddEventSectionName : @"",AddEventItems : [NSMutableArray arrayWithObjects:@{EventRowTitle : @"Lunar", EventRowType : @(EventCellType_IsLunar)},
                                                                                                                @{EventRowTitle : @"All-day", EventRowType : @(EventCellType_IsAllDay)},
                                                                                                                @{EventRowTitle : @"Starts-Ends", EventRowType : @(EventCellType_IsPeriod)},
                                                                                                                @{EventRowTitle : @"Starts", EventRowType : @(EventCellType_StartDate)}, nil]},
                                  // section 2
                                  @{AddEventSectionName : @"",AddEventItems : [NSMutableArray arrayWithObject:@{EventRowTitle : @"ADVANCED", EventRowType : @(EventCellType_Advanced)}]}, nil];
    }
    
    if ( ![[A3DaysCounterModelManager sharedManager] isSupportLunar] ) {
        NSMutableArray *items = [[self.sectionTitleArray objectAtIndex:1] objectForKey:AddEventItems];
        [items removeObjectAtIndex:0];
    }
    
    [self.navigationController setToolbarHidden:YES];
    isFirstAppear = YES;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, (IS_IPHONE ? 15.0 : 28.0), 0, 0);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ( [_sectionTitleArray count] > AddSection_Advanced ) {
        if ( [[_eventModel objectForKey:EventItem_RepeatType] integerValue] != 0 ) {
            // 반복 종료일자 아이템 추가
            if ( ![self isExistsCellType:EventCellType_EndRepeatDate section:AddSection_Advanced] ) {
                [self insertCellType:EventCellType_EndRepeatDate row:2 section:AddSection_Advanced ];
            }
        }
        else {
            // 반복 종료일자 아이템 삭제
            if ( [self isExistsCellType:EventCellType_EndRepeatDate section:AddSection_Advanced] ) {
                [self removeCellType:EventCellType_EndRepeatDate section:AddSection_Advanced];
            }
        }
    }
    
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
    // Dispose of any resources that can be recreated.
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

- (void)showPhotoSelector
{
    A3PhotoSelectViewController *viewCtrl = [[A3PhotoSelectViewController alloc] initWithNibName:@"A3PhotoSelectViewController" bundle:nil];
    viewCtrl.delegate = self;

    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
    navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:navCtrl animated:YES completion:nil];
}

- (BOOL)isExistsCellType:(NSInteger)cellType section:(NSInteger)section
{
    if ( section >= [_sectionTitleArray count] )
        return NO;
    
    NSArray *items = [[_sectionTitleArray objectAtIndex:section] objectForKey:AddEventItems];
    BOOL isExists = NO;
    for(NSDictionary *item in items) {
        if ( [[item objectForKey:EventRowType] integerValue] == cellType ) {
            isExists = YES;
            break;
        }
    }
    
    return isExists;
}

- (void)insertCellType:(NSInteger)cellType row:(NSInteger)row section:(NSInteger)section
{
    if ( section >= [_sectionTitleArray count] )
        return;
    
    NSMutableArray *items = [[_sectionTitleArray objectAtIndex:section] objectForKey:AddEventItems];
    if ( row >= ([items count]+1) )
        return;
    
    [items insertObject:@{EventRowTitle : [[A3DaysCounterModelManager sharedManager] titleForCellType:cellType],EventRowType : @(cellType)} atIndex:row];
}

- (void)removeCellType:(NSInteger)cellType section:(NSInteger)section
{
    if ( section >= [_sectionTitleArray count] )
        return;
    
    NSMutableArray *items = [[_sectionTitleArray objectAtIndex:section] objectForKey:AddEventItems];
    NSMutableArray *removeItems = [NSMutableArray array];
    for(NSDictionary *item in items) {
        if ( [[item objectForKey:EventRowType] integerValue] == cellType ) {
            [removeItems addObject:item];
        }
    }
    [items removeObjectsInArray:removeItems];
    [removeItems removeAllObjects];
    
}

- (void)setupSectionTemplateWithInfo:(DaysCounterEvent*)info
{
    NSMutableArray *section1_Items = [NSMutableArray array];
    [section1_Items addObject:@{EventRowTitle : @"Lunar", EventRowType : @(EventCellType_IsLunar)}];
    [section1_Items addObject:@{EventRowTitle : @"All-day", EventRowType : @(EventCellType_IsAllDay)}];
    [section1_Items addObject:@{EventRowTitle : @"Starts-Ends", EventRowType : @(EventCellType_IsPeriod)}];
    [section1_Items addObject:@{EventRowTitle : @"Starts", EventRowType : @(EventCellType_StartDate)}];
    if ( [info.isPeriod boolValue] ) {
        [section1_Items addObject:@{ EventRowTitle : @"Ends", EventRowType : @(EventCellType_EndDate) }];
    }
    
    self.sectionTitleArray = [NSMutableArray arrayWithObjects:
                              // section 0
                              @{AddEventSectionName : @"",
                                AddEventItems : [NSMutableArray arrayWithObjects:@{EventRowTitle : @"Title",
                                                                                   EventRowType : @(EventCellType_Title)},
                                                                                 @{EventRowTitle : @"Photo",
                                                                                   EventRowType : @(EventCellType_Photo)}, nil]},
                              // section 1
                              @{AddEventSectionName : @"",AddEventItems : section1_Items},
                              // section 2 Advanced
                              @{AddEventSectionName : @"",AddEventItems : [NSMutableArray arrayWithObject:@{EventRowTitle : @"ADVANCED",
                                                                                                            EventRowType : @(EventCellType_Advanced)}]}, nil];

    // section 2 Advanced
    NSMutableArray *advancedSectionItems = [[_sectionTitleArray objectAtIndex:AddSection_Advanced] objectForKey:AddEventItems];
    [advancedSectionItems addObject:@{ EventRowTitle : @"Repeat", EventRowType : @(EventCellType_RepeatType)}];
    if ( [info.repeatType integerValue] != RepeatType_Never ) {
        [advancedSectionItems addObject:@{ EventRowTitle : @"End Repeat", EventRowType : @(EventCellType_EndRepeatDate)}];
    }
    [advancedSectionItems addObject:@{ EventRowTitle : @"Alert", EventRowType : @(EventCellType_Alert)}];
    [advancedSectionItems addObject:@{ EventRowTitle : @"Calendar", EventRowType : @(EventCellType_Calendar)}];
    [advancedSectionItems addObject:@{ EventRowTitle : @"Duration Option", EventRowType : @(EventCellType_DurationOption)}];
    [advancedSectionItems addObject:@{ EventRowTitle : @"Location", EventRowType : @(EventCellType_Location)}];
    [advancedSectionItems addObject:@{ EventRowTitle : @"Notes", EventRowType : @(EventCellType_Notes)}];
//    [_sectionTitleArray addObject:@{AddEventSectionName : @"ADVANCED", AddEventItems : items}];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [_sectionTitleArray count] + (_eventItem ? 1 : 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if ( section == [_sectionTitleArray count] && _eventItem ) {
        return 1;
    }
    NSArray *items = [[_sectionTitleArray objectAtIndex:section] objectForKey:AddEventItems];
    return [items count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ( (_eventItem && section == [_sectionTitleArray count]) || (section < AddSection_Advanced) ) {
        return 35.0;
    }
    if ( section == 0 ) {
        return 36.0;
    }
    else if ( section == 1 ) {
        return 35.0;
    }
    
//    else if ( section >= AddSection_Advanced )
//        return 0.01;
//    return 36.0;
    
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if ( _eventItem && section == [_sectionTitleArray count] ) {
        return 37.0;
    }
    return ( (_eventItem==nil && section == AddSection_Advanced) ? 37.0 : 0.01);
}

- (NSString*)cellIdentifierAtIndexPath:(NSIndexPath*)indexPath
{
    NSArray *cellIDs = @[@"titleCell",@"photoCell",@"switchCell",@"switchCell",@"switchCell",@"dateCell",@"dateCell",@"value1Cell",@"value1Cell",@"value1Cell",@"calendarCell",@"value1Cell",@"value1Cell",@"notesCell",@"dateInputCell",@"",@"",@"advancedCell"];
    if ( _eventItem && indexPath.section == [_sectionTitleArray count] )
        return @"normalCell";
    
    NSArray *items = [[_sectionTitleArray objectAtIndex:indexPath.section] objectForKey:AddEventItems];
    NSDictionary *itemDict = [items objectAtIndex:indexPath.row];
    
    NSInteger itemType = [[itemDict objectForKey:EventRowType] integerValue];
    
    return [cellIDs objectAtIndex:itemType];
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
        //        NSArray *cellArray = [[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterAddEventCell" owner:nil options:nil];
        
        if ( itemType == EventCellType_RepeatType || itemType == EventCellType_EndRepeatDate || itemType == EventCellType_Alert || itemType == EventCellType_DurationOption || itemType == EventCellType_Location) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            //            cell = [cellArray objectAtIndex:14];
            //            UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:11];
            //            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            //            detailTextLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
            //            [cell setNeedsLayout];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
            cell.textLabel.tag = 10;
            cell.detailTextLabel.tag = 11;
        }
        else {
            NSArray *cellArray = [[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterAddEventCell" owner:nil options:nil];
            
            switch (itemType) {
                case EventCellType_Title :{
                    cell = [cellArray objectAtIndex:0];
                    UITextField *textField = (UITextField*)[cell viewWithTag:10];
                    UIButton *button = (UIButton*)[cell viewWithTag:11];
                    textField.delegate = self;
                    //                    textField.returnKeyType = UIReturnKeyDone;
                    [button addTarget:self action:@selector(toggleFavorite:) forControlEvents:UIControlEventTouchUpInside];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                    break;
                case EventCellType_Photo:{
                    cell = [cellArray objectAtIndex:1];
                    UIButton *button = (UIButton*)[cell viewWithTag:11];
                    [button addTarget:self action:@selector(photoAction:) forControlEvents:UIControlEventTouchUpInside];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                    break;
                case EventCellType_IsLunar:
                case EventCellType_IsAllDay:
                case EventCellType_IsPeriod:{
                    cell = [cellArray objectAtIndex:2];
                    UISwitch *swButton = (UISwitch*)[cell viewWithTag:11];
                    [swButton addTarget:self action:@selector(toggleSwitchAction:) forControlEvents:UIControlEventValueChanged];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                    break;
                case EventCellType_StartDate:
                case EventCellType_EndDate:{
                    cell = [cellArray objectAtIndex:3];
                    UIImageView *imageView = (UIImageView*)[cell viewWithTag:11];
                    imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    imageView.tintColor = [UIColor lightGrayColor];
                }
                    break;
                case EventCellType_Calendar:
                {
                    cell = [cellArray objectAtIndex:4];
                    UIImageView *imageView = (UIImageView*)[cell viewWithTag:11];
                    imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                }
                    break;
                case EventCellType_Notes:{
                    cell = [cellArray objectAtIndex:5];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    UITextView *textView = (UITextView*)[cell viewWithTag:10];
                    textView.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
                    textView.delegate = self;
                    //                textView.textContainerInset = UIEdgeInsetsZero;
                }
                    break;
                case EventCellType_DateInput:{
                    cell = [cellArray objectAtIndex:6];
                    UIDatePicker *datePicker = (UIDatePicker*)[cell viewWithTag:10];
                    [datePicker addTarget:self action:@selector(dateChangeAction:) forControlEvents:UIControlEventValueChanged];
                }
                    break;
                case EventCellType_Advanced:{
                    cell = [cellArray objectAtIndex:12];
                    cell.contentView.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    UIButton *button = (UIButton*)[cell viewWithTag:11];
                    [SFKImage setDefaultFont:[UIFont fontWithName:@"appbox" size:17.0]];
                    [SFKImage setDefaultColor:[UIColor grayColor]];
                    UIImage *downImage = [SFKImage imageNamed:@"j"];
                    UIImage *upImage = [SFKImage imageNamed:@"i"];
                    [button setImage:downImage forState:UIControlStateNormal];
                    [button setImage:upImage forState:UIControlStateSelected];
                    button.selected = NO;
                    
                    //                button.transform = CGAffineTransformMakeRotation(DegreesToRadians(90));
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
            button.selected = [[_eventModel objectForKey:EventItem_IsFavorite] boolValue];
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
            break;
        }
            break;
        case EventCellType_IsAllDay:
        {
            UILabel *titleLabel = (UILabel*)[cell viewWithTag:10];
            UISwitch *swButton = (UISwitch*)[cell viewWithTag:11];
            titleLabel.text = [itemDict objectForKey:EventRowTitle];
            swButton.on = [[_eventModel objectForKey:EventItem_IsAllDay] boolValue];
        }
            break;
        case EventCellType_IsPeriod:
        {
            UILabel *titleLabel = (UILabel*)[cell viewWithTag:10];
            UISwitch *swButton = (UISwitch*)[cell viewWithTag:11];
            titleLabel.text = [itemDict objectForKey:EventRowTitle];
            swButton.on = [[_eventModel objectForKey:EventItem_IsPeriod] boolValue];
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
            
            
            //NSInteger inputType = ( [self.inputDateKey isEqualToString:EventItem_StartDate] ? EventCellType_StartDate : ([self.inputDateKey isEqualToString:EventItem_EndDate] ? EventCellType_EndDate : 0) );
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
            
            if ( [keyName isEqualToString:self.inputDateKey] && itemType == inputType ) {
                dateLabel.textColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
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
            UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:11];
            textLabel.text = [itemDict objectForKey:EventRowTitle];
            detailTextLabel.text = [[A3DaysCounterModelManager sharedManager] repeatTypeStringFromValue:[[_eventModel objectForKey:EventItem_RepeatType] integerValue]];
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
            UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
            UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:11];
            textLabel.text = [itemDict objectForKey:EventRowTitle];
            detailTextLabel.text = [[A3DaysCounterModelManager sharedManager] alertDateStringFromDate:[_eventModel objectForKey:EventItem_StartDate]
                                                                                            alertDate:[_eventModel objectForKey:EventItem_AlertDatetime]];
            textLabel.textColor = [UIColor blackColor];
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
            //            UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
            //            UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:11];
            //            textLabel.text = [itemDict objectForKey:EventRowTitle];
            //            detailTextLabel.text = [[A3DaysCounterModelManager sharedManager] durationOptionStringFromValue:[[_eventModel objectForKey:EventItem_DurationOption] integerValue]];
            //            textLabel.textColor = [UIColor blackColor];
            //            [textLabel sizeToFit];
            //            [detailTextLabel sizeToFit];
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
                textLabel.text = [location objectForKey:EventItem_LocationName];//([address length] > 0 ? address : [itemDict objectForKey:EventRowTitle]);
                textLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
            }
            else {
                textLabel.text = @"Location";
                textLabel.textColor = [UIColor colorWithRed:199/255.0 green:199/255.0 blue:205/255.0 alpha:1.0];
            }
            //            cell.textLabel.textColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:205.0/255.0 alpha:1.0];
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
            UIButton *button = (UIButton*)[cell viewWithTag:11];
            
            NSMutableArray *advItems =  [[self.sectionTitleArray objectAtIndex:AddSection_Advanced] objectForKey:AddEventItems];
            BOOL isOpen = [advItems count] > 1;
            //            BOOL isOpen = ([_sectionTitleArray count] > AddSection_Advanced);
            textLabel.textColor = ( isOpen ? [UIColor colorWithRed:3.0/255.0 green:122.0/255.0 blue:1.0 alpha:1.0] : [UIColor colorWithRed:109.0/255.0 green:109.0/255.0 blue:114.0/255.0 alpha:1.0]);
            //            button.transform = CGAffineTransformMakeRotation(DegreesToRadians( (isOpen ? -90 : 90)));
            button.selected = isOpen;
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
            break;
    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( _eventItem && indexPath.section == [_sectionTitleArray count] ) {
        cell.textLabel.frame = CGRectMake(cell.textLabel.frame.origin.x, cell.textLabel.frame.origin.y, cell.contentView.frame.size.width, cell.textLabel.frame.size.height);
    }
    else {
        NSArray *items = [[_sectionTitleArray objectAtIndex:indexPath.section] objectForKey:AddEventItems];
        NSDictionary *itemDict = [items objectAtIndex:indexPath.row];
        NSInteger itemType = [[itemDict objectForKey:EventRowType] integerValue];
        
        switch (itemType) {
            default:
                break;
        }
    }
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
            case EventCellType_Notes:{
                NSString *str = [_eventModel objectForKey:EventItem_Notes];
                CGRect strBounds = [str boundingRectWithSize:CGSizeMake(tableView.frame.size.width, 99999.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17.0]} context:nil];
                retHeight = strBounds.size.height + 24.0;
                if ( retHeight < 180.0 )
                    retHeight = 180.0;
            }
                break;
            case EventCellType_Advanced:
                retHeight = IS_RETINA ? 56: 57.0;
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
    NSDictionary *itemDict = [items objectAtIndex:indexPath.row];
    
    NSInteger itemType = [[itemDict objectForKey:EventRowType] integerValue];
    
    switch (itemType) {
        case EventCellType_Title:{
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            UITextField *textField = (UITextField*)[cell viewWithTag:10];
            [textField becomeFirstResponder];
            [self closeDatePickerCell];
        }
            break;
        case EventCellType_Photo:
            [self photoAction:nil];
            [self closeDatePickerCell];
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
            A3DaysCounterSetupRepeatViewController *nextVC = [[A3DaysCounterSetupRepeatViewController alloc] initWithNibName:@"A3DaysCounterSetupRepeatViewController" bundle:nil];
            nextVC.eventModel = self.eventModel;
            nextVC.dismissCompletionBlock = ^{
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:11];
                detailTextLabel.text = [[A3DaysCounterModelManager sharedManager] repeatTypeStringFromValue:[[_eventModel objectForKey:EventItem_RepeatType] integerValue]];
            };
            if ( IS_IPHONE )
                [self.navigationController pushViewController:nextVC animated:YES];
            else
                [self.A3RootViewController presentRightSideViewController:nextVC];
            [self closeDatePickerCell];
        }
            break;
        case EventCellType_EndRepeatDate:
        {
            A3DaysCounterSetupEndRepeatViewController *nextVC = [[A3DaysCounterSetupEndRepeatViewController alloc] initWithNibName:@"A3DaysCounterSetupEndRepeatViewController" bundle:nil];
            nextVC.eventModel = self.eventModel;
            nextVC.dismissCompletionBlock = ^{
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
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
            A3DaysCounterSetupAlertViewController *nextVC = [[A3DaysCounterSetupAlertViewController alloc] initWithNibName:@"A3DaysCounterSetupAlertViewController" bundle:nil];
            nextVC.eventModel = self.eventModel;
            nextVC.dismissCompletionBlock = ^{
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:11];
                detailTextLabel.text = [[A3DaysCounterModelManager sharedManager] alertDateStringFromDate:[_eventModel objectForKey:EventItem_StartDate]
                                                                                                alertDate:[_eventModel objectForKey:EventItem_AlertDatetime]];
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
            A3DaysCounterSetupCalendarViewController *nextVC = [[A3DaysCounterSetupCalendarViewController alloc] initWithNibName:@"A3DaysCounterSetupCalendarViewController" bundle:nil];
            nextVC.eventModel = self.eventModel;
            nextVC.dismissCompletionBlock = ^{
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
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
            A3DaysCounterSetupDurationViewController *nextVC = [[A3DaysCounterSetupDurationViewController alloc] initWithNibName:@"A3DaysCounterSetupDurationViewController" bundle:nil];
            nextVC.eventModel = self.eventModel;
            nextVC.dismissCompletionBlock = ^{
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
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
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:([_eventModel objectForKey:EventItem_Location] ? @"Delete Location" : nil)
                                                            otherButtonTitles:@"Use My Location",@"Search Location", nil];
            actionSheet.tag = ActionTag_Location;
            [actionSheet showInView:self.view];
            [self closeDatePickerCell];
        }
            break;
        case EventCellType_Advanced:
            [self toggleSectionAction:indexPath];
            break;
    }
}

//#pragma mark - A3PhotoSelectViewControllerDelegate
//- (void)photoSelectViewControllerDidCancel:(A3PhotoSelectViewController *)viewCtrl
//{
//    [viewCtrl dismissViewControllerAnimated:YES completion:nil];
//}
//
//- (void)photoSelectViewControllerDidDone:(A3PhotoSelectViewController *)viewCtrl
//{
//    if ( viewCtrl.item ) {
//        ALAsset *assetItem = (ALAsset*)viewCtrl.item;
//        UIImage *image = [UIImage imageWithCGImage:assetItem.thumbnail];
//        UIImage *circleImage = [A3DaysCounterModelManager circularScaleNCrop:image rect:CGRectMake(0, 0, image.size.width, image.size.height)];
//        [_eventModel setObject:circleImage forKey:EventItem_Thumbnail];
//        
//        ALAssetRepresentation *rep = [assetItem defaultRepresentation];
//        CGImageRef imgRef = [rep fullResolutionImage];
//        UIImage *originalImage = [UIImage imageWithCGImage:imgRef];
//        [_eventModel setObject:originalImage forKey:EventItem_Image];
//        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
//    }
//    [viewCtrl dismissViewControllerAnimated:YES completion:nil];
//}

#pragma mark - action method
- (void)resignAllAction
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if ( cell ) {
        UITextField *textField = (UITextField*)[cell viewWithTag:10];
        [textField resignFirstResponder];
    }
    if ( [_sectionTitleArray count] > AddSection_Advanced ) {
        NSArray *items = [[_sectionTitleArray objectAtIndex:AddSection_Advanced] objectForKey:AddEventItems];
        cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[items count]-1 inSection:AddSection_Advanced]];
        if ( cell ) {
            UITextView *textView = (UITextView*)[cell viewWithTag:10];
            [textView resignFirstResponder];
        }
    }
}

- (void)doneButtonAction:(UIBarButtonItem *)button
{
    [self resignAllAction];
    // 디비추가 처리
    if ( self.eventModel ) {
        // 입력값이 있어야 하는것들에 대한 체크
//        if ( [[_eventModel objectForKey:EventItem_Name] length] < 1 ) {
//            [self alertMessage:@"Please enter a title."];
//            return;
//        }
//        else
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
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Cannot Save Event\nThe start date must be before the end date." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
                return;
            }
        }
        if ( _eventItem )
            [[A3DaysCounterModelManager sharedManager] modifyEvent:_eventItem withInfo:_eventModel];
        else
            [[A3DaysCounterModelManager sharedManager] addEvent:self.eventModel];
    }
    // 창닫기
    [self cancelAction:nil];
}

- (void)cancelAction:(UIBarButtonItem *)button
{
    [self resignAllAction];
//    if ( _eventItem ) {
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }
//    else {
//        if ( IS_IPHONE )
//            [self dismissViewControllerAnimated:YES completion:nil];
//        else
//            [self.navigationController popViewControllerAnimated:YES];
//    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)toggleFavorite:(id)sender
{
    UIButton *button = (UIButton*)sender;
    button.selected = !button.selected;
    [_eventModel setObject:[NSNumber numberWithBool:button.selected] forKey:EventItem_IsFavorite];
}

- (void)photoAction:(id)sender
{
    [self resignAllAction];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:( [_eventModel objectForKey:EventItem_Image] ? @"Delete photo" : nil) otherButtonTitles:@"Take Photo",@"Choose Existing", nil];
    actionSheet.tag = ActionTag_Photo;
    [actionSheet showInView:self.view];
}

- (void)updateEndDateDiffFromStartDate:(NSDate*)startDate
{
    NSMutableArray *items = [[_sectionTitleArray objectAtIndex:AddSection_DateInfo] objectForKey:AddEventItems];
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
    [self reloadItems:items withType:EventCellType_StartDate section:AddSection_DateInfo];
    [self reloadItems:items withType:EventCellType_EndDate section:AddSection_DateInfo];
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
    
    NSMutableArray *items = [[_sectionTitleArray objectAtIndex:indexPath.section] objectForKey:AddEventItems];
    NSDictionary *itemDict = [items objectAtIndex:indexPath.row];
    
    NSInteger itemType = [[itemDict objectForKey:EventRowType] integerValue];
    if ( itemType == EventCellType_IsLunar ) {
        [_eventModel setObject:[NSNumber numberWithBool:swButton.on] forKey:EventItem_IsLunar];
        NSDate *startDate = [_eventModel objectForKey:EventItem_StartDate];
//        BOOL isLunar = [[_eventModel objectForKey:EventItem_IsLunar] boolValue];
//        NSDateComponents *dateComp = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:startDate];
//        BOOL isResultLeapMonth = NO;
//        NSDate *convertDate = [NSDate lunarCalcWithComponents:dateComp gregorianToLunar:isLunar leapMonth:NO korean:[self isCurrentLocaleIsKorea] resultLeapMonth:&isResultLeapMonth];
//        [_eventModel setObject:convertDate forKey:EventItem_StartDate];
        [self updateEndDateDiffFromStartDate:startDate];
    }
    else if ( itemType == EventCellType_IsAllDay ) {
        [_eventModel setObject:[NSNumber numberWithBool:swButton.on] forKey:EventItem_IsAllDay];
        [self reloadItems:items withType:EventCellType_DateInput section:indexPath.section];
        [self reloadItems:items withType:EventCellType_StartDate section:indexPath.section];
        [self reloadItems:items withType:EventCellType_EndDate section:indexPath.section];
    }
    else if ( itemType == EventCellType_IsPeriod ) {
        [_eventModel setObject:[NSNumber numberWithBool:swButton.on] forKey:EventItem_IsPeriod];
        if ( swButton.on ) {
            if ( ![self isExistsEndDateCellInItems:items] ) {
                NSDictionary *rowItem = @{ EventRowTitle : @"Ends", EventRowType : @(EventCellType_EndDate) };
                [items addObject:rowItem];
                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[items count]-1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationTop];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
            }
        }
        else {
            if ( [self isExistsEndDateCellInItems:items] ) {
                [items removeLastObject];
                if ( [self.inputDateKey isEqualToString:EventItem_EndDate] ) {
                    [items removeLastObject];
                }
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[items count] inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
                if ( [self.inputDateKey isEqualToString:EventItem_EndDate] ) {
                    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[items count]+1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
                    self.inputDateKey = nil;
                }
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
                
            }
        }
    }
}

#pragma mark DatePicker
- (void)dateChangeAction:(id)sender
{
    NSLog(@"%s",__FUNCTION__);
    [self resignAllAction];
    UIDatePicker *datePicker = (UIDatePicker*)sender;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[[datePicker superview] superview] superview]];
    if ( indexPath == nil )
        return;
    
    NSMutableArray *items = [[_sectionTitleArray objectAtIndex:indexPath.section] objectForKey:AddEventItems];
    NSDate *prevDate = [_eventModel objectForKey:EventItem_StartDate];
    
    //if ([[_eventModel objectForKey:EventItem_IsLunar] boolValue]) {
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
        [_eventModel setObject:datePicker.date forKey:self.inputDateKey];
    }
    
    if ( [self.inputDateKey isEqualToString:EventItem_StartDate] ) {
        [self updateEndDateDiffFromStartDate:prevDate];
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

- (void)toggleSectionAction:(NSIndexPath*)indexPath {
    [self resignAllAction];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
    UIButton *button = (UIButton*)[cell viewWithTag:11];
    
   
    NSMutableArray *advItems =  [[self.sectionTitleArray objectAtIndex:AddSection_Advanced] objectForKey:AddEventItems];
    BOOL isOpen = [advItems count] > 1;//( [_sectionTitleArray count] > AddSection_Advanced );
    if ( !isOpen ) {
        NSMutableArray *items = advItems;//[NSMutableArray array];
        
        [items addObject:@{ EventRowTitle : @"Repeat", EventRowType : @(EventCellType_RepeatType)}];
        if ( [[_eventModel objectForKey:EventItem_RepeatType] integerValue] != 0 ) {
            [items addObject:@{ EventRowTitle : @"End Repeat", EventRowType : @(EventCellType_EndRepeatDate)}];
        }
        [items addObject:@{ EventRowTitle : @"Alert", EventRowType : @(EventCellType_Alert)}];
        [items addObject:@{ EventRowTitle : @"Calendar", EventRowType : @(EventCellType_Calendar)}];
        [items addObject:@{ EventRowTitle : @"Duration Option", EventRowType : @(EventCellType_DurationOption)}];
        [items addObject:@{ EventRowTitle : @"Location", EventRowType : @(EventCellType_Location)}];
        [items addObject:@{ EventRowTitle : @"Notes", EventRowType : @(EventCellType_Notes)}];

//        [_sectionTitleArray addObject:@{AddEventSectionName : @"ADVANCED", AddEventItems : items}];
//        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:AddSection_Advanced] withRowAnimation:UITableViewRowAnimationMiddle];
        textLabel.textColor = [UIColor colorWithRed:3.0/255.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        NSMutableArray *indexPaths = [NSMutableArray array];
        for(NSInteger i=1; i < [items count]; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
        }
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationMiddle];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    else {
        textLabel.textColor = [UIColor colorWithRed:109.0/255.0 green:109.0/255.0 blue:114.0/255.0 alpha:1.0];
        NSMutableArray *indexPaths = [NSMutableArray array];
        for(NSInteger i=1; i < [advItems count]; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
        }
        [advItems removeObjectsInRange:NSMakeRange(1, [advItems count] - 1)];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationMiddle];
//        [_sectionTitleArray removeObjectAtIndex:AddSection_Advanced];
//        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:AddSection_Advanced] withRowAnimation:UITableViewRowAnimationMiddle];
    }
    button.selected = !isOpen;
    [self.tableView setNeedsDisplay];
//    [UIView animateWithDuration:0.35 animations:^{
//        button.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DegreesToRadians((isOpen ? 90 : -90)));
//    }];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
     if ( actionSheet.tag == ActionTag_Location ) {
        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:2] animated:YES];
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
        else if ( buttonIndex == (actionSheet.firstOtherButtonIndex+1)) {
            if (![[A3AppDelegate instance].reachability isReachable]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Internet Connection is not avaiable." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                return;
            }
            
            A3DaysCounterSetupLocationViewController *nextVC = [[A3DaysCounterSetupLocationViewController alloc] initWithNibName:@"A3DaysCounterSetupLocationViewController"
                                                                                                                          bundle:nil];
            nextVC.eventModel = self.eventModel;
//            UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:nextVC];
//            navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
//            [self presentViewController:navCtrl animated:YES completion:nil];
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
    //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Can not find current location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
//    UITableViewCell *cell = (UITableViewCell*)[[textField.superview superview] superview];
//    cell.selected = YES;
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
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ( [[_eventModel objectForKey:EventItem_Notes] length] < 1 ) {
        textView.text = @"";
    }
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
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *str = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    [_eventModel setObject:str forKey:EventItem_Notes];
    
    CGRect strBounds = [textView.text boundingRectWithSize:CGSizeMake(textView.frame.size.width, 99999.0) options:NSLineBreakByCharWrapping|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : textView.font} context:nil];

    UITableViewCell *cell = (UITableViewCell*)[[[textView superview] superview] superview];
    CGFloat diffHeight = (strBounds.size.height + 24.0 < 180.0 ? 0.0 : (strBounds.size.height + 24.0) - cell.frame.size.height);
    
//    NSLog(@"%s %f, %@",__FUNCTION__,diffHeight,NSStringFromCGRect(strBounds));
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height + diffHeight);
    self.tableView.contentSize = CGSizeMake(self.tableView.contentSize.width, self.tableView.contentSize.height + diffHeight);
    [self.tableView scrollRectToVisible:cell.frame animated:YES];
    
    if ( [str length] > 0 )
        textView.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
    else
        textView.textColor = [UIColor colorWithRed:178.0/255.0 green:178.0/255.0 blue:178.0/255.0 alpha:1.0];
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [_eventModel setObject:textView.text forKey:EventItem_Notes];
}

@end
