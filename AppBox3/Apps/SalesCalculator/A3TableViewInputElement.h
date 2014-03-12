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
	A3TableViewEntryTypeYears,
	A3TableViewEntryTypeInterestRates,
	A3TableViewEntryTypeCalculator,
    A3TableViewEntryTypeTextView,
    A3TableViewEntryTypeSimpleNumber
};

typedef NS_ENUM(NSInteger, A3TableElementValueType) {
    A3TableViewValueTypePercent = 0,
    A3TableViewValueTypeCurrency,
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
typedef void (^CellTextInputBlock)(A3TableViewInputElement *, UITextField *);
typedef void (^BasicBlock)(id sender);

@protocol A3TableViewInputElementDelegate <NSObject>
-(A3JHTableViewRootElement *)tableElementRootDataSource;
@end

@interface A3TableViewInputElement : A3JHTableViewElement

@property (nonatomic, copy) NSString *placeholder;
@property (assign) A3TableViewInputType inputType;
@property (assign) BOOL prevEnabled;
@property (assign) BOOL nextEnabled;
@property (assign) A3TableElementValueType valueType;
@property (assign) A3TableElementBigButtonType bigButton1Type;
@property (assign) A3TableElementBigButtonType bigButton2Type;
@property (nonatomic, weak) id<A3TableViewInputElementDelegate> delegate;
@property (nonatomic, copy) CellTextInputBlock onEditingBegin;
@property (nonatomic, copy) CellTextInputBlock onEditingFinished;
@property (nonatomic, copy) CellTextInputBlock onEditingFinishAll; // for SalesCalc addional
@property (nonatomic, copy) CellTextInputBlock onEditingValueChanged;
@property (nonatomic, copy) BasicBlock doneButtonPressed;
@property (strong) A3NumberKeyboardViewController * inputViewController;
@end
