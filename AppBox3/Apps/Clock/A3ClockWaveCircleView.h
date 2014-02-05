//
//  A3ClockWaveCircleView.h
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A3ClockDataManager;
@class A3ClockWaveCircleView;

@protocol A3ClockWaveCircleDelegate <NSObject>
- (void)clockWaveCircleTapped:(A3ClockWaveCircleView *)waveCircle;
@end

typedef NS_ENUM(NSUInteger, A3ClockWaveLocation) {
    ClockWaveLocationBig = 0,           // 메인
	ClockWaveLocationSmall,
};

@interface A3ClockWaveCircleView : UIView

@property (nonatomic) int lineWidth;
@property (nonatomic) float fillPercent;       // 0.f:none, 1.f:fill
@property (nonatomic) UILabel *textLabel;
@property (nonatomic) BOOL isShowWave;
@property (nonatomic) A3ClockWaveLocation position;
@property (nonatomic) BOOL isMustChange;
@property (nonatomic, weak) id<A3ClockWaveCircleDelegate> delegate;
@property (nonatomic, strong) UIFont *smallFont;
@property (nonatomic, strong) UIFont *bigFont;

@property (nonatomic, strong) id<MASConstraint> textLabelCenterY;
@property (nonatomic, strong) UIView *colonView;

- (void)addColonView;
- (void)setColonColor:(UIColor *)color;

@end
