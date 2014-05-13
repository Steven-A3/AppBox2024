//
//  A3DaysCounterFavoriteListViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterFavoriteListViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "A3DaysCounterSlidershowMainViewController.h"
#import "A3DaysCounterAddEventViewController.h"
#import "A3DaysCounterCalendarListMainViewController.h"
#import "A3DaysCounterReminderListViewController.h"
#import "FMMoveTableView.h"
#import "A3DaysCounterEventDetailViewController.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "DaysCounterEvent.h"
#import "DaysCounterDateModel.h"
#import "A3DateHelper.h"
#import "A3DaysCounterEventListNameCell.h"
#import "DaysCounterFavorite.h"
#import "NSMutableArray+A3Sort.h"

@interface A3DaysCounterFavoriteListViewController () <FMMoveTableViewDelegate, FMMoveTableViewDataSource>

@property (strong, nonatomic) NSMutableArray *itemArray;

- (void)editAction:(id)sender;

@end

@implementation A3DaysCounterFavoriteListViewController

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
    
    self.title = @"Favorites";
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
    self.toolbarItems = _bottomToolbar.items;
    [self registerContentSizeCategoryDidChangeNotification];
    
    [self leftBarButtonAppsButton];
    [self makeBackButtonEmptyArrow];
    
    self.tableView.separatorInset = UIEdgeInsetsMake(0, (IS_IPHONE ? 15.0 : 28.0), 0, 0);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.delegate = nil;
    [self.navigationController setToolbarHidden:NO];
    self.itemArray = [NSMutableArray arrayWithArray:[_sharedManager favoriteEventsList]];
    [self.tableView reloadData];
    
    [[NSUserDefaults standardUserDefaults] setInteger:4 forKey:@"DaysCounterLastOpenedMainIndex"];
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
    static NSString *CellIdentifier = @"eventListNameCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterEventListNameCell" owner:nil options:nil] lastObject];
        
        UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
        UILabel *daysLabel = (UILabel*)[cell viewWithTag:11];
        textLabel.font = (IS_IPHONE ? [UIFont systemFontOfSize:15.0] : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]);
        daysLabel.font = (IS_IPHONE ? [UIFont systemFontOfSize:13.0] : [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]);
        daysLabel.textColor = [UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0];
        UIView *leftView = [cell viewWithTag:13];
        NSLayoutConstraint *leftConst = nil;
        for (NSLayoutConstraint *layout in cell.contentView.constraints) {
            if ( layout.firstAttribute == NSLayoutAttributeLeading && layout.firstItem == leftView ) {
                leftConst = layout;
                break;
            }
        }
        
        if ( leftConst ) {
            leftConst.constant = ( IS_IPHONE ? 15.0 : 28.0 );
            [cell layoutIfNeeded];
        }
    }
    
    // Configure the cell...
    UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
    UILabel *daysLabel = (UILabel*)[cell viewWithTag:11];
    UILabel *markLabel = (UILabel*)[cell viewWithTag:12];
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:13];
    
    if (IS_IPHONE) {
        textLabel.font = [UIFont systemFontOfSize:15.0];
        daysLabel.font = [UIFont systemFontOfSize:13.0];
    }
    else {
        textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        daysLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        UILabel *dateLabel = (UILabel*)[cell viewWithTag:16];
        dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    }
    
    if ( [_itemArray count] > 0) {
        DaysCounterFavorite *favorite = [_itemArray objectAtIndex:indexPath.row];
        textLabel.text = favorite.event.eventName;
        UIImage *image = [favorite.event.imageFilename length] > 0 ? [A3DaysCounterModelManager photoThumbnailFromFilename:favorite.event.imageFilename] : nil;
        imageView.image =  image ? [A3DaysCounterModelManager circularScaleNCrop:image rect:CGRectMake(0, 0, 32, 32)]  : nil;
        NSDate *today = [NSDate date];

		A3DaysCounterEventListNameCell *eventListNameCell = (A3DaysCounterEventListNameCell *) cell;
        if (image) {
            eventListNameCell.photoLeadingConst.constant = IS_IPHONE ? 15 : 28;
            eventListNameCell.sinceLeadingConst.constant = IS_IPHONE ? 52 : 65;
            eventListNameCell.nameLeadingConst.constant = IS_IPHONE ? 52 : 65;
            eventListNameCell.photoWidthConst.constant = 32;
        }
        else {
            eventListNameCell.sinceLeadingConst.constant = IS_IPHONE ? 15 : 28;
            eventListNameCell.nameLeadingConst.constant = IS_IPHONE ? 15 : 28;
            eventListNameCell.photoWidthConst.constant = 0;
        }
        
        
        // markLabel until/since
        markLabel.text = [A3DateHelper untilSinceStringByFromDate:today
                                                           toDate:[favorite.event effectiveStartDate] //nextDate
                                                     allDayOption:[favorite.event.isAllDay boolValue]
                                                           repeat:[favorite.event.repeatType integerValue] != RepeatType_Never ? YES : NO
                                                           strict:[A3DaysCounterModelManager hasHourMinDurationOption:[favorite.event.durationOption integerValue]]];
        
        if ([markLabel.text isEqualToString:@"since"]) {
            markLabel.textColor = [UIColor colorWithRed:1.0 green:45.0/255.0 blue:85.0/255.0 alpha:1.0];
        }
        else {
            markLabel.textColor = [UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:100.0/255.0 alpha:1.0];
        }
        markLabel.font = IS_IPHONE ? [UIFont systemFontOfSize:11] : [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
        markLabel.layer.borderWidth = IS_RETINA ? 0.5 : 1.0;
        markLabel.layer.masksToBounds = YES;
        markLabel.layer.cornerRadius = 9.0;
        markLabel.layer.borderColor = markLabel.textColor.CGColor;

        // daysLabel
        if ([markLabel.text isEqualToString:@"today"] || [markLabel.text isEqualToString:@"Now"]) {
            daysLabel.text = @" ";

            if ( IS_IPAD ) {
                UILabel *dateLabel = (UILabel*)[cell viewWithTag:16];
                NSDate *repeatDate = [A3DaysCounterModelManager repeatDateOfCurrentNotNextWithRepeatOption:[favorite.event.repeatType integerValue]
                                                                                                 firstDate:[favorite.event.startDate solarDate]
                                                                                                  fromDate:[NSDate date]];
                dateLabel.text = [A3DateHelper dateStringFromDate:repeatDate
                                                       withFormat:[_sharedManager dateFormatForAddEditIsAllDays:[favorite.event.isAllDay boolValue]]];
                
                dateLabel.hidden = NO;
                ((A3DaysCounterEventListNameCell *)cell).titleRightSpaceConst.constant = [dateLabel sizeThatFits:CGSizeMake(500, 30)].width + 5;
            }
        }
        else {
            daysLabel.text = [A3DaysCounterModelManager stringOfDurationOption:[favorite.event.durationOption integerValue]
                                                                      fromDate:today
                                                                        toDate:[favorite.event effectiveStartDate] //nextDate
                                                                      isAllDay:[favorite.event.isAllDay boolValue]
                                                                  isShortStyle:IS_IPHONE ? YES : NO];
            if ( IS_IPAD ) {
                UILabel *dateLabel = (UILabel*)[cell viewWithTag:16];
                dateLabel.text = [A3DateHelper dateStringFromDate:favorite.event.effectiveStartDate
                                                       withFormat:[_sharedManager dateFormatForAddEditIsAllDays:[favorite.event.isAllDay boolValue]]];
                
                dateLabel.hidden = NO;
                ((A3DaysCounterEventListNameCell *)cell).titleRightSpaceConst.constant = [dateLabel sizeThatFits:CGSizeMake(500, 30)].width + 5;
            }
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    else {
        textLabel.text = @"";
        daysLabel.text = @"";
        markLabel.text = @"";
        imageView.hidden = YES;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        DaysCounterFavorite *favorite = [_itemArray objectAtIndex:indexPath.row];
		[favorite MR_deleteEntity];
        [favorite.managedObjectContext MR_saveToPersistentStoreAndWait];
        [_itemArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
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
    DaysCounterFavorite *favorite = [_itemArray objectAtIndex:indexPath.row];
    
    A3DaysCounterEventDetailViewController *viewCtrl = [[A3DaysCounterEventDetailViewController alloc] initWithNibName:@"A3DaysCounterEventDetailViewController" bundle:nil];
    viewCtrl.eventItem = favorite.event;
    viewCtrl.sharedManager = _sharedManager;
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

#pragma mark - FMMoveTableView delegate

- (void)moveTableView:(FMMoveTableView *)tableView moveRowFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	[_itemArray moveItemInSortedArrayFromIndex:fromIndexPath.row toIndex:toIndexPath.row];
	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
}

#pragma mark - action method

- (IBAction)photoViewAction:(id)sender {
    A3DaysCounterSlidershowMainViewController *viewCtrl = [[A3DaysCounterSlidershowMainViewController alloc] initWithNibName:@"A3DaysCounterSlidershowMainViewController" bundle:nil];
    viewCtrl.sharedManager = _sharedManager;
    [self popToRootAndPushViewController:viewCtrl animate:NO];
}

- (IBAction)calendarViewAction:(id)sender {
    A3DaysCounterCalendarListMainViewController *viewCtrl = [[A3DaysCounterCalendarListMainViewController alloc] initWithNibName:@"A3DaysCounterCalendarListMainViewController" bundle:nil];
    viewCtrl.sharedManager = _sharedManager;
    [self popToRootAndPushViewController:viewCtrl animate:NO];
}

- (IBAction)addEventAction:(id)sender {
    A3DaysCounterAddEventViewController *viewCtrl = [[A3DaysCounterAddEventViewController alloc] initWithNibName:@"A3DaysCounterAddEventViewController" bundle:nil];
    viewCtrl.sharedManager = _sharedManager;
    if ( IS_IPHONE ) {
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
        navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:navCtrl animated:YES completion:nil];
    }
    else {
        [self.navigationController pushViewController:viewCtrl animated:YES];
    }
}

- (IBAction)reminderAction:(id)sender {
    A3DaysCounterReminderListViewController *viewCtrl = [[A3DaysCounterReminderListViewController alloc] initWithNibName:@"A3DaysCounterReminderListViewController" bundle:nil];
    viewCtrl.sharedManager = _sharedManager;
    [self popToRootAndPushViewController:viewCtrl animate:NO];
}

- (void)editAction:(id)sender
{
    [self.tableView setEditing:!self.tableView.editing animated:YES];
}

@end
