//
//  A3CalendarMonthView.m
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 7/31/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "A3CalendarMonthView.h"

#define A3_CALENDAR_MONTH_VIEW_TEXT_RIGHT_MARGIN	4.0f

@implementation A3CalendarMonthView {
	CGFloat columnWidth, rowHeight;
	CGFloat weekdayHeaderHeight;
	NSUInteger numberOfRow;
	CGFloat rightMargin;
}

@synthesize year = _year;
@synthesize month = _month;
@synthesize weekStartSunday = _weekStartSunday;

- (void)initialize {
	_year = 2012;
	_month = 7;		// July
	_weekStartSunday = YES;

	self.backgroundColor = [UIColor whiteColor];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self initialize];
	}
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		// Initialization code
		[self initialize];
	}

	return self;
}

- (NSDate *)firstDateOfMonthWithCalendar:(NSCalendar *)calendar {
	NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
	dateComponents.year = _year;
	dateComponents.month = _month;
	dateComponents.weekOfMonth = 1;
	dateComponents.weekday = 1;		// Sunday == 1
	return [calendar dateFromComponents:dateComponents];
}

- (NSUInteger)numberOfWeeksWithCalendar:(NSCalendar *)calendar {
	NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
	dateComponents.year = _year;
	dateComponents.month = _month;
	dateComponents.day = 1;
	NSDate *firstDayOfThisMonth = [calendar dateFromComponents:dateComponents];

	// range.length will return the number of weeks in given month
	NSRange range = [calendar rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:firstDayOfThisMonth];
	return range.length;
}


- (void)drawCalendarFrameInContext:(CGContextRef)context rect:(CGRect)rect {
	// Draw weekday text as a header line.

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	NSArray *weekdaySymbols = [dateFormatter shortWeekdaySymbols];
	UIFont *weekdaySymbolFont = [UIFont systemFontOfSize:12.0f];

	for (NSString *symbol in weekdaySymbols) {
		CGSize sizeOfSymbol = [symbol sizeWithFont:weekdaySymbolFont];
		CGPoint drawPoint = CGPointMake(columnWidth * ([weekdaySymbols indexOfObject:symbol] + 1) - sizeOfSymbol.width - rightMargin, 0.0f);
		[symbol drawAtPoint:drawPoint withFont:weekdaySymbolFont];
	}

	CGContextSetAllowsAntialiasing(context, false);

	CGFloat calendarHeight = CGRectGetHeight(rect) - weekdayHeaderHeight;
	CGContextSetRGBFillColor(context, 250.0f/255.0f, 252.0f/255.0f, 252.0f/255.0f, 1.0f);
	CGContextAddRect(context, CGRectMake(CGRectGetMinX(rect), weekdayHeaderHeight, columnWidth, calendarHeight));
	CGContextAddRect(context, CGRectMake(CGRectGetMaxX(rect) - columnWidth, weekdayHeaderHeight, columnWidth, calendarHeight));

	CGContextFillPath(context);

	CGContextSetRGBStrokeColor(context, 207.0f/255.0f, 0.0f, 11.0f/255.0f, 1.0f);
	CGContextSetLineWidth(context, 1.0f);

	CGContextMoveToPoint(context, CGRectGetMinX(rect), weekdayHeaderHeight);
	CGContextAddLineToPoint(context, CGRectGetMaxX(rect), weekdayHeaderHeight);

	CGContextStrokePath(context);

	CGContextSetRGBStrokeColor(context, 192.0f/255.0f, 193.0f/255.0f, 194.0f/255.0f, 1.0f);
	CGContextSetLineWidth(context, 1.0f);

	CGContextMoveToPoint(context, CGRectGetMinX(rect), weekdayHeaderHeight);
	CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect));
	CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
	CGContextAddLineToPoint(context, CGRectGetMaxX(rect), weekdayHeaderHeight);

	for (NSInteger index = 1; index < numberOfRow; index++) {
		CGFloat coordinate_Y = weekdayHeaderHeight + rowHeight * index;
		CGContextMoveToPoint(context, CGRectGetMinX(rect), coordinate_Y);
		CGContextAddLineToPoint(context, CGRectGetMaxX(rect), coordinate_Y);
	}

	for (NSInteger index = 1; index < 7; index++) {
		CGFloat coordinate_X = columnWidth * index;
		CGContextMoveToPoint(context, coordinate_X, weekdayHeaderHeight);
		CGContextAddLineToPoint(context, coordinate_X, CGRectGetMaxY(rect));
	}

	CGContextStrokePath(context);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	CGRect drawingRect = CGRectInset(rect, 1.0f, 0.0f);

    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();

	// Determine how many weeks in the given month.
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDate *startDate = [self firstDateOfMonthWithCalendar:gregorian];
	numberOfRow = [self numberOfWeeksWithCalendar:gregorian];

	weekdayHeaderHeight = 20.0f;
	columnWidth = CGRectGetWidth(drawingRect) / 7.0;
	rowHeight = (CGRectGetHeight(drawingRect) - weekdayHeaderHeight ) / numberOfRow;
	rightMargin = A3_CALENDAR_MONTH_VIEW_TEXT_RIGHT_MARGIN;

	[self drawCalendarFrameInContext:context rect:drawingRect];

	NSDateComponents *addComponent = [[NSDateComponents alloc] init];
	addComponent.day = 1;
	NSDate *currentDate = startDate;

	CGContextSetAllowsAntialiasing(context, true);

	UIFont *font = [UIFont systemFontOfSize:12.0];

	UIColor *textColor = [UIColor colorWithRed:101.0f/255.0f green:101.0f/255.0f blue:101.0f/255.0f alpha:1.0f];
	CGContextSetStrokeColorWithColor(context, textColor.CGColor);
	CGContextSetFillColorWithColor(context, textColor.CGColor);

	for (NSUInteger row = 0; row < numberOfRow; row++) {
		for (NSUInteger col = 0; col < 7; col++) {
			NSDateComponents *currentDateComponent = [gregorian components:NSDayCalendarUnit fromDate:currentDate];

			NSString *dayString = [NSString stringWithFormat:@"%d", currentDateComponent.day];
			CGSize size = [dayString sizeWithFont:font];
			CGPoint point = CGPointMake((col + 1) * columnWidth - size.width - rightMargin, weekdayHeaderHeight + row * rowHeight);
			[dayString drawAtPoint:point withFont:font];

			currentDate = [gregorian dateByAddingComponents:addComponent toDate:currentDate options:0];
		}
	}
}

@end
