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

#pragma mark ------ Lady Calendar
NSString *const A3LadyCalendarCurrentAccountID              = @"A3LadyCalendarCurrentAccountID";
NSString *const A3LadyCalendarSetting                       = @"A3LadyCalendarSetting";
NSString *const A3LadyCalendarOvulationDays                 = @"A3LadyCalendarOvulationDays";
NSString *const A3LadyCalendarLastViewMonth                 = @"A3LadyCalendarLastViewMonth";

CGFloat dash_line_pattern[] = {2.0f, 2.0f};

@implementation A3Utilities

@end

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
