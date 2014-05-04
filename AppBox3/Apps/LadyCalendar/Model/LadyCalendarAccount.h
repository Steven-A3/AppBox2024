//
//  LadyCalendarAccount.h
//  AppBox3
//
//  Created by A3 on 5/3/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LadyCalendarPeriod;

@interface LadyCalendarAccount : NSManagedObject

@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSDate * birthDay;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSDate * modificationDate;
@property (nonatomic, retain) NSOrderedSet *periods;
@end

@interface LadyCalendarAccount (CoreDataGeneratedAccessors)

- (void)insertObject:(LadyCalendarPeriod *)value inPeriodsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPeriodsAtIndex:(NSUInteger)idx;
- (void)insertPeriods:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePeriodsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPeriodsAtIndex:(NSUInteger)idx withObject:(LadyCalendarPeriod *)value;
- (void)replacePeriodsAtIndexes:(NSIndexSet *)indexes withPeriods:(NSArray *)values;
- (void)addPeriodsObject:(LadyCalendarPeriod *)value;
- (void)removePeriodsObject:(LadyCalendarPeriod *)value;
- (void)addPeriods:(NSOrderedSet *)values;
- (void)removePeriods:(NSOrderedSet *)values;
@end
