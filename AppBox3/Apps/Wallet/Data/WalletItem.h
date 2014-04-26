//
//  WalletItem.h
//  AppBox3
//
//  Created by A3 on 4/27/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WalletCategory, WalletFavorite, WalletFieldItem;

@interface WalletItem : NSManagedObject

@property (nonatomic, retain) NSDate * modificationDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSString * order;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) WalletCategory *category;
@property (nonatomic, retain) WalletFavorite *favorite;
@property (nonatomic, retain) NSSet *fieldItems;
@end

@interface WalletItem (CoreDataGeneratedAccessors)

- (void)addFieldItemsObject:(WalletFieldItem *)value;
- (void)removeFieldItemsObject:(WalletFieldItem *)value;
- (void)addFieldItems:(NSSet *)values;
- (void)removeFieldItems:(NSSet *)values;

@end
