//
//  A3PercentCalcHeaderView.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 10. 26..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3OverlappedCircleView.h"
#import "A3PercentCalcData.h"

@interface A3PercentCalcHeaderView : UIView

@property (assign, nonatomic) PercentCalcType calcType;
@property (strong, nonatomic) UIView *sliderLine1View;
@property (strong, nonatomic) UIView *sliderLine2View;
@property (strong, nonatomic) UIView *sliderLine1GaugeView;
@property (strong, nonatomic) UIView *sliderLine2GaugeView;
@property (strong, nonatomic) A3OverlappedCircleView *sliderLine1Thumb;
@property (strong, nonatomic) A3OverlappedCircleView *sliderLine2Thumb;
@property (strong, nonatomic) UILabel *sliderThumb1Label;
@property (strong, nonatomic) UILabel *sliderThumb2Label;
@property (strong, nonatomic) UILabel *slider1AMarkLabel;
@property (strong, nonatomic) UILabel *slider2BMarkLabel;
@property (strong, nonatomic) UIView *bottomLineView;

@property (strong, nonatomic) A3PercentCalcData *factorValues;

- (void)setupLayoutForPercentCalcType:(PercentCalcType)calcType;

@end
