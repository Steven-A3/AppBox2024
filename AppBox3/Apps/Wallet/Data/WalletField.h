//
//  WalletField.h
//  AppBox3
//
//  Created by A3 on 4/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WalletCategory, WalletFieldItem;

@interface WalletField : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * order;
@property (nonatomic, retain) NSString * style;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) WalletCategory *category;
@property (nonatomic, retain) NSSet *fieldItems;
@end

@interface WalletField (CoreDataGeneratedAccessors)

- (void)addFieldItemsObject:(WalletFieldItem *)value;
- (void)removeFieldItemsObject:(WalletFieldItem *)value;
- (void)addFieldItems:(NSSet *)values;
- (void)removeFieldItems:(NSSet *)values;

@end
