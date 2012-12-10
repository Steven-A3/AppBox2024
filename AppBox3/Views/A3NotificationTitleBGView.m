//
//  A3NotificationTitleBGView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 12/10/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "A3NotificationTitleBGView.h"

@implementation A3NotificationTitleBGView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		CAGradientLayer *gradient = [CAGradientLayer layer];
		gradient.anchorPoint      = CGPointMake(0.0f, 0.0f);
		gradient.position         = CGPointMake(0.0f, 0.0f);
		gradient.bounds           = self.bounds;
		gradient.cornerRadius     = 15.0;
		gradient.colors = [NSArray arrayWithObjects:
				(id)[UIColor colorWithWhite:0.8 alpha:0.1].CGColor,
				(id)[UIColor colorWithWhite:1.0f alpha:0.0].CGColor,
				nil];
		[self.layer addSublayer:gradient];
	}
    return self;
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
