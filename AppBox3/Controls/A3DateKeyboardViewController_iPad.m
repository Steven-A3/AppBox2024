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
@property (nonatomic, strong)	IBOutlet A3KeyboardMoveMarkView *markView;
@end

@implementation A3DateKeyboardViewController_iPad

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
    // 오영택 comment : 아래의 내용이 오류가 나서 주석 처리했습니다.
    // *** Terminating app due to uncaught exception 'NSUnknownKeyException', reason: '[<A3KeyboardButton_iOS7_iPad 0xb3d15d0> setValue:forUndefinedKey:]: this class is not key value coding-compliant for the key blueColorOnHighlighted.'
//	NSString *key = @"blueColorOnHighlighted";
//	[self.yearButton setValue:@YES forKey:key];
//	[self.monthButton setValue:@YES forKey:key];
//	[self.dayButton setValue:@YES forKey:key];
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
	[self removeExtraLabelsForButton:self.clear_Dec_Button];
	[self removeExtraLabelsForButton:self.num0_Nov_Button];
	[self removeExtraLabelsForButton:self.today_Oct_Button];
}

- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	CGFloat col_1, col_2, col_3, col_4, col_5;
	CGFloat row_1, row_2, row_3, row_4;
	CGFloat width_small, height_small, width_big, height_big;
	if (UIDeviceOrientationIsPortrait(toInterfaceOrientation)) {
		width_big = 124.0; height_big = 118.0;
		width_small = 89.0; height_small = 57.0;
		col_1 = 74.0; col_2 = 237.0; col_3 = 338.0; col_4 = 440.0, col_5 = 570.0;
		row_1 = 6.0; row_2 = 72.0; row_3 = 137.0; row_4 = 201.0;

		[_markView setFrame:CGRectMake(755.0, 219.0, 8.0, 24.0)];
	} else {
		width_big = 172.0; height_big = 164.0;
		width_small = 108.0; height_small = 77.0;
		col_1 = 114.0; col_2 = 332.0; col_3 = 455.0; col_4 = 578.0, col_5 = 735.0;
		row_1 = 8.0; row_2 = 94.0; row_3 = 179.0; row_4 = 265.0;

		[_markView setFrame:CGRectMake(999.0, 282.0, 10.0, 24.0)];
	}
	switch (self.workingMode) {
		case A3DateKeyboardWorkingModeYearMonthDay:
			[self.blankButton setFrame:CGRectMake(col_1, row_1, width_big, height_small)];
			[self.yearButton setFrame:CGRectMake(col_1, row_2, width_big, height_small)];
			[self.monthButton setFrame:CGRectMake(col_1, row_3, width_big, height_small)];
			[self.dayButton setFrame:CGRectMake(col_1, row_4, width_big, height_small)];
			break;
		case A3DateKeyboardWorkingModeYearMonth:
			[self.yearButton setFrame:CGRectMake(col_1, row_1, width_big, height_big)];
			[self.monthButton setFrame:CGRectMake(col_1, row_3, width_big, height_big)];
			break;
		case A3DateKeyboardWorkingModeMonth:
			break;
	}

	[self.num7_Jan_Button setFrame:CGRectMake(col_2, row_1, width_small, height_small)];
	[self.num4_Apr_Button setFrame:CGRectMake(col_2, row_2, width_small, height_small)];
	[self.num1_Jul_Button setFrame:CGRectMake(col_2, row_3, width_small, height_small)];
	[self.clear_Dec_Button setFrame:CGRectMake(col_2, row_4, width_small, height_small)];

	[self.num8_Feb_Button setFrame:CGRectMake(col_3, row_1, width_small, height_small)];
	[self.num5_May_Button setFrame:CGRectMake(col_3, row_2, width_small, height_small)];
	[self.num2_Aug_Button setFrame:CGRectMake(col_3, row_3, width_small, height_small)];
	[self.num0_Nov_Button setFrame:CGRectMake(col_3, row_4, width_small, height_small)];

	[self.num9_Mar_Button setFrame:CGRectMake(col_4, row_1, width_small, height_small)];
	[self.num6_Jun_Button setFrame:CGRectMake(col_4, row_2, width_small, height_small)];
	[self.num3_Sep_Button setFrame:CGRectMake(col_4, row_3, width_small, height_small)];
	[self.today_Oct_Button setFrame:CGRectMake(col_4, row_4, width_small, height_small)];

	[self.blank2Button setFrame:CGRectMake(col_5, row_1, width_big, height_small)];
	[self.prevButton setFrame:CGRectMake(col_5, row_2, width_big, height_small)];
	[self.nextButton setFrame:CGRectMake(col_5, row_3, width_big, height_small)];
	[self.doneButton setFrame:CGRectMake(col_5, row_4, width_big, height_small)];
}

- (IBAction)switchToMonth {
	self.yearButton.selected = NO;
	self.monthButton.selected = YES;
	self.dayButton.selected = NO;

	NSArray *order = [self monthOrder];

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	NSArray *monthSymbols = dateFormatter.shortMonthSymbols;
	NSUInteger idx = 0;
	for (A3KeyboardButton_iOS7 *button in order) {
		[button setTitle:@"" forState:UIControlStateNormal];
		button.mainTitle.text = [monthSymbols objectAtIndex:idx];
		idx++;
		button.subTitle.text = [NSString stringWithFormat:@"%lu", (unsigned long) idx];
	}
}

@end
