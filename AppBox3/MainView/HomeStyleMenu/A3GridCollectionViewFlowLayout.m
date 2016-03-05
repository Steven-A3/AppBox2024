//
//  A3GridCollectionViewFlowLayout.m
//  HexagonMenu
//
//  Created by Byeong Kwon Kwak on 2/25/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3GridCollectionViewFlowLayout.h"
#import "common.h"

@implementation A3GridCollectionViewFlowLayout

- (instancetype)init {
	self = [super init];
	if (self) {
		_numberOfItemsPerRow = 4;
		_numberOfRowsPerPage = 4;
		_contentHeight = 356.0;
		_numberOfItemsPerPage = 16;
	}
	
	return self;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger indexOnPage = indexPath.row % _numberOfItemsPerPage;

	NSInteger row = indexOnPage / _numberOfItemsPerRow;
	NSInteger col = indexOnPage % _numberOfItemsPerRow;
	
	//    FNLOG(@"row = %ld, col = %ld, indexPath.row = %ld", row, col, indexPath.row);
	
	CGFloat horiOffset = indexPath.row / _numberOfItemsPerPage * [UIScreen mainScreen].bounds.size.width;
	CGFloat horizontalMarginOnPage = 10.0;
	
	UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
	attributes.size = self.itemSize;
	CGFloat contentWidth = self.collectionView.bounds.size.width - horizontalMarginOnPage * 2;
	CGFloat columnWidth = contentWidth / _numberOfItemsPerRow;
	CGFloat rowHeight = _contentHeight / _numberOfRowsPerPage;
	attributes.center = CGPointMake( horiOffset + horizontalMarginOnPage + columnWidth * col + columnWidth / 2,
									 row * rowHeight + rowHeight / 2);
	return attributes;
}

- (CGSize)collectionViewContentSize
{
	CGFloat contentWidth = self.collectionView.bounds.size.width * 2;
	
	return CGSizeMake(contentWidth, _contentHeight);
}

@end
