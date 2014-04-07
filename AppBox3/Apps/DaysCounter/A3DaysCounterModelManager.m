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
#import "NYXImagesKit.h"
#import "A3DateHelper.h"
#import "A3UserDefaults.h"
#import "FXLabel.h"
#import "A3DaysCounterSlideshowEventSummaryView.h"

#define DEFAULT_CALENDAR_COLOR      [UIColor colorWithRed:1.0 green:41.0/255.0 blue:104.0/255.0 alpha:1.0]

static A3DaysCounterModelManager *daysCounterModelManager = nil;

@interface A3DaysCounterModelManager ()
@property (strong, nonatomic) NSMutableArray *calendarColorArray;
//@property (strong, nonatomic) EKEventStore *eventStore;

- (void)checkAndAddSystemCalendarItems;
- (void)addDefaultUserCalendarItems;
- (EKAlarm*)createAlarmWithEvent:(DaysCounterEvent*)event;
- (EKRecurrenceRule*)createRecurrenceRuleWithEvent:(DaysCounterEvent*)event;
- (EKEvent*)registerToEventStore:(DaysCounterEvent*)event;
- (EKReminder*)registerToReminder:(DaysCounterEvent*)event;
@end

@implementation A3DaysCounterModelManager

+ (A3DaysCounterModelManager*)sharedManager
{
    @synchronized (self) {
        if (daysCounterModelManager == nil) {
            daysCounterModelManager = [[self alloc] init];
        }
    }
    return daysCounterModelManager;
}

+ (UIImage*)circularScaleNCrop:(UIImage*)image rect:(CGRect)rect
{
    // This function returns a newImage, based on image, that has been:
    // - scaled to fit in (CGRect) rect
    // - and cropped within a circle of radius: rectWidth/2
    
    //Create the bitmap graphics context
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(rect.size.width, rect.size.height), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Get the width and heights
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    CGFloat rectWidth = rect.size.width;
    CGFloat rectHeight = rect.size.height;
    
    //Calculate the scale factor
    CGFloat scaleFactorX = rectWidth/imageWidth;
    CGFloat scaleFactorY = rectHeight/imageHeight;
    
    //Calculate the centre of the circle
    CGFloat imageCentreX = rectWidth/2;
    CGFloat imageCentreY = rectHeight/2;
    
    // Create and CLIP to a CIRCULAR Path
    // (This could be replaced with any closed path if you want a different shaped clip)
    CGFloat radius = rectWidth/2;
    CGContextBeginPath (context);
    CGContextAddArc (context, imageCentreX, imageCentreY, radius, 0, 2*M_PI, 0);
    CGContextClosePath (context);
    CGContextClip (context);
    
    //Set the SCALE factor for the graphics context
    //All future draw calls will be scaled by this factor
    CGContextScaleCTM (context, scaleFactorX, scaleFactorY);
    
    // Draw the IMAGE
    CGRect myRect = CGRectMake(0, 0, imageWidth, imageHeight);
    [image drawInRect:myRect];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage*)strokCircleImageSize:(CGSize)size color:(UIColor*)color
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

+ (UIImage*)resizeImage:(UIImage*)image toSize:(CGSize)toSize isFill:(BOOL)isFill backgroundColor:(UIColor*)color
{
    UIGraphicsBeginImageContextWithOptions(toSize, NO, 0.0);
    
    
    if ( isFill )
        [image drawInRect:CGRectMake(0, 0, toSize.width,toSize.height)];
    else {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGFloat xRatio = toSize.width / image.size.width;
        CGFloat yRatio = toSize.height / image.size.height;
        CGFloat ratio = ( xRatio > yRatio ? yRatio : xRatio);
        ratio = (ratio > 1.0 ? 1.0 : ratio);
        CGSize newSize = CGSizeMake(image.size.width * ratio, image.size.height * ratio);
        CGContextSetFillColorWithColor(context, [color CGColor]);
        CGContextFillRect(context, CGRectMake(0, 0, toSize.width, toSize.height));
        [image drawInRect:CGRectMake(toSize.width*0.5 - newSize.width*0.5, toSize.height*0.5 - newSize.height*0.5, newSize.width, newSize.height)];
    }

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (NSString *)imagePath
{
    NSString *cacheFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    return [cacheFolder stringByAppendingPathComponent:@"DaysCounterPhoto"];
}

+ (NSString *)thumbnailPath
{
    NSString *cacheFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    return [cacheFolder stringByAppendingPathComponent:@"DaysCounterPhotoThumbnail"];
}

+ (UIImage*)photoImageFromFilename:(NSString*)imageFilename
{
    if ( [imageFilename length] < 1 )
        return nil;
    
    return [UIImage imageWithContentsOfFile:[[A3DaysCounterModelManager imagePath] stringByAppendingPathComponent:imageFilename]];
}

+ (UIImage*)photoThumbnailFromFilename:(NSString*)imageFilename
{
    if ( [imageFilename length] < 1 )
        return nil;
    
    NSString *thumbnailFilename = [A3DaysCounterModelManager thumbnailFilenameFromFilename:imageFilename];
    return [UIImage imageWithContentsOfFile:[[A3DaysCounterModelManager thumbnailPath] stringByAppendingPathComponent:thumbnailFilename]];
}

+ (NSString*)thumbnailFilenameFromFilename:(NSString*)imageFilename
{
    if ( [imageFilename length] < 1 )
        return nil;
    
    return [[[imageFilename stringByDeletingPathExtension] stringByAppendingString:@".thumbnail"] stringByAppendingPathExtension:[imageFilename pathExtension]];
}

- (NSManagedObjectContext*)managedObjectContext
{
    if ( managedContext == nil ) {
        managedContext = [[MagicalRecordStack defaultStack] context];
	}
    
    return managedContext;
}

- (NSMutableDictionary *)dictionaryFromCalendarEntity:(DaysCounterCalendar*)item
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:item.calendarColor];
    [dict setObject:item.calendarId forKey:CalendarItem_ID];
    [dict setObject:color forKey:CalendarItem_Color];
    [dict setObject:item.calendarName forKey:CalendarItem_Name];
    [dict setObject:item.isShow forKey:CalendarItem_IsShow];
    [dict setObject:[NSNumber numberWithInteger:CalendarCellType_User] forKey:CalendarItem_Type];
    [dict setObject:[NSNumber numberWithInteger:[item.events count]] forKey:CalendarItem_NumberOfEvents];
    
    return dict;
}

- (void)checkAndAddSystemCalendarItems
{
    NSArray *array = @[[NSMutableDictionary dictionaryWithDictionary:@{CalendarItem_ID: SystemCalendarID_All,CalendarItem_Name : @"All",CalendarItem_Color : [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0],CalendarItem_IsShow : [NSNumber numberWithBool:YES],CalendarItem_Type : [NSNumber numberWithInteger:CalendarCellType_System],CalendarItem_IsDefault : [NSNumber numberWithBool:NO]}],[NSMutableDictionary dictionaryWithDictionary:@{CalendarItem_ID: SystemCalendarID_Upcoming,CalendarItem_Name : @"Upcoming",CalendarItem_Color : [UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0],CalendarItem_IsShow : [NSNumber numberWithBool:YES],CalendarItem_Type : [NSNumber numberWithInteger:CalendarCellType_System],CalendarItem_IsDefault : [NSNumber numberWithBool:NO]}],[NSMutableDictionary dictionaryWithDictionary:@{CalendarItem_ID: SystemCalendarID_Past,CalendarItem_Name : @"Past",CalendarItem_Color : [UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0],CalendarItem_IsShow : [NSNumber numberWithBool:YES],CalendarItem_Type : [NSNumber numberWithInteger:CalendarCellType_System],CalendarItem_IsDefault : [NSNumber numberWithBool:NO]}]];
    
    for (NSDictionary *item in array) {
        [self addCalendarItem:item];
    }
}

- (void)addDefaultUserCalendarItems
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:@[
                                                             [NSMutableDictionary dictionaryWithDictionary:@{CalendarItem_ID: @"1",CalendarItem_Name : @"Anniversary",CalendarItem_Color : [UIColor colorWithRed:1.0 green:41.0/255.0 blue:104.0/255.0 alpha:1.0],CalendarItem_IsShow : [NSNumber numberWithBool:YES],CalendarItem_Type : [NSNumber numberWithInteger:CalendarCellType_User],CalendarItem_IsDefault : [NSNumber numberWithBool:YES]}],
                                                             [NSMutableDictionary dictionaryWithDictionary:@{CalendarItem_ID: @"2",CalendarItem_Name : @"Appointment",CalendarItem_Color : [UIColor colorWithRed:1.0 green:149.0/255.0 blue:0.0 alpha:1.0],CalendarItem_IsShow : [NSNumber numberWithBool:YES],CalendarItem_Type : [NSNumber numberWithInteger:CalendarCellType_User],CalendarItem_IsDefault : [NSNumber numberWithBool:NO]}],
                                                             [NSMutableDictionary dictionaryWithDictionary:@{CalendarItem_ID: @"3",CalendarItem_Name : @"Birthday",CalendarItem_Color : [UIColor colorWithRed:1.0 green:204.0/255.0 blue:0.0 alpha:1.0],CalendarItem_IsShow : [NSNumber numberWithBool:YES],CalendarItem_Type : [NSNumber numberWithInteger:CalendarCellType_User],CalendarItem_IsDefault : [NSNumber numberWithBool:NO]}],
                                                             [NSMutableDictionary dictionaryWithDictionary:@{CalendarItem_ID: @"4",CalendarItem_Name : @"Journey",CalendarItem_Color : [UIColor colorWithRed:99.0/255.0 green:218.0/255.0 blue:56.0/255.0 alpha:1.0],CalendarItem_IsShow : [NSNumber numberWithBool:YES],CalendarItem_Type : [NSNumber numberWithInteger:CalendarCellType_User],CalendarItem_IsDefault : [NSNumber numberWithBool:NO]}],
                                                             [NSMutableDictionary dictionaryWithDictionary:@{CalendarItem_ID: @"5",CalendarItem_Name : @"Holiday",CalendarItem_Color : [UIColor colorWithRed:27.0/255.0 green:173.0/255.0 blue:248.0/255.0 alpha:1.0],CalendarItem_IsShow : [NSNumber numberWithBool:YES],CalendarItem_Type : [NSNumber numberWithInteger:CalendarCellType_User],CalendarItem_IsDefault : [NSNumber numberWithBool:NO]}],
                                                             [NSMutableDictionary dictionaryWithDictionary:@{CalendarItem_ID: @"6",CalendarItem_Name : @"Work",CalendarItem_Color : [UIColor colorWithRed:88.0/255.0 green:86.0/255.0 blue:214.0/255.0 alpha:1.0],CalendarItem_IsShow : [NSNumber numberWithBool:YES],CalendarItem_Type : [NSNumber numberWithInteger:CalendarCellType_User],CalendarItem_IsDefault : [NSNumber numberWithBool:NO]}]]];
    for (NSMutableDictionary *item in array) {
        NSMutableDictionary *addItem = [self itemForNewUserCalendar];
        [addItem setObject:[item objectForKey:CalendarItem_Name] forKey:CalendarItem_Name];
        [addItem setObject:[item objectForKey:CalendarItem_Color] forKey:CalendarItem_Color];
        [addItem setObject:[item objectForKey:CalendarItem_IsShow] forKey:CalendarItem_IsShow];
        [addItem setObject:[item objectForKey:CalendarItem_IsDefault] forKey:CalendarItem_IsDefault];
        [self addCalendarItem:addItem];
    }
}

//- (void)initEventStore
//{
//    if (_eventStore)
//        return;
//    
//    self.eventStore = [[EKEventStore alloc] init];
//    [_eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
//        if ( !granted) {
//            self.eventStore = nil;
//        }
//    }];
//}

- (void)prepare
{
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:[A3DaysCounterModelManager imagePath]] ) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[A3DaysCounterModelManager imagePath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:[A3DaysCounterModelManager thumbnailPath]] ) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[A3DaysCounterModelManager thumbnailPath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
//    self.calendarDict = [NSMutableDictionary dictionary];
    self.calendarColorArray = [NSMutableArray array];
    [_calendarColorArray addObject:@{CalendarItem_Color : [UIColor colorWithRed:1.0 green:41.0/255.0 blue:104.0/255.0 alpha:1.0],CalendarItem_Name : @"Red"}];
    [_calendarColorArray addObject:@{CalendarItem_Color : [UIColor colorWithRed:1.0 green:149.0/255.0 blue:0 alpha:1.0],CalendarItem_Name : @"Orange"}];
    [_calendarColorArray addObject:@{CalendarItem_Color : [UIColor colorWithRed:1.0 green:204.0/255.0 blue:0 alpha:1.0],CalendarItem_Name : @"Yellow"}];
    [_calendarColorArray addObject:@{CalendarItem_Color : [UIColor colorWithRed:99.0/255.0 green:218.0/255.0 blue:56.0/255.0 alpha:1.0],CalendarItem_Name : @"Green"}];
    [_calendarColorArray addObject:@{CalendarItem_Color : [UIColor colorWithRed:27.0/255.0 green:173.0/255.0 blue:248.0/255.0 alpha:1.0],CalendarItem_Name : @"Blue"}];
    [_calendarColorArray addObject:@{CalendarItem_Color : [UIColor colorWithRed:88.0/255.0 green:86.0/255.0 blue:214.0/255.0 alpha:1.0],CalendarItem_Name : @"Violet"}];
    [_calendarColorArray addObject:@{CalendarItem_Color : [UIColor colorWithRed:204.0/255.0 green:115.0/255.0 blue:225.0/255.0 alpha:1.0],CalendarItem_Name : @"Purple"}];
    [_calendarColorArray addObject:@{CalendarItem_Color : [UIColor colorWithRed:162.0/255.0 green:132.0/255.0 blue:94.0/255.0 alpha:1.0],CalendarItem_Name : @"Brown"}];
    [_calendarColorArray addObject:@{CalendarItem_Color : [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0],CalendarItem_Name : @"Gray"}];
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSUInteger count = [DaysCounterCalendar MR_countOfEntitiesWithContext:context];
    
    if ( count == 0 ) {
        [self addDefaultUserCalendarItems];
    }
    [self checkAndAddSystemCalendarItems];
    
//    [self initEventStore];
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
    NSString *retStr = @"";
    
    switch (repeatType) {
        case 0:
            retStr = @"Never";
            break;
        case -1:
            retStr = @"Every Day";
            break;
        case -2:
            retStr = @"Every Week";
            break;
        case -3:
            retStr = @"Every 2Week";
            break;
        case -4:
            retStr = @"Every Month";
            break;
        case -5:
            retStr = @"Every Year";
            break;
            
        default:
            retStr = [NSString stringWithFormat:@"%ld days", (long)repeatType];
            break;
    }
    
    return retStr;
}

- (NSString*)repeatTypeStringForDetailValue:(NSInteger)repeatType
{
    NSString *retStr = @"";
    
    switch (repeatType) {
        case 0:
            retStr = @"never";
            break;
        case -1:
            retStr = @"daily";
            break;
        case -2:
            retStr = @"weekly";
            break;
        case -3:
            retStr = @"2 week";
            break;
        case -4:
            retStr = @"monthly";
            break;
        case -5:
            retStr = @"yearly";
            break;
            
        default:
            retStr = [NSString stringWithFormat:@"%ld days", (long)repeatType];
            break;
    }
    
    return retStr;
}

- (NSString*)repeatEndDateStringFromDate:(id)date
{
    if ( [date isKindOfClass:[NSDate class]] )
        return [A3Formatter stringFromDate:date format:DaysCounterDefaultDateFormat];
    
    return @"Never";
}

- (NSString*)alertDateStringFromDate:(NSDate*)startDate alertDate:(id)date
{
    NSInteger alertType = [self alertTypeIndexFromDate:startDate alertDate:date];
    if ( alertType == AlertType_Custom ) {
        return [A3Formatter stringFromDate:date format:DaysCounterDefaultDateFormat];
    }
    
    return [self alertStringForType:alertType];
}

- (NSString*)alertStringForType:(NSInteger)alertType
{
    NSArray *array = @[@"None",@"At time of event",@"5 minutes before",@"15 minutes before",@"30 minutes before",@"1 hour before",@"2 hours before",@"1 day before",@"2 days before",@"1 week before"];
    
    if ( alertType < 0 || alertType >= AlertType_Custom )
        return @"";
    
    return [array objectAtIndex:alertType];
}

- (NSInteger)alertTypeIndexFromDate:(NSDate*)date alertDate:(id)alertDate
{
    if ( [alertDate isKindOfClass:[NSNull class]] || !date) {
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

- (NSString*)durationOptionStringFromValue:(NSInteger)value
{
    NSString *retStr = @"";
    
    if ( value & DurationOption_Year )
        retStr = [retStr stringByAppendingFormat:@"%@ Years", ([retStr length] > 0 ? @" " : @"")];
    if ( value & DurationOption_Month )
        retStr = [retStr stringByAppendingFormat:@"%@ Months", ([retStr length] > 0 ? @" " : @"")];
    if ( value & DurationOption_Week)
        retStr = [retStr stringByAppendingFormat:@"%@ Weeks", ([retStr length] > 0 ? @" " : @"")];
    if ( value & DurationOption_Day )
        retStr = [retStr stringByAppendingFormat:@"%@ Days", ([retStr length] > 0 ? @" " : @"")];
    if ( value & DurationOption_Hour)
        retStr = [retStr stringByAppendingFormat:@"%@ Hours", ([retStr length] > 0 ? @" " : @"")];
    if ( value & DurationOption_Minutes)
        retStr = [retStr stringByAppendingFormat:@"%@ Minutes", ([retStr length] > 0 ? @" " : @"")];
    if ( value & DurationOption_Seconds)
        retStr = [retStr stringByAppendingFormat:@"%@ Seconds", ([retStr length] > 0 ? @" " : @"")];
    
    return retStr;
}

- (NSString*)titleForCellType:(NSInteger)cellType
{
    NSArray *array = @[@"Title",@"Photo",@"Lunar",@"All-day",@"Starts-Ends",@"Starts",@"Ends",@"Repeat",@"End Repeat",@"Alert",@"Calendar",@"Duration Option",@"Location",@"Notes",@"Date Input"];
    if ( cellType < 0 || cellType >= [array count] )
        return @"";
    
    return [array objectAtIndex:cellType];
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

- (FSVenue*)fsvenueFromEventModel:(id)locationItem
{
    FSVenue *venue = [[FSVenue alloc] init];
    venue.name = [locationItem objectForKey:EventItem_LocationName];
    venue.contact = [locationItem objectForKey:EventItem_Contact];
    if ( [[locationItem objectForKey:EventItem_Latitude] isKindOfClass:[NSNumber class]] && [[locationItem objectForKey:EventItem_Longitude] isKindOfClass:[NSNumber class]])
        venue.location.coordinate = CLLocationCoordinate2DMake([[locationItem objectForKey:EventItem_Latitude] doubleValue], [[locationItem objectForKey:EventItem_Longitude] doubleValue]);
    venue.location.address = [locationItem objectForKey:EventItem_Address];
    venue.location.city = [locationItem objectForKey:EventItem_City];
    venue.location.state = [locationItem objectForKey:EventItem_State];
    venue.location.country = [locationItem objectForKey:EventItem_Country];
    
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

- (id)emptyEventModel
{
    DaysCounterCalendar *defaultCal = [self defaultCalendar];
    NSMutableDictionary *item = [NSMutableDictionary dictionary];
    [item setObject:[[NSUUID UUID] UUIDString] forKey:EventItem_ID];
    [item setObject:@"" forKey:EventItem_Name];
    [item setObject:@"" forKey:EventItem_ImageFilename];
    [item setObject:[NSNumber numberWithBool:NO] forKey:EventItem_IsLunar];
    [item setObject:[NSNumber numberWithBool:YES] forKey:EventItem_IsAllDay];
    [item setObject:[NSNumber numberWithBool:NO] forKey:EventItem_IsPeriod];
    [item setObject:[NSDate date] forKey:EventItem_StartDate];
    [item setObject:[NSNull null] forKey:EventItem_EndDate];
    [item setObject:[NSNumber numberWithInteger:0] forKey:EventItem_RepeatType];
    [item setObject:[NSNull null] forKey:EventItem_RepeatEndDate];
    [item setObject:[NSNull null] forKey:EventItem_AlertDatetime];
    [item setObject:(defaultCal ? defaultCal.calendarId : @"") forKey:EventItem_CalendarId];
    if ( defaultCal )
        [item setObject:defaultCal forKey:EventItem_Calendar];
    [item setObject:[NSNumber numberWithInteger:DurationOption_Day] forKey:EventItem_DurationOption];
    [item setObject:@"" forKey:EventItem_Notes];
    [item setObject:[NSNumber numberWithBool:NO] forKey:EventItem_IsFavorite];
    [item setObject:[NSNull null] forKey:EventItem_RegDate];
    
    return item;
}

- (id)emptyEventLocationModel
{
    NSMutableDictionary *item = [NSMutableDictionary dictionary];
    [item setObject:@"" forKey:EventItem_ID];
    [item setObject:[NSNull null] forKey:EventItem_Latitude];
    [item setObject:[NSNull null] forKey:EventItem_Longitude];
    [item setObject:@"" forKey:EventItem_Country];
    [item setObject:@"" forKey:EventItem_State];
    [item setObject:@"" forKey:EventItem_City];
    [item setObject:@"" forKey:EventItem_Address];
    [item setObject:@"" forKey:EventItem_LocationName];
    [item setObject:@"" forKey:EventItem_Contact];
    
    return item;
}


- (id)eventItemByID:(NSString*)eventId
{
    DaysCounterEvent *item = [DaysCounterEvent MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"eventId == %@",eventId] inContext:[self managedObjectContext]];
    return item;
}

- (EKAlarm*)createAlarmWithEvent:(DaysCounterEvent*)event
{
    NSTimeInterval interval = 0.0;
    NSInteger intervalType = [self alertTypeIndexFromDate:event.startDate alertDate:event.alertDatetime];
    switch (intervalType) {
        case AlertType_AtTimeOfEvent:
            interval = 0.0;
            break;
        case AlertType_5MinutesBefore:
            interval = 60.0 * 5;
            break;
        case AlertType_15MinutesBefore:
            interval = 60.0 * 15;
            break;
        case AlertType_30MinutesBefore:
            interval = 60.0 * 30;
            break;
        case AlertType_1HourBefore:
            interval = 60.0 * 60;
            break;
        case AlertType_2HoursBefore:
            interval = 60.0 * 120;
            break;
        case AlertType_1DayBefore:
            interval = 60.0 * 60 * 24;
            break;
        case AlertType_2DaysBefore:
            interval = 60.0 * 60 * 48;
            break;
        case AlertType_1WeekBefore:
            interval = 60.0 * 60 * 24 * 7;
            break;
    }
    
    EKAlarm *alarm = nil;
    if ( intervalType == AlertType_Custom )
        alarm = [EKAlarm alarmWithAbsoluteDate:event.alertDatetime];
    else
        alarm = [EKAlarm alarmWithRelativeOffset:-interval];
    return alarm;
}

- (EKRecurrenceRule*)createRecurrenceRuleWithEvent:(DaysCounterEvent*)event
{
    EKRecurrenceRule *rule = nil;
    if ( [event.repeatType integerValue] != RepeatType_Never ) {
        EKRecurrenceFrequency frequency;
        NSInteger interval = 1;
        switch ([event.repeatType integerValue]) {
            case RepeatType_EveryDay:
                frequency = EKRecurrenceFrequencyDaily;
                break;
            case RepeatType_EveryWeek:
                frequency = EKRecurrenceFrequencyWeekly;
                interval = 1;
                break;
            case RepeatType_Every2Week:
                frequency = EKRecurrenceFrequencyWeekly;
                interval = 2;
                break;
            case RepeatType_EveryMonth:
                frequency = EKRecurrenceFrequencyMonthly;
                break;
            case RepeatType_EveryYear:
                frequency = EKRecurrenceFrequencyYearly;
                break;
        }
        EKRecurrenceEnd *end = ( event.repeatEndDate ? [EKRecurrenceEnd recurrenceEndWithEndDate:event.repeatEndDate] : nil);
        rule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:frequency interval:interval end:end];
    }
    
    return rule;
}

- (EKEvent*)registerToEventStore:(DaysCounterEvent*)event
{
//    EKAlarm *alarm = [self createAlarmWithEvent:event];
//    EKEvent *calEvent = [EKEvent eventWithEventStore:_eventStore];
//    calEvent.calendar = [_eventStore defaultCalendarForNewEvents];
//    calEvent.title = event.eventName;
//    calEvent.startDate = event.startDate;
//    calEvent.endDate = (event.endDate ? event.endDate : event.startDate);
//    calEvent.allDay = [event.isAllDay boolValue];
//    [calEvent addAlarm:alarm];
//    
//    EKRecurrenceRule *rule = [self createRecurrenceRuleWithEvent:event];
//    
//    if ( rule )
//        [calEvent addRecurrenceRule:rule];
//    
//    NSError *error = nil;
//    if ( [_eventStore saveEvent:calEvent span:EKSpanThisEvent error:&error] )
//        return calEvent;
//    
//    NSLog(@"%s %@",__FUNCTION__,[error localizedDescription]);
    return nil;
}

- (EKReminder*)registerToReminder:(DaysCounterEvent*)event
{
//    EKAlarm *alarm = [self createAlarmWithEvent:event];
//    EKReminder *reminder = [EKReminder reminderWithEventStore:_eventStore];
//    reminder.calendar = [_eventStore defaultCalendarForNewReminders];
//    reminder.title = event.eventName;
//    reminder.dueDateComponents = [A3DateHelper dateComponentsFromDate:event.startDate unitFlags:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit];
//    [reminder addAlarm:alarm];
//    
//    EKRecurrenceRule *rule = [self createRecurrenceRuleWithEvent:event];
//    
//    if ( rule )
//        [reminder addRecurrenceRule:rule];
//    
//    NSError *error = nil;
//    if ([_eventStore saveReminder:reminder commit:YES error:&error]) {
//        NSLog(@"%s %@",__FUNCTION__,reminder);
//        return reminder;
//    }
    
    return nil;
}

- (BOOL)addEvent:(id)eventModel
{
    NSDictionary *item = (NSDictionary*)eventModel;
    
    NSString *eventID = [eventModel objectForKey:EventItem_ID];
    if ( [self eventItemByID:eventID] )
        return NO;
    
    // 이미지 저장
    UIImage *image = [eventModel objectForKey:EventItem_Image];
    NSString *imageFilename = @"";
    if ( image ) {
        NSData *imageData = UIImagePNGRepresentation(image);
        imageFilename = [NSString stringWithFormat:@"%@.png",eventID];
        [imageData writeToFile:[[A3DaysCounterModelManager imagePath] stringByAppendingPathComponent:imageFilename] atomically:YES];
        
        UIImage *thumbnail = [image scaleToFillSize:CGSizeMake(64.0, 64.0)];
        imageData = UIImagePNGRepresentation(thumbnail);
        [imageData writeToFile:[[A3DaysCounterModelManager thumbnailPath] stringByAppendingPathComponent:[A3DaysCounterModelManager thumbnailFilenameFromFilename:imageFilename]] atomically:YES];
    }

    DaysCounterEvent *addItem = [DaysCounterEvent MR_createInContext:[self managedObjectContext]];
    addItem.eventId = [item objectForKey:EventItem_ID];
    addItem.calendarId = [item objectForKey:EventItem_CalendarId];
    addItem.eventName = [item objectForKey:EventItem_Name];
    addItem.isLunar = [item objectForKey:EventItem_IsLunar];
    addItem.imageFilename = imageFilename;
    addItem.isAllDay = [item objectForKey:EventItem_IsAllDay];
    addItem.isPeriod = [item objectForKey:EventItem_IsPeriod];
    addItem.startDate = [item objectForKey:EventItem_StartDate];
    addItem.endDate = ( [[item objectForKey:EventItem_EndDate] isKindOfClass:[NSNull class]] ? nil : [item objectForKey:EventItem_EndDate] );
    addItem.repeatType = [item objectForKey:EventItem_RepeatType];
    addItem.repeatEndDate = ( [[item objectForKey:EventItem_RepeatEndDate] isKindOfClass:[NSNull class]] ? nil : [item objectForKey:EventItem_RepeatEndDate] );
    addItem.alertDatetime = ( [[item objectForKey:EventItem_AlertDatetime] isKindOfClass:[NSNull class]] ? nil : [item objectForKey:EventItem_AlertDatetime] );
    addItem.durationOption = [item objectForKey:EventItem_DurationOption];
    addItem.notes = [item objectForKey:EventItem_Notes];
    addItem.isFavorite = [item objectForKey:EventItem_IsFavorite];
    addItem.regDate = [NSDate date];
    addItem.calendar = [item objectForKey:EventItem_Calendar];
    
    if ( addItem.alertDatetime ) {
//        EKEvent *calEvent = [self registerToEventStore:addItem];
//        if ( calEvent )
//            addItem.eventKitId = calEvent.eventIdentifier;
//        EKReminder *reminder = [self registerToReminder:addItem];
//        if ( reminder )
//            addItem.eventKitId = reminder.calendarItemIdentifier;
    }
    
    NSDictionary *locItem = [item objectForKey:EventItem_Location];
    if ( locItem ) {
        DaysCounterEventLocation *location = [DaysCounterEventLocation MR_createInContext:addItem.managedObjectContext];
        location.eventId = eventID;
        location.latitude = [locItem objectForKey:EventItem_Latitude];
        location.longitude = [locItem objectForKey:EventItem_Longitude];
        location.address = [locItem objectForKey:EventItem_Address];
        location.city = [locItem objectForKey:EventItem_City];
        location.state = [locItem objectForKey:EventItem_State];
        location.country = [locItem objectForKey:EventItem_Country];
        location.locationName = [locItem objectForKey:EventItem_LocationName];
        location.contact = [locItem objectForKey:EventItem_Contact];
        location.event = addItem;
        addItem.location = location;
    }
    [[self managedObjectContext] MR_saveToPersistentStoreAndWait];
    
    return YES;
}

- (void)removeExistsEventImageFile:(NSString*)imageFilename
{
    NSString *thumbnailPath = [[A3DaysCounterModelManager thumbnailPath] stringByAppendingPathComponent:[A3DaysCounterModelManager thumbnailFilenameFromFilename:imageFilename]];
    NSString *imagePath = [[A3DaysCounterModelManager imagePath] stringByAppendingPathComponent:imageFilename];
    if ( [[NSFileManager defaultManager] fileExistsAtPath:thumbnailPath] )
        [[NSFileManager defaultManager] removeItemAtPath:thumbnailPath error:nil];
    if ( [[NSFileManager defaultManager] fileExistsAtPath:imagePath] )
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
}

- (BOOL)modifyEvent:(DaysCounterEvent*)eventItem withInfo:(NSDictionary*)info
{
    UIImage *image = [info objectForKey:EventItem_Image];
    NSString *imageFilename = @"";

    if ( image ) {
//        if ( [eventItem.imageFilename length] > 0 )
//            [self removeExistsEventImageFile:eventItem.imageFilename];
        NSData *imageData = UIImagePNGRepresentation(image);
        imageFilename = [NSString stringWithFormat:@"%@.png",eventItem.eventId];
        [imageData writeToFile:[[A3DaysCounterModelManager imagePath] stringByAppendingPathComponent:imageFilename] atomically:YES];
        
        UIImage *thumbnail = [image scaleToFillSize:CGSizeMake(64.0, 64.0)];
        imageData = UIImagePNGRepresentation(thumbnail);
        [imageData writeToFile:[[A3DaysCounterModelManager thumbnailPath] stringByAppendingPathComponent:[A3DaysCounterModelManager thumbnailFilenameFromFilename:imageFilename]] atomically:YES];
        eventItem.imageFilename = imageFilename;
    }
    else if ( [eventItem.imageFilename length] > 0 ) {
        [self removeExistsEventImageFile:eventItem.imageFilename];
        eventItem.imageFilename = nil;
    }
    
    eventItem.eventName = [info objectForKey:EventItem_Name];
    eventItem.calendarId = [info objectForKey:EventItem_CalendarId];
    eventItem.calendar = [info objectForKey:EventItem_Calendar];
    eventItem.isLunar = [info objectForKey:EventItem_IsLunar];
    eventItem.isAllDay = [info objectForKey:EventItem_IsAllDay];
    eventItem.isPeriod = [info objectForKey:EventItem_IsPeriod];
    eventItem.startDate = [info objectForKey:EventItem_StartDate];
    eventItem.endDate = ( [[info objectForKey:EventItem_EndDate] isKindOfClass:[NSNull class]] ? nil : [info objectForKey:EventItem_EndDate] );
    eventItem.repeatType = [info objectForKey:EventItem_RepeatType];
    eventItem.repeatEndDate = ( [[info objectForKey:EventItem_RepeatEndDate] isKindOfClass:[NSNull class]] ? nil : [info objectForKey:EventItem_RepeatEndDate] );
    eventItem.alertDatetime = ( [[info objectForKey:EventItem_AlertDatetime] isKindOfClass:[NSNull class]] ? nil : [info objectForKey:EventItem_AlertDatetime] );
    eventItem.durationOption = [info objectForKey:EventItem_DurationOption];
    eventItem.notes = [info objectForKey:EventItem_Notes];
    eventItem.isFavorite = [info objectForKey:EventItem_IsFavorite];
    
    // 기존 alert 수정 또는 추가
//    EKEvent *calEvent = nil;
//    EKReminder *reminder = nil;
//    if ( [eventItem.eventKitId length] > 0 ) {
//        calEvent = [_eventStore eventWithIdentifier:eventItem.eventKitId];
////        reminder = (EKReminder*)[_eventStore calendarItemWithIdentifier:eventItem.eventKitId];
//        if ( calEvent ) {
////        if ( reminder ) {
//            if ( [calEvent.alarms count] > 0 ) {
//                NSArray *removeArray = [NSArray arrayWithArray:calEvent.alarms];
//                for (EKAlarm *alarm in removeArray)
//                    [calEvent removeAlarm:alarm];
//            }
//
//            if ( eventItem.alertDatetime ) {
//                EKAlarm *alarm = [self createAlarmWithEvent:eventItem];
//                if ( alarm )
//                    [calEvent addAlarm:alarm];
//            }
//            else {
////                [_eventStore removeReminder:reminder commit:YES error:nil];
//                [_eventStore removeEvent:calEvent span:EKSpanFutureEvents commit:YES error:nil];
//            }
//        }
//    }
//    else if ( eventItem.alertDatetime ) {
//        calEvent = [self registerToEventStore:eventItem];
//        if ( calEvent )
//            eventItem.eventKitId = calEvent.calendarItemIdentifier;
////        reminder = [self registerToReminder:eventItem];
////        if ( reminder )
////            eventItem.eventKitId = reminder.calendarItemIdentifier;
//    }
    
    NSDictionary *locItem = [info objectForKey:EventItem_Location];
    if ( locItem ) {
        DaysCounterEventLocation *location = nil;
        if ( eventItem.location ) {
            location = eventItem.location;
        }
        else {
            location = [DaysCounterEventLocation MR_createInContext:eventItem.managedObjectContext];
            location.eventId = eventItem.eventId;
            eventItem.location = location;
        }
        location.latitude = [locItem objectForKey:EventItem_Latitude];
        location.longitude = [locItem objectForKey:EventItem_Longitude];
        location.address = [locItem objectForKey:EventItem_Address];
        location.city = [locItem objectForKey:EventItem_City];
        location.state = [locItem objectForKey:EventItem_State];
        location.country = [locItem objectForKey:EventItem_Country];
        location.locationName = [locItem objectForKey:EventItem_LocationName];
        location.contact = [locItem objectForKey:EventItem_Contact];
        location.event = eventItem;
    }
    else if ( eventItem.location ) {
       [eventItem.location MR_deleteEntity];
    }
//    [eventItem.managedObjectContext MR_saveToPersistentStoreAndWait];
	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    
    return YES;
}

- (BOOL)removeEvent:(DaysCounterEvent *)eventItem
{
    // event store에 설정된 값도 삭제한다.
//    if ( [eventItem.eventKitId length] > 0 ) {
//        EKEvent *calEvent = [_eventStore eventWithIdentifier:eventItem.eventKitId];
//        if ( calEvent ) {
//            [_eventStore removeEvent:calEvent span:EKSpanFutureEvents commit:YES error:nil];
//        }
////        EKReminder *reminder = (EKReminder*)[_eventStore calendarItemWithIdentifier:eventItem.eventKitId];
////        if ( reminder )
////            [_eventStore removeReminder:reminder commit:YES error:nil];
//    }
    [eventItem MR_deleteEntity];
//    [eventItem.managedObjectContext MR_saveToPersistentStoreAndWait];
	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    
    return YES;
}

- (NSMutableDictionary *)dictionaryFromEventEntity:(DaysCounterEvent*)item
{
    NSMutableDictionary *dict = [self emptyEventModel];
    [dict setObject:item.eventId forKey:EventItem_ID];
    [dict setObject:item.eventName forKey:EventItem_Name];
    
    if ( [item.imageFilename length] > 0 ) {
        [dict setObject:item.imageFilename forKey:EventItem_ImageFilename];
        UIImage *image = [A3DaysCounterModelManager photoThumbnailFromFilename:item.imageFilename];
        if ( image ) {
            [dict setObject:[A3DaysCounterModelManager circularScaleNCrop:image rect:CGRectMake(0, 0, image.size.width, image.size.height)] forKey:EventItem_Thumbnail];
        }
        image = [A3DaysCounterModelManager photoImageFromFilename:item.imageFilename];
        
        if ( image ) {
            [dict setObject:image forKey:EventItem_Image];
        }
    }
    [dict setObject:item.isLunar forKey:EventItem_IsLunar];
    [dict setObject:item.isAllDay forKey:EventItem_IsAllDay];
    [dict setObject:item.isPeriod forKey:EventItem_IsPeriod];
    [dict setObject:item.startDate forKey:EventItem_StartDate];
    
    if ( item.endDate ) {
        [dict setObject:item.endDate forKey:EventItem_EndDate];
    }
    [dict setObject:item.repeatType forKey:EventItem_RepeatType];
    
    if ( item.repeatEndDate ) {
        [dict setObject:item.repeatEndDate forKey:EventItem_RepeatEndDate];
    }
    if ( item.alertDatetime ) {
        [dict setObject:item.alertDatetime forKey:EventItem_AlertDatetime];
    }
    if ( [item.calendarId length] > 0 ) {
        [dict setObject:item.calendarId forKey:EventItem_CalendarId];
    }
    if ( item.calendar ) {
        [dict setObject:item.calendar forKey:EventItem_Calendar];
    }
    [dict setObject:item.durationOption forKey:EventItem_DurationOption];
    
    if ( [item.notes length] > 0 ) {
        [dict setObject:item.notes forKey:EventItem_Notes];
    }
    [dict setObject:item.isFavorite forKey:EventItem_IsFavorite];
    [dict setObject:item.regDate forKey:EventItem_RegDate];
    
    if ( item.location ) {
        [dict setObject:[self dictionaryFromEventLocationEntity:item.location] forKey:EventItem_Location];
    }
    
    return dict;
}

- (NSMutableDictionary *)dictionaryFromEventLocationEntity:(DaysCounterEventLocation*)location
{
    NSMutableDictionary *item = [self emptyEventLocationModel];
    [item setObject:location.eventId forKey:EventItem_ID];
    [item setObject:location.latitude forKey:EventItem_Latitude];
    [item setObject:location.longitude forKey:EventItem_Longitude];
    if ( [location.country length] > 0 )
        [item setObject:location.country forKey:EventItem_Country];
    if ( [location.state length] > 0 )
        [item setObject:location.state forKey:EventItem_State];
    if ( [location.city length] > 0 )
        [item setObject:location.city forKey:EventItem_City];
    if ( [location.address length] > 0 )
        [item setObject:location.address forKey:EventItem_Address];
    if ( [location.locationName length] > 0 )
        [item setObject:location.locationName forKey:EventItem_LocationName];
    if ( [location.contact length] > 0 )
        [item setObject:location.contact forKey:EventItem_Contact];
    return item;
}

- (NSMutableArray*)visibleCalendarList
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSArray *result = [DaysCounterCalendar MR_findAllSortedBy:@"order" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"isShow == %@",[NSNumber numberWithBool:YES]] inContext:context];
    
    return [NSMutableArray arrayWithArray:result];
}

- (NSMutableArray*)allCalendarList
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSArray *result = [DaysCounterCalendar MR_findAllSortedBy:@"order" ascending:YES inContext:context];
    
    return [NSMutableArray arrayWithArray:result];
}

- (NSMutableArray*)allUserCalendarList
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSArray *result = [DaysCounterCalendar MR_findAllSortedBy:@"order" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"calendarType == %@",[NSNumber numberWithInteger:CalendarCellType_User]] inContext:context];
    
    return [NSMutableArray arrayWithArray:result];
}

- (NSMutableDictionary *)itemForNewUserCalendar
{
    NSMutableDictionary *item = [NSMutableDictionary dictionary];
    
    [item setObject:[[NSUUID UUID] UUIDString]  forKey:CalendarItem_ID];
    [item setObject:@"" forKey:CalendarItem_Name];
    [item setObject:@(YES) forKey:CalendarItem_IsShow];
    [item setObject:@(CalendarCellType_User) forKey:CalendarItem_Type];
    [item setObject:DEFAULT_CALENDAR_COLOR forKey:CalendarItem_Color];
    [item setObject:[NSNumber numberWithInteger:0] forKey:CalendarItem_NumberOfEvents];
    
    return item;
}

- (id)calendarItemByID:(NSString*)calendarId
{
    return [DaysCounterCalendar MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"calendarId == %@",calendarId] inContext:[self managedObjectContext]];
}

- (BOOL)removeCalendarItem:(NSMutableDictionary*)item
{
    DaysCounterCalendar *removeItem = [self calendarItemByID:[item objectForKey:CalendarItem_ID]];
    
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
    DaysCounterCalendar *removeItem = [self calendarItemByID:calendarID];
    
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

- (BOOL)addCalendarItem:(NSDictionary*)item
{
    if ( [self calendarItemByID:[item objectForKey:CalendarItem_ID]] )
        return NO;
    
    NSUInteger numberOfItems = [DaysCounterCalendar MR_countOfEntitiesWithContext:[self managedObjectContext]];
    // save to core data storage
    DaysCounterCalendar *calendar = [DaysCounterCalendar MR_createInContext:[self managedObjectContext]];
    calendar.calendarId = [item objectForKey:CalendarItem_ID];
    calendar.calendarName = [item objectForKey:CalendarItem_Name];
    calendar.calendarColor = [NSKeyedArchiver archivedDataWithRootObject:[item objectForKey:CalendarItem_Color]];
    calendar.isShow = [item objectForKey:CalendarItem_IsShow];
    calendar.calendarType = [item objectForKey:CalendarItem_Type];
    calendar.order = [NSNumber numberWithInteger:numberOfItems+1];
    calendar.isDefault = [item objectForKey:CalendarItem_IsDefault];
    
    [calendar.managedObjectContext MR_saveToPersistentStoreAndWait];
    
    return YES;
}


- (BOOL)updateCalendarItem:(NSMutableDictionary*)item
{
    DaysCounterCalendar *existsCalendar = [self calendarItemByID:[item objectForKey:CalendarItem_ID]];

    if (existsCalendar == nil )
        return NO;

    existsCalendar.calendarColor = [NSKeyedArchiver archivedDataWithRootObject:[item objectForKey:CalendarItem_Color]];
    existsCalendar.calendarName = [item objectForKey:CalendarItem_Name];
    existsCalendar.isShow = [item objectForKey:CalendarItem_IsShow];
    
    [existsCalendar.managedObjectContext  MR_saveToPersistentStoreAndWait];
    
    return YES;
}

- (NSArray*)calendarColorList
{
    return [NSArray arrayWithArray:_calendarColorArray];
}

- (NSInteger)numberOfAllEvents
{
    return [DaysCounterEvent MR_countOfEntities];
}

- (NSInteger)numberOfUpcomingEventsWithDate:(NSDate*)date
{
//    return [DaysCounterEvent MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"startDate > %@",date] inContext:[self managedObjectContext]];
    return [DaysCounterEvent MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"startDate > %@ || repeatEndDate > %@ || (repeatType != %@ && repeatEndDate == %@)", date, date, @(RepeatType_Never), [NSNull null]] inContext:[self managedObjectContext]];
}

- (NSInteger)numberOfPastEventsWithDate:(NSDate*)date
{
//    return [DaysCounterEvent MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"startDate < %@", date] inContext:[self managedObjectContext]];
    return [DaysCounterEvent MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"(startDate < %@ && repeatType == %@) || (repeatEndDate != %@ && repeatEndDate < %@)", date, @(RepeatType_Never), [NSNull null], date] inContext:[self managedObjectContext]];
}

- (NSInteger)numberOfUserCalendarVisible
{
    return [DaysCounterCalendar MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"isShow == %@ and calendarType == %@",[NSNumber numberWithBool:YES],[NSNumber numberWithInteger:CalendarCellType_User]] inContext:[self managedObjectContext]];
}

- (NSInteger)numberOfEventContainedImage
{
    return [DaysCounterEvent MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"imageFilename.length > 0"] inContext:[self managedObjectContext]];
}

- (NSDate*)dateOfLatestEvent
{
    DaysCounterEvent *event = [DaysCounterEvent MR_findFirstOrderedByAttribute:@"regDate" ascending:NO inContext:[self managedObjectContext]];
    if ( event == nil )
        return nil;
    
    return event.regDate;
}

- (DaysCounterCalendar*)defaultCalendar
{
    
    DaysCounterCalendar *defaultCalendar = [DaysCounterCalendar MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"isDefault == %@",[NSNumber numberWithBool:YES]] inContext:[self managedObjectContext]];
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
    return [DaysCounterEvent MR_findAllInContext:[self managedObjectContext]];
}

- (NSArray*)allEventsListContainedImage
{
    return [DaysCounterEvent MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"imageFilename.length > 0"] inContext:[self managedObjectContext]];
}

- (NSArray*)upcomingEventsListWithDate:(NSDate*)date
{
//    return [DaysCounterEvent MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"startDate > %@",date] inContext:[self managedObjectContext]];
    return [DaysCounterEvent MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"startDate > %@ || repeatEndDate > %@ || (repeatType != %@ && repeatEndDate == %@)", date, date, @(RepeatType_Never), [NSNull null]]
                                           inContext:[self managedObjectContext]];
}

- (NSArray*)pastEventsListWithDate:(NSDate*)date
{
//    return [DaysCounterEvent MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"startDate < %@",date] inContext:[self managedObjectContext]];
    return [DaysCounterEvent MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(startDate < %@ && repeatType == %@) || (repeatEndDate != %@ && repeatEndDate < %@)", date, @(RepeatType_Never), [NSNull null], date]
                                           inContext:[self managedObjectContext]];
}

- (NSArray*)favoriteEventsList
{
    return [DaysCounterEvent MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"isFavorite ==  %@",[NSNumber numberWithBool:YES]] inContext:[self managedObjectContext]];
}

- (NSArray*)reminderList
{
    return [DaysCounterEvent MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"alertDatetime !=  %@",[NSNull null]] inContext:[self managedObjectContext]];
}


- (NSDate*)nextDateWithRepeatOption:(NSInteger)repeatType firstDate:(NSDate*)firstDate fromDate:(NSDate*)fromDate
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

- (NSString*)stringOfDurationOption:(NSInteger)option fromDate:(NSDate*)fromDate toDate:(NSDate*)toDate isAllDay:(BOOL)isAllDay
{
    if ( toDate == nil || fromDate == nil) {
		return @"";
    }
    
    NSDate *smallDate = fromDate;
    NSDate *largeDate = toDate;
    
    if ( [fromDate timeIntervalSince1970] > [toDate timeIntervalSince1970] ) {
        largeDate = fromDate;
        smallDate = toDate;
    }
    
    NSUInteger flag = 0;
    if ( option & DurationOption_Seconds) {
        flag |= NSSecondCalendarUnit;
    }
    if ( option & DurationOption_Minutes) {
        flag |= NSMinuteCalendarUnit;
    }
    if ( option & DurationOption_Hour ) {
        flag |= NSHourCalendarUnit;
    }
    if ( option & DurationOption_Day ) {
        flag |= NSDayCalendarUnit;
    }
    if ( option & DurationOption_Week ) {
        flag |= NSWeekCalendarUnit;
    }
    if ( option & DurationOption_Month ) {
        flag |= NSMonthCalendarUnit;
    }
    if ( option & DurationOption_Year ) {
        flag |= NSYearCalendarUnit;
    }
    
    // DurationOption 이 day 이상인 경우에 대한 예외처리. (하루가 안 되는 기간은 0day가 아닌 시분초를 출력함), (또한 hms 에 대한 옵션이 없는 경우만 해당함.)
    if ( (([largeDate timeIntervalSince1970] - [smallDate timeIntervalSince1970]) < 86400) &&
         (!(flag & NSHourCalendarUnit) && !(flag & NSMinuteCalendarUnit) && !(flag & NSSecondCalendarUnit)) &&
        !isAllDay ) {
        flag = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        option = DurationOption_Seconds | DurationOption_Minutes | DurationOption_Hour;
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
    if ( option & DurationOption_Year && [diffComponent year] != 0) {
        [resultArray addObject:[NSString stringWithFormat:@"%ld year%@", (long)labs([diffComponent year]), (labs([diffComponent year]) > 1 ? @"s" : @"")]];
    }
    if ( option & DurationOption_Month && [diffComponent month] != 0) {
        [resultArray addObject:[NSString stringWithFormat:@"%ld month%@", (long)labs([diffComponent month]), (labs([diffComponent month]) > 1 ? @"s" : @"")]];
    }
    if ( option & DurationOption_Week && [diffComponent week] != 0) {
        [resultArray addObject:[NSString stringWithFormat:@"%ld week%@", (long)labs([diffComponent week]), (labs([diffComponent week]) > 1 ? @"s" : @"")]];
    }
    if (option & DurationOption_Day && [diffComponent day] != 0) {
        [resultArray addObject:[NSString stringWithFormat:@"%ld day%@", (long)labs([diffComponent day]), (labs([diffComponent day]) > 1 ? @"s" : @"")]];
    }
    
    if (!isAllDay) {
        if (option & DurationOption_Hour && [diffComponent hour] != 0) {
            [resultArray addObject:[NSString stringWithFormat:@"%ld hour%@", (long)labs([diffComponent hour]), (labs([diffComponent hour]) > 1 ? @"s" : @"")]];
        }
        if (option & DurationOption_Minutes && [diffComponent minute] != 0) {
            [resultArray addObject:[NSString stringWithFormat:@"%ld minute%@", (long)labs([diffComponent minute]), (labs([diffComponent minute]) > 1 ? @"s" : @"")]];
        }
        if (option & DurationOption_Seconds && [diffComponent second] != 0) {
            [resultArray addObject:[NSString stringWithFormat:@"%ld second%@", (long)labs([diffComponent second]), (labs([diffComponent second]) > 1 ? @"s" : @"")]];
        }
    }


//    if ([resultArray count] == 0) {
//        NSDateComponents *fullComponent = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit
//                                                      fromDate:smallDate
//                                                        toDate:largeDate
//                                                       options:0];
//
//        if ( [fullComponent year] > 0 ) {
//            [resultArray addObject:[NSString stringWithFormat:@"%ld year%@", (long)[fullComponent year], ([fullComponent year] > 1 ? @"s" : @"")]];
//        }
//        else if ( [fullComponent month] > 0 ) {
//            [resultArray addObject:[NSString stringWithFormat:@"%ld month%@", (long)[fullComponent month], ([fullComponent month] > 1 ? @"s" : @"")]];
//        }
////        else if ( [fullComponent week] > 0 ) {
////            [resultArray addObject:[NSString stringWithFormat:@"%@%dweek%@", [fullComponent week], ([fullComponent week] > 1 ? @"s" : @"")];
////        }
//        else if ( [fullComponent day] > 0 ) {
//            [resultArray addObject:[NSString stringWithFormat:@"%ld day%@", (long)[fullComponent day], ([fullComponent day] > 1 ? @"s" : @"")]];
//        }
//        
//        if ( isAllDay ) {
//            NSInteger hour = [fullComponent hour];
//            NSInteger minute = [fullComponent minute];
//            NSInteger second = [fullComponent second];
//            
//            if ( hour > 0 || minute > 0 || second > 0 ) {
//                [resultArray addObject:[NSString stringWithFormat:@"0 day"]];
//            }
//        }
//        else {
//            if ( [fullComponent hour] > 0 ) {
//                [resultArray addObject:[NSString stringWithFormat:@"%ld hour%@", (long)[fullComponent hour], ([fullComponent hour] > 1 ? @"s" : @"")]];
//            }
//            else if ( [fullComponent minute] > 0 ) {
//                [resultArray addObject:[NSString stringWithFormat:@"%ld minute%@", (long)[fullComponent minute], ([fullComponent minute] > 1 ? @"s" : @"")]];
//            }
//            else if ( [fullComponent second] > 0 ) {
//                [resultArray addObject:[NSString stringWithFormat:@"%ld second%@", (long)[fullComponent second], ([fullComponent second] > 1 ? @"s" : @"")]];
//            }
//        }
//    }
    
    NSString *result = [resultArray componentsJoinedByString:@" "];
    return result;
}

- (NSString*)stringForSlideshowTransitionType:(NSInteger)type
{
    NSArray *names = @[@"Cube",@"Dissolve",@"Origami",@"Ripple",@"Wipe"];
    if ( type < 0 || type > TransitionType_Wipe )
        return @"";
    
    return [names objectAtIndex:type];
}

- (void)setupEventSummaryInfo:(DaysCounterEvent*)item toView:(UIView*)toView
{
    A3DaysCounterSlideshowEventSummaryView *categoryCell = (A3DaysCounterSlideshowEventSummaryView *)toView;
//    CGFloat daysFontAscenderLine = roundf(categoryCell.dayCountLabel.frame.origin.y + categoryCell.dayCountLabel.font.ascender);
//    categoryCell.daysSinceTopSpaceConst.constant = daysFontAscenderLine + categoryCell.daysSinceLabel.font.ascender;
//    categoryCell.dayCountTopSpaceConst.constant = daysFontAscenderLine + categoryCell.daysSinceLabel.font.ascender;
//    categoryCell.daysSinceTopSpaceConst.constant = categoryCell.dayCountTopSpaceConst.constant;
    if (IS_IPAD) {
        categoryCell.daysSinceTopSpaceConst.constant = 57;
        categoryCell.titleLeadingSpaceConst.constant = 28;
        categoryCell.titleTrailingSpaceConst.constant = 28;
    }
    else {
        categoryCell.titleLeadingSpaceConst.constant = 15;
        categoryCell.titleTrailingSpaceConst.constant = 15;
    }
    
    
    UIImageView *bgImageView = (UIImageView*)[toView viewWithTag:10];
    FXLabel *daysLabel = (FXLabel*)[toView viewWithTag:11];
    FXLabel *markLabel = (FXLabel*)[toView viewWithTag:12];
    FXLabel *dateLabel = (FXLabel*)[toView viewWithTag:13];
    FXLabel *titleLabel = (FXLabel*)[toView viewWithTag:14];
    
    titleLabel.font = [UIFont systemFontOfSize:(IS_IPHONE ? 23.0 : 24.0)];
    titleLabel.text = item.eventName;
    titleLabel.shadowOffset = CGSizeMake(0, 1);
    titleLabel.shadowBlur = 2;
    
    daysLabel.shadowOffset = CGSizeMake(0,1);
    daysLabel.shadowBlur = 2;
    
    markLabel.shadowOffset = CGSizeMake(0,1);
    markLabel.shadowBlur = 2;
    
    dateLabel.shadowOffset = CGSizeMake(0,1);
    dateLabel.shadowBlur = 2;

    dateLabel.font = [UIFont systemFontOfSize:(IS_IPHONE ? 18.0 : 21.0)];
    dateLabel.text = [A3DateHelper dateStringFromDate:item.startDate withFormat:@"EEEE, MMMM dd, yyyy"];
    
    NSInteger diffDays = [A3DateHelper diffDaysFromDate:[NSDate date] toDate:item.startDate];
    if ( diffDays > 0 ) {
        markLabel.text = @"Days\nUntil";
    }
    else if ( diffDays < 0 ) {
        markLabel.text = @"Days\nSince";
    }
    markLabel.font = [UIFont systemFontOfSize:(IS_IPHONE ? 13.0 : 14.0)];
    
    if ( IS_IPHONE ) {
        if ( ABS(diffDays) > 9999 ) {
            daysLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-UltraLightP2" size:84.0];
        }
        else {
            daysLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-UltraLightP2" size:88.0];
        }
    }
    else {
        daysLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-UltraLightP2" size:116.0];
    }
    daysLabel.text = [NSString stringWithFormat:@"%ld", (long)ABS(diffDays)];
    if ( [item.imageFilename length] > 0 ) {
//        NSLog(@"%s %@",__FUNCTION__,NSStringFromCGRect(toView.frame));
        UIImage *image = [A3DaysCounterModelManager photoImageFromFilename:item.imageFilename];
//        image = [image scaleToCoverSize:toView.frame.size];
        bgImageView.image = image;//[A3DaysCounterModelManager resizeImage:image toSize:toView.frame.size isFill:YES backgroundColor:[UIColor blackColor]];
    }
    else {
        bgImageView.image = nil;
    }

    for (NSLayoutConstraint *layout in toView.constraints) {
        if ( layout.firstItem ==markLabel && layout.secondItem == daysLabel && layout.firstAttribute == NSLayoutAttributeLeading && layout.secondAttribute == NSLayoutAttributeTrailing ) {
            layout.constant = (IS_IPAD ? 10.0 : 5.0);
        }
    }
}

- (NSString*)stringForShareEvent:(DaysCounterEvent*)event
{
    NSString *retStr = event.eventName;
    
    retStr = [retStr stringByAppendingFormat:@"\nStart : %@%@",[A3DateHelper dateStringFromDate:event.startDate withFormat:@"EEEE, MMMM dd, yyyy"], ([event.isLunar boolValue] ? @"(lunar)" : @"")];
    if ( event.endDate )
        retStr = [retStr stringByAppendingFormat:@"\nEnd : %@%@",[A3DateHelper dateStringFromDate:event.endDate withFormat:@"EEEE, MMMM dd, yyyy"], ([event.isLunar boolValue] ? @"(lunar)" : @"")];
    if ( [event.repeatType integerValue] != RepeatType_Never )
        retStr = [retStr stringByAppendingFormat:@"\nRepeat : %@",[self repeatTypeStringFromValue:[event.repeatType integerValue]]];
    if ( event.location )
        retStr = [retStr stringByAppendingFormat:@"\nLocation : %@",event.location.locationName];
    
    return retStr;
}

- (BOOL)isSupportLunar
{
    NSString *locale = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    if ( [locale	isEqualToString:@"KR"] || [locale isEqualToString:@"CN"] || [locale isEqualToString:@"TW"] || [locale isEqualToString:@"HK"] || [locale isEqualToString:@"MO"] )
        return YES;
    
    return NO;
}

- (NSString*)dateFormatForAddEditIsAllDays:(BOOL)isAllDays
{
    NSString *retFormat = DaysCounterDefaultDateFormat;
    BOOL isLocaleKorea = [A3DateHelper isCurrentLocaleIsKorea];
    
    if ( IS_IPHONE ) {
        if ( isLocaleKorea ) {
            retFormat = ( isAllDays ? @"yyyy년 MMMM d일" : @"yyyy. MM. d (EEE) a h:mm");
        }
        else {
            retFormat = ( isAllDays ? @"EEE, MMM d, yyyy" : @"EEE, MMM d, yyyy h:mm a");
        }
    }
    else {
        if ( isLocaleKorea ) {
            retFormat = ( isAllDays ? @"yyyy년 MMMM d일 EEEE" : @"yyyy년 MMMM d일 EEEE a h:mm");
        }
        else {
            retFormat = ( isAllDays ? @"EEEE, MMMM d, yyyy" : @"EEEE, MMMM d, yyyy h:mm a");
        }
    }
    
    return retFormat;
}

- (NSString*)dateFormatForDetailIsAllDays:(BOOL)isAllDays
{
    NSString *retFormat = DaysCounterDefaultDateFormat;
    BOOL isLocaleKorea = [A3DateHelper isCurrentLocaleIsKorea];
    
    if ( IS_IPHONE ) {
        if ( isLocaleKorea ) {
            retFormat = ( isAllDays ? @"yyyy년 MMMM d일(EEE)" : @"yyyy년 MMMM d일(EEE) a h:mm");
        }
        else {
            retFormat = ( isAllDays ? @"EEEE, MMM d, yyyy" : @"EEEE, MMM d, yyyy h:mm a");
        }
    }
    else {
        if ( isLocaleKorea ) {
            retFormat = ( isAllDays ? @"yyyy년 MMMM d일 EEEE" : @"yyyy년 MMMM d일 EEEE a h:mm");
        }
        else {
            retFormat = ( isAllDays ? @"EEEE, MMMM d, yyyy" : @"EEEE, MMMM d, yyyy h:mm a");
        }
    }
    
    return retFormat;
}

@end
