//
//  A3PedometerCollectionViewFlowLayout.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/13/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3PedometerCollectionViewFlowLayout.h"

@implementation A3PedometerCollectionViewFlowLayout {
	CGFloat _interItemSpace;
}

- (void)prepareLayout {
	_interItemSpace = 6;
	self.minimumInteritemSpacing = 6;
	CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	self.itemSize = CGSizeMake((screenBounds.size.width - 4 - _interItemSpace * 6) / 7.0, self.collectionView.bounds.size.height);
	FNLOG(@"height for goal: %f", (self.itemSize.height - 35) / 1.3);
	FNLOG(@"%f, %f", self.itemSize.width, self.itemSize.height);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
	NSMutableArray *layoutAttributes = [[NSMutableArray alloc] init];
	NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:0];
	
	for (NSInteger i = 0 ; i < numberOfItems; i++) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
		UICollectionViewLayoutAttributes *layoutAttribute = [self layoutAttributesForItemAtIndexPath:indexPath];
		[layoutAttributes addObject:layoutAttribute];
	}
	
	return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{

	UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
	attributes.size = self.itemSize;
	attributes.frame = CGRectMake(self.itemSize.width * indexPath.row + _interItemSpace * indexPath.row, 0, self.itemSize.width, self.itemSize.height);
	return attributes;
}

- (CGSize)collectionViewContentSize
{
	NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:0];
	return CGSizeMake(self.itemSize.width * numberOfItems + (numberOfItems > 0 ? _interItemSpace * (numberOfItems - 1) : 0), self.collectionView.bounds.size.height);
}

@end
