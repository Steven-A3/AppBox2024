//
//  LoanCalcHistory+extension.m
//  AppBox3
//
//  Created by A3 on 7/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "LoanCalcHistory+extension.h"
#import "LoanCalcData.h"

@implementation LoanCalcHistory (extension)

+ (BOOL)sameDataExistForLoanCalcData:(LoanCalcData *)data type:(NSString *)type {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
			@"downPayment == %@ AND \
			frequency == %@ AND \
			interestRate == %@ AND \
			monthlyPayment == %@ AND \
            principal == %@ AND \
			term == %@ AND \
			calculationMode == %@ AND orderInComparison == %@",
					data.downPayment.stringValue,
					@(data.frequencyIndex),
					data.annualInterestRate.stringValue,
					data.repayment.stringValue,
					data.principal.stringValue,
					data.monthOfTerms.stringValue,
					@(data.calculationMode),
			        type
	];

	return [LoanCalcHistory MR_countOfEntitiesWithPredicate:predicate] > 0;
}

@end
