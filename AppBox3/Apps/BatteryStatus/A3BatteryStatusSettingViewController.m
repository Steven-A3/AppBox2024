//
//  A3BatteryStatusSettingViewController.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 12/4/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3BatteryStatusSettingViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3BatteryStatusManager.h"
#import "A3BatterStatusChooseColorViewController.h"
#import "A3BasicWebViewController.h"
#import "Reachability.h"
#import "UIImage+imageWithColor.h"
#import "UIViewController+iPad_rightSideView.h"
#import "UIViewController+tableViewStandardDimension.h"

NSString *const A3BatteryIndexKey = @"index";
NSString *const A3BatteryCheckedKey = @"checked";
NSString *const A3BatteryTitleKey = @"title";

@interface A3BatteryStatusSettingViewController ()
@end

@implementation A3BatteryStatusSettingViewController
{
    NSArray * _tableDataSourceArray;
    UIColor * _chosenTheme;
    NSMutableArray * _adjustedIndex;
    UIImage * _blankImage;
    NSMutableArray * _presentViews;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _tableDataSourceArray = [A3BatteryStatusManager remainTimeDataArray];
    
    [self makeBackButtonEmptyArrow];
	if (IS_IPHONE) {
		[self rightBarButtonDoneButton];
	}

    self.title = NSLocalizedString(A3AppName_Settings, nil);
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.allowsSelectionDuringEditing = YES;
	self.tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	self.tableView.rowHeight = 44.0;
    [self.tableView setEditing:YES];
    
    _chosenTheme = [A3BatteryStatusManager chosenTheme];
    _adjustedIndex = [[A3BatteryStatusManager adjustedIndex] mutableCopy];

    if (!_adjustedIndex) {
        _adjustedIndex = [NSMutableArray arrayWithCapacity:_tableDataSourceArray.count];

        for (int i=0; i<_tableDataSourceArray.count; i++) {
            [_adjustedIndex addObject:@{ A3BatteryIndexKey : @(i), A3BatteryCheckedKey : @1 }];
        }
    }
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(15, 15), NO, 0);
    _blankImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if ([self.navigationController.navigationBar isHidden]) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
	}
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
-(void)doneButtonAction:(id)sender {
	if (IS_IPAD) {
		[[A3AppDelegate instance].rootViewController_iPad dismissRightSideViewController];
	} else {
		[self.navigationController dismissViewControllerAnimated:YES completion:nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationChildViewControllerDidDismiss object:self];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==1) {
        return _tableDataSourceArray.count;
    } else {
        return 1;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==1) {
        return NSLocalizedString(@"STATUS", @"STATUS");
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const CellIdentifier1 = @"Cell1";
    static NSString * const CellIdentifier2 = @"Cell2";
    static NSString * const CellIdentifier3 = @"Cell3";
    // Configure the cell...
    if (indexPath.section==0) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1];
            cell.textLabel.font = [UIFont systemFontOfSize:17.0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            UIView *themeColorView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 30.0, 30.0)];
            themeColorView.backgroundColor = [UIColor redColor];
            themeColorView.tag = 121;

            [cell.contentView addSubview:themeColorView];

            [themeColorView makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(cell.contentView.centerY);
                make.right.equalTo(cell.contentView.right).with.offset(-27.5);
                make.width.equalTo(@30);
                make.height.equalTo(@30);
            }];

			UIImageView *disclosureIndicator = [UIImageView new];
			disclosureIndicator.image = [UIImage imageNamed:@"arrow"];
			[cell addSubview:disclosureIndicator];

			[disclosureIndicator makeConstraints:^(MASConstraintMaker *make) {
				make.centerY.equalTo(cell.centerY);
				make.right.equalTo(cell.right).with.offset(-15);
			}];
        }

        cell.textLabel.text = NSLocalizedString(@"Theme Color", @"Theme Color");
        UIView *themeColorView = [cell.contentView viewWithTag:121];
        themeColorView.backgroundColor = [[A3BatteryStatusManager themeColorArray] objectAtIndex:[A3BatteryStatusManager chosenThemeIndex]];
        return cell;
    }
    else if (indexPath.section == 1) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
            cell.textLabel.font = [UIFont systemFontOfSize:17];
        }
        
        NSDictionary *adjustedRow = [_adjustedIndex objectAtIndex:indexPath.row];
        NSNumber * index = [adjustedRow objectForKey:A3BatteryIndexKey];
        NSNumber * checked = [adjustedRow objectForKey:A3BatteryCheckedKey];
        
        NSDictionary *rowData = [_tableDataSourceArray objectAtIndex:index.integerValue];
        cell.textLabel.text = NSLocalizedString([rowData objectForKey:A3BatteryTitleKey], nil);
        cell.imageView.image = checked.integerValue == 1 ? [[UIImage imageNamed:@"check_02"] tintedImageWithColor:[A3AppDelegate instance].themeColor] : _blankImage;
        return cell;
    }
    else if (indexPath.section == 2) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier3];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier3];
            cell.textLabel.font = [UIFont systemFontOfSize:17];
            
            UIImageView * info = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"information"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            info.tintColor = [A3AppDelegate instance].themeColor;
            [cell.contentView addSubview:info];
            [info makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(cell.centerY);
                make.right.equalTo(cell.contentView.right).with.offset(-15);
            }];
        }
        
        cell.textLabel.text = NSLocalizedString(@"How to Maximize Power Use", @"How to Maximize Power Use");
        return cell;
    }
    else {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier3];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier3];
            cell.textLabel.font = [UIFont systemFontOfSize:17];
            
            UIImageView * info = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"information"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            [cell.contentView addSubview:info];
            [info makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(cell.centerY);
                make.right.equalTo(cell.contentView.right).with.offset(-15);
            }];
        }
        
        cell.textLabel.text = NSLocalizedString(@"More Information about Batteries", @"More Information about Batteries");
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        A3BatterStatusChooseColorViewController * viewController = [[A3BatterStatusChooseColorViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:viewController animated:YES];
        
    } else if (indexPath.section == 1) {
        NSDictionary * row = _adjustedIndex[indexPath.row];
        NSNumber * index = [row objectForKey:A3BatteryIndexKey];
        NSNumber * checked = [row objectForKey:A3BatteryCheckedKey];

        [_adjustedIndex removeObjectAtIndex:indexPath.row];
        if ([checked isEqualToNumber:@0]) {
            [_adjustedIndex insertObject:@{ A3BatteryIndexKey : index, A3BatteryCheckedKey : @1 } atIndex:indexPath.row];
        } else {
            [_adjustedIndex insertObject:@{ A3BatteryIndexKey : index, A3BatteryCheckedKey : @0 } atIndex:indexPath.row];
        }

        //[tableView reloadData];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell) {
            cell.imageView.image = ([checked integerValue] == 0) ? [[UIImage imageNamed:@"check_02"] tintedImageWithColor:[A3AppDelegate instance].themeColor] : _blankImage;
        }
        [A3BatteryStatusManager setAdjustedIndex:_adjustedIndex];
    }
    else if (indexPath.section == 2) {
        // Battery How to Maximize
		[self presentWebViewControllerURL:[A3BatteryStatusManager howToMaximizePowerUse]];
	}
    else if (indexPath.section == 3) {
        // More Info About Battery
		[self presentWebViewControllerURL:[A3BatteryStatusManager moreInformationAboutBatteries]];
    }
}

- (void)presentWebViewControllerURL:(NSURL *)url {
	if (![[A3AppDelegate instance].reachability isReachable]) {
		[self alertInternetConnectionIsNotAvailable];
		return;
	}
	A3BasicWebViewController *viewController = [[A3BasicWebViewController alloc] init];
	viewController.url = url;
	if (IS_IPHONE) {
		[self.navigationController pushViewController:viewController animated:YES];
	} else {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
		[[[A3AppDelegate instance] rootViewController_iPad] presentViewController:navigationController animated:YES completion:NULL];
	}
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 1 ? YES : NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSDictionary *from = [_adjustedIndex objectAtIndex:fromIndexPath.row];
    [_adjustedIndex removeObjectAtIndex:fromIndexPath.row];
    [_adjustedIndex insertObject:from atIndex:toIndexPath.row];
    
    [A3BatteryStatusManager setAdjustedIndex:_adjustedIndex];

    [self.tableView reloadData];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

@end

