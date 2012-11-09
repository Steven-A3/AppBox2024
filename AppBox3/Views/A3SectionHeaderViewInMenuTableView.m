//
//  A3SectionHeaderViewInMenuTableView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/29/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3SectionHeaderViewInMenuTableView.h"
#import "A3Utilities.h"
#import "common.h"

@interface A3SectionHeaderViewInMenuTableView ()
@property(nonatomic, strong) NSArray *gradientColors;

@end

@implementation A3SectionHeaderViewInMenuTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (NSArray *)gradientColors {
	if (nil == _gradientColors) {
		_gradientColors = @[(__bridge id)[[UIColor colorWithRed:247.0f/255.0f green:250.0f/255.0f blue:249.0f/255.0f alpha:1.0f] CGColor],
		(__bridge id)[[UIColor colorWithRed:232.0f/255.0f green:235.0f/255.0f blue:234.0f/255.0f alpha:1.0f] CGColor]];
	}
	return _gradientColors;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextSaveGState(context);
	CGContextSetShouldAntialias(context, false);

	CGRect gradientRect = rect;
	gradientRect.origin.y = gradientRect.origin.y;
	gradientRect.size.height = gradientRect.size.height;
	drawLinearGradient(context, gradientRect, self.gradientColors);

	// Top horizontal line
	CGContextSetLineWidth(context, 1.0);
	CGContextSetRGBStrokeColor(context, 149.0f/255.0f, 154.0f/255.0f, 149.0f/255.0f, 1.0f);

	// Draw a single line from left to right
	CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect) + 0.5f);
	CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect) + 0.5f);
	CGContextStrokePath(context);

	// Bottom horizontal line
	// Draw a single line from left to right
	CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect) - 0.5f);
	CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect) - 0.5f);
	CGContextStrokePath(context);

	if (self.image) {
		[self.image drawAtPoint:CGPointMake(10.0f, (CGRectGetHeight(rect)/2.0f - self.image.size.height / 2.0))];
	}

	CGContextSetShouldAntialias(context, true);
	if (self.title) {
		UIFont *textFont = [UIFont boldSystemFontOfSize:16.0f];
		CGSize size = [self.title sizeWithFont:textFont];
		UIColor *textColor = [UIColor blackColor];
		CGContextSetStrokeColorWithColor(context, textColor.CGColor);
		CGContextSetFillColorWithColor(context, textColor.CGColor);
		[self.title drawAtPoint:CGPointMake(
				10.0f * 2.0f + (self.image?self.image.size.width:0.0f),
				CGRectGetHeight(rect)/2.0f - size.height / 2.0f)
					   withFont:textFont];
	}

	NSString *openCollapseText;
	UIFont *font;
	font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:37.0f];
	if (self.collapsed) {
		openCollapseText = @"›";

		CGSize size = [openCollapseText sizeWithFont:font];
		[openCollapseText drawAtPoint:CGPointMake(
				CGRectGetWidth(rect) - 20.0f - size.width,
				(CGRectGetHeight(rect)/2.0f - size.height/2.0f) - 2.0f)
							 withFont:font];
	} else {
		openCollapseText = @"»";

		CGSize size = [openCollapseText sizeWithFont:font];

		CGContextRotateCTM(context, DegreesToRadians(-90.0));

		[openCollapseText drawAtPoint:CGPointMake(
				-32.0f,
				CGRectGetWidth(rect) - 10.0f - size.width - 20.0f)
							 withFont:font];
	}

	CGContextRestoreGState(context);
}

@end
