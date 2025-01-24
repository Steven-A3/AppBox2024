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
#import "A3UserDefaultsKeys.h"
#import "A3LadyCalendarSetupAlertViewController.h"
#import "A3DateHelper.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "A3UserDefaults+A3Addition.h"
#import "A3AppDelegate.h"

@interface A3LadyCalendarSettingViewController ()

@property (strong, nonatomic) NSArray *itemArray;
@property (strong, nonatomic) NSMutableDictionary *settingDict;
@property (strong, nonatomic) id settingsObserver;

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

    self.title = NSLocalizedString(A3AppName_Settings, nil);

	self.tableView.showsVerticalScrollIndicator = NO;
	self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.separatorInset = A3UITableViewSeparatorInset;
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}

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
    self.settingDict = [NSMutableDictionary dictionaryWithDictionary:[[A3SyncManager sharedSyncManager] objectForKey:A3LadyCalendarUserDefaultsSettings]];
    if ( self.settingDict == nil ) {
        self.settingDict = [_dataManager createDefaultSetting];
    }
	self.tableView.showsVerticalScrollIndicator = NO;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudKeyValueStoreDidImport object:nil];
}

- (void)cloudStoreDidImport {
	self.settingDict = [NSMutableDictionary dictionaryWithDictionary:[[A3SyncManager sharedSyncManager] objectForKey:A3LadyCalendarUserDefaultsSettings]];
	[self.tableView reloadData];
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudKeyValueStoreDidImport object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([self.navigationController.navigationBar isHidden]) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
	}
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
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
	CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenBounds.size.width, 35)];
    
	UILabel *label = [UILabel new];
	label.font = [UIFont systemFontOfSize:14];
	label.textColor = [UIColor colorWithRed:109.0/255.0 green:109.0/255.0 blue:114.0/255.0 alpha:1.0];
	[headerView addSubview:label];
	
	CGFloat leading = IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28;
	[label makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(headerView.left).with.offset(leading);
		make.centerY.equalTo(headerView.centerY);
	}];
    NSDictionary *dict = [_itemArray objectAtIndex:section];
    if( section == 0 ){
        NSInteger period = [[_settingDict objectForKey:SettingItem_ForeCastingPeriods] integerValue];
        NSString *periodStr = [NSString stringWithFormat:@"%ld", (long)period];
        NSString *text = [NSString stringWithFormat:NSLocalizedString(@"FORECASTING %@ PERIODS", @"FORECASTING %@ PERIODS"), periodStr];
		NSRange numberRange = [text rangeOfString:periodStr];
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:text];
        [attrStr setAttributes:@{NSForegroundColorAttributeName: [[A3UserDefaults standardUserDefaults] themeColor]} range:numberRange];
        label.attributedText = attrStr;
    }
    else{
        label.text = [dict objectForKey:ItemKey_Title];
    }
    
    return headerView;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenBounds.size.width, 35)];
	
	UILabel *label = [UILabel new];
	label.font = [UIFont systemFontOfSize:13];
	label.textColor = [UIColor colorWithRed:109.0/255.0 green:109.0/255.0 blue:114.0/255.0 alpha:1.0];
	label.numberOfLines = 0;
	[footerView addSubview:label];
	
	CGFloat leading = IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28;
	[label makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(footerView.left).with.offset(leading);
		make.right.equalTo(footerView.right).with.offset(-leading);
		make.top.equalTo(footerView.top).with.offset(6);
	}];
	
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
        if (cellType == SettingCell_Periods) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
			UILabel *leftLabel = [UILabel new];
			leftLabel.text = @"3";
			[cell addSubview:leftLabel];
			
			CGFloat leading = IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28;
			[leftLabel makeConstraints:^(MASConstraintMaker *make) {
				make.left.equalTo(cell.left).with.offset(leading);
				make.centerY.equalTo(cell.centerY);
			}];
			
			UILabel *rightLabel = [UILabel new];
			rightLabel.text = @"12";
			[cell addSubview:rightLabel];
			
			[rightLabel makeConstraints:^(MASConstraintMaker *make) {
				make.right.equalTo(cell.right).with.offset(-leading);
				make.centerY.equalTo(cell.centerY);
			}];
			UISlider *slider = [UISlider new];
			slider.tag = 10;
			[slider setMinimumValue:3];
			[slider setMaximumValue:12];
			[slider setValue:3];
			[cell addSubview:slider];
			[slider makeConstraints:^(MASConstraintMaker *make) {
				make.left.equalTo(leftLabel.right).with.offset(8);
				make.centerY.equalTo(cell.centerY);
				make.right.equalTo(rightLabel.left).with.offset(-8);
			}];
			
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            [slider addTarget:self action:@selector(periodChangedAction:) forControlEvents:UIControlEventValueChanged];
        }
        else if (cellType == SettingCell_CycleLength) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            cell.textLabel.font = [UIFont systemFontOfSize:17.0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else if (cellType == SettingCell_AutoRecord) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            UISwitch *swButton = [[UISwitch alloc] init];
            [swButton addTarget:self action:@selector(toggleSwitchAction:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = swButton;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.font = [UIFont systemFontOfSize:17.0];
        }
        else if (cellType == SettingCell_Alert) {
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
    
    if (cellType == SettingCell_Periods) {
        UISlider *slider = (UISlider *)[cell viewWithTag:10];
        slider.value = [[_settingDict objectForKey:SettingItem_ForeCastingPeriods] floatValue];
    }
    else if (cellType == SettingCell_CycleLength) {
        cell.textLabel.text = [item objectForKey:ItemKey_Title];
        cell.accessoryType = (indexPath.row == [[_settingDict objectForKey:SettingItem_CalculateCycle] integerValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
    }
    else if (cellType == SettingCell_AutoRecord) {
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
    if (indexPath.section == 1) {
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
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
				// 설정에 들어가기 전에, Notification 설정을 확인
				UIUserNotificationSettings *currentNotificationSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
				if (currentNotificationSettings.types == UIUserNotificationTypeNone) {

                    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil];
                    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
                    
                    _settingsObserver = [[NSNotificationCenter defaultCenter] addObserverForName:A3NotificationsUserNotificationSettingsRegistered
                                                                                          object:nil
                                                                                           queue:nil
                                                                                      usingBlock:^(NSNotification *note) {
                        [[NSNotificationCenter defaultCenter] removeObserver:_settingsObserver];
                        _settingsObserver = nil;
                        
                        UIUserNotificationSettings *userSettings = note.object;
                        if (userSettings.types == UIUserNotificationTypeNone) {
                            // User did not allow to use notification
                            // Alert User to it is not possible to set alert option
                            
                            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Notifications are disabled", nil)
                                                                                                     message:NSLocalizedString(@"Please enable alert after enabling notifications for this app.", nil)
                                                                                              preferredStyle:UIAlertControllerStyleAlert];
                            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
                                                                                style:UIAlertActionStyleCancel
                                                                              handler:NULL]];
                            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(A3AppName_Settings, nil)
                                                                                style:UIAlertActionStyleDefault
                                                                              handler:^(UIAlertAction *action) {
                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                            }]];
                            [self presentViewController:alertController
                                               animated:YES
                                             completion:NULL];
                        } else {
                            [self moveToAlertSetupViewController];
                        }
                    }];
                    return;
                }
            [self moveToAlertSetupViewController];
        }
    }
}

- (void)moveToAlertSetupViewController
{
    A3LadyCalendarSetupAlertViewController *viewCtrl = [[A3LadyCalendarSetupAlertViewController alloc] init];
    viewCtrl.dataManager = _dataManager;
    viewCtrl.settingDict = self.settingDict;
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

#pragma mark - action method

- (void)doneButtonAction:(UIBarButtonItem *)button
{
	[self removeObserver];

	[_dataManager recalculateDates];
    if( IS_IPHONE )
        [self dismissViewControllerAnimated:YES completion:nil];
    else
        [[[A3AppDelegate instance] rootViewController_iPad] dismissRightSideViewController];
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
	[[A3SyncManager sharedSyncManager] setObject:self.settingDict forKey:A3LadyCalendarUserDefaultsSettings state:A3DataObjectStateModified];

	[_dataManager recalculateDates];
}

- (void)saveSettings {
	[[A3SyncManager sharedSyncManager] setObject:self.settingDict forKey:A3LadyCalendarUserDefaultsSettings state:A3DataObjectStateModified];
}

@end
