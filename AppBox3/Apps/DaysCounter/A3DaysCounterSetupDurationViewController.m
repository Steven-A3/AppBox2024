//
//  A3DaysCounterSetupDurationViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterSetupDurationViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "SFKImage.h"

@interface A3DaysCounterSetupDurationViewController ()
@property (strong, nonatomic) NSArray *itemArray;
@property (strong, nonatomic) NSNumber *originalValue;

- (NSString*)exampleString;
- (void)cancelAction:(id)sender;
@end

@implementation A3DaysCounterSetupDurationViewController
- (NSString*)exampleString
{
    NSString *retStr = @"";
    NSArray *valueArray = @[@"2 years", @"3 months", @"4 weeks",@"15 days" ,@"4 hours", @"30 minutes",@"13 seconds"];
    NSArray *optionArray = @[@(DurationOption_Year),@(DurationOption_Month),@(DurationOption_Week),@(DurationOption_Day),@(DurationOption_Hour),@(DurationOption_Minutes),@(DurationOption_Seconds)];
    
    NSInteger optionValue = [[_eventModel objectForKey:EventItem_DurationOption] integerValue];
    
    for (NSInteger i=0; i < [optionArray count]; i++) {
        NSInteger flag = [[optionArray objectAtIndex:i] integerValue];
        if ( optionValue & flag ) {
            if ( [retStr length] > 0 )
                retStr = [retStr stringByAppendingString:@" "];
            retStr = [retStr stringByAppendingString:[valueArray objectAtIndex:i]];
        }
    }
    
    return retStr;
}

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
        self.originalValue = [_eventModel objectForKey:EventItem_DurationOption];
    }
    self.title = @"Duration Options";
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    self.itemArray = @[
  @{EventRowTitle : @"Year",EventRowType : @(DurationOption_Year)},
  @{EventRowTitle : @"Month",EventRowType : @(DurationOption_Month)},
  @{EventRowTitle : @"Week",EventRowType : @(DurationOption_Week)},
  @{EventRowTitle : @"Day",EventRowType : @(DurationOption_Day)},
  @{EventRowTitle : @"Hour",EventRowType : @(DurationOption_Hour)},
  @{EventRowTitle : @"Minutes",EventRowType : @(DurationOption_Minutes)},
  @{EventRowTitle : @"Seconds",EventRowType : @(DurationOption_Seconds)}];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_itemArray count];
}

//- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    return self.infoView;
//}

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
    // Configure the cell...
    cell.textLabel.text = [item objectForKey:EventRowTitle];
    NSInteger optionValue = [[_eventModel objectForKey:EventItem_DurationOption] integerValue];
    cell.accessoryType = ( optionValue & [[item objectForKey:EventRowType] integerValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [_itemArray objectAtIndex:indexPath.row];
    NSInteger optionValue = [[_eventModel objectForKey:EventItem_DurationOption] integerValue];
    NSInteger flag = [[item objectForKey:EventRowType] integerValue];
    
    optionValue ^= flag;
    if ( optionValue == 0 ) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"To show results, need one option." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    [_eventModel setObject:[NSNumber numberWithInteger:optionValue] forKey:EventItem_DurationOption];
    self.examLabel.text = [self exampleString];
    [self.tableView reloadData];
}

#pragma mark - action method
- (void)cancelAction:(id)sender
{
    [_eventModel setObject:self.originalValue forKey:EventItem_DurationOption];
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
        [self.A3RootViewController dismissRightSideViewController];
        [self.A3RootViewController.centerNavigationController viewWillAppear:YES];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    if (_dismissCompletionBlock) {
        _dismissCompletionBlock();
    }
}

@end
