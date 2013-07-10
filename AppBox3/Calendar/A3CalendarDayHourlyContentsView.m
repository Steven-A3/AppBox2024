//
//  A3CalendarDayHourlyContentsView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/30/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3CalendarDayHourlyContentsView.h"
#import "A3CalendarWeekViewMetrics.h"
#import "A3Utilities.h"
#import "A3CalendarCurrentTimeMarkView.h"
#import "common.h"

@interface A3CalendarDayHourlyContentsView ()
@property(nonatomic, strong) A3CalendarCurrentTimeMarkView *timeMarkView;
@property(nonatomic, strong) NSTimer *timeMarkUpdateTimer;


@end

@implementation A3CalendarDayHourlyContentsView
@synthesize timeMarkView = _timeMarkView;
@synthesize timeMarkUpdateTimer = _timeMarkUpdateTimer;


- (void)initializeView {
	self.backgroundColor = [UIColor clearColor];
	self.contentMode = UIViewContentModeRedraw;

	[self addSubview:self.timeMarkView];

	NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:60.0];
	_timeMarkUpdateTimer = [[NSTimer alloc] initWithFireDate:fireDate
													 interval:60.0
													   target:self
													 selector:@selector(updateTimeMark)
													 userInfo:nil
													  repeats:YES];

	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	[runLoop addTimer:_timeMarkUpdateTimer forMode:NSDefaultRunLoopMode];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self initializeView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
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
    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextSaveGState(context);
	CGContextSetAllowsAntialiasing(context, false);

	CGFloat left = roundf(CGRectGetMinX(rect) + A3_CALENDAR_DAY_ALL_DAY_EVENT_ROW_HEADER_WIDTH);
	CGFloat top = roundf(CGRectGetMinY(rect));
	CGFloat right = roundf(CGRectGetMaxX(rect) - 1.0f);
	CGFloat rowHeight = roundf(A3_CALENDAR_DAY_HOURLY_ROW_HEIGHT);
	CGFloat width = roundf(CGRectGetWidth(rect) - A3_CALENDAR_DAY_ALL_DAY_EVENT_ROW_HEADER_WIDTH);
	CGFloat height = roundf(CGRectGetHeight(rect));

	CGContextSetStrokeColorWithColor(context, A3_CALENDAR_DAY_VIEW_LINE_COLOR.CGColor);

	CGContextAddRect(context, CGRectMake(left, top + 1.0f, width - 1.0f, height));
	CGContextStrokePath(context);

	// Add horizontal hour lines
	for (NSInteger index = 0; index < 23; index++) {
		CGFloat y = roundf(top + rowHeight * (index + 1));
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
	CGContextSetStrokeColorWithColor(context, A3_CALENDAR_DAY_VIEW_TEXT_COLOR.CGColor);
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *dateComponents = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
	dateComponents.hour = 1;
	NSDate *drawingHour = [gregorian dateFromComponents:dateComponents];

	NSDateComponents *addingComponents = [[NSDateComponents alloc] init];
	addingComponents.hour = 1;

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"h a"];
	UIFont *hourFont = [UIFont systemFontOfSize:10.0f];
	left = roundf(CGRectGetMinX(rect));
	for (NSInteger index = 0; index < 23; index++) {
		NSString *hourText = [dateFormatter stringFromDate:drawingHour];
		CGSize size = [hourText sizeWithAttributes:@{NSFontAttributeName:hourFont}];

		CGFloat x = roundf(left + A3_CALENDAR_DAY_ALL_DAY_EVENT_ROW_HEADER_WIDTH - size.width - 3.0f);
		CGFloat y = roundf(top + rowHeight * (index + 1) - size.height / 2.0f);
		[hourText drawAtPoint:CGPointMake(x, y) withAttributes:@{NSFontAttributeName:hourFont}];

		drawingHour = [gregorian dateByAddingComponents:addingComponents toDate:drawingHour options:0];
	}
	[self updateTimeMark];
}

- (void)removeFromSuperview {
	[super removeFromSuperview];

	[self.timeMarkUpdateTimer invalidate];
	self.timeMarkUpdateTimer = nil;
}

- (void)updateTimeMark {
	FNLOG(@"%f, %f, %f, %f", self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);

	CGFloat left = A3_CALENDAR_DAY_ALL_DAY_EVENT_ROW_HEADER_WIDTH - 20.0f;
	CGFloat width = CGRectGetWidth(self.bounds) - A3_CALENDAR_DAY_ALL_DAY_EVENT_ROW_HEADER_WIDTH + 20.0f;
	CGFloat height = 15.0f;

	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [gregorian components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:[NSDate date]];
	FNLOG(@"hour %d, minute %d", components.hour, components.minute);
	CGFloat top = ( ((CGFloat)components.hour * 60.0f + (CGFloat)components.minute) / (24.0f * 60.0f) ) * CGRectGetHeight(self.bounds) + CGRectGetMinY(self.bounds) - 7.0f;
	FNLOG(@"%f, %f, %f, %f", left, top, width, height);
	[self.timeMarkView setFrame:CGRectMake(left, top, width, height)];
}

- (A3CalendarCurrentTimeMarkView *)timeMarkView {
	if (nil == _timeMarkView) {
		_timeMarkView = [[A3CalendarCurrentTimeMarkView alloc] initWithFrame:CGRectZero];
	}
	return _timeMarkView;
}

@end
