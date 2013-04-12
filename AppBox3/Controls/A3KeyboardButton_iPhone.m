//
//  A3KeyboardButton_iPhone.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/9/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3KeyboardButton_iPhone.h"

@interface A3KeyboardButton_iPhone ()
@property (nonatomic, strong) UIColor *topColor1;
@property (nonatomic, strong) UIColor *topColor2;
@property (nonatomic, strong) UIColor *gradientStart, *gradientEnd;
@end

@implementation A3KeyboardButton_iPhone

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setGradientColor {
	if (_colorDarkGray) {
		_gradientStart = [UIColor colorWithRed:111.0/255.0 green:118.0/255.0 blue:131.0/255.0 alpha:1.0];
		_gradientEnd = [UIColor colorWithRed:78.0/255.0 green:85.0/255.0 blue:99.0/255.0 alpha:1.0];
		_topColor1 = [UIColor colorWithRed:53.0/255.0 green:58.0/255.0 blue:68.0/255.0 alpha:1.0];
		_topColor2 = [UIColor colorWithRed:168.0/255.0 green:174.0/255.0 blue:182.0/255.0 alpha:1.0];
	} else {
		_gradientStart = [UIColor colorWithRed:223.0/255.0 green:224.0/255.0 blue:227.0/255.0 alpha:1.0];
		_gradientEnd = [UIColor colorWithRed:180.0/255.0 green:184.0/255.0 blue:191.0/255.0 alpha:1.0];
		_topColor1 = [UIColor colorWithRed:89.0/255.0 green:91.0/255.0 blue:94.0/255.0 alpha:1.0];
		_topColor2 = [UIColor whiteColor];
	}
}

- (void)awakeFromNib {
	[super awakeFromNib];

	self.contentMode = UIViewContentModeRedraw;

	[self setGradientColor];
}

- (void)setSelected:(BOOL)selected{
	[super setSelected:selected];

	if (selected) {
		_gradientStart = [UIColor colorWithRed:70.0/255.0 green:129.0/255.0 blue:223.0/255 alpha:1];
		_gradientEnd = [UIColor colorWithRed:45.0/255.0 green:94.0/255.0 blue:181.0/255 alpha:1];
		_topColor1 = [UIColor colorWithRed:121.0/255.0 green:123.0/255.0 blue:126.0/255.0 alpha:1.0];
		_topColor2 = [UIColor colorWithRed:108.0/255.0 green:172.0/255.0 blue:249.0/255.0 alpha:1.0];
	} else {
		[self setGradientColor];
	}
	[self setNeedsDisplay];
}

- (void)setHighlighted:(BOOL)highlighted {
	[super setHighlighted:highlighted];

	if (highlighted) {
		if (_colorDarkGray) {
			_gradientStart = [UIColor colorWithRed:223.0/255.0 green:224.0/255.0 blue:227.0/255.0 alpha:1.0];
			_gradientEnd = [UIColor colorWithRed:180.0/255.0 green:184.0/255.0 blue:191.0/255.0 alpha:1.0];
			_topColor1 = [UIColor colorWithRed:89.0/255.0 green:91.0/255.0 blue:94.0/255.0 alpha:1.0];
			_topColor2 = [UIColor whiteColor];
		} else {
			_gradientStart = [UIColor colorWithRed:111.0/255.0 green:118.0/255.0 blue:131.0/255.0 alpha:1.0];
			_gradientEnd = [UIColor colorWithRed:78.0/255.0 green:85.0/255.0 blue:99.0/255.0 alpha:1.0];
			_topColor1 = [UIColor colorWithRed:53.0/255.0 green:58.0/255.0 blue:68.0/255.0 alpha:1.0];
			_topColor2 = [UIColor colorWithRed:168.0/255.0 green:174.0/255.0 blue:182.0/255.0 alpha:1.0];
		}
	} else {
		[self setGradientColor];
	}
	[self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
// Drawing code
	CGContextRef context=UIGraphicsGetCurrentContext();

	CGContextSaveGState(context);

	CGColorRef color1=_gradientStart.CGColor;
	CGColorRef color2=_gradientEnd.CGColor;

	CGGradientRef gradient;
	CGFloat locations[2] = { 0.0, 1.0 };
	NSArray *colors = [NSArray arrayWithObjects:(__bridge id)color1, (__bridge id)color2, nil];

	gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);

	CGRect currentBounds = self.bounds;
	CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
	CGPoint midCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMaxY(currentBounds));

	CGContextDrawLinearGradient(context, gradient, topCenter, midCenter, 0);
	CGGradientRelease(gradient);

	[_topColor1 setFill];
	CGContextFillRect(context, CGRectMake(0, 0, rect.size.width, 1));
	CGContextFillRect(context, CGRectMake(0, 0, 1, rect.size.height));
	[_topColor2 setFill];
	CGContextFillRect(context, CGRectMake(1, 1, rect.size.width, 1));

	CGContextRestoreGState(context);    // Drawing code
}

@end
