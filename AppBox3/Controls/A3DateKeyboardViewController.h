//
//  A3DateKeyboardViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/28/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

@class A3DateKeyboardViewController;

@protocol A3DateKeyboardDelegate <NSObject>
@optional

- (void)dateKeyboardValueChangedDate:(NSDate *)date;
- (void)dateKeyboardValueChangedDateComponents:(NSDateComponents *)dateComponents;
- (void)A3KeyboardDoneButtonPressed;

@end

@interface A3DateKeyboardViewController : UIViewController

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
@property (nonatomic, weak)	IBOutlet UIButton *num0_Oct_Button;
@property (nonatomic, weak) IBOutlet UIButton *Nov_Button;
@property (nonatomic, weak)	IBOutlet UIButton *today_Dec_Button;
@property (nonatomic, weak)	IBOutlet UIButton *doneButton;

@property (nonatomic, weak)	UILabel	*displayLabel;
@property (nonatomic, weak) id<A3DateKeyboardDelegate> delegate;
@property (nonatomic, strong) NSDateComponents *dateComponents;
@property (nonatomic, assign) BOOL isLunarDate;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

- (void)initExtraLabels;
- (IBAction)switchToYear;
- (NSArray *)monthOrder;
- (NSArray *)numberOrder;
- (IBAction)numberButtonAction:(UIButton *)button;
- (IBAction)doneButtonAction;
- (IBAction)todayButtonAction;

- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

@end
