//
//  A3GridCollectionViewFlowLayout.h
//  HexagonMenu
//
//  Created by Byeong Kwon Kwak on 2/25/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3CollectionViewFlowLayout.h"

@interface A3GridCollectionViewFlowLayout : A3CollectionViewFlowLayout

@property (nonatomic, assign) NSInteger numberOfItemsPerPage;
@property (nonatomic, assign) NSInteger numberOfItemsPerRow;
@property (nonatomic, assign) NSInteger numberOfRowsPerPage;
@property (nonatomic, assign) CGFloat contentHeight;

@end
