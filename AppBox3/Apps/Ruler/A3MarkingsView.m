//
//  A3MarkingsView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2015. 2. 28..
//  Copyright (c) 2015년 ALLABOUTAPPS. All rights reserved.
//

#import "A3MarkingsView.h"

@implementation A3MarkingsView

- (instancetype)init {
	self = [super init];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
	}

	return self;
}

- (void)drawRect:(CGRect)rect {
	if (_markingsType == A3MarkingsTypeCentimeters) {
		if (_verticalDirection == A3MarkingsVerticalDirectionUp) {
			[self drawCentimetersUpwardInRect:rect];
		} else {
			[self drawCentimetersDownwardInRect:rect];
		}
	} else {
		if (_verticalDirection == A3MarkingsVerticalDirectionUp) {
			[self drawInchesUpwardInRect:rect];
		} else {
			[self drawInchesDownwardInRect:rect];
		}
	}
}

- (void)drawCentimetersUpwardInRect:(CGRect)rect {
	CGFloat lineWidth = 1.0;
	UIBezierPath *drawingPath = [UIBezierPath new];
	if (_drawPortrait) {
		[drawingPath moveToPoint:CGPointMake(rect.origin.x, rect.origin.y + rect.size.height - 1.0)];
		[drawingPath addLineToPoint:CGPointMake(rect.origin.x + rect.size.width, rect.size.height - 1.0)];

		CGFloat space = (rect.size.height - lineWidth * 10.0)/10.0;

		for (NSInteger idx = 0; idx < 9; idx++) {
			CGFloat margin = idx == 4 ? rect.size.width * 0.2 :rect.size.width * 0.4;
			CGFloat y = rect.origin.y + rect.size.height - (idx + 1) * space - ((idx + 1) * lineWidth) - 1.0;
			if (_horizontalDirection == A3MarkingsDirectionRight) {
				[drawingPath moveToPoint:CGPointMake(rect.origin.x + margin, y)];
				[drawingPath addLineToPoint:CGPointMake(rect.origin.x + rect.size.width, y)];
			} else {
				[drawingPath moveToPoint:CGPointMake(rect.origin.x, y)];
				[drawingPath addLineToPoint:CGPointMake(rect.origin.x + rect.size.width - margin, y)];
			}
		}
	} else {
		[drawingPath moveToPoint:CGPointMake(rect.origin.x + lineWidth, rect.origin.y)];
		[drawingPath addLineToPoint:CGPointMake(rect.origin.x + lineWidth, rect.origin.y + rect.size.height)];

		CGFloat space = (rect.size.width - lineWidth * 10.0)/10.0;

		for (NSInteger idx = 0; idx < 9; idx++) {
			CGFloat margin = idx == 4 ? rect.size.height * 0.2 :rect.size.height * 0.4;
			CGFloat x = rect.origin.x + (idx + 1) * space + ((idx + 1) * lineWidth) + 1.0;
			if (_horizontalDirection == A3MarkingsDirectionRight) {
				[drawingPath moveToPoint:CGPointMake(x, rect.origin.y + margin)];
				[drawingPath addLineToPoint:CGPointMake(x, rect.origin.y + rect.size.height)];
			} else {
				[drawingPath moveToPoint:CGPointMake(x, rect.origin.y)];
				[drawingPath addLineToPoint:CGPointMake(x, rect.origin.y + rect.size.height - margin)];
			}
		}
	}
	[[UIColor blackColor] setStroke];
	[drawingPath stroke];
}

- (void)drawCentimetersDownwardInRect:(CGRect)rect {
	CGFloat lineWidth = 1.0;
	UIBezierPath *drawingPath = [UIBezierPath new];
	if (_drawPortrait) {
		[drawingPath moveToPoint:CGPointMake(rect.origin.x, rect.origin.y + 1)];
		[drawingPath addLineToPoint:CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + 1)];

		CGFloat space = (rect.size.height - lineWidth * 10.0)/10.0;

		for (NSInteger idx = 0; idx < 9; idx++) {
			CGFloat margin = idx == 4 ? rect.size.width * 0.2 :rect.size.width * 0.4;
			CGFloat y = rect.origin.y + rect.size.height - (idx + 1) * space - ((idx + 1) * lineWidth) + lineWidth;
			if (_horizontalDirection == A3MarkingsDirectionRight) {
				[drawingPath moveToPoint:CGPointMake(rect.origin.x + margin, y)];
				[drawingPath addLineToPoint:CGPointMake(rect.origin.x + rect.size.width, y)];
			} else {
				[drawingPath moveToPoint:CGPointMake(rect.origin.x, y)];
				[drawingPath addLineToPoint:CGPointMake(rect.origin.x + rect.size.width - margin, y)];
			}
		}
	} else {
		[drawingPath moveToPoint:CGPointMake(rect.origin.x + rect.size.width - lineWidth, rect.origin.y)];
		[drawingPath addLineToPoint:CGPointMake(rect.origin.x + rect.size.width - lineWidth, rect.origin.y + rect.size.height)];

		CGFloat space = (rect.size.width - lineWidth * 10.0)/10.0;

		for (NSInteger idx = 0; idx < 9; idx++) {
			CGFloat margin = idx == 4 ? rect.size.height * 0.2 :rect.size.height * 0.4;
			CGFloat x = rect.origin.x + (idx + 1) * space + ((idx + 1) * lineWidth) + lineWidth - 2.0;
			if (_horizontalDirection == A3MarkingsDirectionRight) {
				[drawingPath moveToPoint:CGPointMake(x, rect.origin.y + margin)];
				[drawingPath addLineToPoint:CGPointMake(x, rect.origin.y + rect.size.height)];
			} else {
				[drawingPath moveToPoint:CGPointMake(x, rect.origin.y)];
				[drawingPath addLineToPoint:CGPointMake(x, rect.origin.y + rect.size.height - margin)];
			}
		}
	}
	[[UIColor blackColor] setStroke];
	[drawingPath stroke];
}

- (void)drawInchesUpwardInRect:(CGRect)rect {
	CGFloat lineWidth = 1.0;
	UIBezierPath *drawingPath = [UIBezierPath new];

	if (_drawPortrait) {
		[drawingPath moveToPoint:CGPointMake(rect.origin.x, rect.origin.y + rect.size.height - lineWidth - 1.0)];
		[drawingPath addLineToPoint:CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - lineWidth - 1.0)];

		CGFloat space = (rect.size.height - lineWidth * 16.0)/16.0;

		for (NSInteger idx = 0; idx < 15; idx++) {
			CGFloat margin;
			if (idx % 2 == 0) {
				margin = rect.size.width * 0.6;
			} else {
				margin = idx == 7 ? rect.size.width * 0.2 : rect.size.width * 0.4;
			}
			CGFloat y = rect.origin.y + rect.size.height - (idx + 1) * space - ((idx + 1) * lineWidth) - lineWidth - 1.0;
			if (_horizontalDirection == A3MarkingsDirectionRight) {
				[drawingPath moveToPoint:CGPointMake(rect.origin.x + margin, y)];
				[drawingPath addLineToPoint:CGPointMake(rect.origin.x + rect.size.width, y)];
			} else {
				[drawingPath moveToPoint:CGPointMake(rect.origin.x, y)];
				[drawingPath addLineToPoint:CGPointMake(rect.origin.x + rect.size.width - margin, y)];
			}
		}
	} else {
		[drawingPath moveToPoint:CGPointMake(rect.origin.x + lineWidth, rect.origin.y)];
		[drawingPath addLineToPoint:CGPointMake(rect.origin.x + lineWidth, rect.origin.y + rect.size.height)];

		CGFloat space = (rect.size.width - lineWidth * 16.0)/16.0;

		for (NSInteger idx = 0; idx < 15; idx++) {
			CGFloat margin;
			if (idx % 2 == 0) {
				margin = rect.size.height * 0.6;
			} else {
				margin = idx == 7 ? rect.size.height * 0.2 : rect.size.height * 0.4;
			}
			CGFloat x = rect.origin.x + (idx + 1) * space + ((idx + 1) * lineWidth) + lineWidth + 1.0;
			if (_horizontalDirection == A3MarkingsDirectionRight) {
				[drawingPath moveToPoint:CGPointMake(x, rect.origin.y + margin)];
				[drawingPath addLineToPoint:CGPointMake(x, rect.origin.y + rect.size.height)];
			} else {
				[drawingPath moveToPoint:CGPointMake(x, rect.origin.y)];
				[drawingPath addLineToPoint:CGPointMake(x, rect.origin.y + rect.size.height - margin)];
			}
		}
	}
	[[UIColor blackColor] setStroke];
	[drawingPath stroke];
}

- (void)drawInchesDownwardInRect:(CGRect)rect {
	CGFloat lineWidth = 1.0;
	UIBezierPath *drawingPath = [UIBezierPath new];

	if (_drawPortrait) {
		[drawingPath moveToPoint:CGPointMake(rect.origin.x, rect.origin.y + 1)];
		[drawingPath addLineToPoint:CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + 1)];

		CGFloat space = (rect.size.height - lineWidth * 16.0)/16.0;

		for (NSInteger idx = 0; idx < 15; idx++) {
			CGFloat margin;
			if (idx % 2 == 0) {
				margin = rect.size.width * 0.6;
			} else {
				margin = idx == 7 ? rect.size.width * 0.2 : rect.size.width * 0.4;
			}
			CGFloat y = rect.origin.y + rect.size.height - (idx + 1) * space - ((idx + 1) * lineWidth) + lineWidth;
			if (_horizontalDirection == A3MarkingsDirectionRight) {
				[drawingPath moveToPoint:CGPointMake(rect.origin.x + margin, y)];
				[drawingPath addLineToPoint:CGPointMake(rect.origin.x + rect.size.width, y)];
			} else {
				[drawingPath moveToPoint:CGPointMake(rect.origin.x, y)];
				[drawingPath addLineToPoint:CGPointMake(rect.origin.x + rect.size.width - margin, y)];
			}
		}
	} else {
		[drawingPath moveToPoint:CGPointMake(rect.origin.x + rect.size.width - lineWidth, rect.origin.y)];
		[drawingPath addLineToPoint:CGPointMake(rect.origin.x + rect.size.width - lineWidth, rect.origin.y + rect.size.height)];

		CGFloat space = (rect.size.width - lineWidth * 16.0)/16.0;

		for (NSInteger idx = 0; idx < 15; idx++) {
			CGFloat margin;
			if (idx % 2 == 0) {
				margin = rect.size.height * 0.6;
			} else {
				margin = idx == 7 ? rect.size.height * 0.2 : rect.size.height * 0.4;
			}
			CGFloat x = rect.origin.x + (idx + 1) * space + ((idx + 1) * lineWidth) + lineWidth - 2.0;
			if (_horizontalDirection == A3MarkingsDirectionRight) {
				[drawingPath moveToPoint:CGPointMake(x, rect.origin.y + margin)];
				[drawingPath addLineToPoint:CGPointMake(x, rect.origin.y + rect.size.height)];
			} else {
				[drawingPath moveToPoint:CGPointMake(x, rect.origin.y)];
				[drawingPath addLineToPoint:CGPointMake(x, rect.origin.y + rect.size.height - margin)];
			}
		}
	}
	[[UIColor blackColor] setStroke];
	[drawingPath stroke];
}

@end
