//
//  A3HorizontalBarChartView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 12/17/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3HorizontalBarChartView.h"
#import "A3UIKit.h"
#import "UIView+A3Drawing.h"

@implementation A3HorizontalBarChartView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
	}
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
	}

	return self;
}

- (void)setLeftValue:(double)leftValue {
	_leftValue = leftValue;
	[self setNeedsDisplay];
}

- (void)setRightValue:(double)rightValue {
	_rightValue = rightValue;
	[self setNeedsDisplay];
}

- (UIColor *)lineColorForEmptyChart {
	return [UIColor colorWithRed:169.0f/255.0f green:170.0f/255.0f blue:171.0f/255.0f alpha:1.0f];
}

- (UIColor *)lineColorForLeftChart {
	return [UIColor colorWithRed:204.0f/255.0f green:38.0f/255.0f blue:21.0f/255.0f alpha:1.0f];
}

- (UIColor *)lineColorForRightChart {
	return [UIColor colorWithRed:47.0f/255.0f green:124.0f/255.0f blue:16.0f/255.0f alpha:1.0f];
}

- (NSArray *)gradientColorsForEmptyChart {
	return @[(__bridge id)[UIColor colorWithRed:182.0f/255.0f green:183.0f/255.0f blue:184.0f/255.0f alpha:1.0f].CGColor,
			(__bridge id)[UIColor colorWithRed:230.0f/255.0f green:232.0f/255.0f blue:233.0f/255.0f alpha:1.0f].CGColor];
}

- (NSArray *)gradientColorsForLeftChart {
	return @[(__bridge id)[UIColor colorWithRed:223.0f/255.0f green:58.0f/255.0f blue:34.0f/255.0f alpha:1.0f].CGColor,
	(__bridge id)[UIColor colorWithRed:234.0f/255.0f green:126.0f/255.0f blue:107.0f/255.0f alpha:1.0f].CGColor];
}

- (NSArray *)gradientColorsForRightChart {
	return @[(__bridge id)[UIColor colorWithRed:63.0f/255.0f green:163.0f/255.0f blue:25.0f/255.0f alpha:1.0f].CGColor,
			(__bridge id)[UIColor colorWithRed:143.0f/255.0f green:213.0f/255.0f blue:36.0f/255.0f alpha:1.0f].CGColor];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();
	if ((_leftValue == 0.0) || (_rightValue == 0.0)) {
		UIBezierPath *chart = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:CGRectGetHeight(rect)/2.0f];
		[chart addClip];
		NSArray *gradientColors;
		UIColor *lineColor;
		if (_leftValue > 0.0) {
			gradientColors = self.gradientColorsForLeftChart;
			lineColor = self.lineColorForLeftChart;
		} else if (_rightValue > 0.0) {
			gradientColors = self.gradientColorsForRightChart;
			lineColor = self.lineColorForRightChart;
		} else {
			gradientColors = self.gradientColorsForEmptyChart;
			lineColor = self.lineColorForEmptyChart;
		}
		[self drawLinearGradientToContext:context rect:rect withColors:gradientColors];
		CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
		[chart stroke];
	} else {
		CGFloat leftWidth = (CGFloat) ((_leftValue / (_leftValue + _rightValue)) * CGRectGetWidth(rect));
		CGFloat rightWidth = CGRectGetWidth(rect) - leftWidth;
		CGFloat height = CGRectGetHeight(rect);
		CGFloat cornerRadius = height / 2.0f;
		CGRect leftRect = CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), leftWidth, height);

		CGContextSaveGState(context);
		UIBezierPath *leftChart = [UIBezierPath bezierPathWithRoundedRect:leftRect byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
		[leftChart addClip];
		[self drawLinearGradientToContext:context rect:leftRect withColors:self.gradientColorsForLeftChart];
		CGContextSetStrokeColorWithColor(context, self.lineColorForLeftChart.CGColor);
		[leftChart stroke];
		CGContextRestoreGState(context);

		CGRect rightRect = CGRectMake(CGRectGetMinX(rect) + leftWidth, CGRectGetMinY(rect), rightWidth, height);
		UIBezierPath *rightChart = [UIBezierPath bezierPathWithRoundedRect:rightRect byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomRight cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
		[rightChart addClip];
		[rightChart stroke];
		[self drawLinearGradientToContext:context rect:rightRect withColors:self.gradientColorsForRightChart];
	}
}

@end
