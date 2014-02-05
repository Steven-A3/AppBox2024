//
//  A3ChooseColorPhone.h
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 29..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ChooseColor.h"

@interface A3ChooseColorPhone : A3ChooseColor

@property (nonatomic, strong) UICollectionView *collectionView;

- (id)initWithFrame:(CGRect)frame colors:(NSArray *)colors selectedIndex:(NSUInteger)selectedIndex;
@end
