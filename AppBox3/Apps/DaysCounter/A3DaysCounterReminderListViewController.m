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
#import "A3DateHelper.h"
#import "NSDate+TimeAgo.h"

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
    //self.tableView.separatorInset = UIEdgeInsetsMake(0, IS_IPHONE ? 15 : 28, 0, 0);
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 30, 0, 0);

	[self leftBarButtonAppsButton];
    [self makeBackButtonEmptyArrow];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.delegate = nil;
    [self registerContentSizeCategoryDidChangeNotification];
    self.itemArray = [NSMutableArray arrayWithArray:[[A3DaysCounterModelManager sharedManager] reminderList]];
    [self.tableView reloadData];
    [self.navigationController setToolbarHidden:NO];
    
    if ( IS_IPAD ) {
        if ( UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            [self leftBarButtonAppsButton];
        }
        else {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
        }
    }
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
    //return ([_itemArray count] < 1) ? ceilf((tableView.frame.size.height / 62.0)) : [_itemArray count];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 0.01;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 0.01;
//}

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
        unReadMark.backgroundColor = [UIColor colorWithRed:0 green:126.0/255 blue:248.0/255 alpha:1.0];
        unReadMark.layer.cornerRadius = 5;
        //[cell.contentView addSubview:unReadMark];
        [cell addSubview:unReadMark];
        [unReadMark makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(cell.contentView.left).with.offset(8);
            //make.top.equalTo(cell.contentView.top).with.offset(10);
            make.centerY.equalTo(cell.textLabel.centerY);
            make.width.equalTo(@10);
            make.height.equalTo(@10);
        }];
    }
    
    cell.textLabel.font = IS_IPHONE ? [UIFont systemFontOfSize:15.0] : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    cell.detailTextLabel.font = IS_IPHONE ? [UIFont systemFontOfSize:12.0] : [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    
    UIView *unreadMarkView = [cell viewWithTag:UNREADVIEW_TAG];
    
    if ( [_itemArray count] > 0 ) {
        DaysCounterEvent *item = [_itemArray objectAtIndex:indexPath.row];
        cell.textLabel.text = item.eventName;
        
        if ([[NSDate date] compare:item.alertDatetime] == NSOrderedDescending) {
            cell.detailTextLabel.text = [item.alertDatetime timeAgo];
            unreadMarkView.hidden = NO;
        }
        else {
            cell.detailTextLabel.text = [A3DateHelper dateStringFromDate:item.alertDatetime
                                                              withFormat:IS_IPHONE ? @"EEEE, MMM dd, yyyy hh:mm a" : @"EEEE, MMMM dd, yyyy hh:mm a"];
            unreadMarkView.hidden = YES;
        }
        
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
    
//    static NSString *CellIdentifier = @"reminderCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        NSArray *cellArray = [[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterEventListCell" owner:nil options:nil];
//        cell = [cellArray objectAtIndex:4];
//        UIButton *deleteButton = (UIButton*)[cell viewWithTag:12];
//        UIButton *clearButton = (UIButton*)[cell viewWithTag:13];
//        [deleteButton setImage:[[deleteButton imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
//        deleteButton.tintColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0];
//        [deleteButton addTarget:self action:@selector(changeClearAction:) forControlEvents:UIControlEventTouchUpInside];
//        
//        clearButton.layer.masksToBounds = YES;
//        clearButton.layer.borderWidth = 1.0;
//        clearButton.layer.borderColor = [[clearButton titleColorForState:UIControlStateNormal] CGColor];
//        clearButton.layer.cornerRadius = 9.0;
//        [clearButton addTarget:self action:@selector(clearAction:) forControlEvents:UIControlEventTouchUpInside];
//    
//
//        UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:11];
//        detailTextLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
//    }
//    
//    UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
//    UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:11];
//    UIButton *deleteButton = (UIButton*)[cell viewWithTag:12];
//    UIButton *clearButton = (UIButton*)[cell viewWithTag:13];
//    
//    textLabel.font = IS_IPHONE ? [UIFont systemFontOfSize:15.0] : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
//    detailTextLabel.font = IS_IPHONE ? [UIFont systemFontOfSize:12.0] : [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
//    
//    
//    if ( [_itemArray count] > 0 ) {
//        DaysCounterEvent *item = [_itemArray objectAtIndex:indexPath.row];
//        textLabel.text = item.eventName;
//        
//        if ([[NSDate date] compare:item.alertDatetime] == NSOrderedDescending) {
//            detailTextLabel.text = [item.alertDatetime timeAgo];
//        }
//        else {
//            detailTextLabel.text = [A3DateHelper dateStringFromDate:item.alertDatetime
//                                                         withFormat:IS_IPHONE ? @"EEEE, MMM dd, yyyy hh:mm a" : @"EEEE, MMMM dd, yyyy hh:mm a"];
//        }
//        
//        deleteButton.hidden = (_clearIndexPath && (_clearIndexPath.row == indexPath.row));
//        clearButton.hidden = !deleteButton.hidden;
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
//    }
//    else {
//        textLabel.text = @"";
//        detailTextLabel.text = @"";
//        deleteButton.hidden = YES;
//        clearButton.hidden = YES;
//        cell.accessoryType = UITableViewCellAccessoryNone;
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    }
//
//    return cell;
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
    DaysCounterEvent *item = [_itemArray objectAtIndex:indexPath.row];
    item.alertDatetime = nil;
	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];

    A3DaysCounterEventDetailViewController *viewCtrl = [[A3DaysCounterEventDetailViewController alloc] initWithNibName:@"A3DaysCounterEventDetailViewController" bundle:nil];
    viewCtrl.eventItem = item;
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

#pragma mark - action method
- (IBAction)photoViewAction:(id)sender {
//    if ( [[A3DaysCounterModelManager sharedManager] numberOfEventContainedImage] < 1 ) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:AlertMessage_NoPhoto delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [alertView show];
//        return;
//    }
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
    
    DaysCounterEvent *item = [_itemArray objectAtIndex:indexPath.row];
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
