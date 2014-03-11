//
//  LoanCalcPreference.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 14..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "LoanCalcPreference.h"

NSString *const A3LoanCalcNotificationDownPaymentEnabled = @"A3LoanCalcNotificationDownPaymentEnabled";
NSString *const A3LoanCalcNotificationDownPaymentDisabled = @"A3LoanCalcNotificationDownPaymentDisabled";
NSString *const A3LoanCalcNotificationExtraPaymentEnabled = @"A3LoanCalcNotificationExtraPaymentEnabled";
NSString *const A3LoanCalcNotificationExtraPaymentDisabled = @"A3LoanCalcNotificationExtraPaymentDisabled";

@interface LoanCalcPreference ()

@end

@implementation LoanCalcPreference

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
    else {
        return NO;
    }
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
