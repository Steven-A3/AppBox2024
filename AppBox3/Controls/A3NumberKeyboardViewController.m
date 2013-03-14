//
//  A3NumberKeyboardViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 12/21/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3NumberKeyboardViewController.h"
#import "QEntryTableViewCell+Extension.h"
#import "A3UIDevice.h"
#import "A3KeyboardMoveMarkView.h"
#import "A3UIKit.h"

@interface A3NumberKeyboardViewController ()

@property (nonatomic, strong) IBOutlet A3KeyboardButton *num1Button;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *num2Button;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *num3Button;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *num4Button;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *num5Button;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *num6Button;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *num7Button;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *num8Button;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *num9Button;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *num0Button;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *clearButton;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *doneButton;
@property (nonatomic, strong) IBOutlet A3KeyboardMoveMarkView *markView;

@end

@implementation A3NumberKeyboardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		_currencyCode = [numberFormatter currencyCode];
		_currencySymbol = [numberFormatter currencySymbol];
	}
    return self;
}

- (void)setKeyboardType:(A3NumberKeyboardType)keyboardType {
	_keyboardType = keyboardType;
	switch (keyboardType) {
		case A3NumberKeyboardTypeCurrency: {
			[self fillBigButtonTitleWith:_currencyCode bigButton2Title:@"%"];
			_bigButton1.blueColorOnHighlighted = NO;
			_bigButton2.blueColorOnHighlighted = NO;
			_bigButton1.selected = NO;
			_bigButton2.selected = NO;
			[_dotButton setTitle:@"." forState:UIControlStateNormal];
			break;
		}
		case A3NumberKeyboardTypePercent: {
			[self fillBigButtonTitleWith:@"%" bigButton2Title:@"$"];
			_bigButton1.blueColorOnHighlighted = NO;
			_bigButton2.blueColorOnHighlighted = NO;
			_bigButton1.selected = NO;
			_bigButton2.selected = NO;

			NSString *imageFilePath = [[NSBundle mainBundle] pathForResource:@"keyboard_calculator_black" ofType:@"png"];
			UIImage *image = [UIImage imageWithContentsOfFile:imageFilePath];
			[_bigButton2 setImage:image forState:UIControlStateNormal];
			imageFilePath = [[NSBundle mainBundle] pathForResource:@"keyboard_calculator_white" ofType:@"png"];
			image = [UIImage imageWithContentsOfFile:imageFilePath];
			[_bigButton2 setImage:image forState:UIControlStateHighlighted];
			[_bigButton2 setTitle:nil forState:UIControlStateNormal];
			[_dotButton setTitle:@"." forState:UIControlStateNormal];
			break;
		}
		case A3NumberKeyboardTypeMonthYear: {
			[self fillBigButtonTitleWith:@"Years" bigButton2Title:@"Months"];
			_bigButton1.blueColorOnHighlighted = YES;
			_bigButton2.blueColorOnHighlighted = YES;
			_bigButton1.selected = NO;
			_bigButton2.selected = NO;
			[_bigButton2 setImage:nil forState:UIControlStateNormal];
			[_bigButton2 setImage:nil forState:UIControlStateHighlighted];
			[_dotButton setTitle:nil forState:UIControlStateNormal];
			break;
		}
		case A3NumberKeyboardTypeInterestRate: {
			[self fillBigButtonTitleWith:@"% /year" bigButton2Title:@"% /month"];
			_bigButton1.blueColorOnHighlighted = YES;
			_bigButton2.blueColorOnHighlighted = YES;
			_bigButton1.selected = NO;
			_bigButton2.selected = NO;
			[_bigButton2 setImage:nil forState:UIControlStateNormal];
			[_bigButton2 setImage:nil forState:UIControlStateHighlighted];
			[_dotButton setTitle:@"." forState:UIControlStateNormal];
			break;
		}
	}
}

- (void)fillBigButtonTitleWith:(NSString *)defaultTitle1 bigButton2Title:(NSString *)defaultTitle2 {
	NSString *bigButton1Title = nil, *bigButton2Title = nil;
	id <A3NumberKeyboardDelegate> o = self.delegate;
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
	[_bigButton1 setTitle:bigButton1Title forState:UIControlStateNormal];
	[_bigButton2 setTitle:bigButton2Title forState:UIControlStateNormal];
}

- (void)setCurrencyCode:(NSString *)currencyCode {
	_currencyCode = currencyCode;
	[_bigButton1 setTitle:_currencyCode forState:UIControlStateNormal];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

	[self rotateToInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation] ];

	[_deleteButton setTitle:nil forState:UIControlStateNormal];
	[_deleteButton setImage:[A3UIKit backspaceImage] forState:UIControlStateNormal];
}

- (void)reloadPrevNextButtons {
	if ([_delegate respondsToSelector:@selector(nextAvailableForElement:)]) {
		BOOL available = [_delegate nextAvailableForElement:_element];
		[_nextButton setTitle:available ? @"Next" : @"" forState:UIControlStateNormal];
		[_nextButton setEnabled:available];
	} else {
		[_nextButton setTitle:@"Next" forState:UIControlStateNormal];
		[_nextButton setEnabled:YES];
	}
	if ([_delegate respondsToSelector:@selector(prevAvailableForElement:)]) {
		BOOL available = [_delegate prevAvailableForElement:_element];
		[_prevButton setTitle:available?@"Prev" : @"" forState:UIControlStateNormal];
		[_prevButton setEnabled:available];
	} else {
		[_prevButton setTitle:@"Prev" forState:UIControlStateNormal];
		[_prevButton setEnabled:YES];
	}
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
	if ([_keyInputDelegate respondsToSelector:@selector(insertText:)]) {
		[_keyInputDelegate insertText:[button titleForState:UIControlStateNormal]];
	}
}

- (IBAction)clearButtonAction {
	if ([_delegate respondsToSelector:@selector(clearButtonPressed)]) {
		[_delegate clearButtonPressed];
	}
}

- (IBAction)backspaceAction:(UIButton *)button {
	if ([_keyInputDelegate respondsToSelector:@selector(deleteBackward)]) {
		[_keyInputDelegate deleteBackward];
	}
}

- (IBAction)prevAction {
	if ([_delegate respondsToSelector:@selector(prevButtonPressedWithElement:)]) {
		[_delegate prevButtonPressedWithElement:_element];
	} else {
		[_entryTableViewCell handlePrevNextWithForNext:NO];
	}
}

- (IBAction)nextAction {
	if ([_delegate respondsToSelector:@selector(nextButtonPressedWithElement:)]) {
		[_delegate nextButtonPressedWithElement:_element];
	} else {
		[_entryTableViewCell handlePrevNextWithForNext:YES];
	}
}

- (IBAction)doneAction {
	[_entryTableViewCell handleActionBarDone:nil];
}

- (IBAction)bigButton1Action {
	if ((_keyboardType == A3NumberKeyboardTypeMonthYear) || (_keyboardType == A3NumberKeyboardTypeInterestRate)) {
		[_bigButton1 setSelected:YES];
		[_bigButton2 setSelected:NO];
	}
	if ([_delegate respondsToSelector:@selector(handleBigButton1)]) {
		[_delegate handleBigButton1];
	}
}

- (IBAction)bigButton2Action {
	if ((_keyboardType == A3NumberKeyboardTypeMonthYear) || (_keyboardType == A3NumberKeyboardTypeInterestRate)) {
		[_bigButton1 setSelected:NO];
		[_bigButton2 setSelected:YES];
	}
	if ([_delegate respondsToSelector:@selector(handleBigButton2)]) {
		[_delegate handleBigButton2];
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
	[_bigButton1 setFrame:CGRectMake(col_1, row_1, width_big, height_big)];
	[_bigButton2 setFrame:CGRectMake(col_1, row_3, width_big, height_big)];

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
	[_dotButton setFrame:CGRectMake(col_4, row_4, width_small, height_small)];

	[_deleteButton setFrame:CGRectMake(col_5, row_1, width_big, height_small)];
	[_prevButton setFrame:CGRectMake(col_5, row_2, width_big, height_small)];
	[_nextButton setFrame:CGRectMake(col_5, row_3, width_big, height_small)];
	[_doneButton setFrame:CGRectMake(col_5, row_4, width_big, height_small)];
}

@end
