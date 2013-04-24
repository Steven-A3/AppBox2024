//
//  A3LoanCalcPreferences.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 3/11/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3UserDefaults.h"
#import "A3LoanCalcPreferences.h"

@interface A3LoanCalcPreferences ()

@end

@implementation A3LoanCalcPreferences

- (A3LoanCalcCalculationFor)calculationFor {
	NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:A3LoanCalcDefaultCalculationFor];
	if (value) {
		return (A3LoanCalcCalculationFor) [value unsignedIntegerValue];
	}
	return A3_LCCF_MonthlyPayment;
}

- (void)setCalculationFor:(A3LoanCalcCalculationFor)calculationFor {
	[[NSUserDefaults standardUserDefaults] setInteger:calculationFor forKey:A3LoanCalcDefaultCalculationFor];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)showDownPayment {
	NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:A3LoanCalcDefaultShowDownPayment];
	if (value) {
		return [value boolValue];
	}
	return YES;
}

- (void)setShowDownPayment:(BOOL)showDownPayment {
	[[NSUserDefaults standardUserDefaults] setBool:showDownPayment forKey:A3LoanCalcDefaultShowDownPayment];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)showExtraPayment {
	NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:A3LoanCalcDefaultShowExtraPayment];
	if (value) {
		return [value boolValue];
	}
	return YES;
}

- (void)setShowExtraPayment:(BOOL)showExtraPayment {
	[[NSUserDefaults standardUserDefaults] setBool:showExtraPayment forKey:A3LoanCalcDefaultShowExtraPayment];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)showAdvanced {
	NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:A3LoanCalcDefaultShowAdvanced];
	if (value) {
		return [value boolValue];
	}
	return YES;
}

- (void)setShowAdvanced:(BOOL)showAdvanced {
	[[NSUserDefaults standardUserDefaults] setBool:showAdvanced forKey:A3LoanCalcDefaultShowAdvanced];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)useSimpleInterest {
	NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:A3LoanCalcDefaultUseSimpleInterest];
	if (value) {
		return [value boolValue];
	}
	return NO;
}

- (void)setUseSimpleInterest:(BOOL)useSimpleInterest {
	[[NSUserDefaults standardUserDefaults] setBool:useSimpleInterest forKey:A3LoanCalcDefaultUseSimpleInterest];
	[[NSUserDefaults standardUserDefaults] synchronize];
}
@end
