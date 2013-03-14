//
//  A3NumberKeyboardViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 12/21/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuickDialog.h"
#import "A3KeyboardButton.h"

@class A3NumberKeyboardViewController;

@protocol A3NumberKeyboardDelegate <NSObject>
@optional

- (void)handleBigButton1;
- (void)handleBigButton2;
- (NSString *)stringForBigButton1;
- (NSString *)stringForBigButton2;
- (void)clearButtonPressed;

- (BOOL)prevAvailableForElement:(QEntryElement *)element;
- (BOOL)nextAvailableForElement:(QEntryElement *)element;
- (void)prevButtonPressedWithElement:(QEntryElement *)element;
- (void)nextButtonPressedWithElement:(QEntryElement *)element;

@end

typedef NS_ENUM(NSInteger, A3NumberKeyboardType) {
	A3NumberKeyboardTypeCurrency = 0,
	A3NumberKeyboardTypePercent,
	A3NumberKeyboardTypeMonthYear,
	A3NumberKeyboardTypeInterestRate
};

@interface A3NumberKeyboardViewController : UIViewController

@property (nonatomic, weak) UIResponder<UIKeyInput> *keyInputDelegate;		// TextField, TextView, ... responder
@property (nonatomic, weak) QEntryTableViewCell *entryTableViewCell;		// Handling Prev, Next button
@property (nonatomic, weak) QEntryElement *element;
@property (nonatomic) 		A3NumberKeyboardType keyboardType;
@property (nonatomic, strong) NSString *currencySymbol;
@property (nonatomic, strong) NSString *currencyCode;
@property (nonatomic, weak) id<A3NumberKeyboardDelegate> delegate;			// Handle big button one and two

@property (nonatomic, strong) IBOutlet A3KeyboardButton *bigButton1;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *bigButton2;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *dotButton;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *deleteButton;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *prevButton;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *nextButton;

- (void)reloadPrevNextButtons;

- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

@end
