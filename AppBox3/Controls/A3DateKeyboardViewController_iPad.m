//
//  A3DateKeyboardViewController_iPad.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 05/22/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3DateKeyboardViewController_iPad.h"
#import "A3KeyboardMoveMarkView.h"
#import "A3KeyboardButton_iOS7.h"

@interface A3DateKeyboardViewController_iPad ()
@end

@implementation A3DateKeyboardViewController_iPad

- (void)viewDidLoad
{
	[super viewDidLoad];

	[self setupSelectedColorForYearMonthDay];
}

- (void)setupSelectedColorForYearMonthDay {
	[self setupSelectedColor:(A3KeyboardButton_iOS7 *) self.yearButton];
	[self setupSelectedColor:(A3KeyboardButton_iOS7 *) self.monthButton];
	[self setupSelectedColor:(A3KeyboardButton_iOS7 *) self.dayButton];
}

- (void)setupSelectedColor:(A3KeyboardButton_iOS7 *)button {
	button.backgroundColorForDefaultState = [UIColor colorWithRed:193.0/255.0 green:196.0/255.0 blue:200.0/255.0 alpha:1.0];
	button.backgroundColorForSelectedState = self.view.tintColor;
}

- (void)removeExtraLabelsForButton:(UIButton *)button {
	A3KeyboardButton_iOS7 *aButton = (A3KeyboardButton_iOS7 *) button;
	if ([aButton respondsToSelector:@selector(removeExtraLabels)]) {
		[aButton removeExtraLabels];
	}
}

- (void)initExtraLabels {
	[self removeExtraLabelsForButton:self.num7_Jan_Button];
	[self removeExtraLabelsForButton:self.num8_Feb_Button];
	[self removeExtraLabelsForButton:self.num9_Mar_Button];
	[self removeExtraLabelsForButton:self.num4_Apr_Button];
	[self removeExtraLabelsForButton:self.num5_May_Button];
	[self removeExtraLabelsForButton:self.num6_Jun_Button];
	[self removeExtraLabelsForButton:self.num1_Jul_Button];
	[self removeExtraLabelsForButton:self.num2_Aug_Button];
	[self removeExtraLabelsForButton:self.num3_Sep_Button];
	[self removeExtraLabelsForButton:self.num0_Oct_Button];
	[self removeExtraLabelsForButton:self.Nov_Button];
	[self removeExtraLabelsForButton:self.today_Dec_Button];
}

- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	CGFloat col_1, col_2, col_3, col_4, col_5;
	CGFloat row_1, row_2, row_3, row_4;
	CGFloat width_small, height_small, width_big, height_big;
	CGFloat zeroWidth;
	
	if (UIDeviceOrientationIsPortrait(toInterfaceOrientation)) {
		width_big = 124.0; height_big = 118.0;
		width_small = 89.0; height_small = 57.0;
		col_1 = 74.0; col_2 = 237.0; col_3 = 338.0; col_4 = 440.0, col_5 = 570.0;
		row_1 = 6.0; row_2 = 72.0; row_3 = 137.0; row_4 = 201.0;
	} else {
		width_big = 172.0; height_big = 164.0;
		width_small = 108.0; height_small = 77.0;
		col_1 = 114.0; col_2 = 332.0; col_3 = 455.0; col_4 = 578.0, col_5 = 735.0;
		row_1 = 8.0; row_2 = 94.0; row_3 = 179.0; row_4 = 265.0;
	}
	if ([self.monthButton isSelected]) {
		zeroWidth = width_small;
	} else {
		zeroWidth = col_3 + width_small - col_2;
	}

	[self.num7_Jan_Button setFrame:CGRectMake(col_2, row_1, width_small, height_small)];
	[self.num4_Apr_Button setFrame:CGRectMake(col_2, row_2, width_small, height_small)];
	[self.num1_Jul_Button setFrame:CGRectMake(col_2, row_3, width_small, height_small)];
	[self.num0_Oct_Button setFrame:CGRectMake(col_2, row_4, zeroWidth, height_small)];

	[self.num8_Feb_Button setFrame:CGRectMake(col_3, row_1, width_small, height_small)];
	[self.num5_May_Button setFrame:CGRectMake(col_3, row_2, width_small, height_small)];
	[self.num2_Aug_Button setFrame:CGRectMake(col_3, row_3, width_small, height_small)];
	[self.Nov_Button setFrame:CGRectMake(col_3, row_4, width_small, height_small)];

	[self.num9_Mar_Button setFrame:CGRectMake(col_4, row_1, width_small, height_small)];
	[self.num6_Jun_Button setFrame:CGRectMake(col_4, row_2, width_small, height_small)];
	[self.num3_Sep_Button setFrame:CGRectMake(col_4, row_3, width_small, height_small)];
	[self.today_Dec_Button setFrame:CGRectMake(col_4, row_4, width_small, height_small)];

	[self.yearButton setFrame:CGRectMake(col_5, row_1, width_big, height_small)];
	[self.monthButton setFrame:CGRectMake(col_5, row_2, width_big, height_small)];
	[self.dayButton setFrame:CGRectMake(col_5, row_3, width_big, height_small)];
	[self.doneButton setFrame:CGRectMake(col_5, row_4, width_big, height_small)];
}

@end
