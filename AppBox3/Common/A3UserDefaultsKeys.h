//
//  A3UserDefaults.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 1/22/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#ifndef AppBox3_A3UserDefaults_h
#define AppBox3_A3UserDefaults_h

// A3KeyValueDB Key는 DaysCounter Calendar data, Wallet Category, Unit Data 저장시 Dictionary Key로 사용
// A3KeyValueDBDataObject가 해당 데이터, 기타는 metadata로 iCloud 상황에서 Sync시 참고하기 위해 사용

typedef NS_ENUM(NSUInteger, A3DataObjectStateValue) {
	A3DataObjectStateInitialized = 0,			// 최초 작성시의 상태
	A3DataObjectStateModified                    // 이후 추가/수정/삭제가 발생한 상태
};

extern NSString *const ID_KEY;
extern NSString *const NAME_KEY;

extern NSString *const A3KeyValueDBDataObject;
extern NSString *const A3KeyValueDBState;
extern NSString *const A3KeyValueDBUpdateDate;

extern NSString *const A3SettingsUserDefaultsThemeColorIndex;
extern NSString *const A3SettingsUseKoreanCalendarForLunarConversion;

extern NSString *const kA3SettingsMainMenuStyle;
extern NSString *const A3SettingsMainMenuStyleTable;
extern NSString *const A3SettingsMainMenuStyleHexagon;
extern NSString *const A3SettingsMainMenuStyleIconGrid;

/**
 *  기기간 동기화가 필요없는 없으므로, NSUserDefaults에 저장한다.
 *  업데이트 설치 후 첫 실행 시 이전 버전이 4.0인 경우에만 아래 설정이 활성화 되어야 한다.
 *  이전 버전이 4.0 미만인 경우와 4.1 이후에는 해당 메뉴가 포함되어 있으므로 아래 설정이 필요가 없다.
 *  한번 추가가 된 이후에는 아래 설정이 OFF가 되어야 한다.
 */
extern NSString *const A3SettingsMainMenuHexagonShouldAddQRCodeMenu;
extern NSString *const A3SettingsMainMenuGridShouldAddQRCodeMenu;
extern NSString *const A3SettingsMainMenuHexagonShouldAddPedometerMenu;
extern NSString *const A3SettingsMainMenuGridShouldAddPedometerMenu;
extern NSString *const A3SettingsMainMenuHexagonShouldAddAbbreviationMenu;
extern NSString *const A3SettingsMainMenuGridShouldAddAbbreviationMenu;

#pragma mark ------ Main Menu
extern NSString *const A3MainMenuDataEntityFavorites;
extern NSString *const A3MainMenuDataEntityRecentlyUsed;
extern NSString *const A3MainMenuDataEntityAllMenu;
extern NSString *const A3MainMenuUserDefaultsMaxRecentlyUsed;

extern NSString *const A3MainMenuHexagonMenuItems;
extern NSString *const A3MainMenuGridMenuItems;

#pragma mark ------ Battery
extern NSString *const A3BatteryChosenThemeIndex;
extern NSString *const A3BatteryChosenTheme;
extern NSString *const A3BatteryAdjustedIndex;
extern NSString *const A3BatteryShowIndex;

#pragma mark ------ Calculator
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
extern NSString *const A3ClockUseAutoLock;
extern NSString *const A3ClockAutoDim;

#pragma mark ------ Currency Converter
extern NSString *const A3CurrencyUserDefaultsAutoUpdate;
extern NSString *const A3CurrencyUserDefaultsUseCellularData;
extern NSString *const A3CurrencyUserDefaultsShowNationalFlag;
extern NSString *const A3CurrencyUserDefaultsLastInputValue;

#pragma mark ------ Date Calculator
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
extern NSString *const A3DaysCounterLastOpenedMainIndex;

#pragma mark ------ Expense List
extern NSString *const A3ExpenseListUserDefaultsCurrencyCode;
extern NSString *const A3ExpenseListIsAddBudgetCanceledByUser;
extern NSString *const A3ExpenseListIsAddBudgetInitiatedOnce;

#pragma mark ------ Holidays
extern NSString *const kHolidayCountriesForCurrentDevice;
extern NSString *const kHolidayCountryExcludedHolidays;
extern NSString *const kHolidayCountriesShowLunarDates; // Holds array of country codes

#pragma mark ------ Loan Calc
extern NSString *const A3LoanCalcUserDefaultShowDownPayment;
extern NSString *const A3LoanCalcUserDefaultShowExtraPayment;
extern NSString *const A3LoanCalcUserDefaultShowAdvanced;
extern NSString *const A3LoanCalcUserDefaultsLoanDataKey;
extern NSString *const A3LoanCalcUserDefaultsLoanDataKey_A;
extern NSString *const A3LoanCalcUserDefaultsLoanDataKey_B;
extern NSString *const A3LoanCalcUserDefaultsCustomCurrencyCode;

#pragma mark ------ LadyCalendar
extern NSString *const A3LadyCalendarCurrentAccountID;
extern NSString *const A3LadyCalendarUserDefaultsSettings;
extern NSString *const A3LadyCalendarLastViewMonth;

#pragma mark ------ Lunar Converter
extern NSString *const A3LunarConverterLastInputDateComponents;
extern NSString *const A3LunarConverterLastInputDateIsLunar;

#pragma mark ------ Percent Calculator
extern NSString *const A3PercentCalcUserDefaultsCalculationType;
extern NSString *const A3PercentCalcUserDefaultsSavedInputData;

#pragma mark ------ Sales Calculator
extern NSString *const A3SalesCalcUserDefaultsSavedInputDataKey;
extern NSString *const A3SalesCalcUserDefaultsCurrencyCode;

#pragma mark ------ Tip Calculator
extern NSString *const A3TipCalcUserDefaultsCurrencyCode;

#pragma mark ------ Unit Converter
extern NSString *const A3UnitConverterDefaultSelectedCategoryID;
extern NSString *const A3UnitConverterTableViewUnitValueKey;
extern NSString *const A3UnitConverterDataEntityUnitCategories;
extern NSString *const A3UnitConverterDataEntityConvertItems;
extern NSString *const A3UnitConverterDataEntityFavorites;

#pragma mark ------ Unit Price
extern NSString *const A3UnitPriceUserDefaultsCurrencyCode;
extern NSString *const A3UnitPriceUserDataEntityPriceFavorites;

#pragma mark ------ Passcode
extern NSString *const kUserDefaultTimerStart;
extern NSString *const kUserDefaultsKeyForPasscodeTimerDuration;
extern NSString *const kUserDefaultsKeyForUseSimplePasscode;
extern NSString *const kUserDefaultsKeyForUseTouchID;
extern NSString *const kUserDefaultsKeyForAskPasscodeForStarting;
extern NSString *const kUserDefaultsKeyForAskPasscodeForSettings;
extern NSString *const kUserDefaultsKeyForAskPasscodeForDaysCounter;
extern NSString *const kUserDefaultsKeyForAskPasscodeForLadyCalendar;
extern NSString *const kUserDefaultsKeyForAskPasscodeForWallet;

#pragma mark ------ Wallet
extern NSString *const A3WalletUserDefaultsSelectedTab;

#endif
