//
//  A3DaysCounterReminderListViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterReminderListViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "A3DaysCounterSlidershowMainViewController.h"
#import "A3DaysCounterAddEventViewController.h"
#import "A3DaysCounterCalendarListMainViewController.h"
#import "A3DaysCounterReminderListViewController.h"
#import "A3DaysCounterFavoriteListViewController.h"
#import "A3DaysCounterEventDetailViewController.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "DaysCounterCalendar.h"
#import "DaysCounterEvent.h"
#import "DaysCounterReminder.h"
#import "A3DateHelper.h"
#import "NSDate+TimeAgo.h"
#import "A3AppDelegate+appearance.h"

@interface A3DaysCounterReminderListViewController ()
@property (strong, nonatomic) NSMutableArray *itemArray;
@property (strong, nonatomic) NSIndexPath *clearIndexPath;

- (void)clearAction:(id)sender;
- (void)changeClearAction:(id)sender;
@end

@implementation A3DaysCounterReminderListViewController

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

    self.title = @"Reminder";
    self.toolbarItems = _bottomToolbar.items;
    [self.navigationController setToolbarHidden:NO];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, IS_IPHONE ? 30 : 56, 0, 0);

	[self leftBarButtonAppsButton];
    [self makeBackButtonEmptyArrow];
    
    [[A3DaysCounterModelManager sharedManager] reloadAlertDateListForLocalNotification];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.delegate = nil;
    [self registerContentSizeCategoryDidChangeNotification];
    self.itemArray = [NSMutableArray arrayWithArray:[[A3DaysCounterModelManager sharedManager] reminderList]];
    [self.tableView reloadData];
    [self.navigationController setToolbarHidden:NO];
    
    [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"DaysCounterLastOpenedMainIndex"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.itemArray = nil;
}

- (void)contentSizeDidChange:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if ( IS_IPAD ) {
        if ( UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            [self leftBarButtonAppsButton];
        }
        else {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
        }
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

#define UNREADVIEW_TAG  111

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const CellIdentifier = @"reminderCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:IS_IPHONE ? UITableViewCellStyleSubtitle : UITableViewCellStyleValue1
                                      reuseIdentifier:CellIdentifier];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
        UIView *unReadMark = [[UIView alloc] initWithFrame:CGRectZero];
        unReadMark.tag = UNREADVIEW_TAG;
        unReadMark.backgroundColor = [A3AppDelegate instance].themeColor; // [UIColor colorWithRed:0 green:126.0/255 blue:248.0/255 alpha:1.0];
        unReadMark.layer.cornerRadius = 5;
        [cell addSubview:unReadMark];
        
        [unReadMark makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(cell.contentView.left).with.offset(IS_IPAD ? 23 : 10);
            make.centerY.equalTo(cell.textLabel.centerY);
            make.width.equalTo(@10);
            make.height.equalTo(@10);
        }];
    }
    
    cell.textLabel.font = IS_IPHONE ? [UIFont systemFontOfSize:15.0] : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    cell.detailTextLabel.font = IS_IPHONE ? [UIFont systemFontOfSize:12.0] : [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    
    UIView *unreadMarkView = [cell viewWithTag:UNREADVIEW_TAG];
    
    if ( [_itemArray count] > 0 ) {
        DaysCounterReminder *reminder = [_itemArray objectAtIndex:indexPath.row];
        DaysCounterEvent *item = reminder.event;
        cell.textLabel.text = item.eventName;
        
        NSString *untilSinceString = [A3DateHelper untilSinceStringByFromDate:[NSDate date]
                                                                       toDate:item.effectiveStartDate
                                                                 allDayOption:[item.isAllDay boolValue]
                                                                       repeat:[item.repeatType integerValue] != RepeatType_Never ? YES : NO];
        if ([untilSinceString isEqualToString:@"today"] || [untilSinceString isEqualToString:@"Now"]) {
            cell.detailTextLabel.text = [A3DateHelper dateStringFromDate:reminder.startDate
                                                              withFormat:[[A3DaysCounterModelManager sharedManager] dateFormatForAddEditIsAllDays:[item.isAllDay boolValue]]];
        }
        else {
            if ([[NSDate date] compare:reminder.startDate] == NSOrderedDescending) {
                cell.detailTextLabel.text = [reminder.startDate timeAgo];
            }
            else {
                // Reminder 의 startDate == EffectiveStartDate 이다.
                // 양력/음력 모두 얄력기준 실제 이벤트 날짜가 startDate 로 정해진다.
                cell.detailTextLabel.text = [A3DateHelper dateStringFromDate:reminder.startDate
                                                                  withFormat:[[A3DaysCounterModelManager sharedManager] dateFormatForAddEditIsAllDays:[item.isAllDay boolValue]]];
            }
        }
        unreadMarkView.hidden = [reminder.isUnread boolValue] ? NO : YES;
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    else {
        unreadMarkView.hidden = YES;
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return cell;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [_itemArray count] < 1 ) {
        return;
    }
    
    DaysCounterReminder *reminder = [_itemArray objectAtIndex:indexPath.row];
    reminder.isUnread = @(NO);
    if ([reminder.startDate timeIntervalSince1970] < [[NSDate date] timeIntervalSince1970]) {
        reminder.isOn = @(NO);
    }
    
    DaysCounterEvent *item = reminder.event;
    // 미반복의 경우 더이상 Reminder에 올라오지 않도록 함.
    if (item.repeatType && [item.repeatType isEqualToNumber:@(RepeatType_Never)] &&
        [reminder.startDate timeIntervalSince1970] < [[NSDate date] timeIntervalSince1970]) {
            item.hasReminder = @(NO);
    }
    [[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    
    self.itemArray = [NSMutableArray arrayWithArray:[[A3DaysCounterModelManager sharedManager] reminderList]];

    A3DaysCounterEventDetailViewController *viewCtrl = [[A3DaysCounterEventDetailViewController alloc] initWithNibName:@"A3DaysCounterEventDetailViewController" bundle:nil];
    viewCtrl.eventItem = item;
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

#pragma mark - action method
- (IBAction)photoViewAction:(id)sender {
    A3DaysCounterSlidershowMainViewController *viewCtrl = [[A3DaysCounterSlidershowMainViewController alloc] initWithNibName:@"A3DaysCounterSlidershowMainViewController"
                                                                                                                      bundle:nil];
    [self popToRootAndPushViewController:viewCtrl animate:NO];
}

- (IBAction)calendarViewAction:(id)sender {
    A3DaysCounterCalendarListMainViewController *viewCtrl = [[A3DaysCounterCalendarListMainViewController alloc] initWithNibName:@"A3DaysCounterCalendarListMainViewController"
                                                                                                                          bundle:nil];
    [self popToRootAndPushViewController:viewCtrl animate:NO];
}

- (IBAction)addEventAction:(id)sender {
    A3DaysCounterAddEventViewController *viewCtrl = [[A3DaysCounterAddEventViewController alloc] initWithNibName:@"A3DaysCounterAddEventViewController"
                                                                                                          bundle:nil];
    if ( IS_IPHONE ) {
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
        navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:navCtrl animated:YES completion:nil];
    }
    else {
        [self.navigationController pushViewController:viewCtrl animated:YES];
    }
}

- (IBAction)favoriteAction:(id)sender {
    A3DaysCounterFavoriteListViewController *viewCtrl = [[A3DaysCounterFavoriteListViewController alloc] initWithNibName:@"A3DaysCounterFavoriteListViewController" bundle:nil];
    [self popToRootAndPushViewController:viewCtrl animate:NO];
}

- (void)clearAction:(id)sender
{
    UIButton *button = (UIButton*)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[[button superview] superview] superview]];
    if ( indexPath == nil ) {
        return;
    }
    
    DaysCounterReminder *reminder = [_itemArray objectAtIndex:indexPath.row];
    DaysCounterEvent *item = reminder.event;
    
    item.alertDatetime = nil;
    [item.managedObjectContext MR_saveToPersistentStoreAndWait];
    self.clearIndexPath = nil;
    [_itemArray removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)changeClearAction:(id)sender
{
    UIButton *button = (UIButton*)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[[button superview] superview] superview]];
    if ( indexPath == nil ) {
        return;
    }
    
    NSIndexPath *prevIndexPath = (_clearIndexPath ? [NSIndexPath indexPathForRow:_clearIndexPath.row inSection:_clearIndexPath.section] : nil);
    self.clearIndexPath = indexPath;
    [self.tableView beginUpdates];
    if ( prevIndexPath && (prevIndexPath.row != indexPath.row) ) {
        [self.tableView reloadRowsAtIndexPaths:@[prevIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

@end
