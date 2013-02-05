//
//  A3CurrencyKeyboardViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 12/21/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3CurrencyKeyboardViewController.h"
#import "QEntryTableViewCell+Extension.h"
#import "A3KeyboardButton.h"
#import "common.h"
#import "A3UIDevice.h"
#import "A3KeyboardMoveMarkView.h"
#import "A3CurrencySelectViewController.h"

@interface A3CurrencyKeyboardViewController ()
@property (nonatomic, strong) IBOutlet A3KeyboardButton *bigButton1;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *bigButton2;
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
@property (nonatomic, strong) IBOutlet A3KeyboardButton *dotButton;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *deleteButton;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *prevButton;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *nextButton;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *doneButton;
@property (nonatomic, strong) IBOutlet A3KeyboardMoveMarkView *markView;
@property (nonatomic, strong) UIPopoverController *myPopoverController;

@end

@implementation A3CurrencyKeyboardViewController

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

- (void)setKeyboardType:(A3CurrencyKeyboardType)keyboardType {
	_keyboardType = keyboardType;
	[_bigButton1 setTitle:keyboardType == A3CurrencyKeyboardTypeCurrency ? _currencyCode : @"%" forState:UIControlStateNormal];
}

- (void)setCurrencyCode:(NSString *)currencyCode {
	_currencyCode = currencyCode;
	[_bigButton1 setTitle:_currencyCode forState:UIControlStateNormal];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	switch (_keyboardType) {
		case A3CurrencyKeyboardTypeCurrency: {
			[_bigButton1 setTitle:_currencyCode forState:UIControlStateNormal];
			NSString *imageFilePath = [[NSBundle mainBundle] pathForResource:@"keyboard_calculator_black" ofType:@"png"];
			UIImage *image = [UIImage imageWithContentsOfFile:imageFilePath];
			[_bigButton2 setImage:image forState:UIControlStateNormal];
			imageFilePath = [[NSBundle mainBundle] pathForResource:@"keyboard_calculator_white" ofType:@"png"];
			image = [UIImage imageWithContentsOfFile:imageFilePath];
			[_bigButton2 setImage:image forState:UIControlStateHighlighted];
			[_bigButton2 setTitle:nil forState:UIControlStateNormal];
			break;
		}
		case A3CurrencyKeyboardTypePercent:
			[_bigButton1 setTitle:@"%" forState:UIControlStateNormal];
			[_bigButton2 setTitle:_currencySymbol forState:UIControlStateNormal];
			break;
	}

	[self deviceOrientationDidChange];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewDidUnload {
	[super viewDidUnload];

	_myPopoverController = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (IBAction)backspaceAction:(UIButton *)button {
	if ([_keyInputDelegate respondsToSelector:@selector(deleteBackward)]) {
		[_keyInputDelegate deleteBackward];
	}
}

- (IBAction)prevAction {
	[_entryTableViewCell handlePrevNextWithForNext:NO];
}

- (IBAction)nextAction {
	[_entryTableViewCell handlePrevNextWithForNext:YES];
}

- (IBAction)doneAction {
	[_entryTableViewCell handleActionBarDone:nil];
}

- (IBAction)bigButton1Action {
	if ([_delegate respondsToSelector:@selector(handleBigButton1)]) {
		[_delegate handleBigButton1];
	}
}

- (IBAction)bigButton2Action {
	if ([_delegate respondsToSelector:@selector(handleBigButton2)]) {
		[_delegate handleBigButton2];
	}
}

- (void)deviceOrientationDidChange {

	if ([A3UIDevice deviceOrientationIsPortrait]) {
		CGFloat bigBtnWidth = 124.0, bigBtnHeight = 118.0;
		CGFloat btnWidth = 89.0, btnHeight = 57.0;
		[_bigButton1 setFrame:CGRectMake(74.0, 6.0, bigBtnWidth, bigBtnHeight)];
		[_bigButton2 setFrame:CGRectMake(74.0, 136.0, bigBtnWidth, bigBtnHeight)];

		[_num7Button setFrame:CGRectMake(237.0, 6.0, btnWidth, btnHeight)];
		[_num8Button setFrame:CGRectMake(338.0, 6.0, btnWidth, btnHeight)];
		[_num9Button setFrame:CGRectMake(440.0, 6.0, btnWidth, btnHeight)];

		[_num4Button setFrame:CGRectMake(237.0, 72.0, btnWidth, btnHeight)];
		[_num5Button setFrame:CGRectMake(338.0, 72.0, btnWidth, btnHeight)];
		[_num6Button setFrame:CGRectMake(440.0, 72.0, btnWidth, btnHeight)];

		[_num1Button setFrame:CGRectMake(237.0, 137.0, btnWidth, btnHeight)];
		[_num2Button setFrame:CGRectMake(338.0, 137.0, btnWidth, btnHeight)];
		[_num3Button setFrame:CGRectMake(440.0, 137.0, btnWidth, btnHeight)];

		[_clearButton setFrame:CGRectMake(237.0, 201.0, btnWidth, btnHeight)];
		[_num0Button setFrame:CGRectMake(338.0, 201.0, btnWidth, btnHeight)];
		[_dotButton setFrame:CGRectMake(440.0, 201.0, btnWidth, btnHeight)];

		[_deleteButton setFrame:CGRectMake(570.0, 6.0, bigBtnWidth, btnHeight)];
		[_prevButton setFrame:CGRectMake(570.0, 73.0, bigBtnWidth, btnHeight)];
		[_nextButton setFrame:CGRectMake(570.0, 136.0, bigBtnWidth, btnHeight)];
		[_doneButton setFrame:CGRectMake(570.0, 201.0, bigBtnWidth, btnHeight)];

		[_markView setFrame:CGRectMake(755.0, 219.0, 8.0, 24.0)];
	} else {
		CGFloat bigBtnWidth = 172.0, bigBtnHeight = 164.0;
		CGFloat btnWidth = 108.0, btnHeight = 77.0;
		[_bigButton1 setFrame:CGRectMake(114.0, 8.0, bigBtnWidth, bigBtnHeight)];
		[_bigButton2 setFrame:CGRectMake(114.0, 179.0, bigBtnWidth, bigBtnHeight)];

		[_num7Button setFrame:CGRectMake(332.0, 7.0, btnWidth, btnHeight)];
		[_num8Button setFrame:CGRectMake(455.0, 7.0, btnWidth, btnHeight)];
		[_num9Button setFrame:CGRectMake(578.0, 7.0, btnWidth, btnHeight)];

		[_num4Button setFrame:CGRectMake(332.0, 94.0, btnWidth, btnHeight)];
		[_num5Button setFrame:CGRectMake(455.0, 94.0, btnWidth, btnHeight)];
		[_num6Button setFrame:CGRectMake(578.0, 94.0, btnWidth, btnHeight)];

		[_num1Button setFrame:CGRectMake(332.0, 179.0, btnWidth, btnHeight)];
		[_num2Button setFrame:CGRectMake(455.0, 179.0, btnWidth, btnHeight)];
		[_num3Button setFrame:CGRectMake(578.0, 179.0, btnWidth, btnHeight)];

		[_clearButton setFrame:CGRectMake(332.0, 265.0, btnWidth, btnHeight)];
		[_num0Button setFrame:CGRectMake(455.0, 265.0, btnWidth, btnHeight)];
		[_dotButton setFrame:CGRectMake(578.0, 265.0, btnWidth, btnHeight)];

		[_deleteButton setFrame:CGRectMake(735.0, 8.0, bigBtnWidth, btnHeight)];
		[_prevButton setFrame:CGRectMake(735.0, 95.0, bigBtnWidth, btnHeight)];
		[_nextButton setFrame:CGRectMake(735.0, 179.0, bigBtnWidth, btnHeight)];
		[_doneButton setFrame:CGRectMake(735.0, 266.0, bigBtnWidth, btnHeight)];

		[_markView setFrame:CGRectMake(999.0, 282.0, 10.0, 24.0)];
	}
}

@end
