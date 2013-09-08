//
//  UIViewController(A3AppCategory)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/18/13 8:46 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "A3KeyboardProtocol.h"
#import "A3RootViewController_iPad.h"

@class A3NumberKeyboardViewController;
@class A3FrequencyKeyboardViewController;
@class A3DateKeyboardViewController;

@interface UIViewController (A3AppCategory) <A3KeyboardDelegate>

@property (nonatomic, strong) A3NumberKeyboardViewController *numberKeyboardViewController;
@property (nonatomic, strong) A3FrequencyKeyboardViewController *frequencyKeyboardViewController;
@property (nonatomic, strong) A3DateKeyboardViewController *dateKeyboardViewController;
@property (nonatomic, strong) NSNumberFormatter *currencyFormatter;
@property (nonatomic, strong) NSNumberFormatter *decimalFormatter;
@property (nonatomic, strong) NSNumberFormatter *percentFormatter;

- (A3RootViewController_iPad *)A3RootViewController;

- (A3NumberKeyboardViewController *)simpleNumberKeyboard;

- (NSString *)zeroCurrency;

- (NSString *)currencyFormattedString:(NSString *)source;

- (NSString *)percentFormattedString:(NSString *)source;

- (void)registerContentSizeCategoryDidChangeNotification;

- (void)contentSizeDidChange:(NSNotification *)notification;

- (void)removeObserver;

- (NSString *)currencyFormattedStringForCurrency:(NSString *)code value:(NSNumber *)value;

@end