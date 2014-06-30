//
//  A3DaysCounterSetupCalendarViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterSetupCalendarViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "DaysCounterCalendar.h"
#import "DaysCounterCalendar+Extension.h"
#import "A3DaysCounterSetupCalendarCell.h"
#import "SFKImage.h"
#import "DaysCounterEvent.h"
#import "UIViewController+tableViewStandardDimension.h"

@interface A3DaysCounterSetupCalendarViewController ()
@property (strong, nonatomic) NSArray *itemArray;
@property (strong, nonatomic) DaysCounterCalendar *originalValue;

- (void)cancelAction:(id)sender;
@end

@implementation A3DaysCounterSetupCalendarViewController

- (id)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {

	}

	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.tableView.showsVerticalScrollIndicator = NO;
	self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.separatorInset = A3UITableViewSeparatorInset;

    if( IS_IPAD ){
        self.originalValue = self.eventModel.calendar;
    }
    self.title = NSLocalizedString(@"Calendar", @"Calendar");
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    
    self.itemArray = [_sharedManager allUserCalendarList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willDismissFromRightSide
{
    if (IS_IPAD && _dismissCompletionBlock) {
        _dismissCompletionBlock();
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"calendarListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterSetupCalendarCell" owner:nil options:nil] lastObject];
        UIImageView *imageView = (UIImageView*)[cell viewWithTag:10];
        imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    // Configure the cell...
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:10];
    UILabel *textLabel = (UILabel*)[cell viewWithTag:11];
    
    DaysCounterCalendar *item = [_itemArray objectAtIndex:indexPath.row];
    textLabel.text = item.calendarName;
    if ([[item isShow] boolValue]) {
        textLabel.textColor = [UIColor blackColor];
    }
    else {
        textLabel.textColor = [UIColor colorWithRed:201/255.0 green:201/255.0 blue:201/255.0 alpha:1.0];
    }
    
    imageView.tintColor = [item color];
    cell.accessoryType = [item.uniqueID isEqualToString:_eventModel.calendar.uniqueID] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DaysCounterCalendar *calendar = [_itemArray objectAtIndex:indexPath.row];
    _eventModel.calendar = calendar;
    
    [tableView reloadData];
    [self doneButtonAction:nil];
    
    if (_completionBlock) {
        _completionBlock();
    }
}

#pragma mark - action method
- (void)cancelAction:(id)sender
{
    _eventModel.calendar = self.originalValue;

    if ( IS_IPAD ) {
        [self.A3RootViewController dismissRightSideViewController];
        [self.A3RootViewController.centerNavigationController viewWillAppear:YES];
    }
    else {
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
        if (_dismissCompletionBlock) {
            _dismissCompletionBlock();
        }
    }
}

@end
