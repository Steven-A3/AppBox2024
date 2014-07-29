//
//  A3UserDefaults.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 1/22/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#ifndef AppBox3_A3UserDefaults_h
#define AppBox3_A3UserDefaults_h

extern NSString *const A3SettingsUserDefaultsThemeColorIndex;
extern NSString *const A3SettingsUseKoreanCalendarForLunarConversion;

#pragma mark ------ Main Menu
extern NSString *const A3MainMenuUserDefaultsFavorites;
extern NSString *const A3MainMenuUserDefaultsRecentlyUsed;
extern NSString *const A3MainMenuUserDefaultsAllMenu;
extern NSString *const A3MainMenuUserDefaultsMaxRecentlyUsed;
extern NSString *const A3MainMenuUserDefaultsUpdateDate;
extern NSString *const A3MainMenuUserDefaultsCloudUpdateDate;

#pragma mark ------ Loan Calc
extern NSString *const A3LoanCalcUserDefaultShowDownPayment;
extern NSString *const A3LoanCalcUserDefaultShowExtraPayment;
extern NSString *const A3LoanCalcUserDefaultShowAdvanced;
extern NSString *const A3LoanCalcUserDefaultsUpdateDate;
extern NSString *const A3LoanCalcUserDefaultsCloudUpdateDate;
extern NSString *const A3LoanCalcUserDefaultsLoanDataKey;
extern NSString *const A3LoanCalcUserDefaultsLoanDataKey_A;
extern NSString *const A3LoanCalcUserDefaultsLoanDataKey_B;
extern NSString *const A3LoanCalcUserDefaultsCustomCurrencyCode;

#pragma mark ------ Expense List
extern NSString *const A3ExpenseListUserDefaultsCurrencyCode;
extern NSString *const A3ExpenseListIsAddBudgetCanceledByUser;
extern NSString *const A3ExpenseListIsAddBudgetInitiatedOnce;
extern NSString *const A3ExpenseListUserDefaultsUpdateDate;
extern NSString *const A3ExpenseListUserDefaultsCloudUpdateDate;

#pragma mark ------ Currency Converter
extern NSString *const A3CurrencyUserDefaultsAutoUpdate;
extern NSString *const A3CurrencyUserDefaultsUseCellularData;
extern NSString *const A3CurrencyUserDefaultsShowNationalFlag;
extern NSString *const A3CurrencyUserDefaultsLastInputValue;
extern NSString *const A3CurrencyUserDefaultsUpdateDate;
extern NSString *const A3CurrencyUserDefaultsCloudUpdateDate;
extern NSString *const A3CurrencyUserDefaultsFavorites;

#pragma mark ------ Lunar Converter
extern NSString *const A3LunarConverterLastInputDateComponents;
extern NSString *const A3LunarConverterLastInputDateIsLunar;
extern NSString *const A3LunarConverterUserDefaultsUpdateDate;
extern NSString *const A3LunarConverterUserDefaultsCloudUpdateDate;

#pragma mark ------ Battery
extern NSString *const A3BatteryChosenThemeIndex;
extern NSString *const A3BatteryChosenTheme;
extern NSString *const A3BatteryAdjustedIndex;
extern NSString *const A3BatteryShowIndex;

#pragma mark ------ Calculator
extern NSString *const A3CalculatorUserDefaultsUpdateDate;
extern NSString *const A3CalculatorUserDefaultsCloudUpdateDate;
extern NSString *const A3CalculatorUserDefaultsSavedLastExpression;
extern NSString *const A3CalculatorUserDefaultsRadianDegreeState;
extern NSString *const A3CalculatorUserDefaultsCalculatorMode;

#pragma mark ------ Clock
extern NSString *const A3ClockTheTimeWithSeconds;
extern NSString *const A3ClockFlashTheTimeSeparators;
extern NSString *const A3ClockUse24hourClock;
extern NSString *const A3ClockShowAMPM;
extern NSString *const A3ClockShowTheDayOfTheWeek;
extern NSString *const A3ClockShowDate;
extern NSString *const A3ClockShowWeather;
extern NSString *const A3ClockUsesFahrenheit;
extern NSString *const A3ClockWaveClockColor;
extern NSString *const A3ClockWaveClockColorIndex;
extern NSString *const A3ClockWaveCircleLayout;
extern NSString *const A3ClockFlipDarkColor;
extern NSString *const A3ClockFlipDarkColorIndex;
extern NSString *const A3ClockFlipLightColor;
extern NSString *const A3ClockFlipLightColorIndex;
extern NSString *const A3ClockLEDColor;
extern NSString *const A3ClockLEDColorIndex;
extern NSString *const A3ClockUserDefaultsCurrentPage;

#pragma mark ------ Date Calculator
extern NSString *const A3DateCalcDefaultsUpdateDate;
extern NSString *const A3DateCalcDefaultsCloudUpdateDate;
extern NSString *const A3DateCalcDefaultsIsAddSubMode;
extern NSString *const A3DateCalcDefaultsFromDate;
extern NSString *const A3DateCalcDefaultsToDate;
extern NSString *const A3DateCalcDefaultsOffsetDate;
extern NSString *const A3DateCalcDefaultsDidSelectMinus;
extern NSString *const A3DateCalcDefaultsSavedYear;
extern NSString *const A3DateCalcDefaultsSavedMonth;
extern NSString *const A3DateCalcDefaultsSavedDay;
extern NSString *const A3DateCalcDefaultsDurationType;
extern NSString *const A3DateCalcDefaultsExcludeOptions;

#pragma mark ------ DaysCounter
extern NSString *const A3DaysCounterUserDefaultsSlideShowOptions;
extern NSString *const A3DaysCounterUserDefaultsUpdateDate;
extern NSString *const A3DaysCounterUserDefaultsCloudUpdateDate;
extern NSString *const A3DaysCounterLastOpenedMainIndex;
extern NSString *const A3DaysCounterUserDefaultsCalendars;

#pragma mark ------ LadyCalendar
extern NSString *const A3LadyCalendarCurrentAccountID;
extern NSString *const A3LadyCalendarUserDefaultsSettings;
extern NSString *const A3LadyCalendarLastViewMonth;
extern NSString *const A3LadyCalendarUserDefaultsUpdateDate;
extern NSString *const A3LadyCalendarUserDefaultsCloudUpdateDate;
extern NSString *const A3LadyCalendarUserDefaultsAccounts;

#pragma mark ------ Percent Calculator
extern NSString *const A3PercentCalcUserDefaultsCalculationType;
extern NSString *const A3PercentCalcUserDefaultsSavedInputData;
extern NSString *const A3PercentCalcUserDefaultsUpdateDate;
extern NSString *const A3PercentCalcUserDefaultsCloudUpdateDate;

#pragma mark ------ Sales Calculator
extern NSString *const A3SalesCalcUserDefaultsSavedInputDataKey;
extern NSString *const A3SalesCalcUserDefaultsCurrencyCode;
extern NSString *const A3SalesCalcUserDefaultsUpdateDate;
extern NSString *const A3SalesCalcUserDefaultsCloudUpdateDate;

#pragma mark ------ Tip Calculator
extern NSString *const A3TipCalcUserDefaultsCurrencyCode;
extern NSString *const A3TipCalcUserDefaultsUpdateDate;
extern NSString *const A3TipCalcUserDefaultsCloudUpdateDate;

#pragma mark ------ Unit Converter
extern NSString *const A3UnitConverterDefaultSelectedCategoryID;
extern NSString *const A3UnitConverterTableViewUnitValueKey;
extern NSString *const A3UnitConverterUserDefaultsUpdateDate;
extern NSString *const A3UnitConverterUserDefaultsCloudUpdateDate;
extern NSString *const A3UnitConverterUserDefaultsUnitCategories;
extern NSString *const A3UnitConverterUserDefaultsConvertItems;
extern NSString *const A3UnitConverterUserDefaultsFavorites;

#pragma mark ------ Unit Price
extern NSString *const A3UnitPriceUserDefaultsCurrencyCode;
extern NSString *const A3UnitPriceUserDefaultsUpdateDate;
extern NSString *const A3UnitPriceUserDefaultsCloudUpdateDate;
extern NSString *const A3UnitPriceUserDefaultsUnitFavorites;

#pragma mark ------ Passcode
extern NSString *const kUserDefaultTimerStart;
extern NSString *const kUserDefaultsKeyForPasscodeTimerDuration;
extern NSString *const kUserDefaultsKeyForUseSimplePasscode;
extern NSString *const kUserDefaultsKeyForAskPasscodeForStarting;
extern NSString *const kUserDefaultsKeyForAskPasscodeForSettings;
extern NSString *const kUserDefaultsKeyForAskPasscodeForDaysCounter;
extern NSString *const kUserDefaultsKeyForAskPasscodeForLadyCalendar;
extern NSString *const kUserDefaultsKeyForAskPasscodeForWallet;

extern NSString *const A3WalletUserDefaultsSelectedTab;
extern NSString *const A3WalletUserDefaultsCategoryInfo;
extern NSString *const A3WalletUserDefaultsUpdateDate;
extern NSString *const A3WalletUserDefaultsCloudUpdateDate;

extern NSString *const kHolidayCountriesForCurrentDevice;
extern NSString *const kHolidayCountryExcludedHolidays;
extern NSString *const kHolidayCountriesShowLunarDates; // Holds array of country codes

#endif
