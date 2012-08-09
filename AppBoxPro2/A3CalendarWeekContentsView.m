//
//  A3CalendarWeekContentsView.m
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 8/3/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3CalendarWeekContentsView.h"
#import "A3CalendarWeekViewMetrics.h"
#import "A3Utilities.h"
#import "A3CalendarWeekView.h"

@implementation A3CalendarWeekContentsView
@synthesize startDate = _startDate;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextSaveGState(context);
	CGContextSetAllowsAntialiasing(context, false);

	CGFloat left = CGRectGetMinX(rect) + A3_CALENDAR_WEEK_VIEW_ROW_HEADER_WIDTH;
	CGFloat top = CGRectGetMinY(rect);
	CGFloat right = CGRectGetMaxX(rect) - 1.0f;
	CGFloat bottom = CGRectGetMaxY(rect);
	CGFloat columnWidth = (CGRectGetWidth(rect) - A3_CALENDAR_WEEK_VIEW_ROW_HEADER_WIDTH) / 7.0;
	CGFloat rowHeight = A3_CALENDAR_WEEKVIEW_ROW_HEIGHT;

	CGContextSetFillColorWithColor(context, A3_CALENDAR_WEEK_VIEW_BACKGROUND_COLOR);
	CGContextAddRect(context, CGRectMake(left, top, columnWidth, CGRectGetHeight(rect)));
	CGContextAddRect(context, CGRectMake(right - columnWidth, top, columnWidth, CGRectGetHeight(rect)));
	CGContextFillPath(context);

	CGContextSetStrokeColorWithColor(context, A3_CALENDAR_WEEK_VIEW_LINE_COLOR);

	// Add vertical lines
	for (NSInteger index = 0; index < 8; index++) {
		CGFloat x = left + columnWidth * index - (index == 7 ? 1.0f : 0.0f);
		CGContextMoveToPoint(context, x, top);
		CGContextAddLineToPoint(context, x, bottom);
	}

	// Add horizontal hour lines
	for (NSInteger index = 0; index < 23; index++) {
		CGFloat y = top + rowHeight * (index + 1);
		CGContextMoveToPoint(context, left, y);
		CGContextAddLineToPoint(context, right, y);
	}
	CGContextStrokePath(context);

	CGContextSetLineDash(context, 1.0f, dash_line_pattern, 2);
	for (NSInteger index = 0; index < 24; index++) {
		CGFloat y = top + rowHeight * index + rowHeight / 2.0f;
		CGContextMoveToPoint(context, left, y);
		CGContextAddLineToPoint(context, right, y);
	}
	CGContextStrokePath(context);

	CGContextRestoreGState(context);

	CGContextSetAllowsAntialiasing(context, true);
	CGContextSetStrokeColorWithColor(context, A3_CALENDAR_WEEK_HEADER_TEXT_COLOR);
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *dateComponents = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
	dateComponents.hour = 1;
	NSDate *currentHour = [gregorian dateFromComponents:dateComponents];

	NSDateComponents *addingComponents = [[NSDateComponents alloc] init];
	addingComponents.hour = 1;

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"h a"];
	UIFont *hourFont = [UIFont systemFontOfSize:10.0f];
	left = CGRectGetMinX(rect);
	for (NSInteger index = 0; index < 23; index++) {
		NSString *hourText = [dateFormatter stringFromDate:currentHour];
		CGSize size = [hourText sizeWithFont:hourFont];

		CGFloat x = left + A3_CALENDAR_WEEK_VIEW_ROW_HEADER_WIDTH - size.width - 3.0f;
		CGFloat y = top + rowHeight * (index + 1) - size.height / 2.0f;
		[hourText drawAtPoint:CGPointMake(x, y) withFont:hourFont];

		currentHour = [gregorian dateByAddingComponents:addingComponents toDate:currentHour options:0];
	}
}

@end
