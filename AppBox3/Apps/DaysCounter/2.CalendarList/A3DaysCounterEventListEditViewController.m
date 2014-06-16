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
#import "DaysCounterCalendar.h"
#import "DaysCounterEvent.h"
#import "A3DaysCounterEventChangeCalendarViewController.h"
#import "A3AppDelegate+appearance.h"
#import "UIImage+JHExtension.h"
#import "A3DateHelper.h"
#import "DaysCounterEvent.h"
#import "DaysCounterDate.h"
#import "UIImage+imageWithColor.h"
#import "NSDate+formatting.h"
#import "NSDateFormatter+A3Addition.h"

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

- (void)cancelAction:(id)sender;
- (void)deleteAllAction:(id)sender;
- (void)toggleSelectAction:(id)sender;
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

    self.title = _calendarItem.calendarName;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadTableView
{
    if( [_calendarItem.calendarType integerValue] == CalendarCellType_User )
        self.itemArray = [NSMutableArray arrayWithArray:[_calendarItem.events array]];
    else{
        NSArray *sourceArray = nil;
        if( [_calendarItem.calendarId isEqualToString:SystemCalendarID_All] )
            sourceArray = [_sharedManager allEventsList];
        else if( [_calendarItem.calendarId isEqualToString:SystemCalendarID_Past] )
            sourceArray = [_sharedManager pastEventsListWithDate:[NSDate date]];
        else if( [_calendarItem.calendarId isEqualToString:SystemCalendarID_Upcoming] )
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
        button.tintColor = [A3AppDelegate instance].themeColor;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [button setImage:[self.checkNormalImage tintedImageWithColor:[A3AppDelegate instance].themeColor] forState:UIControlStateNormal];
        [button setImage:[[UIImage imageNamed:@"check"] tintedImageWithColor:[A3AppDelegate instance].themeColor] forState:UIControlStateSelected];
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
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if( buttonIndex == actionSheet.destructiveButtonIndex ){
        if( actionSheet.tag == ActionSheet_DeleteAll ){
            for(DaysCounterEvent *event in _itemArray){
                [event MR_deleteEntity];
            }
            _calendarItem.events = nil;
            [_checkStatusDict removeAllObjects];
            [_itemArray removeAllObjects];
            [self.tableView reloadData];
        }
        else if( actionSheet.tag == ActionSheet_DeleteSelected ){
            NSMutableArray *removeItems = [NSMutableArray array];
            NSMutableArray *indexPaths = [NSMutableArray array];
            
            for(NSInteger i=0; i < [_itemArray count]; i++){
                DaysCounterEvent *item = [_itemArray objectAtIndex:i];
                if( [[_checkStatusDict objectForKey:item.uniqueID] boolValue] ){
                    [removeItems addObject:item];
                    [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                }
            }
            
            for(DaysCounterEvent *event in removeItems){
                [event MR_deleteEntity];
            }
            [_itemArray removeObjectsInArray:removeItems];
            removeItems = nil;
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        if( [self.itemArray count] < 1 ){
            [self cancelAction:nil];
        }
        
        [[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    }
}

#pragma mark - action method
- (void)cancelAction:(id)sender
{
    if ( IS_IPHONE ) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.A3RootViewController dismissCenterViewController];
        [self.A3RootViewController.centerNavigationController viewWillAppear:YES];
    }
}

- (void)doneButtonAction:(UIBarButtonItem *)button
{
    [self cancelAction:nil];
}

- (void)deleteAllAction:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:NSLocalizedString(@"Delete All", @"Delete All") otherButtonTitles:nil];
    actionSheet.tag = ActionSheet_DeleteAll;
    [actionSheet showInView:self.view];
}

- (void)toggleSelectAction:(id)sender
{
    UIButton *button = (UIButton*)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[[button superview] superview] superview]];
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
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:NSLocalizedString(@"Delete Events", @"Delete Events") otherButtonTitles:nil];
    actionSheet.tag = ActionSheet_DeleteSelected;
    [actionSheet showInView:self.view];
}

- (IBAction)changeCalendarAction:(id)sender {
    if( [_selectedArray count] < 1 ){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Please select events.", @"Please select events.") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
        [alertView show];
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
        navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:navCtrl animated:YES completion:nil];
    }
    else {
        [self.A3RootViewController presentRightSideViewController:viewCtrl];
    }
}

- (IBAction)shareAction:(id)sender {
    if( [_selectedArray count] < 1 ){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Please select events.", @"Please select events.") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[self] applicationActivities:nil];
	if (IS_IPHONE) {
		[self presentViewController:activityController animated:YES completion:NULL];
	}
    else {
		UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:activityController];
        popoverController.delegate = self;
        self.popoverVC = popoverController;
        [popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        activityController.completionHandler = ^(NSString* activityType, BOOL completed) {
        };
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
		[txt appendString:NSLocalizedString(@"<html><body>I'd like to share a days count with you.<br/><br/>", @"<html><body>I'd like to share a days count with you.<br/><br/>")];

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


		[txt appendString:NSLocalizedString(@"daysCounter_share_HTML_body", nil)];
        
		return txt;
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
