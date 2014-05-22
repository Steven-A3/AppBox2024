//
//  A3DaysCounterSetupDurationViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterSetupDurationViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "SFKImage.h"
#import "DaysCounterEvent.h"

@interface A3DaysCounterSetupDurationViewController ()
@property (strong, nonatomic) NSArray *itemArray;
@property (strong, nonatomic) NSNumber *originalValue;
@property (assign, nonatomic) NSInteger selectedOptionFlag;

- (NSString*)exampleString;
- (void)cancelAction:(id)sender;
@end

@implementation A3DaysCounterSetupDurationViewController

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

    if ( IS_IPAD ) {
        self.originalValue = _eventModel.durationOption;
    }
    self.title = @"Duration Options";
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    self.itemArray = @[
                       @{EventRowTitle : @"Years",EventRowType : @(DurationOption_Year)},
                       @{EventRowTitle : @"Months",EventRowType : @(DurationOption_Month)},
                       @{EventRowTitle : @"Weeks",EventRowType : @(DurationOption_Week)},
                       @{EventRowTitle : @"Days",EventRowType : @(DurationOption_Day)},
                       @{EventRowTitle : @"Hours",EventRowType : @(DurationOption_Hour)},
                       @{EventRowTitle : @"Minutes",EventRowType : @(DurationOption_Minutes)}];

    self.selectedOptionFlag = [_eventModel.durationOption integerValue];
    
    if ([_eventModel.isAllDay boolValue]) {
        self.selectedOptionFlag = self.selectedOptionFlag & ~(DurationOption_Hour|DurationOption_Minutes|DurationOption_Seconds);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.examLabel.text = [self exampleString];
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

#pragma mark -

- (NSString*)exampleString
{
    NSString *retStr = @"";
    NSArray *valueArray = @[@"2 years", @"3 months", @"4 weeks",@"15 days" ,@"4 hours", @"30 minutes",@"13 seconds"];
    NSArray *optionArray = @[@(DurationOption_Year), @(DurationOption_Month), @(DurationOption_Week), @(DurationOption_Day), @(DurationOption_Hour), @(DurationOption_Minutes), @(DurationOption_Seconds)];
    
    NSInteger optionValue = [_eventModel.durationOption integerValue];
    
    for (NSInteger i=0; i < [optionArray count]; i++) {
        NSInteger flag = [[optionArray objectAtIndex:i] integerValue];
        if ( optionValue & flag ) {
            if ( [retStr length] > 0 ) {
                retStr = [retStr stringByAppendingString:@" "];
            }
            retStr = [retStr stringByAppendingString:[valueArray objectAtIndex:i]];
        }
    }
    
    return retStr;
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:17];
    }
    
    NSDictionary *item = [_itemArray objectAtIndex:indexPath.row];
    NSInteger itemRowType = [[item objectForKey:EventRowType] integerValue];

    cell.textLabel.text = [item objectForKey:EventRowTitle];
    
    if ([_eventModel.isAllDay boolValue] &&
        (itemRowType == DurationOption_Hour || itemRowType == DurationOption_Minutes || itemRowType == DurationOption_Seconds)) {
        cell.userInteractionEnabled = NO;
        cell.textLabel.textColor = [UIColor colorWithRed:201/255.0 green:201/255.0 blue:201/255.0 alpha:1.0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else {
        cell.userInteractionEnabled = YES;
        cell.textLabel.textColor = [UIColor blackColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = ( self.selectedOptionFlag & itemRowType ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
    }
    
    if (itemRowType == DurationOption_Day) {
        cell.userInteractionEnabled = NO;
        cell.textLabel.textColor = [UIColor colorWithRed:201/255.0 green:201/255.0 blue:201/255.0 alpha:1.0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [_itemArray objectAtIndex:indexPath.row];
    NSInteger itemRowType = [[item objectForKey:EventRowType] integerValue];
    if (itemRowType == DurationOption_Day) {
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger optionValue = self.selectedOptionFlag;//[[_eventModel objectForKey:EventItem_DurationOption] integerValue];
    NSInteger flag = [[item objectForKey:EventRowType] integerValue];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = (optionValue & flag) ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
    
    optionValue ^= flag;
    if ( optionValue == 0 ) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"To show results, need one option."
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
        return;
    }
    
    self.selectedOptionFlag = optionValue;
    self.examLabel.text = [self exampleString];
    self.eventModel.durationOption = @(self.selectedOptionFlag);
}

#pragma mark - action method
- (void)cancelAction:(id)sender
{
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
    if ( IS_IPAD ) {
        _eventModel.durationOption = @(self.selectedOptionFlag);
        [self.A3RootViewController dismissRightSideViewController];
        [self.A3RootViewController.centerNavigationController viewWillAppear:YES];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
        if (_dismissCompletionBlock) {
            _dismissCompletionBlock();
        }
    }
}

@end
