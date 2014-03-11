//
//  A3NumberKeyboardViewController_iPad.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 12/21/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3NumberKeyboardViewController_iPad.h"
#import "A3KeyboardMoveMarkView.h"
#import "A3UIDevice.h"
#import "A3KeyboardButton_iOS7.h"

@interface A3NumberKeyboardViewController_iPad ()

@property (nonatomic, strong) IBOutlet A3KeyboardMoveMarkView *markView;

@end

@implementation A3NumberKeyboardViewController_iPad

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
	}
    return self;
}

- (void)setKeyboardType:(A3NumberKeyboardType)keyboardType {
	super.keyboardType = keyboardType;
	A3KeyboardButton_iOS7 *bigButton1 = (A3KeyboardButton_iOS7 *) self.bigButton1;
	A3KeyboardButton_iOS7 *bigButton2 = (A3KeyboardButton_iOS7 *) self.bigButton2;

	switch (keyboardType) {
		case A3NumberKeyboardTypeCurrency: {
			[self fillBigButtonTitleWith:self.currencyCode bigButton2Title:@"%"];
			bigButton1.selected = NO;
			bigButton2.selected = NO;
			[self.dotButton setTitle:@"." forState:UIControlStateNormal];
			break;
		}
		case A3NumberKeyboardTypePercent: {
			[self fillBigButtonTitleWith:@"%" bigButton2Title:@"$"];
			bigButton1.selected = NO;
			bigButton2.selected = NO;

			UIImage *image = [UIImage imageNamed:@"keyboard_calculator_black"];
			[bigButton2 setImage:image forState:UIControlStateNormal];
			image = [UIImage imageNamed:@"keyboard_calculator_white"];
			[bigButton2 setImage:image forState:UIControlStateHighlighted];
			[bigButton2 setTitle:nil forState:UIControlStateNormal];
			[self.dotButton setTitle:@"." forState:UIControlStateNormal];
			break;
		}
		case A3NumberKeyboardTypeMonthYear: {
			[self fillBigButtonTitleWith:@"Years" bigButton2Title:@"Months"];
			bigButton1.selected = NO;
			bigButton2.selected = NO;
			[bigButton2 setImage:nil forState:UIControlStateNormal];
			[bigButton2 setImage:nil forState:UIControlStateHighlighted];
			[self.dotButton setTitle:nil forState:UIControlStateNormal];
			break;
		}
		case A3NumberKeyboardTypeInterestRate: {
			[self fillBigButtonTitleWith:@"% /year" bigButton2Title:@"% /month"];
			bigButton1.selected = NO;
			bigButton2.selected = NO;
			[bigButton2 setImage:nil forState:UIControlStateNormal];
			[bigButton2 setImage:nil forState:UIControlStateHighlighted];
			[self.dotButton setTitle:@"." forState:UIControlStateNormal];
			break;
		}
		case A3NumberKeyboardTypeFraction:
			break;
	}
}

- (void)fillBigButtonTitleWith:(NSString *)defaultTitle1 bigButton2Title:(NSString *)defaultTitle2 {
	NSString *bigButton1Title = nil, *bigButton2Title = nil;
	id <A3KeyboardDelegate> o = self.delegate;
	if ([o respondsToSelector:@selector(stringForBigButton1)]) {
		bigButton1Title = [o stringForBigButton1];
	}
	if (bigButton1Title == nil) {
		bigButton1Title = defaultTitle1;
	}
	if ([o respondsToSelector:@selector(stringForBigButton2)]) {
		bigButton2Title = [o stringForBigButton2];
	}
	if (bigButton2Title == nil) {
		bigButton2Title = defaultTitle2;
	}
	[self.bigButton1 setTitle:bigButton1Title forState:UIControlStateNormal];
	[self.bigButton2 setTitle:bigButton2Title forState:UIControlStateNormal];
}

- (void)setCurrencyCode:(NSString *)currencyCode {
	super.currencyCode = currencyCode;
	[self.bigButton1 setTitle:self.currencyCode forState:UIControlStateNormal];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self reloadPrevNextButtons];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)bigButton1Action {
	if ((self.keyboardType == A3NumberKeyboardTypeMonthYear) || (self.keyboardType == A3NumberKeyboardTypeInterestRate)) {
		[self.bigButton1 setSelected:YES];
		[self.bigButton2 setSelected:NO];
	}
	if ([self.delegate respondsToSelector:@selector(handleBigButton1)]) {
		[self.delegate handleBigButton1];
	}
}

- (IBAction)bigButton2Action {
	if ((self.keyboardType == A3NumberKeyboardTypeMonthYear) || (self.keyboardType == A3NumberKeyboardTypeInterestRate)) {
		[self.bigButton1 setSelected:NO];
		[self.bigButton2 setSelected:YES];
	}
	if ([self.delegate respondsToSelector:@selector(handleBigButton2)]) {
		[self.delegate handleBigButton2];
	}
}

- (void)reloadPrevNextButtons {
	if ([self.delegate respondsToSelector:@selector(isNextEntryExists)]) {
		BOOL available = [self.delegate isNextEntryExists];
		[self.nextButton setTitle:available ? @"Next" : @"" forState:UIControlStateNormal];
		[self.nextButton setEnabled:available];
	} else {
		[self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
		[self.nextButton setEnabled:YES];
	}
	if ([self.delegate respondsToSelector:@selector(isPreviousEntryExists)]) {
		BOOL available = [self.delegate isPreviousEntryExists];
		[self.prevButton setTitle:available?@"Prev" : @"" forState:UIControlStateNormal];
		[self.prevButton setEnabled:available];
	} else {
		[self.prevButton setTitle:@"Prev" forState:UIControlStateNormal];
		[self.prevButton setEnabled:YES];
	}
}

- (void)viewWillLayoutSubviews {
	CGFloat col_1, col_2, col_3, col_4, col_5;
	CGFloat row_1, row_2, row_3, row_4;
	CGFloat width_small, height_small, width_big, height_big;
	if (IS_PORTRAIT) {
		width_big = 124.0, height_big = 118.0;
		width_small = 89.0, height_small = 57.0;
		col_1 = 74.0; col_2 = 237.0; col_3 = 338.0; col_4 = 440.0, col_5 = 570.0;
		row_1 = 6.0; row_2 = 72.0; row_3 = 137.0; row_4 = 201.0;

		[_markView setFrame:CGRectMake(755.0, 219.0, 8.0, 24.0)];
	} else {
		width_big = 172.0, height_big = 164.0;
		width_small = 108.0, height_small = 77.0;
		col_1 = 114.0; col_2 = 332.0; col_3 = 455.0; col_4 = 578.0, col_5 = 735.0;
		row_1 = 8.0; row_2 = 94.0; row_3 = 179.0; row_4 = 265.0;

		[_markView setFrame:CGRectMake(999.0, 282.0, 10.0, 24.0)];
	}
	[self.bigButton1 setFrame:CGRectMake(col_1, row_1, width_big, height_big)];
	[self.bigButton2 setFrame:CGRectMake(col_1, row_3, width_big, height_big)];

	[_num7Button setFrame:CGRectMake(col_2, row_1, width_small, height_small)];
	[_num8Button setFrame:CGRectMake(col_3, row_1, width_small, height_small)];
	[_num9Button setFrame:CGRectMake(col_4, row_1, width_small, height_small)];

	[_num4Button setFrame:CGRectMake(col_2, row_2, width_small, height_small)];
	[_num5Button setFrame:CGRectMake(col_3, row_2, width_small, height_small)];
	[_num6Button setFrame:CGRectMake(col_4, row_2, width_small, height_small)];

	[_num1Button setFrame:CGRectMake(col_2, row_3, width_small, height_small)];
	[_num2Button setFrame:CGRectMake(col_3, row_3, width_small, height_small)];
	[_num3Button setFrame:CGRectMake(col_4, row_3, width_small, height_small)];

	[_clearButton setFrame:CGRectMake(col_2, row_4, width_small, height_small)];
	[_num0Button setFrame:CGRectMake(col_3, row_4, width_small, height_small)];
	[self.dotButton setFrame:CGRectMake(col_4, row_4, width_small, height_small)];

	[self.deleteButton setFrame:CGRectMake(col_5, row_1, width_big, height_small)];
	[self.prevButton setFrame:CGRectMake(col_5, row_2, width_big, height_small)];
	[self.nextButton setFrame:CGRectMake(col_5, row_3, width_big, height_small)];
	[self.doneButton setFrame:CGRectMake(col_5, row_4, width_big, height_small)];
}

@end
