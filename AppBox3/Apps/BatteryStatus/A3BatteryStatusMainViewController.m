//
//  A3BatteryStatusMainViewController.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 12/4/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3BatteryStatusMainViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "UIViewController+iPad_rightSideView.h"
#import "A3BatteryStatusManager.h"
#import "A3BatterStatusBatteryPanelView.h"
#import "A3BatteryStatusListPageSectionView.h"
#import "A3BatteryStatusSettingViewController.h"
#import "A3DefaultColorDefines.h"
#import "A3InstructionViewController.h"
#import "A3UserDefaults.h"
#import "A3StandardTableViewCell.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "UIViewController+extension.h"
#import "A3SyncManager.h"
#import "A3AppDelegate.h"
#import "A3UIDevice.h"
@import AppBoxKit;

@import GoogleMobileAds;

@interface A3BatteryStatusMainViewController () <A3InstructionViewControllerDelegate, GADBannerViewDelegate>

@property (nonatomic, strong) A3BatteryStatusSettingViewController *settingsViewController;
@property (nonatomic, strong) A3BatteryStatusListPageSectionView *sectionHeaderView;
@property (nonatomic, strong) UINavigationController *modalNavigationController;
@property (nonatomic, strong) A3InstructionViewController *instructionViewController;

@end

@implementation A3BatteryStatusMainViewController
{
    NSArray * _tableDataSourceArray;
    A3BatterStatusBatteryPanelView *_headerView;
    UIView *_topWhitePaddingView;
    BOOL _didReceiveAds;
}

- (id)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {

	}

	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self makeNavigationBarAppearanceDefault];
	[self makeBackButtonEmptyArrow];

    if (IS_IPAD || [UIWindow interfaceOrientationIsPortrait]) {
		[self leftBarButtonAppsButton];
	} else {
		self.navigationItem.leftBarButtonItem = nil;
		self.navigationItem.hidesBackButton = YES;
	}
    [self rightBarButton];
    
    if (IS_IPAD) {
        self.navigationItem.hidesBackButton = YES;
    }
    
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;

    self.title = NSLocalizedString(A3AppName_BatteryStatus, @"Battery Status main view controller title.");
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.separatorInset = A3UITableViewSeparatorInset;
    self.tableView.tableFooterView = nil;

    self.tableView.tableHeaderView = self.headerView;
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}

    [self setupTopWhitePaddingView];
    [self setupInstructionView];
    
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidShow) name:A3NotificationMainMenuDidShow object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewDidAppear) name:A3NotificationRightSideViewDidAppear object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewWillDismiss) name:A3NotificationRightSideViewWillDismiss object:nil];
	}
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(batteryLevelDidChangeNotification:)
												 name:UIDeviceBatteryLevelDidChangeNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(batteryStateDidChangeNotification:)
												 name:UIDeviceBatteryStateDidChangeNotification
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(batteryThemeChanged)
												 name:A3BatteryStatusThemeColorChanged

											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)applicationDidEnterBackground {
	[self dismissInstructionViewController:nil];
}

- (void)removeObserver {
	FNLOG();
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidShow object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidHide object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationRightSideViewDidAppear object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationRightSideViewWillDismiss object:nil];
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceBatteryLevelDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceBatteryStateDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3BatteryStatusThemeColorChanged object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
	[self refreshHeaderView];
    [self reloadTableViewDataSource];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	
	if (IS_IPHONE && [UIWindow interfaceOrientationIsPortrait]) {
		[self leftBarButtonAppsButton];
	}
	if ([self isMovingToParentViewController] || [self isBeingPresented]) {
        [self setupBannerViewForAdUnitID:AdMobAdUnitIDBattery
                                keywords:@[@"battery"]
                                  adSize:IS_IPHONE ? GADAdSizeFluid : GADAdSizeLeaderboard
                                delegate:self];
	}
	if ([self.navigationController.navigationBar isHidden]) {
		[self.navigationController setNavigationBarHidden:NO];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		[self removeObserver];
	}
}

- (void)prepareClose {
	self.tableView.delegate = nil;
	self.tableView.dataSource = nil;
	[self dismissInstructionViewController:nil];
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    }
	[self removeObserver];
	[UIDevice currentDevice].batteryMonitoringEnabled = NO;
}

- (BOOL)resignFirstResponder {
	NSString *startingAppName = [[A3UserDefaults standardUserDefaults] objectForKey:kA3AppsStartingAppName];
	if ([startingAppName length] && ![startingAppName isEqualToString:A3AppName_BatteryStatus]) {
		[self.instructionViewController.view removeFromSuperview];
		self.instructionViewController = nil;
	}
	return [super resignFirstResponder];
}

- (void)cleanUp {
}

- (void)dealloc {
	[self removeObserver];
}

- (void)mainMenuDidShow {
	[self enableControls:NO];
}

- (void)mainMenuDidHide {
	[self enableControls:YES];
}

- (void)rightSideViewDidAppear {
	[self enableControls:NO];
}

- (void)rightSideViewWillDismiss {
	[self enableControls:YES];
	[self refreshHeaderView];
	[self reloadTableViewDataSource];
}

- (void)enableControls:(BOOL)enable {
	if (!IS_IPAD) return;
	[self.navigationItem.leftBarButtonItem setEnabled:enable];
	[self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *barButtonItem, NSUInteger idx, BOOL *stop) {
        [barButtonItem setEnabled:enable];
    }];
	[self.sectionHeaderView.tableSegmentButton setTintColor:enable ? nil : SEGMENTED_CONTROL_DISABLED_TINT_COLOR2];
	[self.sectionHeaderView.tableSegmentButton setEnabled:enable];
}

- (void)setupTopWhitePaddingView
{
    _topWhitePaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.0)];
    _topWhitePaddingView.backgroundColor = [UIColor whiteColor];
    _topWhitePaddingView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.tableView addSubview:_topWhitePaddingView];
}

#pragma mark Instruction Related

static NSString *const A3V3InstructionDidShowForBattery = @"A3V3InstructionDidShowForBattery";

- (void)setupInstructionView
{
    if (![[A3UserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForBattery]) {
        [self showInstructionView];
    }
}

- (void)showInstructionView
{
    if (_instructionViewController) {
        return;
    }

	[[A3UserDefaults standardUserDefaults] setBool:YES forKey:A3V3InstructionDidShowForBattery];

    UIStoryboard *instructionStoryBoard = [UIStoryboard storyboardWithName:IS_IPHONE ? A3StoryboardInstruction_iPhone : A3StoryboardInstruction_iPad bundle:nil];
    _instructionViewController = [instructionStoryBoard instantiateViewControllerWithIdentifier:@"BatteryStatus"];
    self.instructionViewController.delegate = self;
    UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets];
    if (safeAreaInsets.top > 20) {
        [self.instructionViewController view];
        self.instructionViewController.batteryTopConstraint.constant = safeAreaInsets.top;
    }
    [self.navigationController.view addSubview:self.instructionViewController.view];
    [self.instructionViewController.view layoutIfNeeded];
    self.instructionViewController.view.frame = self.navigationController.view.frame;
    self.instructionViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
}

- (void)dismissInstructionViewController:(UIView *)view
{
    [self.instructionViewController.view removeFromSuperview];
    self.instructionViewController = nil;
}

#pragma mark -

- (void)reloadTableViewDataSource
{
    if (self.sectionHeaderView.tableSegmentButton.selectedSegmentIndex == 0) {
        _tableDataSourceArray = [A3BatteryStatusManager deviceInfoDataArray];
    } else {
        _tableDataSourceArray = [A3BatteryStatusManager remainTimeDataArray];
        NSArray * adjustedIndex = [A3BatteryStatusManager adjustedIndex];
        if (adjustedIndex) {
            NSMutableArray * array = [NSMutableArray arrayWithCapacity:_tableDataSourceArray.count];
            for (NSDictionary *rowDic in adjustedIndex) {
                NSNumber *index = [rowDic objectForKey:@"index"];
                NSNumber *checked = [rowDic objectForKey:@"checked"];
                
                if ([checked isEqualToNumber:@1] && (index.integerValue < _tableDataSourceArray.count) ) {
                    [array addObject:[_tableDataSourceArray objectAtIndex:index.integerValue]];
                }
            }
            
            _tableDataSourceArray = array;
        }
    }
    if (_didReceiveAds) {
        NSMutableArray *workingArray = [_tableDataSourceArray mutableCopy];
        [workingArray insertObject:@{} atIndex:0];
        _tableDataSourceArray = workingArray;
    }

    [self.tableView reloadData];
}

- (void)batteryThemeChanged {
	[self refreshHeaderView];
}

- (A3BatteryStatusListPageSectionView *)sectionHeaderView {
	if (!_sectionHeaderView) {
		_sectionHeaderView = [[A3BatteryStatusListPageSectionView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 56.0)];
		[_sectionHeaderView.tableSegmentButton addTarget:self action:@selector(sectionSegmentControlChanged:) forControlEvents:UIControlEventValueChanged];
		_sectionHeaderView.tableSegmentButton.selectedSegmentIndex = 0;
	}
	return _sectionHeaderView;
}

- (void)rightBarButton {
    UIImage *image = [UIImage imageNamed:@"general"];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(settingsButtonAction:)];
    
    self.navigationItem.rightBarButtonItems = @[buttonItem, [self instructionHelpBarButton]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (A3BatterStatusBatteryPanelView *)headerView {
	if (!_headerView) {
		CGFloat height;
		if (IS_IPHONE) {
			height = 219.0;
		}
        else {
			if ([UIWindow interfaceOrientationIsLandscape]) {
				height = 275.0;
			} else {
				height = 321.0;
			}
		}

		_headerView = [[A3BatterStatusBatteryPanelView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, height)];
	}
	return _headerView;
}

/*! If you override this method in your custom view controllers, always call super at some point in
 *  your implementation so that UIKit can forward the size change message appropriately. 
 *  View controllers forward the size change message to their views and child view controllers. 
 *  Presentation controllers forward the size change to their presented view controller.
 * \param
 * \returns
 */
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)transitionCoordinator {
	[super viewWillTransitionToSize:size withTransitionCoordinator:transitionCoordinator];

	UIInterfaceOrientation orientation;
	orientation = size.width < size.height ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeLeft;
    if (IS_IPHONE && [UIWindow interfaceOrientationIsLandscape]) {
        [self leftBarButtonAppsButton];
    }
    CGRect rect = self.headerView.frame;
    if (size.width > size.height) {
        rect.size.height = 275.0;
    }
    else {
        rect.size.height = 321.0;
    }
    _headerView.frame = rect;
    [self.tableView setTableHeaderView:_headerView];
    
    [self refreshHeaderView];
}

#pragma mark - Actions

- (void)settingsButtonAction:(id)sender {
	self.settingsViewController = [[A3BatteryStatusSettingViewController alloc] initWithStyle:UITableViewStyleGrouped];

	if (IS_IPHONE) {
		_modalNavigationController = [[UINavigationController alloc] initWithRootViewController:_settingsViewController];
		[self presentViewController:_modalNavigationController animated:YES completion:NULL];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsViewControllerDidDismiss:) name:A3NotificationChildViewControllerDidDismiss object:_settingsViewController];
	} else {
		[[[A3AppDelegate instance] rootViewController_iPad] presentRightSideViewController:_settingsViewController toViewController:nil];
	}
}

- (void)settingsViewControllerDidDismiss:(NSNotification *)notification {
	if (notification.object == _settingsViewController) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationChildViewControllerDidDismiss object:_settingsViewController];
		_modalNavigationController = nil;
		_settingsViewController = nil;
	}
}

#pragma mark - Battery Notifications

- (void)batteryLevelDidChangeNotification:(NSNotification *)notification {
	[self refreshHeaderView];
}

- (void)batteryStateDidChangeNotification:(NSNotification *)notification {
	[self refreshHeaderView];
}

- (void)refreshHeaderView {
	_headerView.batteryColor = [A3BatteryStatusManager chosenTheme];
	[_headerView setBatteryRemainingPercent:fabsf([[UIDevice currentDevice] batteryLevel] * 100) state:[[UIDevice currentDevice] batteryState]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tableDataSourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_didReceiveAds && indexPath.row == 0) {
        return [self bannerHeight];
    }

    if (_sectionHeaderView.tableSegmentButton.selectedSegmentIndex==0) {
        NSString *chips = [_tableDataSourceArray[indexPath.row] objectForKey:@"value"];
        if ([chips rangeOfString:@"\n"].location==NSNotFound) {
            return 44.0;
        } else {
            return 62.0;
        }
    }
    
    return 44.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.sectionHeaderView;
}

static NSString *CellIdentifier = @"Cell";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	A3StandardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[A3StandardTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        ///cell.textLabel.font = IS_IPHONE ? [UIFont fontWithName:cell.textLabel.font.fontName size:15] : [UIFont fontWithName:cell.textLabel.font.fontName size:17];
        //cell.detailTextLabel.font = IS_IPHONE ? [UIFont fontWithName:cell.textLabel.font.fontName size:15] : [UIFont fontWithName:cell.textLabel.font.fontName size:17];
        cell.textLabel.font = IS_IPHONE ? [UIFont systemFontOfSize:15] : [UIFont systemFontOfSize:17];
        cell.detailTextLabel.font = IS_IPHONE ? [UIFont systemFontOfSize:15] : [UIFont systemFontOfSize:17];

        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
        
        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.detailTextLabel.numberOfLines = 0;
    }
	cell.separatorInset = A3UITableViewSeparatorInset;

    if (_didReceiveAds && indexPath.row == 0) {
        cell.textLabel.text = nil;
        cell.detailTextLabel.text = nil;

        UIView *bannerView = [self bannerView];
        [cell addSubview:bannerView];

        [bannerView makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cell).insets(UIEdgeInsetsMake(1, 0, 1, 0));
        }];

        cell.separatorInset = UIEdgeInsetsZero;
        cell.layoutMargins = UIEdgeInsetsZero;
        return cell;
    }

    // Configure the cell...
    NSDictionary *rowData = [_tableDataSourceArray objectAtIndex:indexPath.row];
    cell.textLabel.text = NSLocalizedString([rowData objectForKey:@"title"], nil);

    if (_sectionHeaderView.tableSegmentButton.selectedSegmentIndex==0) {
        cell.detailTextLabel.text = [rowData objectForKey:@"value"];
    }
    else {
        
        if ([[rowData objectForKey:@"title"] isEqualToString:@"Charging time"]) {
            NSInteger maxTime = [[rowData objectForKey:@"value"] integerValue];
            NSInteger remainingMinute = (maxTime*60) * (1.0 - [[UIDevice currentDevice] batteryLevel]);
            long hours = labs(remainingMinute / 60);
            long minutes = labs(remainingMinute % 60);
            if (hours != 0 && minutes != 0) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@",
                                             [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld hours", @"StringsDict", nil), hours],
                                             [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld minutes", @"StringsDict", nil), minutes]];
                
            } else if (hours != 0) {
                cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld hours", @"StringsDict", nil), hours];
            } else {
                cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld minutes", @"StringsDict", nil), minutes];
            }
        }
        else {
            NSInteger maxTime = [[rowData objectForKey:@"value"] integerValue];
            NSInteger remainingMinute = (maxTime*60) * [[UIDevice currentDevice] batteryLevel];
            long hours = labs(remainingMinute / 60);
            long minutes = labs(remainingMinute % 60);
            if (hours != 0 && minutes != 0) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@",
                                             [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld hours", @"StringsDict", nil), hours],
                                             [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld minutes", @"StringsDict", nil), minutes]];
                
            } else if (hours != 0) {
                cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld hours", @"StringsDict", nil), hours];
            } else {
                cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld minutes", @"StringsDict", nil), minutes];
            }
        }
    }
	[cell layoutIfNeeded];
    
    return cell;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_topWhitePaddingView) {
        if (scrollView.contentOffset.y < -scrollView.contentInset.top ) {
            CGRect rect = _topWhitePaddingView.frame;
            rect.origin.y = -(fabs(scrollView.contentOffset.y) - scrollView.contentInset.top);
            rect.size.height = fabs(scrollView.contentOffset.y) - scrollView.contentInset.top;
            _topWhitePaddingView.frame = rect;
        } else {
            CGRect rect = _topWhitePaddingView.frame;
            rect.origin.y = 0.0;
            rect.size.height = 0.0;
            _topWhitePaddingView.frame = rect;
        }
    }
}

#pragma mark - List Page Section

- (void)sectionSegmentControlChanged:(id)sender {
    [self reloadTableViewDataSource];
}

#pragma mark - AdMob

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
    FNLOG(@"%f", bannerView.adSize.size.height);
    
    _didReceiveAds = YES;
    
    [self reloadTableViewDataSource];
}

@end
