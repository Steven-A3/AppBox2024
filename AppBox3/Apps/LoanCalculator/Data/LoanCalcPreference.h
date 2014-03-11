//
//  LoanCalcPreference.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 14..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A3UserDefaults.h"

typedef NS_ENUM(NSUInteger, A3LoanCalcCalculationFor) {
	A3_LCCF_MonthlyPayment = 1,
	A3_LCCF_DownPayment,
	A3_LCCF_Principal,
	A3_LCCF_TermYears,
	A3_LCCF_TermMonths
};

extern NSString *const A3LoanCalcNotificationDownPaymentEnabled;
extern NSString *const A3LoanCalcNotificationDownPaymentDisabled;
extern NSString *const A3LoanCalcNotificationExtraPaymentEnabled;
extern NSString *const A3LoanCalcNotificationExtraPaymentDisabled;

@interface LoanCalcPreference : NSObject

@property (nonatomic) 			BOOL showDownPayment;
@property (nonatomic)			BOOL showExtraPayment;
@property (nonatomic)			BOOL showAdvanced;
@property (nonatomic)			BOOL useSimpleInterest;
@property (nonatomic)			A3LoanCalcCalculationFor calculationFor;

@end