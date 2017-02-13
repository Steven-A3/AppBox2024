//
//  A3HexagonCollectionViewFlowLayout.m
//  HexagonMenu
//
//  Created by Byeong Kwon Kwak on 2/25/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3HexagonCollectionViewFlowLayout.h"

@interface A3HexagonCollectionViewFlowLayout ()

@property (nonatomic, strong) NSArray<NSNumber *> *lineConfiguration;
@property (nonatomic, assign) NSInteger maxColumn;

@end

@implementation A3HexagonCollectionViewFlowLayout

- (instancetype)init {
	self = [super init];
	if (self) {
		_maxColumn = 6;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
	}
	
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)statusBarOrientationDidChange:(id)notification {
	_lineConfiguration = nil;
}

- (NSArray *)lineConfiguration {
	if (!_lineConfiguration) {
		_lineConfiguration = @[@3, @4, @5, @6, @5, @4, @3];
		_maxColumn = 6;
	}
	return _lineConfiguration;
}

- (NSDictionary *)coordinateFromIndexPath:(NSIndexPath *)indexPath {
	NSInteger row = 0;
	NSInteger sum = 0;
	NSInteger offset = 0;
	NSArray *lineConfiguration = [self lineConfiguration];
	for (NSNumber *count in lineConfiguration) {
		offset = (_maxColumn - [count integerValue]) / 2.0;
		if (indexPath.row < sum + [count integerValue]) {
			return @{@"row" : @(row), @"col":@(indexPath.row - sum + offset)};
		}
		sum += [count integerValue];
		row++;
	}
	return @{@"row" : @(row), @"col":@(indexPath.row - sum + offset)};
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
	CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	CGFloat contentWidth = self.itemSize.width * _maxColumn + self.minimumInteritemSpacing * (_maxColumn - 1);
	CGFloat margin = (screenBounds.size.width - self.collectionView.contentInset.left - self.collectionView.contentInset.right - contentWidth) / 2;

	NSDictionary *coordinate = [self coordinateFromIndexPath:indexPath];
	NSInteger row = [coordinate[@"row"] integerValue];
	NSInteger col = [coordinate[@"col"] integerValue];
	
//	FNLOG(@"row = %ld, col = %ld, indexPath.row = %ld", row, col, indexPath.row);

	CGFloat horiOffset;
	if ([self.lineConfiguration count] % 2 == 1) {
		horiOffset = ((row % 2) == 1) ? 0 : self.itemSize.width * 0.5f + self.minimumInteritemSpacing / 2.0;
	} else {
		horiOffset = ((row % 2) == 0) ? 0 : self.itemSize.width * 0.5f + self.minimumInteritemSpacing / 2.0;
	}
	CGFloat vertOffset = _verticalOffset;
	
	UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
	attributes.size = self.itemSize;
	attributes.center = CGPointMake(margin + ( (col * self.itemSize.width) + (0.5f * self.itemSize.width) + horiOffset) + col * self.minimumInteritemSpacing,
									( ( (row * 0.75f) * self.itemSize.height) + (0.5f * self.itemSize.height) + vertOffset) + self.minimumLineSpacing + row * self.minimumLineSpacing);
	return attributes;
}

- (CGSize)collectionViewContentSize
{
//	FNLOGRECT(self.collectionView.bounds);
	CGFloat contentWidth = self.collectionView.bounds.size.width - self.collectionView.contentInset.left - self.collectionView.contentInset.right;
	CGFloat contentHeight = ([self.lineConfiguration count] * 0.75f) * self.itemSize.height + (0.5f + self.itemSize.height) + self.minimumLineSpacing * (1 + [self.lineConfiguration count]);
	
	return CGSizeMake(contentWidth, contentHeight);
}

@end
