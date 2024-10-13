//
//  A3PedometerCollectionViewCell.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/12/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A3PedometerHandler;

@interface A3PedometerCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) Pedometer_ *pedometerData;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, weak) A3PedometerHandler *pedometerHandler;

- (void)prepareAnimate;
- (void)animateBarCompletion:(void (^)(BOOL finished))completion;

@end
