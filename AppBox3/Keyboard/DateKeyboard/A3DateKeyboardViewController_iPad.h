//
//  A3DateKeyboardViewController_iPad.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 05/22/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3DateKeyboardViewController.h"
#import "A3KeyboardButton_iOS7_iPad.h"

@interface A3DateKeyboardViewController_iPad : A3DateKeyboardViewController

@property (nonatomic, weak)	IBOutlet A3KeyboardButton_iOS7_iPad *yearButton;
@property (nonatomic, weak)	IBOutlet A3KeyboardButton_iOS7_iPad *monthButton;
@property (nonatomic, weak)	IBOutlet A3KeyboardButton_iOS7_iPad *dayButton;
@property (nonatomic, weak)	IBOutlet A3KeyboardButton_iOS7_iPad *num7_Jan_Button;
@property (nonatomic, weak)	IBOutlet A3KeyboardButton_iOS7_iPad *num8_Feb_Button;
@property (nonatomic, weak)	IBOutlet A3KeyboardButton_iOS7_iPad *num9_Mar_Button;
@property (nonatomic, weak)	IBOutlet A3KeyboardButton_iOS7_iPad *num4_Apr_Button;
@property (nonatomic, weak)	IBOutlet A3KeyboardButton_iOS7_iPad *num5_May_Button;
@property (nonatomic, weak)	IBOutlet A3KeyboardButton_iOS7_iPad *num6_Jun_Button;
@property (nonatomic, weak)	IBOutlet A3KeyboardButton_iOS7_iPad *num1_Jul_Button;
@property (nonatomic, weak)	IBOutlet A3KeyboardButton_iOS7_iPad *num2_Aug_Button;
@property (nonatomic, weak)	IBOutlet A3KeyboardButton_iOS7_iPad *num3_Sep_Button;
@property (nonatomic, weak)	IBOutlet A3KeyboardButton_iOS7_iPad *num0_Oct_Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iOS7_iPad *Nov_Button;
@property (nonatomic, weak)	IBOutlet A3KeyboardButton_iOS7_iPad *today_Dec_Button;
@property (nonatomic, weak)	IBOutlet A3KeyboardButton_iOS7_iPad *doneButton;

@end
