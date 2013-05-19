//
//  UIViewController(A3AppCategory)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/18/13 8:46 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "A3ActionMenuViewControllerDelegate.h"
#import "A3KeyboardProtocol.h"

@class A3NumberKeyboardViewController;
@class A3FrequencyKeyboardViewController;
@class A3DateKeyboardViewController;

@interface UIViewController (A3AppCategory) <A3KeyboardDelegate>

@property (nonatomic, strong) UIViewController *actionMenuViewController;
@property (nonatomic, strong) A3NumberKeyboardViewController *numberKeyboardViewController;
@property (nonatomic, strong) A3FrequencyKeyboardViewController *frequencyKeyboardViewController;
@property (nonatomic, strong) A3DateKeyboardViewController *dateKeyboardViewController;
@property (nonatomic, strong) NSNumberFormatter *currencyFormatter;
@property (nonatomic, strong) NSNumberFormatter *decimalFormatter;
@property (nonatomic, strong) NSNumberFormatter *percentFormatter;

- (void)presentActionMenuWithDelegate:(id <A3ActionMenuViewControllerDelegate>)delegate;

- (void)presentEmptyActionMenu;

- (void)closeActionMenuViewWithAnimation:(BOOL)animate;
- (void)addToolsButtonWithAction:(SEL)action;
- (NSString *)zeroCurrency;

- (void)setBlackBackgroundImageForNavigationBar;
- (void)setSilverBackgroundImageForNavigationBar;

- (CAGradientLayer *)addTopGradientLayerToView:(UIView *)view;

- (NSString *)currencyFormattedString:(NSString *)source;

- (NSString *)percentFormattedString:(NSString *)source;

- (void)alertCheck;

- (UIBarButtonItem *)barButtonItemWithTitle:(NSString *)title action:(SEL)selector;

- (UIBarButtonItem *)blackBarButtonItemWithTitle:(NSString *)title action:(SEL)selector;
@end