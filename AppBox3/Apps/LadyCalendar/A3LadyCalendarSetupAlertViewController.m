//
//  A3LadyCalendarSetupAlertViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LadyCalendarSetupAlertViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "A3LadyCalendarDefine.h"
#import "A3LadyCalendarModelManager.h"
#import "A3DateHelper.h"
#import "A3LadyCalendarSetupCustomAlertViewController.h"

@interface A3LadyCalendarSetupAlertViewController ()
@property (strong, nonatomic) NSArray *itemArray;
@end

@implementation A3LadyCalendarSetupAlertViewController

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

    self.title = @"Alert";
    [self makeBackButtonEmptyArrow];
    
    self.itemArray = @[@(AlertType_None),@(AlertType_OnDay),@(AlertType_OneDayBefore),@(AlertType_TwoDaysBefore),@(AlertType_OneWeekBefore),@(AlertType_Custom)];
    
    if( [_settingDict objectForKey:SettingItem_CustomAlertTime] == nil )
        [_settingDict setObject:[NSDate date] forKey:SettingItem_CustomAlertTime];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:17.0];
        cell.textLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSInteger type = [[_itemArray objectAtIndex:indexPath.row] integerValue];
    cell.textLabel.text = [[A3LadyCalendarModelManager sharedManager] stringForAlertType:type];
    
    if( type == AlertType_Custom ){
        NSInteger currentType = [[_settingDict objectForKey:SettingItem_AlertType] integerValue];
        if( currentType == type )
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld days before %@", (long)[[_settingDict objectForKey:SettingItem_CustomAlertDays] integerValue],([_settingDict objectForKey:SettingItem_CustomAlertTime] ? [A3DateHelper dateStringFromDate:[_settingDict objectForKey:SettingItem_CustomAlertTime] withFormat:@"h:mm a"] : @"") ];
        else
            cell.detailTextLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else{
        cell.detailTextLabel.text = nil;
        cell.accessoryType = ( type == [[_settingDict objectForKey:SettingItem_AlertType] integerValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger type = [[_itemArray objectAtIndex:indexPath.row] integerValue];
    
    NSIndexPath *prevIndexPath = [NSIndexPath indexPathForRow:ABS(type) inSection:indexPath.section];
    
    [_settingDict setObject:@(type) forKey:SettingItem_AlertType];
    if( type != AlertType_Custom ){
        [_settingDict removeObjectForKey:SettingItem_CustomAlertDays];
        [_settingDict removeObjectForKey:SettingItem_CustomAlertTime];
    }

    [tableView reloadData];
    if( prevIndexPath.row != indexPath.row )
        [tableView reloadRowsAtIndexPaths:@[prevIndexPath,indexPath] withRowAnimation:UITableViewRowAnimationNone];
    else
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];

    if( type == AlertType_Custom ){
        A3LadyCalendarSetupCustomAlertViewController *viewCtrl = [[A3LadyCalendarSetupCustomAlertViewController alloc] initWithNibName:@"A3LadyCalendarSetupCustomAlertViewController" bundle:nil];
        viewCtrl.settingDict = _settingDict;
        [self.navigationController pushViewController:viewCtrl animated:YES];
    }
}

@end
