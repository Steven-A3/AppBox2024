//
//  A3BookendShapeView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 11/29/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3BookendShapeView.h"
#import "A3UIKit.h"

@implementation A3BookendShapeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
	}

	return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();
	[A3UIKit drawBookendEffectRect:rect context:context];
}

@end
