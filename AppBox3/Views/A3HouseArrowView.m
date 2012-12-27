//
//  A3HouseArrowView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 12/12/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3HouseArrowView.h"
#import "A3UIKit.h"
#import "common.h"

@implementation A3HouseArrowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

		_changeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_changeLabel.backgroundColor = [UIColor clearColor];
		_changeLabel.font = [UIFont boldSystemFontOfSize:14.0f];
		_changeLabel.textAlignment = NSTextAlignmentCenter;
		[self addSubview:_changeLabel];

		_nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_nameLabel.backgroundColor = [UIColor clearColor];
		_nameLabel.textColor = [UIColor whiteColor];
		_nameLabel.font = [UIFont boldSystemFontOfSize:15.0f];
		_nameLabel.textAlignment = NSTextAlignmentCenter;
		[self addSubview:_nameLabel];

		_valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_valueLabel.backgroundColor = [UIColor clearColor];
		_valueLabel.textColor = [UIColor whiteColor];
		_valueLabel.font = [UIFont boldSystemFontOfSize:15.0f];
		_valueLabel.textAlignment = NSTextAlignmentCenter;
		[self addSubview:_valueLabel];

		[self layoutSubviews];

		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];

	CGFloat labelHeight;
	CGFloat offsetX = 0.0f;
	CGFloat offsetY;
	CGFloat width = self.bounds.size.width;

	if ([_changeLabel.text doubleValue] >= 0.0) {
		// Order will be changeLabel, nameLabel, valueLabel
		offsetY = 8.0f;
		labelHeight = 15.0f;
		[_changeLabel setFrame:CGRectMake(offsetX, offsetY, width, labelHeight)];
		offsetY += labelHeight;

		labelHeight = 17.0f;
		[_nameLabel setFrame:CGRectMake(offsetX, offsetY, width, labelHeight)];
		offsetY += labelHeight;

		labelHeight = 17.0f;
		[_valueLabel setFrame:CGRectMake(offsetX, offsetY, width, labelHeight)];

		_changeLabel.textColor = [UIColor colorWithRed:206.0f/255.0f green:252.0f/255.0f blue:46.0f/255.0f alpha:1.0f];
	} else {
		// Order will be nameLabel, valueLabel, changeLabel
		offsetY = 5.0f;
		labelHeight = 17.0f;
		[_nameLabel setFrame:CGRectMake(offsetX, offsetY, width, labelHeight)];
		offsetY += labelHeight;

		labelHeight = 17.0f;
		[_valueLabel setFrame:CGRectMake(offsetX, offsetY, width, labelHeight)];
		offsetY += labelHeight;

		labelHeight = 15.0f;
		[_changeLabel setFrame:CGRectMake(0.0f, offsetY, width, labelHeight)];

		_changeLabel.textColor = [UIColor colorWithRed:254.0f/255.0f green:115.0f/255.0f blue:96.0f/255.0f alpha:1.0f];
	}
}

- (BOOL)isGreen {
	return [_changeLabel.text doubleValue] >= 0.0;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGFloat width = CGRectGetWidth(rect);
//	CGFloat height = CGRectGetHeight(rect);
	CGFloat marginH = 15.0f, roofHeight = 22.0f;
	CGFloat minX = CGRectGetMinX(rect);
	CGFloat minY = CGRectGetMinY(rect);
	CGFloat maxX = CGRectGetMaxX(rect);
	CGFloat maxY = CGRectGetMaxY(rect);

	if (![self isGreen]) {
		CGContextTranslateCTM(context, CGRectGetWidth(rect), CGRectGetHeight(rect));
		CGContextRotateCTM(context, DegreesToRadians(-180));
	}

	CGContextMoveToPoint(context, width / 2.0f, minY);
	CGContextAddLineToPoint(context, minX, minY + roofHeight);
	CGContextAddLineToPoint(context, marginH, minY + roofHeight);
	CGContextAddLineToPoint(context, marginH, maxY);
	CGContextAddLineToPoint(context, maxX - marginH, maxY);
	CGContextAddLineToPoint(context, maxX - marginH, minY + roofHeight);
	CGContextAddLineToPoint(context, maxX, minY + roofHeight);
	CGContextClosePath(context);
	CGContextClip(context);

	NSArray *gradientColors;

	if ([self isGreen]) {
		gradientColors = @[(__bridge id)[UIColor colorWithRed:109.0f/255.0f green:207.0f/255.0f blue:79.0f/255.0f alpha:1.0f].CGColor,
				(__bridge id)[UIColor colorWithRed:46.0f/255.0f green:144.0f/255.0f blue:22.0f/255.0f alpha:1.0f].CGColor];
	} else {
		gradientColors = @[(__bridge id)[UIColor colorWithRed:143.0f/255.0f green:10.0f/255.0f blue:16.0f/255.0f alpha:1.0f].CGColor,
				(__bridge id)[UIColor colorWithRed:246.0f/255.0f green:71.0f/255.0f blue:63.0f/255.0f alpha:1.0f].CGColor];
	}

	[A3UIKit drawLinearGradientToContext:context rect:rect withColors:gradientColors];

}

@end
