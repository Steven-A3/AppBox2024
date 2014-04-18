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
@interface A3DaysCounterModelManager : NSObject{
    NSManagedObjectContext *managedContext;
}

+ (A3DaysCounterModelManager*)sharedManager;
+ (UIImage*)circularScaleNCrop:(UIImage*)image rect:(CGRect)rect;
+ (UIImage*)strokCircleImageSize:(CGSize)size color:(UIColor*)color;
+ (UIImage*)resizeImage:(UIImage*)image toSize:(CGSize)toSize isFill:(BOOL)isFill backgroundColor:(UIColor*)color;
+ (NSString *)imagePath;
+ (NSString *)thumbnailPath;
+ (UIImage*)photoImageFromFilename:(NSString*)imageFilename;
+ (UIImage*)photoThumbnailFromFilename:(NSString*)imageFilename;
+ (NSString*)thumbnailFilenameFromFilename:(NSString*)imageFilename;

- (NSManagedObjectContext*)managedObjectContext;
- (void)prepare;
- (NSString*)repeatTypeStringFromValue:(NSInteger)repeatType;
- (NSString*)repeatTypeStringForDetailValue:(NSInteger)repeatType;
- (NSString*)repeatEndDateStringFromDate:(id)date;
- (NSString*)alertDateStringFromDate:(NSDate*)startDate alertDate:(id)date;
- (NSInteger)alertTypeIndexFromDate:(NSDate*)date alertDate:(id)alertDate;
- (NSString*)alertStringForType:(NSInteger)alertType;
- (NSString*)durationOptionStringFromValue:(NSInteger)value;
- (NSString*)titleForCellType:(NSInteger)cellType;
- (NSString*)addressFromVenue:(FSVenue*)venue isDetail:(BOOL)isDetail;\
- (NSString*)addressFromPlacemark:(CLPlacemark*)placemark;
- (FSVenue*)fsvenueFromEventModel:(id)locationItem;
- (FSVenue*)fsvenueFromEventLocationModel:(id)location;

- (id)emptyEventModel;
- (id)emptyEventLocationModel;
- (id)eventItemByID:(NSString*)eventId;
- (BOOL)addEvent:(id)eventModel;
- (BOOL)modifyEvent:(DaysCounterEvent*)eventItem withInfo:(NSDictionary*)info;
- (BOOL)removeEvent:(DaysCounterEvent*)eventItem;
- (NSMutableDictionary *)dictionaryFromEventEntity:(DaysCounterEvent*)item;
- (NSMutableDictionary *)dictionaryFromEventLocationEntity:(DaysCounterEventLocation*)location;

- (NSMutableDictionary *)dictionaryFromCalendarEntity:(DaysCounterCalendar*)item;
- (NSMutableArray*)visibleCalendarList;
- (NSMutableArray*)allCalendarList;
- (NSMutableArray*)allUserCalendarList;
- (NSMutableDictionary *)itemForNewUserCalendar;
- (id)calendarItemByID:(NSString*)calendarId;
- (BOOL)removeCalendarItem:(NSMutableDictionary*)item;
- (BOOL)removeCalendarItemWithID:(NSString*)calendarID;
- (BOOL)addCalendarItem:(NSDictionary*)item;
- (BOOL)updateCalendarItem:(NSMutableDictionary*)item;
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

- (NSDate*)nextDateWithRepeatOption:(NSInteger)repeatType firstDate:(NSDate*)firstDate fromDate:(NSDate*)fromDate;
- (NSDate*)repeatDateOfCurrentYearWithRepeatOption:(NSInteger)repeatType firstDate:(NSDate*)firstDate fromDate:(NSDate*)fromDate;
- (NSString*)stringOfDurationOption:(NSInteger)option fromDate:(NSDate*)fromDate toDate:(NSDate*)toDate isAllDay:(BOOL)isAllDay isShortStyle:(BOOL)isShortStyle;

- (NSString*)stringForSlideshowTransitionType:(NSInteger)type;
- (void)setupEventSummaryInfo:(DaysCounterEvent*)item toView:(UIView*)toView;
- (NSString*)stringForShareEvent:(DaysCounterEvent*)event;

- (BOOL)isSupportLunar;

- (NSString*)dateFormatForAddEditIsAllDays:(BOOL)isAllDays;
- (NSString*)dateFormatForDetailIsAllDays:(BOOL)isAllDays;

#pragma mark - Period
- (DaysCounterEvent *)closestEventObjectOfCalendar:(DaysCounterCalendar *)calendar;
- (void)renewEffectiveStartDates:(DaysCounterCalendar *)calendar;
- (void)renewAllEffectiveStartDates;
- (NSDate *)effectiveDateForEvent:(DaysCounterEvent *)event basisTime:(NSDate *)now;
#pragma mark EventModel Dictionary
- (NSDate *)effectiveDateForEventModel:(NSMutableDictionary *)event basisTime:(NSDate *)now;
- (void)reloadDatesOfEventModel:(NSMutableDictionary *)event;

#pragma mark - Alert
- (NSDate *)effectiveAlertDateForEvent:(DaysCounterEvent *)event;
- (void)reloadAlertDateListForLocalNotification;
@end
