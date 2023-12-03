//
//  A3PasscodeKeyboard_iPad.m
//  AppBox3
//
//  Created by A3 on 1/7/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3PasscodeKeyboard_iPad.h"
#import "A3UIDevice.h"

@implementation A3PasscodeKeyboard_iPad

- (void)viewWillLayoutSubviews {
	CGRect bounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	CGFloat col_1, col_2, col_3, col_4, col_5;
	CGFloat row_1, row_2, row_3, row_4;
	CGFloat width_small, height_small, width_big, height_big;
	CGFloat width_extra;
	
	if ([UIWindow interfaceOrientationIsPortrait]) {
		CGFloat scaleX = bounds.size.height != 1024 ? 1.25 : 1.0;
		CGFloat space1 = 16.0 * scaleX, space2 = 30.0 * scaleX;
        width_big = 124.0 * scaleX; height_big = 118.0 * scaleX;
        width_small = 108.0 * scaleX; height_small = 57.0 * scaleX;
		col_1 = (bounds.size.width - (width_small * 5 + space1 * 2 + space2 * 2)) / 2.0;
		col_2 = col_1 + width_small + space2;
		col_3 = col_2 + width_small + space1;
		col_4 = col_3 + width_small + space1;
		col_5 = col_4 + width_small + space2;
		row_1 = 9.0;
		row_2 = row_1 + height_small + 6.0;
		row_3 = row_2 + height_small + 6.0;
		row_4 = row_3 + height_small + 6.0;
		width_extra = width_small * 2 + space1;
	} else {
		CGFloat scaleX = bounds.size.height != 768 ? bounds.size.height / 768 : 1.0;
		CGFloat positionScaleY = bounds.size.height != 768 ? 1.16 : 1.0;
		CGFloat heightScaleY = bounds.size.height != 768 ? 1.16 : 1.0;
        width_big = 145.0 * scaleX; height_big = 164.0 * heightScaleY;
        width_small = 145.0 * scaleX; height_small = 76.0 * heightScaleY;
        col_1 = 114.0 * scaleX; col_2 = 275.0 * scaleX; col_3 = 440.0 * scaleX; col_4 = 605.0 * scaleX; col_5 = 790.0 * scaleX;
		row_1 = 11.0 * positionScaleY; row_2 = 98.0 * positionScaleY; row_3 = 182.0 * positionScaleY; row_4 = 268.0 * positionScaleY;
		width_extra = 308.0 * scaleX;
	}
	
	[self.num7Button setFrame:CGRectMake(col_2, row_1, width_small, height_small)];
	[self.num8Button setFrame:CGRectMake(col_3, row_1, width_small, height_small)];
	[self.num9Button setFrame:CGRectMake(col_4, row_1, width_small, height_small)];
	
	[self.num4Button setFrame:CGRectMake(col_2, row_2, width_small, height_small)];
	[self.num5Button setFrame:CGRectMake(col_3, row_2, width_small, height_small)];
	[self.num6Button setFrame:CGRectMake(col_4, row_2, width_small, height_small)];
	
	[self.num1Button setFrame:CGRectMake(col_2, row_3, width_small, height_small)];
	[self.num2Button setFrame:CGRectMake(col_3, row_3, width_small, height_small)];
	[self.num3Button setFrame:CGRectMake(col_4, row_3, width_small, height_small)];
	
	[self.num0Button setFrame:CGRectMake(col_2, row_4, width_extra, height_small)];
	[self.deleteButton setFrame:CGRectMake(col_4, row_4, width_small, height_small)];
}

@end
