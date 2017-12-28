//
//  A3CalcKeyboardView_iPhone.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/22/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CalcKeyboardView_iPhone.h"
#import "A3KeyboardButton_iOS7_iPhone.h"
#import "A3ExpressionComponent.h"

#import "A3AppDelegate+appearance.h"

@implementation A3CalcKeyboardView_iPhone {
    BOOL bSecondButtonSelected;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self setupSubviews];
        bSecondButtonSelected = NO;
    }
    return self;
}

NSString *kA3CalcButtonTitle = @"kA3CalcButtonItle";
NSString *kA3CalcButtonID = @"kA3CalcButtonID";
NSString *kA3CalcButtonFont = @"kA3CalcButtonFont";
NSString *kA3CalcButtonFontSize = @"kA3CalcButtonFontSize";

- (NSArray *)buttonTitlesLevel1_h {
	return @[
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_01_1_h"], kA3CalcButtonID:@(A3E_SIN)},
			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_02_1_h"], kA3CalcButtonID:@(A3E_COS)},
			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_03_1_h"], kA3CalcButtonID:@(A3E_TAN)},
			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_04_h"], kA3CalcButtonID:@(A3E_2ND)},
             @{kA3CalcButtonTitle:@"C", kA3CalcButtonID:@(A3E_CLEAR), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@16.0},
			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_05_h"], kA3CalcButtonID:@(A3E_SIGN)},
			@{kA3CalcButtonTitle:@"%", kA3CalcButtonID:@(A3E_PERCENT), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@17.0},
			@{kA3CalcButtonTitle:@"÷", kA3CalcButtonID:@(A3E_DIVIDE),kA3CalcButtonID:@(A3E_MULTIPLY), kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@26.0},

			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_06_1_h"], kA3CalcButtonID:@(A3E_SINH)},
			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_07_1_h"], kA3CalcButtonID:@(A3E_COSH)},
			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_08_1_h"], kA3CalcButtonID:@(A3E_TANH)},
			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_09_1_h"], kA3CalcButtonID:@(A3E_COT)},
			@{kA3CalcButtonTitle:[UIImage imageNamed:@"backspace"], kA3CalcButtonID:@(A3E_BACKSPACE)},
			@{kA3CalcButtonTitle:@"(", kA3CalcButtonID:@(A3E_LEFT_PARENTHESIS), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@16.0},
			@{kA3CalcButtonTitle:@")", kA3CalcButtonID:@(A3E_RIGHT_PARENTHESIS), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@16.0},
			@{kA3CalcButtonTitle:@"×", kA3CalcButtonID:@(A3E_MULTIPLY), kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@26.0},

			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_10_h"], kA3CalcButtonID:@(A3E_SQUARE)},
			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_11_h"], kA3CalcButtonID:@(A3E_CUBE)},
			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_12_h"], kA3CalcButtonID:@(A3E_POWER_XY)},
			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_13_1_h"], kA3CalcButtonID:@(A3E_POWER_10)},
			@{kA3CalcButtonTitle:@"7", kA3CalcButtonID:@(A3E_7), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@20.0},
			@{kA3CalcButtonTitle:@"8", kA3CalcButtonID:@(A3E_8), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@20.0},
			@{kA3CalcButtonTitle:@"9", kA3CalcButtonID:@(A3E_9), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@20.0},
			@{kA3CalcButtonTitle:@"−", kA3CalcButtonID:@(A3E_MINUS), kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@26.0},

			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_14_h"], kA3CalcButtonID:@(A3E_SQUAREROOT)},
			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_15_h"], kA3CalcButtonID:@(A3E_CUBEROOT)},
			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_16_h"], kA3CalcButtonID:@(A3E_NTHROOT)},
			@{kA3CalcButtonTitle:@"ln", kA3CalcButtonID:@(A3E_LN), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@16.0},
			@{kA3CalcButtonTitle:@"4", kA3CalcButtonID:@(A3E_4), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@20.0},
			@{kA3CalcButtonTitle:@"5", kA3CalcButtonID:@(A3E_5), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@20.0},
			@{kA3CalcButtonTitle:@"6", kA3CalcButtonID:@(A3E_6), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@20.0},
			@{kA3CalcButtonTitle:@"+", kA3CalcButtonID:@(A3E_PLUS), kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@26.0},

			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_18_h"], kA3CalcButtonID:@(A3E_DIVIDE_X), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@16.0},
			@{kA3CalcButtonTitle:@"x!", kA3CalcButtonID:@(A3E_FACTORIAL),kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@16.0},
			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_19_h"], kA3CalcButtonID:@(A3E_PI)},
			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_20_1_h"], kA3CalcButtonID:@(A3E_LOG_10)},
			@{kA3CalcButtonTitle:@"1", kA3CalcButtonID:@(A3E_1), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@20.0},
			@{kA3CalcButtonTitle:@"2", kA3CalcButtonID:@(A3E_2), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@20.0},
			@{kA3CalcButtonTitle:@"3", kA3CalcButtonID:@(A3E_3), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@20.0},
			@{kA3CalcButtonTitle:@"=", kA3CalcButtonID:@(A3E_CALCULATE), kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@26.0},

			@{kA3CalcButtonTitle:@"e", kA3CalcButtonID:@(A3E_BASE_E), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@16.0},
			@{kA3CalcButtonTitle:@"EE", kA3CalcButtonID:@(A3E_E_Number), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@16.0},
			@{kA3CalcButtonTitle:@"Rand", kA3CalcButtonID:@(A3E_RANDOM), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@16.0},
			@{kA3CalcButtonTitle:@"Deg", kA3CalcButtonID:@(A3E_RADIAN_DEGREE), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@16.0},
			@{kA3CalcButtonTitle:@"0", kA3CalcButtonID:@(A3E_0), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@20.0},
			@{kA3CalcButtonTitle:@"00", kA3CalcButtonID:@(A3E_00), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@20.0},
			@{kA3CalcButtonTitle:[[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator], kA3CalcButtonID:@(A3E_DECIMAL_SEPARATOR), kA3CalcButtonFont:@"SystemFont",kA3CalcButtonFontSize:@18.0},
			@{kA3CalcButtonTitle:@""},
	];
}

- (NSArray *)buttonTitlesLevel2_h {
	return @[
			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_01_2_h"], kA3CalcButtonID:@(A3E_ASIN)},
			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_02_2_h"], kA3CalcButtonID:@(A3E_ACOS)},
			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_03_2_h"], kA3CalcButtonID:@(A3E_ATAN)},
			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_04_h"], kA3CalcButtonID:@(A3E_2ND)},
			@{kA3CalcButtonTitle:@"C", kA3CalcButtonID:@(A3E_CLEAR), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@16.0},
			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_05_h"], kA3CalcButtonID:@(A3E_SIGN)},
			@{kA3CalcButtonTitle:@"%", kA3CalcButtonID:@(A3E_PERCENT), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@17.0},
			@{kA3CalcButtonTitle:@"÷", kA3CalcButtonID:@(A3E_DIVIDE), kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@26.0},

			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_06_2_h"], kA3CalcButtonID:@(A3E_ASINH)},
			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_07_2_h"], kA3CalcButtonID:@(A3E_ACOSH)},
			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_08_2_h"], kA3CalcButtonID:@(A3E_ATANH)},
			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_09_2_h"], kA3CalcButtonID:@(A3E_ACOT)},
			@{kA3CalcButtonTitle:[UIImage imageNamed:@"backspace"], kA3CalcButtonID:@(A3E_BACKSPACE)},
			@{kA3CalcButtonTitle:@"(", kA3CalcButtonID:@(A3E_LEFT_PARENTHESIS), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@16.0},
			@{kA3CalcButtonTitle:@")", kA3CalcButtonID:@(A3E_RIGHT_PARENTHESIS), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@16.0},
			@{kA3CalcButtonTitle:@"×", kA3CalcButtonID:@(A3E_MULTIPLY), kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@26.0},

			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_10_h"], kA3CalcButtonID:@(A3E_SQUARE)},
			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_11_h"], kA3CalcButtonID:@(A3E_CUBE)},
			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_12_h"], kA3CalcButtonID:@(A3E_POWER_XY)},
			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_13_2_h"], kA3CalcButtonID:@(A3E_POWER_2)},
			@{kA3CalcButtonTitle:@"7", kA3CalcButtonID:@(A3E_7), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@20.0},
			@{kA3CalcButtonTitle:@"8", kA3CalcButtonID:@(A3E_8), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@20.0},
			@{kA3CalcButtonTitle:@"9", kA3CalcButtonID:@(A3E_9), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@20.0},
			@{kA3CalcButtonTitle:@"−", kA3CalcButtonID:@(A3E_MINUS), kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@26.0},

			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_14_h"], kA3CalcButtonID:@(A3E_SQUAREROOT)},
			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_15_h"], kA3CalcButtonID:@(A3E_CUBEROOT)},
			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_16_h"], kA3CalcButtonID:@(A3E_NTHROOT)},
			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_17_2_h"], kA3CalcButtonID:@(A3E_LOG_Y)},
			@{kA3CalcButtonTitle:@"4", kA3CalcButtonID:@(A3E_4), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@20.0},
			@{kA3CalcButtonTitle:@"5", kA3CalcButtonID:@(A3E_5), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@20.0},
			@{kA3CalcButtonTitle:@"6", kA3CalcButtonID:@(A3E_6), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@20.0},
			@{kA3CalcButtonTitle:@"+", kA3CalcButtonID:@(A3E_PLUS), kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@26.0},

			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_18_h"], kA3CalcButtonID:@(A3E_DIVIDE_X)},
			@{kA3CalcButtonTitle:@"x!", kA3CalcButtonID:@(A3E_FACTORIAL), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@16.0},
			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_19_h"], kA3CalcButtonID:@(A3E_PI)},
			@{kA3CalcButtonTitle:[UIImage imageNamed:@"c_20_2_h"], kA3CalcButtonID:@(A3E_LOG_2)},
			@{kA3CalcButtonTitle:@"1", kA3CalcButtonID:@(A3E_1), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@20.0},
			@{kA3CalcButtonTitle:@"2", kA3CalcButtonID:@(A3E_2), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@20.0},
			@{kA3CalcButtonTitle:@"3", kA3CalcButtonID:@(A3E_3), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@20.0},
			@{kA3CalcButtonTitle:@"=", kA3CalcButtonID:@(A3E_CALCULATE), kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@26.0},

			@{kA3CalcButtonTitle:@"e", kA3CalcButtonID:@(A3E_BASE_E), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@16.0},
			@{kA3CalcButtonTitle:@"EE", kA3CalcButtonID:@(A3E_E_Number), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@16.0},
			@{kA3CalcButtonTitle:@"Rand", kA3CalcButtonID:@(A3E_RANDOM), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@16.0},
			@{kA3CalcButtonTitle:@"Deg", kA3CalcButtonID:@(A3E_RADIAN_DEGREE), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@16.0},
			@{kA3CalcButtonTitle:@"0", kA3CalcButtonID:@(A3E_0), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@20.0},
			@{kA3CalcButtonTitle:@"00", kA3CalcButtonID:@(A3E_00), kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@20.0},
			@{kA3CalcButtonTitle:[[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator], kA3CalcButtonID:@(A3E_DECIMAL_SEPARATOR), kA3CalcButtonFont:@"SystemFont",kA3CalcButtonFontSize:@18.0},
			@{kA3CalcButtonTitle:@""},
	];
}

- (NSArray *)buttonTitlesLevel1_p {
	return @[
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_01_1_p"], kA3CalcButtonID:@(A3E_SIN)},
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_02_1_p"], kA3CalcButtonID:@(A3E_COS)},
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_03_1_p"], kA3CalcButtonID:@(A3E_TAN)},
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_04_p"], kA3CalcButtonID:@(A3E_2ND)},
             @{kA3CalcButtonTitle:@"C", kA3CalcButtonID:@(A3E_CLEAR), kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@25.0},
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_05_p"], kA3CalcButtonID:@(A3E_SIGN)},
             @{kA3CalcButtonTitle:@"%", kA3CalcButtonID:@(A3E_PERCENT),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@25.0},
             @{kA3CalcButtonTitle:@"÷", kA3CalcButtonID:@(A3E_DIVIDE),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@44.0},
             
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_06_1_p"], kA3CalcButtonID:@(A3E_SINH)},
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_07_1_p"], kA3CalcButtonID:@(A3E_COSH)},
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_08_1_p"], kA3CalcButtonID:@(A3E_TANH)},
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_09_1_p"], kA3CalcButtonID:@(A3E_COT)},
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"backspace"], kA3CalcButtonID:@(A3E_BACKSPACE)},
             @{kA3CalcButtonTitle:@"(", kA3CalcButtonID:@(A3E_LEFT_PARENTHESIS),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@25.0},
             @{kA3CalcButtonTitle:@")", kA3CalcButtonID:@(A3E_RIGHT_PARENTHESIS),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@25.0},
             @{kA3CalcButtonTitle:@"×", kA3CalcButtonID:@(A3E_MULTIPLY),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@44.0},
             
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_10_p"], kA3CalcButtonID:@(A3E_SQUARE)},
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_11_p"], kA3CalcButtonID:@(A3E_CUBE)},
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_12_p"], kA3CalcButtonID:@(A3E_POWER_XY)},
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_13_1_p"], kA3CalcButtonID:@(A3E_POWER_10)},
             @{kA3CalcButtonTitle:@"7", kA3CalcButtonID:@(A3E_7),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@34.0},
             @{kA3CalcButtonTitle:@"8", kA3CalcButtonID:@(A3E_8),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@34.0},
             @{kA3CalcButtonTitle:@"9", kA3CalcButtonID:@(A3E_9),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@34.0},
             @{kA3CalcButtonTitle:@"−", kA3CalcButtonID:@(A3E_MINUS),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@44.0},
             
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_14_p"], kA3CalcButtonID:@(A3E_SQUAREROOT)},
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_15_p"], kA3CalcButtonID:@(A3E_CUBEROOT)},
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_16_p"], kA3CalcButtonID:@(A3E_NTHROOT)},
             @{kA3CalcButtonTitle:@"ln", kA3CalcButtonID:@(A3E_LN),kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@22.0},
             @{kA3CalcButtonTitle:@"4", kA3CalcButtonID:@(A3E_4),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@34.0},
             @{kA3CalcButtonTitle:@"5", kA3CalcButtonID:@(A3E_5),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@34.0},
             @{kA3CalcButtonTitle:@"6", kA3CalcButtonID:@(A3E_6),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@34.0},
             @{kA3CalcButtonTitle:@"+", kA3CalcButtonID:@(A3E_PLUS),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@44.0},
             
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_18_p"], kA3CalcButtonID:@(A3E_DIVIDE_X)},
             @{kA3CalcButtonTitle:@"x!", kA3CalcButtonID:@(A3E_FACTORIAL),kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@22.0},
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_19_p"], kA3CalcButtonID:@(A3E_PI)},
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_20_1_p"], kA3CalcButtonID:@(A3E_LOG_10)},
             @{kA3CalcButtonTitle:@"1", kA3CalcButtonID:@(A3E_1),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@34.0},
             @{kA3CalcButtonTitle:@"2", kA3CalcButtonID:@(A3E_2),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@34.0},
             @{kA3CalcButtonTitle:@"3", kA3CalcButtonID:@(A3E_3),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@34.0},
             @{kA3CalcButtonTitle:@"=", kA3CalcButtonID:@(A3E_CALCULATE),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@44.0},
             
             @{kA3CalcButtonTitle:@"e", kA3CalcButtonID:@(A3E_BASE_E),kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@22.0},
             @{kA3CalcButtonTitle:@"EE", kA3CalcButtonID:@(A3E_E_Number),kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@22.0},
             @{kA3CalcButtonTitle:@"Rand", kA3CalcButtonID:@(A3E_RANDOM),kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@22.0},
             @{kA3CalcButtonTitle:@"Deg", kA3CalcButtonID:@(A3E_RADIAN_DEGREE),kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@22.0},
             @{kA3CalcButtonTitle:@"0", kA3CalcButtonID:@(A3E_0),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@34.0},
             @{kA3CalcButtonTitle:@"00", kA3CalcButtonID:@(A3E_00),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@34.0},
             @{kA3CalcButtonTitle:[[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator], kA3CalcButtonID:@(A3E_DECIMAL_SEPARATOR),kA3CalcButtonFont:@"SystemFont",kA3CalcButtonFontSize:@36.0},
             @{kA3CalcButtonTitle:@""},
             ];
}

- (NSArray *)buttonTitlesLevel2_p {
	return @[
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_01_2_p"], kA3CalcButtonID:@(A3E_ASIN)},
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_02_2_p"], kA3CalcButtonID:@(A3E_ACOS)},
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_03_2_p"], kA3CalcButtonID:@(A3E_ATAN)},
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_04_p"], kA3CalcButtonID:@(A3E_2ND)},
             @{kA3CalcButtonTitle:@"C", kA3CalcButtonID:@(A3E_CLEAR),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@25.0},
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_05_p"], kA3CalcButtonID:@(A3E_SIGN)},
             @{kA3CalcButtonTitle:@"%", kA3CalcButtonID:@(A3E_PERCENT),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@25.0},
             @{kA3CalcButtonTitle:@"÷", kA3CalcButtonID:@(A3E_DIVIDE),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@44.0},
             
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_06_2_p"], kA3CalcButtonID:@(A3E_ASINH)},
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_07_2_p"], kA3CalcButtonID:@(A3E_ACOSH)},
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_08_2_p"], kA3CalcButtonID:@(A3E_ATANH)},
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_09_2_p"], kA3CalcButtonID:@(A3E_ACOT)},
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"backspace"], kA3CalcButtonID:@(A3E_BACKSPACE)},
             @{kA3CalcButtonTitle:@"(", kA3CalcButtonID:@(A3E_LEFT_PARENTHESIS),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@25.0},
             @{kA3CalcButtonTitle:@")", kA3CalcButtonID:@(A3E_RIGHT_PARENTHESIS),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@25.0},
             @{kA3CalcButtonTitle:@"×", kA3CalcButtonID:@(A3E_MULTIPLY),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@44.0},
             
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_10_p"], kA3CalcButtonID:@(A3E_SQUARE)},
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_11_p"], kA3CalcButtonID:@(A3E_CUBE)},
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_12_p"], kA3CalcButtonID:@(A3E_POWER_XY)},
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_13_2_p"], kA3CalcButtonID:@(A3E_POWER_2)},
             @{kA3CalcButtonTitle:@"7", kA3CalcButtonID:@(A3E_7),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@34.0},
             @{kA3CalcButtonTitle:@"8", kA3CalcButtonID:@(A3E_8),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@34.0},
             @{kA3CalcButtonTitle:@"9", kA3CalcButtonID:@(A3E_9),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@34.0},
             @{kA3CalcButtonTitle:@"−", kA3CalcButtonID:@(A3E_MINUS),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@44.0},
             
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_14_p"], kA3CalcButtonID:@(A3E_SQUAREROOT)},
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_15_p"], kA3CalcButtonID:@(A3E_CUBEROOT)},
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_16_p"], kA3CalcButtonID:@(A3E_NTHROOT)},
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_17_2_p"], kA3CalcButtonID:@(A3E_LOG_Y)},
             @{kA3CalcButtonTitle:@"4", kA3CalcButtonID:@(A3E_4),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@34.0},
             @{kA3CalcButtonTitle:@"5", kA3CalcButtonID:@(A3E_5),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@34.0},
             @{kA3CalcButtonTitle:@"6", kA3CalcButtonID:@(A3E_6),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@34.0},
             @{kA3CalcButtonTitle:@"+", kA3CalcButtonID:@(A3E_PLUS),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@44.0},
             
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_18_p"], kA3CalcButtonID:@(A3E_DIVIDE_X)},
             @{kA3CalcButtonTitle:@"x!", kA3CalcButtonID:@(A3E_FACTORIAL),kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@22.0},
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_19_p"], kA3CalcButtonID:@(A3E_PI)},
             @{kA3CalcButtonTitle:[UIImage imageNamed:@"c_20_2_p"], kA3CalcButtonID:@(A3E_LOG_2)},
             @{kA3CalcButtonTitle:@"1", kA3CalcButtonID:@(A3E_1),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@34.0},
             @{kA3CalcButtonTitle:@"2", kA3CalcButtonID:@(A3E_2),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@34.0},
             @{kA3CalcButtonTitle:@"3", kA3CalcButtonID:@(A3E_3),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@34.0},
             @{kA3CalcButtonTitle:@"=", kA3CalcButtonID:@(A3E_CALCULATE),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@44.0},
             
             @{kA3CalcButtonTitle:@"e", kA3CalcButtonID:@(A3E_BASE_E),kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@22.0},
             @{kA3CalcButtonTitle:@"EE", kA3CalcButtonID:@(A3E_E_Number),kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@22.0},
             @{kA3CalcButtonTitle:@"Rand", kA3CalcButtonID:@(A3E_RANDOM),kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@22.0},
             @{kA3CalcButtonTitle:@"Deg", kA3CalcButtonID:@(A3E_RADIAN_DEGREE),kA3CalcButtonFont:@".HelveticaNeueInterface-Light",kA3CalcButtonFontSize:@22.0},
             @{kA3CalcButtonTitle:@"0", kA3CalcButtonID:@(A3E_0),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@34.0},
             @{kA3CalcButtonTitle:@"00", kA3CalcButtonID:@(A3E_00),kA3CalcButtonFont:@".HelveticaNeueInterface-Thin",kA3CalcButtonFontSize:@34.0},
             @{kA3CalcButtonTitle:[[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator], kA3CalcButtonID:@(A3E_DECIMAL_SEPARATOR),kA3CalcButtonFont:@"SystemFont",kA3CalcButtonFontSize:@36.0},
             @{kA3CalcButtonTitle:@""},
             ];
}

#define KBD_BUTTON_TAG_BASE     1000

- (void)setupSubviews {
	CGFloat scale = [A3UIDevice scaleToOriginalDesignDimension];
	FNLOG(@"%f", scale);

	// Dimension 320 X 2 / 348, 80 x 54 cell, 8 column, 6 row
	NSArray *buttonTitle = nil;

	CGFloat x, y, width, height;
    if(IS_PORTRAIT) {
        width = 80 * scale; height = 54 * scale;
        buttonTitle = [self buttonTitlesLevel1_p];
    } else {
        width = 60 * scale; height = 40 * scale;
        buttonTitle = [self buttonTitlesLevel1_h];
    }
	for (NSUInteger row = 0; row < 6; row++) {
		for (NSUInteger column = 0; column < 8; column++) {
			NSUInteger idx = row * 8 + column;

			if (idx >= 47) break;

			x = (column == 0) ? -1 : column * width;
			y = row == 0 ? 1 : row * height;
			CGRect frame = CGRectMake(x, y, width + (column == 0 ? 2 : 1), height + (row == 0 ? 0: 1));
			if (idx == 39) {    //"=" button
				frame.size.height = height * 2 + 1;
			}
            if (idx == 46) {
                frame.size.width = width;
            }
			A3KeyboardButton_iOS7_iPhone *button = [[A3KeyboardButton_iOS7_iPhone alloc] initWithFrame:frame];
			button.tag = idx + KBD_BUTTON_TAG_BASE;

			[button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:button];

			id title = buttonTitle[idx];
			[self setTitle:title forButton:button];
            A3ExpressionKind buttonID = [[title objectForKey:kA3CalcButtonID] integerValue];
            if (buttonID == A3E_RADIAN_DEGREE) {
                _radianDegreeButton = button;
            }
            
			if (column == 7) {
                /*
				[button setBackgroundColor:[UIColor colorWithRed:0 green:122.0/255.0 blue:1.0 alpha:0.75]];
               	[button setBackgroundColorForDefaultState:[UIColor colorWithRed:0 green:122.0/255.0 blue:1.0 alpha:0.75]];
                [button setBackgroundColorForHighlightedState:[UIColor colorWithRed:0 green:122.0/255.0 blue:1.0 alpha:1.0]];
				[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                 */
                UIColor *themeColor = [A3AppDelegate instance].themeColor;
                [button setBackgroundColor:themeColor];
                if (IS_PORTRAIT) {
                    button.contentEdgeInsets = UIEdgeInsetsMake(-8, 0, 0, 0);
                } else {
                    button.contentEdgeInsets = UIEdgeInsetsMake(-5, 0, 0, 0);
                }
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
			//} else if (row > 1 && column >= 4) {
			//	[button setBackgroundColor:[UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0]];
			//	[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			} else {
				[button setBackgroundColor:[UIColor colorWithRed:252.0 / 255.0 green:252.0 / 255.0 blue:253.0 / 255.0 alpha:1.0]];
                [button setBackgroundColorForDefaultState:[UIColor colorWithRed:252.0 / 255.0 green:252.0 / 255.0 blue:253.0 / 255.0 alpha:1.0]];
                [button setBackgroundColorForHighlightedState:[UIColor colorWithRed:234.0 / 255.0 green:234.0 / 255.0 blue:235.0 / 255.0 alpha:1.0]];
				[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
				[button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            }
		}
	}
}

- (void)layoutSubviews {
    CGFloat x, y, width, height;
    CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	CGFloat scale = [A3UIDevice scaleToOriginalDesignDimension];
	NSArray *buttonTitle = nil;
    
    if(IS_PORTRAIT) {
        width = 80 * scale; height = 54 * scale;
        buttonTitle = bSecondButtonSelected ? [self buttonTitlesLevel2_p]: [self buttonTitlesLevel1_p];
    } else {
        if (IS_IPHONEX) {
            width = (screenBounds.size.width - 30) / 8;
            height = 40 * scale;
        } else {
            width = (screenBounds.size.width == 480 ? 60 : 71 * scale); height = 40 * scale;
        }
        buttonTitle = bSecondButtonSelected ? [self buttonTitlesLevel2_h]:[self buttonTitlesLevel1_h];
    }
	for (NSUInteger row = 0; row < 6; row++) {
		for (NSUInteger column = 0; column < 8; column++) {
			NSUInteger idx = row * 8 + column;
            if (idx >= 47) break;
            
			x = (column == 0) ? -1 : column * width;
			y = row == 0 ? 1 : row * height;
			CGRect frame = CGRectMake(x, y, width + (column == 0 ? 2 : 1), height + (row == 0 ? 0 : 1));
			if (idx == 39) {    //"=" button
				frame.size.height = height * 2 + 1;
			}
            if (idx == 46) {
                frame.size.width = width + 0.5;
            }
            A3KeyboardButton_iOS7_iPhone *button = (A3KeyboardButton_iOS7_iPhone *) [self viewWithTag:idx+KBD_BUTTON_TAG_BASE];
            [button setFrame:frame];
            id title = buttonTitle[idx];
            if (column == 7) {
                if (IS_PORTRAIT) {
                    button.contentEdgeInsets = UIEdgeInsetsMake(-8, 0, 0, 0);
                } else {
                    button.contentEdgeInsets = UIEdgeInsetsMake(-5, 0, 0, 0);
                }
            }
           // [button setImage:nil forState:UIControlStateNormal];
			[self setTitle:title forButton:button];
            A3ExpressionKind buttonID = [[title objectForKey:kA3CalcButtonID] integerValue];
            if (buttonID == A3E_RADIAN_DEGREE) {
                _radianDegreeButton = button;
            }
        }
    }
}

- (void)setTitle:(NSDictionary *)titleInfo forButton:(A3KeyboardButton_iOS7_iPhone *)button {
	id title = titleInfo[kA3CalcButtonTitle];
	button.identifier = (NSUInteger *)[titleInfo[kA3CalcButtonID] integerValue];
    if(titleInfo[kA3CalcButtonFont] != nil)
    {
        if ([titleInfo[kA3CalcButtonFont] isEqualToString:@"SystemFont"]) {
            button.titleLabel.font = [UIFont systemFontOfSize:[titleInfo[kA3CalcButtonFontSize] floatValue]];
        } else {
            button.titleLabel.font = [UIFont fontWithName:titleInfo[kA3CalcButtonFont] size:[titleInfo[kA3CalcButtonFontSize] floatValue]];
        }
    }
    [button setAttributedTitle:nil forState:UIControlStateNormal];
    [button setTitle:nil forState:UIControlStateNormal];
    [button setImage:nil forState:UIControlStateNormal];
	if ([title isKindOfClass:[NSString class]]) {
	
		[button setTitle:title forState:UIControlStateNormal];
	} else if ([title isKindOfClass:[NSAttributedString class]]) {
	
		[button setAttributedTitle:title forState:UIControlStateNormal];
	} else if ([title isKindOfClass:[UIImage class]]) {
	
		[button setImage:title forState:UIControlStateNormal];
        [button setImage:title forState:UIControlStateSelected];    // 이전 이미지가 selected 이미지로 남아 있는 오류 수정.
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
					[button setBackgroundColor:[UIColor colorWithRed:252.0 / 255.0 green:252.0 / 255.0 blue:253.0 / 255.0 alpha:1.0]];
				}
			}
		}
	} completion:^(BOOL finished) {
		NSArray *buttonTitles = nil;
        if (IS_PORTRAIT) {
            buttonTitles =  level ? [self buttonTitlesLevel2_p] : [self buttonTitlesLevel1_p];
        } else {
            buttonTitles =  level ? [self buttonTitlesLevel2_h] : [self buttonTitlesLevel1_h];
        }
		for (NSUInteger row = 0; row < 5; row++) {
			for (NSUInteger column = 0; column < 4; column++) {
				if (row < 2 || column == 3) {
					NSUInteger idx = row * 8 + column;
					A3KeyboardButton_iOS7_iPhone *button = (A3KeyboardButton_iOS7_iPhone *) [self viewWithTag:idx + KBD_BUTTON_TAG_BASE];
					id title = buttonTitles[idx];
					[self setTitle:title forButton:button];
                    A3ExpressionKind buttonID = [[title objectForKey:kA3CalcButtonID] integerValue];
                    if (buttonID == A3E_RADIAN_DEGREE) {
                        _radianDegreeButton = button;
                    }
				}
			}
		}
	}];
}


- (void)buttonPressed:(A3KeyboardButton_iOS7_iPhone *)button {
	[[UIDevice currentDevice] playInputClick];
	
	A3ExpressionKind input = (A3ExpressionKind)button.identifier;
	if (input == A3E_2ND) {
        bSecondButtonSelected = !bSecondButtonSelected;
        button.selected = bSecondButtonSelected;
		[self setLevel:bSecondButtonSelected];

	} else {
		if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
            if (input == A3E_RADIAN_DEGREE) {
                if([button.titleLabel.text isEqualToString:@"Rad"]) {
                    [button setTitle:@"Deg" forState:UIControlStateNormal];
                } else {
                    [button setTitle:@"Rad" forState:UIControlStateNormal];
                }
            }
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
