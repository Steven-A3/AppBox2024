//
//  A3CircleView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 3/21/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "A3CircleView.h"
#import "A3UIDevice.h"

@implementation A3CircleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (self) {
		[self initialize];
	}

	return self;
}

- (void)initialize {
	CGRect bounds = self.bounds;
	self.layer.cornerRadius = bounds.size.width / 2.0;
	self.layer.borderWidth = 1.0;
	self.layer.borderColor = [UIColor colorWithRed:163.0/255.0 green:163.0/255.0 blue:174.0/255.0 alpha:1.0].CGColor;

	CGRect frame = self.bounds;
	frame.size.height -= 0.0;
	frame.origin.x -= 1.0;
	_textLabel = [[UILabel alloc] initWithFrame:frame];
	_textLabel.font = [UIFont boldSystemFontOfSize:IS_IPAD ? 24.0 : 18.0];
	_textLabel.textAlignment = NSTextAlignmentCenter;
	_textLabel.backgroundColor = [UIColor clearColor];
	_textLabel.center = CGPointMake(bounds.size.width / 2.0, bounds.size.height / 2.0);
	[self addSubview:_textLabel];
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
