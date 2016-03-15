//
//  A3CollectionViewFlowLayout.h
//  HexagonMenu
//
//  Created by Byeong Kwon Kwak on 2/25/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3ReorderableLayoutDataSource <UICollectionViewDataSource>

@required
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;

@optional
- (CGFloat)reorderingItemAlpha:(UICollectionView * )collectionview inSection:(NSInteger)section; //Default 0.
- (UIEdgeInsets)scrollTrigerEdgeInsetsInCollectionView:(UICollectionView *)collectionView;
- (UIEdgeInsets)scrollTrigerPaddingInCollectionView:(UICollectionView *)collectionView;
- (CGFloat)scrollSpeedValueInCollectionView:(UICollectionView *)collectionView;

@end

@class A3CollectionViewFlowLayout;

@protocol A3ReorderableLayoutDelegate <UICollectionViewDelegateFlowLayout>

@optional
- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath;
- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath;
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath;
- (void)collectionView:(UICollectionView *)collectionView layout:(A3CollectionViewFlowLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView layout:(A3CollectionViewFlowLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView layout:(A3CollectionViewFlowLayout *)collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView layout:(A3CollectionViewFlowLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)collectionView:(UICollectionView *)collectionView layout:(A3CollectionViewFlowLayout *)collectionViewLayout didSelectDeleteAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView layout:(A3CollectionViewFlowLayout *)collectionViewLayout willTouchesBeginItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface A3CollectionViewFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, weak) id<A3ReorderableLayoutDelegate> delegate;
@property (nonatomic, weak) id<A3ReorderableLayoutDataSource> dataSource;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIView *deleteZoneView;

- (void)removeCellFakeView:(void(^)(void))completion;
- (void)insertDeleteZoneToView:(UIView *)targetView;
@end
