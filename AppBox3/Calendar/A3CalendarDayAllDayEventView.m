//
//  A3CalendarDayAllDayEventView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/28/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3CalendarDayAllDayEventView.h"
#import "A3CalendarWeekViewMetrics.h"
#import "common.h"

@implementation A3CalendarDayAllDayEventView

- (void)initializeView {
	self.contentMode = UIViewContentModeRedraw;
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
	// "all-day" text
	CGContextRef context = UIGraphicsGetCurrentContext();

	UIColor *textColor = A3_CALENDAR_DAY_VIEW_TEXT_COLOR;
	CGContextSetStrokeColorWithColor(context, textColor.CGColor);
	CGContextSetFillColorWithColor(context, textColor.CGColor);

	UIFont *font = [UIFont systemFontOfSize:11.0];
	NSString *alldayText = @"all-day";
	CGSize size = [alldayText sizeWithAttributes:@{NSFontAttributeName : font}];
	CGPoint point = CGPointMake(A3_CALENDAR_DAY_ALL_DAY_EVENT_ROW_HEADER_WIDTH - 5.0f - size.width, CGRectGetHeight(rect)/2.0f - size.height / 2.0f);
	[alldayText drawAtPoint:point withAttributes:@{NSFontAttributeName : font}];

	CGContextSetAllowsAntialiasing(context, false);

	UIColor *lineColor = A3_CALENDAR_DAY_VIEW_LINE_COLOR;
	CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
	CGContextAddRect(context, CGRectInset(CGRectMake(A3_CALENDAR_DAY_ALL_DAY_EVENT_ROW_HEADER_WIDTH, CGRectGetMinY(rect), CGRectGetWidth(rect) - A3_CALENDAR_DAY_ALL_DAY_EVENT_ROW_HEADER_WIDTH, CGRectGetHeight(rect)), 1.0f, 1.0f) );
	CGContextStrokePath(context);
	FNLOG(@"%f", CGRectGetHeight(rect));
}

@end
