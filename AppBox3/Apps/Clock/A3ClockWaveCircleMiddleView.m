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
