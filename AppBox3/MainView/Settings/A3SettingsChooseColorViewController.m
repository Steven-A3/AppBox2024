//
//  A3SettingsChooseColorViewController.m
//  AppBox3
//
//  Created by A3 on 1/15/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3SettingsChooseColorViewController.h"
#import "A3AppDelegate.h"
#import "A3AppDelegate+appearance.h"
#import "A3UIDevice.h"

@interface A3SettingsChooseColorViewController ()

@property (nonatomic, strong) NSArray *colorsArray;
@property (nonatomic, strong) UIImageView *selectedMarkView;
@property (nonatomic, strong) UICollectionView *collectionViewInCell;

@end

@implementation A3SettingsChooseColorViewController {
	NSUInteger _selectedColorIndex;
}

NSString *kCellID = @"Cell";                          // UICollectionViewCell storyboard id

- (void)awakeFromNib {
	[super awakeFromNib];

	_colorsArray = [[A3AppDelegate instance] themeColors];

	NSNumber *selectedColor = [[NSUserDefaults standardUserDefaults] objectForKey:kA3ThemeColorIndex];
	_selectedColorIndex = selectedColor ? [selectedColor unsignedIntegerValue] : 4;
}

- (UIImageView *)selectedMarkView {
	if (!_selectedMarkView) {
		_selectedMarkView = [UIImageView new];
		_selectedMarkView.image = [UIImage imageNamed:@"check"];
		[_selectedMarkView sizeToFit];
	}
	return _selectedMarkView;
}

- (UICollectionView *)collectionViewInCell {
	if (!_collectionViewInCell) {
		UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];

		if (IS_IPHONE) {
			flowLayout.itemSize = CGSizeMake(80, 88);
			flowLayout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
			flowLayout.minimumInteritemSpacing = 20;
			flowLayout.minimumLineSpacing = 20;
		} else {
			flowLayout.itemSize = CGSizeMake(160, 160);
			flowLayout.sectionInset = UIEdgeInsetsMake(40, 40, 40, 40);
			flowLayout.minimumInteritemSpacing = 30;
			flowLayout.minimumLineSpacing = 30;
		}
		_collectionViewInCell = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
		_collectionViewInCell.dataSource = self;
		_collectionViewInCell.delegate = self;
		_collectionViewInCell.backgroundColor = [UIColor whiteColor];
		[_collectionViewInCell registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCellID];
	}
	return _collectionViewInCell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return IS_IPAD ? 160*3 + 40 + 40 + 30 * 2 : 346;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	[cell addSubview:self.collectionViewInCell];

	[_collectionViewInCell makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(cell);
	}];
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
	return 8;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
	// we're going to use a custom UICollectionViewCell, which will hold an image and its label
	//
	UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
	if (indexPath.row == _selectedColorIndex) {
		UIColor *selectedColor = _colorsArray[(NSUInteger) indexPath.row];
		cell.layer.borderColor = selectedColor.CGColor;
		cell.layer.borderWidth = 1.0;
		cell.backgroundColor = [UIColor whiteColor];
		[cell addSubview:self.selectedMarkView];

		[self.selectedMarkView makeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(cell.centerX);
			make.centerY.equalTo(cell.centerY).with.offset(10);
		}];
	} else {
		cell.backgroundColor = _colorsArray[(NSUInteger) indexPath.row];
		cell.layer.borderWidth = 0.0;
	}

	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	_selectedColorIndex = (NSUInteger) indexPath.row;
	[collectionView reloadData];

	[A3AppDelegate instance].window.tintColor = self.colorsArray[_selectedColorIndex];

	[[NSUserDefaults standardUserDefaults] setObject:@(_selectedColorIndex) forKey:kA3ThemeColorIndex];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
