//
//  A3LadyCalendarSettingViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LadyCalendarSettingViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3LadyCalendarModelManager.h"
#import "A3LadyCalendarDefine.h"
#import "A3LadyCalendarModelManager.h"
#import "A3UserDefaults.h"
#import "A3LadyCalendarSetupAlertViewController.h"
#import "A3DateHelper.h"
#import "A3AppDelegate+appearance.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3SyncManager.h"

@interface A3LadyCalendarSettingViewController ()

@property (strong, nonatomic) NSArray *itemArray;
@property (strong, nonatomic) NSMutableDictionary *settingDict;

@end

@implementation A3LadyCalendarSettingViewController

- (id)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {

	}

	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Settings", @"Settings");

	self.tableView.showsVerticalScrollIndicator = NO;
	self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);

    if( IS_IPHONE ) {
        [self rightBarButtonDoneButton];
    }
    [self makeBackButtonEmptyArrow];
    
    self.itemArray = @[
			@{
					ItemKey_Title : NSLocalizedString(@"FORECASTING PERIODS", @"FORECASTING PERIODS"),
					ItemKey_Description : @"",
					ItemKey_Items :
					@[
							@{
									ItemKey_Title : @"",
									ItemKey_Type : @(SettingCell_Periods)
							}
					]
			},
			@{
					ItemKey_Title : NSLocalizedString(@"CALCULATE CYCLE LENGTH", @"CALCULATE CYCLE LENGTH"),
					ItemKey_Description : @"",
					ItemKey_Items :
					@[
							@{
									ItemKey_Title : NSLocalizedString(@"Same Before Cycle", @"Same Before Cycle"),
									ItemKey_Type : @(SettingCell_CycleLength)
							},
							@{
									ItemKey_Title : NSLocalizedString(@"Average Before Two Cycle", @"Average Before Two Cycle"),
									ItemKey_Type : @(SettingCell_CycleLength)
							},
							@{
									ItemKey_Title : NSLocalizedString(@"Average All Cycle", @"Average All Cycle"),
									ItemKey_Type : @(SettingCell_CycleLength)
							}
					]
			},
                       @{
							   ItemKey_Title : @"",
							   ItemKey_Description : NSLocalizedString(@"Automatically save period after estimated starting date.", @"Automatically save period after estimated starting date."),
							   ItemKey_Items :
							   @[
									   @{
											   ItemKey_Title : NSLocalizedString(@"Auto Record", @"Auto Record"),
											   ItemKey_Type : @(SettingCell_AutoRecord)
									   }
							   ]
					   },
                       @{
							   ItemKey_Title  : @"",
							   ItemKey_Description : NSLocalizedString(@"Notify about estimated next starting date.", @"Notify about estimated next starting date."),
							   ItemKey_Items :
							   @[
									   @{
											   ItemKey_Title: NSLocalizedString(@"Alert", @"Alert"),
											   ItemKey_Type : @(SettingCell_Alert)
									   }
							   ]
					   }
	];
    self.settingDict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:A3LadyCalendarUserDefaultsSettings]];
    if ( self.settingDict == nil ) {
        self.settingDict = [_dataManager createDefaultSetting];
    }
	self.tableView.showsVerticalScrollIndicator = NO;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudKeyValueStoreDidImport object:nil];
}

- (void)cloudStoreDidImport {
	self.settingDict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:A3LadyCalendarUserDefaultsSettings]];
	[self.tableView reloadData];
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudKeyValueStoreDidImport object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	if ([self isMovingToParentViewController] || [self isBeingDismissed]) {
		[self removeObserver];
	}
}

- (void)dealloc {
	[self removeObserver];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES];
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
    return [_itemArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *items = [[_itemArray objectAtIndex:section] objectForKey:ItemKey_Items];
    return [items count];
}

/*
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *dict = [_itemArray objectAtIndex:section];
    return [dict objectForKey:ItemKey_Title];
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSDictionary *dict = [_itemArray objectAtIndex:section];
    return [dict objectForKey:ItemKey_Description];
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if( section == 0 )
        return 55.0;
    else if( section == 2 )
        return 35.0;
    else if( section == 3 )
        return 20.0;
    
    return 30.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if( section == 1 )
        return 0.01;
    else if( section == 2 )
        return 45.0;
    else if( section == 3 )
        return 55.0;
    return 25.0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"A3LadyCalendarSettingCell" owner:nil options:nil] objectAtIndex:1];
    
    UILabel *label = (UILabel*)[headerView viewWithTag:10];
    NSDictionary *dict = [_itemArray objectAtIndex:section];
    if( section == 0 ){
        NSInteger period = [[_settingDict objectForKey:SettingItem_ForeCastingPeriods] integerValue];
        NSString *periodStr = [NSString stringWithFormat:@"%ld", (long)period];
        NSString *text = [NSString stringWithFormat:NSLocalizedString(@"FORECASTING %@ PERIODS", @"FORECASTING %@ PERIODS"), periodStr];
		NSRange numberRange = [text rangeOfString:periodStr];
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:text];
        [attrStr setAttributes:@{NSForegroundColorAttributeName: [[A3AppDelegate instance] themeColor]} range:numberRange];
        label.attributedText = attrStr;
    }
    else{
        label.text = [dict objectForKey:ItemKey_Title];
    }
    
    return headerView;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[[NSBundle mainBundle] loadNibNamed:@"A3LadyCalendarSettingCell" owner:nil options:nil] objectAtIndex:2];
    
    UILabel *label = (UILabel*)[footerView viewWithTag:10];
    NSDictionary *dict = [_itemArray objectAtIndex:section];
    label.text = [dict objectForKey:ItemKey_Description];
    
    return footerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *cellIDs = @[@"sliderCell",@"defaultCell",@"switchCell",@"value1Cell"];
    NSDictionary *dict = [_itemArray objectAtIndex:indexPath.section];
    NSInteger cellType = [[[[dict objectForKey:ItemKey_Items] objectAtIndex:indexPath.row] objectForKey:ItemKey_Type] integerValue];
    NSString *cellID = [cellIDs objectAtIndex:cellType];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        if( cellType == SettingCell_Periods ){
            NSArray *cellArray = [[NSBundle mainBundle] loadNibNamed:@"A3LadyCalendarSettingCell" owner:nil options:nil];
            cell = [cellArray objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UISlider *slider = (UISlider*)[cell viewWithTag:10];
            [slider addTarget:self action:@selector(periodChangedAction:) forControlEvents:UIControlEventValueChanged];
        }
        else if( cellType == SettingCell_CycleLength ){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            cell.textLabel.font = [UIFont systemFontOfSize:17.0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else if( cellType == SettingCell_AutoRecord ){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            UISwitch *swButton = [[UISwitch alloc] init];
            [swButton addTarget:self action:@selector(toggleSwitchAction:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = swButton;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.font = [UIFont systemFontOfSize:17.0];
        }
        else if( cellType == SettingCell_Alert ){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
			cell.textLabel.font = [UIFont systemFontOfSize:17.0];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:17.0];
            cell.detailTextLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    // Configure the cell...
    NSArray *items = [dict objectForKey:ItemKey_Items];
    NSDictionary *item = [items objectAtIndex:indexPath.row];
    
    if( cellType == SettingCell_Periods ){
        UISlider *slider = (UISlider *)[cell viewWithTag:10];
        slider.value = [[_settingDict objectForKey:SettingItem_ForeCastingPeriods] floatValue];
    }
    else if( cellType == SettingCell_CycleLength ){
        cell.textLabel.text = [item objectForKey:ItemKey_Title];
        cell.accessoryType = (indexPath.row == [[_settingDict objectForKey:SettingItem_CalculateCycle] integerValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
    }
    else if( cellType == SettingCell_AutoRecord ){
        cell.textLabel.text = [item objectForKey:ItemKey_Title];
        UISwitch *swButton = (UISwitch*)cell.accessoryView;
        swButton.on = [[_settingDict objectForKey:SettingItem_AutoRecord] boolValue];
    }
    else if( cellType == SettingCell_Alert ){
        cell.textLabel.text = [item objectForKey:ItemKey_Title];
        NSInteger alertType = [[_settingDict objectForKey:SettingItem_AlertType] integerValue];
        if( alertType != AlertType_Custom )
            cell.detailTextLabel.text = [_dataManager stringForAlertType:alertType];
        else
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld days before",@"StringsDict", @"Lady Calendar Custome Alert"), (long) [[_settingDict objectForKey:SettingItem_CustomAlertDays] integerValue]];
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.section == 1 ){
        NSIndexPath *prevIndexPath = [NSIndexPath indexPathForRow:[[_settingDict objectForKey:SettingItem_CalculateCycle] integerValue] inSection:indexPath.section];
        [_settingDict setObject:@(indexPath.row) forKey:SettingItem_CalculateCycle];
		[self saveSettings];

        [tableView reloadData];
        if( prevIndexPath.row != indexPath.row )
            [tableView reloadRowsAtIndexPaths:@[prevIndexPath,indexPath] withRowAnimation:UITableViewRowAnimationNone];
        else
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    else {
        NSDictionary *dict = [_itemArray objectAtIndex:indexPath.section];
        NSArray *items = [dict objectForKey:ItemKey_Items];
        NSDictionary *item = [items objectAtIndex:indexPath.row];
        
        if( [[item objectForKey:ItemKey_Type] integerValue] == SettingCell_Alert ){
            A3LadyCalendarSetupAlertViewController *viewCtrl = [[A3LadyCalendarSetupAlertViewController alloc] init];
			viewCtrl.dataManager = _dataManager;
            viewCtrl.settingDict = self.settingDict;
            [self.navigationController pushViewController:viewCtrl animated:YES];
        }
    }
}

#pragma mark - action method

- (void)doneButtonAction:(UIBarButtonItem *)button
{
	[self removeObserver];

	[_dataManager recalculateDates];
    if( IS_IPHONE )
        [self dismissViewControllerAnimated:YES completion:nil];
    else
        [self.A3RootViewController dismissRightSideViewController];
}

- (void)toggleSwitchAction:(id)sender
{
    UISwitch *swButton = (UISwitch*)sender;
    [_settingDict setObject:@(swButton.on) forKey:SettingItem_AutoRecord];
	[self saveSettings];
}

- (void)periodChangedAction:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    CGFloat sliderValue = roundf(slider.value);
    [_settingDict setObject:@(sliderValue) forKey:SettingItem_ForeCastingPeriods];
	[self saveSettings];

    slider.value = sliderValue;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)willDismissFromRightSide
{
	NSDate *updateDate = [NSDate date];
	[[NSUserDefaults standardUserDefaults] setObject:updateDate forKey:A3LadyCalendarUserDefaultsUpdateDate];
	[[NSUserDefaults standardUserDefaults] setObject:self.settingDict forKey:A3LadyCalendarUserDefaultsSettings];
    [[NSUserDefaults standardUserDefaults] synchronize];

	if ([[A3SyncManager sharedSyncManager] isCloudEnabled]) {
		NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
		[store setObject:self.settingDict forKey:A3LadyCalendarUserDefaultsSettings];
		[store setObject:updateDate forKey:A3LadyCalendarUserDefaultsCloudUpdateDate];
		[store synchronize];
	}

	[_dataManager recalculateDates];
}

- (void)saveSettings {
	NSDate *updateDate = [NSDate date];
	[[NSUserDefaults standardUserDefaults] setObject:updateDate forKey:A3LadyCalendarUserDefaultsUpdateDate];
	[[NSUserDefaults standardUserDefaults] setObject:self.settingDict forKey:A3LadyCalendarUserDefaultsSettings];
	[[NSUserDefaults standardUserDefaults] synchronize];

	if ([[A3SyncManager sharedSyncManager] isCloudEnabled]) {
		NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
		[store setObject:self.settingDict forKey:A3LadyCalendarUserDefaultsSettings];
		[store setObject:updateDate forKey:A3LadyCalendarUserDefaultsCloudUpdateDate];
		[store synchronize];
	}
}

@end
