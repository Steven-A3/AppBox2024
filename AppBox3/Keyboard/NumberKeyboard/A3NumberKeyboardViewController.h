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

@property (nonatomic, weak) UIResponder<UITextInput> *textInputTarget;		// TextField, TextView, ... responder
@property (nonatomic) 		A3NumberKeyboardType keyboardType;
@property (nonatomic, strong) NSString *currencySymbol;
@property (nonatomic, strong) NSString *currencyCode;
@property (nonatomic, weak) id<A3KeyboardDelegate> delegate;			// Handle big button one and two
@property (nonatomic, weak) IBOutlet UIButton *bigButton1;
@property (nonatomic, weak) IBOutlet UIButton *bigButton2;
@property (nonatomic, weak) IBOutlet UIButton *dotButton;

@property (nonatomic, strong) NSString * prevBtnTitleText;
@property (nonatomic, strong) NSString * nextBtnTitleText;
@property (nonatomic, strong) NSNumber *simpleKeyboardLayout;

- (void)reloadPrevNextButtons;
- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
- (void)setupLocale;

@end
