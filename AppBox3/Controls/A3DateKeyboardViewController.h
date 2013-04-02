//
//  A3DateKeyboardViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/28/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuickDialog.h"

@class A3DateKeyboardViewController;

typedef NS_ENUM(NSUInteger, A3DateKeyboardWorkingMode) {
	A3DateKeyboardWorkingModeYearMonthDay = 1,
	A3DateKeyboardWorkingModeYearMonth,
	A3DateKeyboardWorkingModeMonth
};

@protocol A3DateKeyboardDelegate <NSObject>
@optional
- (void)dateKeyboardValueChangedDate:(NSDate *)date element:(QEntryElement *)element;
- (BOOL)prevAvailableForElement:(QEntryElement *)element;
- (BOOL)nextAvailableForElement:(QEntryElement *)element;
- (void)prevButtonPressedWithElement:(QEntryElement *)element;
- (void)nextButtonPressedWithElement:(QEntryElement *)element;
- (void)A3KeyboardViewControllerDoneButtonPressed;

@end

@interface A3DateKeyboardViewController : UIViewController

@property (nonatomic)			A3DateKeyboardWorkingMode 	workingMode;
@property (nonatomic, weak)		UILabel 					*displayLabel;
@property (nonatomic, weak)		QEntryTableViewCell 		*entryTableViewCell;
@property (nonatomic, weak) 	QEntryElement				*element;
@property (nonatomic, weak) 	id<A3DateKeyboardDelegate> 	delegate;
@property (nonatomic, strong)	NSDate 						*date;

- (void)reloadPrevNextButtons;

- (void)resetToDefaultState;
- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

@end
