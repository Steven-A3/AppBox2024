//
//  A3HorizontalBarContainerView.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/11/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A3HorizontalBarChartView;

@interface A3HorizontalBarContainerView : UIView

@property (nonatomic, strong) A3HorizontalBarChartView *percentBarChart;
@property (nonatomic, strong) UILabel *labelRightTop, *labelLeftTop;
@property (nonatomic, strong) UILabel *bottomLabel, *bottomValueLabel;
@property (nonatomic, strong) UILabel *chartLeftValueLabel, *chartRightValueLabel;
@property (nonatomic, strong) UIFont *chartLabelFont;
@property (nonatomic, strong) UIFont *chartValueFont, *bottomValueFont;
@property (nonatomic, strong) UIColor *chartLabelColor;
@property (nonatomic, weak) UIView *accessoryView;

- (void)setBottomLabelText:(NSString *)text;

@end
