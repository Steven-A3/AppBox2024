//
//  A3GridMenuViewController.m
//  HexagonMenu
//
//  Created by Byeong Kwon Kwak on 2/20/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "common.h"
#import "A3GridMenuViewController.h"
#import "A3AppDelegate.h"
#import "A3GridMenuCollectionViewCell.h"
#import "A3GridCollectionViewFlowLayout.h"

NSString *const A3AppNameGrid_DateCalculator = @"Date Calc";
NSString *const A3AppNameGrid_LoanCalculator = @"Loan Calc";
NSString *const A3AppNameGrid_SalesCalculator = @"Sales Calc";
NSString *const A3AppNameGrid_TipCalculator = @"Tip Calc";
NSString *const A3AppNameGrid_UnitPrice = @"Unit Price";
NSString *const A3AppNameGrid_Calculator = @"Calculator";
NSString *const A3AppNameGrid_PercentCalculator = @"Percent Calc";
NSString *const A3AppNameGrid_CurrencyConverter = @"Currency";
NSString *const A3AppNameGrid_LunarConverter = @"Lunar";
NSString *const A3AppNameGrid_Translator = @"Translator";
NSString *const A3AppNameGrid_UnitConverter = @"Unit";
NSString *const A3AppNameGrid_DaysCounter = @"DaysCounter";
NSString *const A3AppNameGrid_LadiesCalendar = @"L Calendar";
NSString *const A3AppNameGrid_Wallet = @"Wallet";
NSString *const A3AppNameGrid_ExpenseList = @"Expense List";
NSString *const A3AppNameGrid_Holidays = @"Holidays";
NSString *const A3AppNameGrid_Clock = @"Clock";
NSString *const A3AppNameGrid_BatteryStatus = @"Battery";
NSString *const A3AppNameGrid_Mirror = @"Mirror";
NSString *const A3AppNameGrid_Magnifier = @"Magnifier";
NSString *const A3AppNameGrid_Flashlight = @"Flashlight";
NSString *const A3AppNameGrid_Random = @"Random";
NSString *const A3AppNameGrid_Ruler = @"Ruler";
NSString *const A3AppNameGrid_Level = @"Level";

NSString *const A3GridMenuCellID = @"gridCell";
NSString *const kA3AppsMenuNameForGrid = @"kA3AppsMenuNameForGrid";

@interface A3GridMenuViewController () <UICollectionViewDelegate, UICollectionViewDataSource, A3ReorderableLayoutDelegate, A3ReorderableLayoutDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) A3GridCollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) NSMutableArray *menuItems;

@end

@implementation A3GridMenuViewController {
    NSInteger _itemsPerPage;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _itemsPerPage = 16;
	[self setupCollectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupCollectionView {

	UIView *superview = self.view;
	[superview addSubview:self.collectionView];

    [self.collectionView makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(superview);
    }];
	
	self.collectionView.backgroundView = [self backgroundView];
	CGRect screenBounds = [[UIScreen mainScreen] bounds];
	CGFloat verticalMargin = (screenBounds.size.height - self.flowLayout.contentHeight) / 2;
	self.collectionView.contentInset = UIEdgeInsetsMake(verticalMargin - 26, 0, verticalMargin + 26, 0);
}

- (A3GridCollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [A3GridCollectionViewFlowLayout new];
        _flowLayout.itemSize = CGSizeMake(78.0, 102.0);
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
		_flowLayout.delegate = self;
		_flowLayout.dataSource = self;
		_flowLayout.contentHeight = 454.0;
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
	if (!_collectionView) {
		_collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
		_collectionView.delegate = self;
		_collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
		[_collectionView registerClass:[A3GridMenuCollectionViewCell class] forCellWithReuseIdentifier:A3GridMenuCellID];
	}
    return _collectionView;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [self.menuItems count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    A3GridMenuCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:A3GridMenuCellID forIndexPath:indexPath];

	NSDictionary *menuInfo = self.menuItems[indexPath.row];
	cell.borderColor = self.groupColors[menuInfo[kA3AppsGroupName]];
	cell.imageName = [self.imageNameDictionary[menuInfo[kA3AppsMenuName]] stringByAppendingString:@"_Large"];
	cell.titleLabel.text = menuInfo[kA3AppsMenuNameForGrid];
	
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView layout:(A3CollectionViewFlowLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
	double delayInSeconds = 0.3;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		NSDictionary *menuInfo = _menuItems[indexPath.row];
		[collectionViewLayout insertDeleteZoneToView:self.collectionView.backgroundView];
		collectionViewLayout.deleteZoneView.backgroundColor = self.groupColors[menuInfo[kA3AppsGroupName]];
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
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath {
	NSDictionary *menuItem = _menuItems[fromIndexPath.row];
	[_menuItems removeObjectAtIndex:fromIndexPath.row];
	[_menuItems insertObject:menuItem atIndex:toIndexPath.row];
}

- (BOOL)collectionView:(UICollectionView *)collectionView layout:(A3CollectionViewFlowLayout *)collectionViewLayout didSelectDeleteAtIndexPath:(NSIndexPath *)indexPath {
	[_menuItems removeObjectAtIndex:indexPath.row];
	[collectionView deleteItemsAtIndexPaths:@[indexPath]];
	[collectionViewLayout removeCellFakeView:nil];
	return NO;
}

- (NSMutableArray *)menuItems {
	if (!_menuItems) {
		_menuItems = [@[
						@{
							kA3AppsMenuName:A3AppName_Level,
							kA3AppsMenuNameForGrid:A3AppNameGrid_Level,
							kA3AppsGroupName:A3AppGroupNameUtility
							},
						@{
							kA3AppsMenuName:A3AppName_CurrencyConverter,
							kA3AppsMenuNameForGrid:A3AppNameGrid_CurrencyConverter,
							kA3AppsGroupName:A3AppGroupNameConverter
							},
						@{
							kA3AppsMenuName:A3AppName_LoanCalculator,
							kA3AppsMenuNameForGrid:A3AppNameGrid_LoanCalculator,
							kA3AppsGroupName:A3AppGroupNameCalculator
							},
						@{
							kA3AppsMenuName:A3AppName_Wallet,
							kA3AppsMenuNameForGrid:A3AppNameGrid_Wallet,
							kA3AppsGroupName:A3AppGroupNameProductivity
						  },
						@{
							kA3AppsMenuName:A3AppName_Ruler,
							kA3AppsMenuNameForGrid:A3AppNameGrid_Ruler,
							kA3AppsGroupName:A3AppGroupNameUtility
							},
						@{
							kA3AppsMenuName:A3AppName_UnitConverter,
							kA3AppsMenuNameForGrid:A3AppNameGrid_UnitConverter,
							kA3AppsGroupName:A3AppGroupNameConverter
							},
						@{
							kA3AppsMenuName:A3AppName_Calculator,
							kA3AppsMenuNameForGrid:A3AppNameGrid_Calculator,
							kA3AppsGroupName:A3AppGroupNameCalculator
							},
						@{
							kA3AppsMenuName:A3AppName_LadiesCalendar,
							kA3AppsMenuNameForGrid:A3AppNameGrid_LadiesCalendar,
							kA3AppsGroupName:A3AppGroupNameProductivity
							},
						@{
							kA3AppsMenuName:A3AppName_BatteryStatus,
							kA3AppsMenuNameForGrid:A3AppNameGrid_BatteryStatus,
							kA3AppsGroupName:A3AppGroupNameUtility
							},
						@{
							kA3AppsMenuName:A3AppName_Translator,
							kA3AppsMenuNameForGrid:A3AppNameGrid_Translator,
							kA3AppsGroupName:A3AppGroupNameConverter
							},
						@{
							kA3AppsMenuName:A3AppName_TipCalculator,
							kA3AppsMenuNameForGrid:A3AppNameGrid_TipCalculator,
							kA3AppsGroupName:A3AppGroupNameCalculator
							},
						@{
							kA3AppsMenuName:A3AppName_DaysCounter,
							kA3AppsMenuNameForGrid:A3AppNameGrid_DaysCounter,
							kA3AppsGroupName:A3AppGroupNameProductivity
							},
						@{
							kA3AppsMenuName:A3AppName_Clock,
							kA3AppsMenuNameForGrid:A3AppNameGrid_Clock,
							kA3AppsGroupName:A3AppGroupNameUtility
							},
						@{
							kA3AppsMenuName:A3AppName_Holidays,
							kA3AppsMenuNameForGrid:A3AppNameGrid_Holidays,
							kA3AppsGroupName:A3AppGroupNameReference
							},
						@{
							kA3AppsMenuName:A3AppName_DateCalculator,
							kA3AppsMenuNameForGrid:A3AppNameGrid_DateCalculator,
							kA3AppsGroupName:A3AppGroupNameCalculator
							},
						@{
							kA3AppsMenuName:A3AppName_ExpenseList,
							kA3AppsMenuNameForGrid:A3AppNameGrid_ExpenseList,
							kA3AppsGroupName:A3AppGroupNameProductivity
							},
						@{
							kA3AppsMenuName:A3AppName_Flashlight,
							kA3AppsMenuNameForGrid:A3AppNameGrid_Flashlight,
							kA3AppsGroupName:A3AppGroupNameUtility
							},
						@{
							kA3AppsMenuName:A3AppName_Mirror,
							kA3AppsMenuNameForGrid:A3AppNameGrid_Mirror,
							kA3AppsGroupName:A3AppGroupNameUtility
							},
						@{
							kA3AppsMenuName:A3AppName_Magnifier,
							kA3AppsMenuNameForGrid:A3AppNameGrid_Magnifier,
							kA3AppsGroupName:A3AppGroupNameUtility
							},
						@{
							kA3AppsMenuName:A3AppName_Random,
							kA3AppsMenuNameForGrid:A3AppNameGrid_Random,
							kA3AppsGroupName:A3AppGroupNameUtility},
						@{
							kA3AppsMenuName:A3AppName_SalesCalculator,
							kA3AppsMenuNameForGrid:A3AppNameGrid_SalesCalculator,
							kA3AppsGroupName:A3AppGroupNameCalculator
							},
						@{
							kA3AppsMenuName:A3AppName_UnitPrice,
							kA3AppsMenuNameForGrid:A3AppNameGrid_UnitPrice,
							kA3AppsGroupName:A3AppGroupNameCalculator
							},
						@{
							kA3AppsMenuName:A3AppName_PercentCalculator,
							kA3AppsMenuNameForGrid:A3AppNameGrid_PercentCalculator,
							kA3AppsGroupName:A3AppGroupNameCalculator
							},
						@{
							kA3AppsMenuName:A3AppName_LunarConverter,
							kA3AppsMenuNameForGrid:A3AppNameGrid_LunarConverter,
							kA3AppsGroupName:A3AppGroupNameConverter
							},
						] mutableCopy];
	}
	return _menuItems;
}

@end
