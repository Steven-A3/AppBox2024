//
//  A3LineChartView.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 22..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3LineChartView : UIView {
    CGFloat yAxisWidth;
    CGRect xAxisLineRect;
    CGFloat xAxisSeperatorHeight;
    CGFloat xAxisSeperatorInterval;
    CGSize pointSize;
    CGFloat yAxisInterval;
    CGSize yLabelMaxSize;
    NSMutableArray *pointArray;
    CGFloat yStartCenterPosition;
    CGPoint valueTotal;
    CGFloat averageLineYPos;
    CGSize xLabelMaxSize;
    CGFloat xAxisLineHeight;
}

@property (strong, nonatomic) UIColor *xLabelColor;
@property (strong, nonatomic) UIColor *yLabelColor;
@property (strong, nonatomic) UIColor *lineColor;
@property (strong, nonatomic) UIColor *pointColor;
@property (strong, nonatomic) UIColor *xAxisColor;
@property (strong, nonatomic) UIColor *averageColor;
@property (strong, nonatomic) UIFont *xAxisFont;
@property (strong, nonatomic) UIFont *yAxisFont;

@property (assign, nonatomic) BOOL fitWidth;
@property (assign, nonatomic) BOOL fitHeight;
@property (assign, nonatomic) BOOL showXLabel;
@property (assign, nonatomic) BOOL showYLabel;
@property (assign, nonatomic) CGFloat minXValue;
@property (assign, nonatomic) CGFloat maxXValue;
@property (assign, nonatomic) CGFloat minYValue;
@property (assign, nonatomic) CGFloat maxYValue;
@property (assign, nonatomic) NSInteger numberOfItemPerPage;

@property (strong, nonatomic) NSArray *xLabelItems;
@property (strong, nonatomic) NSArray *yLabelItems;
@property (strong, nonatomic) NSArray *valueArray;
@property (assign, nonatomic) NSInteger xLabelDisplayInterval;
@end
