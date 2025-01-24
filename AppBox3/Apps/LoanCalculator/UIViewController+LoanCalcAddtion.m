//
//  UIViewController+LoanCalcAddtion.m
//  A3TeamWork
//
//  Created by kihyunkim on 2014. 2. 16..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#import "UIViewController+LoanCalcAddtion.h"
#import "A3LoanCalcContentsTableViewController.h"
#import <objc/runtime.h>
#import <AppBoxKit/AppBoxKit.h>

static char const *const key_loanFormatter	= "key_loanFormatter";

@implementation UIViewController (LoanCalcAddition)

- (NSNumberFormatter *)loanFormatter {
	A3NumberFormatter *formatter = objc_getAssociatedObject(self, key_loanFormatter);
	if (nil == formatter) {
		formatter = [[A3NumberFormatter alloc] init];
		NSString *userCurrencyCode = nil;
		if ([self respondsToSelector:@selector(defaultLoanCurrencyCode)]) {
			userCurrencyCode = [self performSelector:@selector(defaultLoanCurrencyCode)];
			if ([userCurrencyCode length]) {
				[formatter setCurrencyCode:userCurrencyCode];
            } else {
                [formatter setCurrencyCode:[A3UIDevice systemCurrencyCode]];
            }
        } else {
            [formatter setCurrencyCode:[A3UIDevice systemCurrencyCode]];
        }
        
		[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        
		objc_setAssociatedObject(self, key_loanFormatter, formatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return formatter;
}

- (void)setLoanFormatter:(NSNumberFormatter *)loanFormatter {
	objc_setAssociatedObject(self, key_loanFormatter, loanFormatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)defaultLoanCurrencyCode {
	NSString *customCurrencyCode = [[A3SyncManager sharedSyncManager] objectForKey:A3LoanCalcUserDefaultsCustomCurrencyCode];
	if ([customCurrencyCode length]) {
		return customCurrencyCode;
	}
	return nil;
}

@end
