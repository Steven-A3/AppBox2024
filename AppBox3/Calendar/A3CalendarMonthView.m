//
//  A3CalendarMonthView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/31/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "A3CalendarMonthView.h"
#import "common.h"
#import "A3Utilities.h"

#define A3_CALENDAR_MONTH_VIEW_TEXT_RIGHT_MARGIN	4.0f

@interface A3CalendarMonthView ()
@property(nonatomic, strong) NSCalendar *gregorian;
@property(nonatomic, strong) NSDate *startDate;

@end

@implementation A3CalendarMonthView {
	CGFloat columnWidth, rowHeight;
	CGFloat weekdayHeaderHeight;
	NSUInteger numberOfRow;
	CGFloat rightMargin;
	NSDate *_startDate;
	NSCalendar *_gregorian;
}

@synthesize year = _year;
@synthesize month = _month;
@synthesize weekStartSunday = _weekStartSunday;
@synthesize gregorian = _gregorian;
@synthesize startDate = _startDate;
@synthesize bigCalendar = _bigCalendar;
@synthesize currentDate = _currentDate;


- (void)initialize {
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *dateComponents = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:[NSDate date]];
	_year = dateComponents.year;
	_month = dateComponents.month;		// July
	_weekStartSunday = YES;
	_bigCalendar = YES;

	self.contentMode = UIViewContentModeRedraw;
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

- (void)awakeFromNib {
	[super awakeFromNib];

	FNLOG(@"Is big calendar %d", self.bigCalendar);
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
		CGPoint drawPoint;
		if (self.bigCalendar) {
			drawPoint = CGPointMake(columnWidth * ([weekdaySymbols indexOfObject:symbol] + 1) - sizeOfSymbol.width - rightMargin, 0.0f);
		} else{
			drawPoint = CGPointMake(columnWidth * ([weekdaySymbols indexOfObject:symbol]) + columnWidth/2.0f - sizeOfSymbol.width/2.0f, 0.0f);
		}
		[symbol drawAtPoint:drawPoint withFont:weekdaySymbolFont];
	}

	CGContextSetAllowsAntialiasing(context, false);

	CGFloat calendarHeight = CGRectGetHeight(rect) - weekdayHeaderHeight;
	CGContextSetRGBFillColor(context, 250.0f/255.0f, 252.0f/255.0f, 252.0f/255.0f, 1.0f);
	CGContextAddRect(context, CGRectMake(CGRectGetMinX(rect), weekdayHeaderHeight, columnWidth, calendarHeight));
	CGContextAddRect(context, CGRectMake(CGRectGetMaxX(rect) - columnWidth, weekdayHeaderHeight, columnWidth, calendarHeight));

	CGContextFillPath(context);

	CGContextSetRGBStrokeColor(context, 192.0f/255.0f, 193.0f/255.0f, 194.0f/255.0f, 1.0f);
	CGContextSetLineWidth(context, 1.0f);

	// Left, bottom, right border
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

	// Red line
	CGContextSetRGBStrokeColor(context, 207.0f/255.0f, 0.0f, 11.0f/255.0f, 1.0f);
	CGContextSetLineWidth(context, 1.0f);

	CGContextMoveToPoint(context, CGRectGetMinX(rect), weekdayHeaderHeight);
	CGContextAddLineToPoint(context, CGRectGetMaxX(rect), weekdayHeaderHeight);

	CGContextStrokePath(context);
}

- (void)drawEventFrom:(NSDate *)eventFrom to:(NSDate *)eventTo colors:(NSArray *)colors {
	NSDateComponents *dateComponentsFrom = [self.gregorian components:NSDayCalendarUnit fromDate:self.startDate toDate:eventFrom options:0];
	NSDateComponents *dateComponentsTo = nil;
	if ([eventFrom isEqualToDate:eventTo]) {
		NSInteger row, col;
		row = dateComponentsFrom.day / 7;
		col = dateComponentsFrom.day % 7;

		CGContextRef context = UIGraphicsGetCurrentContext();

		CGRect drawingRect = CGRectMake(columnWidth * col + 3.0f, weekdayHeaderHeight + rowHeight * row + 20.0f, columnWidth - 4.0f, 14.0f);

		UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:drawingRect cornerRadius:7.0f];
		[bezierPath addClip];
		drawLinearGradient(context, drawingRect, [NSArray arrayWithObjects:(__bridge id)[[colors objectAtIndex:1] CGColor],(__bridge id)[[colors objectAtIndex:2] CGColor], nil]);

		CGContextSetStrokeColorWithColor(context, [(UIColor *)[colors objectAtIndex:0] CGColor]);
		[bezierPath stroke];

		CGFloat radius = 4.0f, margin = 3.0f;
		CGContextAddArc(context, CGRectGetMinX(drawingRect) + margin + radius + 1.0f, CGRectGetMinY(drawingRect) + margin + radius, radius, 0.0, M_PI * 2.0, 1);
		CGContextSetFillColorWithColor(context, [[colors objectAtIndex:4] CGColor]);
		CGContextFillPath(context);

		CGContextAddArc(context, CGRectGetMinX(drawingRect) + margin + radius + 1.0f, CGRectGetMinY(drawingRect) + margin + radius, radius, 0.0, M_PI * 2.0, 1);
		CGContextSetStrokeColorWithColor(context, [[colors objectAtIndex:3] CGColor]);
		CGContextStrokePath(context);

		NSString *eventTitle = @"Event";
		CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
		CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
		[eventTitle drawAtPoint:CGPointMake(CGRectGetMinX(drawingRect) + radius * 2 + margin + 4.0f, CGRectGetMinY(drawingRect)) withFont:[UIFont systemFontOfSize:10.0]];
	} else {
		dateComponentsTo = [self.gregorian components:NSDayCalendarUnit fromDate:self.startDate toDate:eventTo options:0];
	}
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	CGRect drawingRect = CGRectInset(rect, 1.0f, 0.0f);

    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();

	// Determine how many weeks in the given month.
	numberOfRow = [self numberOfWeeksWithCalendar:self.gregorian];

	weekdayHeaderHeight = 20.0f;
	columnWidth = CGRectGetWidth(drawingRect) / 7.0;
	rowHeight = (CGRectGetHeight(drawingRect) - weekdayHeaderHeight ) / numberOfRow;
	rightMargin = A3_CALENDAR_MONTH_VIEW_TEXT_RIGHT_MARGIN;

	[self drawCalendarFrameInContext:context rect:drawingRect];

	NSDateComponents *addComponent = [[NSDateComponents alloc] init];
	addComponent.day = 1;
	NSDate *drawingDate = self.startDate;

	CGContextSetAllowsAntialiasing(context, true);

	UIFont *font = [UIFont systemFontOfSize:12.0];

	UIColor *textColor = [UIColor colorWithRed:101.0f/255.0f green:101.0f/255.0f blue:101.0f/255.0f alpha:1.0f];
	CGContextSetStrokeColorWithColor(context, textColor.CGColor);
	CGContextSetFillColorWithColor(context, textColor.CGColor);

	UIColor *todayTextColor = [UIColor whiteColor];

	NSDateComponents *dateComponentsForToday = [self.gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
	NSDateComponents *dateComponentsForCurrentDate = [self.gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self.currentDate];

	for (NSUInteger row = 0; row < numberOfRow; row++) {
		for (NSUInteger col = 0; col < 7; col++) {
			NSDateComponents *drawingDateComponent = [self.gregorian components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:drawingDate];

			CGContextSaveGState(context);

			if ([drawingDateComponent isEqual:dateComponentsForToday]) {
				[self drawTodayMarkAtCol:col atRow:row context:context];

				CGContextSetStrokeColorWithColor(context, todayTextColor.CGColor);
				CGContextSetFillColorWithColor(context, todayTextColor.CGColor);
			}
			if (!self.bigCalendar && ![dateComponentsForToday isEqual:dateComponentsForCurrentDate] && [drawingDateComponent isEqual:dateComponentsForCurrentDate]) {
				[self drawCurrentDayMarkAtCol:col atRow:row context:context];

				CGContextSetStrokeColorWithColor(context, todayTextColor.CGColor);
				CGContextSetFillColorWithColor(context, todayTextColor.CGColor);
			}
			NSString *dayString = [NSString stringWithFormat:@"%d", drawingDateComponent.day];
			CGSize size = [dayString sizeWithFont:font];
			CGPoint point;
			if (self.bigCalendar) {
				point = CGPointMake((col + 1) * columnWidth - size.width - rightMargin, weekdayHeaderHeight + row * rowHeight + 3.0f);
			} else {
				point = CGPointMake(col * columnWidth + columnWidth / 2.0f - size.width/2.0f, weekdayHeaderHeight + row * rowHeight + rowHeight / 2.0f - size.height/2.0f);
			}
			[dayString drawAtPoint:point withFont:font];

			CGContextRestoreGState(context);

			drawingDate = [self.gregorian dateByAddingComponents:addComponent toDate:drawingDate options:0];
		}
	}

	if (self.bigCalendar) {
		NSArray *eventColors = [NSArray arrayWithObjects:
				[UIColor colorWithRed:199.0f/255.0f green:202.0f/255.0f blue:229.0f/255.0f alpha:1.0f], // border color
				[UIColor colorWithRed:223.0f/255.0f green:227.0f/255.0f blue:255.0f/255.0f alpha:1.0f], // fill gradient start
				[UIColor colorWithRed:233.0f/255.0f green:235.0f/255.0f blue:255.0f/255.0f alpha:1.0f], // fill gradient end
				[UIColor colorWithRed:38.0f/255.0f green:60.0f/255.0f blue:166.0f/255.0f alpha:1.0f], // circle border
				[UIColor colorWithRed:106.0f/255.0f green:117.0f/255.0f blue:299.0f/255.0f alpha:1.0f], nil];	// circle fill color
		[self drawEventFrom:self.startDate to:self.startDate colors:eventColors];
	}
	self.startDate = nil;
	self.gregorian = nil;
}

- (void)drawCurrentDayMarkAtCol:(NSInteger)col atRow:(NSInteger)row context:(CGContextRef)context {
	CGContextSaveGState(context);

	NSArray *colors = [NSArray arrayWithObjects:
			(__bridge id)[[UIColor colorWithRed:131.0f / 255.0f green:132.0f / 255.0f blue:132.0f / 255.0f alpha:1.0f] CGColor],
			(__bridge id)[[UIColor colorWithRed:99.0f / 255.0f green:100.0f / 255.0f blue:100.0f / 255.0f alpha:1.0f] CGColor], nil];
	CGRect drawRect = CGRectMake(col * columnWidth, row * rowHeight + weekdayHeaderHeight, columnWidth, self.bigCalendar?22.0f:rowHeight);
	drawLinearGradient(context, drawRect, colors);

	CGContextSetAllowsAntialiasing(context, true);
	CGContextSetRGBStrokeColor(context, 71.0f/255.0f, 72.0f/255.0f, 73.0f/255.0f, 1.0f);
	CGContextSetLineWidth(context, 1.0f);
	CGContextAddRect(context, drawRect);
	CGContextStrokePath(context);

	CGContextRestoreGState(context);
}


- (void)drawTodayMarkAtCol:(NSInteger)col atRow:(NSInteger)row context:(CGContextRef)context {
	CGContextSaveGState(context);

	NSArray *colors = [NSArray arrayWithObjects:
			(__bridge id)[[UIColor colorWithRed:119.0f / 255.0f green:122.0f / 255.0f blue:243.0f / 255.0f alpha:1.0f] CGColor],
			(__bridge id)[[UIColor colorWithRed:93.0f / 255.0f green:89.0f / 255.0f blue:208.0f / 255.0f alpha:1.0f] CGColor], nil];
	CGRect drawRect = CGRectMake(col * columnWidth, row * rowHeight + weekdayHeaderHeight, columnWidth, self.bigCalendar?22.0f:rowHeight);
	drawLinearGradient(context, drawRect, colors);

	CGContextSetAllowsAntialiasing(context, true);
	CGContextSetRGBStrokeColor(context, 82.0f/255.0f, 71.0f/255.0f, 210.0f/255.0f, 1.0f);
	CGContextSetLineWidth(context, 1.0f);
	CGContextAddRect(context, drawRect);
	CGContextStrokePath(context);

	CGContextRestoreGState(context);
}

- (NSCalendar *)gregorian {
	if (nil == _gregorian) {
		_gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	}
	return _gregorian;
}

- (NSDate *)startDate {
	if (nil == _startDate) {
		_startDate = [self firstDateOfMonthWithCalendar:self.gregorian];
	}
	FNLOG(@"start date = %@", _startDate);
	return _startDate;
}

- (void)setCurrentDate:(NSDate *)currentDate {
	_currentDate = currentDate;
	NSDateComponents *dateComponents = [self.gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:_currentDate];
	self.year = dateComponents.year;
	self.month = dateComponents.month;

	[self setNeedsDisplay];
}

@end
