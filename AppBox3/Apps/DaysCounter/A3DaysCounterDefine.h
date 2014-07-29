//
//  A3DaysCounterDefine.h
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#ifndef A3TeamWork_A3DaysCounterDefine_h
#define A3TeamWork_A3DaysCounterDefine_h

#define FOURSQUARE_CLIENTID     @"S41X1SN5JUC0LEOG5PIAQODH3YIQHQQOK5S1XE5TOMON2AXT"
#define FOURSQUARE_CLIENTSECRET @"KQWO4HZHJLETEZNCLZULIEC3S2VIV3PFPZ0RJ4YMYDZOAHBU"
#define FOURSQUARE_REDIRECTURI  @"appbox://foursquare"

#define OptionKey_Transition                    @"transition"
#define OptionKey_Showtime                      @"showtime"
#define OptionKey_Repeat                        @"repeat"
#define OptionKey_Shuffle                       @"shuffle"

#define AddEventSectionName                     @"sectionName"
#define AddEventItems                           @"items"
#define EventRowTitle                           @"rowTitle"
#define EventRowType                            @"rowType"

#define EventKey_Date                           @"date"
#define EventKey_Items                          @"items"

#define CalendarItem_ID                         @"uniqueID"
#define CalendarItem_Name                       @"calendarName"
#define CalendarItem_Color                      @"calendarColor"
#define CalendarItem_ColorID                    @"calendarColorID"
#define CalendarItem_IsShow                     @"isShow"
#define CalendarItem_Type                       @"calendarType"
#define CalendarItem_IsDefault                  @"isDefault"

#define SystemCalendarID_All                    @"A"
#define SystemCalendarID_Upcoming               @"U"
#define SystemCalendarID_Past                   @"P"

#define EventItem_StartDate                     @"startDate"
#define EventItem_EndDate                       @"endDate"

#define AlertMessage_NoPhoto                    @"No Photos\nYou can add photos into events."


typedef NS_ENUM(NSInteger, A3DaysCounterDurationOption) {
    DurationOption_Seconds  = 0x00000001,
    DurationOption_Minutes  = 0x00000001 << 1,
    DurationOption_Hour     = 0x00000001 << 2,
    DurationOption_Day      = 0x00000001 << 3,
    DurationOption_Week     = 0x00000001 << 4,
    DurationOption_Month    = 0x00000001 << 5,
    DurationOption_Year     = 0x00000001 << 6,
};

typedef NS_ENUM(NSInteger, A3DaysCounterRepeatType) {
    RepeatType_EveryYear = -5,
    RepeatType_EveryMonth = -4,
    RepeatType_Every2Week = -3,
    RepeatType_EveryWeek = -2,
    RepeatType_EveryDay = -1,
    RepeatType_Never = 0,
};

typedef NS_ENUM(NSInteger, A3DaysCounterAddSection) {
    AddSection_Section_0 = 0,
    AddSection_Section_1,
    AddSection_Section_2,
    AddSection_Section_3,

};

//enum A3DaysCounterAddEventCellType{
typedef NS_ENUM(NSInteger, A3DaysCounterAddEventCellType) {
    EventCellType_Title = 0,
    EventCellType_Photo,
    EventCellType_IsLunar,
    EventCellType_IsAllDay,
    EventCellType_IsPeriod,
    
    EventCellType_StartDate,    // 5
    EventCellType_EndDate,
    EventCellType_RepeatType,
    EventCellType_EndRepeatDate,
    EventCellType_Alert,
    
    EventCellType_Calendar,     // 10
    EventCellType_DurationOption,
    EventCellType_Location,
    EventCellType_Notes,
    EventCellType_DateInput,
    
    EventCellType_Share,        // 15
    EventCellType_Favorites,
    EventCellType_Advanced,
    EventCellType_IsLeapMonth
};

typedef NS_ENUM(NSInteger, A3DaysCounterCalendarCellType) {
    CalendarCellType_User = 0,
    CalendarCellType_System
};

typedef NS_ENUM(NSInteger, A3DaysCounterAlertType) {
    AlertType_None = 0,
    AlertType_AtTimeOfEvent,
    AlertType_5MinutesBefore,
    AlertType_15MinutesBefore,
    AlertType_30MinutesBefore,
    AlertType_1HourBefore,
    AlertType_2HoursBefore,
    AlertType_1DayBefore,
    AlertType_2DaysBefore,
    AlertType_1WeekBefore,
    AlertType_Custom,
};

typedef NS_ENUM(NSInteger, A3DaysCounterCustomAlertCellType) {
    CustomAlertCell_DaysBefore,
    CustomAlertCell_Time,
    CustomAlertCell_TimeInput,
};

typedef NS_ENUM(NSInteger, A3DaysCounterEventListSortType) {
    EventSortType_Date = 0,
    EventSortType_Name ,
};

typedef NS_ENUM(NSInteger, A3DaysCounterSlideshowOptionType) {
    SlideshowOptionType_Transition,
    SlideshowOptionType_Showtime,
    SlideshowOptionType_Repeat,
    SlideshowOptionType_Shuffle,
    SlideshowOptionType_Startshow,
};

typedef NS_ENUM(NSInteger, A3DaysCounterSlideshowTransitionType) {
    TransitionType_Cube,
    TransitionType_Dissolve,
    TransitionType_Origami,
    TransitionType_Ripple,
    TransitionType_Wipe,
};

#endif
