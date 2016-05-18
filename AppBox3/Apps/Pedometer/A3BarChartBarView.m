//
//  A3BarChartBarView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/13/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3BarChartBarView.h"

@interface A3BarChartBarView()

@property (nonatomic, strong) UIBezierPath *breakPath;

@end

@implementation A3BarChartBarView

- (UIBezierPath *)breakPath {
	if (!_breakPath) {
		_breakPath = [UIBezierPath new];
		CGFloat width = self.bounds.size.width;
		CGFloat height = self.bounds.size.height * 0.03;
		CGFloat offset = self.bounds.size.height * 0.2;
		CGFloat controlPointHeight = width / 4;
		[_breakPath moveToPoint:CGPointMake(0, offset)];
		[_breakPath addCurveToPoint:CGPointMake(width, offset)
					  controlPoint1:CGPointMake(width/2, offset - controlPointHeight)
					  controlPoint2:CGPointMake(width/2, offset + controlPointHeight)];
		[_breakPath addLineToPoint:CGPointMake(width, offset + height)];
		[_breakPath addCurveToPoint:CGPointMake(0, offset + height)
					  controlPoint1:CGPointMake(width/2, offset + height + controlPointHeight)
					  controlPoint2:CGPointMake(width/2, offset + height - controlPointHeight)];
		[_breakPath closePath];
	}
	return _breakPath;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	// Drawing code
	if (_drawBreakMark) {
		[[UIColor whiteColor] setFill];
		[self.breakPath fill];
	}
}

@end
