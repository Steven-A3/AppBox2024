//
//  A3CalendarPropertyView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/31/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3CalendarPropertyView.h"
#import "common.h"
#import "A3Utilities.h"

@implementation A3CalendarPropertyView
@synthesize headerText = _headerText;
@synthesize contentText = _contentText;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#define	A3_CALENDAR_PROPERTY_VIEW_HEADER_HEIGHT		26.0f

- (void)addBrokenLinesPathToPath:(UIBezierPath *)path fromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint {
	CGFloat x = fromPoint.x, y = fromPoint.y;

	[path moveToPoint:CGPointMake(x, y)];
	x += 10.0f;
	[path addLineToPoint:CGPointMake(x, y)];
	x += 9.0f;
	y += 7.0f;
	[path addLineToPoint:CGPointMake(x, y)];
	x += 9.0f;
	y -= 7.0f;
	[path addLineToPoint:CGPointMake(x, y)];
	x = toPoint.x;
	[path addLineToPoint:CGPointMake(x, y)];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextSetAllowsAntialiasing(context, false);
	UIBezierPath *roundedBorder = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:3.0f];
	CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:192.0f/255.0f green:193.0f/255.0f blue:194.0f/255.05 alpha:1.0f].CGColor);
	[roundedBorder stroke];

	UIBezierPath *lowerArea = [UIBezierPath bezierPath];
	CGFloat x, y, cornerRadius = 3.0f;
	CGFloat left = CGRectGetMinX(rect), right = CGRectGetMaxX(rect), bottom = CGRectGetMaxY(rect);

	x = left;
	y = A3_CALENDAR_PROPERTY_VIEW_HEADER_HEIGHT;
	[self addBrokenLinesPathToPath:lowerArea fromPoint:CGPointMake(x, y) toPoint:CGPointMake(right, y)];

	y = bottom - cornerRadius;
	[lowerArea addLineToPoint:CGPointMake(x, y)];
	x = right - cornerRadius;
	[lowerArea addArcWithCenter:CGPointMake(x, y) radius:cornerRadius startAngle:DegreesToRadians(0.0f) endAngle:DegreesToRadians(90.0f) clockwise:YES];
	x = left + cornerRadius;
	y = bottom;
	[lowerArea addLineToPoint:CGPointMake(x, y)];
	y = bottom - cornerRadius;
	[lowerArea addArcWithCenter:CGPointMake(x, y) radius:cornerRadius startAngle:DegreesToRadians(90.0f) endAngle:DegreesToRadians(180.0f) clockwise:YES];
	[lowerArea closePath];

	[[UIColor colorWithRed:250.0f / 255.0f green:250.0f / 255.0f blue:250.0f / 255.0f alpha:1.0f] setFill];
	[lowerArea fill];

	UIBezierPath *dashLine = [UIBezierPath bezierPath];
	[self addBrokenLinesPathToPath:dashLine fromPoint:CGPointMake(left, A3_CALENDAR_PROPERTY_VIEW_HEADER_HEIGHT) toPoint:CGPointMake(right, A3_CALENDAR_PROPERTY_VIEW_HEADER_HEIGHT)];
	[[UIColor colorWithRed:217.0f / 255.0f green:217.0f / 255.0f blue:217.0f / 255.0f alpha:1.0f] setStroke];
	[dashLine setLineDash:dash_line_pattern count:2 phase:1.0f];
	[dashLine setLineWidth:1.0f];
	[dashLine stroke];

	if ([_headerText length]) {
		UIColor *headerTextColor = [UIColor colorWithRed:143.0f / 255.0f green:143.0f / 255.0f blue:143.0f / 255.0f alpha:1.0f];
		[headerTextColor setFill];
		[headerTextColor setStroke];
		UIFont *headerFont = [UIFont systemFontOfSize:10.0f];
		[_headerText drawAtPoint:CGPointMake(left + 5.0, CGRectGetMinY(rect) + 3.0f) withFont:headerFont];
	}

	if ([_contentText length]) {
		UIColor *contentTextColor = [UIColor colorWithRed:64.0f/255.0f green:64.0f/255.0f blue:64.0f/255.0f alpha:1.0f];
		[contentTextColor setFill];
		[contentTextColor setStroke];
		UIFont *contentFont = [UIFont boldSystemFontOfSize:13.0f];
		[_contentText drawAtPoint:CGPointMake(left + 18.0f, A3_CALENDAR_PROPERTY_VIEW_HEADER_HEIGHT + 10.0f) withFont:contentFont];
	}
}

@end
