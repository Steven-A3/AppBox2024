//
//  LoanCalcData.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 7..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoanCalcMode.h"

@interface LoanCalcData : NSObject

@property (nonatomic, strong) NSNumber *principal;
@property (nonatomic, strong) NSNumber *downPayment;
@property (nonatomic, strong) NSNumber *repayment;
@property (nonatomic, strong) NSNumber *monthOfTerms;
@property (nonatomic, strong) NSNumber *annualInterestRate;
@property (nonatomic, readwrite) A3LoanCalcFrequencyType frequencyIndex;
@property (nonatomic, strong) NSDate *calculationDate;

// advanced
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSString *note;

// extra payment
@property (nonatomic, strong) NSNumber *extraPaymentMonthly;
@property (nonatomic, strong) NSNumber *extraPaymentYearly;
@property (nonatomic, strong) NSDate *extraPaymentYearlyDate;
@property (nonatomic, strong) NSNumber *extraPaymentOneTime;
@property (nonatomic, strong) NSDate *extraPaymentOneTimeDate;

// setting
@property (nonatomic, readwrite) A3LoanCalcCalculationMode calculationFor;
@property (nonatomic, readwrite) BOOL showAdvanced;
@property (nonatomic, readwrite) BOOL showDownPayment;
@property (nonatomic, readwrite) BOOL showExtraPayment;

@end
