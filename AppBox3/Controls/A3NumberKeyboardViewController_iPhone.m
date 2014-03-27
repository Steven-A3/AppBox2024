//
//  A3NumberKeyboardViewController_iPhone.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/9/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3NumberKeyboardViewController_iPhone.h"
#import "A3KeyboardButton_iPhone.h"
#import "A3KeyboardButton_iOS7_iPhone.h"

@interface A3NumberKeyboardViewController_iPhone ()

@property (nonatomic, weak) IBOutlet A3KeyboardButton_iOS7_iPhone *num1Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iOS7_iPhone *num2Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iOS7_iPhone *num3Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iOS7_iPhone *num4Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iOS7_iPhone *num5Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iOS7_iPhone *num6Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iOS7_iPhone *num7Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iOS7_iPhone *num8Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iOS7_iPhone *num9Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iOS7_iPhone *num0Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iOS7_iPhone *clearButton;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iOS7_iPhone *doneButton;

@end

@implementation A3NumberKeyboardViewController_iPhone

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _needButtonsReload = YES;
    }
    return self;
}

- (void)setKeyboardType:(A3NumberKeyboardType)keyboardType {
	A3KeyboardButton_iPhone *bigButton1 = (A3KeyboardButton_iPhone *) self.bigButton1;
	A3KeyboardButton_iPhone *bigButton2 = (A3KeyboardButton_iPhone *) self.bigButton2;

	super.keyboardType = keyboardType;
	switch (keyboardType) {
		case A3NumberKeyboardTypeInteger:
		case A3NumberKeyboardTypeReal:
		case A3NumberKeyboardTypeCurrency: {
			[self fillBigButtonTitleWith:self.currencyCode bigButton2Title:@"%"];
			bigButton1.selected = NO;
			bigButton2.selected = NO;
			[self.dotButton setTitle:@"." forState:UIControlStateNormal];
			[self.dotButton setEnabled:YES];
			break;
		}
		case A3NumberKeyboardTypePercent: {
			[self fillBigButtonTitleWith:@"%" bigButton2Title:@"$"];
			bigButton1.selected = NO;
			bigButton2.selected = NO;

			UIImage *image = [UIImage imageNamed:@"keyboard_calculator_black.png"];
			[bigButton2 setImage:image forState:UIControlStateNormal];
			image = [UIImage imageNamed:@"keyboard_calculator_white"];
			[bigButton2 setImage:image forState:UIControlStateHighlighted];
			[bigButton2 setTitle:nil forState:UIControlStateNormal];
			[self.dotButton setTitle:@"." forState:UIControlStateNormal];
			[self.dotButton setEnabled:YES];
			break;
		}
		case A3NumberKeyboardTypeMonthYear: {
			[self fillBigButtonTitleWith:@"Years" bigButton2Title:@"Months"];
			bigButton1.selected = NO;
			bigButton2.selected = NO;
			[bigButton2 setImage:nil forState:UIControlStateNormal];
			[bigButton2 setImage:nil forState:UIControlStateHighlighted];
			[self.dotButton setTitle:nil forState:UIControlStateNormal];
			[self.dotButton setEnabled:NO];
			break;
		}
		case A3NumberKeyboardTypeInterestRate: {
			[self fillBigButtonTitleWith:@"% /yr" bigButton2Title:@"% /mo"];
			bigButton1.selected = NO;
			bigButton2.selected = NO;
			[bigButton2 setImage:nil forState:UIControlStateNormal];
			[bigButton2 setImage:nil forState:UIControlStateHighlighted];
			[self.dotButton setTitle:@"." forState:UIControlStateNormal];
			[self.dotButton setEnabled:YES];
			break;
		}
        case A3NumberKeyboardTypeFraction: {
			[self fillBigButtonTitleWith:@"x/y" bigButton2Title:@"Cal"];
			bigButton1.selected = NO;
			bigButton2.selected = YES;
			[self.dotButton setTitle:@"." forState:UIControlStateNormal];
			[self.dotButton setEnabled:YES];
			break;
		}
	}
	[self setupLocale];
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

- (void)reloadPrevNextButtons {
    if ([self.delegate respondsToSelector:@selector(stringForPrevButton:)]) {
        self.prevBtnTitleText = [self.delegate stringForPrevButton:self.prevBtnTitleText];
    }
    if ([self.delegate respondsToSelector:@selector(stringForNextButton:)]) {
        self.nextBtnTitleText = [self.delegate stringForNextButton:self.nextBtnTitleText];
    }

	BOOL available = NO;
	if ([self.delegate respondsToSelector:@selector(isNextEntryExists)]) {
		available = [self.delegate isNextEntryExists];
	}
	if (IS_IPAD) {
		[_nextButton setTitle:available ? @"Next" : nil forState:UIControlStateNormal];
	} else {
        if (self.nextBtnTitleText) {
            [_nextButton setImage:nil forState:UIControlStateNormal];
            [_nextButton setTitle:available ? self.nextBtnTitleText : nil forState:UIControlStateNormal];
            _nextButton.titleLabel.font = _doneButton.titleLabel.font;
        } else {
            UIImage *image = available ? [UIImage imageNamed:@"k_next"] : nil;
            [_nextButton setImage:image forState:UIControlStateNormal];
            [_nextButton setTitle:nil forState:UIControlStateNormal];
        }
	}
	[_nextButton setEnabled:available];

	available = NO;
	if ([self.delegate respondsToSelector:@selector(isPreviousEntryExists)]) {
		available = [self.delegate isPreviousEntryExists];
	}
	if (IS_IPAD) {
		[_prevButton setTitle:available ? @"Prev" : nil forState:UIControlStateNormal];
	} else {
        if (self.prevBtnTitleText) {
            [_prevButton setImage:nil forState:UIControlStateNormal];
            [_prevButton setTitle:available ? self.prevBtnTitleText : nil forState:UIControlStateNormal];
            _prevButton.titleLabel.font = _doneButton.titleLabel.font;
        } else {
            UIImage *image = available ? [UIImage imageNamed:@"k_previous"] : nil;
            [_prevButton setImage:image forState:UIControlStateNormal];
            [_prevButton setTitle:nil forState:UIControlStateNormal];
        }
	}
	[_prevButton setEnabled:available];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

    
    if (_needButtonsReload)
        [self reloadPrevNextButtons];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (IBAction)bigButton1Action {
	[[UIDevice currentDevice] playInputClick];
	
	//if ((self.keyboardType == A3NumberKeyboardTypeMonthYear) || (self.keyboardType == A3NumberKeyboardTypeInterestRate)) {
	if ((self.keyboardType == A3NumberKeyboardTypeMonthYear) || (self.keyboardType == A3NumberKeyboardTypeInterestRate) || (self.keyboardType == A3NumberKeyboardTypeCurrency)) {   // KJH
		[self.bigButton1 setSelected:YES];
		[self.bigButton2 setSelected:NO];
	}
	if ([self.delegate respondsToSelector:@selector(handleBigButton1)]) {
		[self.delegate handleBigButton1];
	}
}

- (IBAction)bigButton2Action {
	[[UIDevice currentDevice] playInputClick];

	//if ((self.keyboardType == A3NumberKeyboardTypeMonthYear) || (self.keyboardType == A3NumberKeyboardTypeInterestRate)) {
    if ((self.keyboardType == A3NumberKeyboardTypeMonthYear) || (self.keyboardType == A3NumberKeyboardTypeInterestRate) || (self.keyboardType == A3NumberKeyboardTypeCurrency)) {
		[self.bigButton1 setSelected:NO];
		[self.bigButton2 setSelected:YES];
	}
    
	if ([self.delegate respondsToSelector:@selector(handleBigButton2)]) {
		[self.delegate handleBigButton2];
	}
}

- (IBAction)calculatorButtonAction:(UIButton *)sender {
	[[UIDevice currentDevice] playInputClick];

}

@end
