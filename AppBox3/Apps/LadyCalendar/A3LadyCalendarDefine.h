//
//  A3LadyCalendarDefine.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#ifndef A3TeamWork_A3LadyCalendarDefine_h
#define A3TeamWork_A3LadyCalendarDefine_h

#define ItemKey_Items                       @"items"
#define ItemKey_Title                       @"title"
#define ItemKey_Type                        @"type"
#define ItemKey_Index						@"index"
#define ItemKey_RowHeight					@"rowHeight"
#define ItemKey_Description                 @"description"

#define PeriodItem_ID                       @"periodID"
#define PeriodItem_StartDate                @"startDate"
#define PeriodItem_EndDate                  @"endDate"
#define PeriodItem_CycleLength              @"cycleLength"
#define PeriodItem_Ovulation                @"ovulation"
#define PeriodItem_Notes                    @"periodNotes"
#define PeriodItem_RegDate                  @"regDate"
#define PeriodItem_AccountID                @"accountID"
#define PeriodItem_Account                  @"account"
#define PeriodItem_IsPerdict                @"isPredict"
#define PeriodItem_CalendarID               @"calendarID"
#define PeriodItem_IsAutoSave               @"isAutoSave"

#define AccountItem_ID                      @"accountID"
#define AccountItem_Name                    @"accountName"
#define AccountItem_Birthday                @"birthDay"
#define AccountItem_Notes                   @"accountNotes"
#define AccountItem_Order                   @"order"
#define AccountItem_RegDate                 @"regDate"

#define SettingItem_ForeCastingPeriods      @"forecastingPeriods"
#define SettingItem_CalculateCycle          @"calculateCycle"
#define SettingItem_AutoRecord              @"autoRecord"
#define SettingItem_AlertType               @"alertType"
#define SettingItem_CustomAlertDays         @"customAlertDays"
#define SettingItem_CustomAlertTime         @"customAlertTime"

#define DefaultAccountID                    @"defaultAccount"
#define DefaultAccountName                  @"User01"

#define CalendarItem_Month                  @"monthDate"
#define CalendarItem_FirstDayPosition       @"firstDayPosition"
#define CalendarItem_LastDay                @"lastDay"
#define CalendarItem_Period                 @"period"
#define CalendarItem_IsPeriodStart          @"isPeriodStart"
#define CalendarItem_IsPeriodEnd            @"isPeriodEnd"

typedef NS_ENUM(NSInteger, A3LadyCalendarSettingAlertType) {
    AlertType_Custom = -5,
    AlertType_OneWeekBefore = -4,
    AlertType_TwoDaysBefore = -3,
    AlertType_OneDayBefore = -2,
    AlertType_OnDay = -1,
    AlertType_None = 0,
};

typedef NS_ENUM(NSInteger, A3LadyCalendarAccountCellType) {
    AccountCell_Name = 0,
    AccountCell_Birthday,
    AccountCell_Notes,
    AccountCell_DateInput,
};

typedef NS_ENUM(NSInteger, A3LadyCalendarSettingCellType) {
    SettingCell_Periods = 0,
    SettingCell_CycleLength,
    SettingCell_AutoRecord,
    SettingCell_Alert,
};

typedef NS_ENUM(NSInteger, A3LadyCalendarSettingCycleLengthType) {
    CycleLength_SameBeforeCycle = 0,
    CycleLength_AverageBeforeTwoCycle,
    CycleLength_AverageAllCycle,
};

typedef NS_ENUM(NSInteger, A3LadyCalendarPeriodCellType) {
    PeriodCellType_StartDate = 0,
    PeriodCellType_EndDate,
    PeriodCellType_CycleLength,
    PeriodCellType_Ovulation,
    PeriodCellType_Notes,
    PeriodCellType_DateInput,
    PeriodCellType_Delete,
};

typedef NS_ENUM(NSInteger, A3LadyCalendarDetailCellType) {
    DetailCellType_Title = 0,
    DetailCellType_StartDate,
    DetailCellType_EndDate,
    DetailCellType_CycleLength,
    DetailCellType_Notes,
    DetailCellType_Pregnancy,
    DetailCellType_Ovulation,
    DetailCellType_MenstrualPeriod,
    DetailCellType_DescTitle,
	DetailCellType_Blank,
};

typedef NS_ENUM(NSInteger, A3ladyCalendarCustomAlertCellType) {
    CustomAlertCell_DaysBefore,
    CustomAlertCell_Time,
    CustomAlertCell_TimeInput,
};

#endif
