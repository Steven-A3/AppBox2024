//
//  UnitHistory.h
//  AppBox3
//
//  Created by A3 on 6/30/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UnitHistoryItem, UnitItem;

@interface UnitHistory : NSManagedObject

@property (nonatomic, retain) NSDate *updateDate;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) UnitItem *source;
@property (nonatomic, retain) NSSet *targets;
@end

@interface UnitHistory (CoreDataGeneratedAccessors)

- (void)addTargetsObject:(UnitHistoryItem *)value;
- (void)removeTargetsObject:(UnitHistoryItem *)value;
- (void)addTargets:(NSSet *)values;
- (void)removeTargets:(NSSet *)values;

@end
