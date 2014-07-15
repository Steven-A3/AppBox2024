//
//  WalletCategory.h
//  AppBox3
//
//  Created by A3 on 7/15/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WalletField;

@interface WalletCategory : NSManagedObject

@property (nonatomic, retain) NSNumber * doNotShow;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * order;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSSet *fields;
@end

@interface WalletCategory (CoreDataGeneratedAccessors)

- (void)addFieldsObject:(WalletField *)value;
- (void)removeFieldsObject:(WalletField *)value;
- (void)addFields:(NSSet *)values;
- (void)removeFields:(NSSet *)values;

@end
