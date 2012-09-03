//
//  A3CalendarDayHourlyView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/30/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "A3CalendarDayHourlyView.h"
#import "A3CalendarDayHourlyContentsView.h"
#import "common.h"
#import "A3CalendarWeekViewMetrics.h"

@interface A3CalendarDayHourlyView ()
@property(nonatomic, retain) A3CalendarDayHourlyContentsView *contentsView;

@end

@implementation A3CalendarDayHourlyView
@synthesize contentsView = _contentsView;

- (void)initialize {
	self.contentSize = CGSizeMake(CGRectGetWidth(self.bounds), A3_CALENDAR_DAY_HOURLY_VIEW_HEIGHT);
	self.contentOffset = CGPointMake(0.0f, 0.0f);
	self.bounces = NO;
	self.contentMode = UIViewContentModeRedraw;
	[self addSubview:self.contentsView];
}

- (id)initWithFrame:(CGRect)frame
{
	FNLOG(@"Is it called?");
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	FNLOG(@"Is it called?");
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self initialize];
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
	CGContextSetStrokeColorWithColor(context, A3_CALENDAR_DAY_VIEW_LINE_COLOR.CGColor);

	CGContextMoveToPoint(context, A3_CALENDAR_DAY_ALL_DAY_EVENT_ROW_HEADER_WIDTH, CGRectGetMinY(rect) + 1.0f);
	CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect) + 1.0f);
	CGContextMoveToPoint(context, A3_CALENDAR_DAY_ALL_DAY_EVENT_ROW_HEADER_WIDTH, CGRectGetMaxY(rect));
	CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
	CGContextStrokePath(context);
}

- (A3CalendarDayHourlyContentsView *)contentsView {
	if (nil == _contentsView) {
		_contentsView = [[A3CalendarDayHourlyContentsView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds), self.contentSize.height)];
		_contentsView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	}
	return _contentsView;
}

- (void)resetContentSizeAfterLayoutChange {
	FNLOG(@"bounds %f, %f", CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
	FNLOG(@"contentsize %f, %f", self.contentSize.width, self.contentSize.height);
	[self setContentSize:CGSizeMake(CGRectGetWidth(self.bounds), A3_CALENDAR_DAY_HOURLY_VIEW_HEIGHT)];
	[self.contentsView setFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds), A3_CALENDAR_DAY_HOURLY_VIEW_HEIGHT)];
	FNLOG(@"contentsize %f, %f", self.contentSize.width, self.contentSize.height);
}

@end
