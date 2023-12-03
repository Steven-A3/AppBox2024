//
//  A3DaysCounterEventListEditViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 7..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterEventListEditViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "UIViewController+iPad_rightSideView.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "DaysCounterEvent.h"
#import "A3DaysCounterEventChangeCalendarViewController.h"
#import "A3DateHelper.h"
#import "UIImage+imageWithColor.h"
#import "NSDate+formatting.h"
#import "NSDateFormatter+A3Addition.h"
#import "DaysCounterCalendar.h"
#import "UITableView+utility.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"
#import "A3SyncManager.h"
#import "A3AppDelegate.h"
#import "A3UIDevice.h"
#import "A3UserDefaults+A3Addition.h"

#define ActionSheet_DeleteAll           100
#define ActionSheet_DeleteSelected      101

@interface A3DaysCounterEventListEditViewController () <UIPopoverControllerDelegate, UIActionSheetDelegate, UIActivityItemSource>
@property (strong, nonatomic) NSMutableArray *itemArray;
@property (strong, nonatomic) UIImage *checkNormalImage;
@property (strong, nonatomic) NSMutableDictionary *checkStatusDict;
@property (strong, nonatomic) NSMutableArray *selectedArray;
@property (strong, nonatomic) UIPopoverController *popoverVC;
@property (strong, nonatomic) UINavigationController *modalVC;
@property (assign, nonatomic) NSInteger shareItemTitleIndex;
@property (strong, nonatomic) UIActivityViewController *activityViewController;

@end


@implementation A3DaysCounterEventListEditViewController

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

    self.title = _calendarItem.name;
    [self rightBarButtonDoneButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Delete All", @"Delete All") style:UIBarButtonItemStylePlain target:self action:@selector(deleteAllAction:)];
    self.toolbarItems = _bottomToolbar.items;
    [self.navigationController setToolbarHidden:NO];
    
    self.checkNormalImage = [A3DaysCounterModelManager strokeCircleImageSize:CGSizeMake(22.0, 22.0) color:[UIColor colorWithRed:201.0 / 255.0 green:201.0 / 255.0 blue:204.0 / 255.0 alpha:1.0]];
    self.checkStatusDict = [NSMutableDictionary dictionary];
    self.selectedArray = [NSMutableArray array];
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 48, 0, 0)];

	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewDidAppear) name:A3NotificationRightSideViewDidAppear object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewWillDismiss) name:A3NotificationRightSideViewWillDismiss object:nil];
	}
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)applicationWillResignActive {
	if (_activityViewController) {
		[self dismissViewControllerAnimated:NO completion:^{
			_activityViewController = nil;
		}];
	}
	if (_popoverVC) {
		[_popoverVC dismissPopoverAnimated:NO];
		_popoverVC = nil;
	}
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
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
	[self reloadTableView];
}

- (void)enableControls:(BOOL)enable {
	[self.navigationItem.leftBarButtonItem setEnabled:enable];
	[self.navigationItem.rightBarButtonItem setEnabled:enable];
	[self.toolbarItems[0] setEnabled:enable];
	[self.toolbarItems[2] setEnabled:enable];
	[self.toolbarItems[4] setEnabled:enable];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadTableView];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([self.navigationController.navigationBar isHidden]) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadTableView
{
    if( [_calendarItem.type integerValue] == CalendarCellType_User ) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"calendarID == %@", _calendarItem.uniqueID];
		NSArray *events = [DaysCounterEvent findAllWithPredicate:predicate];
        self.itemArray = [NSMutableArray arrayWithArray:events];
	} else {
        NSArray *sourceArray = nil;
        if( [_calendarItem.uniqueID isEqualToString:SystemCalendarID_All] )
            sourceArray = [_sharedManager allEventsList];
        else if( [_calendarItem.uniqueID isEqualToString:SystemCalendarID_Past] )
            sourceArray = [_sharedManager pastEventsListWithDate:[NSDate date]];
        else if( [_calendarItem.uniqueID isEqualToString:SystemCalendarID_Upcoming] )
            sourceArray = [_sharedManager upcomingEventsListWithDate:[NSDate date]];
        self.itemArray = [NSMutableArray arrayWithArray:sourceArray];
    }
    [self.tableView reloadData];
}

#pragma mark
- (void)willDismissFromRightSide
{
    if (_modalVC) {
        [_modalVC dismissViewControllerAnimated:NO completion:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_itemArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"eventListEditCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterEventListEditCell" owner:nil options:nil] lastObject];
        UIButton *button = (UIButton*)[cell viewWithTag:11];
        [button addTarget:self action:@selector(toggleSelectAction:) forControlEvents:UIControlEventTouchUpInside];
        button.tintColor = [[A3UserDefaults standardUserDefaults] themeColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [button setImage:[self.checkNormalImage tintedImageWithColor:[[A3UserDefaults standardUserDefaults] themeColor]] forState:UIControlStateNormal];
        [button setImage:[[UIImage imageNamed:@"check"] tintedImageWithColor:[[A3UserDefaults standardUserDefaults] themeColor]] forState:UIControlStateSelected];
    }   
    
    // Configure the cell...
    DaysCounterEvent *item = [_itemArray objectAtIndex:indexPath.row];
    UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
    UIButton *checkButton = (UIButton*)[cell viewWithTag:11];
    textLabel.text = item.eventName;
    checkButton.selected = [[_checkStatusDict objectForKey:item.uniqueID] boolValue];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - UIActionSheetDelegate

- (void)deleteAllEventsAction
{
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    for(DaysCounterEvent *event in _itemArray){
        [context deleteObject:event];
    }
    [_checkStatusDict removeAllObjects];
    [_itemArray removeAllObjects];
    [self.tableView reloadData];
}

- (void)deleteSelectedEventsAction
{
    NSMutableArray *removeItems = [NSMutableArray array];
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    for(NSInteger i=0; i < [_itemArray count]; i++){
        DaysCounterEvent *item = [_itemArray objectAtIndex:i];
        if( [[_checkStatusDict objectForKey:item.uniqueID] boolValue] ) {
            [removeItems addObject:item];
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
    }

    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    for (DaysCounterEvent *event in removeItems) {
        [context deleteObject:event];
    }
    [_itemArray removeObjectsInArray:removeItems];
    removeItems = nil;
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self setFirstActionSheet:nil];
    
    if( buttonIndex == actionSheet.destructiveButtonIndex ){
        if( actionSheet.tag == ActionSheet_DeleteAll ){
            [self deleteAllEventsAction];
        }
        else if( actionSheet.tag == ActionSheet_DeleteSelected ){
            [self deleteSelectedEventsAction];
        }
        
        NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
        [context saveContext];

        if( [self.itemArray count] < 1 ){
            [self cancelAction:nil];
        }
    }
}

#pragma mark ActionSheet Rotation Related
- (void)rotateFirstActionSheet {
    NSInteger currentActionSheetTag = [self.firstActionSheet tag];
    [super rotateFirstActionSheet];
    [self setFirstActionSheet:nil];
    
    [self showActionSheetAdaptivelyInViewWithTag:currentActionSheetTag];
}

- (void)showActionSheetAdaptivelyInViewWithTag:(NSInteger)actionSheetTag {
    switch (actionSheetTag) {
        case ActionSheet_DeleteAll:
            [self showDeleteAllActionSheet];
            break;
            
        case ActionSheet_DeleteSelected:
			[self showDeleteSelectedActionSheet];
            break;
            
        default:
            break;
    }
}

- (void)showDeleteAllActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:NSLocalizedString(@"Delete All", @"Delete All") otherButtonTitles:nil];
    actionSheet.tag = ActionSheet_DeleteAll;
    [actionSheet showInView:self.view];
    [self setFirstActionSheet:actionSheet];
}

- (void)showDeleteSelectedActionSheet {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:NSLocalizedString(@"Delete Events", @"Delete Events") otherButtonTitles:nil];
    actionSheet.tag = ActionSheet_DeleteSelected;
    [actionSheet showInView:self.view];
    [self setFirstActionSheet:actionSheet];
}

#pragma mark - action method
- (void)cancelAction:(id)sender
{
    if ( IS_IPHONE ) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [[[A3AppDelegate instance] rootViewController_iPad] dismissCenterViewController];
        [[[A3AppDelegate instance] rootViewController_iPad].centerNavigationController viewWillAppear:YES];
    }
}

- (void)doneButtonAction:(UIBarButtonItem *)button
{
    [self cancelAction:nil];
}

- (void)deleteAllAction:(id)sender
{
	[self showDeleteAllActionSheet];
}

- (void)toggleSelectAction:(id)sender
{
    UIButton *button = (UIButton*)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCellSubview:button];
    if (indexPath == nil )
        return;
    
    button.selected = !button.selected;
    
    DaysCounterEvent *item = [_itemArray objectAtIndex:indexPath.row];
	[_checkStatusDict setObject:[NSNumber numberWithBool:button.selected] forKey:item.uniqueID];
    if( button.selected )
        [_selectedArray addObject:item];
    else
        [_selectedArray removeObject:item];
}

- (IBAction)removeAction:(id)sender {
    if (![self hasSelectedItem]) {
        return;
    }

	[self showDeleteSelectedActionSheet];
}

-(BOOL)hasSelectedItem
{
    if ( [_selectedArray count] < 1 ) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Please select events.", @"Please select events.")
                                                                                 message:@""
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:NULL];
        }]];
        [self.navigationController presentViewController:alertController animated:YES completion:NULL];
        
        return NO;
    }
    
    return YES;
}

- (IBAction)changeCalendarAction:(id)sender {
    if (![self hasSelectedItem]) {
        return;
    }

    A3DaysCounterEventChangeCalendarViewController *viewCtrl = [[A3DaysCounterEventChangeCalendarViewController alloc] init];
    viewCtrl.currentCalendar = _calendarItem;
    viewCtrl.eventArray = _selectedArray;
    viewCtrl.sharedManager = _sharedManager;
    viewCtrl.doneActionCompletionBlock = ^{
        [_selectedArray removeAllObjects];
    };

    if ( IS_IPHONE ) {
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
        navCtrl.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:navCtrl animated:YES completion:nil];
    }
    else {
        [[[A3AppDelegate instance] rootViewController_iPad] presentRightSideViewController:viewCtrl toViewController:nil];
    }
}

- (IBAction)shareAction:(id)sender {
    if (![self hasSelectedItem]) {
        return;
    }
    
    _activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self] applicationActivities:nil];
	if (IS_IPHONE) {
		[self presentViewController:_activityViewController animated:YES completion:NULL];
	}
    else {
		UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:_activityViewController];
        popoverController.delegate = self;
        self.popoverVC = popoverController;
        [popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    _trashBarButton.enabled = YES;
    _calendarBarButton.enabled = YES;
    _shareBarButton.enabled = YES;
    self.popoverVC = nil;
	[self enableControls:YES];
}

#pragma mark - UIActivityItemSource

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
{
    NSArray *sortedArray = [_selectedArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        DaysCounterEvent *item1 = (DaysCounterEvent *)obj1;
        DaysCounterEvent *item2 = (DaysCounterEvent *)obj2;
        return [item1.effectiveStartDate compare:item2.effectiveStartDate];
    }];
    
    DaysCounterEvent *eventItem = [sortedArray firstObject];
    
	if ([activityType isEqualToString:UIActivityTypeMail]) {
        return [NSString stringWithFormat:NSLocalizedString(@"%@ using AppBox Pro", @"%@ using AppBox Pro"), eventItem.eventName];
	}
    
	return eventItem.eventName;
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
	return NSLocalizedString(@"Share Days Counter Data", @"Share Days Counter Data");
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
	if ([activityType isEqualToString:UIActivityTypeMail]) {
		NSMutableString *txt = [NSMutableString new];

        for (DaysCounterEvent *event in _selectedArray) {
            // 7 days until (계산된 날짜)
            NSString *eventName = event.eventName;
            NSString *daysString = [A3DaysCounterModelManager stringOfDurationOption:[event.durationOption integerValue]
                                                                            fromDate:[NSDate date]
                                                                              toDate:event.effectiveStartDate
                                                                            isAllDay:[event.isAllDay boolValue]
                                                                        isShortStyle:IS_IPHONE ? YES : NO
                                                                   isStrictShortType:NO];
            NSString *untilSinceString = [A3DateHelper untilSinceStringByFromDate:[NSDate date]
                                                                           toDate:event.effectiveStartDate
                                                                     allDayOption:[event.isAllDay boolValue]
                                                                           repeat:[event.repeatType integerValue] != RepeatType_Never ? YES : NO
                                                                           strict:NO];
            [txt appendFormat:@"%@<br/>", eventName];
            [txt appendFormat:@"%@ %@<br/>", daysString, untilSinceString];
            
            //         Friday, April 11, 2014 (사용자가 입력한 날)
            NSDateFormatter *formatter = [NSDateFormatter new];
            [formatter setDateStyle:NSDateFormatterFullStyle];
            if (![event.isAllDay boolValue]) {
                [formatter setTimeStyle:NSDateFormatterShortStyle];
            }
            [txt appendFormat:@"%@<br/><br/>", [A3DateHelper dateStringFromDate:[event effectiveStartDate]
                                                                     withFormat:[formatter dateFormat]]];
        }
		return [self shareMailMessageWithHeader:NSLocalizedString(@"I'd like to share an event with you.", @"I'd like to share an event with you.")
									   contents:txt
										   tail:NSLocalizedString(@"You can manage your events in the AppBox Pro.", @"You can manage your events in the AppBox Pro.")];
	}
	else {
		NSMutableString *txt = [NSMutableString new];
        
        for (DaysCounterEvent *event in _selectedArray) {
            // 7 days until (계산된 날짜)
            NSString *daysString = [A3DaysCounterModelManager stringOfDurationOption:[event.durationOption integerValue]
                                                                            fromDate:[NSDate date]
                                                                              toDate:event.effectiveStartDate
                                                                            isAllDay:[event.isAllDay boolValue]
                                                                        isShortStyle:IS_IPHONE ? YES : NO
                                                                   isStrictShortType:NO];
            NSString *untilSinceString = [A3DateHelper untilSinceStringByFromDate:[NSDate date]
                                                                           toDate:event.effectiveStartDate
                                                                     allDayOption:[event.isAllDay boolValue]
                                                                           repeat:[event.repeatType integerValue] != RepeatType_Never ? YES : NO
                                                                           strict:YES];
            [txt appendFormat:@"%@\n", event.eventName];
            [txt appendFormat:@"%@ %@\n", daysString, untilSinceString];
            
            //         Friday, April 11, 2014 (사용자가 입력한 날)
            NSDateFormatter *formatter = [NSDateFormatter new];
            if ([NSDate isFullStyleLocale]) {
                [formatter setDateStyle:NSDateFormatterFullStyle];
                if (![event.isAllDay boolValue]) {
                    [formatter setTimeStyle:NSDateFormatterShortStyle];
                }
            }
            else {
                if ([event.isAllDay boolValue]) {
                    [formatter setDateFormat:[formatter customFullStyleFormat]];
                }
                else {
                    [formatter setDateFormat:[formatter customFullWithTimeStyleFormat]];
                }
            }
            
            [txt appendFormat:@"%@\n\n", [A3DateHelper dateStringFromDate:[event effectiveStartDate]
                                                             withFormat:[formatter dateFormat]] ];
        }

        
		return txt;
	}
}

@end
