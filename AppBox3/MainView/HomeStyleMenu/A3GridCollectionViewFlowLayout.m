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
		_numberOfRowsPerPage = IS_IPHONE ? 4 : 5;
    }
	
	return self;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger numberOfItemsPerPage = _numberOfItemsPerRow * _numberOfRowsPerPage;
	NSInteger indexOnPage = indexPath.row % numberOfItemsPerPage;

	NSInteger row = indexOnPage / _numberOfItemsPerRow;
	NSInteger col = indexOnPage % _numberOfItemsPerRow;
	
	//    FNLOG(@"row = %ld, col = %ld, indexPath.row = %ld", row, col, indexPath.row);
	
	CGFloat horiOffset = indexPath.row / numberOfItemsPerPage * [A3UIDevice screenBoundsAdjustedWithOrientation].size.width;
	CGFloat horizontalMarginOnPage = IS_IPHONE ? 10.0 : [UIWindow interfaceOrientationIsPortrait] ? 32.0 : 21;
	
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
    NSInteger numberOfItemsPerPage = self.numberOfItemsPerRow * self.numberOfRowsPerPage;
	CGFloat contentWidth = self.collectionView.bounds.size.width * (([self.collectionView numberOfItemsInSection:0] - 1) / numberOfItemsPerPage + 1);
	
	return CGSizeMake(contentWidth, _contentHeight);
}

@end
