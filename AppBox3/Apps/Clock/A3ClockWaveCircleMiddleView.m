//
//  A3ClockWaveCircleMiddleView.m
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ClockWaveCircleMiddleView.h"
#import "A3ClockDataManager.h"

@interface A3ClockWaveCircleMiddleView ()

@end

@implementation A3ClockWaveCircleMiddleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.nLineWidth = 1;
    }
    return self;
}

- (void)setBounds:(CGRect)bounds {
	[super setBounds:bounds];

	self.layer.cornerRadius = bounds.size.width * 0.5f;

	if(self.position == ClockWaveLocationBig)
	{
		[self.textLabel setFont:self.bigFont];
	}
	else
	{
		[self.textLabel setFont:self.smallFont];
	}

	if (self.isShowWave) {
		[self setFillPercent:self.fillPercent];
	} else {
		self.textLabelCenterY.offset(bounds.size.height / 2);
		[self.textLabel setTextColor:self.superview.backgroundColor];
	}

	[self layoutIfNeeded];
}

- (void)setTemperature:(int)aTemperature
{
	self.textLabel.text = [NSString stringWithFormat:@"%dº", aTemperature];
}

- (void)setDate:(int)aDay
{
    self.textLabel.text = [NSString stringWithFormat:@"%d", aDay];
}

- (void)setWeek:(NSString*)aWeek
{
    self.textLabel.text = aWeek;
}

@end
