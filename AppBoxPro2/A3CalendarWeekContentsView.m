//
//  A3CalendarWeekContentsView.m
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 8/3/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3CalendarWeekContentsView.h"

@implementation A3CalendarWeekContentsView {
	CGFloat timeTextWidth;
	CGFloat dayAndWeekdayBarHeight;
	CGFloat numberOfColumn;
	CGFloat columnWidth;		// 7 weekday
	CGFloat rowHeight;			// 24 hours
	CGFloat allDayEventHeight;
	CGFloat calendarHeight;
}
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
	timeTextWidth = 60.0f;
	dayAndWeekdayBarHeight = 20.0f;
	allDayEventHeight = 30.0f;
	rowHeight = 44.0f;
	numberOfColumn = 7;
	calendarHeight = CGRectGetHeight(rect) - dayAndWeekdayBarHeight;

	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextSetRGBFillColor(context, 250.0f/255.0f, 252.0f/255.0f, 252.0f/255.0f, 1.0f);
	CGContextAddRect(context, CGRectMake(timeTextWidth, dayAndWeekdayBarHeight, columnWidth, calendarHeight));
	CGContextAddRect(context, CGRectMake(CGRectGetMaxX(rect)-columnWidth, dayAndWeekdayBarHeight, columnWidth, calendarHeight));
	CGContextFillPath(context);

	CGFloat originX = timeTextWidth;
	CGFloat originY = dayAndWeekdayBarHeight;
	CGContextSetRGBStrokeColor(context, 192.0f/255.0f, 193.0f/255.0f, 194.0f/255.0f, 1.0f);

	CGContextMoveToPoint(context, timeTextWidth, dayAndWeekdayBarHeight + allDayEventHeight - 5.0f);
	CGContextAddLineToPoint(context, CGRectGetWidth(rect), dayAndWeekdayBarHeight + allDayEventHeight - 5.0f);

	CGContextMoveToPoint(context, timeTextWidth, dayAndWeekdayBarHeight + allDayEventHeight);
	CGContextAddLineToPoint(context, CGRectGetWidth(rect), dayAndWeekdayBarHeight + allDayEventHeight);

	// Add vertical line
	for (NSInteger index = 0; index < 8; index++) {
		CGContextMoveToPoint(context, timeTextWidth + columnWidth * index, dayAndWeekdayBarHeight);
		CGContextAddLineToPoint(context, timeTextWidth + columnWidth * index, CGRectGetHeight(rect));
	}

	// Add horizontal line
	originY = dayAndWeekdayBarHeight + allDayEventHeight;
	for (NSInteger index = 0; index < 24; index++) {
		CGContextMoveToPoint(context, timeTextWidth, originY + rowHeight * index);
		CGContextAddLineToPoint(context, CGRectGetMaxX(rect), originY + rowHeight * index);
	}
	CGContextFillPath(context);
}

@end
