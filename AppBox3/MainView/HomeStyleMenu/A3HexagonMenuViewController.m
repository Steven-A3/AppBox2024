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

@interface A3HexagonMenuViewController () <A3ReorderableLayoutDelegate, A3ReorderableLayoutDataSource,  UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) A3CollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UILabel *appTitleLabel;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *menuItems;
@property (nonatomic, strong) NSIndexPath *movingCellOriginalIndexPath;

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
    CGSize contentSize = [_flowLayout collectionViewContentSize];
	if (IS_IPHONE) {
		_collectionView.contentInset = UIEdgeInsetsMake((self.view.bounds.size.height - contentSize.height)/2, horizontalInset, (self.view.bounds.size.height - contentSize.height)/2, horizontalInset);
	} else {
		if (IS_PORTRAIT) {
			_collectionView.contentInset = UIEdgeInsetsMake((self.view.bounds.size.height - contentSize.height)/2 + 80, 0, (self.view.bounds.size.height - contentSize.height)/2 - 80, 0);
		} else {
			_collectionView.contentInset = UIEdgeInsetsMake((self.view.bounds.size.height - contentSize.height)/2 + 19, 0, (self.view.bounds.size.height - contentSize.height)/2 - 19, 0);
		}
	}
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
	cell.borderColor = self.groupColors[menuInfo[kA3AppsGroupName]];
	NSString *imageName = [[A3AppDelegate instance] imageNameForApp:menuInfo[kA3AppsMenuName]];
	if (IS_IPAD) {
		imageName = [imageName stringByAppendingString:@"_Large"];
	}
	cell.imageName = imageName;

	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	FNLOG();
	self.appTitleLabel.text = @"";
	
	NSDictionary *menuInfo = self.menuItems[indexPath.row];
	[[A3AppDelegate instance] launchAppNamed:menuInfo[kA3AppsMenuName] verifyPasscode:YES animated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView layout:(A3CollectionViewFlowLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
	self.appTitleLabel.text = @"";
	[collectionViewLayout.deleteZoneView setHidden:YES];
	double delayInSeconds = 0.3;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[collectionViewLayout.deleteZoneView setHidden:YES];
	});
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {
	NSDictionary *menuInfo = self.menuItems[fromIndexPath.row];
	[_flowLayout insertDeleteZoneToView:self.collectionView.backgroundView];
	_flowLayout.deleteZoneView.backgroundColor = self.groupColors[menuInfo[kA3AppsGroupName]];
	[_flowLayout.deleteZoneView setHidden:NO];
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
	[self setAppTitleTextAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView layout:(A3CollectionViewFlowLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
	_movingCellOriginalIndexPath = [indexPath copy];
	double delayInSeconds = 0.3;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		NSDictionary *menuInfo = self.menuItems[indexPath.row];
		[collectionViewLayout insertDeleteZoneToView:self.collectionView.backgroundView];
		collectionViewLayout.deleteZoneView.backgroundColor = self.groupColors[menuInfo[kA3AppsGroupName]];
		[collectionViewLayout.deleteZoneView setHidden:NO];
	});
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath {
	NSMutableArray *menuItems = self.menuItems;
	NSDictionary *menuItem = menuItems[fromIndexPath.row];
	[menuItems removeObjectAtIndex:fromIndexPath.row];
	[menuItems insertObject:menuItem atIndex:toIndexPath.row];
}

- (BOOL)collectionView:(UICollectionView *)collectionView layout:(A3CollectionViewFlowLayout *)collectionViewLayout didSelectDeleteAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row != _movingCellOriginalIndexPath.row) {
		[self.collectionView moveItemAtIndexPath:indexPath toIndexPath:_movingCellOriginalIndexPath];
	}
	[self.menuItems replaceObjectAtIndex:_movingCellOriginalIndexPath.row withObject:@{kA3AppsMenuName:A3AppName_None, kA3AppsGroupName:A3AppGroupNameNone}];
	[collectionViewLayout removeCellFakeView:^{
		[self.collectionView reloadItemsAtIndexPaths:@[_movingCellOriginalIndexPath]];
	}];
	return NO;
}

- (void)setAppTitleTextAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *menuInfo = self.menuItems[indexPath.row];
	self.appTitleLabel.text = menuInfo[kA3AppsMenuName];
	self.appTitleLabel.textColor = self.groupColors[menuInfo[kA3AppsGroupName]];
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

- (NSMutableArray *)menuItems {
	if (!_menuItems) {
		_menuItems = [@[
				@{kA3AppsMenuName:A3AppName_Magnifier, kA3AppsGroupName:A3AppGroupNameUtility},
				@{kA3AppsMenuName:A3AppName_Random, kA3AppsGroupName:A3AppGroupNameUtility},
				@{kA3AppsMenuName:A3AppName_Clock, kA3AppsGroupName:A3AppGroupNameUtility},
				@{kA3AppsMenuName:A3AppName_Calculator, kA3AppsGroupName:A3AppGroupNameCalculator},
				@{kA3AppsMenuName:A3AppName_Ruler, kA3AppsGroupName:A3AppGroupNameUtility},
				@{kA3AppsMenuName:A3AppName_Level, kA3AppsGroupName:A3AppGroupNameUtility},
				@{kA3AppsMenuName:A3AppName_BatteryStatus, kA3AppsGroupName:A3AppGroupNameUtility},
				@{kA3AppsMenuName:A3AppName_DaysCounter, kA3AppsGroupName:A3AppGroupNameProductivity},
				@{kA3AppsMenuName:A3AppName_DateCalculator, kA3AppsGroupName:A3AppGroupNameCalculator},
				@{kA3AppsMenuName:A3AppName_Flashlight, kA3AppsGroupName:A3AppGroupNameUtility},
				@{kA3AppsMenuName:A3AppName_Mirror, kA3AppsGroupName:A3AppGroupNameUtility},
				@{kA3AppsMenuName:A3AppName_Holidays, kA3AppsGroupName:A3AppGroupNameReference},
				@{kA3AppsMenuName:A3AppName_ExpenseList, kA3AppsGroupName:A3AppGroupNameProductivity},
				@{kA3AppsMenuName:A3AppName_LoanCalculator, kA3AppsGroupName:A3AppGroupNameCalculator},
				@{kA3AppsMenuName:A3AppName_PercentCalculator, kA3AppsGroupName:A3AppGroupNameCalculator},
				@{kA3AppsMenuName:A3AppName_CurrencyConverter, kA3AppsGroupName:A3AppGroupNameConverter},
				@{kA3AppsMenuName:A3AppName_UnitConverter, kA3AppsGroupName:A3AppGroupNameConverter},
				@{kA3AppsMenuName:A3AppName_LadiesCalendar, kA3AppsGroupName:A3AppGroupNameProductivity},
				@{kA3AppsMenuName:A3AppName_TipCalculator, kA3AppsGroupName:A3AppGroupNameCalculator},
				@{kA3AppsMenuName:A3AppName_SalesCalculator, kA3AppsGroupName:A3AppGroupNameCalculator},
				@{kA3AppsMenuName:A3AppName_Translator, kA3AppsGroupName:A3AppGroupNameConverter},
				@{kA3AppsMenuName:A3AppName_LunarConverter, kA3AppsGroupName:A3AppGroupNameConverter},
				@{kA3AppsMenuName:A3AppName_Wallet, kA3AppsGroupName:A3AppGroupNameProductivity},
				@{kA3AppsMenuName:A3AppName_UnitPrice, kA3AppsGroupName:A3AppGroupNameCalculator},
		] mutableCopy];
	}
	return _menuItems;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

	if (IS_IPAD) {
		CGSize contentSize = [_flowLayout collectionViewContentSize];
		if (size.width < size.height) {
			_collectionView.contentInset = UIEdgeInsetsMake((self.view.bounds.size.height - contentSize.height)/2 + 80, 0, (self.view.bounds.size.height - contentSize.height)/2 - 80, 0);
		} else {
			_collectionView.contentInset = UIEdgeInsetsMake((self.view.bounds.size.height - contentSize.height)/2 + 19, 0, (self.view.bounds.size.height - contentSize.height)/2 - 19, 0);
		}
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

	if (IS_IPAD) {
		CGSize contentSize = [_flowLayout collectionViewContentSize];
		if (IS_PORTRAIT) {
			_collectionView.contentInset = UIEdgeInsetsMake((self.view.bounds.size.height - contentSize.height)/2 + 80, 0, (self.view.bounds.size.height - contentSize.height)/2 - 80, 0);
		} else {
			_collectionView.contentInset = UIEdgeInsetsMake((self.view.bounds.size.height - contentSize.height)/2 + 19, 0, (self.view.bounds.size.height - contentSize.height)/2 - 19, 0);
		}
	}
}

@end
