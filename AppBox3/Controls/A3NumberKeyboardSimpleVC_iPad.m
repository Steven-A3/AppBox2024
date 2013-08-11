//
//  A3NumberKeyboardSimpleVC_iPad
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/12/13 12:52 AM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3NumberKeyboardSimpleVC_iPad.h"
#import "A3UIDevice.h"


@implementation A3NumberKeyboardSimpleVC_iPad {

}

- (void)viewWillLayoutSubviews {
	CGFloat col_1, col_2, col_3, col_4, col_5;
	CGFloat row_1, row_2, row_3, row_4;
	CGFloat width_small, height_small, width_big, height_big;
	CGFloat width_extra;
	if (IS_PORTRAIT) {
		CGFloat space1 = 16.0, space2 = 30.0;
		width_big = 124.0, height_big = 118.0;
		width_small = 108.0, height_small = 57.0;
		col_1 = (768.0 - (width_small * 5 + space1 * 2 + space2 * 2)) / 2.0;
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
		width_big = 145.0, height_big = 164.0;
		width_small = 145.0, height_small = 76.0;
		col_1 = 114.0; col_2 = 275.0; col_3 = 440.0; col_4 = 605.0, col_5 = 790.0;
		row_1 = 10.0; row_2 = 98.0; row_3 = 182.0; row_4 = 268.0;
		width_extra = 308.0;
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
	[self.dotButton setFrame:CGRectMake(col_4, row_4, width_small, height_small)];

	[self.deleteButton setFrame:CGRectMake(col_5, row_1, width_small, height_small)];
	[self.clearButton setFrame:CGRectMake(col_5, row_2, width_small, height_small)];
	[self.calculatorButton setFrame:CGRectMake(col_5, row_3, width_small, height_small)];
	[self.doneButton setFrame:CGRectMake(col_5, row_4, width_small, height_small)];
}

@end