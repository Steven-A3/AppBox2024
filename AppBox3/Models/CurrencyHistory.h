//
//  CurrencyHistory.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/16/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CurrencyHistory : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * sourceCurrencyCode;
@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) NSSet *targets;
@end

@interface CurrencyHistory (CoreDataGeneratedAccessors)

- (void)addTargetsObject:(NSManagedObject *)value;
- (void)removeTargetsObject:(NSManagedObject *)value;
- (void)addTargets:(NSSet *)values;
- (void)removeTargets:(NSSet *)values;

@end
