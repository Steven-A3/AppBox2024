//
//  A3TranslatorCircleView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/19/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TranslatorCircleView.h"

@implementation A3TranslatorCircleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self initialize];
    }
    return self;
}

- (void)initialize {
    self.backgroundColor = [UIColor clearColor];
	self.opaque = NO;
	CGRect frame = self.bounds;
	frame.size.height -= 0.0;
	frame.origin.x -= 1.0;
	_textLabel = [[UILabel alloc] initWithFrame:frame];
	_textLabel.textColor = [UIColor whiteColor];
	_textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
	_textLabel.textAlignment = NSTextAlignmentCenter;
	_textLabel.center = CGPointMake(frame.size.width / 2.0, frame.size.height / 2.0);
	[self addSubview:_textLabel];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0].CGColor);
	CGContextFillEllipseInRect(context, rect);
}

@end
