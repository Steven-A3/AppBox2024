//
//  LoanCalcMode.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 8..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, A3LoanCalcCalculationMode) {
	A3LC_CalculationForDownPayment = 1,
	A3LC_CalculationForRepayment,
	A3LC_CalculationForPrincipal,
    A3LC_CalculationForTermOfYears,
	A3LC_CalculationForTermOfMonths,
};

typedef NS_ENUM(NSUInteger, A3LoanCalcCalculationItem) {
	A3LC_CalculationItemPrincipal = 1,
	A3LC_CalculationItemDownPayment,
	A3LC_CalculationItemTerm,
    A3LC_CalculationItemInterestRate,
	A3LC_CalculationItemRepayment,
    A3LC_CalculationItemFrequency,
};

typedef NS_ENUM(NSUInteger, A3LoanCalcFrequencyType) {
	A3LC_FrequencyWeekly = 1,
	A3LC_FrequencyBiweekly,
	A3LC_FrequencyMonthly,
	A3LC_FrequencyBimonthly,
	A3LC_FrequencyQuarterly,
	A3LC_FrequencySemiannualy,
	A3LC_FrequencyAnnually,
};

typedef NS_ENUM(NSUInteger, A3LoanCalcExtraPaymentType) {
	A3LC_ExtraPaymentMonthly = 1,
	A3LC_ExtraPaymentYearly,
	A3LC_ExtraPaymentOnetime,
};

@interface LoanCalcMode : NSObject

+ (NSArray *) calculationModes;
+ (NSArray *) frequencyTypes;
+ (NSArray *) extraPaymentTypes;
+ (NSArray *) calculateItemForMode:(A3LoanCalcCalculationMode) mode withDownPaymentEnabled:(BOOL)enabled;
+ (NSArray *) compareCalculateItemsForDownPaymentEnabled:(BOOL)onoff;
+ (A3LoanCalcCalculationItem)resltItemForCalcFor:(A3LoanCalcCalculationMode)calFor;

@end
