//
//  A3NumberKeyboardViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/9/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3KeyboardDelegate.h"

typedef NS_ENUM(NSUInteger, A3NumberKeyboardSimpleLayout) {
	A3NumberKeyboardSimpleLayoutHasCalculator = 0,
	A3NumberKeyboardSimpleLayoutHasPrevNext,
	A3NumberKeyboardSimpleLayoutHasPrevNextClear
};

@interface A3NumberKeyboardViewController : UIViewController

@property (nonatomic, weak) UITextField *textInputTarget;		// TextField, TextView, ... responder
@property (nonatomic) 		A3NumberKeyboardType keyboardType;
@property (nonatomic, strong) NSString *currencySymbol;
@property (nonatomic, strong) NSString *currencyCode;
@property (nonatomic, weak) id<A3KeyboardDelegate> delegate;			// Handle big button one and two
@property (nonatomic, weak) IBOutlet UIButton *bigButton1;
@property (nonatomic, weak) IBOutlet UIButton *bigButton2;
@property (nonatomic, weak) IBOutlet UIButton *dotButton;
@property (nonatomic, weak) IBOutlet UIButton *prevButton;
@property (nonatomic, weak) IBOutlet UIButton *nextButton;
@property (nonatomic, weak) IBOutlet UIButton *clearButton;
@property (nonatomic, weak) IBOutlet UIButton *fractionButton;
@property (nonatomic, weak) IBOutlet UIButton *plusMinusButton;
@property (nonatomic, weak) IBOutlet UIButton *doneButton;

@property (nonatomic, strong) NSNumber *simpleKeyboardLayout;
@property (nonatomic, assign) BOOL useDotAsClearButton;
@property (nonatomic, assign) BOOL hidesLeftBigButtons;

- (void)reloadPrevNextButtons;
- (CGFloat)keyboardHeight;
- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
- (void)setupLocale;
- (void)presentCurrencySelectViewController;
- (IBAction)calculatorButtonAction:(UIButton *)sender;

@end
