//
//  A3HexagonMenuViewController.m
//  HexagonMenu
//
//  Created by Byeong Kwon Kwak on 2/10/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import "common.h"
#import "A3HexagonMenuViewController.h"
#import "A3HexagonCell.h"
#import "A3AppDelegate.h"
#import "A3HexagonCollectionViewFlowLayout.h"
#import "A3AppSelectTableViewController.h"
#import "A3NavigationController.h"
#import "A3UserDefaults.h"
#import "A3InstructionViewController.h"
#import "A3HomeStyleHelpViewController.h"
#import "A3SyncManager.h"
#import "A3UIDevice.h"

@interface A3HexagonMenuViewController () <A3ReorderableLayoutDelegate, A3ReorderableLayoutDataSource,
UICollectionViewDataSource, UICollectionViewDelegate, A3AppSelectViewControllerDelegate,
A3InstructionViewControllerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) A3HexagonCollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UILabel *appTitleLabel;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *menuItems;
@property (nonatomic, strong) NSIndexPath *movingCellOriginalIndexPath;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, copy) NSMutableArray *previousMenuItemsBeforeMovingCell;
@property (nonatomic, strong) NSArray *availableMenuItems;
@property (nonatomic, strong) MASConstraint *appTitleTopConstraint;
@property (nonatomic, strong) A3HomeStyleHelpViewController *instructionViewController;

@end

@implementation A3HexagonMenuViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

	CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	CGFloat horizontalInset = IS_IPHONE ? (screenBounds.size.height <= 568 ? 10 : 15) : 0;
    _flowLayout = [A3HexagonCollectionViewFlowLayout new];
	_flowLayout.delegate = self;
	_flowLayout.dataSource = self;
	_flowLayout.minimumInteritemSpacing = IS_IPHONE ? (screenBounds.size.height <= 568 ? 5 : 6) : IS_IPAD_PRO ? 13 : 10;
	_flowLayout.minimumLineSpacing = IS_IPHONE ? (screenBounds.size.height <= 568 ? 5 : 6) : IS_IPAD_PRO ? 13 : 10;
	_flowLayout.sectionInset = UIEdgeInsetsZero;
	if (IS_IPHONE) {
		CGFloat itemSize;
		itemSize = (screenBounds.size.width - _flowLayout.minimumInteritemSpacing * 7 - horizontalInset * 2) / 6;
		_flowLayout.itemSize = CGSizeMake(itemSize, itemSize * 1.13);
	} else {
		if (IS_IPAD_PRO) {
			_flowLayout.itemSize = CGSizeMake(117, 132);
		} else {
			_flowLayout.itemSize = CGSizeMake(88, 100);
		}
	}

    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:_flowLayout];
	// 42	54	59
	_collectionView.backgroundView = self.backgroundView;
	_collectionView.backgroundView.backgroundColor = [UIColor colorWithRed:42.0/255.0 green:54.0/255.0 blue:59.0/255.0 alpha:1.0];
	
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerClass:[A3HexagonCell class] forCellWithReuseIdentifier:@"HexagonCell"];
    [self.view addSubview:_collectionView];

	[self.collectionView makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.view);
	}];
	
	if ([self.collectionView respondsToSelector:@selector(layoutMargins)]) {
		self.collectionView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuContentsDidChange) name:A3NotificationAppsMainMenuContentsChanged object:nil];

	if (IS_IPHONE_3_5_INCH) {
		_flowLayout.verticalOffset = 40;
	}
    
    _collectionView.scrollEnabled = NO;
}

- (void)mainMenuContentsDidChange {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateShouldShowHouseAds];
        self.collectionView.backgroundView = self.backgroundView;
        self.collectionView.backgroundView.backgroundColor = [UIColor colorWithRed:42.0/255.0 green:54.0/255.0 blue:59.0/255.0 alpha:1.0];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationAppsMainMenuContentsChanged object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	_menuItems = nil;
	
	CGSize contentSize = [_flowLayout collectionViewContentSize];
	if (IS_IPHONE) {
		CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
		CGFloat offset = screenBounds.size.height <= 568 ? 24 : 0;
		if (screenBounds.size.height == 568) {
			offset = 24;
		} else if (screenBounds.size.height == 480) {
			offset = 20;
		} else if (screenBounds.size.height >= 667) {
			offset = 30;
        } else if (screenBounds.size.height == 812 || screenBounds.size.height == 896) {
            contentSize.height += 100;
        }

        FNLOGRECT(self.view.bounds);
        FNLOGRECT(_collectionView.bounds);
		_collectionView.contentInset = UIEdgeInsetsMake((self.view.bounds.size.height - contentSize.height)/2 + offset, 0, (self.view.bounds.size.height - contentSize.height)/2 - offset, 0);
        FNLOG(@"%f", _collectionView.contentInset.top + _collectionView.contentInset.bottom + contentSize.height);
        FNLOGINSETS(_collectionView.contentInset);
	} else {
		CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
		[self setupCollectionViewContentInsetWithSize:screenBounds.size];
	}
	[self.collectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[self setupInstructionView];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.menuItems count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    UICollectionViewFlowLayout *flowLayout = collectionView.collectionViewLayout;
//    FNLOG(@"%f, %f", flowLayout.itemSize.width, flowLayout.itemSize.height);
//	FNLOG(@"%f", flowLayout.minimumInteritemSpacing);
//	FNLOG(@"%f", flowLayout.minimumLineSpacing);
	A3HexagonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HexagonCell" forIndexPath:indexPath];
	cell.enabled = [[self availableMenuItems] count] > 0;

	NSDictionary *menuInfo = self.menuItems[indexPath.row];
	NSDictionary *appInfo = [[A3AppDelegate instance] appInfoDictionary][menuInfo[kA3AppsMenuName]];
	cell.borderColor = [A3AppDelegate instance].groupColors[appInfo[kA3AppsGroupName]];
	NSString *imageName = [[A3AppDelegate instance] imageNameForApp:menuInfo[kA3AppsMenuName]];
	if (IS_IPAD) {
		imageName = [imageName stringByAppendingString:@"_Large"];
	}
	cell.imageName = imageName;

	return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	self.appTitleLabel.text = @"";

	NSDictionary *menuInfo = self.menuItems[indexPath.row];
	if ([menuInfo[kA3AppsMenuName] isEqualToString:A3AppName_None] && [[self availableMenuItems] count] > 0) {
		_selectedIndexPath = indexPath;

		A3AppSelectTableViewController *viewController = [[A3AppSelectTableViewController alloc] initWithArray:[self availableMenuItems]];
		viewController.delegate = self;
		A3NavigationController *navigationController = [[A3NavigationController alloc] initWithRootViewController:viewController];
		[self presentViewController:navigationController animated:YES completion:nil];
	} else {
		if (![[A3AppDelegate instance] launchAppNamed:menuInfo[kA3AppsMenuName] verifyPasscode:YES animated:YES]) {
			self.selectedAppName = [menuInfo[kA3AppsMenuName] copy];
		} else {
			[[A3AppDelegate instance] updateRecentlyUsedAppsWithAppName:menuInfo[kA3AppsMenuName]];
			self.activeAppName = [menuInfo[kA3AppsMenuName] copy];
		}
	}
}

- (void)viewController:(UIViewController *)viewController didSelectAppNamed:(NSString *)appName {
	[self.menuItems replaceObjectAtIndex:_selectedIndexPath.row withObject:@{kA3AppsMenuName:appName}];
	_availableMenuItems = nil;
	[self.collectionView reloadItemsAtIndexPaths:@[_selectedIndexPath]];

	[[NSUserDefaults standardUserDefaults] setObject:_menuItems forKey:A3MainMenuHexagonMenuItems];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    FNLOGRECT(_collectionView.bounds);
    FNLOGINSETS(_collectionView.contentInset);
}

#pragma mark - A3CollectionViewFlowLayoutDelegate

- (void)collectionView:(UICollectionView *)collectionView layout:(A3CollectionViewFlowLayout *)collectionViewLayout willTouchesBeginItemAtIndexPath:(NSIndexPath *)indexPath {
	[self setAppTitleTextAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {
	NSDictionary *menuInfo = self.menuItems[fromIndexPath.row];
	if ([menuInfo[kA3AppsMenuName] isEqualToString:A3AppName_None]) return;
	
	NSDictionary *appInfo = [[A3AppDelegate instance] appInfoDictionary][menuInfo[kA3AppsMenuName]];
	[_flowLayout insertDeleteZoneToView:self.collectionView.backgroundView];
	_flowLayout.deleteZoneView.backgroundColor = [A3AppDelegate instance].groupColors[appInfo[kA3AppsGroupName]];
	[_flowLayout.deleteZoneView setHidden:NO];
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
	_movingCellOriginalIndexPath = [indexPath copy];
	_previousMenuItemsBeforeMovingCell = [[self menuItems] copy];

	[self setAppTitleTextAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView layout:(A3CollectionViewFlowLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *menuInfo = self.menuItems[indexPath.row];
	if ([menuInfo[kA3AppsMenuName] isEqualToString:A3AppName_None]) return;
	
	double delayInSeconds = 0.3;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		NSDictionary *appInfo = [[A3AppDelegate instance] appInfoDictionary][menuInfo[kA3AppsMenuName]];
		[collectionViewLayout insertDeleteZoneToView:self.collectionView.backgroundView];
		collectionViewLayout.deleteZoneView.backgroundColor = [A3AppDelegate instance].groupColors[appInfo[kA3AppsGroupName]];
		[collectionViewLayout.deleteZoneView setHidden:NO];
	});
}

- (void)collectionView:(UICollectionView *)collectionView layout:(A3CollectionViewFlowLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
	self.appTitleLabel.text = @"";
	[collectionViewLayout.deleteZoneView setHidden:YES];
	double delayInSeconds = 0.3;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[collectionViewLayout.deleteZoneView setHidden:YES];
	});
	
	_previousMenuItemsBeforeMovingCell = nil;
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath {
	NSMutableArray *menuItems = self.menuItems;
	NSDictionary *menuItem = menuItems[fromIndexPath.row];
	[menuItems removeObjectAtIndex:fromIndexPath.row];
	[menuItems insertObject:menuItem atIndex:toIndexPath.row];
	
	[[NSUserDefaults standardUserDefaults] setObject:_menuItems forKey:A3MainMenuHexagonMenuItems];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)collectionView:(UICollectionView *)collectionView layout:(A3CollectionViewFlowLayout *)collectionViewLayout didSelectDeleteAtIndexPath:(NSIndexPath *)indexPath {
	_menuItems = [_previousMenuItemsBeforeMovingCell mutableCopy];
	[_menuItems replaceObjectAtIndex:_movingCellOriginalIndexPath.row withObject:@{kA3AppsMenuName:A3AppName_None}];
	_availableMenuItems = nil;

	[collectionViewLayout removeCellFakeView:^{
		[self.collectionView reloadItemsAtIndexPaths:@[_movingCellOriginalIndexPath]];
	}];

	[[NSUserDefaults standardUserDefaults] setObject:_menuItems forKey:A3MainMenuHexagonMenuItems];
	[[NSUserDefaults standardUserDefaults] synchronize];

	[self.collectionView reloadData];
	
	return NO;
}

- (void)setAppTitleTextAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *menuInfo = self.menuItems[indexPath.row];
	if ([menuInfo[kA3AppsMenuName] isEqualToString:A3AppName_None]) return;

	NSDictionary *appInfo = [[A3AppDelegate instance] appInfoDictionary][menuInfo[kA3AppsMenuName]];
	self.appTitleLabel.text = NSLocalizedString(menuInfo[kA3AppsMenuName], nil);
	self.appTitleLabel.textColor = [A3AppDelegate instance].groupColors[appInfo[kA3AppsGroupName]];
}

- (UILabel *)appTitleLabel {
	if (!_appTitleLabel) {
		_appTitleLabel = [UILabel new];
		_appTitleLabel.font = [UIFont systemFontOfSize:31];

		[_collectionView.backgroundView addSubview:_appTitleLabel];

		UIView *superview = _collectionView.backgroundView;
		[_appTitleLabel makeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(superview.centerX);
			CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
			_appTitleTopConstraint =  make.top.equalTo(superview.top).with.offset(screenBounds.size.height * ([UIWindow interfaceOrientationIsPortrait] ? 0.15 : 0.11));
		}];
	}
	return _appTitleLabel;
}

- (NSArray *)originalMenuItems {
	if (IS_IPHONE) {
	return @[
			 @{kA3AppsMenuName:A3AppName_Abbreviation},
			 @{kA3AppsMenuName:A3AppName_Kaomoji},
			 @{kA3AppsMenuName:A3AppName_Magnifier},
			 @{kA3AppsMenuName:A3AppName_Random},
			 @{kA3AppsMenuName:A3AppName_Clock},
			 @{kA3AppsMenuName:A3AppName_Calculator},
			 @{kA3AppsMenuName:A3AppName_Ruler},
			 @{kA3AppsMenuName:A3AppName_Level},
			 @{kA3AppsMenuName:A3AppName_BatteryStatus},
			 @{kA3AppsMenuName:A3AppName_DaysCounter},
			 @{kA3AppsMenuName:A3AppName_DateCalculator},
			 @{kA3AppsMenuName:A3AppName_Flashlight},
			 @{kA3AppsMenuName:A3AppName_Mirror},
			 @{kA3AppsMenuName:A3AppName_Holidays},
			 @{kA3AppsMenuName:A3AppName_ExpenseList},
			 @{kA3AppsMenuName:A3AppName_LoanCalculator},
			 @{kA3AppsMenuName:A3AppName_PercentCalculator},
			 @{kA3AppsMenuName:A3AppName_CurrencyConverter},
			 @{kA3AppsMenuName:A3AppName_UnitConverter},
			 @{kA3AppsMenuName:A3AppName_LadiesCalendar},
			 @{kA3AppsMenuName:A3AppName_TipCalculator},
			 @{kA3AppsMenuName:A3AppName_SalesCalculator},
			 @{kA3AppsMenuName:A3AppName_Translator},
			 @{kA3AppsMenuName:A3AppName_LunarConverter},
			 @{kA3AppsMenuName:A3AppName_Wallet},
			 @{kA3AppsMenuName:A3AppName_UnitPrice},
			 @{kA3AppsMenuName:A3AppName_QRCode},
			 @{kA3AppsMenuName:A3AppName_Pedometer},
			 ];
	} else {
		return @[
				 @{kA3AppsMenuName:A3AppName_Abbreviation},
				 @{kA3AppsMenuName:A3AppName_Kaomoji},
				 @{kA3AppsMenuName:A3AppName_Magnifier},
				 @{kA3AppsMenuName:A3AppName_Random},
				 @{kA3AppsMenuName:A3AppName_Clock},
				 @{kA3AppsMenuName:A3AppName_Calculator},
				 @{kA3AppsMenuName:A3AppName_Ruler},
				 @{kA3AppsMenuName:A3AppName_QRCode},
				 @{kA3AppsMenuName:A3AppName_BatteryStatus},
				 @{kA3AppsMenuName:A3AppName_DaysCounter},
				 @{kA3AppsMenuName:A3AppName_DateCalculator},
				 @{kA3AppsMenuName:A3AppName_Flashlight},
				 @{kA3AppsMenuName:A3AppName_Mirror},
				 @{kA3AppsMenuName:A3AppName_Holidays},
				 @{kA3AppsMenuName:A3AppName_ExpenseList},
				 @{kA3AppsMenuName:A3AppName_LoanCalculator},
				 @{kA3AppsMenuName:A3AppName_PercentCalculator},
				 @{kA3AppsMenuName:A3AppName_CurrencyConverter},
				 @{kA3AppsMenuName:A3AppName_UnitConverter},
				 @{kA3AppsMenuName:A3AppName_LadiesCalendar},
				 @{kA3AppsMenuName:A3AppName_TipCalculator},
				 @{kA3AppsMenuName:A3AppName_SalesCalculator},
				 @{kA3AppsMenuName:A3AppName_Translator},
				 @{kA3AppsMenuName:A3AppName_LunarConverter},
				 @{kA3AppsMenuName:A3AppName_Wallet},
				 @{kA3AppsMenuName:A3AppName_UnitPrice},
				 @{kA3AppsMenuName:A3AppName_Pedometer},
				 ];
	}
}

- (NSMutableArray *)menuItems {
	if (!_menuItems) {
		_menuItems = [[[NSUserDefaults standardUserDefaults] objectForKey:A3MainMenuHexagonMenuItems] mutableCopy];
		if (!_menuItems) {
			_menuItems = [[self originalMenuItems] mutableCopy];
		}
		BOOL isStepCountingAvailable = [CMPedometer isStepCountingAvailable];
#if TARGET_IPHONE_SIMULATOR
		if (IS_IPAD) {
			[_menuItems removeObject:@{kA3AppsMenuName:A3AppName_Pedometer}];
		}
#else
		if (!isStepCountingAvailable) {
			[_menuItems removeObject:@{kA3AppsMenuName:A3AppName_Pedometer}];
		}
#endif
		if ([[NSUserDefaults standardUserDefaults] boolForKey:A3SettingsMainMenuHexagonShouldAddQRCodeMenu]) {
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:A3SettingsMainMenuHexagonShouldAddQRCodeMenu];

			if (IS_IPAD && [_menuItems count] == 24) {
				NSInteger indexOfEmptyMenu = [_menuItems indexOfObject:@{kA3AppsMenuName:A3AppName_None}];
				if (indexOfEmptyMenu != NSNotFound) {
					[_menuItems replaceObjectAtIndex:indexOfEmptyMenu withObject:@{kA3AppsMenuName:A3AppName_QRCode}];
				}
			}
			if (([_menuItems count] == 24) && [_menuItems indexOfObject:@{kA3AppsMenuName:A3AppName_QRCode}] == NSNotFound) {
				[_menuItems addObject:@{kA3AppsMenuName:A3AppName_QRCode}];
			}
			
			[[NSUserDefaults standardUserDefaults] setObject:_menuItems forKey:A3MainMenuHexagonMenuItems];
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:A3SettingsMainMenuHexagonShouldAddPedometerMenu]) {
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:A3SettingsMainMenuHexagonShouldAddPedometerMenu];

			if (isStepCountingAvailable) {
				if ([_menuItems indexOfObject:@{kA3AppsMenuName:A3AppName_Pedometer}] == NSNotFound) {
					[_menuItems addObject:@{kA3AppsMenuName:A3AppName_Pedometer}];
				}

				[[NSUserDefaults standardUserDefaults] setObject:_menuItems forKey:A3MainMenuHexagonMenuItems];
			}
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:A3SettingsMainMenuHexagonShouldAddAbbreviationMenu]) {
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:A3SettingsMainMenuHexagonShouldAddAbbreviationMenu];

			NSDictionary *menuItem = @{kA3AppsMenuName:A3AppName_Abbreviation};
			if ([_menuItems indexOfObject:menuItem] == NSNotFound) {
				[_menuItems insertObject:menuItem atIndex:0];
				[_menuItems insertObject:@{kA3AppsMenuName:A3AppName_Kaomoji} atIndex:1];
			}

			[[NSUserDefaults standardUserDefaults] setObject:_menuItems forKey:A3MainMenuHexagonMenuItems];
		}
		FNLOG(@"%@", _menuItems);
	}
	return _menuItems;
}

- (NSArray *)availableMenuItems {
	if (!_availableMenuItems) {
		NSMutableArray *availableMenuItems = [[self originalMenuItems] mutableCopy];
		[availableMenuItems removeObjectsInArray:[self menuItems]];
		if (IS_IPAD) {
			[availableMenuItems removeObject:@{kA3AppsMenuName:A3AppName_Level}];
		}
		_availableMenuItems = availableMenuItems;
	}
	return _availableMenuItems;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

	[self setupCollectionViewContentInsetWithSize:size];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

	FNLOGRECT(self.view.bounds);
	[self setupCollectionViewContentInsetWithSize:self.view.bounds.size];
}

- (void)setupCollectionViewContentInsetWithSize:(CGSize)size {
	CGSize contentSize = [_flowLayout collectionViewContentSize];
	if (IS_IPAD_PRO) {
		CGFloat offset = 40;
		if (size.width < size.height) {
			offset = 100;
		} else {
			offset = 40;
		}
		_collectionView.contentInset = UIEdgeInsetsMake((size.height - contentSize.height)/2 + offset, 0, (size.height - contentSize.height)/2 - offset, 0);
	} else if (IS_IPAD) {
		CGFloat offset = 40;
		if (size.width < size.height) {
			offset = 80;
		} else {
			offset = 40;
		}
		_collectionView.contentInset = UIEdgeInsetsMake((size.height - contentSize.height)/2 + offset, 0, (size.height - contentSize.height)/2 - offset, 0);
	}
	_appTitleTopConstraint.offset = size.height * (size.width < size.height ? 0.2 : 0.13);
	
    FNLOGRECT(_collectionView.bounds);

	[self adjustFingerCenter];
}

#pragma mark - Instruction View

static NSString *const A3V3InstructionDidShowForHexagonMenu = @"A3V3InstructionDidShowForHexagonMenu";

- (void)setupInstructionView
{
	if (![[A3UserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForHexagonMenu]) {
		[self showInstructionView];
	}
}

- (void)showInstructionView
{
	if (_instructionViewController) {
		return;
	}
	
	[[A3UserDefaults standardUserDefaults] setBool:YES forKey:A3V3InstructionDidShowForHexagonMenu];
	
	UIStoryboard *instructionStoryBoard = [UIStoryboard storyboardWithName:IS_IPHONE ? A3StoryboardInstruction_iPhone : A3StoryboardInstruction_iPad bundle:nil];
	_instructionViewController = [instructionStoryBoard instantiateViewControllerWithIdentifier:@"HomeStyle"];
	[_instructionViewController view];
	[self adjustFingerCenter];
	self.instructionViewController.delegate = self;
	[self.navigationController.view addSubview:self.instructionViewController.view];
	self.instructionViewController.view.frame = self.navigationController.view.frame;
	self.instructionViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
}

- (void)dismissInstructionViewController:(UIView *)view
{
	[self.instructionViewController.view removeFromSuperview];
	self.instructionViewController = nil;
}

- (void)helpButtonAction:(id)sender {
	[self showInstructionView];
}

- (void)applicationDidEnterBackground {
	[self dismissInstructionViewController:nil];
}

- (void)adjustFingerCenter {
	if (!_instructionViewController) return;
	
	UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:10 inSection:0]];
	CGPoint centerInView = [self.view convertPoint:cell.center fromView:self.collectionView];
	FNLOG(@"centerX = %f, centerY = %f", centerInView.x, centerInView.y);
	FNLOGRECT(cell.frame);
	_instructionViewController.fingerUpCenterXConstraint.constant = centerInView.x;
	_instructionViewController.fingerUpCenterYConstraint.constant = centerInView.y + 6;
	[_instructionViewController.view layoutIfNeeded];
	
	NSStringDrawingContext *context = [NSStringDrawingContext new];
	CGRect textBounds = [_instructionViewController.helpLabel.text boundingRectWithSize:CGSizeMake(_instructionViewController.helpLabel.bounds.size.width, CGFLOAT_MAX)
																				 options:NSStringDrawingUsesLineFragmentOrigin
																			  attributes:@{NSFontAttributeName:_instructionViewController.helpLabel.font}
																				 context:context];
	_instructionViewController.helpTextHeightConstraint.constant = textBounds.size.height + 2;
	[_instructionViewController.view layoutIfNeeded];
}

@end
