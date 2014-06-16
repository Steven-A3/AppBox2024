//
//  A3NumberKeyboardViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/9/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3KeyboardButton_iOS7_iPhone.h"
#import "A3CalculatorViewController_iPad.h"
#import "A3CalculatorViewController_iPhone.h"
#import "A3CurrencySelectViewController.h"
#import "A3NumberKeyboardViewController_iPhone.h"
#import "A3NumberKeyboardViewController.h"
#import "A3AppDelegate.h"
#import "A3CacheStoreManager.h"
#import "CurrencyRateItem.h"
#import "UIViewController+NumberKeyboard.h"

@interface A3NumberKeyboardViewController ()

@end

@implementation A3NumberKeyboardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

	[self setupLocale];

	[self.doneButton setTitle:NSLocalizedString(@"DoneButton", nil) forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)keyboardInputAction:(UIButton *)button {
	[[UIDevice currentDevice] playInputClick];

	if (_useDotAsClearButton && button == _dotButton) {
		[self clearButtonAction];
		return;
	}
	NSString *inputString = [button titleForState:UIControlStateNormal];
	if (![inputString length]) {
		return;
	}
	BOOL allowedToChange = YES;

	if ([_textInputTarget isKindOfClass:[UITextField class]]) {
		UITextField *textField = (UITextField *) _textInputTarget;

		// Setup
		NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
		[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		if (self.currencyCode) {
			[numberFormatter setCurrencyCode:self.currencyCode];
		}

		// 0 뒤에 . 이 입력된 경우는 OK
		// 0 뒤에 0이 들어오면 무시
		// 0 뒤에 1~9가 들어오면 0을 없앤다.
		if ([textField.text length] == 1 && [textField.text isEqualToString:@"0"]) {
			if ([inputString isEqualToString:@"0"]) {
				// 입력을 처리하지 않는다.
				return;
			}
			if (![inputString isEqualToString:numberFormatter.decimalSeparator]) {
				textField.text = @"";
			}
		}

		// decimalSeparator 가 두번 들어가지 않도록
		// 화폐면 화폐별 소수점 이하 이상 입력되지 않도록
		// 실수면 소수점 3자리 이상 입력되지 않도록

		NSRange testRange = [textField.text rangeOfString:numberFormatter.decimalSeparator];
		if ([inputString isEqualToString:numberFormatter.decimalSeparator]) {
			if (testRange.location != NSNotFound) {
				return;
			}
		}

		if (testRange.location != NSNotFound) {
			NSUInteger maximumFractionDigits = 3;
			if (self.keyboardType == A3NumberKeyboardTypeCurrency || (self.keyboardType == A3NumberKeyboardTypePercent && [self.bigButton2 isSelected])) {
				maximumFractionDigits = numberFormatter.maximumFractionDigits;
			}
			NSArray *components = [textField.text componentsSeparatedByString:numberFormatter.decimalSeparator];
			if ([[components lastObject] length] >= maximumFractionDigits) {
				return;
			}
		} else {
			NSUInteger maximumIntegerDigits = IS_IPHONE ? 8 : 13;
			if ([textField.text length] >= maximumIntegerDigits) {
				return;
			}
		}

		UITextRange *selectedRange = textField.selectedTextRange;
		NSUInteger location = (NSUInteger) [textField offsetFromPosition:textField.beginningOfDocument toPosition:selectedRange.start];
		NSUInteger length = (NSUInteger) [textField offsetFromPosition:selectedRange.start toPosition:selectedRange.end];
		NSRange range = NSMakeRange(location, length);
		FNLOG(@"%lu, %lu", (unsigned long)location, (unsigned long)length);
		id <UITextFieldDelegate> delegate = textField.delegate;
		if ([delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
			allowedToChange = [delegate textField:textField shouldChangeCharactersInRange:range replacementString:inputString];
		}
	}
	if (allowedToChange && [_textInputTarget respondsToSelector:@selector(insertText:)]) {
		[_textInputTarget insertText:inputString];
	}
}

- (IBAction)clearButtonAction {
	[[UIDevice currentDevice] playInputClick];

	if ([_delegate respondsToSelector:@selector(A3KeyboardController:clearButtonPressedTo:)]) {
		[_delegate A3KeyboardController:(id) self clearButtonPressedTo:_textInputTarget];
	}
}

- (IBAction)backspaceAction:(UIButton *)button {
	[[UIDevice currentDevice] playInputClick];
	
	BOOL allowedToChange = YES;

	if ([_textInputTarget isKindOfClass:[UITextField class]]) {
		UITextField *textField = (UITextField *) _textInputTarget;
		UITextRange *selectedRange = textField.selectedTextRange;
		NSInteger location = [textField offsetFromPosition:textField.beginningOfDocument toPosition:selectedRange.start];
		NSInteger length = [textField offsetFromPosition:selectedRange.start toPosition:selectedRange.end];
		if (!location && !length) return;

		if (length == 0) {
			location = MAX(location - 1, 0);
			length = 1;
		}
		FNLOG(@"%lu, %lu", (unsigned long)location, (unsigned long)length);
		NSRange range = NSMakeRange(location, length);
		id <UITextFieldDelegate> o = textField.delegate;
		if ([o respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
			allowedToChange = [o textField:textField shouldChangeCharactersInRange:range replacementString:@""];
		}
	}
	if (allowedToChange && [_textInputTarget respondsToSelector:@selector(deleteBackward)]) {
		[_textInputTarget deleteBackward];
	}
}

- (IBAction)prevAction {
	[[UIDevice currentDevice] playInputClick];
	
	if ([_delegate respondsToSelector:@selector(prevButtonPressed)]) {
		[_delegate prevButtonPressed];
	}
}

- (IBAction)nextAction {
	[[UIDevice currentDevice] playInputClick];

	if ([_delegate respondsToSelector:@selector(nextButtonPressed)]) {
		[_delegate nextButtonPressed];
	}
}

- (IBAction)doneAction {
	[[UIDevice currentDevice] playInputClick];

	if ([_delegate respondsToSelector:@selector(A3KeyboardController:doneButtonPressedTo:)]) {
		[_delegate A3KeyboardController:self doneButtonPressedTo:_textInputTarget];
	}
}

- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
}

- (void)setCurrencyCode:(NSString *)currencyCode {
	_currencyCode = currencyCode;
	NSManagedObjectContext *context = [A3AppDelegate instance].cacheStoreManager.context;
	CurrencyRateItem *currencyInfo = [CurrencyRateItem MR_findFirstByAttribute:@"currencyCode" withValue:currencyCode inContext:context];
	_currencySymbol = currencyInfo.currencySymbol;
	FNLOG(@"%@, %@", _currencyCode, _currencySymbol);

	[self setupLocale];
}

- (void)setupLocale {
	FNLOG(@"%@", _currencyCode);
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	if ([_currencyCode length]) {
		[numberFormatter setCurrencyCode:_currencyCode];
	} else {
		_currencyCode = [numberFormatter currencyCode];
	}

	if (_useDotAsClearButton) {
		[self.dotButton setTitle:IS_IPHONE ? @"C" : NSLocalizedString(@"Clear", @"Clear") forState:UIControlStateNormal];
		self.dotButton.titleLabel.font = [UIFont systemFontOfSize:IS_LANDSCAPE ? 25 : 18];
	} else {
		switch (_keyboardType) {
			case A3NumberKeyboardTypeCurrency:
				if (numberFormatter.maximumFractionDigits > 0) {
					[self.dotButton setTitle:numberFormatter.decimalSeparator forState:UIControlStateNormal];
					[self.dotButton setEnabled:YES];
				} else {
					[self.dotButton setTitle:nil forState:UIControlStateNormal];
					[self.dotButton setEnabled:NO];
				}
				break;
			case A3NumberKeyboardTypeInterestRate:
			case A3NumberKeyboardTypeReal:
				[self.dotButton setTitle:numberFormatter.decimalSeparator forState:UIControlStateNormal];
				[self.dotButton setEnabled:YES];
				break;
			case A3NumberKeyboardTypePercent:
				// BigButton1 = %, BigButton2 = $
				if ([self.bigButton2 isSelected] && numberFormatter.maximumFractionDigits == 0) {
					[self.dotButton setTitle:nil forState:UIControlStateNormal];
					[self.dotButton setEnabled:NO];
				} else {
					[self.dotButton setTitle:numberFormatter.decimalSeparator forState:UIControlStateNormal];
					[self.dotButton setEnabled:YES];
				}
				break;
			case A3NumberKeyboardTypeMonthYear:
			case A3NumberKeyboardTypeInteger:
			case A3NumberKeyboardTypeFraction:
				[self.dotButton setTitle:nil forState:UIControlStateNormal];
				[self.dotButton setEnabled:NO];
				break;
		}
	}
	switch (_keyboardType) {
		case A3NumberKeyboardTypeInteger:
		case A3NumberKeyboardTypeReal:
		case A3NumberKeyboardTypeCurrency:
			[self fillBigButtonTitleWith:self.currencyCode bigButton2Title:@""];
			break;
		case A3NumberKeyboardTypePercent:
			[self fillBigButtonTitleWith:@"%" bigButton2Title:_currencySymbol];
			break;
		default:
			break;
	}
}

- (void)reloadPrevNextButtons {
	BOOL available = NO;
	if ([self.delegate respondsToSelector:@selector(isNextEntryExists)]) {
		available = [self.delegate isNextEntryExists];
	}

	[_nextButton setTitle:available ? NSLocalizedString(@"Next", @"Next") : nil forState:UIControlStateNormal];
	[_nextButton setEnabled:available];

	available = NO;
	if ([self.delegate respondsToSelector:@selector(isPreviousEntryExists)]) {
		available = [self.delegate isPreviousEntryExists];
	}
	[_prevButton setTitle:available ? NSLocalizedString(@"Prev", @"Prev") : nil forState:UIControlStateNormal];
	[_prevButton setEnabled:available];

	[self setupLocale];
}

- (void)setKeyboardType:(A3NumberKeyboardType)keyboardType {
	_keyboardType = keyboardType;

	UIButton *bigButton1 = self.bigButton1;
	UIButton *bigButton2 = self.bigButton2;

	// Initialize
	[bigButton2 setImage:nil forState:UIControlStateNormal];
	bigButton1.selected = NO;
	bigButton2.selected = NO;

	switch (keyboardType) {
		case A3NumberKeyboardTypeInteger:
		case A3NumberKeyboardTypeReal:
		case A3NumberKeyboardTypeCurrency: {
			[self setBigButton2CalculatorImage];
			if (IS_IPHONE) {
				[self.bigButton1.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
				[self.bigButton2.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
			}
			break;
		}
		case A3NumberKeyboardTypePercent: {
			[self fillBigButtonTitleWith:@"%" bigButton2Title:@"$"];
			bigButton1.selected = YES;
			if (IS_IPHONE) {
				[self.bigButton1.titleLabel setFont:[UIFont systemFontOfSize:26.0]];
				[self.bigButton2.titleLabel setFont:[UIFont systemFontOfSize:26.0]];
			}
			break;
		}
		case A3NumberKeyboardTypeMonthYear: {
			[self fillBigButtonTitleWith:NSLocalizedString(@"Years", @"Years") bigButton2Title:@"Months"];
			bigButton1.selected = YES;
			if (IS_IPHONE) {
				[self.bigButton1.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
				[self.bigButton2.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
			}
			break;
		}
		case A3NumberKeyboardTypeInterestRate: {
			[self fillBigButtonTitleWith:@"%/yr" bigButton2Title:@"%/mo"];
			bigButton1.selected = YES;
			if (IS_IPHONE) {
				[self.bigButton1.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
				[self.bigButton2.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
			}
			break;
		}
        case A3NumberKeyboardTypeFraction: {
			[self fillBigButtonTitleWith:@"x/y" bigButton2Title:@""];
			[self setBigButton2CalculatorImage];
			if (IS_IPHONE) {
				[self.bigButton1.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
				[self.bigButton2.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
			}
			break;
		}
	}
	[self setupLocale];
}

- (IBAction)bigButton1Action {
	[[UIDevice currentDevice] playInputClick];

	switch (self.keyboardType) {
		case A3NumberKeyboardTypeCurrency:
			// Launch Currency Select View
			[self presentCurrencySelectViewController];
			return;
		case A3NumberKeyboardTypePercent:
		case A3NumberKeyboardTypeMonthYear:
		case A3NumberKeyboardTypeInterestRate:
			[self.bigButton1 setSelected:YES];
			[self.bigButton2 setSelected:NO];
		case A3NumberKeyboardTypeInteger:
		case A3NumberKeyboardTypeReal:
		case A3NumberKeyboardTypeFraction:
			if ([self.delegate respondsToSelector:@selector(handleBigButton1)]) {
				[self.delegate handleBigButton1];
			}
			break;
	}
	[self setupLocale];
}

- (IBAction)bigButton2Action {
	[[UIDevice currentDevice] playInputClick];

	switch (self.keyboardType) {
		case A3NumberKeyboardTypeCurrency:
		case A3NumberKeyboardTypeInteger:
		case A3NumberKeyboardTypeReal:
		case A3NumberKeyboardTypeFraction:
			// Switch to calculator
			[self calculatorButtonAction:nil];
			return;
		case A3NumberKeyboardTypePercent:
		case A3NumberKeyboardTypeMonthYear:
		case A3NumberKeyboardTypeInterestRate:
			[self.bigButton1 setSelected:NO];
			[self.bigButton2 setSelected:YES];

			if ([self.delegate respondsToSelector:@selector(handleBigButton2)]) {
				[self.delegate handleBigButton2];
			}
			break;
	}
	if (self.keyboardType == A3NumberKeyboardTypePercent && [_textInputTarget isKindOfClass:[UITextField class]]) {
		// 화폐 형식으로 입력을 전환하는 경우, 소수점 자리수 조정이 필요
		// 화폐 형식의 경우, 소수점 이하 자리수는 0~3까지 다양
		// % 입력시 소수점 이하 최대 자리수는 세자리, 소수점 자리수가 3이 아닌 경우, 화폐 형식에 맞추어 입력된 숫자를 재 포맷한다.
		UITextField *textField = (UITextField *) _textInputTarget;
		if ([textField.text doubleValue] != 0) {
			NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
			[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
			if (self.currencyCode) {
				[numberFormatter setCurrencyCode:self.currencyCode];
			}
			if ([numberFormatter maximumFractionDigits] != 3) {
				NSUInteger maximumFractionDigits = numberFormatter.maximumFractionDigits;

				[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
				[numberFormatter setMaximumFractionDigits:maximumFractionDigits];
				[numberFormatter setUsesGroupingSeparator:NO];
				textField.text = [numberFormatter stringFromNumber:@([textField.text doubleValue])];
			}
		}
	}
	[self setupLocale];
}

- (void)setBigButton2CalculatorImage {
	UIImage *image = [UIImage imageNamed:@"calculator"];
	[self.bigButton2 setImage:image forState:UIControlStateNormal];
	[self.bigButton2 setTitle:nil forState:UIControlStateNormal];
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

- (void)presentCurrencySelectViewController {
	[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationCurrencyButtonPressed object:self.currencyCode];
}

- (IBAction)calculatorButtonAction:(UIButton *)sender {
	[[UIDevice currentDevice] playInputClick];

	[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationCalculatorButtonPressed object:nil];
}

- (IBAction)fractionButtonAction:(UIButton *)sender {
	if ([_delegate respondsToSelector:@selector(keyboardViewController:fractionButtonPressed:)]) {
		[_delegate keyboardViewController:self fractionButtonPressed:sender];
	}
}

- (IBAction)plusMinusButtonAction:(UIButton *)sender {
	if ([_delegate respondsToSelector:@selector(keyboardViewController:plusMinusButtonPressed:)]) {
		[_delegate keyboardViewController:self plusMinusButtonPressed:sender];
	}
}

@end
