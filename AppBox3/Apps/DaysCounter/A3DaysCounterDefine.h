//
//  A3DaysCounterDefine.h
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#ifndef A3TeamWork_A3DaysCounterDefine_h
#define A3TeamWork_A3DaysCounterDefine_h

#define FOURSQUARE_CLIENTID     @"B3K4HF0AMLNYXAI42X0CDP3E0B5DXNYKT1JIUNL4EQ1AP0W5"
#define FOURSQUARE_CLIENTSECRET @"IWACU25PDFAJZ1WKLKEDL4LJWI41MXV535CQE5YQOQT3NALA"
#define FOURSQUARE_REDIRECTURI  @"A3TeamWork://foursquare"

#define DaysCounterDefaultDateFormat            @"EEE, MMM d, yyyy"

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

#define CalendarItem_ID                         @"calendarId"
#define CalendarItem_Name                       @"calendarName"
#define CalendarItem_Color                      @"calendarColor"
#define CalendarItem_IsShow                     @"isShow"
#define CalendarItem_Type                       @"calendarType"
#define CalendarItem_IsDefault                  @"isDefault"
#define CalendarItem_NumberOfEvents             @"numberOfEvents"


#define SystemCalendarID_All                    @"A"
#define SystemCalendarID_Upcoming               @"U"
#define SystemCalendarID_Past                   @"P"

#define EventItem_ID                            @"eventId"
#define EventItem_Name                          @"eventName"
#define EventItem_ImageFilename                 @"imageFilename"
#define EventItem_Image                         @"image"
#define EventItem_Thumbnail                     @"thumbnail"
#define EventItem_IsLunar                       @"isLunar"
#define EventItem_IsAllDay                      @"isAllDay"
#define EventItem_IsPeriod                      @"isPeriod"
#define EventItem_StartDate                     @"startDate"
#define EventItem_EndDate                       @"endDate"
#define EventItem_RepeatType                    @"repeatType"
#define EventItem_RepeatEndDate                 @"repeatEndDate"
#define EventItem_AlertDatetime                 @"alertDatetime"
#define EventItem_DurationOption                @"durationOption"
#define EventItem_Notes                         @"notes"
#define EventItem_IsFavorite                    @"isFavorite"
#define EventItem_RegDate                       @"regDate"
#define EventItem_CalendarId                    @"calendarId"
#define EventItem_Calendar                      @"calendar"
#define EventItem_Location                      @"location"
#define EventItem_Latitude                      @"latitude"
#define EventItem_Longitude                     @"longitude"
#define EventItem_Address                       @"address"
#define EventItem_City                          @"city"
#define EventItem_State                         @"state"
#define EventItem_Country                       @"country"
#define EventItem_LocationName                  @"locationName"
#define EventItem_Contact                       @"contact"

#define AlertMessage_NoPhoto                    @"No Photos\nYou can add photos into events."


enum A3DaysCounterDurationOption{
    DurationOption_Seconds  = 0x00000001,
    DurationOption_Minutes  = 0x00000001 << 1,
    DurationOption_Hour     = 0x00000001 << 2,
    DurationOption_Day      = 0x00000001 << 3,
    DurationOption_Week     = 0x00000001 << 4,
    DurationOption_Month    = 0x00000001 << 5,
    DurationOption_Year     = 0x00000001 << 6,
};

enum A3DaysCounterRepeatType{
    RepeatType_EveryYear = -5,
    RepeatType_EveryMonth = -4,
    RepeatType_Every2Week = -3,
    RepeatType_EveryWeek = -2,
    RepeatType_EveryDay = -1,
    RepeatType_Never = 0,
};

enum A3DaysCounterAddSection {
    AddSection_DefaultInfo = 0,
    AddSection_DateInfo,
    AddSection_Advanced,
    AddSection_AdvancedSeperator,
};

enum A3DaysCounterAddEventCellType{
    EventCellType_Title = 0,
    EventCellType_Photo,
    EventCellType_IsLunar,
    EventCellType_IsAllDay,
    EventCellType_IsPeriod,
    EventCellType_StartDate,
    EventCellType_EndDate,
    EventCellType_RepeatType,
    EventCellType_EndRepeatDate,
    EventCellType_Alert,
    EventCellType_Calendar,
    EventCellType_DurationOption,
    EventCellType_Location,
    EventCellType_Notes,
    EventCellType_DateInput,
    EventCellType_Share,
    EventCellType_Favorites,
    EventCellType_Advanced,
};

typedef NS_ENUM(NSInteger, A3DaysCounterCalendarCellType) {
    CalendarCellType_User = 0,
    CalendarCellType_System
};

enum A3DaysCounterAlertType{
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

enum A3DaysCounterCustomAlertCellType{
    CustomAlertCell_DaysBefore,
    CustomAlertCell_Time,
    CustomAlertCell_TimeInput,
};


enum A3DaysCounterEventListSortType{
    EventSortType_Date = 0,
    EventSortType_Name ,
};

enum A3DaysCounterSlideshowOptionType{
    SlideshowOptionType_Transition,
    SlideshowOptionType_Showtime,
    SlideshowOptionType_Repeat,
    SlideshowOptionType_Shuffle,
    SlideshowOptionType_Startshow,
};

enum A3DaysCounterSlideshowTransitionType{
    TransitionType_Cube,
    TransitionType_Dissolve,
    TransitionType_Origami,
    TransitionType_Ripple,
    TransitionType_Wipe,
};

#endif
