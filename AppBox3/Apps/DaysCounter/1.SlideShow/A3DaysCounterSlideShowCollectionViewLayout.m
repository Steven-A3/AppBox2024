//
//  A3DaysCounterSlideShowCollectionViewLayout.m
//  AppBox3
//
//  Created by dotnetguy83 on 7/7/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterSlideShowCollectionViewLayout.h"

@implementation A3DaysCounterSlideShowCollectionViewLayout

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    return nil;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    return [self layoutAttributesForItemAtIndexPath:itemIndexPath];
}

@end
