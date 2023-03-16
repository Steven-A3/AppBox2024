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
#import "A3SyncManager.h"
#import "DaysCounterCalendar.h"
#import "NSMutableArray+A3Sort.h"
#import "UITableView+utility.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"

@interface A3DaysCounterEditCalendarListViewController ()
@property (strong, nonatomic) NSMutableArray *calendarArray;
@property (strong, nonatomic) UINavigationController *modalVC;

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
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCalendarAction:)];

    [self rightBarButtonDoneButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.modalVC = nil;

	NSArray *calendars = [DaysCounterCalendar findAllSortedBy:A3CommonPropertyOrder ascending:YES];
	self.calendarArray = [NSMutableArray arrayWithArray:calendars];
    
    [self.tableView reloadData];
    [self.tableView setEditing:YES];
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
    DaysCounterCalendar *calendar = [_calendarArray objectAtIndex:indexPath.row];
    NSInteger cellType = [calendar.type integerValue];

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

    imageView.tintColor = [_sharedManager colorForCalendar:calendar];
    textLabel.text = calendar.name;
    checkButton.selected = [calendar.isShow boolValue];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"calendarID == %@", calendar.uniqueID];
	long eventCounts = [DaysCounterEvent countOfEntitiesWithPredicate:predicate];
    detailTextLabel.text = [NSString stringWithFormat:@"%ld", eventCounts];
    
    textLabel.font = [UIFont systemFontOfSize:17];
    
    if ( [calendar.type integerValue] == CalendarCellType_System ) {
        NSInteger numberOfEvents = 0;
        if ( [calendar.uniqueID isEqualToString:SystemCalendarID_All] ) {
            numberOfEvents = [_sharedManager numberOfAllEventsToIncludeHiddenCalendar];
			textLabel.text = NSLocalizedString(@"DaysCounter_ALL", nil);
		}
        else if ( [calendar.uniqueID isEqualToString:SystemCalendarID_Upcoming]) {
            numberOfEvents = [_sharedManager numberOfUpcomingEventsWithDate:[NSDate date] withHiddenCalendar:YES];
			textLabel.text = NSLocalizedString(@"List_Upcoming", nil);
		}
        else if ( [calendar.uniqueID isEqualToString:SystemCalendarID_Past] ) {
            numberOfEvents = [_sharedManager numberOfPastEventsWithDate:[NSDate date] withHiddenCalendar:YES];
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
	[_calendarArray moveItemInSortedArrayFromIndex:fromIndexPath.row toIndex:toIndexPath.row];
    NSManagedObjectContext *context = [[A3AppDelegate instance] managedObjectContext];
    [context saveContext];

    [tableView reloadData];

}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    //return IS_RETINA ? 35.5 : 36;
    return 38;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DaysCounterCalendar *calendar = [_calendarArray objectAtIndex:indexPath.row];
    BOOL checkState = [calendar.isShow boolValue];
    calendar.isShow = @(!checkState);

    NSManagedObjectContext *context = [[A3AppDelegate instance] managedObjectContext];
    [context saveContext];

    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}
 
#pragma mark - action method

- (void)doneButtonAction:(UIBarButtonItem *)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)checkAction:(id)sender
{
    UIButton *button = (UIButton*)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCellSubview:button];
    if ( indexPath == nil )
        return;
    
    NSArray *shownUserCalendar = [_calendarArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isShow == %@ AND type == %@", @(YES), @(CalendarCellType_User)]];
    DaysCounterCalendar *calendar = [_calendarArray objectAtIndex:indexPath.row];
    BOOL checkState = [calendar.isShow boolValue];
    if (checkState && [shownUserCalendar count] <= 1 && [calendar.type isEqualToNumber:@(CalendarCellType_User)]) {
        return;
    }
    
    calendar.isShow = @(!checkState);
    NSManagedObjectContext *context = [[A3AppDelegate instance] managedObjectContext];
    [context saveContext];
    if (checkState && ([shownUserCalendar count] == 2)) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)addCalendarAction:(id)sender
{
    A3DaysCounterAddAndEditCalendarViewController *viewCtrl = [[A3DaysCounterAddAndEditCalendarViewController alloc] init];
    viewCtrl.isEditMode = NO;
    viewCtrl.sharedManager = _sharedManager;
    
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
    navCtrl.modalPresentationStyle = UIModalPresentationFullScreen;

    // 왼쪽 바운드 라인이 사라지는 버그 수정을 위하여 추가.
    UIView *leftLineView = [[UIView alloc] initWithFrame:CGRectMake(-(IS_RETINA ? 0.5 : 1), 0, (IS_RETINA ? 0.5 : 1), CGRectGetHeight(navCtrl.view.frame))];
    leftLineView.backgroundColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0];
    [navCtrl.view addSubview:leftLineView];

    self.modalVC = navCtrl;
    [self presentViewController:navCtrl animated:YES completion:nil];

	if (IS_IPAD) {
		[A3AppDelegate instance].rootViewController_iPad.modalPresentedInRightNavigationViewController = navCtrl;
	}
}

- (void)editCalendarAction:(id)sender
{
    UIButton *button = (UIButton*)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCellSubview:button];
    if ( indexPath == nil )
        return;

	DaysCounterCalendar *calendar = _calendarArray[indexPath.row];
    if ( [calendar.type integerValue] == CalendarCellType_System )
        return;
    
    A3DaysCounterAddAndEditCalendarViewController *viewCtrl = [[A3DaysCounterAddAndEditCalendarViewController alloc] init];
    viewCtrl.isEditMode = YES;
    viewCtrl.calendar = calendar;
    viewCtrl.sharedManager = _sharedManager;
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
    navCtrl.modalPresentationStyle = UIModalPresentationFullScreen;
    self.modalVC = navCtrl;
    
    // 왼쪽 바운드 라인이 사라지는 버그 수정을 위하여 추가.
    UIView *leftLineView = [[UIView alloc] initWithFrame:CGRectMake(-(IS_RETINA ? 0.5 : 1), 0, (IS_RETINA ? 0.5 : 1), CGRectGetHeight(navCtrl.view.frame))];
    leftLineView.backgroundColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0];
    [navCtrl.view addSubview:leftLineView];
    
    [self presentViewController:navCtrl animated:YES completion:nil];
}

@end
