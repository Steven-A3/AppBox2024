//
//  A3Utilities.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 6/11/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "A3Utilities.h"

float dash_line_pattern[] = {2.0f, 2.0f};

@implementation A3Utilities

+ (NSDate *)firstWeekdayOfDate:(NSDate *)date {
	NSDate *result;
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [gregorian components:NSWeekdayCalendarUnit fromDate:date];
	// weekday 1 == sunday, 1SUN 2MON 3TUE 4WED 5THU 6FRI 7SAT
	if (components.weekday > 1) {
		NSDateComponents *subtractComponents = [[NSDateComponents alloc] init];
		subtractComponents.day = 1 - components.weekday;
		result = [gregorian dateByAddingComponents:subtractComponents toDate:date options:0];
	} else {
		result = date;
	}

	return result;
}

@end

void addLeftGradientLayer8Point(UIView *targetView) {
	// Gradient layer for Tableview left and right side
	CAGradientLayer *leftGradientOnMenuLayer = [CAGradientLayer layer];
	[leftGradientOnMenuLayer setColors:
			[NSArray arrayWithObjects:
					(__bridge id)[[UIColor colorWithRed:32.0f/255.0f green:34.0f/255.0f blue:34.0f/255.0f alpha:0.8f] CGColor],
					(__bridge id)[[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f] CGColor],
					nil ] ];
	[leftGradientOnMenuLayer setAnchorPoint:CGPointMake(0.0f, 0.0f)];
	[leftGradientOnMenuLayer setBounds:[targetView bounds]];
	[leftGradientOnMenuLayer setStartPoint:CGPointMake(0.0f, 0.5f)];
	[leftGradientOnMenuLayer setEndPoint:CGPointMake(1.0f, 0.5f)];
	[[targetView layer] insertSublayer:leftGradientOnMenuLayer atIndex:1];
}


void addRightGradientLayer8Point(UIView *targetView) {
	CAGradientLayer *rightGradientOnMenuLayer = [CAGradientLayer layer];
	[rightGradientOnMenuLayer setColors:
			[NSArray arrayWithObjects:
					(__bridge id)[[UIColor colorWithRed:32.0f/255.0f green:34.0f/255.0f blue:34.0f/255.0f alpha:0.8f] CGColor],
					(__bridge id)[[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f] CGColor],
					nil ] ];
	[rightGradientOnMenuLayer setAnchorPoint:CGPointMake(0.0f, 0.0f)];
	[rightGradientOnMenuLayer setBounds:[targetView bounds]];
	[rightGradientOnMenuLayer setStartPoint:CGPointMake(1.0f, 0.5f)];
	[rightGradientOnMenuLayer setEndPoint:CGPointMake(0.0f, 0.5f)];
	[[targetView layer] insertSublayer:rightGradientOnMenuLayer atIndex:1];
}

void drawLinearGradient(CGContextRef context, CGRect rect, NSArray *colors) {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0f, 1.0f };
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextSaveGState(context);
    CGContextAddRect(context, rect);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
}

BOOL UserInterfacePortrait() {
	return UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
}