//
//  UIViewController(A3AppCategory)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/18/13 8:46 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <objc/runtime.h>
#import "UIViewController+A3AppCategory.h"
#import "A3UIDevice.h"
#import "A3NumberKeyboardViewController.h"
#import "A3DateKeyboardViewController.h"
#import "A3NumberKeyboardViewController_iPad.h"
#import "A3NumberKeyboardViewController_iPhone.h"
#import "A3DateKeyboardViewController_iPad.h"
#import "A3DateKeyboardViewController_iPhone.h"
#import "A3AppDelegate.h"
#import "A3NumberKeyboardSimpleVC_iPad.h"

static char const *const key_numberKeyboardViewController 		= "key_numberKeyboardViewController";
static char const *const key_dateKeyboardViewController 		= "key_dateKeyboardViewController";
static char const *const key_currencyFormatter					= "key_currencyFormatter";
static char const *const key_decimalFormatter 					= "key_decimalFormatter";
static char const *const key_percentFormatter					= "key_percentFormatter";

@implementation UIViewController (A3AppCategory)

- (A3RootViewController_iPad *)A3RootViewController {
	return [[A3AppDelegate instance] rootViewController];
}

- (A3NumberKeyboardViewController *)iPadNumberKeyboard {
	return [[A3NumberKeyboardViewController_iPad alloc] initWithNibName:@"A3NumberKeyboardViewController_iPad" bundle:nil];
}

- (A3NumberKeyboardViewController *)simpleNumberKeyboard {
	A3NumberKeyboardViewController *viewController;
	if (IS_IPHONE) {
		viewController = [[A3NumberKeyboardViewController_iPhone alloc] initWithNibName:@"A3NumberKeyboardSimpleVC_iPhone" bundle:nil];
	} else {
		viewController = [[A3NumberKeyboardSimpleVC_iPad alloc] initWithNibName:@"A3NumberKeyboardSimpleVC_iPad" bundle:nil];
	}
	return viewController;
}

- (A3NumberKeyboardViewController *)normalNumberKeyboard {
	A3NumberKeyboardViewController *viewController;
	if (IS_IPAD) {
		viewController = [self iPadNumberKeyboard];
		viewController.delegate = self;
	} else {
		viewController = [[A3NumberKeyboardViewController_iPhone alloc] initWithNibName:@"A3NumberKeyboardViewController_iPhone" bundle:nil];
		viewController.delegate = self;
	}
	return viewController;
}

- (A3NumberKeyboardViewController *)numberKeyboardViewController {
	A3NumberKeyboardViewController *viewController = objc_getAssociatedObject(self, key_numberKeyboardViewController);
	if (nil == viewController) {
		viewController = [self normalNumberKeyboard];
		objc_setAssociatedObject(self, key_numberKeyboardViewController, viewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return viewController;
}

- (void)setNumberKeyboardViewController:(A3NumberKeyboardViewController *)keyboardViewController {
	objc_setAssociatedObject(self, key_numberKeyboardViewController, keyboardViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (A3DateKeyboardViewController *)dateKeyboardViewController {
	A3DateKeyboardViewController *viewController = objc_getAssociatedObject(self, key_dateKeyboardViewController);
	if (nil == viewController) {
		if (IS_IPAD) {
			viewController = [[A3DateKeyboardViewController_iPad alloc] initWithNibName:@"A3DateKeyboardViewController_iPad" bundle:nil];
		} else {
			viewController = [[A3DateKeyboardViewController_iPhone alloc] initWithNibName:@"A3DateKeyboardViewController_iPhone" bundle:nil];
		}
		viewController.delegate = (id <A3DateKeyboardDelegate>) self;
		viewController.workingMode = A3DateKeyboardWorkingModeYearMonthDay;
		objc_setAssociatedObject(self, key_dateKeyboardViewController, viewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return viewController;
}

- (void)setDateKeyboardViewController:(A3DateKeyboardViewController *)dateKeyboardViewController1 {
	objc_setAssociatedObject(self, key_dateKeyboardViewController, dateKeyboardViewController1, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)defaultCurrencyCode {
    return nil;
}

- (NSNumberFormatter *)currencyFormatter {
	NSNumberFormatter *formatter = objc_getAssociatedObject(self, key_currencyFormatter);
	if (nil == formatter) {
		formatter = [[NSNumberFormatter alloc] init];
		NSString *userCurrencyCode = nil;
		if ([self respondsToSelector:@selector(defaultCurrencyCode)]) {
			userCurrencyCode = [self performSelector:@selector(defaultCurrencyCode)];
			if ([userCurrencyCode length]) {
				[formatter setCurrencyCode:userCurrencyCode];
			}
		}

		[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		objc_setAssociatedObject(self, key_currencyFormatter, formatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return formatter;
}

- (void)setCurrencyFormatter:(NSNumberFormatter *)currencyFormatter {
	objc_setAssociatedObject(self, key_currencyFormatter, currencyFormatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumberFormatter *)decimalFormatter {
	NSNumberFormatter *formatter = objc_getAssociatedObject(self, key_decimalFormatter);
	if (nil == formatter) {
		formatter = [[NSNumberFormatter alloc] init];
		[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
		objc_setAssociatedObject(self, key_decimalFormatter, formatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return formatter;
}

- (void)setDecimalFormatter:(NSNumberFormatter *)decimalFormatter {
	objc_setAssociatedObject(self, key_decimalFormatter, decimalFormatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumberFormatter *)percentFormatter {
	NSNumberFormatter *formatter = objc_getAssociatedObject(self, key_percentFormatter);
	if (nil == formatter) {
		formatter = [[NSNumberFormatter alloc] init];
		[formatter setNumberStyle:NSNumberFormatterPercentStyle];
		objc_setAssociatedObject(self, key_percentFormatter, formatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return formatter;
}

- (void)setPercentFormatter:(NSNumberFormatter *)percentFormatter {
	objc_setAssociatedObject(self, key_percentFormatter, percentFormatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)zeroCurrency {
	return [self.currencyFormatter stringFromNumber: @0 ];
}

- (NSString *)currencyFormattedString:(NSString *)source {
	if ([source floatValue] == 0.0) return @"";
	return [self.currencyFormatter stringFromNumber:[NSNumber numberWithFloat:[source floatValue]]];
}

- (NSString *)percentFormattedString:(NSString *)source {
	if ([source floatValue] == 0.0) return @"";
	return [self.percentFormatter stringFromNumber:[NSNumber numberWithFloat:[source floatValue] / 100.0]];
}

/*! Register UIContentSizeCategoryDidChangeNotification
 *  You must to override - (void)contentSizeDidChange:(NSNotification *)notification
 */
- (void)registerContentSizeCategoryDidChangeNotification {
	@autoreleasepool {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentSizeDidChange:) name:UIContentSizeCategoryDidChangeNotification object:nil];
	}
}

- (void)contentSizeDidChange:(NSNotification *)notification {

}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)currencyFormattedStringForCurrency:(NSString *)code value:(NSNumber *)value {
	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	[nf setCurrencyCode:code];
	[nf setNumberStyle:NSNumberFormatterCurrencyStyle];

	if (IS_IPHONE) {
		[nf setCurrencySymbol:@""];
	}
	return [nf stringFromNumber:value];
}

@end
