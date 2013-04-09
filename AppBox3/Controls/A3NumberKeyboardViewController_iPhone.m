//
//  A3NumberKeyboardViewController_iPhone.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/9/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3NumberKeyboardViewController_iPhone.h"
#import "A3KeyboardButton_iPhone.h"
#import "QEntryTableViewCell+Extension.h"
#import "A3UIKit.h"

@interface A3NumberKeyboardViewController_iPhone ()

@property (nonatomic, weak) IBOutlet A3KeyboardButton_iPhone *num1Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iPhone *num2Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iPhone *num3Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iPhone *num4Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iPhone *num5Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iPhone *num6Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iPhone *num7Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iPhone *num8Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iPhone *num9Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iPhone *num0Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iPhone *clearButton;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iPhone *doneButton;

@end

@implementation A3NumberKeyboardViewController_iPhone

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setKeyboardType:(A3NumberKeyboardType)keyboardType {
	_keyboardType = keyboardType;
	switch (keyboardType) {
		case A3NumberKeyboardTypeCurrency: {
			[self fillBigButtonTitleWith:_currencyCode bigButton2Title:@"%"];
			_bigButton1.blueColorOnSelectedState = NO;
			_bigButton2.blueColorOnSelectedState = NO;
			_bigButton1.selected = NO;
			_bigButton2.selected = NO;
			[_dotButton setTitle:@"." forState:UIControlStateNormal];
			break;
		}
		case A3NumberKeyboardTypePercent: {
			[self fillBigButtonTitleWith:@"%" bigButton2Title:@"$"];
			_bigButton1.blueColorOnSelectedState = NO;
			_bigButton2.blueColorOnSelectedState = NO;
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
			_bigButton1.blueColorOnSelectedState = YES;
			_bigButton2.blueColorOnSelectedState = YES;
			_bigButton1.selected = NO;
			_bigButton2.selected = NO;
			[_bigButton2 setImage:nil forState:UIControlStateNormal];
			[_bigButton2 setImage:nil forState:UIControlStateHighlighted];
			[_dotButton setTitle:nil forState:UIControlStateNormal];
			break;
		}
		case A3NumberKeyboardTypeInterestRate: {
			[self fillBigButtonTitleWith:@"% /year" bigButton2Title:@"% /month"];
			_bigButton1.blueColorOnSelectedState = YES;
			_bigButton2.blueColorOnSelectedState = YES;
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
	if ([_delegate respondsToSelector:@selector(A3KeyboardViewControllerDoneButtonPressed)]) {
		[_delegate A3KeyboardViewControllerDoneButtonPressed];
	} else {
		[_entryTableViewCell handleActionBarDone:nil];
	}
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

@end
