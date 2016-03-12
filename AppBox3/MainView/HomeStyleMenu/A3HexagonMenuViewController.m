//
//  A3HexagonMenuViewController.m
//  HexagonMenu
//
//  Created by Byeong Kwon Kwak on 2/10/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "common.h"
#import "A3HexagonMenuViewController.h"
#import "A3HexagonCell.h"
#import "A3AppDelegate.h"
#import "A3HexagonCollectionViewFlowLayout.h"
#import "A3AppSelectTableViewController.h"
#import "A3NavigationController.h"

@interface A3HexagonMenuViewController () <A3ReorderableLayoutDelegate, A3ReorderableLayoutDataSource,  UICollectionViewDataSource, UICollectionViewDelegate, A3AppSelectViewControllerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) A3CollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UILabel *appTitleLabel;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *menuItems;
@property (nonatomic, strong) NSIndexPath *movingCellOriginalIndexPath;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, copy) NSMutableArray *previousMenuItemsBeforeMovingCell;

@end

@implementation A3HexagonMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

	CGFloat horizontalInset = IS_IPHONE ? 15 : 0;
    _flowLayout = [A3HexagonCollectionViewFlowLayout new];
	_flowLayout.delegate = self;
	_flowLayout.dataSource = self;
	_flowLayout.minimumInteritemSpacing = IS_IPHONE ? 6 : 10;
	_flowLayout.minimumLineSpacing = IS_IPHONE ? 6 : 10;
	_flowLayout.sectionInset = UIEdgeInsetsZero;
	if (IS_IPHONE) {
		CGFloat itemSize;
		itemSize = ([[UIScreen mainScreen] bounds].size.width - _flowLayout.minimumInteritemSpacing * 7 - horizontalInset * 2) / 6;
		_flowLayout.itemSize = CGSizeMake(itemSize, itemSize * 1.1);
	} else {
		_flowLayout.itemSize = CGSizeMake(88, 100);
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	_menuItems = nil;
	
	CGSize contentSize = [_flowLayout collectionViewContentSize];
	if (IS_IPHONE) {
		_collectionView.contentInset = UIEdgeInsetsMake((self.view.bounds.size.height - contentSize.height)/2, 0, (self.view.bounds.size.height - contentSize.height)/2, 0);
	} else {
		CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
		[self setupCollectionViewContentInsetWithSize:screenBounds.size];
	}
	[self.collectionView reloadData];
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

	NSDictionary *menuInfo = self.menuItems[indexPath.row];
	NSDictionary *appInfo = [[A3AppDelegate instance] appInfoDictionary][menuInfo[kA3AppsMenuName]];
	cell.borderColor = self.groupColors[appInfo[kA3AppsGroupName]];
	NSString *imageName = [[A3AppDelegate instance] imageNameForApp:menuInfo[kA3AppsMenuName]];
	if (IS_IPAD) {
		imageName = [imageName stringByAppendingString:@"_Large"];
	}
	cell.imageName = imageName;

	return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	FNLOG();
	self.appTitleLabel.text = @"";

	NSDictionary *menuInfo = self.menuItems[indexPath.row];
	if ([menuInfo[kA3AppsMenuName] isEqualToString:A3AppName_None]) {
		_selectedIndexPath = indexPath;

		A3AppSelectTableViewController *viewController = [[A3AppSelectTableViewController alloc] initWithArray:[self availableMenuItems]];
		viewController.delegate = self;
		A3NavigationController *navigationController = [[A3NavigationController alloc] initWithRootViewController:viewController];
		[self presentViewController:navigationController animated:YES completion:nil];
	} else {
		[[A3AppDelegate instance] launchAppNamed:menuInfo[kA3AppsMenuName] verifyPasscode:YES animated:YES];
	}
}

- (void)viewController:(UIViewController *)viewController didSelectAppNamed:(NSString *)appName {
	[self.menuItems replaceObjectAtIndex:_selectedIndexPath.row withObject:@{kA3AppsMenuName:appName}];
	[self.collectionView reloadItemsAtIndexPaths:@[_selectedIndexPath]];

	[[NSUserDefaults standardUserDefaults] setObject:_menuItems forKey:A3MainMenuHexagonMenuItems];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - A3CollectionViewFlowLayoutDelegate

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {
	NSDictionary *menuInfo = self.menuItems[fromIndexPath.row];
	NSDictionary *appInfo = [[A3AppDelegate instance] appInfoDictionary][menuInfo[kA3AppsMenuName]];
	[_flowLayout insertDeleteZoneToView:self.collectionView.backgroundView];
	_flowLayout.deleteZoneView.backgroundColor = self.groupColors[appInfo[kA3AppsGroupName]];
	[_flowLayout.deleteZoneView setHidden:NO];
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
	FNLOG();
	_movingCellOriginalIndexPath = [indexPath copy];
	_previousMenuItemsBeforeMovingCell = [[self menuItems] copy];

	[self setAppTitleTextAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView layout:(A3CollectionViewFlowLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
	double delayInSeconds = 0.3;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		NSDictionary *menuInfo = self.menuItems[indexPath.row];
		NSDictionary *appInfo = [[A3AppDelegate instance] appInfoDictionary][menuInfo[kA3AppsMenuName]];
		[collectionViewLayout insertDeleteZoneToView:self.collectionView.backgroundView];
		collectionViewLayout.deleteZoneView.backgroundColor = self.groupColors[appInfo[kA3AppsGroupName]];
		[collectionViewLayout.deleteZoneView setHidden:NO];
	});
}

- (void)collectionView:(UICollectionView *)collectionView layout:(A3CollectionViewFlowLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
	FNLOG();
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
	FNLOG();

	_menuItems = [_previousMenuItemsBeforeMovingCell mutableCopy];
	[_menuItems replaceObjectAtIndex:_movingCellOriginalIndexPath.row withObject:@{kA3AppsMenuName:A3AppName_None}];

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
	NSDictionary *appInfo = [[A3AppDelegate instance] appInfoDictionary][menuInfo[kA3AppsMenuName]];
	self.appTitleLabel.text = menuInfo[kA3AppsMenuName];
	self.appTitleLabel.textColor = self.groupColors[appInfo[kA3AppsGroupName]];
}

- (UILabel *)appTitleLabel {
	if (!_appTitleLabel) {
		_appTitleLabel = [UILabel new];
		_appTitleLabel.font = [UIFont systemFontOfSize:31];

		[_collectionView.backgroundView addSubview:_appTitleLabel];

		UIView *superview = _collectionView.backgroundView;
		[_appTitleLabel makeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(superview.centerX);
			make.top.equalTo(superview.bottom).with.multipliedBy(0.2);
		}];
	}
	return _appTitleLabel;
}

- (NSArray *)originalMenuItems {
	return @[
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
			 ];
}

- (NSMutableArray *)menuItems {
	if (!_menuItems) {
		_menuItems = [[[NSUserDefaults standardUserDefaults] objectForKey:A3MainMenuHexagonMenuItems] mutableCopy];
		if (!_menuItems) {
			_menuItems = [[self originalMenuItems] mutableCopy];
		}
	}
	return _menuItems;
}

- (NSArray *)availableMenuItems {
	NSMutableArray *availableMenuItems = [[self originalMenuItems] mutableCopy];
	[availableMenuItems removeObjectsInArray:[self menuItems]];
	return availableMenuItems;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

	[self setupCollectionViewContentInsetWithSize:size];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

	[self setupCollectionViewContentInsetWithSize:self.view.bounds.size];
}

- (void)setupCollectionViewContentInsetWithSize:(CGSize)size {
	if (IS_IPAD) {
		CGSize contentSize = [_flowLayout collectionViewContentSize];
		if (size.width < size.height) {
			_collectionView.contentInset = UIEdgeInsetsMake((size.height - contentSize.height)/2 + 80, 0, (size.height - contentSize.height)/2 - 80, 0);
		} else {
			FNLOGRECT(self.view.bounds);
			CGFloat offset = 40;
			_collectionView.contentInset = UIEdgeInsetsMake((size.height - contentSize.height)/2 + offset, 0, (size.height - contentSize.height)/2 - offset, 0);
		}
	}
}

@end
