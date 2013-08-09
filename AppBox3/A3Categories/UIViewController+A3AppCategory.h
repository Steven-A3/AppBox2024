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

- (A3NumberKeyboardViewController *)simpleNumberKeyboard;

- (NSString *)zeroCurrency;

- (UIImage *)navigationBarBackgroundImageForBarMetrics:(UIBarMetrics)barMetrics;

- (void)setBlackBackgroundImageForNavigationBar;

- (UIImage *)navigationBarSilverBackgroundImageForBarMetrics:(UIBarMetrics)barMetrics;

- (CAGradientLayer *)addTopGradientLayerToView:(UIView *)view position:(CGFloat)position;

- (CAGradientLayer *)addTopGradientLayerToWhiteView:(UIView *)view position:(CGFloat)position;

- (NSString *)currencyFormattedString:(NSString *)source;

- (NSString *)percentFormattedString:(NSString *)source;

- (void)alertCheck;

- (UIBarButtonItem *)barButtonItemWithTitle:(NSString *)title action:(SEL)selector;

- (UIBarButtonItem *)blackBarButtonItemWithTitle:(NSString *)title action:(SEL)selector;

- (void)addActionIcon:(NSString *)iconName title:(NSString *)title selector:(SEL)selector atIndex:(NSInteger)index1;

- (CGRect)boundsForRightSideView;

- (void)assignLeftBarButtonItemWithAppListWithSelector:(SEL)selector;

- (void)assignBackBarButtonItemWithAppListWithSelector:(SEL)selector;

- (UIView *)moreMenuViewWithButtons:(NSArray *)buttonsArray;

- (UIView *)presentMoreMenuWithButtons:(NSArray *)buttons tableView:(UITableView *)tableView;

- (void)dismissMoreMenuView:(UIView *)moreMenuView tableView:(UITableView *)tableView;

- (void)moreMenuDismissAction:(UITapGestureRecognizer *)gestureRecognizer;

- (UIButton *)shareButton;

- (void)shareButtonAction:(UIButton *)button;

- (UIButton *)historyButton;

- (void)historyButtonAction:(UIButton *)button;

- (UIButton *)settingsButton;

- (void)settingsButtonAction:(UIButton *)button;

- (void)registerContentSizeCategoryDidChangeNotification;

- (void)contentSizeDidChange:(NSNotification *)notification;

- (void)removeObserver;
@end