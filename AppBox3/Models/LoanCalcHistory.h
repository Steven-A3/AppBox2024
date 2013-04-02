//
//  LoanCalcHistory.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/1/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LoanCalcHistory : NSManagedObject

@property (nonatomic, retain) NSNumber * calculationFor;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * downPayment;
@property (nonatomic, retain) NSNumber * editing;
@property (nonatomic, retain) NSString * extraPaymentMonthly;
@property (nonatomic, retain) NSString * extraPaymentOnetime;
@property (nonatomic, retain) NSString * extraPaymentYearly;
@property (nonatomic, retain) NSNumber * frequency;
@property (nonatomic, retain) NSString * interestRate;
@property (nonatomic, retain) NSNumber * interestRatePerYear;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * monthlyPayment;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * principal;
@property (nonatomic, retain) NSNumber * showAdvanced;
@property (nonatomic, retain) NSNumber * showDownPayment;
@property (nonatomic, retain) NSNumber * showExtraPayment;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * term;
@property (nonatomic, retain) NSNumber * termTypeMonth;
@property (nonatomic, retain) NSNumber * useSimpleInterest;
@property (nonatomic, retain) NSDate * extraPaymentYearlyMonth;
@property (nonatomic, retain) NSDate * extraPaymentOnetimeYearMonth;

@end
