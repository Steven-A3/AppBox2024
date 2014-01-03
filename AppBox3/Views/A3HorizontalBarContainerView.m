//
//  A3HorizontalBarContainerView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/11/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3HorizontalBarContainerView.h"
#import "A3HorizontalBarChartView.h"
#import "A3UIDevice.h"

@implementation A3HorizontalBarContainerView {
	CGFloat rightMargin;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (UILabel *)labelLeftTop {
	if (nil == _labelLeftTop) {
		_labelLeftTop = [[UILabel alloc] initWithFrame:CGRectZero];
		_labelLeftTop.backgroundColor = [UIColor clearColor];
		_labelLeftTop.font = self.chartLabelFont;
		_labelLeftTop.textColor = self.chartLabelColor;
		_labelLeftTop.text = @"Sale Price";
	}
	return _labelLeftTop;
}

- (UILabel *)labelRightTop {
	if (nil == _labelRightTop) {
		_labelRightTop = [[UILabel alloc] initWithFrame:CGRectZero];
		_labelRightTop.backgroundColor = [UIColor clearColor];
		_labelRightTop.font = self.chartLabelFont;
		_labelRightTop.textColor = self.chartLabelColor;
		_labelRightTop.textAlignment = NSTextAlignmentRight;
		_labelRightTop.text = @"Amount Saved";
	}
	return _labelRightTop;
}

- (UILabel *)chartLeftValueLabel {
	if (nil == _chartLeftValueLabel) {
		_chartLeftValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_chartLeftValueLabel.backgroundColor = [UIColor clearColor];
		_chartLeftValueLabel.textColor = [UIColor whiteColor];
		_chartLeftValueLabel.font = _chartValueFont;
		_chartLeftValueLabel.textAlignment = NSTextAlignmentLeft;
	}
	return _chartLeftValueLabel;
}

- (UILabel *)chartRightValueLabel {
	if (nil == _chartRightValueLabel) {
		_chartRightValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_chartRightValueLabel.backgroundColor = [UIColor clearColor];
		_chartRightValueLabel.textColor = [UIColor whiteColor];
		_chartRightValueLabel.font = _chartValueFont;
		_chartRightValueLabel.textAlignment = NSTextAlignmentRight;
	}
	return _chartRightValueLabel;
}

- (UILabel *)bottomLabel {
	if (nil == _bottomLabel) {
		_bottomLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_bottomLabel.backgroundColor = [UIColor clearColor];
		_bottomLabel.font = self.chartLabelFont;
		_bottomLabel.textColor = self.chartLabelColor;
		_bottomLabel.textAlignment = NSTextAlignmentRight;
		_bottomLabel.text = @"Original Price";
	}
	return _bottomLabel;
}

- (UILabel *)bottomValueLabel {
	if (nil == _bottomValueLabel) {
		_bottomValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_bottomValueLabel.backgroundColor = [UIColor clearColor];
		_bottomValueLabel.font = _bottomValueFont;
		_bottomValueLabel.textColor = self.chartLabelColor;
		_bottomValueLabel.textAlignment = NSTextAlignmentRight;
	}
	return _bottomValueLabel;
}

- (void)setBottomLabelText:(NSString *)text {
	_bottomValueLabel.text = text;
	CGSize sizeForLabel = [_bottomLabel.text sizeWithAttributes:@{NSFontAttributeName:_bottomLabel.font}];
	CGSize sizeForValue = [text sizeWithAttributes:@{NSFontAttributeName:_bottomValueLabel.font}];
	CGRect labelFrame = _bottomLabel.frame;
	labelFrame.origin.x = self.bounds.size.width - rightMargin - 10.0 - sizeForValue.width - sizeForLabel.width;
	labelFrame.size.width = sizeForLabel.width;
	[_bottomLabel setFrame:labelFrame];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
	[super willMoveToSuperview:newSuperview];

	self.backgroundColor = [UIColor clearColor];

	_chartLabelColor = [UIColor colorWithRed:73.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f];

	CGFloat width;
	CGFloat offsetX, offsetY, label_Y_Offset, chartHeight, chartWidth;
	CGFloat labelHeight, headerViewHeight, label_X_Offset;

	if (IS_IPAD) {
		width = APP_VIEW_WIDTH_iPAD;
		offsetX = 44.0;
		offsetY = 45.0;
		label_Y_Offset = 19.0;
		chartHeight = 44.0;
		chartWidth = width - offsetX * 2.0;
		labelHeight = 23.0;
		headerViewHeight = 120.0;
		label_X_Offset = 22.0;
		rightMargin = 44.0 + 10.0;
	} else {
		width = APP_VIEW_WIDTH_iPHONE;
		offsetX = 10.0;
		offsetY = 32.0;
		label_Y_Offset = 16.0;
		chartHeight = 32.0;
		chartWidth = width - offsetX * 2.0;
		labelHeight = 16.0;
		headerViewHeight = 100.0;
		label_X_Offset = 11.0;
		rightMargin = 20.0;
	}

	self.frame = CGRectMake(0.0f, 0.0f, width, headerViewHeight);

	self.labelLeftTop.frame = CGRectMake(offsetX + label_X_Offset, label_Y_Offset, chartWidth / 2.0f - label_X_Offset, labelHeight);
	[self addSubview:self.labelLeftTop];

	self.labelRightTop.frame = CGRectMake(offsetX + chartWidth / 2.0, label_Y_Offset, chartWidth / 2.0f - label_X_Offset, labelHeight);
	[self addSubview:self.labelRightTop];

	self.bottomLabel.frame = CGRectMake(offsetX, offsetY + chartHeight + 5.0f, chartWidth - label_X_Offset, labelHeight);
	[self addSubview:_bottomLabel];

	_percentBarChart = [[A3HorizontalBarChartView alloc] initWithFrame:CGRectMake(offsetX, offsetY, width - offsetX * 2.0f, chartHeight)];
	[self addSubview:_percentBarChart];

	self.chartLeftValueLabel.frame = CGRectMake(offsetX + 10.0, offsetY, 200.0, chartHeight);
	[self addSubview:_chartLeftValueLabel];

	self.chartRightValueLabel.frame = CGRectMake(width - rightMargin - 200.0, offsetY, 200.0, chartHeight);
	[self addSubview:_chartRightValueLabel];

	if (!IS_IPAD) {
		offsetY -= 2.0;
		labelHeight = 26.0;
	}
	self.bottomValueLabel.frame = CGRectMake(width - rightMargin - 200.0, offsetY + chartHeight + 5.0, 200.0, labelHeight);
	[self addSubview:_bottomValueLabel];
}

- (void)setAccessoryView:(UIView *)accessoryView {
	_accessoryView = accessoryView;

	rightMargin = IS_IPAD ? 44.0 + 10.0 : 20.0;

	CGRect bounds = self.bounds;
	CGRect targetBounds = _accessoryView.bounds;
	_accessoryView.frame = CGRectMake(bounds.size.width - rightMargin - accessoryView.bounds.size.width,
	_bottomLabel.frame.origin.y, targetBounds.size.width, targetBounds.size.height);
	[self addSubview:_accessoryView];

	CGFloat offset = accessoryView.bounds.size.width + 4.0;
	rightMargin += offset;

	CGRect frame = _bottomValueLabel.frame;
	frame = CGRectOffset(frame, offset * -1.0, 0.0);
	_bottomValueLabel.frame = frame;

	[self setBottomLabelText:_bottomValueLabel.text];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
