//
//  LoanCalcComparisonHistory.h
//  AppBox3
//
//  Created by A3 on 8/2/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LoanCalcComparisonHistory : NSManagedObject

@property (nonatomic, retain) NSString * totalAmountA;
@property (nonatomic, retain) NSString * totalAmountB;
@property (nonatomic, retain) NSString * totalInterestA;
@property (nonatomic, retain) NSString * totalInterestB;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSString * currencyCode;

@end
