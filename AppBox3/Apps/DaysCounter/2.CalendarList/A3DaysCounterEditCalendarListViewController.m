//
//  A3DaysCounterEditCalendarListViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 10. 30..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterEditCalendarListViewController.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3DaysCounterAddAndEditCalendarViewController.h"
#import "UIImage+imageWithColor.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "DaysCounterEvent.h"

@interface A3DaysCounterEditCalendarListViewController ()
@property (strong, nonatomic) NSMutableArray *calendarArray;
@property (strong, nonatomic) UINavigationController *modalVC;

- (void)checkAction:(id)sender;
@end

@implementation A3DaysCounterEditCalendarListViewController

- (id)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {

	}

	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Edit Calendars", @"Edit Calendars");

	self.tableView.showsVerticalScrollIndicator = NO;
	self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.separatorInset = A3UITableViewSeparatorInset;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCalendarAction:)];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    if (IS_IPHONE) {
        [self rightBarButtonDoneButton];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.modalVC = nil;

	self.calendarArray = [_sharedManager calendars];
    
    [self.tableView reloadData];
    [self.tableView setEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_calendarArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"calendarEditCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterCalendarListMainEditCell" owner:nil options:nil] lastObject];
        UIButton *checkButton = (UIButton*)[cell viewWithTag:10];
        UIImage *image = [[UIImage imageNamed:@"check_02"] tintedImageWithColor:[[A3AppDelegate instance] themeColor]];
		[checkButton setImage:image forState:UIControlStateSelected];
        [checkButton setImage:nil forState:UIControlStateNormal];
        [checkButton addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *imageView = (UIImageView*)[cell viewWithTag:11];
        imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIButton *addEditCalendarButton = (UIButton*)[cell viewWithTag:14];
        [addEditCalendarButton addTarget:self action:@selector(editCalendarAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIButton *checkButton = (UIButton*)[cell viewWithTag:10];
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:11];
    UILabel *textLabel = (UILabel*)[cell viewWithTag:12];
    UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:13];
    NSDictionary *item = [_calendarArray objectAtIndex:indexPath.row];
    NSInteger cellType = [item[CalendarItem_Type] integerValue];
    
    if ( cellType == CalendarCellType_System ) {
        imageView.hidden = YES;
        cell.editingAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        cell.editingAccessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        imageView.hidden = NO;
        cell.editingAccessoryView = nil;
        cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }

    imageView.tintColor = [_sharedManager colorForCalendar:item];
    textLabel.text = item[CalendarItem_Name];
    checkButton.selected = [item[CalendarItem_IsShow] boolValue];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"calendarID == %@", item[CalendarItem_ID]];
	long eventCounts = [DaysCounterEvent MR_countOfEntitiesWithPredicate:predicate];
    detailTextLabel.text = [NSString stringWithFormat:@"%ld", eventCounts];
    
    textLabel.font = [UIFont systemFontOfSize:17];
    
    if ( [item[CalendarItem_Type] integerValue] == CalendarCellType_System ) {
        NSInteger numberOfEvents = 0;
        if ( [item[CalendarItem_ID] isEqualToString:SystemCalendarID_All] ) {
            numberOfEvents = [_sharedManager numberOfAllEvents];
			textLabel.text = NSLocalizedString(@"DaysCounter_ALL", nil);
		}
        else if ( [item[CalendarItem_ID] isEqualToString:SystemCalendarID_Upcoming]) {
            numberOfEvents = [_sharedManager numberOfUpcomingEventsWithDate:[NSDate date]];
			textLabel.text = NSLocalizedString(@"List_Upcoming", nil);
		}
        else if ( [item[CalendarItem_ID] isEqualToString:SystemCalendarID_Past] ) {
            numberOfEvents = [_sharedManager numberOfPastEventsWithDate:[NSDate date]];
			textLabel.text = NSLocalizedString(@"List_Past", nil);
		}
        detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)numberOfEvents];
    }
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSDictionary *item = [_calendarArray objectAtIndex:fromIndexPath.row];
    [_calendarArray removeObjectAtIndex:fromIndexPath.row];
    [_calendarArray insertObject:item atIndex:toIndexPath.row];

    [tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    //return IS_RETINA ? 35.5 : 36;
    return 38;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *item = [[_calendarArray objectAtIndex:indexPath.row] mutableCopy];
    BOOL checkState = [item[CalendarItem_IsShow] boolValue];
    item[CalendarItem_IsShow] = @(!checkState);
    [_calendarArray replaceObjectAtIndex:indexPath.row withObject:item];

    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}
 
#pragma mark - action method

- (void)doneButtonAction:(UIBarButtonItem *)button
{
	if (![_calendarArray isEqualToArray:[_sharedManager calendars]]) {
		[_sharedManager saveCalendars:_calendarArray];
	}

    if ( IS_IPHONE ) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        if ( self.modalVC ) {
            [self.modalVC dismissViewControllerAnimated:NO completion:^{
                [self.A3RootViewController dismissRightSideViewController];
                UINavigationController *navCtrl = self.A3RootViewController.centerNavigationController;
                UIViewController *viewCtrl = navCtrl.topViewController;
                [viewCtrl viewWillAppear:YES];
            }];
        }
        else {
            [self.A3RootViewController dismissRightSideViewController];
            UINavigationController *navCtrl = self.A3RootViewController.centerNavigationController;
            UIViewController *viewCtrl = navCtrl.topViewController;
            [viewCtrl viewWillAppear:YES];
       }
    }
}

- (void)checkAction:(id)sender
{
    UIButton *button = (UIButton*)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[[button superview] superview] superview]];
    if ( indexPath == nil )
        return;
    
    NSMutableDictionary *item = [_calendarArray objectAtIndex:indexPath.row];
    BOOL checkState = [item[CalendarItem_IsShow] boolValue];
    item[CalendarItem_IsShow] = @(!checkState);
    [_calendarArray replaceObjectAtIndex:indexPath.row withObject:item];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)addCalendarAction:(id)sender
{
    A3DaysCounterAddAndEditCalendarViewController *viewCtrl = [[A3DaysCounterAddAndEditCalendarViewController alloc] init];
    viewCtrl.isEditMode = NO;
    viewCtrl.calendarItem = nil;
    viewCtrl.sharedManager = _sharedManager;
    
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
    navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;

    // 왼쪽 바운드 라인이 사라지는 버그 수정을 위하여 추가.
    UIView *leftLineView = [[UIView alloc] initWithFrame:CGRectMake(-(IS_RETINA ? 0.5 : 1), 0, (IS_RETINA ? 0.5 : 1), CGRectGetHeight(navCtrl.view.frame))];
    leftLineView.backgroundColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0];
    [navCtrl.view addSubview:leftLineView];

    self.modalVC = navCtrl;
    [self presentViewController:navCtrl animated:YES completion:nil];

	if (IS_IPAD) {
		[A3AppDelegate instance].rootViewController.modalPresentedInRightNavigationViewController = navCtrl;
	}
}

- (void)editCalendarAction:(id)sender
{
    UIButton *button = (UIButton*)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[[button superview] superview] superview]];
    if ( indexPath == nil )
        return;

    NSDictionary *item = [_calendarArray objectAtIndex:indexPath.row];
    if ( [item[CalendarItem_Type] integerValue] == CalendarCellType_System )
        return;
    
    A3DaysCounterAddAndEditCalendarViewController *viewCtrl = [[A3DaysCounterAddAndEditCalendarViewController alloc] init];
    viewCtrl.isEditMode = YES;
    viewCtrl.calendarItem = [item mutableCopy];
    viewCtrl.sharedManager = _sharedManager;
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
    navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.modalVC = navCtrl;
    
    // 왼쪽 바운드 라인이 사라지는 버그 수정을 위하여 추가.
    UIView *leftLineView = [[UIView alloc] initWithFrame:CGRectMake(-(IS_RETINA ? 0.5 : 1), 0, (IS_RETINA ? 0.5 : 1), CGRectGetHeight(navCtrl.view.frame))];
    leftLineView.backgroundColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0];
    [navCtrl.view addSubview:leftLineView];
    
    [self presentViewController:navCtrl animated:YES completion:nil];

	if (IS_IPAD) {
		[A3AppDelegate instance].rootViewController.modalPresentedInRightNavigationViewController = navCtrl;
	}
}

@end
