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

@dynamic yearButton, monthButton, dayButton, num7_Jan_Button, num8_Feb_Button, num9_Mar_Button, num4_Apr_Button, num5_May_Button, num6_Jun_Button;
@dynamic num1_Jul_Button, num2_Aug_Button, num3_Sep_Button, today_Oct_Button, num0_Nov_Button, delete_Dec_Button, doneButton;

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
	[self removeExtraLabelsForButton:self.today_Oct_Button];
	[self removeExtraLabelsForButton:self.num0_Nov_Button];
	[self removeExtraLabelsForButton:self.delete_Dec_Button];
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];

	[self rotateToInterfaceOrientation:self.interfaceOrientation];
}

- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	CGRect bounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	CGFloat col_1, col_2, col_3, col_4, col_5;
	CGFloat row_1, row_2, row_3, row_4;
	CGFloat width_small, height_small, width_big, height_big;

	BOOL portrait = UIDeviceOrientationIsPortrait((UIDeviceOrientation)toInterfaceOrientation);
	if (portrait) {
		CGFloat scaleX = bounds.size.height != 1024 ? bounds.size.width / 768 : 1.0;
		CGFloat scaleY = bounds.size.height != 1024 ? 1.22 : 1.0;
		width_big = 124.0 * scaleX; height_big = 118.0 * scaleY;
		width_small = 89.0 * scaleX; height_small = 57.0 * scaleY;
		col_1 = 74.0 * scaleX; col_2 = 237.0 * scaleX; col_3 = 338.0 * scaleX; col_4 = 440.0 * scaleX, col_5 = 570.0 * scaleX;
		row_1 = 6.0 * scaleY; row_2 = 72.0 * scaleY; row_3 = 137.0 * scaleY; row_4 = 201.0 * scaleY;
	} else {
		CGFloat scaleX = bounds.size.height != 768 ? bounds.size.height / 768 : 1.0;
		CGFloat scaleY = bounds.size.height != 768 ? 1.16 : 1.0;
		width_big = 172.0 * scaleX; height_big = 164.0 * scaleY;
		width_small = 108.0 * scaleX; height_small = 77.0 * scaleY;
		col_1 = 114.0 * scaleX; col_2 = 332.0 * scaleX; col_3 = 455.0 * scaleX; col_4 = 578.0 * scaleX, col_5 = 735.0 * scaleX;
		row_1 = 8.0 * scaleY; row_2 = 94.0 * scaleY; row_3 = 179.0 * scaleY; row_4 = 265.0 * scaleY;
	}

	[self.num7_Jan_Button setFrame:CGRectMake(col_2, row_1, width_small, height_small)];
	[self.num4_Apr_Button setFrame:CGRectMake(col_2, row_2, width_small, height_small)];
	[self.num1_Jul_Button setFrame:CGRectMake(col_2, row_3, width_small, height_small)];
	[self.today_Oct_Button setFrame:CGRectMake(col_2, row_4, width_small, height_small)];

	[self.num8_Feb_Button setFrame:CGRectMake(col_3, row_1, width_small, height_small)];
	[self.num5_May_Button setFrame:CGRectMake(col_3, row_2, width_small, height_small)];
	[self.num2_Aug_Button setFrame:CGRectMake(col_3, row_3, width_small, height_small)];
	[self.num0_Nov_Button setFrame:CGRectMake(col_3, row_4, width_small, height_small)];

	[self.num9_Mar_Button setFrame:CGRectMake(col_4, row_1, width_small, height_small)];
	[self.num6_Jun_Button setFrame:CGRectMake(col_4, row_2, width_small, height_small)];
	[self.num3_Sep_Button setFrame:CGRectMake(col_4, row_3, width_small, height_small)];
	[self.delete_Dec_Button setFrame:CGRectMake(col_4, row_4, width_small, height_small)];

	[self.yearButton setFrame:CGRectMake(col_5, row_1, width_big, height_small)];
	[self.monthButton setFrame:CGRectMake(col_5, row_2, width_big, height_small)];
	[self.dayButton setFrame:CGRectMake(col_5, row_3, width_big, height_small)];
	[self.doneButton setFrame:CGRectMake(col_5, row_4, width_big, height_small)];

	[self setupFonts];
}

- (void)setupFonts {
	BOOL portrait = IS_PORTRAIT;

	if ([self.yearButton isSelected] || [self.dayButton isSelected]) {
		NSArray *numbers = @[self.today_Oct_Button, self.num1_Jul_Button, self.num2_Aug_Button, self.num3_Sep_Button, self.num4_Apr_Button, self.num5_May_Button, self.num6_Jun_Button, self.num7_Jan_Button, self.num8_Feb_Button, self.num9_Mar_Button];
		[numbers enumerateObjectsUsingBlock:^(A3KeyboardButton_iOS7_iPad *button, NSUInteger idx, BOOL *stop) {
			button.titleLabel.font = [UIFont systemFontOfSize:portrait ? 22 : 27];
		}];
		[self.today_Oct_Button.titleLabel setFont:[UIFont systemFontOfSize:portrait ? 18 : 25]];
	} else {
		NSArray *months = @[self.num7_Jan_Button, self.num8_Feb_Button, self.num9_Mar_Button, self.num4_Apr_Button, self.num5_May_Button, self.num6_Jun_Button, self.num1_Jul_Button, self.num2_Aug_Button, self.num3_Sep_Button, self.today_Oct_Button, self.num0_Nov_Button, self.delete_Dec_Button];
		BOOL showNumber = [self.num7_Jan_Button.titleLabel.text rangeOfString:@"1"].location == NSNotFound;
		if (showNumber) {
			[months enumerateObjectsUsingBlock:^(A3KeyboardButton_iOS7_iPad *button, NSUInteger idx, BOOL *stop) {
				button.mainTitle.font = [UIFont systemFontOfSize:20];
				button.subTitle.font = [UIFont systemFontOfSize:portrait ? 15 : 17];
			}];
		} else {
			[months enumerateObjectsUsingBlock:^(A3KeyboardButton_iOS7_iPad *button, NSUInteger idx, BOOL *stop) {
				button.titleLabel.font = [UIFont systemFontOfSize:20];
			}];
		}
	}

	[self.yearButton.titleLabel setFont:[UIFont systemFontOfSize:portrait ? 18 : 25]];
	[self.monthButton.titleLabel setFont:[UIFont systemFontOfSize:portrait ? 18 : 25]];
	[self.dayButton.titleLabel setFont:[UIFont systemFontOfSize:portrait ? 18 : 25]];
	[self.doneButton.titleLabel setFont:[UIFont systemFontOfSize:portrait ? 18 : 25]];
}

@end
