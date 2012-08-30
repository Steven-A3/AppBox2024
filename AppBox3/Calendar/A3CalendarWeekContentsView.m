//
//  A3CalendarWeekContentsView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/3/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "A3CalendarWeekContentsView.h"
#import "A3CalendarWeekViewMetrics.h"
#import "A3Utilities.h"
#import "common.h"
#import "A3CalendarWeekCurrentTimeMarkView.h"

@interface A3CalendarWeekContentsView ()
@property (nonatomic, strong) A3CalendarWeekCurrentTimeMarkView *timeMarkView;
@property (nonatomic, strong) NSTimer *timerMarkUpdateTimer;

@end

@implementation A3CalendarWeekContentsView
@synthesize startDate = _startDate;
@synthesize timeMarkView = _timeMarkView;
@synthesize timerMarkUpdateTimer = _timerMarkUpdateTimer;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
		self.contentMode = UIViewContentModeRedraw;

		NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:60.0];
		_timerMarkUpdateTimer = [[NSTimer alloc] initWithFireDate:fireDate
											   interval:60.0
												 target:self
											   selector:@selector(updateTimeMark)
											   userInfo:nil
												repeats:YES];

		NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
		[runLoop addTimer:_timerMarkUpdateTimer forMode:NSDefaultRunLoopMode];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	FNLOG(@"drawRect %f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);

	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextSaveGState(context);
	CGContextSetAllowsAntialiasing(context, false);

	CGFloat left = roundf(CGRectGetMinX(rect) + A3_CALENDAR_WEEK_VIEW_ROW_HEADER_WIDTH);
	CGFloat top = roundf(CGRectGetMinY(rect));
	CGFloat right = roundf(CGRectGetMaxX(rect) - 1.0f);
	CGFloat bottom = roundf(CGRectGetMaxY(rect));
	CGFloat columnWidth = (CGRectGetWidth(rect) - A3_CALENDAR_WEEK_VIEW_ROW_HEADER_WIDTH) / 7.0;
	CGFloat rowHeight = roundf(A3_CALENDAR_WEEKVIEW_ROW_HEIGHT);
	CGFloat height = roundf(CGRectGetHeight(rect));

	CGContextSetFillColorWithColor(context, A3_CALENDAR_WEEK_VIEW_BACKGROUND_COLOR);
	CGContextAddRect(context, CGRectMake(left, top, roundf(columnWidth), height));
	CGContextAddRect(context, CGRectMake(right - columnWidth, top, roundf(columnWidth), height));
	CGContextFillPath(context);

	CGContextSetStrokeColorWithColor(context, A3_CALENDAR_WEEK_VIEW_LINE_COLOR);

	// Add vertical lines
	for (NSInteger index = 0; index < 8; index++) {
		CGFloat x = left + columnWidth * index;
		x = roundf(x) - (index == 7 ? 1.0f : 0.0f);
//		FNLOG(@"vertical line x coordinate %f", x);
		CGContextMoveToPoint(context, x, top);
		CGContextAddLineToPoint(context, x, bottom);
	}

	// Add horizontal hour lines
	for (NSInteger index = 0; index < 23; index++) {
		CGFloat y = roundf(top + rowHeight * (index + 1));
//		FNLOG(@"%f", y);
		CGContextMoveToPoint(context, left, y);
		CGContextAddLineToPoint(context, right, y);
	}
	CGContextStrokePath(context);

	CGContextSetLineDash(context, 1.0f, dash_line_pattern, 2);
	for (NSInteger index = 0; index < 24; index++) {
		CGFloat y = roundf(top + rowHeight * index + rowHeight / 2.0f);
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
	left = roundf(CGRectGetMinX(rect));
	for (NSInteger index = 0; index < 23; index++) {
		NSString *hourText = [dateFormatter stringFromDate:currentHour];
		CGSize size = [hourText sizeWithFont:hourFont];

		CGFloat x = roundf(left + A3_CALENDAR_WEEK_VIEW_ROW_HEADER_WIDTH - size.width - 3.0f);
		CGFloat y = roundf(top + rowHeight * (index + 1) - size.height / 2.0f);
		[hourText drawAtPoint:CGPointMake(x, y) withFont:hourFont];

		currentHour = [gregorian dateByAddingComponents:addingComponents toDate:currentHour options:0];
	}
	[self updateTimeMark];
}

- (void)removeFromSuperview {
	[super removeFromSuperview];

	[self.timerMarkUpdateTimer invalidate];
	self.timerMarkUpdateTimer = nil;
}

- (void)updateTimeMark {
	FNLOG(@"%f, %f, %f, %f", self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);

	CGFloat left = A3_CALENDAR_WEEK_VIEW_ROW_HEADER_WIDTH - 20.0f;
	CGFloat width = CGRectGetWidth(self.bounds) - A3_CALENDAR_WEEK_VIEW_ROW_HEADER_WIDTH + 20.0f;
	CGFloat height = 15.0f;

	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [gregorian components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:[NSDate date]];
	FNLOG(@"hour %d, minute %d", components.hour, components.minute);
	CGFloat top = ( ((CGFloat)components.hour * 60.0f + (CGFloat)components.minute) / (24.0f * 60.0f) ) * CGRectGetHeight(self.bounds) + CGRectGetMinY(self.bounds) - 7.0f;
	FNLOG(@"%f, %f, %f, %f", left, top, width, height);
	[self.timeMarkView setFrame:CGRectMake(left, top, width, height)];
}

- (A3CalendarWeekCurrentTimeMarkView *)timeMarkView {
	if (nil == _timeMarkView) {
		_timeMarkView = [[A3CalendarWeekCurrentTimeMarkView alloc] initWithFrame:CGRectZero];
		[self addSubview:_timeMarkView];
	}
	return _timeMarkView;
}

@end
