//
//  A3LoanCalcString.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/27/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcString.h"
#import "A3LoanCalcPreferences.h"

@implementation A3LoanCalcString

+ (NSString *)stringForFrequencyValue:(NSNumber *)number {
	NSString *string = nil;
	switch ((A3LoanCalcFrequency)[number unsignedIntegerValue]) {
		case A3LoanCalcFrequencyWeekly:
			string = @"Weekly";
			break;
		case A3LoanCalcFrequencyFortnightly:
			string = @"Fortnightly";
			break;
		case A3LoanCalcFrequencyMonthly:
			string = @"Monthly";
			break;
		case A3LoanCalcFrequencyBiMonthly:
			string = @"Bi-Monthly";
			break;
		case A3LoanCalcFrequencySemiAnnually:
			string = @"Semi-Annually";
			break;
		case A3LoanCalcFrequencyQuarterly:
			string = @"Quarterly";
			break;
		case A3LoanCalcFrequencyAnnually:
			string = @"Annually";
			break;
	}
	return string;
}

+ (NSString *)stringFromCalculationFor:(A3LoanCalcCalculationFor)calculationFor {
	NSString *string = @"";
	switch (calculationFor) {
		case A3_LCCF_MonthlyPayment:
			string = @"Monthly Payment";
			break;
		case A3_LCCF_DownPayment:
			string = @"Down Payment";
			break;
		case A3_LCCF_Principal:
			string = @"Principal";
			break;
		case A3_LCCF_TermYears:
			string = @"Term(Years)";
			break;
		case A3_LCCF_TermMonths:
			string = @"Term(Months)";
			break;
	}
	return string;
}

+ (NSString *)stringFromTermInMonths:(float)months {
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	return [NSString stringWithFormat:@"%@ %@", [numberFormatter stringFromNumber:[NSNumber numberWithFloat:months]], @"months"];
}

+ (NSString *)stringFromTermInYears:(float)years {
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	return [NSString stringWithFormat:@"%@ %@", [numberFormatter stringFromNumber:[NSNumber numberWithFloat:years]], @"years"];
}

@end
