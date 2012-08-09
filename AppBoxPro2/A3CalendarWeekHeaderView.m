//
//  A3CalendarWeekHeaderView.m
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 8/9/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "A3CalendarWeekHeaderView.h"
#import "A3CalendarWeekViewMetrics.h"

#define	A3_CALENDAR_WEEK_VIEW_TOP_RED_LINE_COLOR		[UIColor colorWithRed:206.0f/255.0f green:0.0f blue:11.0f/255.0f alpha:1.0f].CGColor
#define A3_CALENDAR_WEEK_HEADER_VIEW_LABEL_HEIGHT		20.0f
#define A3_CALENDAR_WEEK_HEADER_VIEW_ALL_DAY_HEIGHT		25.0f
#define A3_CALENDAR_WEEK_HEADER_VIEW_SEPARATOR_HEIGHT	5.0f

@implementation A3CalendarWeekHeaderView
@synthesize startDate = _startDate;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextSetAllowsAntialiasing(context, false);

	CGFloat left = CGRectGetMinX(rect) + A3_CALENDAR_WEEK_VIEW_ROW_HEADER_WIDTH;
	CGFloat right = CGRectGetMaxX(rect) - 1.0f;
	CGFloat top = CGRectGetMinY(rect) + A3_CALENDAR_WEEK_HEADER_VIEW_LABEL_HEIGHT;
	CGFloat bottom = CGRectGetMaxY(rect);
	CGFloat colWidth = (CGRectGetWidth(rect) - A3_CALENDAR_WEEK_VIEW_ROW_HEADER_WIDTH) / 7.0;

	CGContextSaveGState(context);
	CGContextSetFillColorWithColor(context, A3_CALENDAR_WEEK_VIEW_BACKGROUND_COLOR);
	CGContextAddRect(context, CGRectMake(left, top, colWidth, A3_CALENDAR_WEEK_HEADER_VIEW_ALL_DAY_HEIGHT + A3_CALENDAR_WEEK_HEADER_VIEW_SEPARATOR_HEIGHT));
	CGContextAddRect(context, CGRectMake(right - colWidth, top, colWidth, A3_CALENDAR_WEEK_HEADER_VIEW_ALL_DAY_HEIGHT + A3_CALENDAR_WEEK_HEADER_VIEW_SEPARATOR_HEIGHT));
	CGContextFillPath(context);
	CGContextRestoreGState(context);

	CGContextSetStrokeColorWithColor(context, A3_CALENDAR_WEEK_VIEW_LINE_COLOR);
	CGContextMoveToPoint(context, left, top);
	CGContextAddLineToPoint(context, left, bottom);
	CGContextAddLineToPoint(context, right, bottom);
	CGContextAddLineToPoint(context, right, top);

	for (NSInteger index = 0; index < 6; index++) {
		CGFloat x = left + colWidth * (index + 1);
		CGContextMoveToPoint(context, x, top);
		CGContextAddLineToPoint(context, x, bottom);
	}
	top += A3_CALENDAR_WEEK_HEADER_VIEW_ALL_DAY_HEIGHT;
	CGContextMoveToPoint(context, left, top);
	CGContextAddLineToPoint(context, right, top);

	top += A3_CALENDAR_WEEK_HEADER_VIEW_SEPARATOR_HEIGHT;
	CGContextMoveToPoint(context, left, top);
	CGContextAddLineToPoint(context, right, top);

	CGContextStrokePath(context);

	top = CGRectGetMinY(rect) + A3_CALENDAR_WEEK_HEADER_VIEW_LABEL_HEIGHT;
	CGContextSetStrokeColorWithColor(context, A3_CALENDAR_WEEK_VIEW_TOP_RED_LINE_COLOR);
	CGContextMoveToPoint(context, left, top);
	CGContextAddLineToPoint(context, right, top);
	CGContextStrokePath(context);

	CGContextSetStrokeColorWithColor(context, A3_CALENDAR_WEEK_HEADER_TEXT_COLOR);
	CGContextSetAllowsAntialiasing(context, true);
	NSDate *currentDate = self.startDate;
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

	NSDateComponents *addingComponents = [[NSDateComponents alloc] init];
	addingComponents.day = 1;

	CGFloat x,y = 2.0f;
	UIFont *font = [UIFont systemFontOfSize:13.0];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"d EEE"];

	for (NSInteger index = 0; index < 7; index++) {
		NSString *text = [dateFormatter stringFromDate:currentDate];
		CGSize size = [text sizeWithFont:font];
		x = left + colWidth * (index + 1) - size.width - 5.0f;
		[text drawAtPoint:CGPointMake(x, y) withFont:font];

		currentDate = [gregorian dateByAddingComponents:addingComponents toDate:currentDate options:0];
	}

	{
		NSString *allDay = @"all-day";
		UIFont *allDayFont = [UIFont systemFontOfSize:11.0];
		CGSize size = [allDay sizeWithFont:allDayFont];
		CGFloat x = A3_CALENDAR_WEEK_VIEW_ROW_HEADER_WIDTH - 4.0f - size.width;
		CGFloat y = A3_CALENDAR_WEEK_HEADER_VIEW_LABEL_HEIGHT + (A3_CALENDAR_WEEK_HEADER_VIEW_ALL_DAY_HEIGHT / 2.0f - size.height/2.0f);
		[allDay drawAtPoint:CGPointMake(x, y) withFont:allDayFont];
	}
}

- (NSDate *)firstWeekdayOfDate:(NSDate *)date {
	NSDate *result;
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [gregorian components:NSWeekdayCalendarUnit fromDate:date];
	// weekday 1 == sunday, 1SUN 2MON 3TUE 4WED 5THU 6FRI 7SAT
	if (components.weekday > 1) {
		NSDateComponents *subtractComponents = [[NSDateComponents alloc] init];
		subtractComponents.day = 1 - components.weekday;
		result = [gregorian dateByAddingComponents:subtractComponents toDate:date options:0];
	} else {
		result = date;
	}

	return result;
}

- (NSDate *)startDate {
	if (nil == _startDate) {
		_startDate = [self firstWeekdayOfDate:[NSDate date]];
	}
	return _startDate;
}

- (void)setStartDate:(NSDate *)startDate {
	_startDate = [self firstWeekdayOfDate:_startDate];
}

@end
