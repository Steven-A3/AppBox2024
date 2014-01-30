//
//  A3ClockFlipViewController.h
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 20..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ClockViewController.h"
#import "A3ClockDataManager.h"
#import "A3SBTickerView.h"

typedef NS_ENUM(NSUInteger, A3ClockFlipViewStyle) {
	A3ClockFlipViewStyleDark = 1,
	A3ClockFlipViewStyleLight
};

@interface A3ClockFlipViewController : A3ClockViewController

@property (assign, nonatomic) A3ClockFlipViewStyle style;

- (instancetype)initWithClockDataManager:(A3ClockDataManager *)clockDataManager style:(A3ClockFlipViewStyle)style;
@end
