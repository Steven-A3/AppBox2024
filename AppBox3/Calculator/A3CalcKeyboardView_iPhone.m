//
//  A3CalcKeyboardView_iPhone.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/22/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "A3CalcKeyboardView_iPhone.h"
#import "A3KeyboardButton_iOS7_iPhone.h"
#import "A3ExpressionComponent.h"

@implementation A3CalcKeyboardView_iPhone

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

		[self setupSubviews];
    }
    return self;
}

NSString *kA3CalcButtonTitle = @"kA3CalcButtonItle";
NSString *kA3CalcButtonID = @"kA3CalcButtonID";

- (NSArray *)buttonTitlesLevel1 {
	return @[
			@{kA3CalcButtonTitle:@"sin", kA3CalcButtonID:@(A3E_SIN)},
			@{kA3CalcButtonTitle:@"cos", kA3CalcButtonID:@(A3E_COS)},
			@{kA3CalcButtonTitle:@"tan", kA3CalcButtonID:@(A3E_TAN)},
			@{kA3CalcButtonTitle:[self stringSecond], kA3CalcButtonID:@(A3E_2ND)},
			@{kA3CalcButtonTitle:@"C", kA3CalcButtonID:@(A3E_CLEAR)},
			@{kA3CalcButtonTitle:@"+/-", kA3CalcButtonID:@(A3E_SIGN)},
			@{kA3CalcButtonTitle:@"%", kA3CalcButtonID:@(A3E_PERCENT)},
			@{kA3CalcButtonTitle:@"÷", kA3CalcButtonID:@(A3E_DIVIDE)},

			@{kA3CalcButtonTitle:@"sinh", kA3CalcButtonID:@(A3E_SINH)},
			@{kA3CalcButtonTitle:@"cosh", kA3CalcButtonID:@(A3E_COSH)},
			@{kA3CalcButtonTitle:@"tanh", kA3CalcButtonID:@(A3E_TANH)},
			@{kA3CalcButtonTitle:[self stringEx], kA3CalcButtonID:@(A3E_POWER_E)},
			@{kA3CalcButtonTitle:[UIImage imageNamed:@"backspace"], kA3CalcButtonID:@(A3E_BACKSPACE)},
			@{kA3CalcButtonTitle:@"(", kA3CalcButtonID:@(A3E_LEFT_PARENTHESIS)},
			@{kA3CalcButtonTitle:@")", kA3CalcButtonID:@(A3E_RIGHT_PARENTHESIS)},
			@{kA3CalcButtonTitle:@"×", kA3CalcButtonID:@(A3E_MULTIPLY)},

			@{kA3CalcButtonTitle:[self stringX2], kA3CalcButtonID:@(A3E_SQUARE)},
			@{kA3CalcButtonTitle:[self stringX3], kA3CalcButtonID:@(A3E_CUBE)},
			@{kA3CalcButtonTitle:[self stringXY], kA3CalcButtonID:@(A3E_POWER_XY)},
			@{kA3CalcButtonTitle:[self string10X], kA3CalcButtonID:@(A3E_POWER_10)},
			@{kA3CalcButtonTitle:@"7", kA3CalcButtonID:@(A3E_7)},
			@{kA3CalcButtonTitle:@"8", kA3CalcButtonID:@(A3E_8)},
			@{kA3CalcButtonTitle:@"9", kA3CalcButtonID:@(A3E_9)},
			@{kA3CalcButtonTitle:@"−", kA3CalcButtonID:@(A3E_MINUS)},

			@{kA3CalcButtonTitle:@"sqrt", kA3CalcButtonID:@(A3E_SQUAREROOT)},
			@{kA3CalcButtonTitle:@"sqrt(3)", kA3CalcButtonID:@(A3E_CUBEROOT)},
			@{kA3CalcButtonTitle:@"sqrt(y)", kA3CalcButtonID:@(A3E_NTHROOT)},
			@{kA3CalcButtonTitle:@"ln", kA3CalcButtonID:@(A3E_LN)},
			@{kA3CalcButtonTitle:@"4", kA3CalcButtonID:@(A3E_4)},
			@{kA3CalcButtonTitle:@"5", kA3CalcButtonID:@(A3E_5)},
			@{kA3CalcButtonTitle:@"6", kA3CalcButtonID:@(A3E_6)},
			@{kA3CalcButtonTitle:@"+", kA3CalcButtonID:@(A3E_PLUS)},

			@{kA3CalcButtonTitle:@"1/x", kA3CalcButtonID:@(A3E_DIVIDE_X)},
			@{kA3CalcButtonTitle:@"x!", kA3CalcButtonID:@(A3E_FACTORIAL)},
			@{kA3CalcButtonTitle:@"pi", kA3CalcButtonID:@(A3E_PI)},
			@{kA3CalcButtonTitle:[self stringLog10], kA3CalcButtonID:@(A3E_LOG_10)},
			@{kA3CalcButtonTitle:@"1", kA3CalcButtonID:@(A3E_1)},
			@{kA3CalcButtonTitle:@"2", kA3CalcButtonID:@(A3E_2)},
			@{kA3CalcButtonTitle:@"3", kA3CalcButtonID:@(A3E_3)},
			@{kA3CalcButtonTitle:@"=", kA3CalcButtonID:@(A3E_CALCULATE)},

			@{kA3CalcButtonTitle:@"e", kA3CalcButtonID:@(A3E_BASE_E)},
			@{kA3CalcButtonTitle:@"EE", kA3CalcButtonID:@(A3E_E_Number)},
			@{kA3CalcButtonTitle:@"Rand", kA3CalcButtonID:@(A3E_RANDOM)},
			@{kA3CalcButtonTitle:@"Rad", kA3CalcButtonID:@(A3E_RADIAN_DEGREE)},
			@{kA3CalcButtonTitle:@"0", kA3CalcButtonID:@(A3E_Number)},
			@{kA3CalcButtonTitle:@"00", kA3CalcButtonID:@(A3E_Number)},
			@{kA3CalcButtonTitle:@".", kA3CalcButtonID:@(A3E_DECIMAL_SEPARATOR)},
			@{kA3CalcButtonTitle:@""},
	];
}

- (NSArray *)buttonTitlesLevel2 {
	return @[
			@{kA3CalcButtonTitle:[self stringArcSin], kA3CalcButtonID:@(A3E_ASIN)},
			@{kA3CalcButtonTitle:[self stringArcCos], kA3CalcButtonID:@(A3E_ACOS)},
			@{kA3CalcButtonTitle:[self stringArcTan], kA3CalcButtonID:@(A3E_ATAN)},
			@{kA3CalcButtonTitle:[self stringSecond], kA3CalcButtonID:@(A3E_2ND)},
			@{kA3CalcButtonTitle:@"C", kA3CalcButtonID:@(A3E_CLEAR)},
			@{kA3CalcButtonTitle:@"+/-", kA3CalcButtonID:@(A3E_SIGN)},
			@{kA3CalcButtonTitle:@"%", kA3CalcButtonID:@(A3E_PERCENT)},
			@{kA3CalcButtonTitle:@"÷", kA3CalcButtonID:@(A3E_DIVIDE)},

			@{kA3CalcButtonTitle:[self stringArcSinh], kA3CalcButtonID:@(A3E_ASINH)},
			@{kA3CalcButtonTitle:[self stringArcCosh], kA3CalcButtonID:@(A3E_ACOSH)},
			@{kA3CalcButtonTitle:[self stringArcTanh], kA3CalcButtonID:@(A3E_ATANH)},
			@{kA3CalcButtonTitle:[self stringYX], kA3CalcButtonID:@(A3E_POWER_YX)},
			@{kA3CalcButtonTitle:[UIImage imageNamed:@"backspace"], kA3CalcButtonID:@(A3E_BACKSPACE)},
			@{kA3CalcButtonTitle:@"(", kA3CalcButtonID:@(A3E_LEFT_PARENTHESIS)},
			@{kA3CalcButtonTitle:@")", kA3CalcButtonID:@(A3E_RIGHT_PARENTHESIS)},
			@{kA3CalcButtonTitle:@"×", kA3CalcButtonID:@(A3E_MULTIPLY)},

			@{kA3CalcButtonTitle:[self stringX2], kA3CalcButtonID:@(A3E_SQUARE)},
			@{kA3CalcButtonTitle:[self stringX3], kA3CalcButtonID:@(A3E_CUBE)},
			@{kA3CalcButtonTitle:[self stringXY], kA3CalcButtonID:@(A3E_POWER_XY)},
			@{kA3CalcButtonTitle:[self string2X], kA3CalcButtonID:@(A3E_POWER_2)},
			@{kA3CalcButtonTitle:@"7", kA3CalcButtonID:@(A3E_7)},
			@{kA3CalcButtonTitle:@"8", kA3CalcButtonID:@(A3E_8)},
			@{kA3CalcButtonTitle:@"9", kA3CalcButtonID:@(A3E_9)},
			@{kA3CalcButtonTitle:@"−", kA3CalcButtonID:@(A3E_MINUS)},

			@{kA3CalcButtonTitle:@"sqrt", kA3CalcButtonID:@(A3E_SQUAREROOT)},
			@{kA3CalcButtonTitle:@"sqrt(3)", kA3CalcButtonID:@(A3E_CUBEROOT)},
			@{kA3CalcButtonTitle:@"sqrt(y)", kA3CalcButtonID:@(A3E_NTHROOT)},
			@{kA3CalcButtonTitle:[self stringLogy], kA3CalcButtonID:@(A3E_LOG_Y)},
			@{kA3CalcButtonTitle:@"4", kA3CalcButtonID:@(A3E_4)},
			@{kA3CalcButtonTitle:@"5", kA3CalcButtonID:@(A3E_5)},
			@{kA3CalcButtonTitle:@"6", kA3CalcButtonID:@(A3E_6)},
			@{kA3CalcButtonTitle:@"+", kA3CalcButtonID:@(A3E_PLUS)},

			@{kA3CalcButtonTitle:@"1/x", kA3CalcButtonID:@(A3E_DIVIDE_X)},
			@{kA3CalcButtonTitle:@"x!", kA3CalcButtonID:@(A3E_FACTORIAL)},
			@{kA3CalcButtonTitle:@"pi", kA3CalcButtonID:@(A3E_PI)},
			@{kA3CalcButtonTitle:[self stringLog2], kA3CalcButtonID:@(A3E_LOG_2)},
			@{kA3CalcButtonTitle:@"1", kA3CalcButtonID:@(A3E_1)},
			@{kA3CalcButtonTitle:@"2", kA3CalcButtonID:@(A3E_2)},
			@{kA3CalcButtonTitle:@"3", kA3CalcButtonID:@(A3E_3)},
			@{kA3CalcButtonTitle:@"=", kA3CalcButtonID:@(A3E_CALCULATE)},

			@{kA3CalcButtonTitle:@"e", kA3CalcButtonID:@(A3E_BASE_E)},
			@{kA3CalcButtonTitle:@"EE", kA3CalcButtonID:@(A3E_E_Number)},
			@{kA3CalcButtonTitle:@"Rand", kA3CalcButtonID:@(A3E_RANDOM)},
			@{kA3CalcButtonTitle:@"Rad", kA3CalcButtonID:@(A3E_RADIAN_DEGREE)},
			@{kA3CalcButtonTitle:@"0", kA3CalcButtonID:@(A3E_0)},
			@{kA3CalcButtonTitle:@"00", kA3CalcButtonID:@(A3E_00)},
			@{kA3CalcButtonTitle:@".", kA3CalcButtonID:@(A3E_DECIMAL_SEPARATOR)},
			@{kA3CalcButtonTitle:@""},
	];
}

#define KBD_BUTTON_TAG_BASE     1000

- (void)setupSubviews {
	// Dimension 320 X 2 / 348, 80 x 54 cell, 8 column, 6 row
	NSArray *buttonTitle = [self buttonTitlesLevel1];

	CGFloat x, y, width = 80, height = 54;
	for (NSUInteger row = 0; row < 6; row++) {
		for (NSUInteger column = 0; column < 8; column++) {
			NSUInteger idx = row * 8 + column;

			if (idx >= 47) break;

			x = (column == 0) ? -1 : column * width;
			y = row == 0 ? -1 : row * height;
			CGRect frame = CGRectMake(x, y, width + (column == 0 ? 2 : 1), height + (row == 0 ? 2 : 1));
			if (idx == 39) {
				frame.size.height = height * 2 + 1;
			}
			A3KeyboardButton_iOS7_iPhone *button = [[A3KeyboardButton_iOS7_iPhone alloc] initWithFrame:frame];
			button.tag = idx + KBD_BUTTON_TAG_BASE;
			[button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:button];

			id title = buttonTitle[idx];
			[self setTitle:title forButton:button];

			if (column == 7) {
				[button setBackgroundColor:[UIColor colorWithRed:0 green:122.0/255.0 blue:1.0 alpha:1.0]];
				[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
			} else if (row > 1 && column >= 4) {
				[button setBackgroundColor:[UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0]];
				[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			} else {
				[button setBackgroundColor:[UIColor colorWithRed:237.0 / 255.0 green:239.9 / 255.0 blue:242.0 / 255.0 alpha:1.0]];
				[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
		}
	}
}

- (void)setTitle:(NSDictionary *)titleInfo forButton:(A3KeyboardButton_iOS7_iPhone *)button {
	id title = titleInfo[kA3CalcButtonTitle];
	button.identifier = (NSUInteger *)[titleInfo[kA3CalcButtonID] integerValue];
	if ([title isKindOfClass:[NSString class]]) {
		[button setAttributedTitle:nil forState:UIControlStateNormal];
		[button setTitle:title forState:UIControlStateNormal];
	} else if ([title isKindOfClass:[NSAttributedString class]]) {
		[button setTitle:nil forState:UIControlStateNormal];
		[button setAttributedTitle:title forState:UIControlStateNormal];
	} else if ([title isKindOfClass:[UIImage class]]) {
		[button setTitle:nil forState:UIControlStateNormal];
		[button setAttributedTitle:nil forState:UIControlStateNormal];
		[button setImage:title forState:UIControlStateNormal];
	}
}

- (void)setLevel:(BOOL)level {
	for (NSUInteger row = 0; row < 5; row++) {
		for (NSUInteger column = 0; column < 4; column++) {
			if (row < 2 || column == 3) {
				NSUInteger idx = row * 8 + column;
				A3KeyboardButton_iOS7_iPhone *button = (A3KeyboardButton_iOS7_iPhone *) [self viewWithTag:idx + KBD_BUTTON_TAG_BASE];
				[button setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
			}
		}
	}
	[UIView animateWithDuration:0.4
						  delay:0
						options:UIViewAnimationOptionCurveLinear
					 animations:^{
		for (NSUInteger row = 0; row < 5; row++) {
			for (NSUInteger column = 0; column < 4; column++) {
				if (row < 2 || column == 3) {
					NSUInteger idx = row * 8 + column;
					A3KeyboardButton_iOS7_iPhone *button = (A3KeyboardButton_iOS7_iPhone *) [self viewWithTag:idx + KBD_BUTTON_TAG_BASE];
					[button setBackgroundColor:[UIColor colorWithRed:237.0 / 255.0 green:239.9 / 255.0 blue:242.0 / 255.0 alpha:1.0]];
				}
			}
		}
	} completion:^(BOOL finished) {
		NSArray *buttonTitles = level ? [self buttonTitlesLevel1] : [self buttonTitlesLevel2];
		for (NSUInteger row = 0; row < 5; row++) {
			for (NSUInteger column = 0; column < 4; column++) {
				if (row < 2 || column == 3) {
					NSUInteger idx = row * 8 + column;
					A3KeyboardButton_iOS7_iPhone *button = (A3KeyboardButton_iOS7_iPhone *) [self viewWithTag:idx + KBD_BUTTON_TAG_BASE];
					id title = buttonTitles[idx];
					[self setTitle:title forButton:button];
				}
			}
		}
	}];
}

- (UIFont *)superscriptFont {
	return [UIFont fontWithName:@".HelveticaNeueInterface-M3" size:11];
}

- (id)stringWithSuperscript:(NSString *)input location:(NSUInteger)loc length:(NSUInteger)len {
	NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:input];
	[string addAttribute:(NSString *)kCTSuperscriptAttributeName value:@1 range:NSMakeRange(loc,len)];
	[string addAttribute:(NSString *)kCTFontAttributeName value:[self superscriptFont] range:NSMakeRange(loc,len)];
	return string;
}

- (id)stringArcTanh {
	return [self stringWithSuperscript:@"tanh-1" location:4 length:2];
}

- (id)stringArcCosh {
	return [self stringWithSuperscript:@"cosh-1" location:4 length:2];
}

- (id)stringArcSinh {
	return [self stringWithSuperscript:@"sinh-1" location:4 length:2];
}

- (id)stringArcTan {
	return [self stringWithSuperscript:@"tan-1" location:3 length:2];
}

- (id)stringArcCos {
	return [self stringWithSuperscript:@"cos-1" location:3 length:2];
}

- (id)stringArcSin {
	return [self stringWithSuperscript:@"sin-1" location:3 length:2];
}

- (id)stringEx {
	return [self stringWithSuperscript:@"ex" location:1 length:1];
}

- (id)stringLog2 {
	return [self stringWithSuperscript:@"log2" location:3 length:1];
}

- (id)stringLogy {
	return [self stringWithSuperscript:@"logy" location:3 length:1];
}

- (id)string2X {
	return [self stringWithSuperscript:@"2x" location:1 length:1];
}

- (id)stringYX {
	return [self stringWithSuperscript:@"yx" location:1 length:1];
}

- (id)stringLog10 {
	return [self stringWithSuperscript:@"log10" location:3 length:2];
}

- (id)string10X {
	return [self stringWithSuperscript:@"10x" location:2 length:1];
}

- (id)stringXY {
	return [self stringWithSuperscript:@"xy" location:1 length:1];
}

- (id)stringX3 {
	return [self stringWithSuperscript:@"x3" location:1 length:1];
}

- (id)stringX2 {
	return [self stringWithSuperscript:@"x2" location:1 length:1];
}

- (id)stringSecond {
	return [self stringWithSuperscript:@"2nd" location:1 length:2];
}

- (void)buttonPressed:(A3KeyboardButton_iOS7_iPhone *)button {
	A3ExpressionKind input = (A3ExpressionKind)button.identifier;
	if (input == A3E_2ND) {
		[self setLevel:!button.selected ? 0 : 1];
		button.selected = !button.selected;
	} else {
		if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
			[_delegate keyboardButtonPressed:input];
		}
	}
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
