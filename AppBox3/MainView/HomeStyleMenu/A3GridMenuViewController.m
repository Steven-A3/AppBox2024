//
//  A3GridMenuViewController.m
//  HexagonMenu
//
//  Created by Byeong Kwon Kwak on 2/20/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import "common.h"
#import "A3GridMenuViewController.h"
#import "A3AppDelegate.h"
#import "A3GridMenuCollectionViewCell.h"
#import "A3GridCollectionViewFlowLayout.h"
#import "UIView+SBExtras.h"
#import "A3AppSelectTableViewController.h"
#import "A3NavigationController.h"
#import "A3UserDefaults.h"
#import "A3HomeStyleHelpViewController.h"
#import "A3InstructionViewController.h"
#import "A3SyncManager.h"
#import "A3UIDevice.h"

NSString *const A3GridMenuCellID = @"gridCell";

@interface A3GridMenuViewController () <UICollectionViewDelegate, UICollectionViewDataSource,
A3ReorderableLayoutDelegate, A3ReorderableLayoutDataSource, A3AppSelectViewControllerDelegate,
A3InstructionViewControllerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) A3GridCollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) NSMutableArray *menuItems;
@property (nonatomic, strong) NSArray *availableMenuItems;

/**
 *  앱을 삭제하는 경우에 원래 있던 자리에서 삭제가 되도록 하기 위해서, 드래그를 시작하면 시작전 상태를 저장해 둡니다.
 *  드래그를 시작하기 전 상태와 최초 선택된 indexPath를 기록해 두었다가, 삭제 행위가 발생하면, 
 *  드래그 시작전 상태에서 선택된 메뉴를 삭제하도록 합니다.
 */
@property (nonatomic, copy) NSIndexPath *movingCellOriginalIndexPath;
@property (nonatomic, copy) NSArray *previousMenuItemsBeforeMovingCell;

/**
 *  삭제된 App이 있는 경우, 앱을 추가할 수 있습니다.
 *  삭제된 앱이 있는 경우, 마지막 아이템 한개는 "+" 아이콘이 됩니다.
 *  이것을 선택한 경우, 앱을 추가할 수 있으며, 앱을 추가하는 뷰 컨트롤러가 표시될때 선택된 indexPath를 기억합니다.
 */
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) A3HomeStyleHelpViewController *instructionViewController;
@property (nonatomic, assign) NSInteger pageBeforeViewDisappear;

@end

@implementation A3GridMenuViewController {
    NSInteger _itemsPerPage;
	NSInteger _pageBeforeViewDisappear;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _itemsPerPage = 16;
	[self setupCollectionView];
	[self setupPageControl];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuContentsDidChange) name:A3NotificationAppsMainMenuContentsChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)mainMenuContentsDidChange {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateShouldShowHouseAds];
        
        [self setupContentHeightWithSize:self.view.bounds.size];
        self.collectionView.backgroundView = self.backgroundView;
        [self.collectionView reloadData];
        [self layoutPageControl];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationAppsMainMenuContentsChanged object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	_menuItems = nil;
	[self.collectionView reloadData];

	dispatch_async(dispatch_get_main_queue(), ^{
		self.pageControl.currentPage = self.pageBeforeViewDisappear;
		[self pageControlValueChanged:self.pageControl];
	});
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

    [self setupInstructionView];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	_pageBeforeViewDisappear = _pageControl.currentPage;
	
	if (_instructionViewController && _instructionViewController.view.superview) {
		[[A3UserDefaults standardUserDefaults] setBool:NO forKey:A3V3InstructionDidShowForGridMenu];
		[self dismissInstructionViewController:nil];
	}
}

- (void)applicationDidBecomeActive {
    [self mainMenuContentsDidChange];
    [self setupInstructionView];
}

- (void)setupCollectionView {
	UIView *superview = self.view;
	[superview addSubview:self.collectionView];

    [self.collectionView makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(superview);
    }];
	
    self.view.backgroundColor = [UIColor colorWithRed:56.0/255.0 green:63.0/255.0 blue:74.0/255.0 alpha:1.0];
    self.collectionView.backgroundColor = [UIColor colorWithRed:56.0/255.0 green:63.0/255.0 blue:74.0/255.0 alpha:1.0];
	self.collectionView.backgroundView = [self backgroundView];

	[self setupContentHeightWithSize:[A3UIDevice screenBoundsAdjustedWithOrientation].size];
}

- (void)setupPageControl {
    UIEdgeInsets safeAreaInsets = [[UIApplication sharedApplication] keyWindow].safeAreaInsets;
    FNLOG(@"%@, %f, %f, %f", [A3UIDevice deviceInformationDictionary][@"Model"], safeAreaInsets.top, safeAreaInsets.bottom, safeAreaInsets.left);

    if (_pageControl == nil) {
        _pageControl = [UIPageControl new];
        [_pageControl addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:_pageControl];
    }
    NSInteger numberOfItemsPerPage = _flowLayout.numberOfItemsPerRow * _flowLayout.numberOfRowsPerPage;
	_pageControl.numberOfPages = [self.menuItems count] / numberOfItemsPerPage + 1;
	_pageControl.currentPage = 0;

    __weak __typeof__(self) weakSelf = self;
	[_pageControl makeConstraints:^(MASConstraintMaker *make) {
        __typeof__(self) strongSelf = weakSelf;
        
		CGFloat offset;
        offset = -(strongSelf.collectionView.contentInset.bottom - 20);
		make.bottom.equalTo(strongSelf.view.bottom).with.offset(offset);
		make.centerX.equalTo(strongSelf.collectionView.centerX);
	}];
	[self updatePageControl];
}

- (void)layoutPageControl {
    [self updatePageControl];
    
    __weak __typeof__(self) weakSelf = self;
    [_pageControl remakeConstraints:^(MASConstraintMaker *make) {
        __typeof__(self) strongSelf = weakSelf;
        
        CGFloat offset;
        offset = -(strongSelf.collectionView.contentInset.bottom - 20);
        make.bottom.equalTo(strongSelf.view.bottom).with.offset(offset);
        make.centerX.equalTo(strongSelf.collectionView.centerX);
    }];
}

- (void)updatePageControl {
    NSInteger numberOfItemsPerPage = _flowLayout.numberOfItemsPerRow * _flowLayout.numberOfRowsPerPage;
    if (numberOfItemsPerPage == 0) numberOfItemsPerPage = 20;
    
	_pageControl.numberOfPages = ([self.menuItems count] - 1) / numberOfItemsPerPage + 1;
	[_pageControl setHidden:_pageControl.numberOfPages == 1];
}

- (void)pageControlValueChanged:(UIPageControl *)pageControl {
	CGPoint offset = self.collectionView.contentOffset;
	offset = CGPointMake(pageControl.currentPage * self.collectionView.bounds.size.width, offset.y);
	[self.collectionView setContentOffset:offset animated:YES];
}

- (A3GridCollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [A3GridCollectionViewFlowLayout new];
		CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
		if (IS_IPHONE) {
			if ([[UIScreen mainScreen] scale] == 3) {
                if (screenBounds.size.height == 693) {
                    _flowLayout.itemSize = CGSizeMake(70.0, 88.0);
                } else if (screenBounds.size.width == 320) {
                    _flowLayout.itemSize = CGSizeMake(70.0, 93.0);
                } else {
                    _flowLayout.itemSize = CGSizeMake(78.0, 102.0);
                }
			} else {
                if (screenBounds.size.height == 667) // iPhone SE 3rd
                {
                    _flowLayout.itemSize = CGSizeMake(70.0, 94.0);
                } else if (screenBounds.size.height >= 647) {
                    _flowLayout.itemSize = CGSizeMake(70.0, 85.0);
				} else if (screenBounds.size.height == 568) {
					_flowLayout.itemSize = CGSizeMake(60.0, 78.0);
				} else {
					_flowLayout.itemSize = CGSizeMake(50.0, 65.0);
				}
			}
		} else {
			if (IS_IPAD_PRO) {
				_flowLayout.itemSize = CGSizeMake(100.0, 132.0);
			} else {
				_flowLayout.itemSize = CGSizeMake(76.0, 100.0);
			}
		}
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
		_flowLayout.delegate = self;
		_flowLayout.dataSource = self;
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
	if (!_collectionView) {
		_collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
		_collectionView.delegate = self;
		_collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
		_collectionView.showsVerticalScrollIndicator = NO;
		_collectionView.showsHorizontalScrollIndicator = NO;
		[_collectionView registerClass:[A3GridMenuCollectionViewCell class] forCellWithReuseIdentifier:A3GridMenuCellID];
	}
    return _collectionView;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [self.menuItems count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    A3GridMenuCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:A3GridMenuCellID forIndexPath:indexPath];

	NSDictionary *menuInfo = self.menuItems[indexPath.row];
	NSDictionary *appInfo = [[A3AppDelegate instance] appInfoDictionary][menuInfo[kA3AppsMenuName]];
    if (![[A3UserDefaults standardUserDefaults] boolForKey:kA3AppsUseGrayIconsOnGridMenu]) {
        cell.borderColor = [A3AppDelegate instance].groupColors[appInfo[kA3AppsGroupName]];
    }

    if ([menuInfo[kA3AppsMenuName] isEqualToString:A3AppName_None]) {
		cell.imageName = @"add01";
		cell.titleLabel.text = @"Add";
	} else {
		NSString *imageName = appInfo[kA3AppsMenuImageName];
		CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
		if (screenBounds.size.height > 568) {
			imageName = [imageName stringByAppendingString:@"_Large"];
		}
		cell.imageName = imageName;
		cell.titleLabel.text = NSLocalizedString(appInfo[kA3AppsMenuNameForGrid], nil);
	}

    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *menuInfo = self.menuItems[indexPath.row];
	if ([menuInfo[kA3AppsMenuName] isEqualToString:A3AppName_None]) {
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
	[_menuItems insertObject:@{kA3AppsMenuName:appName} atIndex:_selectedIndexPath.row];
	_availableMenuItems = nil;

	if (![[self availableMenuItems] count]) {
		[_menuItems removeObject:@{kA3AppsMenuName : A3AppName_None}];
	}

	[[NSUserDefaults standardUserDefaults] setObject:_menuItems forKey:A3MainMenuGridMenuItems];
	[[NSUserDefaults standardUserDefaults] synchronize];

	[self updatePageControl];
	[self.collectionView reloadData];
}

#pragma mark - A3CollectionViewFlowLayoutDelegate

- (void)collectionView:(UICollectionView *)collectionView layout:(A3CollectionViewFlowLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
	_movingCellOriginalIndexPath = [indexPath copy];
	_previousMenuItemsBeforeMovingCell = [[self menuItems] copy];
}

- (void)collectionView:(UICollectionView *)collectionView layout:(A3CollectionViewFlowLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *menuInfo = _menuItems[indexPath.row];
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
	[collectionViewLayout.deleteZoneView setHidden:YES];

	double delayInSeconds = 0.3;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[collectionViewLayout.deleteZoneView setHidden:YES];
	});
	_previousMenuItemsBeforeMovingCell = nil;
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath {
	NSDictionary *menuItem = _menuItems[fromIndexPath.row];
	[_menuItems removeObjectAtIndex:fromIndexPath.row];
	[_menuItems insertObject:menuItem atIndex:toIndexPath.row];

	[[NSUserDefaults standardUserDefaults] setObject:_menuItems forKey:A3MainMenuGridMenuItems];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)collectionView:(UICollectionView *)collectionView layout:(A3CollectionViewFlowLayout *)collectionViewLayout didSelectDeleteAtIndexPath:(NSIndexPath *)indexPath {
	_menuItems = [_previousMenuItemsBeforeMovingCell mutableCopy];

	[_menuItems removeObjectAtIndex:_movingCellOriginalIndexPath.row];
	_availableMenuItems = nil;
	
	[collectionViewLayout removeCellFakeView:nil];

	if ([_menuItems indexOfObject:@{kA3AppsMenuName : A3AppName_None}] == NSNotFound) {
		[_menuItems addObject:@{kA3AppsMenuName : A3AppName_None}];
	}

	[_collectionView setCollectionViewLayout:_flowLayout];
	[self.collectionView reloadData];
	[self updatePageControl];
	
	[[NSUserDefaults standardUserDefaults] setObject:_menuItems forKey:A3MainMenuGridMenuItems];
	[[NSUserDefaults standardUserDefaults] synchronize];
	return NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	_pageControl.currentPage = scrollView.contentOffset.x / scrollView.bounds.size.width;
}

- (NSArray *)originalMenuItems {
	if (IS_IPAD) {
		return @[
				 @{kA3AppsMenuName:A3AppName_Abbreviation},
				 @{kA3AppsMenuName:A3AppName_Kaomoji},
				 @{kA3AppsMenuName:A3AppName_Pedometer},
				 @{kA3AppsMenuName:A3AppName_QRCode},
				 @{kA3AppsMenuName:A3AppName_BatteryStatus},
				 @{kA3AppsMenuName:A3AppName_CurrencyConverter},
				 @{kA3AppsMenuName:A3AppName_LoanCalculator},
				 @{kA3AppsMenuName:A3AppName_Wallet},
				 @{kA3AppsMenuName:A3AppName_Clock},
				 @{kA3AppsMenuName:A3AppName_UnitConverter},
				 @{kA3AppsMenuName:A3AppName_Calculator},
				 @{kA3AppsMenuName:A3AppName_LadiesCalendar},
				 @{kA3AppsMenuName:A3AppName_Mirror},
				 @{kA3AppsMenuName:A3AppName_Translator},
				 @{kA3AppsMenuName:A3AppName_TipCalculator},
				 @{kA3AppsMenuName:A3AppName_DaysCounter},
				 @{kA3AppsMenuName:A3AppName_Ruler},
				 @{kA3AppsMenuName:A3AppName_Holidays},
				 @{kA3AppsMenuName:A3AppName_DateCalculator},
				 @{kA3AppsMenuName:A3AppName_ExpenseList},
				 @{kA3AppsMenuName:A3AppName_Flashlight},
				 @{kA3AppsMenuName:A3AppName_Magnifier},
				 @{kA3AppsMenuName:A3AppName_Random},
				 @{kA3AppsMenuName:A3AppName_SalesCalculator},
				 @{kA3AppsMenuName:A3AppName_UnitPrice},
				 @{kA3AppsMenuName:A3AppName_PercentCalculator},
				 @{kA3AppsMenuName:A3AppName_LunarConverter},
				 ];
	} else {
		return @[
				 @{kA3AppsMenuName:A3AppName_Abbreviation},
				 @{kA3AppsMenuName:A3AppName_Kaomoji},
				 @{kA3AppsMenuName:A3AppName_Pedometer},
				 @{kA3AppsMenuName:A3AppName_QRCode},
				 @{kA3AppsMenuName:A3AppName_Level},
				 @{kA3AppsMenuName:A3AppName_CurrencyConverter},
				 @{kA3AppsMenuName:A3AppName_LoanCalculator},
				 @{kA3AppsMenuName:A3AppName_Wallet},
				 @{kA3AppsMenuName:A3AppName_Ruler},
				 @{kA3AppsMenuName:A3AppName_UnitConverter},
				 @{kA3AppsMenuName:A3AppName_Calculator},
				 @{kA3AppsMenuName:A3AppName_LadiesCalendar},
				 @{kA3AppsMenuName:A3AppName_BatteryStatus},
				 @{kA3AppsMenuName:A3AppName_Translator},
				 @{kA3AppsMenuName:A3AppName_TipCalculator},
				 @{kA3AppsMenuName:A3AppName_DaysCounter},
				 @{kA3AppsMenuName:A3AppName_Clock},
				 @{kA3AppsMenuName:A3AppName_Holidays},
				 @{kA3AppsMenuName:A3AppName_DateCalculator},
				 @{kA3AppsMenuName:A3AppName_ExpenseList},
				 @{kA3AppsMenuName:A3AppName_Flashlight},
				 @{kA3AppsMenuName:A3AppName_Mirror},
				 @{kA3AppsMenuName:A3AppName_Magnifier},
				 @{kA3AppsMenuName:A3AppName_Random},
				 @{kA3AppsMenuName:A3AppName_SalesCalculator},
				 @{kA3AppsMenuName:A3AppName_UnitPrice},
				 @{kA3AppsMenuName:A3AppName_PercentCalculator},
				 @{kA3AppsMenuName:A3AppName_LunarConverter},
				 ];
	}
}

- (NSMutableArray *)menuItems {
	if (!_menuItems) {
		_menuItems = [[[NSUserDefaults standardUserDefaults] objectForKey:A3MainMenuGridMenuItems] mutableCopy];
		if (!_menuItems) {
			_menuItems = [[self originalMenuItems] mutableCopy];
		}
		BOOL isStepCountingAvailable = [CMPedometer isStepCountingAvailable];
		FNLOG(@"%@", @([CMPedometer isStepCountingAvailable]));
		if (IS_IPAD) {
			[_menuItems removeObject:@{kA3AppsMenuName:A3AppName_Level}];
		}
#if TARGET_IPHONE_SIMULATOR
		if (IS_IPAD) {
			[_menuItems removeObject:@{kA3AppsMenuName:A3AppName_Pedometer}];
		}
#else
		if (!isStepCountingAvailable) {
			[_menuItems removeObject:@{kA3AppsMenuName:A3AppName_Pedometer}];
		}
#endif

		// NEW_APP: 새앱이 추가되면 수정되어야 하는 영역
		if ([[NSUserDefaults standardUserDefaults] boolForKey:A3SettingsMainMenuGridShouldAddQRCodeMenu]) {
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:A3SettingsMainMenuGridShouldAddQRCodeMenu];
			
			NSDictionary *qrcodeMenu = @{kA3AppsMenuName : A3AppName_QRCode};
			NSInteger qrcodeIndex = [_menuItems indexOfObject:qrcodeMenu];
			if (qrcodeIndex == NSNotFound) {
				[_menuItems insertObject:qrcodeMenu atIndex:0];
			}
			[[NSUserDefaults standardUserDefaults] setObject:_menuItems forKey:A3MainMenuGridMenuItems];
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:A3SettingsMainMenuGridShouldAddPedometerMenu]) {
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:A3SettingsMainMenuGridShouldAddPedometerMenu];

			if (isStepCountingAvailable) {
				NSDictionary *pedometerMenu = @{kA3AppsMenuName : A3AppName_Pedometer};
				NSInteger qrcodeIndex = [_menuItems indexOfObject:pedometerMenu];
				if (qrcodeIndex == NSNotFound) {
					[_menuItems insertObject:pedometerMenu atIndex:0];
				}
				[[NSUserDefaults standardUserDefaults] setObject:_menuItems forKey:A3MainMenuGridMenuItems];
			}
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:A3SettingsMainMenuGridShouldAddAbbreviationMenu]) {
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:A3SettingsMainMenuGridShouldAddAbbreviationMenu];

			NSDictionary *newMenu = @{kA3AppsMenuName : A3AppName_Abbreviation};
			NSInteger menuIndex = [_menuItems indexOfObject:newMenu];
			if (menuIndex == NSNotFound) {
				[_menuItems insertObject:newMenu atIndex:0];
				[_menuItems insertObject:@{kA3AppsMenuName: A3AppName_Kaomoji} atIndex:1];
			}
			[[NSUserDefaults standardUserDefaults] setObject:_menuItems forKey:A3MainMenuGridMenuItems];
		}
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

	[self setupContentHeightWithSize:size];
    [self layoutPageControl];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	[self setupContentHeightWithSize:screenBounds.size];
    [self layoutPageControl];
}

- (void)setupContentHeightWithSize:(CGSize)toSize {
    // Content Height는
    // toSize.height -
    // safeAreaInsets.top
    // NavigationBar Height 44
    //
    // safeAreaInsets.bottom
    // if (shouldShowHouseAds) {
    //      Height of House Ads = topMargin 8 Icon Height 40 margin To Text 4, text height 15, bototm margin 8
    //      16 (top/bottom margin), text Height 15 + 4 = 35 + 40 = 75
    // }
    // Page Control 10 Point
    //
    // Again
    //
    // safeAreaInsets.top
    // NavigationBar
    // topMargin
    // ContentHeight
    // bottomMargin
    // PageControl
    // HouseAds Height
    // safeAreaInsets.bottom
    
    UIEdgeInsets safeAreaInsets = [[UIApplication sharedApplication] keyWindow].safeAreaInsets;

    if (IS_IPHONE) {
        CGFloat contentHeight = toSize.height;
        CGFloat topInset = safeAreaInsets.top + 44 + 10; // NavigationBarHeight + topMargin
        CGFloat bottomInset = safeAreaInsets.bottom + 20; // bottomMargin + pageControlHeight
        if (self.shouldShowHouseAd) {
            bottomInset += 75 + 20;
        }
        contentHeight -= topInset;
        contentHeight -= bottomInset;

        _flowLayout.numberOfItemsPerRow = 4;
        _flowLayout.numberOfRowsPerPage = MIN(floor((contentHeight - 100) / _flowLayout.itemSize.height), 5);
        _flowLayout.contentHeight = contentHeight;
        
        self.collectionView.contentInset = UIEdgeInsetsMake(topInset, safeAreaInsets.left, bottomInset, safeAreaInsets.right);
	} else {
        CGFloat contentHeight = toSize.height;
        
        CGFloat verticalMargin = (toSize.height > toSize.width) ? 90 : 30;
        CGFloat topInset = safeAreaInsets.top + 44 + verticalMargin; // NavigationBarHeight + topMargin
        CGFloat bottomInset = safeAreaInsets.bottom + 20 + verticalMargin; // bottomMargin + pageControlHeight
        if (self.shouldShowHouseAd) {
//            if (toSize.width > toSize.height) {
//                bottomInset -= 30;
//            }
            bottomInset += 75 + 20;
        }
        contentHeight -= topInset;
        contentHeight -= bottomInset;

        NSInteger maxRows = (toSize.height > toSize.width) ? 5 : 4;

        // Is Landscape?
        _flowLayout.numberOfItemsPerRow = (toSize.height > toSize.width) ? 4 : 5;
        _flowLayout.numberOfRowsPerPage = MIN(floor((contentHeight - 100) / _flowLayout.itemSize.height), maxRows);
        _flowLayout.contentHeight = contentHeight;
        
        self.collectionView.contentInset = UIEdgeInsetsMake(topInset, safeAreaInsets.left, bottomInset, safeAreaInsets.right);
	}
    
 	NSInteger currentPage = _pageControl.currentPage;

    __weak __typeof__(self) weakSelf = self;
	dispatch_async(dispatch_get_main_queue(), ^{
        __typeof__(self) strongSelf = weakSelf;
		FNLOG(@"%ld", (long)weakSelf.pageControl.currentPage);
		strongSelf.collectionView.contentOffset = CGPointMake(toSize.width * currentPage, -strongSelf.collectionView.contentInset.top);
	});
	
	if (_instructionViewController) {
		dispatch_async(dispatch_get_main_queue(), ^{
            __typeof__(self) strongSelf = weakSelf;
			[strongSelf adjustFingerCenter];
		});
	}
}

#pragma mark - Instruction View

static NSString *const A3V3InstructionDidShowForGridMenu = @"A3V3InstructionDidShowForGridMenu";

- (void)setupInstructionView
{

	if (![self.navigationController.visibleViewController isKindOfClass:[self class]]) {
        FNLOG();
		return;
	}
	if (![[A3UserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForGridMenu]) {
        
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [[A3UserDefaults standardUserDefaults] setBool:YES forKey:A3V3InstructionDidShowForGridMenu];
            [[A3UserDefaults standardUserDefaults] synchronize];
            
            [self showInstructionView];
        });
	}
}

- (void)showInstructionView
{
	if (_instructionViewController) {
		return;
	}
	
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
	if ([self.collectionView numberOfItemsInSection:0] == 0) return;

	BOOL hideImageView;
	NSInteger row;
	NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:0];
	if (_pageControl.currentPage == 0) {
		row = numberOfItems >= 14 ? 13 : 0;
		hideImageView = row == 0;
	} else {
        NSInteger numberOfItemsPerPage = _flowLayout.numberOfItemsPerRow * _flowLayout.numberOfRowsPerPage;
		row = numberOfItems >= numberOfItemsPerPage + 6 ? numberOfItemsPerPage + 5 : numberOfItemsPerPage;
		hideImageView = IS_IPHONE;
	}
	
    if (IS_IPHONE35 && row == 13) {
        row = 9;
    }
	if (hideImageView) {
		[_instructionViewController.fingerRight setHidden:YES];
		[_instructionViewController.changeStyleLabel setHidden:YES];
		[_instructionViewController.homeStyleListImageView setHidden:YES];
		[_instructionViewController.homeStyleHexagonImageView setHidden:YES];
		[_instructionViewController.homeStyleGridImageView setHidden:YES];
	}
	UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
	CGPoint centerInView = [self.view convertPoint:cell.center fromView:self.collectionView];
	FNLOG(@"centerX = %f, centerY = %f", centerInView.x, centerInView.y);
	FNLOGRECT(cell.frame);
    if (centerInView.x == 0) {
        return;
    }
	_instructionViewController.fingerUpCenterXConstraint.constant = centerInView.x;
	_instructionViewController.fingerUpCenterYConstraint.constant = centerInView.y;
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
