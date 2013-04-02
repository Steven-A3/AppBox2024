//
//  LoanCalcHistory+calculation.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 3/28/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "LoanCalcHistory.h"

#define A3LC_KEY_CALCULATION_FOR					@"CalculationFor"
#define A3LC_KEY_PRINCIPAL							@"principal"
#define A3LC_KEY_MONTHLY_PAYMENT					@"monthlyPayment"
#define A3LC_KEY_DOWN_PAYMENT 						@"downPayment"
#define A3LC_KEY_TERM								@"term"
#define A3LC_KEY_INTEREST_RATE						@"interestRate"
#define A3LC_KEY_FREQUENCY							@"frequency"
#define A3LC_KEY_START_DATE							@"startDate"
#define A3LC_KEY_NOTES								@"notes"
#define A3LC_KEY_EXTRA_PAYMENT_MONTHLY  			@"extraPaymentMonthly"
#define A3LC_KEY_EXTRA_PAYMENT_YEARLY 		  		@"extraPaymentYearly"
#define A3LC_KEY_EXTRA_PAYMENT_ONETIME 				@"extraPaymentOnetime"
#define A3LC_KEY_EXTRA_PAYMENT_YEARLY_MONTH 		@"extraPaymentYearlyMonth"
#define A3LC_KEY_EXTRA_PAYMENT_ONETIME_YEAR_MONTH	@"extraPaymentOnetimeYearMonth"

typedef NS_ENUM(NSUInteger, A3LoanCalculatorEntry) {
	A3LCEntryPrincipal = 1,
	A3LCEntryMonthlyPayment,
	A3LCEntryDownPayment,
	A3LCEntryTerm,
	A3LCEntryInterestRate,
	A3LCEntryFrequency,
	A3LCEntryStartDate,
	A3LCEntryNotes,
	A3LCEntryButton,
	A3LCEntryExtraPaymentMonthly,
	A3LCEntryExtraPaymentYearly,
	A3LCEntryExtraPaymentOneTime
};

@interface LoanCalcHistory (calculation)

- (void)initializeValues;
- (float)termInMonth;
- (void)calculateMonthlyPayment;
- (void)calculatePrincipal;
- (void)calculateDownPayment;
- (void)calculateTerm:(BOOL)inMonth;

- (void)calculate;
@end
