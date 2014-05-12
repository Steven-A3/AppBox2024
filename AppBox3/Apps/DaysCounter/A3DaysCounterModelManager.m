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
#import "DaysCounterDateModel.h"
#import "NYXImagesKit.h"
#import "A3DateHelper.h"
#import "A3UserDefaults.h"
//#import "FXLabel.h"
#import "A3DaysCounterSlideshowEventSummaryView.h"
#import "NSDate+LunarConverter.h"
#import "NSDateFormatter+LunarDate.h"
#import "NSDateFormatter+A3Addition.h"
#import "A3AppDelegate.h"

#define DEFAULT_CALENDAR_COLOR      [UIColor colorWithRed:1.0 green:41.0/255.0 blue:104.0/255.0 alpha:1.0]

static A3DaysCounterModelManager *daysCounterModelManager = nil;

@interface A3DaysCounterModelManager ()
@property (strong, nonatomic) NSMutableArray *calendarColorArray;

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
                                                             [NSMutableDictionary dictionaryWithDictionary:@{ CalendarItem_ID:@"1", CalendarItem_Name : @"Anniversary", CalendarItem_Color : [UIColor colorWithRed:1.0 green:41.0/255.0 blue:104.0/255.0 alpha:1.0], CalendarItem_IsShow : [NSNumber numberWithBool:YES], CalendarItem_Type : [NSNumber numberWithInteger:CalendarCellType_User], CalendarItem_IsDefault : [NSNumber numberWithBool:YES]}],
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
    [_calendarColorArray addObject:@{ CalendarItem_Color : [UIColor colorWithRed:1.0 green:41.0/255.0 blue:104.0/255.0 alpha:1.0], CalendarItem_Name : @"Red" }];
    [_calendarColorArray addObject:@{ CalendarItem_Color : [UIColor colorWithRed:1.0 green:149.0/255.0 blue:0 alpha:1.0], CalendarItem_Name : @"Orange" }];
    [_calendarColorArray addObject:@{ CalendarItem_Color : [UIColor colorWithRed:1.0 green:204.0/255.0 blue:0 alpha:1.0], CalendarItem_Name : @"Yellow" }];
    [_calendarColorArray addObject:@{ CalendarItem_Color : [UIColor colorWithRed:99.0/255.0 green:218.0/255.0 blue:56.0/255.0 alpha:1.0], CalendarItem_Name : @"Green" }];
    [_calendarColorArray addObject:@{ CalendarItem_Color : [UIColor colorWithRed:27.0/255.0 green:173.0/255.0 blue:248.0/255.0 alpha:1.0], CalendarItem_Name : @"Blue" }];
    [_calendarColorArray addObject:@{ CalendarItem_Color : [UIColor colorWithRed:88.0/255.0 green:86.0/255.0 blue:214.0/255.0 alpha:1.0], CalendarItem_Name : @"Violet" }];
    [_calendarColorArray addObject:@{ CalendarItem_Color : [UIColor colorWithRed:204.0/255.0 green:115.0/255.0 blue:225.0/255.0 alpha:1.0], CalendarItem_Name : @"Purple" }];
    [_calendarColorArray addObject:@{ CalendarItem_Color : [UIColor colorWithRed:162.0/255.0 green:132.0/255.0 blue:94.0/255.0 alpha:1.0], CalendarItem_Name : @"Brown" }];
    [_calendarColorArray addObject:@{ CalendarItem_Color : [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0], CalendarItem_Name : @"Gray" }];
    
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
    if ( date ) {
        return [A3Formatter stringFromDate:date format:DaysCounterDefaultDateFormat];
    }
    
    return @"Never";
}

- (NSString*)alertDateStringFromDate:(NSDate*)startDate alertDate:(id)date
{
    NSInteger alertType = [self alertTypeIndexFromDate:startDate alertDate:date];
    if (alertType == AlertType_Custom) {
        //return [A3Formatter stringFromDate:date format:DaysCounterDefaultDateFormat];
        NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:date toDate:startDate options:0];
        return [NSString stringWithFormat:@"%ld %@", (long)comp.day, comp.day > 1 ? @"days before" : @"day before"];
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
    if ( [alertDate isKindOfClass:[NSNull class]] || !date || !alertDate) {
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
    
    NSString *retStr = @"";
    NSMutableArray *resultOptionStrings = [NSMutableArray new];
    if ( option & DurationOption_Year ) {
        [resultOptionStrings addObject: isShortType ? @"y" : @"Years"];
    }
    if ( option & DurationOption_Month ) {
        [resultOptionStrings addObject: isShortType ? @"m" : @"Months"];
    }
    if ( option & DurationOption_Week ) {
        [resultOptionStrings addObject: isShortType ? @"w" : @"Months"];
    }
    if ( option & DurationOption_Day ) {
        [resultOptionStrings addObject: isShortType ? @"d" : @"Days"];
    }
    if ( option & DurationOption_Hour ) {
        [resultOptionStrings addObject: isShortType ? @"hr" : @"Hours"];
    }
    if ( option & DurationOption_Minutes ) {
        [resultOptionStrings addObject: isShortType ? @"min" : @"Minutes"];
    }
    retStr = [resultOptionStrings componentsJoinedByString:@" "];
    
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

- (id)eventItemByID:(NSString*)eventId
{
    DaysCounterEvent *item = [DaysCounterEvent MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"eventId == %@",eventId] inContext:[self managedObjectContext]];
    return item;
}

- (BOOL)addEvent:(DaysCounterEvent *)eventModel image:(UIImage *)image
{
    NSAssert(!eventModel.eventId, @"eventModel.eventId error");
    if ( !eventModel.eventId ) {
        eventModel.eventId = [[NSUUID UUID] UUIDString];
    }
    
    // 이미지 저장
    NSString *imageFilename;
    if ( image ) {
        NSData *imageData = UIImagePNGRepresentation(image);
        imageFilename = [NSString stringWithFormat:@"%@.png", eventModel.eventId];
        [imageData writeToFile:[[A3DaysCounterModelManager imagePath] stringByAppendingPathComponent:imageFilename] atomically:YES];
        
        UIImage *thumbnail = [image scaleToFillSize:CGSizeMake(64.0, 64.0)];
        imageData = UIImagePNGRepresentation(thumbnail);
        [imageData writeToFile:[[A3DaysCounterModelManager thumbnailPath] stringByAppendingPathComponent:[A3DaysCounterModelManager thumbnailFilenameFromFilename:imageFilename]] atomically:YES];
    }

    eventModel.imageFilename = imageFilename;
    
    if ( !eventModel.alertDatetime ) {
        eventModel.alertDatetime = nil;
        eventModel.hasReminder = @(NO);
    }
    else {
        eventModel.hasReminder = ([eventModel.alertDatetime timeIntervalSince1970] > [[NSDate date] timeIntervalSince1970]) || (![eventModel.repeatType isEqualToNumber:@(RepeatType_Never)]) ? @(YES) : @(NO);
    }

    if (!eventModel.effectiveStartDate) {
        eventModel.effectiveStartDate = [eventModel.startDate solarDate];
    }
    
    eventModel.regDate = [NSDate date];

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    
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

- (BOOL)modifyEvent:(DaysCounterEvent*)eventItem image:(UIImage *)image
{
    NSString *imageFilename = @"";

    if ( image ) {
        // TODO 이상함
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

    if ( !eventItem.effectiveStartDate ) {
        eventItem.effectiveStartDate = [eventItem.startDate solarDate];
    }
    
    eventItem.effectiveStartDate = [self effectiveDateForEvent:eventItem basisTime:[NSDate date]];
    
    if ( !eventItem.alertDatetime ) {
        eventItem.alertDatetime = nil;
        eventItem.hasReminder = @(NO);
    }
    else {
        eventItem.alertDatetime = [self effectiveAlertDateForEvent:eventItem];
        eventItem.hasReminder = ([eventItem.alertDatetime timeIntervalSince1970] > [[NSDate date] timeIntervalSince1970]) || (![eventItem.repeatType isEqualToNumber:@(RepeatType_Never)]) ? @(YES) : @(NO);
    }
    
	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    
    return YES;
}

- (BOOL)removeEvent:(DaysCounterEvent *)eventItem
{
    // event store에 설정된 값도 삭제한다.
    [eventItem MR_deleteEntity];

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    
    return YES;
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
    return [DaysCounterEvent MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"calendar.isShow == %@", @(YES)]];
}

- (NSInteger)numberOfUpcomingEventsWithDate:(NSDate*)date
{
    return [DaysCounterEvent MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"calendar.isShow == %@ && (effectiveStartDate > %@ || repeatEndDate > %@ || (repeatType != %@ && repeatEndDate == %@))", @(YES), date, date, @(RepeatType_Never), [NSNull null]] inContext:[self managedObjectContext]];
}

- (NSInteger)numberOfPastEventsWithDate:(NSDate*)date
{
    return [DaysCounterEvent MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"calendar.isShow == %@ && ((effectiveStartDate < %@ && repeatType == %@) || (repeatEndDate != %@ && repeatEndDate < %@))", @(YES), date, @(RepeatType_Never), [NSNull null], date] inContext:[self managedObjectContext]];
}

- (NSInteger)numberOfUserCalendarVisible
{
    return [DaysCounterCalendar MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"isShow == %@ and calendarType == %@",[NSNumber numberWithBool:YES],[NSNumber numberWithInteger:CalendarCellType_User]] inContext:[self managedObjectContext]];
}

- (NSInteger)numberOfEventContainedImage
{
    return [DaysCounterEvent MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"calendar.isShow == %@ && imageFilename.length > 0", @(YES)] inContext:[self managedObjectContext]];
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
    DaysCounterCalendar *defaultCalendar = [DaysCounterCalendar MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"isDefault == %@", [NSNumber numberWithBool:YES]] inContext:[self managedObjectContext]];
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
    //return [DaysCounterEvent MR_findAllInContext:[self managedObjectContext]];
    return [DaysCounterEvent MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"calendar.isShow == %@", @(YES)]];
}

- (NSArray*)allEventsListContainedImage
{
    return [DaysCounterEvent MR_findAllSortedBy:@"effectiveStartDate" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"imageFilename.length > 0"]];
}

- (NSArray*)upcomingEventsListWithDate:(NSDate*)date
{
//    return [DaysCounterEvent MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"effectiveStartDate > %@ || repeatEndDate > %@ || (repeatType != %@ && repeatEndDate == %@)", date, date, @(RepeatType_Never), [NSNull null]]
//                                           inContext:[self managedObjectContext]];
    return [DaysCounterEvent MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"calendar.isShow == %@ && (effectiveStartDate > %@ || repeatEndDate > %@ || (repeatType != %@ && repeatEndDate == %@))", @(YES), date, date, @(RepeatType_Never), [NSNull null]]
                                           inContext:[self managedObjectContext]];
}

- (NSArray*)pastEventsListWithDate:(NSDate*)date
{
//    return [DaysCounterEvent MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(effectiveStartDate < %@ && repeatType == %@) || (repeatEndDate != %@ && repeatEndDate < %@)", date, @(RepeatType_Never), [NSNull null], date]
//                                           inContext:[self managedObjectContext]];
    return [DaysCounterEvent MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"calendar.isShow == %@ && ((effectiveStartDate < %@ && repeatType == %@) || (repeatEndDate != %@ && repeatEndDate < %@))", @(YES), date, @(RepeatType_Never), [NSNull null], date]
                                           inContext:[self managedObjectContext]];
}

- (NSArray*)favoriteEventsList
{
    return [DaysCounterEvent MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"isFavorite ==  %@",[NSNumber numberWithBool:YES]] inContext:[self managedObjectContext]];
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
    //return [DaysCounterEvent MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"isReminder == %@", @(YES)] inContext:[self managedObjectContext]];
    [self arrangeReminderList];
    return [DaysCounterReminder MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"isOn == %@", @(YES)]];
}

- (NSDate*)nextDateWithRepeatOption:(NSInteger)repeatType firstDate:(NSDate*)firstDate fromDate:(NSDate*)fromDate isAllDay:(BOOL)isAllDay
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


- (NSDate*)repeatDateOfCurrentNotNextWithRepeatOption:(NSInteger)repeatType firstDate:(NSDate*)firstDate fromDate:(NSDate*)fromDate
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

- (NSString*)stringOfDurationOption:(NSInteger)option fromDate:(NSDate*)fromDate toDate:(NSDate*)toDate isAllDay:(BOOL)isAllDay isShortStyle:(BOOL)isShortStyle
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
//    if ( option & DurationOption_Seconds) {
//        flag |= NSSecondCalendarUnit;
//        flagCount++;
//    }
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
//        else if (IS_IPAD && IS_PORTRAIT && flagCount == 6) {
//            isShortStyle = YES;
//        }
    }
    if (IS_IPAD && !isShortStyle && flagCount == 6) {
        isShortStyle = YES;
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
    if (!isShortStyle) {
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
//            if (option & DurationOption_Seconds && [diffComponent second] != 0) {
//                [resultArray addObject:[NSString stringWithFormat:@"%ld second%@", (long)labs([diffComponent second]), (labs([diffComponent second]) > 1 ? @"s" : @"")]];
//            }
        }
    }
    else {
        if ( option & DurationOption_Year && [diffComponent year] != 0) {
            [resultArray addObject:[NSString stringWithFormat:@"%ld y", (long)labs([diffComponent year])]];
        }
        if ( option & DurationOption_Month && [diffComponent month] != 0) {
            [resultArray addObject:[NSString stringWithFormat:@"%ld m", (long)labs([diffComponent month])]];
        }
        if ( option & DurationOption_Week && [diffComponent week] != 0) {
            [resultArray addObject:[NSString stringWithFormat:@"%ld w", (long)labs([diffComponent week])]];
        }
        if (option & DurationOption_Day && [diffComponent day] != 0) {
            [resultArray addObject:[NSString stringWithFormat:@"%ld d", (long)labs([diffComponent day])]];
        }
        
        if (!isAllDay) {
            if (option & DurationOption_Hour && [diffComponent hour] != 0) {
                [resultArray addObject:[NSString stringWithFormat:@"%ld hr", (long)labs([diffComponent hour])]];
            }
            if (option & DurationOption_Minutes && [diffComponent minute] != 0) {
                [resultArray addObject:[NSString stringWithFormat:@"%ld min", (long)labs([diffComponent minute])]];
            }
//            if (option & DurationOption_Seconds && [diffComponent second] != 0) {
//                [resultArray addObject:[NSString stringWithFormat:@"%ld s", (long)labs([diffComponent second])]];
//            }
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
    NSArray *names = @[@"Cube",@"Dissolve",@"Origami",@"Ripple",@"Wipe"];
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
    titleLabel.shadowOffset = CGSizeMake(0, 1);
//    titleLabel.shadowBlur = 2;
    
    daysLabel.shadowOffset = CGSizeMake(0,1);
//    daysLabel.shadowBlur = 2;
    
    markLabel.shadowOffset = CGSizeMake(0,1);
//    markLabel.shadowBlur = 2;
    markLabel.font = [UIFont systemFontOfSize:(IS_IPHONE ? 13.0 : 14.0)];
    
    dateLabel.shadowOffset = CGSizeMake(0,1);
//    dateLabel.shadowBlur = 2;
    dateLabel.font = [UIFont systemFontOfSize:(IS_IPHONE ? 18.0 : 21.0)];
    
    NSString *untilSinceString = [A3DateHelper untilSinceStringByFromDate:[NSDate date]
                                                                   toDate:item.effectiveStartDate
                                                             allDayOption:[item.isAllDay boolValue]
                                                                   repeat:[item.repeatType integerValue] != RepeatType_Never ? YES : NO
                                                                   strict:NO];
    
    if ([untilSinceString isEqualToString:@"today"] || [untilSinceString isEqualToString:@"now"]) {
        NSDate *repeatDate = [[A3DaysCounterModelManager sharedManager] repeatDateOfCurrentNotNextWithRepeatOption:[item.repeatType integerValue]
                                                                                                  firstDate:[item.startDate solarDate]
                                                                                                   fromDate:[NSDate date]];
        
//        dateLabel.text = [A3DateHelper dateStringFromDate:repeatDate
//                                               withFormat:[[A3DaysCounterModelManager sharedManager] dateFormatForAddEditIsAllDays:[item.isLunar boolValue] ? YES : [item.isAllDay boolValue]]];
        dateLabel.text = [A3DateHelper dateStringFromDate:repeatDate
                                               withFormat:[[A3DaysCounterModelManager sharedManager] dateFormatForPhotoWithIsAllDays:[item.isLunar boolValue] ? YES : [item.isAllDay boolValue]]];
        
        
        daysLabel.text = [untilSinceString isEqualToString:@"today"] ? @" Today " : @" Now ";
        markLabel.text = @"";
        daysLabel.font = IS_IPHONE ? [UIFont fontWithName:@".HelveticaNeueInterface-UltraLightP2" size:88.0] : [UIFont fontWithName:@".HelveticaNeueInterface-UltraLightP2" size:116.0];
        
    }
    else {
        //dateLabel.text = [A3DateHelper dateStringFromDate:item.effectiveStartDate withFormat:[item.isAllDay boolValue] ? @"EEEE, MMMM dd, yyyy" : @"EEEE, MMMM dd, yyyy h:mm a"];
        dateLabel.text = [A3DateHelper dateStringFromDate:item.effectiveStartDate
                                               withFormat:[[A3DaysCounterModelManager sharedManager] dateFormatForPhotoWithIsAllDays:[item.isLunar boolValue] ? YES : [item.isAllDay boolValue]]];
        
        NSInteger diffDays = [A3DateHelper diffDaysFromDate:[NSDate date] toDate:item.effectiveStartDate isAllDay:YES];
        if ( diffDays > 0 ) {
            markLabel.text = @"Days\nUntil";
        }
        else if ( diffDays < 0 ) {
            markLabel.text = @"Days\nSince";
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
    
    if ( [item.imageFilename length] > 0 ) {
        UIImage *image = [A3DaysCounterModelManager photoImageFromFilename:item.imageFilename];
        bgImageView.image = image;
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
    
    retStr = [retStr stringByAppendingFormat:@"\nStart : %@%@",[A3DateHelper dateStringFromDate:[event.startDate solarDate] withFormat:@"EEEE, MMMM dd, yyyy"], ([event.isLunar boolValue] ? @"(lunar)" : @"")];
    if ( event.endDate )
        retStr = [retStr stringByAppendingFormat:@"\nEnd : %@%@",[A3DateHelper dateStringFromDate:[event.endDate solarDate] withFormat:@"EEEE, MMMM dd, yyyy"], ([event.isLunar boolValue] ? @"(lunar)" : @"")];
    if ( [event.repeatType integerValue] != RepeatType_Never )
        retStr = [retStr stringByAppendingFormat:@"\nRepeat : %@",[self repeatTypeStringFromValue:[event.repeatType integerValue]]];
    if ( event.location )
        retStr = [retStr stringByAppendingFormat:@"\nLocation : %@",event.location.locationName];
    
    return retStr;
}

- (BOOL)isSupportLunar
{
    NSString *locale = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    if ( [locale isEqualToString:@"KR"] || [locale isEqualToString:@"CN"] || [locale isEqualToString:@"TW"] || [locale isEqualToString:@"HK"] || [locale isEqualToString:@"MO"] )
        return YES;
    
    return NO;
}

- (NSString*)dateFormatForAddEditIsAllDays:(BOOL)isAllDays
{
    NSString *retFormat = DaysCounterDefaultDateFormat;
    BOOL isLocaleKorea = [A3DateHelper isCurrentLocaleIsKorea];
    
    if ( IS_IPHONE ) {
        if ( isLocaleKorea ) {
            retFormat = ( isAllDays ? @"yyyy년 MMMM d일 EEEE" : @"yyyy. MM. d EEEE a h:mm");
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

- (NSString*)dateFormatForPhotoWithIsAllDays:(BOOL)isAllDays
{
    NSString *retFormat = DaysCounterDefaultDateFormat;
    BOOL isLocaleKorea = [A3DateHelper isCurrentLocaleIsKorea];
    
    if ( IS_IPHONE ) {
        if ( isLocaleKorea ) {
            retFormat = ( isAllDays ? @"yyyy년 MMMM d일 EEEE" : @"yyyy. M. d EEEE a h:mm");
        }
        else {
            retFormat = ( isAllDays ? @"EEE, MMM d, yyyy" : @"EEE, MMM d, yyyy h:mm a");
        }
    }
    else {
        if ( isLocaleKorea ) {
            retFormat = ( isAllDays ? @"yyyy년 MMMM d일 EEEE" : @"yyyy. M. d EEEE a h:mm");
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
            retFormat = ( isAllDays ? @"yyyy년 MMMM d일 EEEE" : @"yyyy년 MMMM d일 EEEE a h:mm");
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
    NSSortDescriptor *event = [[NSSortDescriptor alloc] initWithKey:@"effectiveStartDate" ascending:YES];
    NSArray *sortedArray = [calendar.events sortedArrayUsingDescriptors:@[event]];
    NSDate *now = [NSDate date];
    __block NSInteger closestIndex;
    [sortedArray enumerateObjectsUsingBlock:^(DaysCounterEvent * event, NSUInteger idx, BOOL *stop) {
        if ([event.effectiveStartDate timeIntervalSince1970] >= [now timeIntervalSince1970]) {
            closestIndex = (idx == 0) ? 0 : (idx - 1);
            *stop = YES;
            return;
        }
        closestIndex = idx;
    }];
    
    return [sortedArray objectAtIndex:closestIndex];
}

- (void)renewEffectiveStartDates:(DaysCounterCalendar *)calendar
{
    NSDate * const now = [NSDate date];
    [calendar.events enumerateObjectsUsingBlock:^(DaysCounterEvent *event, NSUInteger idx, BOOL *stop) {
        event.effectiveStartDate = [self effectiveDateForEvent:event basisTime:now];
        event.alertDatetime = [self effectiveAlertDateForEvent:event];
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
        event.effectiveStartDate = [self effectiveDateForEvent:event basisTime:now];
        event.alertDatetime = [self effectiveAlertDateForEvent:event];
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

- (NSDate *)effectiveDateForEvent:(DaysCounterEvent *)event basisTime:(NSDate *)now
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
                                                              leapMonth:[event.useLeapMonth boolValue]
                                                               fromDate:now];
        nextDate = [[NSCalendar currentCalendar] dateFromComponents:solarComp];
        FNLOG(@"\ntoday: %@, \nFirstStartDate: %@, \nEffectiveDate: %@", now, [[event startDate] solarDate], nextDate);
        return nextDate;
    }
    else {
        // Solar
        startDate = [event.startDate solarDate];
        
        // 종료된 Event의 경우.
        if ([event repeatEndDate] && [event.repeatEndDate timeIntervalSince1970] < [now timeIntervalSince1970]) {
            now = [event repeatEndDate];
        }
        
        nextDate = [self nextDateWithRepeatOption:[event.repeatType integerValue]
                                        firstDate:startDate
                                         fromDate:now
                                         isAllDay:[event.isLunar boolValue] ? YES : [event.isAllDay boolValue]];
        
        FNLOG(@"\ntoday: %@, \nFirstStartDate: %@, \nEffectiveDate: %@", now, [event startDate], nextDate);
        return nextDate;
    }
}

//- (BOOL)isTodayEvent:(DaysCounterEvent *)event fromDate:(NSDate *)now
- (BOOL)isTodayEventForDate:(NSDate *)eventDate fromDate:(NSDate *)now repeatType:(NSInteger)repeatType
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
    eventModel.effectiveStartDate = [self effectiveDateForEvent:eventModel basisTime:[NSDate date]];
    
    // EffectiveAlertDate 갱신.
    NSDate *alertDate = eventModel.alertDatetime;
    if (alertDate && ![alertDate isKindOfClass:[NSNull class]]) {
        NSDateComponents *alertIntervalComp = [NSDateComponents new];
        alertIntervalComp.minute = -labs([eventModel.alertInterval integerValue]);
        NSDate *alertDate = [[NSCalendar currentCalendar] dateByAddingComponents:alertIntervalComp toDate:eventModel.effectiveStartDate options:0];
        NSDateComponents *alertDateComp = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:alertDate];
        alertDateComp.second = 0;
        
        eventModel.alertDatetime = [[NSCalendar currentCalendar] dateFromComponents:alertDateComp];
    }
    
    FNLOG(@"\ntoday: %@, \nFirstStartDate: %@, \nEffectiveDate: %@, \nAlertDate: %@", [NSDate date], [eventModel.startDate solarDate], eventModel.effectiveStartDate, eventModel.alertDatetime);
}

#pragma mark - EventTime Management (AlertTime, EffectiveStartDate)
- (void)reloadAlertDateListForLocalNotification
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

        event.effectiveStartDate = [self effectiveDateForEvent:event basisTime:now];    // 현재 기준 앞으로 발생할 실제 이벤트 시간을 얻는다.
        event.alertDatetime = [self effectiveAlertDateForEvent:event];                  // 이벤트 시간 기준, 실제 발생할 이벤트 얼럿 시간을 얻는다.
        FNLOG(@"\n[%ld] EventID: %@, EventName: %@\nEffectiveStartDate: %@, \nAlertDatetime: %@", (long)idx, event.eventId, event.eventName, event.effectiveStartDate, event.alertDatetime);
        
        if ([event.hasReminder isEqualToNumber:@(YES)] && [event.alertDatetime timeIntervalSince1970] < [now timeIntervalSince1970]) {
            DaysCounterReminder *reminder = [DaysCounterReminder MR_findFirstByAttribute:@"event.eventId" withValue:[event eventId]];
            if (reminder) {
                // Remind 이벤트가 이미 존재하는 경우,
                if ([reminder.alertDate timeIntervalSince1970] < [event.alertDatetime timeIntervalSince1970]) {
                    // event 의 갱신된 시간기준으로 reminder 시간 갱신.
                    reminder.isOn = @(YES);
                    reminder.isUnread = @(YES);
                }
                // event 의 갱신된 시간기준으로 reminder 시간 갱신.
                reminder.startDate = event.effectiveStartDate;
                reminder.alertDate = event.alertDatetime;
            }
            else {
                // Remind 이벤트가 없는 경우, 추가.
                reminder = [DaysCounterReminder MR_createEntity];
                reminder.isOn = @(YES);
                reminder.isUnread = @(YES);
                reminder.startDate = event.effectiveStartDate;      // 실제 이벤트 발생일.
                reminder.alertDate = event.alertDatetime;           // 실제 이벤트 얼럿 발생시간. 이 시간이 지나면, Reminder 리스트에 보여지게 된다.
                reminder.event = event;                             // 릴레이션.
            }
        }
        
        if ([event.alertDatetime timeIntervalSince1970] > [now timeIntervalSince1970]) {
            // 현재 이후의 시간에 대하여 등록.
            UILocalNotification *notification = [UILocalNotification new];
            notification.fireDate = [event alertDatetime];
            notification.alertBody = [event eventName];
            notification.userInfo = @{
                                       A3LocalNotificationOwner : A3LocalNotificationFromDaysCounter,
                                       A3LocalNotificationDataID : [event eventId]};

            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            [localNotifications addObject:notification];
        }
    }];

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
}

- (NSDate *)effectiveAlertDateForEvent:(DaysCounterEvent *)event
{
    NSDateComponents *alertIntervalComp = [NSDateComponents new];
    alertIntervalComp.minute = -[event.alertInterval integerValue];
    NSDate *effectiveAlertDate = [[NSCalendar currentCalendar] dateByAddingComponents:alertIntervalComp toDate:event.effectiveStartDate options:0];
    return effectiveAlertDate;
}

#pragma mark - Lunar
- (NSDateComponents *)nextSolarDateComponentsFromLunarDateComponents:(NSDateComponents *)lunarComponents leapMonth:(BOOL)isLeapMonth fromDate:(NSDate *)fromDate
{
    BOOL isResultLeapMonth;
    if (isLeapMonth) {
        isLeapMonth = [NSDate isLunarDateComponents:lunarComponents isKorean:YES];
    }

    NSDateComponents *fromComp = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:fromDate];
    lunarComponents.year = fromComp.year;
    NSDateComponents *startComp = [NSDate lunarCalcWithComponents:lunarComponents gregorianToLunar:NO leapMonth:isLeapMonth korean:YES resultLeapMonth:&isResultLeapMonth];
    NSDateComponents *resultComp;
    if (fromComp.year == startComp.year && startComp.month >= fromComp.month && startComp.day > fromComp.day) {
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

- (NSDate *)nextSolarDateFromLunarDateComponents:(NSDateComponents *)lunarComponents leapMonth:(BOOL)isLeapMonth fromDate:(NSDate *)fromDate
{
    NSDateComponents *solarComp = [self nextSolarDateComponentsFromLunarDateComponents:lunarComponents leapMonth:isLeapMonth fromDate:fromDate];
    NSDate *result = [[NSCalendar currentCalendar] dateFromComponents:solarComp];
    return result;
}

- (NSDateComponents *)dateComponentsOfRepeatForLunarDateComponent:(NSDateComponents *)lunarComponents aboutNextTime:(BOOL)isAboutNextTime leapMonth:(BOOL)isLeapMonth fromDate:(NSDate *)fromDate repeatType:(NSInteger)repeatType
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

- (NSDateComponents *)validLunarDateComponents:(NSDateComponents *)comp
{
    BOOL result = [NSDate isLunarDateComponents:comp isKorean:YES];
    if (result) {
        return comp;
    }
    else {
        comp.year += 1;
        comp = [self validLunarDateComponents:comp];
    }
    
    return comp;
}

#pragma mark - Manipulate DaysCounterDateModel Object
+ (void)setDateModelObjectForDateComponents:(NSDateComponents *)dateComponents withEventModel:(DaysCounterEvent *)eventModel endDate:(BOOL)isEndDate;
{
    DaysCounterDateModel *dateModel = isEndDate ? eventModel.endDate : eventModel.startDate;
    if (!dateModel) {
        dateModel = [DaysCounterDateModel MR_createEntity];
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
        if ([eventModel.useLeapMonth boolValue]) {
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

+ (NSDateComponents *)dateComponentsFromDateModelObject:(DaysCounterDateModel *)dateObject toLunar:(BOOL)isLunar
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
+ (NSString *)dateStringFromDateModel:(DaysCounterDateModel *)dateModel isLunar:(BOOL)isLunar isAllDay:(BOOL)isAllDay isLeapMonth:(BOOL)isLeapMonth
{
    NSString *dateString;
    if (!isLunar) {
        dateString = [NSString stringWithFormat:@"%@", [A3DateHelper dateStringFromDate:[dateModel solarDate] withFormat:[[A3DaysCounterModelManager sharedManager] dateFormatForDetailIsAllDays:isAllDay]]];
    }
    else {
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
        
//        NSDateComponents *solarComp = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:[dateModel solarDate]];
//        if (solarComp.year == [dateModel.year integerValue]) {
//            NSArray *dateFormats = [[dateFormat componentsSeparatedByString:@"M"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (SELF CONTAINS[c] %@)", @"y"]];
//            dateFormat = [[dateFormats componentsJoinedByString:@""] mutableCopy];
//        }

        if (IS_IPAD) {
            dateString = [NSString stringWithFormat:@"%@ (음력 %@)",
                          [A3DateHelper dateStringFromDate:[dateModel solarDate] withFormat:[[A3DaysCounterModelManager sharedManager] dateFormatForDetailIsAllDays:isAllDay]],
                          [A3DateHelper dateStringFromDateComponents:[A3DaysCounterModelManager dateComponentsFromDateModelObject:dateModel toLunar:isLunar] withFormat:dateFormat]];
        }
        else {
            dateString = [NSString stringWithFormat:@"(음력 %@)",
                          [A3DateHelper dateStringFromDateComponents:[A3DaysCounterModelManager dateComponentsFromDateModelObject:dateModel toLunar:isLunar] withFormat:dateFormat]];
        }
    }
    
    return dateString;
}

+ (NSString *)dateStringFromEffectiveDate:(NSDate *)date isLunar:(BOOL)isLunar isAllDay:(BOOL)isAllDay isLeapMonth:(BOOL)isLeapMonth
{
    NSString *dateString;
    if (!isLunar) {
        dateString = [NSString stringWithFormat:@"%@", [A3DateHelper dateStringFromDate:date withFormat:[[A3DaysCounterModelManager sharedManager] dateFormatForDetailIsAllDays:isAllDay]]];
    }
    else {
//        BOOL isResultLeapMonth;
//        NSDateFormatter *formatter = [NSDateFormatter new];
//        [formatter setDateStyle:NSDateFormatterFullStyle];
//        NSMutableString *dateFormat = [formatter.dateFormat mutableCopy];
//        [dateFormat replaceOccurrencesOfString:@"EEEE" withString:@"" options:0 range:NSMakeRange(0, [dateFormat length])];
//        [dateFormat replaceOccurrencesOfString:@"MMMM" withString:@"MMM" options:0 range:NSMakeRange(0, [dateFormat length])];
//        
//        NSDateComponents *lunarComp = [NSDate lunarCalcWithComponents:[[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date] gregorianToLunar:YES leapMonth:isLeapMonth korean:YES resultLeapMonth:&isResultLeapMonth];
//        
//        NSDateComponents *solarComp = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:date];
//        if (solarComp.year == lunarComp.year) {
//            NSArray *dateFormats = [[dateFormat componentsSeparatedByString:@" "] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (SELF CONTAINS[c] %@)", @"y"]];
//            dateFormat = [[dateFormats componentsJoinedByString:@" "] mutableCopy];
//        }
//        
//        dateString = [NSString stringWithFormat:@"%@ (음력 %@)",
//                      [A3DateHelper dateStringFromDate:date withFormat:[[A3DaysCounterModelManager sharedManager] dateFormatForDetailIsAllDays:YES]],
//                      [A3DateHelper dateStringFromDateComponents:lunarComp withFormat:dateFormat]];
        dateString = [NSString stringWithFormat:@"%@",
                      [A3DateHelper dateStringFromDate:date withFormat:[[A3DaysCounterModelManager sharedManager] dateFormatForDetailIsAllDays:YES]]];
    }
    
    return dateString;
}

+ (NSString *)dateStringOfLunarFromDateModel:(DaysCounterDateModel *)dateModel isLeapMonth:(BOOL)isLeapMonth
{
    NSString *dateString;
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateStyle:NSDateFormatterFullStyle];
    NSMutableString *dateFormat = [formatter.dateFormat mutableCopy];
    [dateFormat replaceOccurrencesOfString:@"EEEE" withString:@"" options:0 range:NSMakeRange(0, [dateFormat length])];
    [dateFormat replaceOccurrencesOfString:@"MMMM" withString:@"MMM" options:0 range:NSMakeRange(0, [dateFormat length])];
    
    dateString = [NSString stringWithFormat:@"음력 %@",
                  [A3DateHelper dateStringFromDateComponents:[A3DaysCounterModelManager dateComponentsFromDateModelObject:dateModel toLunar:YES] withFormat:dateFormat]];
    return dateString;
}
@end
