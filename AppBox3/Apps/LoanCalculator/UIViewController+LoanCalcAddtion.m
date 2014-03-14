//
//  UIViewController+LoanCalcAddtion.m
//  A3TeamWork
//
//  Created by kihyunkim on 2014. 2. 16..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#import "UIViewController+LoanCalcAddtion.h"
#import <objc/runtime.h>

static char const *const key_loanFormatter					= "key_loanFormatter";

@implementation UIViewController (LoanCalcAddtion)

- (NSNumberFormatter *)loanFormatter {
	NSNumberFormatter *formatter = objc_getAssociatedObject(self, key_loanFormatter);
	if (nil == formatter) {
		formatter = [[NSNumberFormatter alloc] init];
		NSString *userCurrencyCode = nil;
		if ([self respondsToSelector:@selector(defaultLoanCurrencyCode)]) {
			userCurrencyCode = [self performSelector:@selector(defaultLoanCurrencyCode)];
			if ([userCurrencyCode length]) {
				[formatter setCurrencyCode:userCurrencyCode];
			}
		}
        
		[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
//        [formatter setMaximumFractionDigits:3];   // KJH, 기본 통화 fractionDigits 을 따르기 위해서
        
		objc_setAssociatedObject(self, key_loanFormatter, formatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return formatter;
}

- (void)setLoanFormatter:(NSNumberFormatter *)loanFormatter {
	objc_setAssociatedObject(self, key_loanFormatter, loanFormatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)defaultLoanCurrencyCode {
    return nil;
}

@end
