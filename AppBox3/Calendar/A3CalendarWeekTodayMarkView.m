//
//  A3CalendarWeekTodayMarkView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/10/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "A3CalendarWeekTodayMarkView.h"
#import "A3CalendarWeekViewMetrics.h"
#import "A3Utilities.h"
#import "common.h"

@implementation A3CalendarWeekTodayMarkView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
		self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	FNLOG(@"drawRect %f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);

    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextSetAllowsAntialiasing(context, false);

	CGRect gradientRect = CGRectInset(CGRectMake(roundf(CGRectGetMinX(self.bounds)), roundf(CGRectGetMinY(self.bounds)), roundf(CGRectGetWidth(self.bounds)), roundf(A3_CALENDAR_WEEK_HEADER_VIEW_LABEL_HEIGHT) + 1.0f), 1.0f, 1.0f);
	NSArray *colors = [NSArray arrayWithObjects:
			(__bridge id)[UIColor colorWithRed:85.0f/255.0f green:90.0f/255.0f blue:241.0f/255.0f alpha:1.0f].CGColor,
			(__bridge id)[UIColor colorWithRed:51.0f/255.0f green:52.0f/255.0f blue:196.0f/255.0f alpha:1.0f].CGColor,
			nil];
	FNLOG(@"gradient rect %f, %f, %f, %f", gradientRect.origin.x, gradientRect.origin.y, gradientRect.size.width, gradientRect.size.height);
	drawLinearGradient(context, gradientRect, colors);

	CGContextSetRGBStrokeColor(context, 28.0f/255.0f, 45.0f/255.0f, 174.0f/255.0f, 1.0f);
	CGContextSetRGBFillColor(context, 28.0f/255.0f, 45.0f/255.0f, 174.0f/255.0f, 1.0f);
	CGFloat offset = (UserInterfacePortrait()?2.0f:1.0f);
	CGRect rectangleToDraw = CGRectMake(roundf(CGRectGetMinX(self.bounds)),
			roundf(CGRectGetMinY(self.bounds)) + 1.0f,
			roundf(CGRectGetWidth(self.bounds)) - offset,
			roundf(CGRectGetHeight(self.bounds)) - 1.0f);
	FNLOG(@"todaymarkview %f, %f, %f, %f", rectangleToDraw.origin.x, rectangleToDraw.origin.y, rectangleToDraw.size.width, rectangleToDraw.size.height);
	CGContextAddRect(context, rectangleToDraw);

	CGContextMoveToPoint(context, roundf(CGRectGetMinX(self.bounds)), roundf(A3_CALENDAR_WEEK_HEADER_VIEW_LABEL_HEIGHT));
	CGContextAddLineToPoint(context, roundf(CGRectGetMaxX(self.bounds)) - offset, roundf(A3_CALENDAR_WEEK_HEADER_VIEW_LABEL_HEIGHT));
	CGContextStrokePath(context);

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"d EEE"];
	NSString *text = [dateFormatter stringFromDate:[NSDate date]];
	UIFont *font = A3_CALENDAR_WEEK_VIEW_HEADER_FONT;
	CGSize size = [text sizeWithFont:font];
	CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
	CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
	CGContextSetAllowsAntialiasing(context, true);
	[text drawAtPoint:CGPointMake(roundf(CGRectGetMaxX(self.bounds) - size.width - A3_CALENDAR_WEEK_HEADER_VIEW_TEXT_RIGHT_MARGIN),
			roundf(CGRectGetMinY(self.bounds) + A3_CALENDAR_WEEK_HEADER_VIEW_TEXT_TOP_MARGIN)) withFont:font];
}

@end
