//
//  A3CalendarEventPropertyCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/4/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3CalendarEventPropertyCell.h"
#import "common.h"
#import "A3Utilities.h"

@implementation A3CalendarEventPropertyCell
@synthesize headerText = _headerText;
@synthesize contentText = _contentText;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#define	A3_CALENDAR_PROPERTY_VIEW_HEADER_HEIGHT		26.0f

- (void)addBrokenLinesPathToPath:(UIBezierPath *)path fromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint {
	CGFloat x = fromPoint.x, y = fromPoint.y;

	[path moveToPoint:CGPointMake(x, y)];
	x += 10.0f;
	[path addLineToPoint:CGPointMake(x, y)];
	x += 8.0f;
	y += 7.0f;
	[path addLineToPoint:CGPointMake(x, y)];
	x += 8.0f;
	y -= 7.0f;
	[path addLineToPoint:CGPointMake(x, y)];
	x = toPoint.x;
	[path addLineToPoint:CGPointMake(x, y)];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	FNLOG(@"width = %f, height = %f", rect.size.width, rect.size.height);

	// Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGRect drawingRect = CGRectInset(rect, 1.0f, 2.0f);
	drawingRect.size.height -= 8.0f;

	CGContextSetAllowsAntialiasing(context, false);

	UIBezierPath *lowerArea = [UIBezierPath bezierPath];
	CGFloat x, y, cornerRadius = 3.0f;
	CGFloat left = CGRectGetMinX(drawingRect), right = CGRectGetMaxX(drawingRect), top = CGRectGetMinY(drawingRect), bottom = CGRectGetMaxY(drawingRect);

	x = left;
	y = top + A3_CALENDAR_PROPERTY_VIEW_HEADER_HEIGHT;
	[self addBrokenLinesPathToPath:lowerArea fromPoint:CGPointMake(x, y) toPoint:CGPointMake(right, y)];

	x = right;
	y = bottom - cornerRadius;
	[lowerArea addLineToPoint:CGPointMake(x, y)];
	x = right - cornerRadius;
	[lowerArea addArcWithCenter:CGPointMake(x, y) radius:cornerRadius startAngle:(CGFloat) DegreesToRadians(0.0f) endAngle:(CGFloat) DegreesToRadians(90.0f) clockwise:YES];
	x = left + cornerRadius;
	y = bottom;
	[lowerArea addLineToPoint:CGPointMake(x, y)];
	y = bottom - cornerRadius;
	[lowerArea addArcWithCenter:CGPointMake(x, y) radius:cornerRadius startAngle:(CGFloat) DegreesToRadians(90.0f) endAngle:(CGFloat) DegreesToRadians(180.0f) clockwise:YES];
	[lowerArea closePath];

	[[UIColor colorWithRed:250.0f / 255.0f green:250.0f / 255.0f blue:250.0f / 255.0f alpha:1.0f] setFill];
	[lowerArea fill];

	UIBezierPath *dashLine = [UIBezierPath bezierPath];
	[self addBrokenLinesPathToPath:dashLine fromPoint:CGPointMake(left, top + A3_CALENDAR_PROPERTY_VIEW_HEADER_HEIGHT) toPoint:CGPointMake(right, A3_CALENDAR_PROPERTY_VIEW_HEADER_HEIGHT)];
	[[UIColor colorWithRed:217.0f / 255.0f green:217.0f / 255.0f blue:217.0f / 255.0f alpha:1.0f] setStroke];
	[dashLine setLineDash:dash_line_pattern count:2 phase:1.0f];
	[dashLine setLineWidth:1.0f];
	[dashLine stroke];

	CGContextSetAllowsAntialiasing(context, true);

	UIBezierPath *roundedBorder = [UIBezierPath bezierPathWithRoundedRect:drawingRect cornerRadius:4.0f];
	[roundedBorder setLineWidth:1.0f];
	CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:192.0f/255.0f green:193.0f/255.0f blue:194.0f/255.05 alpha:1.0f].CGColor);
	[roundedBorder stroke];

	if ([_headerText length]) {
		UIColor *headerTextColor = [UIColor colorWithRed:143.0f / 255.0f green:143.0f / 255.0f blue:143.0f / 255.0f alpha:1.0f];
		[headerTextColor setFill];
		[headerTextColor setStroke];
		UIFont *headerFont = [UIFont systemFontOfSize:13.0f];
		[_headerText drawAtPoint:CGPointMake(left + 11.0, top + 5.0f) withAttributes:@{NSFontAttributeName:headerFont}];
	}

	if ([_contentText length]) {
		UIColor *contentTextColor = [UIColor colorWithRed:64.0f/255.0f green:64.0f/255.0f blue:64.0f/255.0f alpha:1.0f];
		[contentTextColor setFill];
		[contentTextColor setStroke];
		UIFont *contentFont = [UIFont systemFontOfSize:14.0f];

        CGRect boundingRect = [_contentText boundingRectWithSize:CGSizeMake(drawingRect.size.width - 26.0f - 5.0f, drawingRect.size.height - A3_CALENDAR_PROPERTY_VIEW_HEADER_HEIGHT - 2.0f - 5.0f) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : contentFont} context:nil];
        
		CGRect contentRect = CGRectMake(left + 26.0f, top + A3_CALENDAR_PROPERTY_VIEW_HEADER_HEIGHT + 2.0f, boundingRect.size.width, boundingRect.size.height);
		[_contentText drawInRect:contentRect withAttributes:@{NSFontAttributeName:contentFont}];
	}
}

@end
