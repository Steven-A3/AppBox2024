//
//  A3ComparisonView
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/24/13 9:27 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3ComparisonView.h"
#import "CPTPlatformSpecificCategories.h"

@interface A3ComparisonView ()
@property (nonatomic, strong) UILabel *leftValueLabel;
@property (nonatomic, strong) UILabel *rightValueLabel;
@end

@implementation A3ComparisonView {

}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self addSubview:self.leftValueLabel];
		[self addSubview:self.rightValueLabel];
	}

	return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
	return CGSizeMake(size.width, 28.0);
}

- (void)applyLabelAttribute:(UILabel *)label {
	label.font = [UIFont boldSystemFontOfSize:22.0];
	label.textColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor clearColor];
}

- (UILabel *)leftValueLabel {
	if (nil == _leftValueLabel) {
		CGRect frame = self.bounds;
		frame.origin.x += 10.0;
		frame.size.width = frame.size.width / 2.0 - 10.0;
		_leftValueLabel = [[UILabel alloc] initWithFrame:frame];
		[self applyLabelAttribute:_leftValueLabel];
	}
	return _leftValueLabel;
}

- (void)setLeftValue:(NSNumber *)leftValue {
	_leftValue = leftValue;
}

- (void)setRightValue:(NSNumber *)rightValue {
	_rightValue = rightValue;
}

- (UILabel *)rightValueLabel {
	if (nil == _rightValueLabel) {
		CGRect frame = self.bounds;
		frame.origin.x = CGRectGetMinX(frame) + CGRectGetWidth(frame) / 2.0;
		frame.size.width = frame.size.width / 2.0 - 10.0;
		_rightValueLabel = [[UILabel alloc] initWithFrame:frame];
		[self applyLabelAttribute:_rightValueLabel];
	}
	return _rightValueLabel;
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
		if ([self.leftValue isLessThan:self.rightValue]) {
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
		[leftColor setFill];
		[leftPath addClip];
		[leftPath fill];

		[rightColor setFill];
		[rightPath addClip];
		[rightPath fill];
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
	[path moveToPoint:(CGPoint) {maxX, maxY}];
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
	[path moveToPoint:(CGPoint) {maxX, maxY}];
	[path addLineToPoint:(CGPoint) {midX, minY}];
	[path addLineToPoint:(CGPoint) {midX - gap, midY}];
	[path addLineToPoint:(CGPoint) {midX, maxY}];
	[path addLineToPoint:(CGPoint) {maxX, maxY}];
	[path closePath];
	return path;
}


@end