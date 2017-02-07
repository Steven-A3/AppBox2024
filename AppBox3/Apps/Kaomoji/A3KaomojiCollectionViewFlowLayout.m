//
//  A3KaomojiCollectionViewFlowLayout.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 2/6/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "A3KaomojiCollectionViewFlowLayout.h"

@implementation A3KaomojiCollectionViewFlowLayout {
	NSInteger _numberOfColumns;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (self) {
		_numberOfColumns = 3;
	}

	return self;
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
	NSMutableArray *layoutAttributes = [NSMutableArray new];

	NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:0];
	for (NSInteger idx = 0; idx < numberOfItems; idx++) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
		UICollectionViewLayoutAttributes *layoutAttribute = [self layoutAttributesForItemAtIndexPath:indexPath];
		[layoutAttributes addObject:layoutAttribute];
	}
	
	return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger row = indexPath.row / _numberOfColumns;
	NSInteger col = indexPath.row % _numberOfColumns;

	UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
	attributes.size = self.itemSize;
	attributes.center = CGPointMake(self.sectionInset.left + self.itemSize.width * col + self.itemSize.width/2 + self.minimumInteritemSpacing * col,
			self.sectionInset.top + self.headerReferenceSize.height + self.itemSize.height * row + self.itemSize.height / 2 + self.minimumLineSpacing * row);
	return attributes;
}

- (CGSize)collectionViewContentSize {
	NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:0];
	CGFloat numberOfLines = numberOfItems / _numberOfColumns;
	CGSize size = CGSizeMake(self.sectionInset.left + self.sectionInset.right + self.itemSize.width * _numberOfColumns + self.minimumInteritemSpacing * (_numberOfColumns - 1),
			self.itemSize.height * numberOfLines + self.headerReferenceSize.height + self.footerReferenceSize.height + self.minimumLineSpacing * (numberOfLines - 1) + self.sectionInset.top + self.sectionInset.bottom);
	return size;
}

@end
