//
//  A3LoanCalcPreferences.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 3/11/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
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

@interface A3LoanCalcPreferences : NSObject

@property (nonatomic) 			BOOL showDownPayment;
@property (nonatomic)			BOOL showExtraPayment;
@property (nonatomic)			BOOL showAdvanced;
@property (nonatomic)			BOOL useSimpleInterest;
@property (nonatomic)			A3LoanCalcCalculationFor calculationFor;

@end
