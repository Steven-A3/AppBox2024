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
	// "all-day" text
	CGContextRef context = UIGraphicsGetCurrentContext();

	UIColor *textColor = [UIColor colorWithRed:101.0f/255.0f green:101.0f/255.0f blue:101.0f/255.0f alpha:1.0f];
	CGContextSetStrokeColorWithColor(context, textColor.CGColor);
	CGContextSetFillColorWithColor(context, textColor.CGColor);

	UIFont *font = [UIFont systemFontOfSize:11.0];
	NSString *alldayText = @"all-day";
	CGSize size = [alldayText sizeWithFont:font];
	CGPoint point = CGPointMake(A3_CALENDAR_DAY_ALL_DAY_EVENT_ROW_HEADER_WIDTH - 5.0f - size.width, CGRectGetHeight(rect)/2.0f - size.height / 2.0f);
	[alldayText drawAtPoint:point withFont:font];

	CGContextSetAllowsAntialiasing(context, false);

	UIColor *lineColor = [UIColor colorWithRed:192.0f/255.0f green:193.0f/255.0f blue:194.0f/255.0f alpha:1.0f];
	CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
	CGContextAddRect(context, CGRectInset(CGRectMake(A3_CALENDAR_DAY_ALL_DAY_EVENT_ROW_HEADER_WIDTH, CGRectGetMinY(rect), CGRectGetWidth(rect) - A3_CALENDAR_DAY_ALL_DAY_EVENT_ROW_HEADER_WIDTH, CGRectGetHeight(rect)), 1.0f, 1.0f) );
	CGContextStrokePath(context);
	FNLOG(@"%f", CGRectGetHeight(rect));
}

@end
