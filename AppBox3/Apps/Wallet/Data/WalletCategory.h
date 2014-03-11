//
//  WalletCategory.h
//  AppBox3
//
//  Created by A3 on 3/11/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WalletField, WalletItem;

@interface WalletCategory : NSManagedObject

@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSDate * modificationDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * order;
@property (nonatomic, retain) NSSet *fields;
@property (nonatomic, retain) NSSet *items;
@end

@interface WalletCategory (CoreDataGeneratedAccessors)

- (void)addFieldsObject:(WalletField *)value;
- (void)removeFieldsObject:(WalletField *)value;
- (void)addFields:(NSSet *)values;
- (void)removeFields:(NSSet *)values;

- (void)addItemsObject:(WalletItem *)value;
- (void)removeItemsObject:(WalletItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
