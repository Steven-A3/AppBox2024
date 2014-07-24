//
//  LoanCalcPreference.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 14..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "LoanCalcPreference.h"
#import "A3AppDelegate.h"
#import "A3SyncManager.h"

NSString *const A3LoanCalcNotificationDownPaymentEnabled = @"A3LoanCalcNotificationDownPaymentEnabled";
NSString *const A3LoanCalcNotificationDownPaymentDisabled = @"A3LoanCalcNotificationDownPaymentDisabled";
NSString *const A3LoanCalcNotificationExtraPaymentEnabled = @"A3LoanCalcNotificationExtraPaymentEnabled";
NSString *const A3LoanCalcNotificationExtraPaymentDisabled = @"A3LoanCalcNotificationExtraPaymentDisabled";

@interface LoanCalcPreference ()

@end

@implementation LoanCalcPreference

- (A3LoanCalcCalculationFor)calculationFor {
	NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:A3LoanCalcUserDefaultCalculationFor];
	if (value) {
		return (A3LoanCalcCalculationFor) [value unsignedIntegerValue];
	}
	return A3_LCCF_MonthlyPayment;
}

- (void)setCalculationFor:(A3LoanCalcCalculationFor)calculationFor {
	NSDate *updateDate = [NSDate date];
	[[NSUserDefaults standardUserDefaults] setObject:updateDate forKey:A3LoanCalcUserDefaultsUpdateDate];
	[[NSUserDefaults standardUserDefaults] setObject:@(calculationFor) forKey:A3LoanCalcUserDefaultCalculationFor];
	[[NSUserDefaults standardUserDefaults] synchronize];

	if ([[A3SyncManager sharedSyncManager] isCloudEnabled]) {
		NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
		[store setObject:@(calculationFor) forKey:A3LoanCalcUserDefaultCalculationFor];
		[store setObject:updateDate forKey:A3LoanCalcUserDefaultsCloudUpdateDate];
		[store synchronize];
	}
}

- (BOOL)showDownPayment {
	NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:A3LoanCalcUserDefaultShowDownPayment];
	if (value) {
		return [value boolValue];
	}
	return YES;
}

- (void)setShowDownPayment:(BOOL)showDownPayment {
	NSDate *updateDate = [NSDate date];
	[[NSUserDefaults standardUserDefaults] setObject:updateDate forKey:A3LoanCalcUserDefaultsUpdateDate];
	[[NSUserDefaults standardUserDefaults] setBool:showDownPayment forKey:A3LoanCalcUserDefaultShowDownPayment];
	[[NSUserDefaults standardUserDefaults] synchronize];

	if ([[A3SyncManager sharedSyncManager] isCloudEnabled]) {
		NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
		[store setBool:showDownPayment forKey:A3LoanCalcUserDefaultShowDownPayment];
		[store setObject:updateDate forKey:A3LoanCalcUserDefaultsCloudUpdateDate];
		[store synchronize];
	}
}

- (BOOL)showExtraPayment {
	NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:A3LoanCalcUserDefaultShowExtraPayment];
	if (value) {
		return [value boolValue];
	}
	return YES;
}

- (void)setShowExtraPayment:(BOOL)showExtraPayment {
	NSDate *updateDate = [NSDate date];
	[[NSUserDefaults standardUserDefaults] setObject:updateDate forKey:A3LoanCalcUserDefaultsUpdateDate];
	[[NSUserDefaults standardUserDefaults] setBool:showExtraPayment forKey:A3LoanCalcUserDefaultShowExtraPayment];
	[[NSUserDefaults standardUserDefaults] synchronize];

	if ([[A3SyncManager sharedSyncManager] isCloudEnabled]) {
		NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
		[store setBool:showExtraPayment forKey:A3LoanCalcUserDefaultShowExtraPayment];
		[store setObject:updateDate forKey:A3LoanCalcUserDefaultsCloudUpdateDate];
		[store synchronize];
	}
}

- (BOOL)showAdvanced {
	NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:A3LoanCalcUserDefaultShowAdvanced];
	if (value) {
		return [value boolValue];
	}
    else {
        return NO;
    }
}

- (void)setShowAdvanced:(BOOL)showAdvanced {
	NSDate *updateDate = [NSDate date];
	[[NSUserDefaults standardUserDefaults] setObject:updateDate forKey:A3LoanCalcUserDefaultsUpdateDate];
	[[NSUserDefaults standardUserDefaults] setBool:showAdvanced forKey:A3LoanCalcUserDefaultShowAdvanced];
	[[NSUserDefaults standardUserDefaults] synchronize];

	if ([[A3SyncManager sharedSyncManager] isCloudEnabled]) {
		NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
		[store setBool:showAdvanced forKey:A3LoanCalcUserDefaultShowAdvanced];
		[store setObject:updateDate forKey:A3LoanCalcUserDefaultsCloudUpdateDate];
		[store synchronize];
	}
}

- (BOOL)useSimpleInterest {
	NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:A3LoanCalcUserDefaultUseSimpleInterest];
	if (value) {
		return [value boolValue];
	}
	return NO;
}

- (void)setUseSimpleInterest:(BOOL)useSimpleInterest {
	NSDate *updateDate = [NSDate date];
	[[NSUserDefaults standardUserDefaults] setObject:updateDate forKey:A3LoanCalcUserDefaultsUpdateDate];
	[[NSUserDefaults standardUserDefaults] setBool:useSimpleInterest forKey:A3LoanCalcUserDefaultUseSimpleInterest];
	[[NSUserDefaults standardUserDefaults] synchronize];

	if ([[A3SyncManager sharedSyncManager] isCloudEnabled]) {
		NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
		[store setBool:useSimpleInterest forKey:A3LoanCalcUserDefaultUseSimpleInterest];
		[store setObject:updateDate forKey:A3LoanCalcUserDefaultsCloudUpdateDate];
		[store synchronize];
	}
}

@end
