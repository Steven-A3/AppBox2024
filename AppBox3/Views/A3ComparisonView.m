//
//  A3ComparisonView
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/24/13 9:27 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3ComparisonView.h"

@interface A3ComparisonView ()
@end

@implementation A3ComparisonView {

}

- (void)awakeFromNib {
	[super awakeFromNib];

	self.backgroundColor = [UIColor clearColor];
}

- (CGSize)sizeThatFits:(CGSize)size {
	return CGSizeMake(size.width, 28.0);
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];

	CGContextRef context = UIGraphicsGetCurrentContext();

	if ([self.leftValue isEqualToNumber:self.rightValue]) {
		[self.bigColor setFill];
		CGContextFillRect(context, rect);
	} else {
		UIBezierPath *leftPath, *rightPath;
		UIColor *leftColor, *rightColor;
		NSComparisonResult result = [self.leftValue compare:self.rightValue];
		if (result == NSOrderedSame || result == NSOrderedAscending) {
			leftPath = [self leftSmallPathWithRect:rect];
			rightPath = [self rightBigPathWithRect:rect];
			leftColor = self.smallColor;
			rightColor = self.bigColor;
		} else {
			leftPath = [self leftBigPathWithRect:rect];
			rightPath = [self rightSmallPathWithRect:rect];
			leftColor = self.bigColor;
			rightColor = self.smallColor;
		}
		CGContextSaveGState(context);
		[leftColor setFill];
		[leftPath addClip];
		[leftPath fill];
		CGContextRestoreGState(context);

		CGContextSaveGState(context);
		[rightColor setFill];
		[rightPath addClip];
		[rightPath fill];
		CGContextRestoreGState(context);
	}
}

- (UIColor *)bigColor {
	return [UIColor colorWithRed:55.0 / 255.0 green:84.0 / 255.0 blue:135.0 / 255.0 alpha:1.0];
}

- (UIColor *)smallColor {
	return [UIColor colorWithRed:189.0 / 255.0 green:190.0 / 255.0 blue:190.0 / 255.0 alpha:1.0];
}

- (UIBezierPath *)leftSmallPathWithRect:(CGRect)rect {
	CGFloat minX = CGRectGetMinX(rect);
	CGFloat minY = CGRectGetMinY(rect);
	CGFloat midX = CGRectGetMidX(rect);
	CGFloat midY = CGRectGetMidY(rect);
	CGFloat maxY = CGRectGetMaxY(rect);
	CGFloat gap = 10.0;

	// Path for left side for small
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:(CGPoint) {minX, minY}];
	[path addLineToPoint:(CGPoint) {midX - gap, minY}];
	[path addLineToPoint:(CGPoint) {midX - gap * 2.0, midY}];
	[path addLineToPoint:(CGPoint) {midX - gap, maxY}];
	[path addLineToPoint:(CGPoint) {minX, maxY}];
	[path closePath];

	return path;
}

- (UIBezierPath *)leftBigPathWithRect:(CGRect)rect {
	CGFloat minX = CGRectGetMinX(rect);
	CGFloat minY = CGRectGetMinY(rect);
	CGFloat midX = CGRectGetMidX(rect);
	CGFloat midY = CGRectGetMidY(rect);
	CGFloat maxY = CGRectGetMaxY(rect);
	CGFloat gap = 10.0;

	// Path for left side for small
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:(CGPoint) {minX, minY}];
	[path addLineToPoint:(CGPoint) {midX, minY}];
	[path addLineToPoint:(CGPoint) {midX + gap, midY}];
	[path addLineToPoint:(CGPoint) {midX, maxY}];
	[path addLineToPoint:(CGPoint) {minX, maxY}];
	[path closePath];
	return path;
}

- (UIBezierPath *)rightSmallPathWithRect:(CGRect)rect {
	CGFloat maxX = CGRectGetMaxX(rect);
	CGFloat minY = CGRectGetMinY(rect);
	CGFloat midX = CGRectGetMidX(rect);
	CGFloat midY = CGRectGetMidY(rect);
	CGFloat maxY = CGRectGetMaxY(rect);
	CGFloat gap = 10.0;

	// Path for left side for small
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:(CGPoint) {maxX, minY}];
	[path addLineToPoint:(CGPoint) {midX + gap, minY}];
	[path addLineToPoint:(CGPoint) {midX + gap * 2.0, midY}];
	[path addLineToPoint:(CGPoint) {midX + gap, maxY}];
	[path addLineToPoint:(CGPoint) {maxX, maxY}];
	[path closePath];
	return path;
}

- (UIBezierPath *)rightBigPathWithRect:(CGRect)rect {
	CGFloat maxX = CGRectGetMaxX(rect);
	CGFloat minY = CGRectGetMinY(rect);
	CGFloat midX = CGRectGetMidX(rect);
	CGFloat midY = CGRectGetMidY(rect);
	CGFloat maxY = CGRectGetMaxY(rect);
	CGFloat gap = 10.0;

	// Path for left side for small
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:(CGPoint) {maxX, minY}];
	[path addLineToPoint:(CGPoint) {midX, minY}];
	[path addLineToPoint:(CGPoint) {midX - gap, midY}];
	[path addLineToPoint:(CGPoint) {midX, maxY}];
	[path addLineToPoint:(CGPoint) {maxX, maxY}];
	[path closePath];
	return path;
}


@end