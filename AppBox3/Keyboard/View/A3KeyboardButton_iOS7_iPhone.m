//
//  A3KeyboardButton_iOS7_iPhone.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/25/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3KeyboardButton_iOS7_iPhone.h"
#import "common.h"
#import "A3UserDefaults+A3Addition.h"

@interface A3KeyboardButton_iOS7_iPhone ()

@property (nonatomic, strong) CALayer *selectedMarkLayer;

@end

@implementation A3KeyboardButton_iOS7_iPhone

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self configureLayer];
	}

	return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];

	[self configureLayer];
}

- (void)configureLayer {
	self.layer.borderColor = [UIColor colorWithRed:163.0 / 255.0 green:167.0 / 255.0 blue:171.0 / 255.0 alpha:1.0].CGColor;
	self.layer.borderWidth = 1 / [[UIScreen mainScreen] scale];
	
	[self.layer addSublayer:self.highlightedMarkLayer];
}

- (void)setHighlighted:(BOOL)highlighted {
	[super setHighlighted:highlighted];

	if (!self.backgroundColorForHighlightedState) {
		_highlightedMarkLayer.hidden = !highlighted;
	}

	if (self.backgroundColorForHighlightedState) {
		self.backgroundColor = highlighted ? self.backgroundColorForHighlightedState : self.backgroundColorForDefaultState;
	}
}

- (CALayer *)highlightedMarkLayer {
	if (!_highlightedMarkLayer) {
		_highlightedMarkLayer = [CALayer layer];
		UIEdgeInsets edgeInsets = UIEdgeInsetsFromString(self.markInsetsString);
		CGRect frame = self.layer.bounds;
		frame.origin.x += edgeInsets.left;
		frame.origin.y += edgeInsets.top;
		frame.size.width -= edgeInsets.left + edgeInsets.right;
		frame.size.height -= edgeInsets.top + edgeInsets.bottom;
		_highlightedMarkLayer.frame = frame;
		_highlightedMarkLayer.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1].CGColor;
		_highlightedMarkLayer.hidden = YES;
	}
	return _highlightedMarkLayer;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    if (_highlightedMarkLayer != nil) {
        _highlightedMarkLayer.frame = self.layer.bounds;
    }
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];

    self.backgroundColor = selected ? [[A3UserDefaults standardUserDefaults] themeColor] : [UIColor colorWithRed:193.0/255.0 green:196.0/255.0 blue:200.0/255.0 alpha:1.0];
}

@end
