//
//  LoanCalcComparisonHistory.h
//  AppBox3
//
//  Created by A3 on 3/11/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LoanCalcHistory;

@interface LoanCalcComparisonHistory : NSManagedObject

@property (nonatomic, retain) NSDate * calculateDate;
@property (nonatomic, retain) NSString * totalAmountA;
@property (nonatomic, retain) NSString * totalAmountB;
@property (nonatomic, retain) NSString * totalInterestA;
@property (nonatomic, retain) NSString * totalInterestB;
@property (nonatomic, retain) NSSet *details;
@end

@interface LoanCalcComparisonHistory (CoreDataGeneratedAccessors)

- (void)addDetailsObject:(LoanCalcHistory *)value;
- (void)removeDetailsObject:(LoanCalcHistory *)value;
- (void)addDetails:(NSSet *)values;
- (void)removeDetails:(NSSet *)values;

@end
