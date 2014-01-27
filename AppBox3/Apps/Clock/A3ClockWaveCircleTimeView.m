//
//  A3ClockWaveCircleTimeView.m
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ClockWaveCircleTimeView.h"
#import "A3ClockDataManager.h"
#import "NSUserDefaults+A3Defaults.h"


@interface A3ClockWaveCircleTimeView ()

@end

@implementation A3ClockWaveCircleTimeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.nLineWidth = 2;
    }
    return self;
}

- (void)setTime:(NSString*)aTime
{
	self.textLabel.text = aTime;
}

@end
