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
	if ([_keyInputDelegate respondsToSelector:@selector(insertText:)]) {
		[_keyInputDelegate insertText:[button titleForState:UIControlStateNormal]];
	}
}

- (IBAction)clearButtonAction {
	if ([_delegate respondsToSelector:@selector(A3KeyboardController:clearButtonPressedTo:)]) {
		[_delegate A3KeyboardController:(id)self clearButtonPressedTo:_keyInputDelegate];
	}
}

- (IBAction)backspaceAction:(UIButton *)button {
	if ([_keyInputDelegate respondsToSelector:@selector(deleteBackward)]) {
		[_keyInputDelegate deleteBackward];
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
		[_delegate A3KeyboardController:self doneButtonPressedTo:_keyInputDelegate ];
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
