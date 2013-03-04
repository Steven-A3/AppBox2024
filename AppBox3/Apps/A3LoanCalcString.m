//
//  A3LoanCalcString.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/27/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcString.h"

@implementation A3LoanCalcString

+(NSString *)stringForFrequencyValue:(NSNumber *)number {
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

@end
