//
//  A3FSegmentedControl.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/15/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3FSegmentedControl.h"
#import "common.h"

@interface A3FSegmentedControl ()
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@end

@implementation A3FSegmentedControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
		_tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
		[self addGestureRecognizer:_tapGestureRecognizer];
	}
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	// Drawing code
	CGFloat height = CGRectGetHeight(rect);
	CGFloat width = CGRectGetWidth(rect) / [_items count];

	UIColor *strokeColor = [UIColor colorWithWhite:1.0 alpha:0.7];

	UIColor *selectedTextColor = [UIColor blackColor];
	UIColor *textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
	UIColor *disabledTextColor = [UIColor colorWithWhite:1.0 alpha:0.3];
	UIFont *textFont = [UIFont systemFontOfSize:13];

	for (NSInteger idx = 0; idx < [_items count]; idx++) {
		CGRect frame = CGRectMake(width * idx, 0, width, height);
		[strokeColor setStroke];
		[strokeColor setFill];
		if (idx == 0) {
			CGFloat x = width * idx;
			// Bezier path for right open half rounded rect
			UIBezierPath *path = [UIBezierPath bezierPath];
			[path moveToPoint:CGPointMake(x + width - 0.2, 0)];
			[path addLineToPoint:CGPointMake(x + 5, 0)];
			[path addArcWithCenter:CGPointMake(x + 5, 5) radius:5 startAngle:DegreesToRadians(270) endAngle:DegreesToRadians(180) clockwise:NO];
			[path addLineToPoint:CGPointMake(x, height - 5)];
			[path addArcWithCenter:CGPointMake(x + 5, height - 5) radius:5 startAngle:DegreesToRadians(180) endAngle:DegreesToRadians(90) clockwise:NO];
			[path addLineToPoint:CGPointMake(x + width - 0.2, height)];

			path.lineWidth = 1.0;
			[path stroke];
			if (idx == _selectedSegmentIndex) {
				[path fill];
			}
		} else if (idx == ([_items count] - 1)) {
			UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:frame byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(5, 5)];
			path.lineWidth = 1.0;
			[path stroke];
			if (idx == _selectedSegmentIndex) {
				[path fill];
			}
		} else {
			// Bezier path for rectangle with open right.
			CGFloat x = width * idx;
			UIBezierPath *path = [UIBezierPath bezierPath];
			[path moveToPoint:CGPointMake(x + width, 0)];
			[path addLineToPoint:CGPointMake(x, 0)];
			[path addLineToPoint:CGPointMake(x, height)];
			[path addLineToPoint:CGPointMake(x + width, height)];

			path.lineWidth = 1.0;

			[[UIColor blackColor] setStroke];
			[path stroke];

			[strokeColor setStroke];
			[path stroke];

			if (idx == _selectedSegmentIndex) {
				[path fill];
			}
		}

		// Draw item text
		NSString *text = _items[idx];
		NSDictionary *textAttributes;
		if (idx == _selectedSegmentIndex) {
			textAttributes = @{NSFontAttributeName:textFont, NSForegroundColorAttributeName:selectedTextColor};
		} else if (_states && ![_states[idx] boolValue]) {
			textAttributes = @{NSFontAttributeName:textFont, NSForegroundColorAttributeName:disabledTextColor};
		} else {
			textAttributes = @{NSFontAttributeName:textFont, NSForegroundColorAttributeName:textColor};
		}
		CGRect textBoundingRect = [text boundingRectWithSize:CGSizeMake(width, height)
													 options:NSStringDrawingUsesLineFragmentOrigin
												  attributes:textAttributes
													 context:nil];
		textBoundingRect.origin.x = width * idx + (width - textBoundingRect.size.width) / 2.0;
		textBoundingRect.origin.y = (height - textBoundingRect.size.height) / 2.0;

		[text drawInRect:textBoundingRect withAttributes:textAttributes];
	}
}

- (void)tapGesture:(UITapGestureRecognizer *)tapGestureRecognizer {
	CGPoint point = [tapGestureRecognizer locationInView:self];
	NSUInteger newIndex = (NSUInteger) (point.x / (CGRectGetWidth(self.bounds)/ [_items count]));
	if (newIndex != _selectedSegmentIndex) {
		if (_states && ![_states[newIndex] boolValue])
			return;
		_selectedSegmentIndex = newIndex;
		[self sendActionsForControlEvents:UIControlEventValueChanged];
		[self setNeedsDisplay];
	}
}

- (void)setItems:(NSArray *)items {
	_items = items;
	[self setNeedsDisplay];
}

- (void)setSelectedSegmentIndex:(NSUInteger)selectedSegmentIndex {
	_selectedSegmentIndex = selectedSegmentIndex;
	[self setNeedsDisplay];
}

- (void)setStates:(NSArray *)states {
	_states = states;
	[self setNeedsDisplay];
}

@end
