//
//  UIViewController(A3AppCategory)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/18/13 8:46 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "A3KeyboardDelegate.h"
#import "A3RootViewController_iPad.h"

extern NSString *const A3NotificationCurrencyButtonPressed;
extern NSString *const A3NotificationCalculatorButtonPressed;

@class A3NumberKeyboardViewController;
@class A3DateKeyboardViewController;
@class A3CurrencySelectViewController;
@class A3CalculatorViewController;

@interface UIViewController (NumberKeyboard) <A3KeyboardDelegate>

@property (nonatomic, strong) A3NumberKeyboardViewController *numberKeyboardViewController;
@property (nonatomic, strong) A3DateKeyboardViewController *dateKeyboardViewController;
@property (nonatomic, strong) NSNumberFormatter *currencyFormatter;
@property (nonatomic, strong) NSNumberFormatter *decimalFormatter;
@property (nonatomic, strong) NSNumberFormatter *percentFormatter;
@property (nonatomic, strong) UINavigationController *navigationControllerForKeyboard;
@property (nonatomic, weak) UIResponder *firstResponder;

- (A3RootViewController_iPad *)A3RootViewController;
- (A3NumberKeyboardViewController *)simpleNumberKeyboard;
- (A3NumberKeyboardViewController *)simplePrevNextNumberKeyboard;
- (A3NumberKeyboardViewController *)simplePrevNextClearNumberKeyboard;
- (A3NumberKeyboardViewController *)simpleUnitConverterNumberKeyboard;
- (A3NumberKeyboardViewController *)normalNumberKeyboard;
- (A3NumberKeyboardViewController *)passcodeKeyboard;
- (A3DateKeyboardViewController *)newDateKeyboardViewController;
- (NSString *)zeroCurrency;
- (NSString *)currencyFormattedString:(NSString *)source;
- (NSString *)percentFormattedString:(NSString *)source;
- (void)registerContentSizeCategoryDidChangeNotification;

- (void)removeContentSizeCategoryDidChangeNotification;

- (void)contentSizeDidChange:(NSNotification *)notification;
- (void)removeObserver;

- (UIColor *)tableViewSeparatorColor;
- (UIColor *)selectedTextColor;

- (A3CurrencySelectViewController *)presentCurrencySelectViewControllerWithCurrencyCode:(NSString *)currencyCode;
- (A3CalculatorViewController *)presentCalculatorViewController;

- (void)addNumberKeyboardNotificationObservers;
- (void)removeNumberKeyboardNotificationObservers;
- (void)currencySelectButtonAction:(NSNotification *)notification;
- (void)calculatorButtonAction;

@end
