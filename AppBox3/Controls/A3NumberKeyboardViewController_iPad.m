//
//  A3NumberKeyboardViewController_iPad.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 12/21/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3NumberKeyboardViewController_iPad.h"
#import "QEntryTableViewCell+Extension.h"
#import "A3KeyboardMoveMarkView.h"
#import "A3UIKit.h"

@interface A3NumberKeyboardViewController_iPad ()

@property (nonatomic, weak) IBOutlet A3KeyboardButton *num1Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton *num2Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton *num3Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton *num4Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton *num5Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton *num6Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton *num7Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton *num8Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton *num9Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton *num0Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton *clearButton;
@property (nonatomic, weak) IBOutlet A3KeyboardButton *doneButton;
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
	A3KeyboardButton *bigButton1 = (A3KeyboardButton *) self.bigButton1;
	A3KeyboardButton *bigButton2 = (A3KeyboardButton *) self.bigButton2;

	switch (keyboardType) {
		case A3NumberKeyboardTypeCurrency: {
			[self fillBigButtonTitleWith:self.currencyCode bigButton2Title:@"%"];
			bigButton1.blueColorOnHighlighted = NO;
			bigButton2.blueColorOnHighlighted = NO;
			bigButton1.selected = NO;
			bigButton2.selected = NO;
			[self.dotButton setTitle:@"." forState:UIControlStateNormal];
			break;
		}
		case A3NumberKeyboardTypePercent: {
			[self fillBigButtonTitleWith:@"%" bigButton2Title:@"$"];
			bigButton1.blueColorOnHighlighted = NO;
			bigButton2.blueColorOnHighlighted = NO;
			bigButton1.selected = NO;
			bigButton2.selected = NO;

			NSString *imageFilePath = [[NSBundle mainBundle] pathForResource:@"keyboard_calculator_black" ofType:@"png"];
			UIImage *image = [UIImage imageWithContentsOfFile:imageFilePath];
			[bigButton2 setImage:image forState:UIControlStateNormal];
			imageFilePath = [[NSBundle mainBundle] pathForResource:@"keyboard_calculator_white" ofType:@"png"];
			image = [UIImage imageWithContentsOfFile:imageFilePath];
			[bigButton2 setImage:image forState:UIControlStateHighlighted];
			[bigButton2 setTitle:nil forState:UIControlStateNormal];
			[self.dotButton setTitle:@"." forState:UIControlStateNormal];
			break;
		}
		case A3NumberKeyboardTypeMonthYear: {
			[self fillBigButtonTitleWith:@"Years" bigButton2Title:@"Months"];
			bigButton1.blueColorOnHighlighted = YES;
			bigButton2.blueColorOnHighlighted = YES;
			bigButton1.selected = NO;
			bigButton2.selected = NO;
			[bigButton2 setImage:nil forState:UIControlStateNormal];
			[bigButton2 setImage:nil forState:UIControlStateHighlighted];
			[self.dotButton setTitle:nil forState:UIControlStateNormal];
			break;
		}
		case A3NumberKeyboardTypeInterestRate: {
			[self fillBigButtonTitleWith:@"% /year" bigButton2Title:@"% /month"];
			bigButton1.blueColorOnHighlighted = YES;
			bigButton2.blueColorOnHighlighted = YES;
			bigButton1.selected = NO;
			bigButton2.selected = NO;
			[bigButton2 setImage:nil forState:UIControlStateNormal];
			[bigButton2 setImage:nil forState:UIControlStateHighlighted];
			[self.dotButton setTitle:@"." forState:UIControlStateNormal];
			break;
		}
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

	[self rotateToInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation] ];

	[self.deleteButton setTitle:nil forState:UIControlStateNormal];
	[self.deleteButton setImage:[A3UIKit backspaceImage] forState:UIControlStateNormal];
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

- (IBAction)keyboardInputAction:(UIButton *)button {
	if ([self.keyInputDelegate respondsToSelector:@selector(insertText:)]) {
		[self.keyInputDelegate insertText:[button titleForState:UIControlStateNormal]];
	}
}

- (IBAction)clearButtonAction {
	if ([self.delegate respondsToSelector:@selector(clearButtonPressed)]) {
		[self.delegate clearButtonPressed];
	}
}

- (IBAction)backspaceAction:(UIButton *)button {
	if ([self.keyInputDelegate respondsToSelector:@selector(deleteBackward)]) {
		[self.keyInputDelegate deleteBackward];
	}
}

- (IBAction)prevAction {
	if ([self.delegate respondsToSelector:@selector(prevButtonPressedWithElement:)]) {
		[self.delegate prevButtonPressedWithElement:self.element];
	} else {
		[self.entryTableViewCell handlePrevNextWithForNext:NO];
	}
}

- (IBAction)nextAction {
	if ([self.delegate respondsToSelector:@selector(nextButtonPressedWithElement:)]) {
		[self.delegate nextButtonPressedWithElement:self.element];
	} else {
		[self.entryTableViewCell handlePrevNextWithForNext:YES];
	}
}

- (IBAction)doneAction {
	if ([self.delegate respondsToSelector:@selector(A3KeyboardDoneButtonPressed)]) {
		[self.delegate A3KeyboardDoneButtonPressed];
	} else {
		[self.entryTableViewCell handleActionBarDone:nil];
	}
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
	if ([self.delegate respondsToSelector:@selector(nextAvailableForElement:)]) {
		BOOL available = [self.delegate nextAvailableForElement:self.element];
		[self.nextButton setTitle:available ? @"Next" : @"" forState:UIControlStateNormal];
		[self.nextButton setEnabled:available];
	} else {
		[self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
		[self.nextButton setEnabled:YES];
	}
	if ([self.delegate respondsToSelector:@selector(prevAvailableForElement:)]) {
		BOOL available = [self.delegate prevAvailableForElement:self.element];
		[self.prevButton setTitle:available?@"Prev" : @"" forState:UIControlStateNormal];
		[self.prevButton setEnabled:available];
	} else {
		[self.prevButton setTitle:@"Prev" forState:UIControlStateNormal];
		[self.prevButton setEnabled:YES];
	}
}

- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	CGFloat col_1, col_2, col_3, col_4, col_5;
	CGFloat row_1, row_2, row_3, row_4;
	CGFloat width_small, height_small, width_big, height_big;
	if (UIDeviceOrientationIsPortrait(toInterfaceOrientation)) {
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
