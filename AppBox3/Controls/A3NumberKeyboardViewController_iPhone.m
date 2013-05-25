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
#import "SFKImage.h"
#import "A3UIDevice.h"

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
	A3KeyboardButton_iPhone *bigButton1 = (A3KeyboardButton_iPhone *) self.bigButton1;
	A3KeyboardButton_iPhone *bigButton2 = (A3KeyboardButton_iPhone *) self.bigButton2;

	super.keyboardType = keyboardType;
	switch (keyboardType) {
		case A3NumberKeyboardTypeCurrency: {
			[self fillBigButtonTitleWith:self.currencyCode bigButton2Title:@"%"];
			bigButton1.blueColorOnSelectedState = NO;
			bigButton2.blueColorOnSelectedState = NO;
			bigButton1.selected = NO;
			bigButton2.selected = NO;
			[_dotButton setTitle:@"." forState:UIControlStateNormal];
			break;
		}
		case A3NumberKeyboardTypePercent: {
			[self fillBigButtonTitleWith:@"%" bigButton2Title:@"$"];
			bigButton1.blueColorOnSelectedState = NO;
			bigButton2.blueColorOnSelectedState = NO;
			bigButton1.selected = NO;
			bigButton2.selected = NO;

			NSString *imageFilePath = [[NSBundle mainBundle] pathForResource:@"keyboard_calculator_black" ofType:@"png"];
			UIImage *image = [UIImage imageWithContentsOfFile:imageFilePath];
			[bigButton2 setImage:image forState:UIControlStateNormal];
			imageFilePath = [[NSBundle mainBundle] pathForResource:@"keyboard_calculator_white" ofType:@"png"];
			image = [UIImage imageWithContentsOfFile:imageFilePath];
			[bigButton2 setImage:image forState:UIControlStateHighlighted];
			[bigButton2 setTitle:nil forState:UIControlStateNormal];
			[_dotButton setTitle:@"." forState:UIControlStateNormal];
			break;
		}
		case A3NumberKeyboardTypeMonthYear: {
			[self fillBigButtonTitleWith:@"Years" bigButton2Title:@"Months"];
			bigButton1.blueColorOnSelectedState = YES;
			bigButton2.blueColorOnSelectedState = YES;
			bigButton1.selected = NO;
			bigButton2.selected = NO;
			[bigButton2 setImage:nil forState:UIControlStateNormal];
			[bigButton2 setImage:nil forState:UIControlStateHighlighted];
			[_dotButton setTitle:nil forState:UIControlStateNormal];
			break;
		}
		case A3NumberKeyboardTypeInterestRate: {
			[self fillBigButtonTitleWith:@"% /yr" bigButton2Title:@"% /mo"];
			bigButton1.blueColorOnSelectedState = YES;
			bigButton2.blueColorOnSelectedState = YES;
			bigButton1.selected = NO;
			bigButton2.selected = NO;
			[bigButton2 setImage:nil forState:UIControlStateNormal];
			[bigButton2 setImage:nil forState:UIControlStateHighlighted];
			[_dotButton setTitle:@"." forState:UIControlStateNormal];
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

	[_deleteButton setTitle:nil forState:UIControlStateNormal];
	[_deleteButton setImage:[A3UIKit backspaceImage2] forState:UIControlStateNormal];
}

- (void)initSymbolFont {
	[SFKImage setDefaultFont:[UIFont fontWithName:@"LigatureSymbols" size:30.0]];
	[SFKImage setDefaultColor:[UIColor whiteColor]];
}

- (void)reloadPrevNextButtons {
	[self initSymbolFont];

	BOOL available = NO;
	if ([self.delegate respondsToSelector:@selector(nextAvailableForElement:)]) {
		available = [self.delegate nextAvailableForElement:self.element];
	}
	if (DEVICE_IPAD) {
		[_nextButton setTitle:available ? @"Next" : nil forState:UIControlStateNormal];
	} else {
		UIImage *image = available ? [SFKImage imageNamed:@"arrowdown"] : nil;
		[_nextButton setImage:image forState:UIControlStateNormal];
	}
	[_nextButton setEnabled:available];

	available = NO;
	if ([self.delegate respondsToSelector:@selector(prevAvailableForElement:)]) {
		available = [self.delegate prevAvailableForElement:self.element];
	}
	if (DEVICE_IPAD) {
		[_prevButton setTitle:available ? @"Prev" : nil forState:UIControlStateNormal];
	} else {
		UIImage *image = available ? [SFKImage imageNamed:@"arrowup"] : nil;
		[_prevButton setImage:image forState:UIControlStateNormal];
	}
	[_prevButton setEnabled:available];
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

@end
