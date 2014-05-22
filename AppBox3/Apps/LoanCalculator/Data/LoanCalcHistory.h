//
//  LoanCalcHistory.h
//  AppBox3
//
//  Created by dotnetguy83 on 5/22/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LoanCalcComparisonHistory, LoanCalcHistory;

@interface LoanCalcHistory : NSManagedObject

@property (nonatomic, retain) NSNumber * calculationMode;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * downPayment;
@property (nonatomic, retain) NSNumber * editing;
@property (nonatomic, retain) NSString * extraPaymentMonthly;
@property (nonatomic, retain) NSString * extraPaymentOnetime;
@property (nonatomic, retain) NSDate * extraPaymentOnetimeYearMonth;
@property (nonatomic, retain) NSString * extraPaymentYearly;
@property (nonatomic, retain) NSDate * extraPaymentYearlyMonth;
@property (nonatomic, retain) NSNumber * frequency;
@property (nonatomic, retain) NSString * interestRate;
@property (nonatomic, retain) NSNumber * interestRatePerYear;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * monthlyPayment;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * orderInComparison;
@property (nonatomic, retain) NSString * principal;
@property (nonatomic, retain) NSNumber * showAdvanced;
@property (nonatomic, retain) NSNumber * showDownPayment;
@property (nonatomic, retain) NSNumber * showExtraPayment;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * term;
@property (nonatomic, retain) NSNumber * termTypeMonth;
@property (nonatomic, retain) NSNumber * useSimpleInterest;
@property (nonatomic, retain) LoanCalcHistory *compareWith;
@property (nonatomic, retain) LoanCalcComparisonHistory *comparisonHistory;

@end
