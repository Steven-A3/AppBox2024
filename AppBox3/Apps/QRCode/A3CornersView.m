//
//  A3CornersView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/12/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3CornersView.h"

@interface A3CornersView ()

@property (nonatomic, strong) UIBezierPath *cornersPath;

@end

@implementation A3CornersView {
	CGFloat _cornerWidth, _cornerHeight;
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	_cornersPath = nil;
}

- (void)setBounds:(CGRect)bounds {
	[super setBounds:bounds];

	_cornersPath = nil;
}

- (UIBezierPath *)cornersPath {
	if (!_cornersPath) {
		CGSize size = self.bounds.size;
		_cornerWidth = size.width * 0.1;
		_cornerHeight = size.height * 0.09;

		_cornersPath = [UIBezierPath new];
		[_cornersPath moveToPoint:CGPointMake(0, _cornerHeight)];
		[_cornersPath addLineToPoint:CGPointMake(0, 0)];
		[_cornersPath addLineToPoint:CGPointMake(_cornerWidth, 0)];

		[_cornersPath moveToPoint:CGPointMake(size.width - _cornerWidth, 0)];
		[_cornersPath addLineToPoint:CGPointMake(size.width, 0)];
		[_cornersPath addLineToPoint:CGPointMake(size.width, _cornerHeight)];

		[_cornersPath moveToPoint:CGPointMake(size.width, size.height - _cornerHeight)];
		[_cornersPath addLineToPoint:CGPointMake(size.width, size.height)];
		[_cornersPath addLineToPoint:CGPointMake(size.width - _cornerWidth, size.height)];

		[_cornersPath moveToPoint:CGPointMake(_cornerWidth, size.height)];
		[_cornersPath addLineToPoint:CGPointMake(0, size.height)];
		[_cornersPath addLineToPoint:CGPointMake(0, size.height - _cornerHeight)];

		_cornersPath.lineWidth = 10;
	}
	return _cornersPath;
}

- (void)drawRect:(CGRect)rect {
	[[UIColor whiteColor] setStroke];
	[self.cornersPath stroke];
}

@end
