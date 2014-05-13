//
//  A3DaysCounterModelManager.h
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSVenue.h"
#import "MagicalRecord.h"

@class DaysCounterCalendar;
@class DaysCounterEvent;
@class DaysCounterEventLocation;
@class DaysCounterDateModel;
@interface A3DaysCounterModelManager : NSObject{
//    NSManagedObjectContext *managedContext;
}

//+ (A3DaysCounterModelManager*)sharedManager;
+ (UIImage*)circularScaleNCrop:(UIImage*)image rect:(CGRect)rect;
+ (UIImage*)strokCircleImageSize:(CGSize)size color:(UIColor*)color;
+ (UIImage*)resizeImage:(UIImage*)image toSize:(CGSize)toSize isFill:(BOOL)isFill backgroundColor:(UIColor*)color;
+ (NSString *)imagePath;
+ (NSString *)thumbnailPath;
+ (UIImage*)photoImageFromFilename:(NSString*)imageFilename;
+ (UIImage*)photoThumbnailFromFilename:(NSString*)imageFilename;
+ (NSString*)thumbnailFilenameFromFilename:(NSString*)imageFilename;

//- (NSManagedObjectContext*)managedObjectContext;
- (void)prepare;
- (NSString*)repeatTypeStringFromValue:(NSInteger)repeatType;
- (NSString*)repeatTypeStringForDetailValue:(NSInteger)repeatType;
- (NSString*)repeatEndDateStringFromDate:(id)date;
- (NSString*)alertDateStringFromDate:(NSDate*)startDate alertDate:(id)date;
- (NSInteger)alertTypeIndexFromDate:(NSDate*)date alertDate:(id)alertDate;
- (NSString*)alertStringForType:(NSInteger)alertType;
- (NSString*)durationOptionStringFromValue:(NSInteger)value;
- (NSString*)titleForCellType:(NSInteger)cellType;
- (NSString*)addressFromVenue:(FSVenue*)venue isDetail:(BOOL)isDetail;
- (NSString*)addressFromPlacemark:(CLPlacemark*)placemark;
- (FSVenue*)fsvenueFromEventModel:(DaysCounterEventLocation *)locationItem;
- (FSVenue*)fsvenueFromEventLocationModel:(id)location;

- (id)eventItemByID:(NSString*)eventId;
- (BOOL)addEvent:(DaysCounterEvent *)eventModel image:(UIImage *)image;
- (BOOL)modifyEvent:(DaysCounterEvent*)eventItem image:(UIImage *)image;
- (BOOL)removeEvent:(DaysCounterEvent*)eventItem;

- (NSMutableDictionary *)dictionaryFromCalendarEntity:(DaysCounterCalendar*)item;
- (NSMutableArray*)visibleCalendarList;
- (NSMutableArray*)allCalendarList;
- (NSMutableArray*)allUserCalendarList;
- (NSMutableDictionary *)itemForNewUserCalendar;
- (id)calendarItemByID:(NSString*)calendarId;
- (BOOL)removeCalendarItem:(NSMutableDictionary*)item;
- (BOOL)removeCalendarItemWithID:(NSString*)calendarID;
- (DaysCounterCalendar *)addCalendarItem:(NSDictionary*)item colorID:(NSString *)colorID;
- (BOOL)updateCalendarItem:(NSMutableDictionary*)item colorID:(NSString *)colorID;
- (NSInteger)numberOfAllEvents;
- (NSInteger)numberOfUpcomingEventsWithDate:(NSDate*)date;
- (NSInteger)numberOfPastEventsWithDate:(NSDate*)date;
- (NSInteger)numberOfUserCalendarVisible;
- (NSInteger)numberOfEventContainedImage;
- (NSDate*)dateOfLatestEvent;
- (DaysCounterCalendar*)defaultCalendar;

- (NSArray*)calendarColorList;
- (NSArray*)allEventsList;
- (NSArray*)allEventsListContainedImage;
- (NSArray*)upcomingEventsListWithDate:(NSDate*)date;
- (NSArray*)pastEventsListWithDate:(NSDate*)date;
- (NSArray*)favoriteEventsList;
- (NSArray*)reminderList;

+ (NSDate*)nextDateWithRepeatOption:(NSInteger)repeatType firstDate:(NSDate*)firstDate fromDate:(NSDate*)fromDate isAllDay:(BOOL)isAllDay;
+ (NSDate*)repeatDateOfCurrentNotNextWithRepeatOption:(NSInteger)repeatType firstDate:(NSDate*)firstDate fromDate:(NSDate*)fromDate; // 반복 시작이 당해 혹은 현재 시점 날짜 출력을 위하여 추가.
+ (NSString*)stringOfDurationOption:(NSInteger)option fromDate:(NSDate*)fromDate toDate:(NSDate*)toDate isAllDay:(BOOL)isAllDay isShortStyle:(BOOL)isShortStyle;


- (NSString*)stringForSlideshowTransitionType:(NSInteger)type;
- (void)setupEventSummaryInfo:(DaysCounterEvent*)item toView:(UIView*)toView;
- (NSString*)stringForShareEvent:(DaysCounterEvent*)event;

- (BOOL)isSupportLunar;

- (NSString*)dateFormatForAddEditIsAllDays:(BOOL)isAllDays;
+ (NSString*)dateFormatForDetailIsAllDays:(BOOL)isAllDays;
- (NSString*)dateFormatForPhotoWithIsAllDays:(BOOL)isAllDays;

#pragma mark - Specific Condition Validation
+ (BOOL)hasHourMinDurationOption:(NSInteger)durationOption;

#pragma mark - Period
- (DaysCounterEvent *)closestEventObjectOfCalendar:(DaysCounterCalendar *)calendar;
- (void)renewEffectiveStartDates:(DaysCounterCalendar *)calendar;
- (void)renewAllEffectiveStartDates;
+ (NSDate *)effectiveDateForEvent:(DaysCounterEvent *)event basisTime:(NSDate *)now;
#pragma mark EventModel Dictionary
- (void)recalculateEventDatesForEvent:(DaysCounterEvent *)event;

#pragma mark - EventTime Management (AlertTime, EffectiveStartDate)
+ (NSDate *)effectiveAlertDateForEvent:(DaysCounterEvent *)event;
+ (void)reloadAlertDateListForLocalNotification;

#pragma mark - Lunar
+ (NSDateComponents *)nextSolarDateComponentsFromLunarDateComponents:(NSDateComponents *)lunarComponents leapMonth:(BOOL)isLeapMonth fromDate:(NSDate *)fromDate;
+ (NSDate *)nextSolarDateFromLunarDateComponents:(NSDateComponents *)lunarComponents leapMonth:(BOOL)isLeapMonth fromDate:(NSDate *)fromDate;
+ (NSDateComponents *)dateComponentsOfRepeatForLunarDateComponent:(NSDateComponents *)lunarComponents aboutNextTime:(BOOL)isAboutNextTime leapMonth:(BOOL)isLeapMonth fromDate:(NSDate *)fromDate repeatType:(NSInteger)repeatType;

#pragma mark - Manipulate DaysCounterDateModel Object
+ (void)setDateModelObjectForDateComponents:(NSDateComponents *)dateComponents withEventModel:(DaysCounterEvent *)eventModel endDate:(BOOL)isEndDate;
+ (NSDateComponents *)dateComponentsFromDateModelObject:(DaysCounterDateModel *)dateObject toLunar:(BOOL)isLunar;

#pragma mark - Print Date String From DaysCounterDateModel Or SolarDate(Effective Date)
+ (NSString *)dateStringFromDateModel:(DaysCounterDateModel *)dateModel isLunar:(BOOL)isLunar isAllDay:(BOOL)isAllDay isLeapMonth:(BOOL)isLeapMonth;
+ (NSString *)dateStringFromEffectiveDate:(NSDate *)date isLunar:(BOOL)isLunar isAllDay:(BOOL)isAllDay isLeapMonth:(BOOL)isLeapMonth;
+ (NSString *)dateStringOfLunarFromDateModel:(DaysCounterDateModel *)dateModel isLeapMonth:(BOOL)isLeapMonth;
@end
