//
//  UnitType.h
//  AppBox3
//
//  Created by A3 on 6/30/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UnitItem;

@interface UnitType : NSManagedObject

@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSString * unitTypeName;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSSet *items;
@end

@interface UnitType (CoreDataGeneratedAccessors)

- (void)addItemsObject:(UnitItem *)value;
- (void)removeItemsObject:(UnitItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
