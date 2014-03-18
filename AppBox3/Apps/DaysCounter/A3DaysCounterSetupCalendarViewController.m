//
//  A3DaysCounterSetupCalendarViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterSetupCalendarViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "DaysCounterCalendar.h"
#import "SFKImage.h"

@interface A3DaysCounterSetupCalendarViewController ()
@property (strong, nonatomic) NSArray *itemArray;
@property (strong, nonatomic) DaysCounterCalendar *originalValue;

- (void)cancelAction:(id)sender;
@end

@implementation A3DaysCounterSetupCalendarViewController

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

    if( IS_IPAD ){
        [SFKImage setDefaultFont:[UIFont fontWithName:@"appbox" size:31.0]];
        [SFKImage setDefaultColor:[UIColor blueColor]];
        UIImage *image = [SFKImage imageNamed:@"o"];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleBordered target:self action:@selector(doneButtonAction:)];
//        [self rightBarButtonDoneButton];
        self.originalValue = [_eventModel objectForKey:EventItem_Calendar];
    }
    self.title = @"Calendar";
    [self makeBackButtonEmptyArrow];
    
    self.itemArray = [[A3DaysCounterModelManager sharedManager] allUserCalendarList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"calendarListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *cellArray = [[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterAddEventCell" owner:nil options:nil];
        cell = [cellArray objectAtIndex:8];
        UIImageView *imageView = (UIImageView*)[cell viewWithTag:10];
        imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // Configure the cell...
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:10];
    UILabel *textLabel = (UILabel*)[cell viewWithTag:11];
    
    DaysCounterCalendar *item = [_itemArray objectAtIndex:indexPath.row];
    textLabel.text = item.calendarName;
    textLabel.textColor = ( item.isShow ? [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] : [UIColor colorWithRed:143.0/255.0 green:143.0/255.0 blue:143.0/255.0 alpha:1.0] );
    imageView.tintColor = [item color];
    cell.accessoryType = ( [item.calendarId isEqualToString:[_eventModel objectForKey:EventItem_CalendarId]] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
    
    return cell;
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DaysCounterCalendar *item = [_itemArray objectAtIndex:indexPath.row];
    [_eventModel setObject:item.calendarId forKey:EventItem_CalendarId];
    [_eventModel setObject:item forKey:EventItem_Calendar];
    [tableView reloadData];
    [self doneButtonAction:nil];
}

#pragma mark - action method
- (void)cancelAction:(id)sender
{
    [_eventModel setObject:self.originalValue forKey:EventItem_Calendar];
    [_eventModel setObject:self.originalValue.calendarId forKey:EventItem_CalendarId];
    if( IS_IPAD ){
        [self.A3RootViewController dismissRightSideViewController];
        [self.A3RootViewController.centerNavigationController viewWillAppear:YES];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)doneButtonAction:(UIBarButtonItem *)button
{
    if( IS_IPAD ){
        [self.A3RootViewController dismissRightSideViewController];
        [self.A3RootViewController.centerNavigationController viewWillAppear:YES];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
