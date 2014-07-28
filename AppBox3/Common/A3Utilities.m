//
//  A3Utilities.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 6/11/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3Utilities.h"

NSString *const A3SettingsUserDefaultsThemeColorIndex = @"A3SettingsUserDefaultsThemeColorIndex";
NSString *const A3SettingsUseKoreanCalendarForLunarConversion = @"A3SettingsUseKoreanCalendarForLunarConversion";

#pragma mark ------ Main Menu
NSString *const A3MainMenuUserDefaultsFavorites 			= @"A3MainMenuUserDefaultsFavorites";
NSString *const A3MainMenuUserDefaultsRecentlyUsed 			= @"A3MainMenuUserDefaultsRecentlyUsed";
NSString *const A3MainMenuUserDefaultsAllMenu 				= @"A3MainMenuUserDefaultsAllMenu";
NSString *const A3MainMenuUserDefaultsMaxRecentlyUsed 		= @"A3MainMenuUserDefaultsMaxRecentlyUsed";
NSString *const A3MainMenuUserDefaultsUpdateDate			= @"A3MainMenuUserDefaultsUpdateDate";
NSString *const A3MainMenuUserDefaultsCloudUpdateDate		= @"A3MainMenuUserDefaultsCloudUpdateDate";

#pragma mark ------ Battery
NSString *const A3BatteryChosenThemeIndex 					= @"A3BatteryChosenThemeIndex";
NSString *const A3BatteryChosenTheme 						= @"A3BatteryChosenTheme";
NSString *const A3BatteryAdjustedIndex 						= @"A3BatteryAdjustedIndex";
NSString *const A3BatteryShowIndex 							= @"A3BatteryShowIndex";

#pragma mark ------ Calculator
NSString *const A3CalculatorUserDefaultsUpdateDate 			= @"A3CalculatorUserDefaultsUpdateDate";
NSString *const A3CalculatorUserDefaultsCloudUpdateDate 	= @"A3CalculatorUserDefaultsCloudUpdateDate";
NSString *const A3CalculatorUserDefaultsSavedLastExpression = @"A3CalculatorUserDefaultsSavedLastExpression";
NSString *const A3CalculatorUserDefaultsRadianDegreeState 	= @"A3CalculatorUserDefaultsRadianDegreeState";
NSString *const A3CalculatorUserDefaultsCalculatorMode 		= @"A3CalculatorUserDefaultsCalculatorMode";

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
NSString *const A3ClockUserDefaultsCurrentPage 				= @"A3ClockUserDefaultsCurrentPage";

#pragma mark ------ Currency Converter
NSString *const A3CurrencyUserDefaultsAutoUpdate 			= @"A3CurrencyUserDefaultsAutoUpdate";
NSString *const A3CurrencyUserDefaultsUseCellularData 		= @"A3CurrencyUserDefaultsUseCellularData";
NSString *const A3CurrencyUserDefaultsShowNationalFlag 		= @"A3CurrencyUserDefaultsShowNationalFlag";
NSString *const A3CurrencyUserDefaultsLastInputValue 		= @"A3CurrencyUserDefaultsLastInputValue";
NSString *const A3CurrencyUserDefaultsUpdateDate 			= @"A3CurrencyUserDefaultsUpdateDate";
NSString *const A3CurrencyUserDefaultsCloudUpdateDate 		= @"A3CurrencyUserDefaultsCloudUpdateDate";

#pragma mark ------ Date Calculator
NSString *const A3DateCalcDefaultsUpdateDate 				= @"A3DateCalcDefaultsUpdateDate";
NSString *const A3DateCalcDefaultsCloudUpdateDate 			= @"A3DateCalcDefaultsCloudUpdateDate";
NSString *const A3DateCalcDefaultsIsAddSubMode 				= @"A3DateCalcDefaultsIsAddSubMode";
NSString *const A3DateCalcDefaultsFromDate 					= @"A3DateCalcDefaultsFromDate";
NSString *const A3DateCalcDefaultsToDate 					= @"A3DateCalcDefaultsToDate";
NSString *const A3DateCalcDefaultsOffsetDate 				= @"A3DateCalcDefaultsOffsetDate";
NSString *const A3DateCalcDefaultsDidSelectMinus 			= @"A3DateCalcDefaultsDidSelectMinus";
NSString *const A3DateCalcDefaultsSavedYear 				= @"A3DateCalcDefaultSavedYear";
NSString *const A3DateCalcDefaultsSavedMonth 				= @"A3DateCalcDefaultSavedMonth";
NSString *const A3DateCalcDefaultsSavedDay 					= @"A3DateCalcDefaultSavedDay";
NSString *const A3DateCalcDefaultsDurationType 				= @"A3DateCalcDefaultsDurationType";
NSString *const A3DateCalcDefaultsExcludeOptions 			= @"A3DateCalcDefaultsExcludeOptions";

#pragma mark ------ Days Counter
NSString *const A3DaysCounterUserDefaultsUpdateDate			= @"A3DaysCounterUserDefaultsUpdateDate";
NSString *const A3DaysCounterUserDefaultsCloudUpdateDate	= @"A3DaysCounterUserDefaultsCloudUpdateDate";
NSString *const A3DaysCounterUserDefaultsSlideShowOptions 	= @"A3DaysCounterUserDefaultsSlideShowOptions";
NSString *const A3DaysCounterLastOpenedMainIndex			= @"A3DaysCounterLastOpenedMainIndex";

#pragma mark ------ Expense List
NSString *const A3ExpenseListUserDefaultsCurrencyCode 		= @"A3ExpenseListUserDefaultsCurrencyCode";
NSString *const A3ExpenseListIsAddBudgetCanceledByUser 		= @"A3ExpenseListIsAddBudgetCanceledByUser";
NSString *const A3ExpenseListIsAddBudgetInitiatedOnce 		= @"A3ExpenseListIsAddBudgetInitiatedOnce";
NSString *const A3ExpenseListUserDefaultsUpdateDate 		= @"A3ExpenseListUserDefaultsUpdateDate";
NSString *const A3ExpenseListUserDefaultsCloudUpdateDate 	= @"A3ExpenseListUserDefaultsCloudUpdateDate";

#pragma mark ------ Holidays
NSString *const kHolidayCountriesForCurrentDevice 			= @"HolidayCountriesForCurrentDevice";
NSString *const kHolidayCountryExcludedHolidays 			= @"kHolidayCountryExcludedHolidays";
NSString *const kHolidayCountriesShowLunarDates 			= @"kHolidayCountriesShowLunarDates"; // Holds array of country codes

#pragma mark ------ Loan Calc
NSString *const A3LoanCalcUserDefaultShowDownPayment 		= @"A3LoanCalcUserDefaultShowDownPayment";
NSString *const A3LoanCalcUserDefaultShowExtraPayment 		= @"A3LoanCalcUserDefaultShowExtraPayment";
NSString *const A3LoanCalcUserDefaultShowAdvanced 			= @"A3LoanCalcUserDefaultShowAdvanced";
NSString *const A3LoanCalcUserDefaultsUpdateDate 			= @"A3LoanCalcUserDefaultsUpdateDate";
NSString *const A3LoanCalcUserDefaultsCloudUpdateDate 		= @"A3LoanCalcUserDefaultsCloudUpdateDate";
NSString *const A3LoanCalcUserDefaultsLoanDataKey 			= @"A3LoanCalcUserDefaultsLoanDataKey";
NSString *const A3LoanCalcUserDefaultsLoanDataKey_A 		= @"A3LoanCalcUserDefaultsLoanDataKey_A";
NSString *const A3LoanCalcUserDefaultsLoanDataKey_B 		= @"A3LoanCalcUserDefaultsLoanDataKey_B";
NSString *const A3LoanCalcUserDefaultsCustomCurrencyCode 	= @"A3LoanCalcUserDefaultsCustomCurrencyCode";

#pragma mark ------ Lady Calendar
NSString *const A3LadyCalendarCurrentAccountID              = @"A3LadyCalendarCurrentAccountID";
NSString *const A3LadyCalendarSetting                       = @"A3LadyCalendarSetting";
NSString *const A3LadyCalendarLastViewMonth                 = @"A3LadyCalendarLastViewMonth";
NSString *const A3LadyCalendarUserDefaultsUpdateDate		= @"A3LadyCalendarUserDefaultsUpdateDate";
NSString *const A3LadyCalendarUserDefaultsCloudUpdateDate	= @"A3LadyCalendarUserDefaultsCloudUpdateDate";

#pragma mark ------ Lunar Converter
NSString *const A3LunarConverterLastInputDateComponents 	= @"A3LunarConverterLastInputDateComponents";
NSString *const A3LunarConverterLastInputDateIsLunar        = @"A3LunarConverterLastInputDateIsLunar";
NSString *const A3LunarConverterUserDefaultsUpdateDate		= @"A3LunarConverterUserDefaultsUpdateDate";
NSString *const A3LunarConverterUserDefaultsCloudUpdateDate	= @"A3LunarConverterUserDefaultsCloudUpdateDate";

#pragma mark ------ Percent Calculator
NSString *const A3PercentCalcUserDefaultsCalculationType 	= @"A3PercentCalcUserDefaultsCalculationType";
NSString *const A3PercentCalcUserDefaultsSavedInputData 	= @"A3PercentCalcUserDefaultsSavedInputData";
NSString *const A3PercentCalcUserDefaultsUpdateDate 		= @"A3PercentCalcUserDefaultsUpdateDate";
NSString *const A3PercentCalcUserDefaultsCloudUpdateDate 	= @"A3PercentCalcUserDefaultsCloudUpdateDate";

#pragma mark ------ Sales Calculator
NSString *const A3SalesCalcUserDefaultsCurrencyCode 		= @"A3SalesCalcUserDefaultsCurrencyCode";
NSString *const A3SalesCalcUserDefaultsSavedInputDataKey 	= @"A3SalesCalcUserDefaultsSavedInputDataKey";
NSString *const A3SalesCalcUserDefaultsUpdateDate 			= @"A3SalesCalcUserDefaultsUpdateDate";
NSString *const A3SalesCalcUserDefaultsCloudUpdateDate 		= @"A3SalesCalcUserDefaultsCloudUpdateDate";

#pragma mark ------ Tip Calculator
NSString *const A3TipCalcUserDefaultsCurrencyCode 			= @"A3TipCalcUserDefaultsCurrencyCode";
NSString *const A3TipCalcUserDefaultsUpdateDate 			= @"A3TipCalcUserDefaultsUpdateDate";
NSString *const A3TipCalcUserDefaultsCloudUpdateDate 		= @"A3TipCalcUserDefaultsCloudUpdateDate";

#pragma mark ------ Unit Converter
NSString *const A3UnitConverterDefaultSelectedCategoryID 	= @"A3UnitConverterDefaultSelectedCategoryID";
NSString *const A3UnitConverterTableViewUnitValueKey 		= @"A3UnitConverterTableViewUnitValueKey";
NSString *const A3UnitConverterUserDefaultsUpdateDate 		= @"A3UnitConverterUserDefaultsUpdateDate";
NSString *const A3UnitConverterUserDefaultsCloudUpdateDate 	= @"A3UnitConverterUserDefaultsCloudUpdateDate";
NSString *const A3UnitConverterUserDefaultsUnitCategories	= @"A3UnitConverterUserDefaultsUnitCategories";
NSString *const A3UnitConverterUserDefaultsConvertItems  	= @"A3UnitConverterUserDefaultsConvertItems";
NSString *const A3UnitConverterUserDefaultsFavorites		= @"A3UnitConverterUserDefaultsFavorites";

#pragma mark ------ Unit Price
NSString *const A3UnitPriceUserDefaultsCurrencyCode			= @"A3UnitPriceUserDefaultsCurrencyCode";
NSString *const A3UnitPriceUserDefaultsUpdateDate 			= @"A3UnitPriceUserDefaultsUpdateDate";
NSString *const A3UnitPriceUserDefaultsCloudUpdateDate 		= @"A3UnitPriceUserDefaultsCloudUpdateDate";
NSString *const A3UnitPriceUserDefaultsUnitFavorites		= @"A3UnitPriceUserDefaultsUnitFavorites";

#pragma mark ------ Wallet
NSString *const A3WalletUserDefaultsSelectedTab 			= @"A3WalletUserDefaultsSelectedTab";
NSString *const A3WalletUserDefaultsCategoryInfo			= @"A3WalletUserDefaultsCategoryInfo";
NSString *const A3WalletUserDefaultsUpdateDate				= @"A3WalletUserDefaultsUpdateDate";
NSString *const A3WalletUserDefaultsCloudUpdateDate			= @"A3WalletUserDefaultsCloudUpdateDate";

#pragma mark ------ Passcode
NSString *const kUserDefaultTimerStart 						= @"AppBoxPasscodeTimerStart";
NSString *const kUserDefaultsKeyForPasscodeTimerDuration 	= @"kUserRequirePasscodeAfterMinutes";
NSString *const kUserDefaultsKeyForUseSimplePasscode 		= @"kUserUseSimplePasscode";
NSString *const kUserDefaultsKeyForAskPasscodeForStarting 	= @"kUserRequirePasscodeAppBoxPro";
NSString *const kUserDefaultsKeyForAskPasscodeForSettings 	= @"kUserRequirePasscodeSettiings";
NSString *const kUserDefaultsKeyForAskPasscodeForDaysCounter = @"kUserRequirePasscodeDaysUntil";
NSString *const kUserDefaultsKeyForAskPasscodeForLadyCalendar = @"kUserRequirePasscodePCalendar";
NSString *const kUserDefaultsKeyForAskPasscodeForWallet 	= @"passcodeAskPasscodeForWallet";


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
