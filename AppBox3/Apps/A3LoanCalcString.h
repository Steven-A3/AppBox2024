//
//  A3LoanCalcString.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/27/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, A3LoanCalcFrequency) {
	A3LoanCalcFrequencyWeekly = 1,
	A3LoanCalcFrequencyFortnightly,
	A3LoanCalcFrequencyMonthly,
	A3LoanCalcFrequencyBiMonthly,
	A3LoanCalcFrequencySemiAnnually,
	A3LoanCalcFrequencyQuarterly,
	A3LoanCalcFrequencyAnnually
};

@interface A3LoanCalcString : NSObject

+ (NSString *)stringForFrequencyValue:(NSNumber *)number;
@end
