//
//  CurrencyHistory.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/7/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CurrencyHistoryItem;

@interface CurrencyHistory : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * currencyCode;
@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) NSNumber * rate;
@property (nonatomic, retain) NSSet *targets;
@end

@interface CurrencyHistory (CoreDataGeneratedAccessors)

- (void)addTargetsObject:(CurrencyHistoryItem *)value;
- (void)removeTargetsObject:(CurrencyHistoryItem *)value;
- (void)addTargets:(NSSet *)values;
- (void)removeTargets:(NSSet *)values;

@end
