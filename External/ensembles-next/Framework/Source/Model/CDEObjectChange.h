//
//  CDEObjectChange.h
//  Test App iOS
//
//  Created by Drew McCormack on 4/14/13.
//  Copyright (c) 2013 The Mental Faculty B.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDEStoreModificationEvent;
@class CDEGlobalIdentifier;
@class CDEPropertyChangeValue;

typedef NS_ENUM(int16_t, CDEObjectChangeType) {
    CDEObjectChangeTypeInsert = 100,
    CDEObjectChangeTypeUpdate = 200,
    CDEObjectChangeTypeDelete = 300
};

@interface CDEObjectChange : NSManagedObject

@property (nonatomic) CDEObjectChangeType type;
@property (nonatomic, strong) CDEGlobalIdentifier *globalIdentifier;
@property (nonatomic, strong) CDEStoreModificationEvent *storeModificationEvent;
@property (nonatomic, strong) NSString *nameOfEntity;
@property (nonatomic, strong) NSArray *propertyChangeValues;
@property (nonatomic, strong) NSSet *dataFiles;

- (CDEPropertyChangeValue *)propertyChangeValueForPropertyName:(NSString *)name;

// Give priority to values in self
- (void)mergeValuesFromSubordinateObjectChange:(CDEObjectChange *)change;
- (void)mergeValuesFromSubordinateObjectChange:(CDEObjectChange *)change isModified:(BOOL *)modified;

+ (void)prefetchRelatedObjectsForObjectChanges:(NSArray *)objectChanges;
+ (void)prefetchObjectChangesForObjectIDs:(NSArray *)objectChangeIDs inManagedObjectContext:(NSManagedObjectContext *)context;

+ (NSUInteger)countOfObjectChangesInStoreModificationEvents:(NSArray *)events;

+ (NSArray *)sortDescriptorsForEventOrder;

@end