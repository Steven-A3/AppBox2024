//
//  LoanCalcPreference.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 14..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "LoanCalcPreference.h"
#import "A3AppDelegate.h"

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
	[[NSUserDefaults standardUserDefaults] setObject:@(calculationFor) forKey:A3LoanCalcDefaultCalculationFor];
	[[NSUserDefaults standardUserDefaults] synchronize];

	if ([[A3AppDelegate instance].ubiquityStoreManager cloudEnabled]) {
		NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
		[store setObject:@(calculationFor) forKey:A3LoanCalcDefaultCalculationFor];
		[store synchronize];
	}
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

	if ([[A3AppDelegate instance].ubiquityStoreManager cloudEnabled]) {
		NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
		[store setBool:showDownPayment forKey:A3LoanCalcDefaultShowDownPayment];
		[store synchronize];
	}
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

	if ([[A3AppDelegate instance].ubiquityStoreManager cloudEnabled]) {
		NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
		[store setBool:showExtraPayment forKey:A3LoanCalcDefaultShowExtraPayment];
		[store synchronize];
	}
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

	if ([[A3AppDelegate instance].ubiquityStoreManager cloudEnabled]) {
		NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
		[store setBool:showAdvanced forKey:A3LoanCalcDefaultShowAdvanced];
		[store synchronize];
	}
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

	if ([[A3AppDelegate instance].ubiquityStoreManager cloudEnabled]) {
		NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
		[store setBool:useSimpleInterest forKey:A3LoanCalcDefaultUseSimpleInterest];
		[store synchronize];
	}
}

@end
