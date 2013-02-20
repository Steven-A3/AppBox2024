//
//  A3CurrencyKeyboardViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 12/21/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuickDialog.h"
#import "A3KeyboardButton.h"

@protocol CurrencyKeyboardDelegate <NSObject>
@optional

- (void)handleBigButton1;
- (void)handleBigButton2;

@end

typedef NS_ENUM(NSInteger, A3CurrencyKeyboardType) {
	A3CurrencyKeyboardTypeCurrency = 0,
	A3CurrencyKeyboardTypePercent,
	A3CurrencyKeyboardTypeMonthYear
};

@interface A3CurrencyKeyboardViewController : UIViewController

@property (nonatomic, weak) UIResponder<UIKeyInput> *keyInputDelegate;		// TextField, TextView, ... responder
@property (nonatomic, weak) QEntryTableViewCell *entryTableViewCell;		// Handling Prev, Next button
@property (nonatomic) 		A3CurrencyKeyboardType keyboardType;
@property (nonatomic, strong) NSString *currencySymbol;
@property (nonatomic, strong) NSString *currencyCode;
@property (nonatomic, weak) id<CurrencyKeyboardDelegate> delegate;			// Handle big button one and two

@property (nonatomic, strong) IBOutlet A3KeyboardButton *bigButton1;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *bigButton2;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *dotButton;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *deleteButton;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *prevButton;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *nextButton;
@end
