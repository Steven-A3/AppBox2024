//
//  A3SalesCalcQuickDialogViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 11/17/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuickDialog.h"
#import "A3NumberKeyboardViewController_iPad.h"
#import "A3CurrencySelectViewController.h"

@class SalesCalcHistory;
@class A3HorizontalBarContainerView;

typedef NS_ENUM(NSUInteger, A3SalesCalculatorType) {
	A3SalesCalculatorTypeSimple = 1,
	A3SalesCalculatorTypeAdvanced
};

typedef NS_ENUM(NSUInteger, A3SalesCalcEntryItemIndex) {
	A3SalesCalcEntryIndexPrice = 0,
	A3SalesCalcEntryIndexDiscount,
	A3SalesCalcEntryIndexAdditionalOff,
	A3SalesCalcEntryIndexTax,
	A3SalesCalcEntryIndexNotes,
};

typedef NS_ENUM(NSUInteger, A3SalesCalcKnownValue) {
	A3SalesCalcKnownValueOriginalPrice = 0,
	A3SalesCaleKnownValueSalePrice,
};

#define	SC_KEY_PRICE				@"PRICE"
#define SC_KEY_DISCOUNT				@"DISCOUNT"
#define SC_KEY_ADDITIONAL_OFF		@"ADDITIONAL_OFF"
#define SC_KEY_TAX					@"TAX"
#define SC_KEY_NOTES				@"NOTES"
#define SC_KEY_KNOWN_VALUE_SECTION	@"KNOWN_VALUE_SECTION"
#define SC_KEY_NUMBER_SECTION		@"NUMBERS_SECTION"

@interface A3SalesCalcQuickDialogViewController : QuickDialogController
		<QuickDialogStyleProvider, QuickDialogEntryElementDelegate, A3NumberKeyboardDelegate, CurrencySelectViewControllerDelegate>

@property (nonatomic, strong) A3NumberKeyboardViewController *keyboardViewController;
@property (nonatomic, strong) A3HorizontalBarContainerView *tableHeaderView;

- (void)applyCurrentContentsWithSalesCalcHistory:(SalesCalcHistory *)history;

@end
