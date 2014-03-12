//
//  A3Utilities.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 6/11/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "A3Utilities.h"

#pragma mark ------ Global for App
NSString *const A3AppDefaultUserCurrencyCode 				= @"A3AppDefaultUserCurrencyCode";

#pragma mark ------ Sales Calc

NSString *const A3SalesCalcDefaultUserCurrencyCode  		= @"A3SalesCalcDefaultUserCurrencyCode";
NSString *const A3SalesCalcDefaultKnownValueOriginalPrice	= @"A3SalesCalcDefaultKnownValueOriginalPrice";
NSString *const A3SalesCalcDefaultShowAdvanced				= @"A3SalesCalcDefaultShowAdvanced";

#pragma mark ------ Loan Calc

NSString *const A3LoanCalcDefaultUserCurrencyCode			= @"A3LoanCalcDefaultUserCurrencyCode";
NSString *const A3LoanCalcDefaultCalculationFor				= @"A3LoanCalcDefaultCalculationFor";
NSString *const A3LoanCalcDefaultShowDownPayment			= @"A3LoanCalcDefaultShowDownPayment";
NSString *const A3LoanCalcDefaultShowExtraPayment			= @"A3LoanCalcDefaultShowExtraPayment";
NSString *const A3LoanCalcDefaultShowAdvanced				= @"A3LoanCalcDefaultShowAdvanced";
NSString *const A3LoanCalcDefaultUseTermTypeMonth           = @"A3LoanCalcDefaultUseTermTypeMonth";
NSString *const A3LoanCalcDefaultUseSimpleInterest			= @"A3LoanCalcDefaultUseSimpleInterest";

#pragma mark ------ Expense List
NSString *const A3ExpenseListDefaultUserCurrencyCode		= @"A3ExpenseListDefaultUserCurrencyCode";
NSString *const A3ExpenseListDefaultShowAdvanced			= @"A3ExpenseListDefaultShowAdvanced";
NSString *const A3ExpenseListAddBudgetDefaultShowAdvanced   = @"A3ExpenseListAddBudgetDefaultShowAdvanced";

#pragma mark ------ Currency Converter
NSString *const A3CurrencyAutoUpdate						= @"A3CurrencyAutoUpdate";
NSString *const A3CurrencyUseCellularData 					= @"A3CurrencyUseCellularData";
NSString *const A3CurrencyShowNationalFlag					= @"A3CurrencyShowNationalFlag";

#pragma mark ------ Lunar Converter
NSString *const A3LunarConverterLastInputDateComponents = @"A3LunarConverterLastInputDateComponents";
NSString *const A3LunarConverterLastInputDateIsLunar        = @"A3LunarConverterLastInputDateIsLunar";

#pragma mark ------ Tip Calc
NSString *const A3TipCalcTax                                = @"A3TipCalcTax";
NSString *const A3TipCalcSplit                              = @"A3TipCalcSplit";
NSString *const A3TipCalcRoundingMethod                     = @"A3TipCalcRoundingMethod";

#pragma mark ------ Days Counter
NSString *const A3DaysCounterSlideshowOption                = @"A3DaysCounterSlideshowOption";

#pragma mark ------ Clock
NSString *const A3ClockTheTimeWithSeconds                   = @"A3ClockTheTimeWithSeconds";
NSString *const A3ClockFlashTheTimeSeparators               = @"A3ClockFlashTheTimeSeparators";
NSString *const A3ClockUse24hourClock                       = @"A3ClockUse24hourClock";
NSString *const A3ClockShowAMPM                             = @"A3ClockShowAMPM";
NSString *const A3ClockShowTheDayOfTheWeek                  = @"A3ClockShowTheDayOfTheWeek";
NSString *const A3ClockShowDate                             = @"A3ClockShowDate";
NSString *const A3ClockShowWeather                          = @"A3ClockShowWeather";
NSString *const A3ClockUsesFahrenheit 						= @"A3ClockUsesFahrenheit";
NSString *const A3ClockWaveClockColor						= @"A3ClockWaveClockColor";
NSString *const A3ClockWaveClockColorIndex					= @"A3ClockWaveClockColorIndex";
NSString *const A3ClockWaveCircleLayout						= @"A3ClockWaveCircleLayout";	// Array of circle type
NSString *const A3ClockFlipDarkColor						= @"A3ClockFlipDarkColor";
NSString *const A3ClockFlipDarkColorIndex					= @"A3ClockFlipDarkColorIndex";
NSString *const A3ClockFlipLightColor						= @"A3ClockFlipLightColor";
NSString *const A3ClockFlipLightColorIndex					= @"A3ClockFlipLightColorIndex";
NSString *const A3ClockLEDColor								= @"A3ClockLEDColor";
NSString *const A3ClockLEDColorIndex						= @"A3ClockLEDColorIndex";

#pragma mark ------ Unit Converter
NSString *const A3UnitConverterDefaultCurrentUnitTap		= @"A3UnitConverterDefaultCurrentUnitTap";

CGFloat dash_line_pattern[] = {2.0f, 2.0f};

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

+ (NSDate *)dateByAddingDay:(NSInteger)difference toDate:(NSDate *)date {
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *differenceComponents = [[NSDateComponents alloc] init];
	differenceComponents.day = difference;
	return [gregorian dateByAddingComponents:differenceComponents toDate:date options:0];
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
