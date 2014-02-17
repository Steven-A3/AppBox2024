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
        self.lineWidth = 1;
    }
    return self;
}

- (void)setTemperature:(NSInteger)temperature
{
	self.textLabel.text = [NSString stringWithFormat:@"%ldº", (long)temperature];
}

- (void)setDay:(NSInteger)day
{
    self.textLabel.text = [NSString stringWithFormat:@"%ld", (long)day];
}

- (void)setWeek:(NSString*)aWeek
{
    self.textLabel.text = aWeek;
}

@end
