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
- (void)A3KeyboardDoneButtonPressed;

@end

@interface A3DateKeyboardViewController : UIViewController

@property (nonatomic, weak)	IBOutlet UIButton *blankButton;
@property (nonatomic, weak)	IBOutlet UIButton *yearButton;
@property (nonatomic, weak)	IBOutlet UIButton *monthButton;
@property (nonatomic, weak)	IBOutlet UIButton *dayButton;
@property (nonatomic, weak)	IBOutlet UIButton *num7_Jan_Button;
@property (nonatomic, weak)	IBOutlet UIButton *num8_Feb_Button;
@property (nonatomic, weak)	IBOutlet UIButton *num9_Mar_Button;
@property (nonatomic, weak)	IBOutlet UIButton *num4_Apr_Button;
@property (nonatomic, weak)	IBOutlet UIButton *num5_May_Button;
@property (nonatomic, weak)	IBOutlet UIButton *num6_Jun_Button;
@property (nonatomic, weak)	IBOutlet UIButton *num1_Jul_Button;
@property (nonatomic, weak)	IBOutlet UIButton *num2_Aug_Button;
@property (nonatomic, weak)	IBOutlet UIButton *num3_Sep_Button;
@property (nonatomic, weak)	IBOutlet UIButton *clear_Dec_Button;
@property (nonatomic, weak)	IBOutlet UIButton *num0_Nov_Button;
@property (nonatomic, weak)	IBOutlet UIButton *today_Oct_Button;
@property (nonatomic, weak)	IBOutlet UIButton *blank2Button;
@property (nonatomic, weak)	IBOutlet UIButton *prevButton;
@property (nonatomic, weak)	IBOutlet UIButton *nextButton;
@property (nonatomic, weak)	IBOutlet UIButton *doneButton;

@property (nonatomic)			A3DateKeyboardWorkingMode 	workingMode;
@property (nonatomic, weak)		UILabel 					*displayLabel;
@property (nonatomic, weak)		QEntryTableViewCell 		*entryTableViewCell;
@property (nonatomic, weak) 	QEntryElement				*element;
@property (nonatomic, weak) 	id<A3DateKeyboardDelegate> 	delegate;
@property (nonatomic, strong)	NSDate 						*date;

- (void)initExtraLabels;

- (IBAction)switchToYear;

- (void)reloadPrevNextButtons;

- (NSArray *)monthOrder;

- (NSArray *)numberOrder;

- (IBAction)numberButtonAction:(UIButton *)button;

- (IBAction)prevButtonAction;

- (IBAction)nextButtonAction;

- (IBAction)doneButtonAction;

- (IBAction)clearButtonAction;

- (IBAction)todayButtonAction;

- (void)resetToDefaultState;
- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

- (void)layoutForWorkingMode;
@end
