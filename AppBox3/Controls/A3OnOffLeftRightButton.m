//
//  A3OnOffLeftRightButton.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 05/21/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "A3OnOffLeftRightButton.h"

@implementation A3OnOffLeftRightButton

- (void)awakeFromNib {
	[super awakeFromNib];

	UIColor *titleColor;
	titleColor = [UIColor colorWithRed:254.0 / 255.0 green:254.0 / 255.0 blue:254.0 / 255.0 alpha:1.0];
	[super setTitleColor:titleColor forState:UIControlStateSelected];
	[super setTitleColor:titleColor forState:UIControlStateHighlighted];
	titleColor = [UIColor colorWithRed:57.0 / 255.0 green:57.0 / 255.0 blue:57.0 / 255.0 alpha:1.0];
	[super setTitleColor:titleColor forState:UIControlStateNormal];
}


- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];

	CGRect borderRect = rect;

	UIRectCorner rectCorner;
	if (_left) {
		rectCorner = UIRectCornerTopLeft | UIRectCornerBottomLeft;
	} else {
		rectCorner = UIRectCornerTopRight | UIRectCornerBottomRight;
	}
	UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:borderRect byRoundingCorners:rectCorner cornerRadii:CGSizeMake(5.0, 5.0)];
	if (self.selected || self.highlighted) {
		[[UIColor colorWithRed:40.0 / 255.0 green:42.0 / 255.0 blue:40.0 / 255.0 alpha:1.0] setFill];
		[bezierPath fill];

		[[UIColor colorWithRed:13.0 / 255.0 green:13.0 / 255.0 blue:13.0 / 255.0 alpha:1.0] setStroke];
		[bezierPath stroke];
	} else {
		[[UIColor colorWithRed:200.0 / 255.0 green:200.0 / 255.0 blue:201.0 / 255.0 alpha:1.0] setFill];
		[bezierPath fill];

		[[UIColor colorWithRed:13.0 / 255.0 green:13.0 / 255.0 blue:13.0 / 255.0 alpha:1.0] setStroke];
		[bezierPath stroke];

		if (_left) {
			borderRect.origin.x += 1.0;
			borderRect.size.width -= 2.0;
		} else {
			borderRect.origin.x += 1.0;
			borderRect.size.width -= 2.0;
		}

		borderRect.origin.y += 2.0;
		borderRect.size.height -= 5.0;
		UIBezierPath *gradientPath = [UIBezierPath bezierPathWithRoundedRect:borderRect byRoundingCorners:rectCorner cornerRadii:CGSizeMake(5.0, 5.0)];
		[gradientPath addClip];

		CGContextRef context=UIGraphicsGetCurrentContext();

		CGContextSaveGState(context);
		UIColor *ucolor1=[UIColor colorWithRed:252.0/255.0 green:253.0/255.0 blue:254.0/255.0 alpha:1.0];
		UIColor *ucolor2=[UIColor colorWithRed:243.0/255.0 green:244.0/255.0 blue:245.0/255.0 alpha:1.0];

		NSArray *colors = @[(id)ucolor1.CGColor, (id)ucolor2.CGColor];

		CGGradientRef gradient;
		CGFloat locations[2] = { 0.0, 1.0 };
		gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);

		CGPoint topCenter, midCenter;
		topCenter = CGPointMake(CGRectGetMidX(borderRect), -(self.frame.origin.y));
		midCenter = CGPointMake(CGRectGetMidX(borderRect), self.superview.bounds.size.height-(self.frame.origin.y));

		CGContextDrawLinearGradient(context, gradient, topCenter, midCenter, 0);
		CGGradientRelease(gradient);
		CGContextRestoreGState(context);
	}
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];
	[self setNeedsDisplay];
}

- (void)setHighlighted:(BOOL)highlighted {
	[super setHighlighted:highlighted];
	[self setNeedsDisplay];
}

@end
