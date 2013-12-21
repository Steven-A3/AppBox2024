//
//  CurrencyHistory.h
//  AppBox3
//
//  Created by A3 on 12/21/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CurrencyHistoryItem;

@interface CurrencyHistory : NSManagedObject

@property (nonatomic, retain) NSString * currencyCode;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSNumber * rate;
@property (nonatomic, retain) NSString * uniqueIdentifier;
@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) NSSet *targets;
@end

@interface CurrencyHistory (CoreDataGeneratedAccessors)

- (void)addTargetsObject:(CurrencyHistoryItem *)value;
- (void)removeTargetsObject:(CurrencyHistoryItem *)value;
- (void)addTargets:(NSSet *)values;
- (void)removeTargets:(NSSet *)values;

@end
