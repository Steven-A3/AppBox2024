//
//  A3SegmentedControl.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/10/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3SegmentedControl.h"
#import "A3Utilities.h"

@implementation A3SegmentedControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		_numberOfSegment = 3;
		_selectedIndex = 0;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		_numberOfSegment = 3;
		_selectedIndex = 0;
	}

	return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	if ([_dataSource respondsToSelector:@selector(numberOfColumnsInSegmentedControl:)]) {
		_numberOfSegment = [_dataSource numberOfColumnsInSegmentedControl:self];
	}

	CGRect drawingRect = CGRectMake(rect.origin.x, rect.origin.y + 1.0f, rect.size.width, rect.size.height - 1.0f);

	// Drawing code
	NSArray *colorsForSelected = @[
	(__bridge id) [[UIColor colorWithRed:164.0f / 255.0f green:164.0f / 255.0f blue:164.0f / 255.0f alpha:1.0f] CGColor],
	(__bridge id) [[UIColor colorWithRed:225.0f / 255.0f green:226.0f / 255.0f blue:228.0f / 255.0f alpha:1.0f] CGColor]];
	NSArray *colorsForNormal = @[
	(__bridge id) [[UIColor colorWithRed:240.0f / 255.0f green:241.0f / 255.0f blue:242.0f / 255.0f alpha:1.0f] CGColor],
	(__bridge id) [[UIColor colorWithRed:194.0f / 255.0f green:194.0f / 255.0f blue:195.0f / 255.0f alpha:1.0f] CGColor]];

	CGContextRef context = UIGraphicsGetCurrentContext();

	CGFloat width = CGRectGetWidth(drawingRect) / _numberOfSegment;
	CGFloat height = CGRectGetHeight(drawingRect);

	UIFont *titleFont = [UIFont boldSystemFontOfSize:14.0f];
	UIColor *titleColor = [UIColor colorWithRed:66.0f/255.0f green:66.0f/255.0f blue:66.0f/255.0f alpha:1.0f];
	CGContextSetStrokeColorWithColor(context, titleColor.CGColor);
	CGContextSetFillColorWithColor(context, titleColor.CGColor);
	for (NSUInteger i = 0; i < 3; i++) {
		CGRect subRect = CGRectMake(width * i, CGRectGetMinY(rect), width, height);
		drawLinearGradient(context, subRect, i == _selectedIndex ? colorsForSelected : colorsForNormal);
		// Draw image
		if ([_dataSource respondsToSelector:@selector(segmentedControl:imageForIndex:)]) {
			UIImage *image = [_dataSource segmentedControl:self imageForIndex:i];
			NSString *title = nil;
			if ([_dataSource respondsToSelector:@selector(segmentedControl:titleForIndex:)]) {
				title = [_dataSource segmentedControl:self titleForIndex:i];
			}
            
			CGSize size = [title sizeWithAttributes:@{NSFontAttributeName : titleFont}];
			CGFloat contentsWidth = image.size.width + 5.0f + size.width;
			CGFloat contentsStart = width * i + (width / 2.0f - contentsWidth / 2.0f);
			[image drawAtPoint:CGPointMake(contentsStart, CGRectGetHeight(drawingRect)/2.0f - image.size.height/2.0f)];
			[title drawAtPoint:CGPointMake(contentsStart + image.size.width + 5.0f, CGRectGetHeight(drawingRect) / 2.0f - size.height / 2.0f) withAttributes:@{NSFontAttributeName : titleFont}];
		}
	}

	CGContextSetAllowsAntialiasing(context, false);

	CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:149.0f / 255.0f green:154.0f / 255.0f blue:149.0f / 255.0f alpha:1.0f].CGColor);
	CGContextAddRect(context, drawingRect);
	CGContextMoveToPoint(context, width, CGRectGetMinY(drawingRect));
	CGContextAddLineToPoint(context, width, CGRectGetMaxY(drawingRect));
	CGContextMoveToPoint(context, width * 2.0f, CGRectGetMinY(drawingRect));
	CGContextAddLineToPoint(context, width * 2.0f, CGRectGetMaxY(drawingRect));
	CGContextStrokePath(context);

	CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];

	if ([touches count] > 1) return;

	UITouch *touch = [touches anyObject];
	CGPoint touchLocation = [touch locationInView:self];

	NSUInteger newIndex = (NSUInteger) (touchLocation.x / (CGRectGetWidth(self.bounds)/3.0));
	if (newIndex != _selectedIndex) {

		if ([_delegate respondsToSelector:@selector(segmentedControl:didChangedSelectedIndex:fromIndex:)]) {
			[_delegate segmentedControl:self didChangedSelectedIndex:newIndex fromIndex:_selectedIndex];
		}
		_selectedIndex = newIndex;
		[self setNeedsDisplay];
	}
}

@end
