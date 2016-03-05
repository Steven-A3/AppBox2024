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
		_lineConfiguration = @[@4, @5, @6, @5, @4];
		_maxColumn = 6;
	}
	
	return self;
}

- (NSDictionary *)coordinateFromIndexPath:(NSIndexPath *)indexPath {
	NSInteger row = 0;
	NSInteger sum = 0;
	NSInteger offset = 0;
	for (NSNumber *count in _lineConfiguration) {
		offset = (_maxColumn - [count integerValue]) / 2;
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
	NSDictionary *coordinate = [self coordinateFromIndexPath:indexPath];
	NSInteger row = [coordinate[@"row"] integerValue];
	NSInteger col = [coordinate[@"col"] integerValue];
	
	//    FNLOG(@"row = %ld, col = %ld, indexPath.row = %ld", row, col, indexPath.row);
	
	CGFloat horiOffset = ((row % 2) == 0) ? 0 : self.itemSize.width * 0.5f + self.minimumInteritemSpacing / 2.0;
	CGFloat vertOffset = 0;
	
	UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
	attributes.size = self.itemSize;
	attributes.center = CGPointMake( ( (col * self.itemSize.width) + (0.5f * self.itemSize.width) + horiOffset) + self.minimumInteritemSpacing + col * self.minimumInteritemSpacing,
									( ( (row * 0.75f) * self.itemSize.height) + (0.5f * self.itemSize.height) + vertOffset) + self.minimumLineSpacing + row * self.minimumLineSpacing);
	return attributes;
}

- (CGSize)collectionViewContentSize
{
	CGFloat contentWidth = self.collectionView.bounds.size.width - self.collectionView.contentInset.left - self.collectionView.contentInset.right;
	CGFloat contentHeight = ([_lineConfiguration count] * 0.75f) * self.itemSize.height + (0.5f + self.itemSize.height) + self.minimumLineSpacing * (1 + [_lineConfiguration count]);
	
	return CGSizeMake(contentWidth, contentHeight);
}

@end
