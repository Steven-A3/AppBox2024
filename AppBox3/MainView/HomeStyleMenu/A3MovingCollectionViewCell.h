//
//  A3MovingCollectionViewCell.h
//  HexagonMenu
//
//  Created by Byeong Kwon Kwak on 2/25/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3MovingCollectionViewCell : UIView

@property (nonatomic, weak)UICollectionViewCell *cell;
@property (nonatomic, strong)UIImageView *cellFakeImageView;
@property (nonatomic, strong)UIImageView *cellFakeHightedView;
@property (nonatomic, strong)NSIndexPath *indexPath;
@property (nonatomic, assign)CGPoint originalCenter;
@property (nonatomic, assign)CGRect cellFrame;

- (instancetype)initWithCell:(UICollectionViewCell *)cell;
- (void)changeBoundsIfNeeded:(CGRect)bounds;
- (void)pushFowardView;
- (void)pushBackView:(void(^)(void))completion;

@end
