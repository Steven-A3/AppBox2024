//
//  A3NumberKeyboardSimpleVC_iPad
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/12/13 12:52 AM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3NumberKeyboardSimpleVC_iPad.h"
#import "A3UIDevice.h"


@implementation A3NumberKeyboardSimpleVC_iPad

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];

	[self rotateToInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	BOOL isLandscape = IS_LANDSCAPE;
	CGRect bounds = [A3UIDevice screenBoundsAdjustedWithOrientation];

	CGFloat col_1, col_2, col_3, col_4, col_5;
	CGFloat row_1, row_2, row_3, row_4;
	CGFloat width_small, height_small, width_big, height_big;
	CGFloat width_extra;
	if (IS_PORTRAIT) {
		CGFloat scaleX = bounds.size.height != 1024 ? bounds.size.width / 768 : 1.0;
		CGFloat scaleY = bounds.size.height != 1024 ? 1.22 : 1.0;
		CGFloat space1 = 16.0 * scaleX;
        width_big = 124.0 * scaleX; height_big = 118.0 * scaleY;
        width_small = 89.0 * scaleX; height_small = 57.0 * scaleY;
		col_1 = 74.0 * scaleX;
		col_2 = 237.0 * scaleX;
		col_3 = 338.0 * scaleX;
		col_4 = 440.0 * scaleX;
		col_5 = 570.0 * scaleX;
		row_1 = 6.0 * scaleY; row_2 = 72.0 * scaleY; row_3 = 137.0 * scaleY; row_4 = 201.0 * scaleY;
		width_extra = width_small * 2 + space1;
	} else {
		CGFloat scaleX = bounds.size.height != 768 ? bounds.size.height / 768 : 1.0;
		CGFloat scaleY = bounds.size.height != 768 ? 1.16 : 1.0;
        width_big = 172.0 * scaleX; height_big = 164.0 * scaleY;
        width_small = 108.0 * scaleX; height_small = 77.0 * scaleY;
		
		col_1 = 114.0 * scaleX;
		col_2 = 332.0 * scaleX;
		col_3 = 455.0 * scaleX;
		col_4 = 578.0 * scaleX;
		col_5 = 735.0 * scaleX;
		row_1 = 8.0 * scaleY; row_2 = 94.0 * scaleY; row_3 = 179.0 * scaleY; row_4 = 265.0 * scaleY;
		width_extra = col_3 + width_small - col_2;
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

	[self.dotButton setFrame:CGRectMake(col_4, row_4, width_small, height_small)];

	[self.deleteButton setFrame:CGRectMake(col_5, row_1, width_big, height_small)];
	// SimpleVC_iPad 에는 clearButton 과 calculationButton 이 있고,
	[self.calculatorButton setFrame:CGRectMake(col_5, row_3, width_big, height_small)];
	// SimplePrevNextVC_iPad 에는 prevButton 과 nextButton 이 있다.
	[self.prevButton setFrame:CGRectMake(col_5, row_2, width_big, height_small)];
	[self.fractionButton setFrame:CGRectMake(col_5, row_2, width_big, height_small)];
	[self.nextButton setFrame:CGRectMake(col_5, row_3, width_big, height_small)];
	[self.plusMinusButton setFrame:CGRectMake(col_5, row_3, width_big, height_small)];
	[self.doneButton setFrame:CGRectMake(col_5, row_4, width_big, height_small)];

	UIFont *numberFont = [UIFont systemFontOfSize:isLandscape ? 27 : 22];
	[self.num7Button.titleLabel setFont:numberFont];
	[self.num8Button.titleLabel setFont:numberFont];
	[self.num9Button.titleLabel setFont:numberFont];

	[self.num6Button.titleLabel setFont:numberFont];
	[self.num5Button.titleLabel setFont:numberFont];
	[self.num4Button.titleLabel setFont:numberFont];

	[self.num3Button.titleLabel setFont:numberFont];
	[self.num2Button.titleLabel setFont:numberFont];
	[self.num1Button.titleLabel setFont:numberFont];
	[self.num0Button.titleLabel setFont:numberFont];

	[self.clearButton.titleLabel setFont:[UIFont systemFontOfSize:isLandscape ? 25 : 18]];
	[self.doneButton.titleLabel setFont:[UIFont systemFontOfSize:isLandscape ? 25 : 18]];
	[self.prevButton.titleLabel setFont:[UIFont systemFontOfSize:isLandscape ? 25 : 18]];
	[self.fractionButton.titleLabel setFont:[UIFont systemFontOfSize:isLandscape ? 25 : 18]];
	[self.nextButton.titleLabel setFont:[UIFont systemFontOfSize:isLandscape ? 25 : 18]];
	[self.plusMinusButton.titleLabel setFont:[UIFont systemFontOfSize:isLandscape ? 25 : 18]];

	if (self.useDotAsClearButton) {
		[self.dotButton.titleLabel setFont:[UIFont systemFontOfSize:isLandscape ? 25 : 18]];
	} else {
		[self.dotButton.titleLabel setFont:[UIFont systemFontOfSize:isLandscape ? 33 : 28]];
	}

	if ([self.simpleKeyboardLayout unsignedIntegerValue] == A3NumberKeyboardSimpleLayoutHasPrevNextClear) {
		[self.clearButton setFrame:CGRectMake(col_2, row_4, width_small, height_small)];
		[self.num0Button setFrame:CGRectMake(col_3, row_4, width_small, height_small)];
	} else {
		[self.clearButton setFrame:CGRectMake(col_5, row_2, width_big, height_small)];
		[self.num0Button setFrame:CGRectMake(col_2, row_4, width_extra, height_small)];
	}

	if (self.plusMinusButton) {
		UIImage *image = [UIImage imageNamed:isLandscape ? @"minus_h" : @"minus_p"];
		[self.plusMinusButton setImage:image forState:UIControlStateNormal];
	}
}


@end
