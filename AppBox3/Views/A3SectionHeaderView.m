//
//  A3SectionHeaderView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 12/6/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "A3SectionHeaderView.h"

@implementation A3SectionHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

	}
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);
	CGContextSetLineWidth(context, 1.0f);
	CGContextMoveToPoint(context, CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds));
	CGContextAddLineToPoint(context, CGRectGetMaxX(self.bounds), CGRectGetMinY(self.bounds));
	CGContextMoveToPoint(context, CGRectGetMinX(self.bounds), CGRectGetMaxY(self.bounds));
	CGContextAddLineToPoint(context, CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds));
	CGContextStrokePath(context);
}

@end
