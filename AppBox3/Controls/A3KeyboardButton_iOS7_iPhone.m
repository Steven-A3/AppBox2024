//
//  A3KeyboardButton_iOS7_iPhone.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/25/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3KeyboardButton_iOS7_iPhone.h"

@interface A3KeyboardButton_iOS7_iPhone ()

@property (nonatomic, strong) CALayer *selectedMarkLayer;

@end

@implementation A3KeyboardButton_iOS7_iPhone


- (void)awakeFromNib {
	[super awakeFromNib];

	[self configureLayer];
}

- (void)configureLayer {
	self.layer.borderColor = [UIColor colorWithRed:220.0/255.0 green:223.0/255.0 blue:227.0/255.0 alpha:1.0].CGColor;
	self.layer.borderWidth = 1.0;
	[self.layer addSublayer:self.selectedMarkLayer];
}

- (void)setHighlighted:(BOOL)highlighted {
	[super setHighlighted:highlighted];

	_selectedMarkLayer.hidden = !highlighted;
}


- (CALayer *)selectedMarkLayer {
	if (!_selectedMarkLayer) {
		_selectedMarkLayer = [CALayer layer];
		UIEdgeInsets edgeInsets = UIEdgeInsetsFromString(self.markInsetsString);
		CGRect frame = self.layer.bounds;
		frame.origin.x += edgeInsets.left;
		frame.origin.y += edgeInsets.top;
		frame.size.width -= edgeInsets.left + edgeInsets.right;
		frame.size.height -= edgeInsets.top + edgeInsets.bottom;
		_selectedMarkLayer.frame = frame;
		_selectedMarkLayer.borderColor = [UIColor colorWithRed:220.0 / 255.0 green:223.0 / 255.0 blue:227.0 / 255.0 alpha:1.0].CGColor;
		_selectedMarkLayer.borderWidth = 3.0;
		_selectedMarkLayer.hidden = YES;
	}
	return _selectedMarkLayer;
}

@end
