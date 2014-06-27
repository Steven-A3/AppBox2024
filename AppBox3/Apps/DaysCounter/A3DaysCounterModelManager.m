//
//  A3DaysCounterModelManager.m
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <EventKit/EventKit.h>
#import "A3DaysCounterModelManager.h"
#import "A3DaysCounterDefine.h"
#import "A3Formatter.h"
#import "DaysCounterCalendar.h"
#import "DaysCounterEvent.h"
#import "DaysCounterEventLocation.h"
#import "DaysCounterReminder.h"
#import "DaysCounterDate.h"
#import "NYXImagesKit.h"
#import "A3DateHelper.h"
#import "A3UserDefaults.h"
#import "A3DaysCounterSlideshowEventSummaryView.h"
#import "NSDate+LunarConverter.h"
#import "NSDate+formatting.h"
#import "NSDateFormatter+LunarDate.h"
#import "NSDateFormatter+A3Addition.h"
#import "A3AppDelegate.h"
#import "DaysCounterFavorite.h"
#import "DaysCounterEvent+management.h"
#import "NSString+conversion.h"

extern NSString *const A3DaysCounterImageThumbnailDirectory;

@interface A3DaysCounterModelManager ()

@property (strong, nonatomic) NSMutableArray *calendarColorArray;

@end

@implementation A3DaysCounterModelManager

+ (UIImage*)strokeCircleImageSize:(CGSize)size color:(UIColor*)color
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width, size.height), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [color CGColor]);
    CGContextAddArc(context, size.width*0.5, size.height*0.5, size.width*0.5-0.5, 0.0, M_PI*2.0, YES);
    CGContextStrokePath(context);
    
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return retImage;
}

+ (NSString *)thumbnailDirectory
{
    NSString *cacheFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    return [cacheFolder stringByAppendingPathComponent:A3DaysCounterImageThumbnailDirectory];
}

- (NSMutableDictionary *)dictionaryFromCalendarEntity:(DaysCounterCalendar*)item
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:item.calendarColor];
    [dict setObject:item.calendarId forKey:CalendarItem_ID];
    [dict setObject:color forKey:CalendarItem_Color];
    [dict setObject:item.calendarColorID forKey:CalendarItem_ColorID];
    [dict setObject:item.calendarName forKey:CalendarItem_Name];
    [dict setObject:item.isShow forKey:CalendarItem_IsShow];
    [dict setObject:[NSNumber numberWithInteger:CalendarCellType_User] forKey:CalendarItem_Type];
    [dict setObject:[NSNumber numberWithInteger:[item.events count]] forKey:CalendarItem_NumberOfEvents];
    
    return dict;
}

- (void)checkAndAddSystemCalendarItemsInContext:(NSManagedObjectContext *)context {
    NSArray *array = @[
			[NSMutableDictionary dictionaryWithDictionary:
			@{
					CalendarItem_ID: SystemCalendarID_All,
					CalendarItem_Name : @"All",
					CalendarItem_Color : [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0],
					CalendarItem_IsShow : @YES,
					CalendarItem_Type : @(CalendarCellType_System),
					CalendarItem_IsDefault : @YES
			}],
			[NSMutableDictionary dictionaryWithDictionary:
					@{
							CalendarItem_ID: SystemCalendarID_Upcoming,
							CalendarItem_Name : @"Upcoming",
							CalendarItem_Color : [UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0],
							CalendarItem_IsShow : @YES,
							CalendarItem_Type : @(CalendarCellType_System),
							CalendarItem_IsDefault : @YES
					}],
			[NSMutableDictionary dictionaryWithDictionary:
					@{CalendarItem_ID: SystemCalendarID_Past,
							CalendarItem_Name : @"Past",
							CalendarItem_Color : [UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0],
							CalendarItem_IsShow : @YES,
							CalendarItem_Type : @(CalendarCellType_System),
							CalendarItem_IsDefault : @YES
					}]
	];
    
    for (NSDictionary *item in array) {
        [self addCalendarItem:item colorID:nil inContext:context ];
    }
    
	[context MR_saveToPersistentStoreAndWait];
}

- (void)addDefaultUserCalendarItemsInContext:(NSManagedObjectContext *)context {
    NSMutableArray *array = [NSMutableArray arrayWithArray:@[
                                                             [NSMutableDictionary dictionaryWithDictionary:@{ CalendarItem_ID:@"1", CalendarItem_Name : NSLocalizedString(@"Anniversary", @"Anniversary"),
                                                                                                              CalendarItem_Color : [self.calendarColorArray[0] objectForKey:CalendarItem_Color],
                                                                                                              CalendarItem_IsShow : [NSNumber numberWithBool:YES], CalendarItem_Type : [NSNumber numberWithInteger:CalendarCellType_User], CalendarItem_IsDefault : [NSNumber numberWithBool:YES]}],
                                                             [NSMutableDictionary dictionaryWithDictionary:@{CalendarItem_ID: @"2",CalendarItem_Name : NSLocalizedString(@"Appointment", @"Appointment"),
                                                                                                             CalendarItem_Color : [self.calendarColorArray[1] objectForKey:CalendarItem_Color],
                                                                                                             CalendarItem_IsShow : [NSNumber numberWithBool:YES],CalendarItem_Type : [NSNumber numberWithInteger:CalendarCellType_User],CalendarItem_IsDefault : [NSNumber numberWithBool:NO]}],
                                                             [NSMutableDictionary dictionaryWithDictionary:@{CalendarItem_ID: @"3",CalendarItem_Name : NSLocalizedString(@"Birthday", @"Birthday"),
                                                                                                             CalendarItem_Color : [self.calendarColorArray[2] objectForKey:CalendarItem_Color],
                                                                                                             CalendarItem_IsShow : [NSNumber numberWithBool:YES],CalendarItem_Type : [NSNumber numberWithInteger:CalendarCellType_User],CalendarItem_IsDefault : [NSNumber numberWithBool:NO]}],
                                                             [NSMutableDictionary dictionaryWithDictionary:@{CalendarItem_ID: @"4",CalendarItem_Name : NSLocalizedString(@"Journey", @"Journey"),
                                                                                                             CalendarItem_Color : [self.calendarColorArray[3] objectForKey:CalendarItem_Color],
                                                                                                             CalendarItem_IsShow : [NSNumber numberWithBool:YES],CalendarItem_Type : [NSNumber numberWithInteger:CalendarCellType_User],CalendarItem_IsDefault : [NSNumber numberWithBool:NO]}],
                                                             [NSMutableDictionary dictionaryWithDictionary:@{CalendarItem_ID: @"5",CalendarItem_Name : NSLocalizedString(@"Holiday", @"Holiday"),
                                                                                                             CalendarItem_Color : [self.calendarColorArray[4] objectForKey:CalendarItem_Color],
                                                                                                             CalendarItem_IsShow : [NSNumber numberWithBool:YES],CalendarItem_Type : [NSNumber numberWithInteger:CalendarCellType_User],CalendarItem_IsDefault : [NSNumber numberWithBool:NO]}],
                                                             [NSMutableDictionary dictionaryWithDictionary:@{CalendarItem_ID: @"6",CalendarItem_Name : NSLocalizedString(@"Work", @"Work"),
                                                                                                             CalendarItem_Color : [self.calendarColorArray[5] objectForKey:CalendarItem_Color],
                                                                                                             CalendarItem_IsShow : [NSNumber numberWithBool:YES],CalendarItem_Type : [NSNumber numberWithInteger:CalendarCellType_User],CalendarItem_IsDefault : [NSNumber numberWithBool:NO]}]]];
    int idx = 0;
    for (NSMutableDictionary *item in array) {
        NSMutableDictionary *addItem = [self itemForNewUserCalendar];
        [addItem setObject:[item objectForKey:CalendarItem_Name] forKey:CalendarItem_Name];
        [addItem setObject:[item objectForKey:CalendarItem_Color] forKey:CalendarItem_Color];
        [addItem setObject:[item objectForKey:CalendarItem_IsShow] forKey:CalendarItem_IsShow];
        [addItem setObject:[item objectForKey:CalendarItem_IsDefault] forKey:CalendarItem_IsDefault];
        [self addCalendarItem:addItem colorID:[self.calendarColorArray[idx] objectForKey:CalendarItem_Name] inContext:context ];
        idx++;
    }
    
    [context MR_saveToPersistentStoreAndWait];
}

- (void)prepareInContext:(NSManagedObjectContext *)context {
    NSUInteger count = [DaysCounterCalendar MR_countOfEntitiesWithContext:context];

	if ( count == 0 ) {
        [self addDefaultUserCalendarItemsInContext:context ];
    }
    [self checkAndAddSystemCalendarItemsInContext:context ];
    
    // slideshow option create
    NSDictionary *opt = [[NSUserDefaults standardUserDefaults] objectForKey:A3DaysCounterSlideshowOption];
    if ( opt == nil || [opt count] < 4 ) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:@(TransitionType_Dissolve) forKey:OptionKey_Transition];
        [dict setObject:@(3) forKey:OptionKey_Showtime];
        [dict setObject:@(NO) forKey:OptionKey_Repeat];
        [dict setObject:@(NO) forKey:OptionKey_Shuffle];
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:A3DaysCounterSlideshowOption];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


- (NSString*)repeatTypeStringFromValue:(NSInteger)repeatType
{
    NSString *retStr;
    
    switch (repeatType) {
        case 0:
            retStr = NSLocalizedString(@"Never", @"Never");
            break;
        case -1:
            retStr = NSLocalizedString(@"Every Day", @"Every Day");
            break;
        case -2:
            retStr = NSLocalizedString(@"Every Week", @"Every Week");
            break;
        case -3:
            retStr = NSLocalizedString(@"Every 2Weeks", @"Every 2Week");
            break;
        case -4:
            retStr = NSLocalizedString(@"Every Month", @"Every Month");
            break;
        case -5:
            retStr = NSLocalizedString(@"Every Year", @"Every Year");
            break;
            
        default:
            retStr = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld days", @"StringsDict", nil), (long)repeatType];
            break;
    }
    
    return retStr;
}

- (NSString*)repeatTypeStringForDetailValue:(NSInteger)repeatType
{
    NSString *retStr;
    
    switch (repeatType) {
        case 0:
            retStr = NSLocalizedString(@"Never", nil);
            break;
        case -1:
            retStr = NSLocalizedString(@"Daily", nil);
            break;
        case -2:
            retStr = NSLocalizedString(@"Weekly", nil);
            break;
        case -3:
            retStr = NSLocalizedString(@"Bi-Weekly", nil);
            break;
        case -4:
            retStr = NSLocalizedString(@"Monthly", nil);
            break;
        case -5:
            retStr = NSLocalizedString(@"Yearly", nil);
            break;
            
        default:
            retStr = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld days", @"StringsDict", nil), (long)repeatType];
            break;
    }
    
    return retStr;
}

- (NSString*)alertDateStringFromDate:(NSDate*)startDate alertDate:(id)date
{
    NSInteger alertType = [self alertTypeIndexFromDate:startDate alertDate:date];
    if (alertType == AlertType_Custom) {
        //return [A3Formatter stringFromDate:date format:DaysCounterDefaultDateFormat];
        NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:date toDate:startDate options:0];
        return [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld days before", @"StringsDict", nil), (long)comp.day];
    }
    
    return [self alertStringForType:alertType];
}

- (NSString*)alertStringForType:(NSInteger)alertType
{
    NSArray *array = @[
			NSLocalizedString(@"None", @"None"),
			NSLocalizedString(@"At time of event", @"At time of event"),
			NSLocalizedString(@"5 minutes before", @"5 minutes before"),
			NSLocalizedString(@"15 minutes before", @"15 minutes before"),
			NSLocalizedString(@"30 minutes before", @"30 minutes before"),
			NSLocalizedString(@"1 hour before", @"1 hour before"),
			NSLocalizedString(@"2 hours before", @"2 hours before"),
			NSLocalizedString(@"1 day before", @"1 day before"),
			NSLocalizedString(@"2 days before", @"2 days before"),
			NSLocalizedString(@"1 week before", @"1 week before")];
    
    if ( alertType < 0 || alertType >= AlertType_Custom )
        return @"";
    
    return [array objectAtIndex:alertType];
}

- (NSInteger)alertTypeIndexFromDate:(NSDate*)date alertDate:(id)alertDate
{
    if (!date || !alertDate) {
        return AlertType_None;
    }
    
    NSInteger retType = AlertType_Custom;
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:alertDate toDate:date options:0];
    if ( [comps year] == 0 && [comps month] == 0 && [comps day] == 0 && [comps hour] == 0 && [comps minute] == 0 ) {
        retType = AlertType_AtTimeOfEvent;
    }
    else if ( [comps year] == 0 && [comps month] == 0 && [comps day] == 0 && [comps hour] == 0 ) {
        if ( [comps minute] == 5 )
            retType = AlertType_5MinutesBefore;
        else if ( [comps minute] == 15 )
            retType = AlertType_15MinutesBefore;
        else if ( [comps minute] == 30 )
            retType = AlertType_30MinutesBefore;
    }
    else if ( [comps year] == 0 && [comps month] == 0 && [comps day] == 0 && [comps minute] == 0 ) {
        if ( [comps hour] == 1 )
            retType = AlertType_1HourBefore;
        else if ( [comps hour] == 2 )
            retType = AlertType_2HoursBefore;
    }
    else if ( [comps year] == 0 && [comps month] == 0 && [comps hour] == 0 && [comps minute] == 0 ) {
        if ( [comps day] == 1 )
            retType = AlertType_1DayBefore;
        else if ( [comps day] == 2 )
            retType = AlertType_2DaysBefore;
        else if ( [comps day] == 7 )
            retType = AlertType_1WeekBefore;
    }
    
    return retType;
}

- (NSString*)durationOptionStringFromValue:(NSInteger)option
{
    NSUInteger flagCount = 0;

    if ( option & DurationOption_Minutes) {
        flagCount++;
    }
    if ( option & DurationOption_Hour ) {
        flagCount++;
    }
    if ( option & DurationOption_Day ) {
        flagCount++;
    }
    if ( option & DurationOption_Week ) {
        flagCount++;
    }
    if ( option & DurationOption_Month ) {
        flagCount++;
    }
    if ( option & DurationOption_Year ) {
        flagCount++;
    }
    
    BOOL isShortType = NO;
    if (IS_IPHONE && flagCount >= 3) {
        isShortType = YES;
    }
    
    NSString *retStr;
    NSMutableArray *resultOptionStrings = [NSMutableArray new];
    if ( option & DurationOption_Year ) {
		[resultOptionStrings addObject:isShortType ? NSLocalizedString(@"DaysCounterDuration_year_abbreviation", @"y") : NSLocalizedString(@"Years", @"Years")];
    }
    if ( option & DurationOption_Month ) {
		[resultOptionStrings addObject:isShortType ? NSLocalizedString(@"DaysCounterDuration_month_abbreviation", @"m") : NSLocalizedString(@"Months", @"Months")];
    }
    if ( option & DurationOption_Week ) {
		[resultOptionStrings addObject:isShortType ? NSLocalizedString(@"DaysCounterDuration_week_abbreviation", @"w") : NSLocalizedString(@"Weeks", @"Weeks")];
    }
    if ( option & DurationOption_Day ) {
		[resultOptionStrings addObject:isShortType ? NSLocalizedString(@"DaysCounterDuration_day_abbreviation", @"d") : NSLocalizedString(@"Days", @"Days")];
    }
    if ( option & DurationOption_Hour ) {
		[resultOptionStrings addObject:isShortType ? NSLocalizedString(@"DaysCounterDuration_hour_abbreviation", @"hr") : NSLocalizedString(@"Hours", @"Hours")];
    }
    if ( option & DurationOption_Minutes ) {
		[resultOptionStrings addObject:isShortType ? NSLocalizedString(@"DaysCounterDuration_minute_abbreviation", @"min") : NSLocalizedString(@"Minutes", @"Minutes")];
    }
    retStr = [resultOptionStrings componentsJoinedByString:@" "];
    
    return retStr;
}

- (NSString*)addressFromVenue:(FSVenue*)venue isDetail:(BOOL)isDetail
{
    NSString *address = venue.location.address;
    if ( [venue.location.city length] > 0 )
        address = [address stringByAppendingFormat:@"%@%@", (isDetail ? @"\n" : @" "),venue.location.city];
    if ( [venue.location.state length] > 0 )
         address = [address stringByAppendingFormat:@"%@%@", (isDetail ? @"\n" : @" "),venue.location.state];
    if ( [venue.location.country length] > 0 )
        address = [address stringByAppendingFormat:@"%@%@", (isDetail ? @"\n" : @" "),venue.location.country];
    return address;
}

- (NSString*)addressFromPlacemark:(CLPlacemark*)placemark
{
    NSDictionary *addressDict = placemark.addressDictionary;
    NSString *address = @"";
    if ( [[addressDict objectForKey:(NSString*)kABPersonAddressStreetKey] length] > 0 )
       address = [addressDict objectForKey:(NSString*)kABPersonAddressStreetKey];
    if ( [placemark.subLocality length] > 0 )
        address = [address stringByAppendingFormat:@"%@%@", ([address length] > 0 ? @" " : @""),placemark.subLocality];
    if ( [[addressDict objectForKey:(NSString*)kABPersonAddressCityKey] length] > 0 )
        address = [address stringByAppendingFormat:@"%@%@", ([address length] > 0 ? @" " : @""),[addressDict objectForKey:(NSString*)kABPersonAddressCityKey]];
    if ( [[addressDict objectForKey:(NSString*)kABPersonAddressStateKey] length] > 0 )
        address = [address stringByAppendingFormat:@"%@%@", ([address length] > 0 ? @" " : @""),[addressDict objectForKey:(NSString*)kABPersonAddressStateKey]];
    if ( [[addressDict objectForKey:(NSString*)kABPersonAddressCountryKey] length] > 0 )
        address = [address stringByAppendingFormat:@"%@%@", ([address length] > 0 ? @" " : @""),[addressDict objectForKey:(NSString*)kABPersonAddressCountryKey]];
    return address;
}

- (FSVenue*)fsvenueFromEventModel:(DaysCounterEventLocation *)locationItem
{
    FSVenue *venue = [[FSVenue alloc] init];
    venue.name = locationItem.locationName;
    venue.contact = locationItem.contact;
    if ( locationItem.latitude && locationItem.locationName ) {
        venue.location.coordinate = CLLocationCoordinate2DMake([locationItem.latitude doubleValue], [locationItem.longitude doubleValue]);
    }
    venue.location.address = locationItem.address;
    venue.location.city = locationItem.city;
    venue.location.state = locationItem.state;
    venue.location.country = locationItem.country;
    
    return venue;
}

- (FSVenue*)fsvenueFromEventLocationModel:(id)location
{
    DaysCounterEventLocation *locationItem = (DaysCounterEventLocation*)location;
    FSVenue *venue = [[FSVenue alloc] init];
    venue.name = locationItem.locationName;
    venue.contact = locationItem.contact;
    venue.location.coordinate = CLLocationCoordinate2DMake([locationItem.latitude doubleValue], [locationItem.longitude doubleValue]);
    venue.location.address = locationItem.address;
    venue.location.city = locationItem.city;
    venue.location.state = locationItem.state;
    venue.location.country = locationItem.country;
    
    return venue;
}

- (BOOL)addEvent:(DaysCounterEvent *)eventModel {
    if ( !eventModel.alertDatetime ) {
        eventModel.alertDatetime = nil;
        eventModel.hasReminder = @(NO);
    }
    else {
        eventModel.hasReminder = @(YES);
    }

    if (!eventModel.effectiveStartDate) {
        eventModel.effectiveStartDate = [eventModel.startDate solarDate];
    }
    
    eventModel.modificationDate = [NSDate date];

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    
    return YES;
}

- (BOOL)modifyEvent:(DaysCounterEvent *)eventItem {
    if ( !eventItem.effectiveStartDate ) {
        eventItem.effectiveStartDate = [eventItem.startDate solarDate];
    }
    
    eventItem.effectiveStartDate = [A3DaysCounterModelManager effectiveDateForEvent:eventItem basisTime:[NSDate date]];
    
    if ( !eventItem.alertDatetime ) {
        eventItem.alertDatetime = nil;
        eventItem.hasReminder = @(NO);
    }
    else {
        eventItem.alertDatetime = [A3DaysCounterModelManager effectiveAlertDateForEvent:eventItem];
        eventItem.hasReminder = ([eventItem.alertDatetime timeIntervalSince1970] > [[NSDate date] timeIntervalSince1970]) || (![eventItem.repeatType isEqualToNumber:@(RepeatType_Never)]) ? @(YES) : @(NO);
    }
    
    if ([eventItem.hasReminder boolValue] && eventItem.reminder) {
        eventItem.reminder.isUnread = @(YES);
        eventItem.reminder.isOn = @(NO);
        eventItem.reminder.startDate = eventItem.effectiveStartDate;
        eventItem.reminder.alertDate = eventItem.alertDatetime;
    }
    
	eventItem.modificationDate = [NSDate date];
    
	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    
    return YES;
}

- (BOOL)removeEvent:(DaysCounterEvent *)eventItem
{
    // event store 에 설정된 값도 삭제한다.
    [eventItem MR_deleteEntity];
	[eventItem deletePhoto];

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    
    return YES;
}

- (NSMutableArray*)visibleCalendarList
{
    NSArray *result = [DaysCounterCalendar MR_findAllSortedBy:@"order" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"isShow == %@",[NSNumber numberWithBool:YES]]];
    
    return [NSMutableArray arrayWithArray:result];
}

- (NSMutableArray*)allCalendarList
{
    NSArray *result = [DaysCounterCalendar MR_findAllSortedBy:@"order" ascending:YES];
    
    return [NSMutableArray arrayWithArray:result];
}

- (NSMutableArray*)allUserCalendarList
{
    NSArray *result = [DaysCounterCalendar MR_findAllSortedBy:@"order" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"calendarType == %@",[NSNumber numberWithInteger:CalendarCellType_User]]];
    
    return [NSMutableArray arrayWithArray:result];
}

- (NSMutableDictionary *)itemForNewUserCalendar
{
    NSMutableDictionary *item = [NSMutableDictionary dictionary];
    
    [item setObject:[[NSUUID UUID] UUIDString]  forKey:CalendarItem_ID];
    [item setObject:@"" forKey:CalendarItem_Name];
    [item setObject:@(YES) forKey:CalendarItem_IsShow];
    [item setObject:@(CalendarCellType_User) forKey:CalendarItem_Type];
    [item setObject:[self.calendarColorArray[6] objectForKey:CalendarItem_Color] forKey:CalendarItem_Color];
    [item setObject:[self.calendarColorArray[6] objectForKey:CalendarItem_Name] forKey:CalendarItem_ColorID];
    [item setObject:[NSNumber numberWithInteger:0] forKey:CalendarItem_NumberOfEvents];
    
    return item;
}

- (id)calendarItemByID:(NSString *)calendarId inContext:(NSManagedObjectContext *)context {
    return [DaysCounterCalendar MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"calendarId == %@",calendarId] inContext:context];
}

- (BOOL)removeCalendarItem:(NSMutableDictionary*)item
{
    DaysCounterCalendar *removeItem = [self calendarItemByID:[item objectForKey:CalendarItem_ID] inContext:[[MagicalRecordStack defaultStack] context] ];
    
    if ( removeItem == nil )
        return NO;
    
    NSManagedObjectContext *context = [removeItem managedObjectContext];
    BOOL retValue = NO;
    if ( [removeItem MR_deleteInContext:context] ) {
        [context MR_saveToPersistentStoreAndWait];
        retValue = YES;
    }
    else
        retValue = NO;
    return retValue;
}

- (BOOL)removeCalendarItemWithID:(NSString*)calendarID
{
    DaysCounterCalendar *removeItem = [self calendarItemByID:calendarID inContext:[[MagicalRecordStack defaultStack] context] ];
    
    if ( removeItem == nil )
        return NO;
    
    NSManagedObjectContext *context = [removeItem managedObjectContext];
    BOOL retValue = NO;
    if ( [removeItem MR_deleteInContext:context] ) {
        [context MR_saveToPersistentStoreAndWait];
        retValue = YES;
    }
    else {
        retValue = NO;
    }
    
    return retValue;
}

- (DaysCounterCalendar *)addCalendarItem:(NSDictionary *)item colorID:(NSString *)colorID inContext:(NSManagedObjectContext *)context {
    if ([self calendarItemByID:[item objectForKey:CalendarItem_ID] inContext:context] )
        return nil;
    
    NSUInteger numberOfItems = [DaysCounterCalendar MR_countOfEntitiesWithContext:context];
    // save to core data storage
    DaysCounterCalendar *calendar = [DaysCounterCalendar MR_createInContext:context];
    calendar.calendarId = [item objectForKey:CalendarItem_ID];
    calendar.calendarName = [item objectForKey:CalendarItem_Name];
    calendar.calendarColor = [NSKeyedArchiver archivedDataWithRootObject:[item objectForKey:CalendarItem_Color]];
    calendar.isShow = [item objectForKey:CalendarItem_IsShow];
    calendar.calendarType = [item objectForKey:CalendarItem_Type];
    calendar.order = [NSNumber numberWithInteger:numberOfItems+1];
    calendar.isDefault = [item objectForKey:CalendarItem_IsDefault];
    calendar.calendarColorID = colorID;
    
    [context MR_saveToPersistentStoreAndWait];
    
    return calendar;
}


- (BOOL)updateCalendarItem:(NSMutableDictionary*)item colorID:(NSString *)colorID
{
    DaysCounterCalendar *existsCalendar = [self calendarItemByID:[item objectForKey:CalendarItem_ID] inContext:[[MagicalRecordStack defaultStack] context]];

    if (existsCalendar == nil )
        return NO;

    existsCalendar.calendarColor = [NSKeyedArchiver archivedDataWithRootObject:[item objectForKey:CalendarItem_Color]];
    existsCalendar.calendarName = [item objectForKey:CalendarItem_Name];
    existsCalendar.isShow = [item objectForKey:CalendarItem_IsShow];
    existsCalendar.calendarColorID = colorID;
    
    [[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    
    return YES;
}

- (NSArray*)calendarColorList
{
    return [NSArray arrayWithArray:[self calendarColorArray]];
}

- (NSMutableArray *)calendarColorArray
{
    if (!_calendarColorArray) {
        _calendarColorArray = [NSMutableArray array];
        [_calendarColorArray addObject:@{ CalendarItem_Color : [UIColor colorWithRed:1.0 green:41.0/255.0 blue:104.0/255.0 alpha:1.0], CalendarItem_Name : @"Red"}];
        [_calendarColorArray addObject:@{ CalendarItem_Color : [UIColor colorWithRed:1.0 green:149.0/255.0 blue:0 alpha:1.0], CalendarItem_Name : @"Orange"}];
        [_calendarColorArray addObject:@{ CalendarItem_Color : [UIColor colorWithRed:1.0 green:204.0/255.0 blue:0 alpha:1.0], CalendarItem_Name : @"Yellow"}];
        [_calendarColorArray addObject:@{ CalendarItem_Color : [UIColor colorWithRed:99.0/255.0 green:218.0/255.0 blue:56.0/255.0 alpha:1.0], CalendarItem_Name : @"Green" }];
        [_calendarColorArray addObject:@{ CalendarItem_Color : [UIColor colorWithRed:27.0/255.0 green:173.0/255.0 blue:248.0/255.0 alpha:1.0], CalendarItem_Name : @"Blue" }];
        [_calendarColorArray addObject:@{ CalendarItem_Color : [UIColor colorWithRed:88.0/255.0 green:86.0/255.0 blue:214.0/255.0 alpha:1.0], CalendarItem_Name : @"Violet" }];
        [_calendarColorArray addObject:@{ CalendarItem_Color : [UIColor colorWithRed:204.0/255.0 green:115.0/255.0 blue:225.0/255.0 alpha:1.0], CalendarItem_Name : @"Purple" }];
        [_calendarColorArray addObject:@{ CalendarItem_Color : [UIColor colorWithRed:162.0/255.0 green:132.0/255.0 blue:94.0/255.0 alpha:1.0], CalendarItem_Name : @"Brown" }];
        [_calendarColorArray addObject:@{ CalendarItem_Color : [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0], CalendarItem_Name : @"Gray" }];
    }
    
    return _calendarColorArray;
}

- (NSInteger)numberOfAllEvents
{
    return [DaysCounterEvent MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"calendar.isShow == %@", @(YES)]];
}

- (NSInteger)numberOfUpcomingEventsWithDate:(NSDate*)date
{
    return [DaysCounterEvent MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"calendar.isShow == %@ && (effectiveStartDate > %@ || repeatEndDate > %@ || (repeatType != %@ && repeatEndDate == nil))", @(YES), date, date, @(RepeatType_Never)]];
}

- (NSInteger)numberOfPastEventsWithDate:(NSDate*)date
{
    return [DaysCounterEvent MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"calendar.isShow == %@ && ((effectiveStartDate < %@ && repeatType == %@) || (repeatEndDate == nil && repeatEndDate < %@))", @(YES), date, @(RepeatType_Never), date]];
}

- (NSInteger)numberOfUserCalendarVisible
{
    return [DaysCounterCalendar MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"isShow == %@ and calendarType == %@",[NSNumber numberWithBool:YES],[NSNumber numberWithInteger:CalendarCellType_User]]];
}

- (NSInteger)numberOfEventContainedImage
{
    return [DaysCounterEvent MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"calendar.isShow == YES && hasPhoto == YES"]];
}

- (NSDate*)dateOfLatestEvent
{
    DaysCounterEvent *event = [DaysCounterEvent MR_findFirstOrderedByAttribute:@"modificationDate" ascending:NO];
    if ( event == nil )
        return nil;
    
    return event.modificationDate;
}

- (DaysCounterCalendar*)defaultCalendar
{
    DaysCounterCalendar *defaultCalendar = [DaysCounterCalendar MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"isDefault == %@", [NSNumber numberWithBool:YES]]];
    if ( defaultCalendar == nil ) {
        NSArray *calendarList = [self visibleCalendarList];
        if ( [calendarList count] < 1 )
            calendarList = [self allUserCalendarList];
        if ( [calendarList count] > 0 )
            defaultCalendar = [calendarList objectAtIndex:0];
        
        if ( defaultCalendar ) {
            defaultCalendar.isDefault = @(YES);
            [defaultCalendar.managedObjectContext  MR_saveToPersistentStoreAndWait];
        }
    }
    
    return defaultCalendar;
}

- (NSArray*)allEventsList
{
    return [DaysCounterEvent MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"calendar.isShow == %@", @(YES)]];
}

- (NSArray*)allEventsListContainedImage
{
    return [DaysCounterEvent MR_findAllSortedBy:@"effectiveStartDate" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"calendar.isShow == YES && hasPhoto == YES"]];
}

- (NSArray*)upcomingEventsListWithDate:(NSDate*)date
{
    return [DaysCounterEvent MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"calendar.isShow == %@ && (effectiveStartDate > %@ || repeatEndDate > %@ || (repeatType != %@ && repeatEndDate == nil))", @(YES), date, date, @(RepeatType_Never)]
                                           ];
}

- (NSArray*)pastEventsListWithDate:(NSDate*)date
{
    return [DaysCounterEvent MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"calendar.isShow == %@ && ((effectiveStartDate < %@ && repeatType == %@) || (repeatEndDate == nil && repeatEndDate < %@))", @(YES), date, @(RepeatType_Never), date]
                                           ];
}

- (NSArray*)favoriteEventsList
{
    return [DaysCounterFavorite MR_findAllSortedBy:@"order" ascending:YES];
}

- (void)arrangeReminderList
{
    NSDate *now = [NSDate date];
    NSArray *reminders = [DaysCounterReminder MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"isOn == %@", @(YES)]];
    [reminders enumerateObjectsUsingBlock:^(DaysCounterReminder *reminder, NSUInteger idx, BOOL *stop) {
        if ([reminder.isUnread isEqualToNumber:@(NO)]) {
            if ([reminder.startDate timeIntervalSince1970] < [now timeIntervalSince1970]) {
                reminder.isOn = @(NO);
            }
        }
    }];
}

- (NSArray*)reminderList
{
    [self arrangeReminderList];
    return [DaysCounterReminder MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"isOn == %@", @(YES)]];
}

+ (NSDate*)nextDateWithRepeatOption:(NSInteger)repeatType firstDate:(NSDate*)firstDate fromDate:(NSDate*)fromDate isAllDay:(BOOL)isAllDay
{
    NSDate *retDate = nil;
    if (isAllDay) {
        fromDate = [A3DateHelper midnightForDate:fromDate];
        firstDate = [A3DateHelper midnightForDate:firstDate];
    }

    if ([self isTodayEventForDate:firstDate fromDate:fromDate repeatType:repeatType]) {
        retDate = [self repeatDateOfCurrentNotNextWithRepeatOption:repeatType firstDate:firstDate fromDate:fromDate];
        return retDate;
    }
    
    NSInteger days = [A3DateHelper diffDaysFromDate:firstDate toDate:fromDate];
    
    if ( days < 0 ) {
        return firstDate;
    }
    // 시작일로부터 오늘까지 각 설정에 맞는 주수를 계산
    switch (repeatType) {
        case RepeatType_Never:
            retDate = firstDate;
            break;
            
        case RepeatType_EveryDay:{
            NSInteger days = [A3DateHelper diffDaysFromDate:firstDate toDate:fromDate];
            retDate = [A3DateHelper dateByAddingDays:days+1 fromDate:firstDate];
        }
            break;
            
        case RepeatType_EveryWeek:{
            NSInteger weeks = [A3DateHelper diffWeeksFromDate:firstDate toDate:fromDate];
            retDate = [A3DateHelper dateByAddingWeeks:weeks+1 fromDate:firstDate];
        }
            break;
        case RepeatType_Every2Week:{
            NSInteger weeks = [A3DateHelper diffWeeksFromDate:firstDate toDate:fromDate];
            NSInteger remainNum = weeks % 2;
            retDate = [A3DateHelper dateByAddingWeeks:weeks+ (2-remainNum) fromDate:firstDate];
        }
            break;
        case RepeatType_EveryMonth:{
            NSInteger month = [A3DateHelper diffMonthsFromDate:firstDate toDate:fromDate];
            retDate = [A3DateHelper dateByAddingMonth:month+1 fromDate:firstDate];
        }
            break;
        case RepeatType_EveryYear:{
            NSInteger year = [A3DateHelper diffYearsFromDate:firstDate toDate:fromDate];
            retDate = [A3DateHelper dateByAddingYears:year+1 fromDate:firstDate];
        }
            break;
            
        default:{
            NSInteger dayUnit = repeatType;
            NSInteger days = [A3DateHelper diffDaysFromDate:firstDate toDate:fromDate];
            NSInteger remainNum = days % dayUnit;
            retDate = [A3DateHelper dateByAddingDays:days+(dayUnit-remainNum) fromDate:firstDate];
        }
            break;
    }
    return retDate;
}


+ (NSDate*)repeatDateOfCurrentNotNextWithRepeatOption:(NSInteger)repeatType firstDate:(NSDate*)firstDate fromDate:(NSDate*)fromDate
{
    NSDate *retDate = nil;
    NSInteger days = [A3DateHelper diffDaysFromDate:firstDate toDate:fromDate];
    if ( days < 0 ) {
        return firstDate;
    }

    // 시작일로부터 오늘까지 각 설정에 맞는 주수를 계산
    switch (repeatType) {
        case RepeatType_Never:
            retDate = firstDate;
            break;
            
        case RepeatType_EveryDay:
        {
            NSInteger days = [A3DateHelper diffDaysFromDate:firstDate toDate:fromDate];
            retDate = [A3DateHelper dateByAddingDays:days fromDate:firstDate];
        }
            break;
            
        case RepeatType_EveryWeek:
        {
            NSInteger weeks = [A3DateHelper diffWeeksFromDate:firstDate toDate:fromDate];
            retDate = [A3DateHelper dateByAddingWeeks:weeks fromDate:firstDate];
        }
            break;
        case RepeatType_Every2Week:
        {
            NSInteger weeks = [A3DateHelper diffWeeksFromDate:firstDate toDate:fromDate];
            NSInteger remainNum = weeks % 2;
            retDate = [A3DateHelper dateByAddingWeeks:weeks + remainNum fromDate:firstDate];
        }
            break;
        case RepeatType_EveryMonth:
        {
            NSInteger month = [A3DateHelper diffMonthsFromDate:firstDate toDate:fromDate];
            retDate = [A3DateHelper dateByAddingMonth:month fromDate:firstDate];
        }
            break;
        case RepeatType_EveryYear:{
            NSInteger year = [A3DateHelper diffYearsFromDate:firstDate toDate:fromDate];
            retDate = [A3DateHelper dateByAddingYears:year fromDate:firstDate];
        }
            break;
            
        default:{
            NSInteger dayUnit = repeatType;
            NSInteger days = [A3DateHelper diffDaysFromDate:firstDate toDate:fromDate];
            NSInteger remainNum = days % dayUnit;
            retDate = [A3DateHelper dateByAddingDays:days + (dayUnit - remainNum) fromDate:firstDate];
        }
            break;
    }
    return retDate;
}

+ (NSString*)stringOfDurationOption:(NSInteger)option fromDate:(NSDate*)fromDate toDate:(NSDate*)toDate isAllDay:(BOOL)isAllDay isShortStyle:(BOOL)isShortStyle isStrictShortType:(BOOL)isStrictShortType
{
    if ( toDate == nil || fromDate == nil) {
		return @" ";
    }
    
    NSDate *smallDate = fromDate;
    NSDate *largeDate = toDate;
    
    if ( [fromDate timeIntervalSince1970] > [toDate timeIntervalSince1970] ) {
        largeDate = fromDate;
        smallDate = toDate;
    }
    
    NSUInteger flag = 0;
    NSUInteger flagCount = 0;

    if ( option & DurationOption_Minutes) {
        flag |= NSMinuteCalendarUnit;
        flagCount++;
    }
    if ( option & DurationOption_Hour ) {
        flag |= NSHourCalendarUnit;
        flagCount++;
    }
    if ( option & DurationOption_Day ) {
        flag |= NSDayCalendarUnit;
        flagCount++;
    }
    if ( option & DurationOption_Week ) {
        flag |= NSWeekCalendarUnit;
        flagCount++;
    }
    if ( option & DurationOption_Month ) {
        flag |= NSMonthCalendarUnit;
        flagCount++;
    }
    if ( option & DurationOption_Year ) {
        flag |= NSYearCalendarUnit;
        flagCount++;
    }


    if (!isShortStyle) {
        if (IS_IPHONE && flagCount >= 3) {
            isShortStyle = YES;
        }
    }

    if (IS_IPHONE && isShortStyle && flagCount <= 2) {
        isShortStyle = NO;
    }
    if (IS_IPAD && !isShortStyle && flagCount == 6) {
        isShortStyle = YES;
    }
//    NSInteger diffDays = [A3DateHelper diffDaysFromDate:[NSDate date] toDate:item.effectiveStartDate isAllDay:YES];
    // DurationOption 이 day 이상인 경우에 대한 예외처리. (하루가 안 되는 기간은 0day가 아닌 시분초를 출력함), (또한 hms 에 대한 옵션이 없는 경우만 해당함.)
    if ( (([largeDate timeIntervalSince1970] - [smallDate timeIntervalSince1970]) < 86400) &&
         (!(flag & NSHourCalendarUnit) && !(flag & NSMinuteCalendarUnit)) &&
//         (!(flag & NSHourCalendarUnit) && !(flag & NSMinuteCalendarUnit) && !(flag & NSSecondCalendarUnit)) &&
        !isAllDay ) {
            flag = NSHourCalendarUnit | NSMinuteCalendarUnit;
            option = DurationOption_Minutes | DurationOption_Hour;
    }

	NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *diffComponent;

    if (isAllDay) {
        NSDateComponents *fromComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit
                                                 fromDate:fromDate];
        NSDateComponents *toComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit
                                               fromDate:toDate];
        fromComp.hour = 0;
        fromComp.minute = 0;
        fromComp.second = 0;
        toComp.hour = 0;
        toComp.minute = 0;
        toComp.second = 0;
        
        diffComponent = [calendar components:flag
                                    fromDate:[calendar dateFromComponents:fromComp]
                                      toDate:[calendar dateFromComponents:toComp]
                                     options:0];
    }
    else {
        diffComponent = [calendar components:flag
                                    fromDate:smallDate
                                      toDate:largeDate options:0];
    }

    NSMutableArray * resultArray = [NSMutableArray new];
    
    
    if (!isShortStyle) {
        if ( option & DurationOption_Year && [diffComponent year] != 0) {
            [resultArray addObject:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld years", @"StringsDict", nil), labs([diffComponent year]) ] ];
        }
        if ( option & DurationOption_Month && [diffComponent month] != 0) {
            [resultArray addObject:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld months", @"StringsDict", nil), labs([diffComponent month]) ] ];
        }
        if ( option & DurationOption_Week && [diffComponent week] != 0) {
            [resultArray addObject:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld weeks", @"StringsDict", nil), labs([diffComponent week]) ] ];
        }
        if (option & DurationOption_Day && [diffComponent day] != 0) {
            [resultArray addObject:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld days", @"StringsDict", nil), labs([diffComponent day]) ] ];
        }
        
        if (!isAllDay) {
            if (option & DurationOption_Hour && [diffComponent hour] != 0) {
                [resultArray addObject:[NSString stringWithFormat: isStrictShortType ? NSLocalizedStringFromTable(@"%ld hrs", @"StringsDict", nil) : NSLocalizedStringFromTable(@"%ld hours", @"StringsDict", nil),
                                        labs([diffComponent hour]) ] ];
            }
            if (option & DurationOption_Minutes && [diffComponent minute] != 0) {
                [resultArray addObject:[NSString stringWithFormat: isStrictShortType ? NSLocalizedStringFromTable(@"%ld mins", @"StringsDict", nil) : NSLocalizedStringFromTable(@"%ld minutes", @"StringsDict", nil),
                                        labs([diffComponent minute])]];
            }
        }
    }
    else {
        if ( option & DurationOption_Year && [diffComponent year] != 0) {
            [resultArray addObject:[NSString stringWithFormat:NSLocalizedString(@"%ld y", @"%ld y"), labs([diffComponent year])]];
        }
        if ( option & DurationOption_Month && [diffComponent month] != 0) {
            [resultArray addObject:[NSString stringWithFormat:NSLocalizedString(@"%ld m", @"%ld m"), labs([diffComponent month])]];
        }
        if ( option & DurationOption_Week && [diffComponent week] != 0) {
            [resultArray addObject:[NSString stringWithFormat:NSLocalizedString(@"%ld w", @"%ld w"), labs([diffComponent week])]];
        }
        if (option & DurationOption_Day && [diffComponent day] != 0) {
            [resultArray addObject:[NSString stringWithFormat:NSLocalizedString(@"%ld d", @"%ld d"), labs([diffComponent day])]];
        }
        
        if (!isAllDay) {
            if (option & DurationOption_Hour && [diffComponent hour] != 0) {
                [resultArray addObject:[NSString stringWithFormat:NSLocalizedString(@"%ld hr", @"%ld hr"), (long) labs([diffComponent hour])]];
            }
            if (option & DurationOption_Minutes && [diffComponent minute] != 0) {
                [resultArray addObject:[NSString stringWithFormat:NSLocalizedString(@"%ld min", @"%ld min"), (long) labs([diffComponent minute])]];
            }
        }
    }

    
    NSString *result = [resultArray componentsJoinedByString:@" "];
    if ([result isEqualToString:@""]) {
        result = @" ";
    }
    return result;
}

- (NSString*)stringForSlideshowTransitionType:(NSInteger)type
{
    NSArray *names = @[
			NSLocalizedString(@"Cube", @"Cube"),
			NSLocalizedString(@"Dissolve", @"Dissolve"),
			NSLocalizedString(@"Origami", @"Origami"),
			NSLocalizedString(@"Ripple", @"Ripple"),
			NSLocalizedString(@"Wipe", @"Wipe")
	];
    if ( type < 0 || type > TransitionType_Wipe )
        return @"";
    
    return [names objectAtIndex:type];
}

- (void)setupEventSummaryInfo:(DaysCounterEvent*)item toView:(UIView*)toView
{
    A3DaysCounterSlideshowEventSummaryView *categoryCell = (A3DaysCounterSlideshowEventSummaryView *)toView;

    if (IS_IPAD) {
        categoryCell.daysSinceTopSpaceConst.constant = IS_LANDSCAPE ? 67 : 77;
        categoryCell.titleLeadingSpaceConst.constant = 28;
        categoryCell.titleTrailingSpaceConst.constant = 28;
        categoryCell.countBaselineConst.constant = IS_LANDSCAPE ? 150 : 160;
        categoryCell.dateBaselineConst.constant = IS_LANDSCAPE ? 188 : 198;
    }
    else {
        categoryCell.daysSinceTopSpaceConst.constant = 56;
        categoryCell.titleLeadingSpaceConst.constant = 15;
        categoryCell.titleTrailingSpaceConst.constant = 15;
        categoryCell.countBaselineConst.constant = 120;
        categoryCell.dateBaselineConst.constant = 148;
    }
    
    UIImageView *bgImageView = (UIImageView*)[toView viewWithTag:10];
    UILabel *daysLabel = (UILabel *)[toView viewWithTag:11];
    UILabel *markLabel = (UILabel *)[toView viewWithTag:12];
    UILabel *dateLabel = (UILabel *)[toView viewWithTag:13];
    UILabel *titleLabel = (UILabel *)[toView viewWithTag:14];
    
    titleLabel.font = [UIFont systemFontOfSize:(IS_IPHONE ? 23.0 : 24.0)];
    titleLabel.text = item.eventName;
    markLabel.font = [UIFont systemFontOfSize:(IS_IPHONE ? 13.0 : 14.0)];
    dateLabel.shadowOffset = CGSizeMake(0,1);
    dateLabel.font = [UIFont systemFontOfSize:(IS_IPHONE ? 18.0 : 21.0)];
    
    NSString *untilSinceString = [A3DateHelper untilSinceStringByFromDate:[NSDate date]
                                                                   toDate:item.effectiveStartDate
                                                             allDayOption:[item.isAllDay boolValue]
                                                                   repeat:[item.repeatType integerValue] != RepeatType_Never ? YES : NO
                                                                   strict:NO];

    if ([untilSinceString isEqualToString:NSLocalizedString(@"Today", @"Today")] || [untilSinceString isEqualToString:NSLocalizedString(@"Now", @"Now")]) {
        NSDate *repeatDate = [A3DaysCounterModelManager repeatDateOfCurrentNotNextWithRepeatOption:[item.repeatType integerValue]
                                                                                         firstDate:[item.startDate solarDate]
                                                                                          fromDate:[NSDate date]];
        dateLabel.text = [A3DateHelper dateStringFromDate:repeatDate
                                               withFormat:[self dateFormatForPhotoWithIsAllDays:[item.isLunar boolValue] ? YES : [item.isAllDay boolValue]]];
        daysLabel.text = [NSString stringWithFormat:@" %@ ", [untilSinceString isEqualToString:NSLocalizedString(@"Today", @"Today")] ? NSLocalizedString(@"Today", @"Today") : NSLocalizedString(@"Now", @"Now")];
        markLabel.text = @"";
        daysLabel.font = IS_IPHONE ? [UIFont fontWithName:@".HelveticaNeueInterface-UltraLightP2" size:88.0] : [UIFont fontWithName:@".HelveticaNeueInterface-UltraLightP2" size:116.0];
    }
    else {
        dateLabel.text = [A3DateHelper dateStringFromDate:item.effectiveStartDate
                                               withFormat:[self dateFormatForPhotoWithIsAllDays:[item.isLunar boolValue] ? YES : [item.isAllDay boolValue]]];
        NSInteger diffDays = [A3DateHelper diffDaysFromDate:[NSDate date] toDate:item.effectiveStartDate isAllDay:YES];
        if ( diffDays > 0 ) {
            markLabel.text = [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"Days", @"Days"), NSLocalizedString(@"Until", @"Until")];
        }
        else if ( diffDays < 0 ) {
            markLabel.text = [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"Days", @"Days"), NSLocalizedString(@"Since", @"Since")];
        }

        daysLabel.text = [NSString stringWithFormat:@"%ld", labs(diffDays)];

        if ( IS_IPHONE ) {
            if ( labs(diffDays) > 9999 ) {
                daysLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-UltraLightP2" size:84.0];
            }
            else {
                daysLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-UltraLightP2" size:88.0];
            }
        }
        else {
            daysLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-UltraLightP2" size:116.0];
        }
    }
    
    [daysLabel sizeToFit];

	bgImageView.image = [item photoInOriginalDirectory:YES];
	FNLOG(@"%f", bgImageView.contentScaleFactor);

    for (NSLayoutConstraint *layout in toView.constraints) {
        if ( layout.firstItem ==markLabel && layout.secondItem == daysLabel && layout.firstAttribute == NSLayoutAttributeLeading && layout.secondAttribute == NSLayoutAttributeTrailing ) {
            layout.constant = (IS_IPAD ? 10.0 : 5.0);
        }
    }
}

- (BOOL)isSupportLunar
{
    NSString *locale = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    if ( [locale isEqualToString:@"KR"] || [locale isEqualToString:@"CN"] || [locale isEqualToString:@"TW"] || [locale isEqualToString:@"HK"] || [locale isEqualToString:@"MO"] )
        return YES;
    
    return NO;
}

- (NSString*)dateFormatForPhotoWithIsAllDays:(BOOL)isAllDays
{
    NSString *retFormat;
    NSDateFormatter *formatter = [NSDateFormatter new];
    
    if (isAllDays) {
        if (IS_IPAD) {
            [formatter setDateStyle:NSDateFormatterFullStyle];
            retFormat = [formatter dateFormat];
        }
        else {
            if ([NSDate isFullStyleLocale]) {
                [formatter setDateStyle:NSDateFormatterFullStyle];
                retFormat = [formatter dateFormat];
            }
            else {
                retFormat = [formatter customFullStyleFormat];
            }
        }
    }
    else {
        if (IS_IPAD) {
            [formatter setDateStyle:NSDateFormatterFullStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            retFormat = [NSString stringWithFormat:@"%@", [formatter dateFormat]];
        }
        else {
            if ([NSDate isFullStyleLocale]) {
                [formatter setDateStyle:NSDateFormatterMediumStyle];
                [formatter setTimeStyle:NSDateFormatterShortStyle];
                retFormat = [NSString stringWithFormat:@"%@", [formatter dateFormat]];
            }
            else {
                [formatter setDateFormat:[formatter customFullWithTimeStyleFormat]];
                retFormat = [NSString stringWithFormat:@"%@", [formatter dateFormat]];
            }
        }
    }
    
    return retFormat;
}

+ (NSString*)dateFormatForDetailIsAllDays:(BOOL)isAllDays
{
    NSString *retFormat;
    NSDateFormatter *formatter = [NSDateFormatter new];
    
    if (isAllDays) {
        if (IS_IPAD) {
            [formatter setDateStyle:NSDateFormatterFullStyle];
            retFormat = [formatter dateFormat];
        }
        else {
            if ([NSDate isFullStyleLocale]) {
                [formatter setDateStyle:NSDateFormatterFullStyle];
                retFormat = [formatter dateFormat];
            }
            else {
                retFormat = [formatter customFullStyleFormat];
            }
        }
    }
    else {
        if (IS_IPAD) {
            [formatter setDateStyle:NSDateFormatterFullStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            retFormat = [NSString stringWithFormat:@"%@", [formatter dateFormat]];
        }
        else {
            [formatter setDateStyle:NSDateFormatterMediumStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            retFormat = [NSString stringWithFormat:@"%@", [formatter dateFormat]];
        }
    }

    return retFormat;
}

#pragma mark - Specific Condition Validation
+ (BOOL)hasHourMinDurationOption:(NSInteger)durationOption
{
    if ( (durationOption & DurationOption_Hour) || (durationOption & DurationOption_Minutes) ) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Period

- (DaysCounterEvent *)closestEventObjectOfCalendar:(DaysCounterCalendar *)calendar
{
    NSDateComponents *nowComp = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:[NSDate date]];
    nowComp.hour = 0;
    nowComp.minute = 0;
    nowComp.second = 0;
    NSDate *today = [[NSCalendar currentCalendar] dateFromComponents:nowComp];

    // return Today or closest until
    NSOrderedSet *untilOrderedSet = [calendar.events filteredOrderedSetUsingPredicate:[NSPredicate predicateWithFormat:@"effectiveStartDate >= %@", today]];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"effectiveStartDate" ascending:YES];
    NSArray *sortedArray = [untilOrderedSet sortedArrayUsingDescriptors:@[sortDescriptor]];
    if ([sortedArray count] > 0) {
        return [sortedArray firstObject];
    }

    // return closest since
    NSOrderedSet *sinceOrderedSet = [calendar.events filteredOrderedSetUsingPredicate:[NSPredicate predicateWithFormat:@"effectiveStartDate < %@", today]];
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"effectiveStartDate" ascending:NO];
    sortedArray = [sinceOrderedSet sortedArrayUsingDescriptors:@[sortDescriptor]];
    return [sortedArray firstObject];
}

- (void)renewEffectiveStartDates:(DaysCounterCalendar *)calendar
{
    NSDate * const now = [NSDate date];
    [calendar.events enumerateObjectsUsingBlock:^(DaysCounterEvent *event, NSUInteger idx, BOOL *stop) {
        event.effectiveStartDate = [A3DaysCounterModelManager effectiveDateForEvent:event basisTime:now];
        event.alertDatetime = [A3DaysCounterModelManager effectiveAlertDateForEvent:event];
        if ([event.alertDatetime timeIntervalSince1970] < [now timeIntervalSince1970] && event.alertInterval && [event.alertInterval integerValue] > 0) {
            DaysCounterReminder *reminder = [DaysCounterReminder MR_findFirstByAttribute:@"event" withValue:event];
            if (!reminder) {
                reminder = [DaysCounterReminder MR_createEntity];
                reminder.startDate = event.effectiveStartDate;
                reminder.alertDate = event.alertDatetime;
                reminder.isOn = @(YES);
                reminder.isUnread = @(YES);
                reminder.event = event;
            }
            else {
                if ([reminder.alertDate timeIntervalSince1970] < [event.alertDatetime timeIntervalSince1970]) {
                    reminder.startDate = event.effectiveStartDate;
                    reminder.alertDate = event.alertDatetime;
                    reminder.isOn = @(YES);
                    reminder.isUnread = @(YES);
                }
            }
        }
    }];
}

- (void)renewAllEffectiveStartDates
{
    NSDate *now = [NSDate date];
    NSArray *allEvents = [DaysCounterEvent MR_findAll];
    [allEvents enumerateObjectsUsingBlock:^(DaysCounterEvent *event, NSUInteger idx, BOOL *stop) {
        event.effectiveStartDate = [A3DaysCounterModelManager effectiveDateForEvent:event basisTime:now];
        event.alertDatetime = [A3DaysCounterModelManager effectiveAlertDateForEvent:event];
        if ([event.alertDatetime timeIntervalSince1970] < [now timeIntervalSince1970] && event.alertInterval && [event.alertInterval integerValue] > 0) {
            DaysCounterReminder *reminder = [DaysCounterReminder MR_findFirstByAttribute:@"event" withValue:event];
            if (!reminder) {
                reminder = [DaysCounterReminder MR_createEntity];
                reminder.startDate = event.effectiveStartDate;
                reminder.alertDate = event.alertDatetime;
                reminder.isOn = @(YES);
                reminder.isUnread = @(YES);
                reminder.event = event;
            }
            else {
                if ([reminder.alertDate timeIntervalSince1970] < [event.alertDatetime timeIntervalSince1970]) {
                    reminder.startDate = event.effectiveStartDate;
                    reminder.alertDate = event.alertDatetime;
                    reminder.isOn = @(YES);
                    reminder.isUnread = @(YES);
                }
            }
        }
    }];
}

+ (NSDate *)effectiveDateForEvent:(DaysCounterEvent *)event basisTime:(NSDate *)now
{
    if ([event.repeatType isEqual:@(RepeatType_Never)]) {
        return [event.startDate solarDate];
    }
    
    NSDate *startDate;
    NSDate *nextDate;
    // Lunar
    if ([event.isLunar boolValue]) {
        NSDateComponents *solarComp;
        solarComp = [self nextSolarDateComponentsFromLunarDateComponents:[A3DaysCounterModelManager dateComponentsFromDateModelObject:event.startDate toLunar:YES]
                                                              leapMonth:[event.startDate.isLeapMonth boolValue]
                                                               fromDate:now];
        nextDate = [[NSCalendar currentCalendar] dateFromComponents:solarComp];
        FNLOG(@"\nToday: %@, \nFirstStartDate: %@, \nEffectiveDate: %@", now, [[event startDate] solarDate], nextDate);
        return nextDate;
    }
    else {
        // Solar
        startDate = [event.startDate solarDate];
        
        // 종료된 Event의 경우.
        if ([event repeatEndDate] && [event.repeatEndDate timeIntervalSince1970] < [now timeIntervalSince1970]) {
            now = [event repeatEndDate];
        }
        
        nextDate = [A3DaysCounterModelManager nextDateWithRepeatOption:[event.repeatType integerValue]
                                                             firstDate:startDate
                                                              fromDate:now
                                                              isAllDay:[event.isLunar boolValue] ? YES : [event.isAllDay boolValue]];
        
        FNLOG(@"\nToday: %@, \nFirstStartDate: %@, \nEffectiveDate: %@", now, [event startDate], nextDate);
        return nextDate;
    }
}

//- (BOOL)isTodayEvent:(DaysCounterEvent *)event fromDate:(NSDate *)now
+ (BOOL)isTodayEventForDate:(NSDate *)eventDate fromDate:(NSDate *)now repeatType:(NSInteger)repeatType
{
    NSCalendarUnit calendarUnit = NSDayCalendarUnit;
    switch (repeatType) {
        case RepeatType_EveryYear:
            calendarUnit |= NSYearCalendarUnit;
            break;
        case RepeatType_EveryMonth:
            calendarUnit |= NSMonthCalendarUnit;
            break;
        case RepeatType_Every2Week:
        case RepeatType_EveryWeek:
            calendarUnit |= NSWeekCalendarUnit;
            break;
        case RepeatType_EveryDay:
            break;
        case RepeatType_Never:
            calendarUnit |= NSYearCalendarUnit|NSMonthCalendarUnit;
            break;
        default:
            break;
    }
    
    NSDateComponents *daysComp = [A3DateHelper diffCompFromDate:eventDate toDate:now calendarUnit:calendarUnit];
    if (repeatType == RepeatType_EveryDay) {
        return YES;
    }
    if (daysComp.day == 0) {
        return YES;
    }
    
    return NO;
}

#pragma mark EventModel Dictionary
- (void)recalculateEventDatesForEvent:(DaysCounterEvent *)eventModel
{
    // EffectiveStartDate 갱신.
    eventModel.effectiveStartDate = [A3DaysCounterModelManager effectiveDateForEvent:eventModel basisTime:[NSDate date]];
    
    // EffectiveAlertDate 갱신.
    NSDate *alertDate = eventModel.alertDatetime;
    if (alertDate) {
        NSDateComponents *alertIntervalComp = [NSDateComponents new];
        alertIntervalComp.minute = -labs([eventModel.alertInterval integerValue]);
        NSDate *alertDate = [[NSCalendar currentCalendar] dateByAddingComponents:alertIntervalComp toDate:eventModel.effectiveStartDate options:0];
        NSDateComponents *alertDateComp = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:alertDate];
        alertDateComp.second = 0;
        
        eventModel.alertDatetime = [[NSCalendar currentCalendar] dateFromComponents:alertDateComp];
    }
    
    FNLOG(@"\nToday: %@, \nFirstStartDate: %@, \nEffectiveDate: %@, \nAlertDate: %@", [NSDate date], [eventModel.startDate solarDate], eventModel.effectiveStartDate, eventModel.alertDatetime);
}

#pragma mark - EventTime Management (AlertTime, EffectiveStartDate)
+ (void)reloadAlertDateListForLocalNotification
{
    // 기존 등록 얼럿 제거.
    [[[UIApplication sharedApplication] scheduledLocalNotifications] enumerateObjectsUsingBlock:^(UILocalNotification *notification, NSUInteger idx, BOOL *stop) {
        NSString *notificationType = [notification.userInfo objectForKey:A3LocalNotificationOwner];
        if ([notificationType isEqualToString:A3LocalNotificationFromDaysCounter]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }];

    // 얼럿 생성 & 등록.
    __block NSDate *now = [NSDate date];
    NSMutableArray *localNotifications = [NSMutableArray new];
    NSArray *alertItems = [DaysCounterEvent MR_findAllSortedBy:@"alertDatetime" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"alertDatetime != nil"]];
    [alertItems enumerateObjectsUsingBlock:^(DaysCounterEvent *event, NSUInteger idx, BOOL *stop) {
        if ([event.hasReminder isEqualToNumber:@(NO)] && event.reminder) {
            [event.reminder MR_deleteEntity];
            event.reminder = nil;
        }
        
        if (event.repeatEndDate && [event.repeatEndDate timeIntervalSince1970] < [[NSDate date] timeIntervalSince1970]) {
            return;
        }

        event.effectiveStartDate = [A3DaysCounterModelManager effectiveDateForEvent:event basisTime:now];    // 현재 기준 앞으로 발생할 실제 이벤트 시간을 얻는다.
        event.alertDatetime = [self effectiveAlertDateForEvent:event];                  // 이벤트 시간 기준, 실제 발생할 이벤트 얼럿 시간을 얻는다.
        FNLOG(@"\n[%ld] EventID: %@, EventName: %@\nEffectiveStartDate: %@, \nAlertDatetime: %@", (long)idx, event.uniqueID, event.eventName, event.effectiveStartDate, event.alertDatetime);
        
        
        
        // 리마인더 이벤트 리스트 관리.
        if ([event.hasReminder isEqualToNumber:@(YES)]) {
            DaysCounterReminder *reminder = [DaysCounterReminder MR_findFirstByAttribute:@"event.uniqueID" withValue:[event uniqueID]];
            if (!reminder) {
                reminder = [DaysCounterReminder MR_createEntity];
                reminder.event = event;
                reminder.isOn = @(NO);
                reminder.isUnread = @(YES);
                reminder.startDate = event.effectiveStartDate;
                reminder.alertDate = event.alertDatetime;
            }
            
            // 읽은 이벤트에 한하여 리마인더의 시간을 변경함. 그래야 ago 출력이 가능. (ago 출력을 위하여, Reminder 이벤트/알람 시간을 별도로 관리.
            if ([reminder.isUnread boolValue] == NO && [reminder.startDate timeIntervalSince1970] < [now timeIntervalSince1970]) {          // 읽음 && 리마인더의 이벤트 당일을 경과.
                reminder.startDate = event.effectiveStartDate;      // 시간갱신
                reminder.alertDate = event.alertDatetime;           // 시간갱신, 이벤트 알림시간은 now 보다 미래가 됨.
                reminder.isOn = @(NO);                              // 리마인더리스트에서 숨김.
                reminder.isUnread = @(YES);                         // 안 읽음 상태
            }
            else if ([reminder.isUnread boolValue] == YES && [event.alertDatetime timeIntervalSince1970] < [now timeIntervalSince1970]) {   // 읽지 않음 && 이벤트의 알림 날짜를 경과 (이벤트 알림 날짜는 항상 갱신됨)
                reminder.startDate = event.effectiveStartDate;      // 시간갱신
                reminder.alertDate = event.alertDatetime;           // 시간갱신, 이벤트 알림시간은 now 보다 미래가 됨.
                reminder.isOn = @(YES);                              // 리마인더리스트에서 출력.
            }
            else if ([reminder.isUnread boolValue] == YES && [event.alertDatetime timeIntervalSince1970] > [now timeIntervalSince1970]) {   // 읽지 않음 && 이벤트의 알림 날짜에 도달하기 전.
                reminder.startDate = event.effectiveStartDate;      // 시간갱신
                reminder.alertDate = event.alertDatetime;           // 시간갱신, 이벤트 알림시간은 now 보다 미래가 됨.
                reminder.isOn = @(NO);                              // 리마인더리스트에서 숨김.
            }

            // 이벤트 알림시간을 경과
            if ([event.alertDatetime timeIntervalSince1970] < [now timeIntervalSince1970]) {
                reminder.isOn = @(YES);     // 리마인더리스트에 출력.
            }
        }
        else {
            DaysCounterReminder *reminder = [DaysCounterReminder MR_findFirstByAttribute:@"event.uniqueID" withValue:[event uniqueID]];
            if (reminder) {
                [reminder MR_deleteEntity];
            }
        }
        
        if ([event.alertDatetime timeIntervalSince1970] > [now timeIntervalSince1970]) {
            // 현재 이후의 시간에 대하여 등록.
            UILocalNotification *notification = [UILocalNotification new];
            notification.fireDate = [event alertDatetime];
            notification.alertBody = [event eventName];
            notification.userInfo = @{
                                       A3LocalNotificationOwner : A3LocalNotificationFromDaysCounter,
                                       A3LocalNotificationDataID : [event uniqueID]};

            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            [localNotifications addObject:notification];
        }
    }];

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
}

+ (NSDate *)effectiveAlertDateForEvent:(DaysCounterEvent *)event
{
    NSDateComponents *alertIntervalComp = [NSDateComponents new];
    alertIntervalComp.minute = -[event.alertInterval integerValue];
    NSDate *effectiveAlertDate = [[NSCalendar currentCalendar] dateByAddingComponents:alertIntervalComp toDate:event.effectiveStartDate options:0];
    return effectiveAlertDate;
}

#pragma mark - Lunar
+ (NSDateComponents *)nextSolarDateComponentsFromLunarDateComponents:(NSDateComponents *)lunarComponents leapMonth:(BOOL)isLeapMonth fromDate:(NSDate *)fromDate
{
    BOOL isResultLeapMonth;
    if (isLeapMonth) {
        isLeapMonth = [NSDate isLunarDateComponents:lunarComponents isKorean:YES];
    }

    NSDateComponents *fromComp = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:fromDate];
    lunarComponents.year = fromComp.year;
    NSDateComponents *startComp = [NSDate lunarCalcWithComponents:lunarComponents gregorianToLunar:NO leapMonth:isLeapMonth korean:YES resultLeapMonth:&isResultLeapMonth];
    NSDateComponents *resultComp;
    if (fromComp.year == startComp.year &&
        (startComp.month > fromComp.month ||
        (startComp.month == fromComp.month && startComp.day > fromComp.day)) ) {
        resultComp = [self dateComponentsOfRepeatForLunarDateComponent:lunarComponents aboutNextTime:NO leapMonth:isLeapMonth fromDate:fromDate repeatType:RepeatType_EveryYear];
    }
    else {
        resultComp = [self dateComponentsOfRepeatForLunarDateComponent:lunarComponents aboutNextTime:(startComp.year > fromComp.year ? NO : YES) leapMonth:isLeapMonth fromDate:fromDate repeatType:RepeatType_EveryYear];
    }
    
//    NSAssert(resultComp, @"Not Exist Lunar Date");
    if (!resultComp) {
        return nil;
    }

    NSDateComponents *resultDateComponents = [NSDate lunarCalcWithComponents:resultComp gregorianToLunar:NO leapMonth:isLeapMonth korean:YES resultLeapMonth:&isResultLeapMonth];
    return resultDateComponents;
}

+ (NSDate *)nextSolarDateFromLunarDateComponents:(NSDateComponents *)lunarComponents leapMonth:(BOOL)isLeapMonth fromDate:(NSDate *)fromDate
{
    NSDateComponents *solarComp = [self nextSolarDateComponentsFromLunarDateComponents:lunarComponents leapMonth:isLeapMonth fromDate:fromDate];
    NSDate *result = [[NSCalendar currentCalendar] dateFromComponents:solarComp];
    return result;
}

+ (NSDateComponents *)dateComponentsOfRepeatForLunarDateComponent:(NSDateComponents *)lunarComponents aboutNextTime:(BOOL)isAboutNextTime leapMonth:(BOOL)isLeapMonth fromDate:(NSDate *)fromDate repeatType:(NSInteger)repeatType
{
    BOOL isResultLeapMonth;
    NSDateComponents *fromComp = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:fromDate];
    NSDateComponents *calcComp = [NSDateComponents new];
    
    switch (repeatType) {
        case RepeatType_EveryYear:
        {
            calcComp.year = isAboutNextTime ? fromComp.year + 1 : fromComp.year;
            calcComp.month = lunarComponents.month;
            calcComp.day = lunarComponents.day;
            calcComp = [self validLunarDateComponents:calcComp];
        }
            break;
        case RepeatType_EveryMonth:
        case RepeatType_Every2Week:
        case RepeatType_EveryWeek:
        case RepeatType_EveryDay:
        {
            
        }
            break;
        default:
            break;
    }
    
    // 존재하지 않는 반복 음력날짜에 대한 검증
    if (isLeapMonth) {
        isLeapMonth = [NSDate isLunarDateComponents:calcComp isKorean:YES];
    }
    NSDateComponents *resultDateComponents = [NSDate lunarCalcWithComponents:calcComp gregorianToLunar:NO leapMonth:isLeapMonth korean:YES resultLeapMonth:&isResultLeapMonth];
    NSDate *resultDate = [[NSCalendar currentCalendar] dateFromComponents:resultDateComponents];
    if (!resultDateComponents || !resultDate || [resultDate timeIntervalSince1970] < [fromDate timeIntervalSince1970]) {
        return nil;
    }

    return calcComp;
}

+ (NSDateComponents *)validLunarDateComponents:(NSDateComponents *)comp
{
    BOOL result = [NSDate isLunarDateComponents:comp isKorean:YES];
    if (result) {
        return comp;
    }
    else {
        comp.year += 1;
        comp = [A3DaysCounterModelManager validLunarDateComponents:comp];
    }
    
    return comp;
}

#pragma mark - Manipulate DaysCounterDateModel Object
+ (void)setDateModelObjectForDateComponents:(NSDateComponents *)dateComponents withEventModel:(DaysCounterEvent *)eventModel endDate:(BOOL)isEndDate;
{
    DaysCounterDate *dateModel = isEndDate ? eventModel.endDate : eventModel.startDate;
    if (!dateModel) {
        dateModel = [DaysCounterDate MR_createEntity];
        if (isEndDate) {
            eventModel.endDate = dateModel;
        }
        else {
            eventModel.startDate = dateModel;
        }
    }
    
    BOOL isResultLeapMonth;
    if ([eventModel.isLunar boolValue]) {
        dateModel.year = @(dateComponents.year);
        dateModel.month = @(dateComponents.month);
        dateModel.day = @(dateComponents.day);

        if ([dateModel.isLeapMonth boolValue]) {
            dateModel.isLeapMonth = @([NSDate isLunarLeapMonthAtDateComponents:dateComponents isKorean:YES]);
        }
        else {
            dateModel.isLeapMonth = @(NO);
        }
        
        NSDateComponents *solarComp = [NSDate lunarCalcWithComponents:dateComponents gregorianToLunar:NO leapMonth:[dateModel.isLeapMonth boolValue] korean:YES resultLeapMonth:&isResultLeapMonth];
        solarComp.hour = 0;     // lunar 는 all day.
        solarComp.minute = 0;
        solarComp.second = 0;
        dateModel.solarDate = [[NSCalendar currentCalendar] dateFromComponents:solarComp];
    }
    else {
        dateModel.solarDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
        dateModel.year = @(dateComponents.year);
        dateModel.month = @(dateComponents.month);
        dateModel.day = @(dateComponents.day);
        dateModel.hour = @(dateComponents.hour);
        dateModel.minute = @(dateComponents.minute);
    }
}

+ (NSDateComponents *)dateComponentsFromDateModelObject:(DaysCounterDate *)dateObject toLunar:(BOOL)isLunar
{
    NSDateComponents * dateComp;
    if (isLunar) {
        dateComp = [NSDateComponents new];
        dateComp.year = [dateObject.year integerValue];
        dateComp.month = [dateObject.month integerValue];
        dateComp.day = [dateObject.day integerValue];
        dateComp.hour = 0;
        dateComp.minute = 0;
        dateComp.second = 0;
    }
    else {
        dateComp = [NSDateComponents new];
        dateComp.year = [dateObject.year integerValue];
        dateComp.month = [dateObject.month integerValue];
        dateComp.day = [dateObject.day integerValue];
        dateComp.hour = [dateObject.hour integerValue];
        dateComp.minute = [dateObject.minute integerValue];
        dateComp.second = 0;
    }

    return dateComp;
}

#pragma mark - Print Date String From DaysCounterDateModel Or SolarDate(Effective Date)

+ (NSString *)dateStringFromDateModel:(DaysCounterDate *)dateModel isLunar:(BOOL)isLunar isAllDay:(BOOL)isAllDay {
    NSString *dateString;
    if (isLunar) {
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateStyle:NSDateFormatterFullStyle];
        NSMutableString *dateFormat = [formatter.dateFormat mutableCopy];
        [dateFormat replaceOccurrencesOfString:@"EEEE" withString:@"" options:0 range:NSMakeRange(0, [dateFormat length])];
        [dateFormat replaceOccurrencesOfString:@"MMMM" withString:@"MMM" options:0 range:NSMakeRange(0, [dateFormat length])];
        dateFormat = [[dateFormat stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] mutableCopy];
        
        NSDateComponents *solarComp = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:[dateModel solarDate]];
        if (solarComp.year == [dateModel.year integerValue]) {
            NSRange range = [dateFormat rangeOfString:@"M" options:NSCaseInsensitiveSearch];
            dateFormat = [[dateFormat substringFromIndex:range.location] mutableCopy];
        }
        
        if (IS_IPAD) {
            dateString = [NSString stringWithFormat:@"%@ (%@ %@)",
													NSLocalizedString(@"Lunar", @"Lunar"),
													[A3DateHelper dateStringFromDate:[dateModel solarDate] withFormat:[self dateFormatForDetailIsAllDays:isAllDay]],
													[A3DateHelper dateStringFromDateComponents:[A3DaysCounterModelManager dateComponentsFromDateModelObject:dateModel toLunar:isLunar] withFormat:dateFormat]];
        }
        else {
            dateString = [NSString stringWithFormat:@"(%@ %@)",
													NSLocalizedString(@"Lunar", @"Lunar"),
													[A3DateHelper dateStringFromDateComponents:[A3DaysCounterModelManager dateComponentsFromDateModelObject:dateModel toLunar:isLunar] withFormat:dateFormat]];
        }
    }
    else {
        dateString = [NSString stringWithFormat:@"%@", [A3DateHelper dateStringFromDate:[dateModel solarDate] withFormat:[self dateFormatForDetailIsAllDays:isAllDay]]];
    }
    
    return dateString;
}

+ (NSString *)dateStringFromEffectiveDate:(NSDate *)date isLunar:(BOOL)isLunar isAllDay:(BOOL)isAllDay isLeapMonth:(BOOL)isLeapMonth
{
    NSString *dateString;
    if (!isLunar) {
        dateString = [NSString stringWithFormat:@"%@", [A3DateHelper dateStringFromDate:date withFormat:[self dateFormatForDetailIsAllDays:isAllDay]]];
    }
    else {
        dateString = [NSString stringWithFormat:@"%@",
                      [A3DateHelper dateStringFromDate:date withFormat:[self dateFormatForDetailIsAllDays:YES]]];
    }
    
    return dateString;
}

+ (NSString *)dateStringOfLunarFromDateModel:(DaysCounterDate *)dateModel isLeapMonth:(BOOL)isLeapMonth
{
    NSString *dateString;
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateStyle:NSDateFormatterFullStyle];
    NSMutableString *dateFormat = [formatter.dateFormat mutableCopy];
    [dateFormat replaceOccurrencesOfString:@"EEEE" withString:@"" options:0 range:NSMakeRange(0, [dateFormat length])];
    [dateFormat replaceOccurrencesOfString:@"MMMM" withString:@"MMM" options:0 range:NSMakeRange(0, [dateFormat length])];
    
    dateString = [NSString stringWithFormat:@"%@ %@",
											NSLocalizedString(@"Lunar", @"Lunar"),
											[A3DateHelper dateStringFromDateComponents:[A3DaysCounterModelManager dateComponentsFromDateModelObject:dateModel toLunar:YES] withFormat:dateFormat]];
    return dateString;
}

- (NSString *)localizedSystemCalendarNameForCalendarID:(NSString *)calendarID {
	if ( [calendarID isEqualToString:SystemCalendarID_All] ) {
		return NSLocalizedString(@"DaysCounter_All", nil);
	}
	else if ( [calendarID isEqualToString:SystemCalendarID_Upcoming]) {
		return NSLocalizedString(@"List_Upcoming", nil);
	}
	else if ( [calendarID isEqualToString:SystemCalendarID_Past] ) {
		return NSLocalizedString(@"List_Past", nil);
	}
	return nil;
}

@end
