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
#import "UIViewController+A3AppCategory.h"
#import "SFKImage.h"
#import "A3DaysCounterAddAndEditCalendarViewController.h"
#import "DaysCounterCalendar.h"
#import "A3AppDelegate+appearance.h"

@interface A3DaysCounterEditCalendarListViewController ()
@property (strong, nonatomic) NSMutableArray *itemArray;
@property (strong, nonatomic) UINavigationController *modalVC;

- (void)checkAction:(id)sender;
- (void)reorderingItems;
@end

@implementation A3DaysCounterEditCalendarListViewController

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
    self.title = @"Edit Calendars";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCalendarAction:)];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    [self rightBarButtonDoneButton];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.modalVC = nil;
    NSMutableArray *array = [[A3DaysCounterModelManager sharedManager] allCalendarList];
    if ( self.itemArray == nil ) {
        self.itemArray = array;
    }
    else {
        if ( [self.itemArray count] != [array count] ) {
            self.itemArray = array;
            [self reorderingItems];
        }
    }
    
    [self.tableView reloadData];
    [self.tableView setEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)reorderingItems
{
    for (NSInteger i=0; i < [_itemArray count]; i++) {
        DaysCounterCalendar *item = [_itemArray objectAtIndex:i];
        item.order = [NSNumber numberWithInteger:i+1];
    }
    [[[A3DaysCounterModelManager sharedManager] managedObjectContext] MR_saveToPersistentStoreAndWait];
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
    static NSString *CellIdentifier = @"calendarEditCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterCalendarListMainEditCell" owner:nil options:nil] lastObject];
        UIButton *checkButton = (UIButton*)[cell viewWithTag:10];
        [SFKImage setDefaultFont:[UIFont fontWithName:@"LigatureSymbols" size:18.0]];
        [SFKImage setDefaultColor:[A3AppDelegate instance].themeColor];
        UIImage *image = [SFKImage imageNamed:@"check"];
        [checkButton setImage:image forState:UIControlStateSelected];
        [checkButton setImage:nil forState:UIControlStateNormal];
        [checkButton addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *imageView = (UIImageView*)[cell viewWithTag:11];
        imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    UIButton *checkButton = (UIButton*)[cell viewWithTag:10];
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:11];
    UILabel *textLabel = (UILabel*)[cell viewWithTag:12];
    UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:13];
    DaysCounterCalendar *item = [_itemArray objectAtIndex:indexPath.row];
    NSInteger cellType = [item.calendarType integerValue];
    
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

    imageView.tintColor = [item color];
    textLabel.text = item.calendarName;
    checkButton.selected = [item.isShow boolValue];
    detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)[item.events count]];
    
    textLabel.font = [UIFont systemFontOfSize:17];
    
    if ( [item.calendarType integerValue] == CalendarCellType_System ) {
        NSInteger numberOfEvents = 0;
        if ( [item.calendarId isEqualToString:SystemCalendarID_All] )
            numberOfEvents = [[A3DaysCounterModelManager sharedManager] numberOfAllEvents];
        else if ( [item.calendarId isEqualToString:SystemCalendarID_Upcoming])
            numberOfEvents = [[A3DaysCounterModelManager sharedManager] numberOfUpcomingEventsWithDate:[NSDate date]];
        else if ( [item.calendarId isEqualToString:SystemCalendarID_Past] )
            numberOfEvents = [[A3DaysCounterModelManager sharedManager] numberOfPastEventsWithDate:[NSDate date]];
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
    DaysCounterCalendar *item = [_itemArray objectAtIndex:fromIndexPath.row];
    [_itemArray removeObjectAtIndex:fromIndexPath.row];
    [_itemArray insertObject:item atIndex:toIndexPath.row];

    [self reorderingItems];
    
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
    DaysCounterCalendar *item = [_itemArray objectAtIndex:indexPath.row];
    if ( [item.calendarType integerValue] == CalendarCellType_System )
        return;
    
    A3DaysCounterAddAndEditCalendarViewController *viewCtrl = [[A3DaysCounterAddAndEditCalendarViewController alloc] initWithNibName:@"A3DaysCounterAddAndEditCalendarViewController" bundle:nil];
    viewCtrl.isEditMode = YES;
    viewCtrl.calendarItem = [[A3DaysCounterModelManager sharedManager] dictionaryFromCalendarEntity:item];
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
    navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.modalVC = navCtrl;
    
    // 왼쪽 바운드 라인이 사라지는 버그 수정을 위하여 추가.
    UIView *leftLineView = [[UIView alloc] initWithFrame:CGRectMake(-(IS_RETINA ? 0.5 : 1), 0, (IS_RETINA ? 0.5 : 1), CGRectGetHeight(navCtrl.view.frame))];
    leftLineView.backgroundColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0];
    [navCtrl.view addSubview:leftLineView];
    
    [self presentViewController:navCtrl animated:YES completion:nil];
    
}
 
#pragma mark - action method
- (void)doneButtonAction:(UIBarButtonItem *)button
{
    if ( IS_IPHONE )
        [self dismissViewControllerAnimated:YES completion:nil];
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
    
    DaysCounterCalendar *item = [_itemArray objectAtIndex:indexPath.row];
    BOOL checkState = [item.isShow boolValue];
    item.isShow = @(!checkState);
    [_itemArray replaceObjectAtIndex:indexPath.row withObject:item];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)addCalendarAction:(id)sender
{
    A3DaysCounterAddAndEditCalendarViewController *viewCtrl = [[A3DaysCounterAddAndEditCalendarViewController alloc] initWithNibName:@"A3DaysCounterAddAndEditCalendarViewController" bundle:nil];
    viewCtrl.isEditMode = NO;
    viewCtrl.calendarItem = nil;
    
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
    navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;

    // 왼쪽 바운드 라인이 사라지는 버그 수정을 위하여 추가.
    UIView *leftLineView = [[UIView alloc] initWithFrame:CGRectMake(-(IS_RETINA ? 0.5 : 1), 0, (IS_RETINA ? 0.5 : 1), CGRectGetHeight(navCtrl.view.frame))];
    leftLineView.backgroundColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0];
    [navCtrl.view addSubview:leftLineView];

    self.modalVC = navCtrl;
    [self presentViewController:navCtrl animated:YES completion:nil];
}
@end
