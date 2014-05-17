//
//  A3KeyboardProtocol.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/9/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

@protocol A3SearchViewControllerDelegate;
@class A3NumberKeyboardViewController;

typedef NS_ENUM(NSInteger, A3NumberKeyboardType) {
	A3NumberKeyboardTypeCurrency = 0,
	A3NumberKeyboardTypePercent,
	A3NumberKeyboardTypeMonthYear,
	A3NumberKeyboardTypeInterestRate,
    A3NumberKeyboardTypeFraction,
	A3NumberKeyboardTypeInteger,
	A3NumberKeyboardTypeReal
};

@protocol A3KeyboardDelegate <NSObject>
@optional

- (void)handleBigButton1;
- (void)handleBigButton2;
- (NSString *)stringForBigButton1;
- (NSString *)stringForBigButton2;

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate;
- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate;
- (void)keyboardViewController:(A3NumberKeyboardViewController *)vc fractionButtonPressed:(UIButton *)button;
- (void)keyboardViewController:(A3NumberKeyboardViewController *)vc plusMinusButtonPressed:(UIButton *)button;

- (BOOL)isPreviousEntryExists;
- (BOOL)isNextEntryExists;
- (void)prevButtonPressed;
- (void)nextButtonPressed;

@end
