//
//  A3DaysCounterLocationPopupViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 12..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterLocationPopupViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "DaysCounterEventLocation.h"

@interface A3DaysCounterLocationPopupViewController ()
@property (strong, nonatomic) NSString *addressStr;
@end

@implementation A3DaysCounterLocationPopupViewController

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

    self.title = _locationItem.name;
    if( self.showDoneButton )
        [self rightBarButtonDoneButton];
    
    self.addressStr = [[A3DaysCounterModelManager sharedManager] addressFromVenue:_locationItem isDetail:YES];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 44.0, 0, 0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.popoverVC = nil;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if( cell == nil ){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        
        cell.textLabel.textColor = [UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0];
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        
        cell.detailTextLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:17.0];
        cell.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:0.95];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if( indexPath.row == 0 ){
        cell.textLabel.text = @"Phone";
        cell.detailTextLabel.text = _locationItem.contact;
    }
    else{
        cell.textLabel.text = @"Address";
        cell.detailTextLabel.text = _addressStr;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row == 1 ){
        CGSize size = [self.addressStr sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17.0]}];
        CGSize textSize = [@"Address" sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15.0]}];
        return size.height + textSize.height + 14.0;
        //        return 122.0;
    }
    return 44.0;
}

#pragma mark - action method
- (void)doneButtonAction:(UIBarButtonItem *)button
{
    [self.popoverVC dismissPopoverAnimated:YES];
}

@end
