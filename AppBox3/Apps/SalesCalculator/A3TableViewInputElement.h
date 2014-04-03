//
//  A3TableViewInputElement.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 20..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3JHTableViewElement.h"

typedef NS_ENUM(NSInteger, A3TableViewInputType) {
	A3TableViewEntryTypeText = 0,
	A3TableViewEntryTypeCurrency,
	A3TableViewEntryTypePercent,
	A3TableViewEntryTypeYears,
	A3TableViewEntryTypeRealNumber,
	A3TableViewEntryTypeInteger,
};

typedef NS_ENUM(NSInteger, A3TableElementValueType) {
	A3TableViewValueTypeCurrency = 0,
	A3TableViewValueTypePercent,
    A3TableViewValueTypeText,
    A3TableViewValueTypeNumber
};

typedef NS_ENUM(NSInteger, A3TableElementBigButtonType) {
    A3TableViewBigButtonTypeCurrency = 1,
    A3TableViewBigButtonTypePercent,
    A3TableViewBigButtonTypeCalculator
};

@class A3JHTableViewRootElement;
@class A3TableViewInputElement;
@class A3NumberKeyboardViewController;
@protocol A3CalculatorDelegate;
@protocol A3SearchViewControllerDelegate;

typedef void (^CellTextInputBlock)(A3TableViewInputElement *, UITextField *);
typedef void (^BasicBlock)(id sender);

@protocol A3TableViewInputElementDelegate <NSObject>
- (A3JHTableViewRootElement *)tableElementRootDataSource;
- (UIViewController *)containerViewController;
- (id<A3CalculatorDelegate>)delegateForCalculator;
- (id<A3SearchViewControllerDelegate>)delegateForCurrencySelector;
- (NSNumberFormatter *)currencyFormatterForTableViewInputElement;
@end

@interface A3TableViewInputElement : A3JHTableViewElement

@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, assign) A3TableViewInputType inputType;
@property (nonatomic, assign) BOOL prevEnabled;
@property (nonatomic, assign) BOOL nextEnabled;
@property (nonatomic, assign) A3TableElementValueType valueType;
@property (nonatomic, copy) NSString *currencyCode;
@property (nonatomic, weak) id<A3TableViewInputElementDelegate> delegate;
@property (nonatomic, copy) CellTextInputBlock onEditingBegin;
@property (nonatomic, copy) CellTextInputBlock onEditingFinished;
@property (nonatomic, copy) CellTextInputBlock onEditingFinishAll; // for SalesCalc addional
@property (nonatomic, copy) CellTextInputBlock onEditingValueChanged;
@property (nonatomic, copy) BasicBlock doneButtonPressed;
@property (nonatomic, strong) A3NumberKeyboardViewController * inputViewController;

@end
