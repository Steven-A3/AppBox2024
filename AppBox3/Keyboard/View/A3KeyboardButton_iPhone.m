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

- (void)applySelectedColor {
	_gradientStart = [UIColor colorWithRed:70.0/255.0 green:129.0/255.0 blue:223.0/255 alpha:1];
	_gradientEnd = [UIColor colorWithRed:45.0/255.0 green:94.0/255.0 blue:181.0/255 alpha:1];
	_topColor1 = [UIColor colorWithRed:121.0/255.0 green:123.0/255.0 blue:126.0/255.0 alpha:1.0];
	_topColor2 = [UIColor colorWithRed:108.0/255.0 green:172.0/255.0 blue:249.0/255.0 alpha:1.0];
}

- (void)applyHighlightedColor {
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
}

- (void)applyColorForState {
	if (self.highlighted) {
		[self applyHighlightedColor];
	} else if (self.selected) {
		[self applySelectedColor];
	} else {
		[self setGradientColor];
	}

	[self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected{
	[super setSelected:selected];

	[self applyColorForState];
}

- (void)setHighlighted:(BOOL)highlighted {
	[super setHighlighted:highlighted];

	[self applyColorForState];
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

- (UIColor *)subTitleColor {
	return [UIColor colorWithRed:80.0/255.0 green:89.0/255.0 blue:102.0/255.0 alpha:1.0];
}

- (UILabel *)mainTitle {
	if (nil == _mainTitle) {
		CGRect frame = self.bounds;
		frame.size.height = frame.size.height * 0.75;
		_mainTitle = [[UILabel alloc] initWithFrame:frame];
		_mainTitle.backgroundColor = [UIColor clearColor];
		_mainTitle.font = super.titleLabel.font;
		_mainTitle.textColor = [super titleColorForState:UIControlStateNormal];
		_mainTitle.shadowOffset = CGSizeMake(0.0, 1.0);
		_mainTitle.shadowColor = [UIColor whiteColor];
		_mainTitle.textAlignment = NSTextAlignmentCenter;
		[self addSubview:_mainTitle];
	}
	return _mainTitle;
}

- (UILabel *)subTitle {
	if (nil == _subTitle) {
		CGRect frame = self.bounds;
		frame.origin.y += frame.size.height * 0.45;
		frame.size.height -= frame.size.height * 0.4;
		_subTitle = [[UILabel alloc] initWithFrame:frame];
		_subTitle.backgroundColor = [UIColor clearColor];
		_subTitle.font = [UIFont boldSystemFontOfSize:14.0];
		_subTitle.textColor = [self subTitleColor];
		_subTitle.textAlignment = NSTextAlignmentCenter;
		_subTitle.shadowOffset = CGSizeMake(0.0, 1.0);
		_subTitle.shadowColor = [UIColor whiteColor];
		[self addSubview:_subTitle];
	}
	return _subTitle;
}

- (void)removeExtraLabels {
	[_mainTitle removeFromSuperview];
	_mainTitle = nil;
	[_subTitle removeFromSuperview];
	_subTitle = nil;
}

@end
