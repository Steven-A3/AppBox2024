//
//  A3Utilities.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 6/11/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3Utilities.h"

NSString *const ID_KEY = @"uniqueID";
NSString *const NAME_KEY = @"name";

// A3KeyValueDB Key는 DaysCounter Calendar data, Wallet Category, Unit Data 저장시 Dictionary Key로 사용
// A3KeyValueDBDataObject가 해당 데이터, 기타는 metadata로 iCloud 상황에서 Sync시 참고하기 위해 사용
NSString *const A3KeyValueDBDataObject   = @"A3KeyValueDBDataObject";
NSString *const A3KeyValueDBState		 = @"A3KeyValueDBState";
NSString *const A3KeyValueDBUpdateDate	 = @"A3KeyValueDBUpdateDate";

NSString *const A3SettingsUserDefaultsThemeColorIndex = @"A3SettingsUserDefaultsThemeColorIndex";
NSString *const A3SettingsUseKoreanCalendarForLunarConversion = @"A3SettingsUseKoreanCalendarForLunarConversion";
/**
 *  AppBox Pro의 메인 메뉴 스타일을 두가지가 2015년 2월에 추가되었다.
 *  이날 이전에는 왼쪽 측면에서 화면이 밀고 들어오는 테이블 뷰 방식의 메뉴가 3.0 최초에 적용된 스타일 하나가 있었다.
 *  Version이 4.0이 되면서 메뉴 스타일 두가지, 헥사곤 스타일과 둥근 사각형 그리드 스타일 두가지가 추가 되었다.
 *  Version 4.0 디폴트는 헥사곤 스타일이다.
 *  설정은 아래의 키에 저장을 하고, 값은 A3SettingsMainMenuStyleTable, A3SettingsMainMenuStyleHexagon, A3SettingsMainMenuStyleGrid를 갖는다.
 */
NSString *const kA3SettingsMainMenuStyle = @"kA3SettingsMainMenuStyle";
NSString *const A3SettingsMainMenuStyleTable = @"tableStyle";
NSString *const A3SettingsMainMenuStyleHexagon = @"hexagon";
NSString *const A3SettingsMainMenuStyleIconGrid = @"iconGrid";

NSString *const A3SettingsMainMenuHexagonShouldAddQRCodeMenu = @"A3SettingsMainMenuHexagonShouldAddQRCodeMenu";
NSString *const A3SettingsMainMenuGridShouldAddQRCodeMenu = @"A3SettingsMainMenuGridShouldAddQRCodeMenu";

#pragma mark ------ Main Menu
NSString *const A3MainMenuDataEntityFavorites 				= @"A3MainMenuDataEntityFavorites";
NSString *const A3MainMenuDataEntityRecentlyUsed 			= @"A3MainMenuDataEntityRecentlyUsed";
NSString *const A3MainMenuDataEntityAllMenu 				= @"A3MainMenuDataEntityAllMenu";
NSString *const A3MainMenuUserDefaultsMaxRecentlyUsed 		= @"A3MainMenuUserDefaultsMaxRecentlyUsed";

// A3UserDefault에 저장을 하면 iCloud를 통한 동기화가 이루어 집니다.
// Core Data에 저장할 필요는 없습니다.
// 아래의 두 값은 디바이스간 동기화 방지를 위해서 NSUserDefaults에 저장합니다.
// 백업에는 포함해서 백업을 한다. 복원이 되어야 합니다.
NSString *const A3MainMenuHexagonMenuItems					= @"A3MainMenuHexagonMenuItems";
NSString *const A3MainMenuGridMenuItems						= @"A3MainMenuGridMenuItems";

#pragma mark ------ Battery
NSString *const A3BatteryChosenThemeIndex 					= @"A3BatteryChosenThemeIndex";
NSString *const A3BatteryChosenTheme 						= @"A3BatteryChosenTheme";
NSString *const A3BatteryAdjustedIndex 						= @"A3BatteryAdjustedIndex";
NSString *const A3BatteryShowIndex 							= @"A3BatteryShowIndex";

#pragma mark ------ Calculator
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
NSString *const A3ClockUseAutoLock                          = @"A3ClockUseAutoLock";
NSString *const A3ClockAutoDim                              = @"A3ClockAutoDim";

#pragma mark ------ Currency Converter
NSString *const A3CurrencyUserDefaultsAutoUpdate 			= @"A3CurrencyUserDefaultsAutoUpdate";
NSString *const A3CurrencyUserDefaultsUseCellularData 		= @"A3CurrencyUserDefaultsUseCellularData";
NSString *const A3CurrencyUserDefaultsShowNationalFlag 		= @"A3CurrencyUserDefaultsShowNationalFlag";
NSString *const A3CurrencyUserDefaultsLastInputValue 		= @"A3CurrencyUserDefaultsLastInputValue";

#pragma mark ------ Date Calculator
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
NSString *const A3DaysCounterUserDefaultsSlideShowOptions 	= @"A3DaysCounterUserDefaultsSlideShowOptions";
NSString *const A3DaysCounterLastOpenedMainIndex			= @"A3DaysCounterLastOpenedMainIndex";

#pragma mark ------ Expense List
NSString *const A3ExpenseListUserDefaultsCurrencyCode 		= @"A3ExpenseListUserDefaultsCurrencyCode";
NSString *const A3ExpenseListIsAddBudgetCanceledByUser 		= @"A3ExpenseListIsAddBudgetCanceledByUser";
NSString *const A3ExpenseListIsAddBudgetInitiatedOnce 		= @"A3ExpenseListIsAddBudgetInitiatedOnce";

#pragma mark ------ Holidays
NSString *const kHolidayCountriesForCurrentDevice 			= @"HolidayCountriesForCurrentDevice";
NSString *const kHolidayCountryExcludedHolidays 			= @"kHolidayCountryExcludedHolidays";
NSString *const kHolidayCountriesShowLunarDates 			= @"kHolidayCountriesShowLunarDates"; // Holds array of country codes

#pragma mark ------ Loan Calc
NSString *const A3LoanCalcUserDefaultShowDownPayment 		= @"A3LoanCalcUserDefaultShowDownPayment";
NSString *const A3LoanCalcUserDefaultShowExtraPayment 		= @"A3LoanCalcUserDefaultShowExtraPayment";
NSString *const A3LoanCalcUserDefaultShowAdvanced 			= @"A3LoanCalcUserDefaultShowAdvanced";
NSString *const A3LoanCalcUserDefaultsLoanDataKey 			= @"A3LoanCalcUserDefaultsLoanDataKey";
NSString *const A3LoanCalcUserDefaultsLoanDataKey_A 		= @"A3LoanCalcUserDefaultsLoanDataKey_A";
NSString *const A3LoanCalcUserDefaultsLoanDataKey_B 		= @"A3LoanCalcUserDefaultsLoanDataKey_B";
NSString *const A3LoanCalcUserDefaultsCustomCurrencyCode 	= @"A3LoanCalcUserDefaultsCustomCurrencyCode";

#pragma mark ------ Lady Calendar
NSString *const A3LadyCalendarCurrentAccountID              = @"A3LadyCalendarCurrentAccountID";
NSString *const A3LadyCalendarUserDefaultsSettings = @"A3LadyCalendarUserDefaultsSettings";
NSString *const A3LadyCalendarLastViewMonth                 = @"A3LadyCalendarLastViewMonth";

#pragma mark ------ Lunar Converter
NSString *const A3LunarConverterLastInputDateComponents 	= @"A3LunarConverterLastInputDateComponents";
NSString *const A3LunarConverterLastInputDateIsLunar        = @"A3LunarConverterLastInputDateIsLunar";

#pragma mark ------ Percent Calculator
NSString *const A3PercentCalcUserDefaultsCalculationType 	= @"A3PercentCalcUserDefaultsCalculationType";
NSString *const A3PercentCalcUserDefaultsSavedInputData 	= @"A3PercentCalcUserDefaultsSavedInputData";

#pragma mark ------ Sales Calculator
NSString *const A3SalesCalcUserDefaultsCurrencyCode 		= @"A3SalesCalcUserDefaultsCurrencyCode";
NSString *const A3SalesCalcUserDefaultsSavedInputDataKey 	= @"A3SalesCalcUserDefaultsSavedInputDataKey";

#pragma mark ------ Tip Calculator
NSString *const A3TipCalcUserDefaultsCurrencyCode 			= @"A3TipCalcUserDefaultsCurrencyCode";

#pragma mark ------ Unit Converter
NSString *const A3UnitConverterDefaultSelectedCategoryID 	= @"A3UnitConverterDefaultSelectedCategoryID";
NSString *const A3UnitConverterTableViewUnitValueKey 		= @"A3UnitConverterTableViewUnitValueKey";
NSString *const A3UnitConverterDataEntityUnitCategories 	= @"A3UnitConverterDataEntityUnitCategories";
NSString *const A3UnitConverterDataEntityConvertItems 		= @"A3UnitConverterDataEntityConvertItems";
NSString *const A3UnitConverterDataEntityFavorites = @"A3UnitConverterDataEntityFavorites";

#pragma mark ------ Unit Price
NSString *const A3UnitPriceUserDefaultsCurrencyCode			= @"A3UnitPriceUserDefaultsCurrencyCode";
NSString *const A3UnitPriceUserDataEntityPriceFavorites = @"A3UnitPriceUserDataEntityPriceFavorites";

#pragma mark ------ Wallet
NSString *const A3WalletUserDefaultsSelectedTab 			= @"A3WalletUserDefaultsSelectedTab";

#pragma mark ------ Passcode
NSString *const kUserDefaultTimerStart 						= @"AppBoxPasscodeTimerStart";
NSString *const kUserDefaultsKeyForPasscodeTimerDuration 	= @"kUserRequirePasscodeAfterMinutes";
NSString *const kUserDefaultsKeyForUseSimplePasscode 		= @"kUserUseSimplePasscode";
NSString *const kUserDefaultsKeyForUseTouchID 				= @"kUserDefaultsKeyForUseTouchID";
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
