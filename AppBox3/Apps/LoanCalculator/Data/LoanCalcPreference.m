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
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"

NSString *const A3LoanCalcNotificationDownPaymentEnabled = @"A3LoanCalcNotificationDownPaymentEnabled";
NSString *const A3LoanCalcNotificationDownPaymentDisabled = @"A3LoanCalcNotificationDownPaymentDisabled";
NSString *const A3LoanCalcNotificationExtraPaymentEnabled = @"A3LoanCalcNotificationExtraPaymentEnabled";
NSString *const A3LoanCalcNotificationExtraPaymentDisabled = @"A3LoanCalcNotificationExtraPaymentDisabled";

@interface LoanCalcPreference ()

@end

@implementation LoanCalcPreference

- (BOOL)showDownPayment {
	NSNumber *value = [[A3SyncManager sharedSyncManager] objectForKey:A3LoanCalcUserDefaultShowDownPayment];
	if (value) {
		return [value boolValue];
	}
	return YES;
}

- (void)setShowDownPayment:(BOOL)showDownPayment {
	[[A3SyncManager sharedSyncManager] setBool:showDownPayment forKey:A3LoanCalcUserDefaultShowDownPayment state:A3DataObjectStateModified];
}

- (BOOL)showExtraPayment {
	NSNumber *value = [[A3SyncManager sharedSyncManager] objectForKey:A3LoanCalcUserDefaultShowExtraPayment];
	if (value) {
		return [value boolValue];
	}
	return YES;
}

- (void)setShowExtraPayment:(BOOL)showExtraPayment {
	[[A3SyncManager sharedSyncManager] setBool:showExtraPayment forKey:A3LoanCalcUserDefaultShowExtraPayment state:A3DataObjectStateModified];
}

- (BOOL)showAdvanced {
	NSNumber *value = [[A3SyncManager sharedSyncManager] objectForKey:A3LoanCalcUserDefaultShowAdvanced];
	if (value) {
		return [value boolValue];
	}
    else {
        return NO;
    }
}

- (void)setShowAdvanced:(BOOL)showAdvanced {
	[[A3SyncManager sharedSyncManager] setBool:showAdvanced forKey:A3LoanCalcUserDefaultShowAdvanced state:A3DataObjectStateModified];
}

@end
