//
//  A3DaysCounterEventListEditViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 7..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterEventListEditViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "DaysCounterCalendar.h"
#import "DaysCounterEvent.h"
#import "A3DaysCounterEventChangeCalendarViewController.h"
#import "A3AppDelegate+appearance.h"
#import "UIImage+JHExtension.h"

#define ActionSheet_DeleteAll           100
#define ActionSheet_DeleteSelected      101

@interface A3DaysCounterEventListEditViewController ()
@property (strong, nonatomic) NSMutableArray *itemArray;
@property (strong, nonatomic) UIImage *checkNormalImage;
@property (strong, nonatomic) NSMutableDictionary *checkStatusDict;
@property (strong, nonatomic) NSMutableArray *selectedArray;
@property (strong, nonatomic) UIPopoverController *popoverVC;

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
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Delete All" style:UIBarButtonItemStylePlain target:self action:@selector(deleteAllAction:)];
    self.toolbarItems = _bottomToolbar.items;
    [self.navigationController setToolbarHidden:NO];
    
    self.checkNormalImage = [A3DaysCounterModelManager strokCircleImageSize:CGSizeMake(22.0, 22.0) color:[UIColor colorWithRed:201.0/255.0 green:201.0/255.0 blue:204.0/255.0 alpha:1.0]];
    self.checkStatusDict = [NSMutableDictionary dictionary];
    self.selectedArray = [NSMutableArray array];
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 48, 0, 0)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if( [_calendarItem.calendarType integerValue] == CalendarCellType_User )
        self.itemArray = [NSMutableArray arrayWithArray:[_calendarItem.events array]];
    else{
        NSArray *sourceArray = nil;
        if( [_calendarItem.calendarId isEqualToString:SystemCalendarID_All] )
            sourceArray = [[A3DaysCounterModelManager sharedManager] allEventsList];
        else if( [_calendarItem.calendarId isEqualToString:SystemCalendarID_Past] )
            sourceArray = [[A3DaysCounterModelManager sharedManager] pastEventsListWithDate:[NSDate date]];
        else if( [_calendarItem.calendarId isEqualToString:SystemCalendarID_Upcoming] )
            sourceArray = [[A3DaysCounterModelManager sharedManager] upcomingEventsListWithDate:[NSDate date]];
        self.itemArray = [NSMutableArray arrayWithArray:sourceArray];
    }
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.checkNormalImage = nil;
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
        [button setImage:self.checkNormalImage forState:UIControlStateNormal];
        [button addTarget:self action:@selector(toggleSelectAction:) forControlEvents:UIControlEventTouchUpInside];
        button.tintColor = [A3AppDelegate instance].themeColor;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }   
    
    // Configure the cell...
    DaysCounterEvent *item = [_itemArray objectAtIndex:indexPath.row];
    UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
    UIButton *checkButton = (UIButton*)[cell viewWithTag:11];
    textLabel.text = item.eventName;
    checkButton.selected = [[_checkStatusDict objectForKey:item.eventId] boolValue];
    
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
            NSManagedObjectContext *context = [[A3DaysCounterModelManager sharedManager] managedObjectContext];
            for(DaysCounterEvent *event in _itemArray){
                [event MR_deleteInContext:context];
            }
            _calendarItem.events = nil;
            [context MR_saveToPersistentStoreAndWait];
            [_checkStatusDict removeAllObjects];
            [_itemArray removeAllObjects];
            [self.tableView reloadData];
        }
        else if( actionSheet.tag == ActionSheet_DeleteSelected ){
            NSMutableArray *removeItems = [NSMutableArray array];
            NSMutableArray *indexPaths = [NSMutableArray array];
            
            for(NSInteger i=0; i < [_itemArray count]; i++){
                DaysCounterEvent *item = [_itemArray objectAtIndex:i];
                if( [[_checkStatusDict objectForKey:item.eventId] boolValue] ){
                    [removeItems addObject:item];
                    [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                }
            }
            
            NSManagedObjectContext *context = [[A3DaysCounterModelManager sharedManager] managedObjectContext];
            for(DaysCounterEvent *event in removeItems){
                [event MR_deleteInContext:context];
            }
            [context MR_saveToPersistentStoreAndWait];
            [_itemArray removeObjectsInArray:removeItems];
            removeItems = nil;
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        if( [self.itemArray count] < 1 ){
            [self cancelAction:nil];
        }
    }
}

#pragma mark - action method
- (void)cancelAction:(id)sender
{
    if( IS_IPHONE )
        [self dismissViewControllerAnimated:YES completion:nil];
    else{
        [self.A3RootViewController dismissRightSideViewController];
        [self.A3RootViewController.centerNavigationController viewWillAppear:YES];
        
    }
}

- (void)doneButtonAction:(UIBarButtonItem *)button
{
    [self cancelAction:nil];
}

- (void)deleteAllAction:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete All" otherButtonTitles: nil];
    actionSheet.tag = ActionSheet_DeleteAll;
    [actionSheet showInView:self.view];
}

- (void)toggleSelectAction:(id)sender
{
    UIButton* button = (UIButton*)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[[button superview] superview] superview]];
    if (indexPath == nil )
        return;
    
    button.selected = !button.selected;
    
    if (button.selected) {
        [button setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
    }
    else {
        [button setBackgroundImage:self.checkNormalImage forState:UIControlStateNormal];
    }
    
    DaysCounterEvent *item = [_itemArray objectAtIndex:indexPath.row];
    [_checkStatusDict setObject:[NSNumber numberWithBool:button.selected] forKey:item.eventId];
    if( button.selected )
        [_selectedArray addObject:item];
    else
        [_selectedArray removeObject:item];
}

- (IBAction)removeAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Events" otherButtonTitles: nil];
    actionSheet.tag = ActionSheet_DeleteSelected;
    [actionSheet showInView:self.view];
}

- (IBAction)changeCalendarAction:(id)sender {
    if( [_selectedArray count] < 1 ){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Please select events" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        return;
    }

    A3DaysCounterEventChangeCalendarViewController *viewCtrl = [[A3DaysCounterEventChangeCalendarViewController alloc] initWithNibName:@"A3DaysCounterEventChangeCalendarViewController" bundle:nil];
    viewCtrl.currentCalendar = _calendarItem;
    viewCtrl.eventArray = _selectedArray;
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
    navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:navCtrl animated:YES completion:nil];
}

- (IBAction)shareAction:(id)sender {
    if( [_selectedArray count] < 1 ){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Please select events" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    NSMutableArray *activityItems = [NSMutableArray array];
    for(DaysCounterEvent *event in _selectedArray){
        [activityItems addObject:[NSString stringWithFormat:@"%@",[[A3DaysCounterModelManager sharedManager] stringForShareEvent:event]]];
    }
    
    self.popoverVC = [self presentActivityViewControllerWithActivityItems:activityItems fromBarButtonItem:sender];
    if( self.popoverVC )
        self.popoverVC.delegate = self;
}

#pragma mark - UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popoverVC = nil;
}
@end
