//
//  LoanCalcHistory+calculation.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 3/28/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "LoanCalcHistory+calculation.h"
#import "A3Categories.h"
#import "common.h"
#import "A3LoanCalcString.h"

@implementation LoanCalcHistory (calculation)

- (void)initializeValues {
	A3LoanCalcPreferences *preferences = [[A3LoanCalcPreferences alloc] init];
	self.calculationFor = [NSNumber numberWithUnsignedInteger:preferences.calculationFor];
	self.useSimpleInterest = [NSNumber numberWithBool:preferences.useSimpleInterest];
	self.showDownPayment = [NSNumber numberWithBool:preferences.showDownPayment];
	self.showExtraPayment = [NSNumber numberWithBool:preferences.showExtraPayment];
	self.showAdvanced = [NSNumber numberWithBool:preferences.showAdvanced];
	self.principal = @"";
	self.downPayment = @"";
	self.term = @"";
	self.termTypeMonth = [NSNumber numberWithBool:YES];
	self.interestRate = @"";
	self.interestRatePerYear = [NSNumber numberWithBool:YES];
	self.frequency = [NSNumber numberWithInteger:0];
	self.startDate = nil;
	self.notes = @"";
	self.created = [NSDate date];
	self.extraPaymentMonthly = @"";
	self.extraPaymentYearly = @"";
	self.extraPaymentOnetime = @"";
	self.location = @"S";	// S for single, A for comparison A, B for comparison B

	self.editing = [NSNumber numberWithBool:YES];
}

- (NSNumberFormatter *)currencyFormatter {
    NSNumberFormatter *_currencyFormatter;
	if (nil == _currencyFormatter) {
		_currencyFormatter = [[NSNumberFormatter alloc] init];
		[_currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	}
	return _currencyFormatter;
}

- (float)monthlyInterestRate {
	float monthlyInterestRate = [self.interestRate floatValueEx];
	if ([self.interestRatePerYear boolValue]) {
		monthlyInterestRate /= 12.0;
	}
	return monthlyInterestRate / 100.0;
}

- (float)termInMonth {
	float termMonth = [self.term floatValueEx];
	if (![self.termTypeMonth boolValue]) {
		termMonth *= 12.0;
	}
	return termMonth;
}

- (void)calculateMonthlyPayment {
	float monthlyPayment;
	float principal, downPayment = 0.0;
	float monthlyInterestRate = self.monthlyInterestRate;
	float termInMonth = self.termInMonth;
    
	principal = [self.principal floatValueEx];
	if (self.showDownPayment) {
		downPayment = [self.downPayment floatValueEx];
	}
    
	monthlyPayment = (monthlyInterestRate / (1 - powf(1 + monthlyInterestRate, -termInMonth))) * (principal - downPayment);
    
	FNLOG("principal = %f\nmonthlyPayment = %f\nmonthlyInterestRate = %f\nterminMonth = %f\ndownPayment = %f", principal, monthlyPayment, monthlyInterestRate, termInMonth, downPayment);
    
	self.monthlyPayment = [self.currencyFormatter stringFromNumber:[NSNumber numberWithFloat:monthlyPayment]];
}

- (void)calculatePrincipal {
	float principal;
	float monthlyPayment;
	float downPayment = 0.0;
	float monthlyInterestRate = self.monthlyInterestRate;
	float termInMonth = self.termInMonth;
    
	monthlyPayment = [self.monthlyPayment floatValueEx];
    
	principal = (monthlyPayment*powf(monthlyInterestRate+1,termInMonth)-monthlyPayment)/(monthlyInterestRate*powf(monthlyInterestRate+1,termInMonth));
    
	if (self.showDownPayment) {
		downPayment = [self.downPayment floatValueEx];
		principal -= downPayment;
	}
    
	FNLOG("principal = %f\nmonthlyPayment = %f\nmonthlyInterestRate = %f\nterminMonth = %f\ndownPayment = %f", principal, monthlyPayment, monthlyInterestRate, termInMonth, downPayment);
    
	self.principal = [self.currencyFormatter stringFromNumber:[NSNumber numberWithFloat:principal]];
}

- (void)calculateDownPayment {
	float downPayment;
	float principal = [self.principal floatValueEx];
	float monthlyPayment = [self.monthlyPayment floatValueEx];
	float monthlyInterestRate = self.monthlyInterestRate;
	float termInMonth = self.termInMonth;
    
	float calculatedPrincipal = (monthlyPayment*powf(monthlyInterestRate+1,termInMonth)-monthlyPayment)/(monthlyInterestRate*powf(monthlyInterestRate+1,termInMonth));
	downPayment = calculatedPrincipal - principal;
    
	FNLOG("principal = %f\nmonthlyPayment = %f\nmonthlyInterestRate = %f\nterminMonth = %f\ndownPayment = %f", principal, monthlyPayment, monthlyInterestRate, termInMonth, downPayment);
    
	self.downPayment = [self.currencyFormatter stringFromNumber:[NSNumber numberWithFloat:downPayment]];
}

- (void)calculateTerm:(BOOL)inMonth {
	float principal = [self.principal floatValueEx];
	float downPayment = self.showDownPayment ? [self.downPayment floatValueEx] : 0.0;
	float monthlyPayment = [self.monthlyPayment floatValueEx];
	float monthlyInterestRate = self.monthlyInterestRate;
    
	float calculatedPrincipal = principal - downPayment;
	float term = logf(monthlyPayment/(monthlyPayment-calculatedPrincipal*monthlyInterestRate))/logf(monthlyInterestRate+1);
    
	FNLOG("principal = %f\nmonthlyPayment = %f\nmonthlyInterestRate = %f\nterm = %f\ndownPayment = %f", principal, monthlyPayment, monthlyInterestRate, term, downPayment);
    
	if (inMonth) {
		self.term = [A3LoanCalcString stringFromTermInMonths:term];
	} else {
		term /= 12.0;
		self.term = [A3LoanCalcString stringFromTermInYears:term];
	}
}

@end
