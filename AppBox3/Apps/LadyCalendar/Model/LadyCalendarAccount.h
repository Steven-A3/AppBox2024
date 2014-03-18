//
//  LadyCalendarAccount.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LadyCalendarAccount : NSManagedObject

@property (nonatomic, retain) NSString * accountID;
@property (nonatomic, retain) NSString * accountName;
@property (nonatomic, retain) NSDate * birthDay;
@property (nonatomic, retain) NSString * accountNotes;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSDate * regDate;
@property (nonatomic, retain) NSOrderedSet *periods;
@end

@interface LadyCalendarAccount (CoreDataGeneratedAccessors)

- (void)insertObject:(NSManagedObject *)value inPeriodsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPeriodsAtIndex:(NSUInteger)idx;
- (void)insertPeriods:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePeriodsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPeriodsAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replacePeriodsAtIndexes:(NSIndexSet *)indexes withPeriods:(NSArray *)values;
- (void)addPeriodsObject:(NSManagedObject *)value;
- (void)removePeriodsObject:(NSManagedObject *)value;
- (void)addPeriods:(NSOrderedSet *)values;
- (void)removePeriods:(NSOrderedSet *)values;
@end
