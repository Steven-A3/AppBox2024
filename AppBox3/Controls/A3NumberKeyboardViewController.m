//
//  A3NumberKeyboardViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/9/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3NumberKeyboardViewController.h"
#import "common.h"

@interface A3NumberKeyboardViewController ()

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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)keyboardInputAction:(UIButton *)button {
	NSString *pressedString = [button titleForState:UIControlStateNormal];
	BOOL allowedToChange = YES;

	if ([_textInputTarget isKindOfClass:[UITextField class]]) {
		UITextField *textField = (UITextField *) _textInputTarget;
		UITextRange *selectedRange = textField.selectedTextRange;
		NSUInteger location = (NSUInteger) [textField offsetFromPosition:textField.beginningOfDocument toPosition:selectedRange.start];
		NSUInteger length = (NSUInteger) [textField offsetFromPosition:selectedRange.start toPosition:selectedRange.end];
		NSRange range = NSMakeRange(location, length);
		FNLOG(@"%lu, %lu", (unsigned long)location, (unsigned long)length);
		id <UITextFieldDelegate> o = textField.delegate;
		if ([o respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
			allowedToChange = [o textField:textField shouldChangeCharactersInRange:range replacementString:pressedString];
		}
	}
	if (allowedToChange && [_textInputTarget respondsToSelector:@selector(insertText:)]) {
		[_textInputTarget insertText:pressedString];
	}
}

- (IBAction)clearButtonAction {
	if ([_delegate respondsToSelector:@selector(A3KeyboardController:clearButtonPressedTo:)]) {
		[_delegate A3KeyboardController:(id) self clearButtonPressedTo:_textInputTarget];
	}
}

- (IBAction)backspaceAction:(UIButton *)button {
	BOOL allowedToChange = YES;

	if ([_textInputTarget isKindOfClass:[UITextField class]]) {
		UITextField *textField = (UITextField *) _textInputTarget;
		UITextRange *selectedRange = textField.selectedTextRange;
		NSUInteger location = (NSUInteger) [textField offsetFromPosition:textField.beginningOfDocument toPosition:selectedRange.start];
		NSUInteger length = (NSUInteger) [textField offsetFromPosition:selectedRange.start toPosition:selectedRange.end];
		if (length == 0) {
			location = MAX(location - 1, 0);
			length = 1;
		}
		FNLOG(@"%lu, %lu", (unsigned long)location, (unsigned long)length);
		NSRange range = NSMakeRange(location, length);
		allowedToChange = [textField.delegate textField:textField shouldChangeCharactersInRange:range replacementString:@""];
	}
	if (allowedToChange && [_textInputTarget respondsToSelector:@selector(deleteBackward)]) {
		[_textInputTarget deleteBackward];
	}
}

- (IBAction)prevAction {
	if ([_delegate respondsToSelector:@selector(prevButtonPressed)]) {
		[_delegate prevButtonPressed];
	}
}

- (IBAction)nextAction {
	if ([_delegate respondsToSelector:@selector(nextButtonPressed)]) {
		[_delegate nextButtonPressed];
	}
}

- (IBAction)doneAction {
	if ([_delegate respondsToSelector:@selector(A3KeyboardController:doneButtonPressedTo:)]) {
		[_delegate A3KeyboardController:self doneButtonPressedTo:_textInputTarget];
	}
}

- (void)reloadPrevNextButtons {
}

- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
}

- (void)setCurrencyCode:(NSString *)currencyCode {
	_currencyCode = currencyCode;
	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	[nf setCurrencyCode:currencyCode];
	_currencySymbol = nf.currencySymbol;
	FNLOG(@"%@, %@", _currencyCode, _currencySymbol);
}

@end
