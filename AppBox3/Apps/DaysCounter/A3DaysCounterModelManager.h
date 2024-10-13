//
//  A3DaysCounterModelManager.h
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSVenue.h"

@class DaysCounterEvent_;
@class DaysCounterEventLocation_;
@class DaysCounterDate_;
@class DaysCounterCalendar_;

@interface A3DaysCounterModelManager : NSObject

+ (UIImage*)strokeCircleImageSize:(CGSize)size color:(UIColor*)color;
+ (NSString *)thumbnailDirectory;

+ (NSMutableArray *)calendars;

- (void)prepareToUse;
- (NSString*)repeatTypeStringFromValue:(NSInteger)repeatType;
- (NSString*)repeatTypeStringForDetailValue:(NSInteger)repeatType;

- (NSString*)alertDateStringFromDate:(NSDate*)startDate alertDate:(id)date;
- (NSInteger)alertTypeIndexFromDate:(NSDate*)date alertDate:(id)alertDate;
- (NSString*)alertStringForType:(NSInteger)alertType;
- (NSString*)durationOptionStringFromValue:(NSInteger)value;

- (NSString*)addressFromVenue:(FSVenue*)venue isDetail:(BOOL)isDetail;
- (NSString*)addressFromPlacemark:(CLPlacemark*)placemark;
- (FSVenue*)fsvenueFromEventModel:(DaysCounterEventLocation_ *)locationItem;
- (FSVenue*)fsvenueFromEventLocationModel:(id)location;

- (BOOL)addEvent:(DaysCounterEvent_ *)eventModel;

- (BOOL)modifyEvent:(DaysCounterEvent_ *)eventItem;

- (BOOL)removeEvent:(DaysCounterEvent_ *)eventItem;

- (NSArray *)visibleCalendarList;
- (NSArray *)allUserVisibleCalendarList;
- (NSArray *)allUserCalendarList;

- (id)calendarItemByID:(NSString *)calendarID;

- (BOOL)removeCalendar:(DaysCounterCalendar_ *)calendar;

- (NSInteger)numberOfAllEvents;
- (NSInteger)numberOfAllEventsToIncludeHiddenCalendar;
- (NSInteger)numberOfUpcomingEventsWithDate:(NSDate*)date withHiddenCalendar:(BOOL)hiddenCalendar;
- (NSInteger)numberOfPastEventsWithDate:(NSDate*)date withHiddenCalendar:(BOOL)hiddenCalendar;
- (NSInteger)numberOfUserCalendarVisible;
- (NSInteger)numberOfEventContainedImage;
- (NSDate*)dateOfLatestEvent;

- (UIColor *)colorForCalendar:(DaysCounterCalendar_ *)calendar;

- (NSArray *)calendarColorArray;

- (NSArray*)allEventsList;
- (NSArray*)allEventsListContainedImage;
- (NSArray*)upcomingEventsListWithDate:(NSDate*)date;
- (NSArray*)pastEventsListWithDate:(NSDate*)date;
- (NSArray*)favoriteEventsList;
- (NSArray*)reminderList;

+ (NSDate*)nextDateWithRepeatOption:(NSInteger)repeatType firstDate:(NSDate*)firstDate fromDate:(NSDate*)fromDate isAllDay:(BOOL)isAllDay;
+ (NSDate*)repeatDateOfCurrentNotNextWithRepeatOption:(NSInteger)repeatType firstDate:(NSDate*)firstDate fromDate:(NSDate*)fromDate; // 반복 시작이 당해 혹은 현재 시점 날짜 출력을 위하여 추가.
+ (NSString*)stringOfDurationOption:(NSInteger)option fromDate:(NSDate*)fromDate toDate:(NSDate*)toDate isAllDay:(BOOL)isAllDay isShortStyle:(BOOL)isShortStyle isStrictShortType:(BOOL)isStrictShortType;

- (NSString*)stringForSlideshowTransitionType:(NSInteger)type;
- (void)setupEventSummaryInfo:(DaysCounterEvent_ *)item toView:(UIView*)toView;

+ (NSString*)dateFormatForDetailIsAllDays:(BOOL)isAllDays;
- (NSString*)dateFormatForPhotoWithIsAllDays:(BOOL)isAllDays;

#pragma mark - Specific Condition Validation
+ (BOOL)hasHourMinDurationOption:(NSInteger)durationOption;

#pragma mark - Period
- (DaysCounterEvent_ *)closestEventObjectOfCalendar:(DaysCounterCalendar_ *)calendar;
+ (NSDate *)effectiveDateForEvent:(DaysCounterEvent_ *)event basisTime:(NSDate *)now;
#pragma mark EventModel Dictionary
- (void)recalculateEventDatesForEvent:(DaysCounterEvent_ *)event;

#pragma mark - EventTime Management (AlertTime, EffectiveStartDate)
- (NSString *)localizedSystemCalendarNameForCalendarID:(NSString *)calendarID;
+ (NSDate *)effectiveAlertDateForEvent:(DaysCounterEvent_ *)event;
+ (void)reloadAlertDateListForLocalNotification;

#pragma mark - Lunar
+ (NSDateComponents *)nextSolarDateComponentsFromLunarDateComponents:(NSDateComponents *)lunarComponents leapMonth:(BOOL)isLeapMonth fromDate:(NSDate *)fromDate;
+ (NSDate *)nextSolarDateFromLunarDateComponents:(NSDateComponents *)lunarComponents leapMonth:(BOOL)isLeapMonth fromDate:(NSDate *)fromDate;

#pragma mark - Manipulate DaysCounterDateModel Object
+ (void)setDateModelObjectForDateComponents:(NSDateComponents *)dateComponents withEventModel:(DaysCounterEvent_ *)eventModel endDate:(BOOL)isEndDate;
+ (NSDateComponents *)dateComponentsFromDateModelObject:(DaysCounterDate_ *)dateObject toLunar:(BOOL)isLunar;

#pragma mark - Print Date String From DaysCounterDateModel Or SolarDate(Effective Date)
+ (NSString *)dateStringFromDateModel:(DaysCounterDate_ *)dateModel isLunar:(BOOL)isLunar isAllDay:(BOOL)isAllDay;
+ (NSString *)dateStringFromEffectiveDate:(NSDate *)date isLunar:(BOOL)isLunar isAllDay:(BOOL)isAllDay isLeapMonth:(BOOL)isLeapMonth;
+ (NSString *)dateStringOfLunarFromDateModel:(DaysCounterDate_ *)dateModel isLeapMonth:(BOOL)isLeapMonth;
@end
