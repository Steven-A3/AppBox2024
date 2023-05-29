//
//  UIViewController(A3AppCategory)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/18/13 8:46 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <objc/runtime.h>
#import "UIViewController+NumberKeyboard.h"
#import "A3NumberKeyboardViewController.h"
#import "A3DateKeyboardViewController.h"
#import "A3NumberKeyboardViewController_iPad.h"
#import "A3NumberKeyboardViewController_iPhone.h"
#import "A3DateKeyboardViewController_iPad.h"
#import "A3DateKeyboardViewController_iPhone.h"
#import "A3AppDelegate.h"
#import "A3NumberKeyboardSimpleVC_iPad.h"
#import "A3PasscodeKeyboard_iPad.h"
#import "A3CurrencySelectViewController.h"
#import "A3CalculatorViewController.h"
#import "A3CalculatorViewController_iPhone.h"
#import "A3CalculatorViewController_iPad.h"
#import "UIViewController+iPad_rightSideView.h"
#import <AppBoxKit/AppBoxKit.h>

NSString *const A3NotificationCurrencyButtonPressed = @"A3NotificationCurrencyButtonPressed";
NSString *const A3NotificationCalculatorButtonPressed = @"A3NotificationCalculatorButtonPressed";

static char const *const key_numberKeyboardViewController 		= "key_numberKeyboardViewController";
static char const *const key_dateKeyboardViewController 		= "key_dateKeyboardViewController";
static char const *const key_currencyFormatter					= "key_currencyFormatter";
static char const *const key_decimalFormatter 					= "key_decimalFormatter";
static char const *const key_percentFormatter					= "key_percentFormatter";
static char const *const key_firstResponder 					= "key_firstResponder";
static char const *const key_navigationControllerForKeyboard	= "key_navigationControllerForKeyboard";

@implementation UIViewController (NumberKeyboard)

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

- (A3NumberKeyboardViewController *)simplePrevNextNumberKeyboard {
	A3NumberKeyboardViewController *viewController;
	if (IS_IPHONE) {
		viewController = [[A3NumberKeyboardViewController_iPhone alloc] initWithNibName:@"A3NumberKeyboardSimplePrevNextVC_iPhone" bundle:nil];
	} else {
		viewController = [[A3NumberKeyboardSimpleVC_iPad alloc] initWithNibName:@"A3NumberKeyboardSimplePrevNextVC_iPad" bundle:nil];
	}
	return viewController;
}

- (A3NumberKeyboardViewController *)simplePrevNextClearNumberKeyboard {
	A3NumberKeyboardViewController *viewController;
	if (IS_IPHONE) {
		viewController = [[A3NumberKeyboardViewController_iPhone alloc] initWithNibName:@"A3NumberKeyboardSimplePrevNextClearVC_iPhone" bundle:nil];
	} else {
		viewController = [[A3NumberKeyboardSimpleVC_iPad alloc] initWithNibName:@"A3NumberKeyboardSimplePrevNextClearVC_iPad" bundle:nil];
	}
	return viewController;
}

- (A3NumberKeyboardViewController *)simpleUnitConverterNumberKeyboard {
	A3NumberKeyboardViewController *viewController;
	if (IS_IPHONE) {
		viewController = [[A3NumberKeyboardViewController_iPhone alloc] initWithNibName:@"A3NumberKeyboardSimpleUnitConverterVC_iPhone" bundle:nil];
	} else {
		viewController = [[A3NumberKeyboardSimpleVC_iPad alloc] initWithNibName:@"A3NumberKeyboardSimpleUnitConverterVC_iPad" bundle:nil];
	}
	return viewController;
}

- (A3NumberKeyboardViewController *)normalNumberKeyboard {
	A3NumberKeyboardViewController *viewController;
	if (IS_IPAD) {
		viewController = [self iPadNumberKeyboard];
	} else {
		viewController = [[A3NumberKeyboardViewController_iPhone alloc] initWithNibName:@"A3NumberKeyboardViewController_iPhone" bundle:nil];
	}
	viewController.delegate = self;
	return viewController;
}

- (A3NumberKeyboardViewController *)passcodeKeyboard {
	A3NumberKeyboardViewController *viewController;
	if (IS_IPHONE) {
		viewController = [[A3NumberKeyboardViewController_iPhone alloc] initWithNibName:@"A3PasscodeKeyboard_iPhone" bundle:nil];
	} else {
		viewController = [[A3PasscodeKeyboard_iPad alloc] initWithNibName:@"A3PasscodeKeyboard_iPad" bundle:nil];
	}
	CGRect bounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	if (IS_IPHONE) {
		CGFloat scale = [A3UIDevice scaleToOriginalDesignDimension];
		viewController.view.bounds = CGRectMake(0, 0, bounds.size.width, 216 * scale);
	}
	viewController.keyboardType = A3NumberKeyboardTypePasscode;
	viewController.delegate = self;
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
	if (keyboardViewController == nil) {
#ifdef DEBUG
		NSArray *symbols = [NSThread callStackSymbols];
		for (NSString *symbol in symbols) {
			NSLog(@"%@", symbol);
		}
		FNLOG(@"🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨 SET numberKeyboardViewController to nil!");
#endif
	}
	objc_setAssociatedObject(self, key_numberKeyboardViewController, keyboardViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (A3DateKeyboardViewController *)newDateKeyboardViewController {
	A3DateKeyboardViewController *viewController;
	if (IS_IPAD) {
		viewController = [[A3DateKeyboardViewController_iPad alloc] initWithNibName:@"A3DateKeyboardViewController_iPad" bundle:nil];
	} else {
		viewController = [[A3DateKeyboardViewController_iPhone alloc] initWithNibName:@"A3DateKeyboardViewController_iPhone" bundle:nil];
	}
	viewController.delegate = (id <A3DateKeyboardDelegate>) self;
	[viewController view];
	return viewController;
}

- (A3DateKeyboardViewController *)dateKeyboardViewController {
	A3DateKeyboardViewController *viewController = objc_getAssociatedObject(self, key_dateKeyboardViewController);
	return viewController;
}

- (void)setDateKeyboardViewController:(A3DateKeyboardViewController *)dateKeyboardViewController1 {
	objc_setAssociatedObject(self, key_dateKeyboardViewController, dateKeyboardViewController1, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)defaultCurrencyCode {
    return nil;
}

- (NSNumberFormatter *)currencyFormatter {
	A3NumberFormatter *formatter = objc_getAssociatedObject(self, key_currencyFormatter);
	if (nil == formatter) {
		formatter = [[A3NumberFormatter alloc] init];
		NSString *userCurrencyCode = nil;
		if ([self respondsToSelector:@selector(defaultCurrencyCode)]) {
			userCurrencyCode = [self defaultCurrencyCode];
			if ([userCurrencyCode length]) {
				[formatter setCurrencyCode:userCurrencyCode];
			}
        }
        if ([formatter currencyCode] == nil) {
            [formatter setCurrencySymbol:@"$"];
            [formatter setCurrencyCode:@"USD"];
        }

		[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        FNLOG(@"%@", [[NSLocale systemLocale] currencyCode]);
        FNLOG(@"%@", formatter.currencySymbol);
        FNLOG(@"%@", formatter.currencyCode);
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
		[formatter setMaximumFractionDigits:3];
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
		[formatter setMaximumFractionDigits:3];
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
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentSizeDidChange:) name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)removeContentSizeCategoryDidChangeNotification {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)contentSizeDidChange:(NSNotification *)notification {

}

- (void)removeObserver {
}

- (UIColor *)tableViewSeparatorColor
{
    return [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
}

- (UIColor *)selectedTextColor {
	return [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0];
}

- (UIResponder *)editingObject {
	return objc_getAssociatedObject(self, key_firstResponder);
}

- (void)setEditingObject:(UIResponder *)editingObject {
	objc_setAssociatedObject(self, key_firstResponder, editingObject, OBJC_ASSOCIATION_ASSIGN);
}

- (UINavigationController *)navigationControllerForKeyboard {
	return objc_getAssociatedObject(self, key_navigationControllerForKeyboard);
}

- (void)setNavigationControllerForKeyboard:(UINavigationController *)controller {
	objc_setAssociatedObject(self, key_navigationControllerForKeyboard, controller, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (A3CurrencySelectViewController *)presentCurrencySelectViewControllerWithCurrencyCode:(NSString *)currencyCode {
	A3CurrencySelectViewController *viewController = [[A3CurrencySelectViewController alloc] init];
	viewController.showCancelButton = YES;
	viewController.allowChooseFavorite = YES;
	viewController.selectedCurrencyCode = currencyCode;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	[self presentViewController:navigationController animated:YES completion:nil];
	[self setNavigationControllerForKeyboard:navigationController];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(childViewControllerFromKeyboardDidDismiss) name:A3NotificationChildViewControllerDidDismiss object:viewController];
	return viewController;
}

- (A3CalculatorViewController *)presentCalculatorViewController {
	A3CalculatorViewController *viewController;
	if (IS_IPHONE) {
		viewController = [[A3CalculatorViewController_iPhone alloc] initWithPresentingViewController:self];
	} else {
		viewController = [[A3CalculatorViewController_iPad alloc] initWithPresentingViewController:self];
	}

	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
	[self presentViewController:navigationController animated:YES completion:nil];
	[self setNavigationControllerForKeyboard:navigationController];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(childViewControllerFromKeyboardDidDismiss) name:A3NotificationChildViewControllerDidDismiss object:viewController];
	return viewController;
}

- (void)childViewControllerFromKeyboardDidDismiss {
	FNLOG();
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationChildViewControllerDidDismiss object:self.navigationControllerForKeyboard.childViewControllers[0]];
	[self setNavigationControllerForKeyboard:nil];
}

- (void)addNumberKeyboardNotificationObservers {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currencySelectButtonAction:) name:A3NotificationCurrencyButtonPressed object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(calculatorButtonAction) name:A3NotificationCalculatorButtonPressed object:nil];
}

- (void)removeNumberKeyboardNotificationObservers {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCurrencyButtonPressed object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCalculatorButtonPressed object:nil];
}

- (void)currencySelectButtonAction:(NSNotification *)notification {
	FNLOG(@"이 member는 override를 전제로 한 virtual member 입니다. addNumberKeyboardNotificationObsservers를 사용했다면, 이 member도 구현해야 합니다.");
}

- (void)calculatorButtonAction {
	FNLOG(@"이 member는 override를 전제로 한 virtual member 입니다. addNumberKeyboardNotificationObsservers를 사용했다면, 이 member도 구현해야 합니다.");
}

@end
