//
//  A3DashLineView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/11/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3DashLineView.h"

@interface A3DashLineView ()

@end

@implementation A3DashLineView

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
	}
	
	return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	[[UIColor colorWithRed:112.0/255.0 green:182.0/255.0 blue:45.0/255.0 alpha:1.0] setStroke];
	UIBezierPath *path = [UIBezierPath new];
	[path moveToPoint:CGPointMake(0, 0)];
	[path addLineToPoint:CGPointMake(rect.size.width, 0)];
	path.lineWidth = 3;
	CGFloat dashes[] = {5, 5};
	[path setLineDash:dashes count:2 phase:0];
	[path stroke];
}

@end
