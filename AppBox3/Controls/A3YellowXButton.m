//
//  A3YellowXButton.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 12/11/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "A3YellowXButton.h"

@implementation A3YellowXButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		CAGradientLayer *gradient = [CAGradientLayer layer];
		gradient.anchorPoint      = CGPointMake(0.0f, 0.0f);
		gradient.position         = CGPointMake(0.0f, 0.0f);
		gradient.bounds           = self.bounds;
		gradient.cornerRadius     = CGRectGetHeight(self.bounds)/2.0f;
		gradient.colors = [NSArray arrayWithObjects:
				(id)[UIColor colorWithRed:254.0f/255.0f green:209.0f/255.0f blue:61.0f/255.0f alpha:1.0f].CGColor,
				(id)[UIColor colorWithRed:239.0f/255.0f green:146.0f/255.0f blue:29.0f/255.0f alpha:1.0f].CGColor,
				nil];
		[self.layer addSublayer:gradient];

		CGFloat height = CGRectGetHeight(self.bounds);
		CGRect xFrame = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds) - height * 0.07f, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
		UILabel *X = [[UILabel alloc] initWithFrame:xFrame];
		X.text = @"×";
		X.textAlignment = UITextAlignmentCenter;
		X.font = [UIFont boldSystemFontOfSize:CGRectGetHeight(self.bounds) * 1.2];
		X.textColor = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
		X.backgroundColor = [UIColor clearColor];
		[self addSubview:X];
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
