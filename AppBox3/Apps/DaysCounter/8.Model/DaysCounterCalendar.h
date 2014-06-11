//
//  DaysCounterCalendar.h
//  AppBox3
//
//  Created by A3 on 5/30/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DaysCounterEvent;

@interface DaysCounterCalendar : NSManagedObject

@property (nonatomic, retain) NSData * calendarColor;
@property (nonatomic, retain) NSString * calendarColorID;
@property (nonatomic, retain) NSString * calendarId;
@property (nonatomic, retain) NSString * calendarName;
@property (nonatomic, retain) NSNumber * calendarType;
@property (nonatomic, retain) NSNumber * isDefault;
@property (nonatomic, retain) NSNumber * isShow;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSOrderedSet *events;
@end

@interface DaysCounterCalendar (CoreDataGeneratedAccessors)

- (void)insertObject:(DaysCounterEvent *)value inEventsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromEventsAtIndex:(NSUInteger)idx;
- (void)insertEvents:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeEventsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInEventsAtIndex:(NSUInteger)idx withObject:(DaysCounterEvent *)value;
- (void)replaceEventsAtIndexes:(NSIndexSet *)indexes withEvents:(NSArray *)values;
- (void)addEventsObject:(DaysCounterEvent *)value;
- (void)removeEventsObject:(DaysCounterEvent *)value;
- (void)addEvents:(NSOrderedSet *)values;
- (void)removeEvents:(NSOrderedSet *)values;
@end
