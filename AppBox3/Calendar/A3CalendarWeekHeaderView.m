//
//  A3CalendarWeekHeaderView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/9/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "A3CalendarWeekHeaderView.h"
#import "A3CalendarWeekViewMetrics.h"
#import "A3Utilities.h"
#import "common.h"

#define	A3_CALENDAR_WEEK_VIEW_TOP_RED_LINE_COLOR		[UIColor colorWithRed:206.0f/255.0f green:0.0f blue:11.0f/255.0f alpha:1.0f].CGColor

@implementation A3CalendarWeekHeaderView
@synthesize startDate = _startDate;

- (void)initializeView {
	self.contentMode = UIViewContentModeRedraw;
}

- (id)initWithFrame:(CGRect)frame
{
	FNLOG(@"is it called?");
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self initializeView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	FNLOG(@"is it called?");
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self initializeView];
	}

	return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	FNLOG(@"drawRect %f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);

    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextSetAllowsAntialiasing(context, false);

	CGFloat left = roundf( CGRectGetMinX(rect) + A3_CALENDAR_WEEK_VIEW_ROW_HEADER_WIDTH );
	CGFloat right = roundf( CGRectGetMaxX(rect) ) - 1.0f;
	CGFloat top = roundf( CGRectGetMinY(rect) + A3_CALENDAR_WEEK_HEADER_VIEW_LABEL_HEIGHT );
	CGFloat bottom = roundf( CGRectGetMaxY(rect) );
	CGFloat colWidth = (CGRectGetWidth(rect) - A3_CALENDAR_WEEK_VIEW_ROW_HEADER_WIDTH) / 7.0;

//	FNLOG(@"left %f, colWidth = %f", left, colWidth);

	CGContextSaveGState(context);
	CGContextSetFillColorWithColor(context, A3_CALENDAR_WEEK_VIEW_BACKGROUND_COLOR.CGColor);
	CGContextAddRect( context, CGRectMake( left, top, roundf(colWidth), roundf(A3_CALENDAR_WEEK_HEADER_VIEW_ALL_DAY_HEIGHT + A3_CALENDAR_WEEK_HEADER_VIEW_SEPARATOR_HEIGHT ) ) );
	CGContextAddRect(context, CGRectMake(roundf(right - colWidth), top, roundf(colWidth), roundf(A3_CALENDAR_WEEK_HEADER_VIEW_ALL_DAY_HEIGHT + A3_CALENDAR_WEEK_HEADER_VIEW_SEPARATOR_HEIGHT) ));
	CGContextFillPath(context);
	CGContextRestoreGState(context);

	CGContextSetStrokeColorWithColor(context, A3_CALENDAR_WEEK_VIEW_LINE_COLOR.CGColor);
	CGContextMoveToPoint(context, left, top);
	CGContextAddLineToPoint(context, left, bottom);
	CGContextAddLineToPoint(context, right, bottom);
	CGContextAddLineToPoint(context, right, top);

	for (NSInteger index = 0; index < 6; index++) {
		CGFloat x = roundf( left + colWidth * (index + 1) );
//		FNLOG(@"vertical x = %f", x);
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

	CGContextSetStrokeColorWithColor(context, A3_CALENDAR_WEEK_HEADER_TEXT_COLOR.CGColor);
	CGContextSetAllowsAntialiasing(context, true);
	NSDate *currentDate = self.startDate;
	FNLOG(@"%@", self.startDate);
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

	NSDateComponents *addingComponents = [[NSDateComponents alloc] init];
	addingComponents.day = 1;

	CGFloat x,y = 2.0f;
	UIFont *font = A3_CALENDAR_WEEK_VIEW_HEADER_FONT;
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"d EEE"];

	for (NSInteger index = 0; index < 7; index++) {
		NSString *text = [dateFormatter stringFromDate:currentDate];
		CGSize size = [text sizeWithFont:font];
		x = roundf(left + colWidth * (index + 1) - size.width - 5.0f);
		[text drawAtPoint:CGPointMake(x, y) withFont:font];

		currentDate = [gregorian dateByAddingComponents:addingComponents toDate:currentDate options:0];
	}

	{
		NSString *allDay = @"all-day";
		UIFont *allDayFont = [UIFont systemFontOfSize:11.0];
		CGSize size = [allDay sizeWithFont:allDayFont];
		CGFloat x = roundf( A3_CALENDAR_WEEK_VIEW_ROW_HEADER_WIDTH - A3_CALENDAR_WEEK_HEADER_VIEW_TEXT_RIGHT_MARGIN - size.width );
		CGFloat y = roundf( A3_CALENDAR_WEEK_HEADER_VIEW_LABEL_HEIGHT + (A3_CALENDAR_WEEK_HEADER_VIEW_ALL_DAY_HEIGHT / 2.0f - size.height/2.0f) );
		[allDay drawAtPoint:CGPointMake(x, y) withFont:allDayFont];
	}
}

- (NSDate *)startDate {
	if (nil == _startDate) {
		_startDate = [A3Utilities firstWeekdayOfDate:[NSDate date]];
	}
	return _startDate;
}

- (void)setStartDate:(NSDate *)startDate {
	_startDate = [A3Utilities firstWeekdayOfDate:startDate];
}

@end
