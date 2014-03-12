//
//  A3ExpressionComponent.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/24/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, A3NumberType) {
	A3N_RADIAN = 1,
	A3N_DEGREE
};

typedef NS_ENUM(NSUInteger, A3ExpressionKind) {
	A3E_Number = 1,
	A3E_E_Number,

	// Operator
	A3E_PLUS = 1000,
	A3E_MINUS,
	A3E_MULTIPLY,
	A3E_DIVIDE,
	A3E_LEFT_PARENTHESIS,
	A3E_RIGHT_PARENTHESIS,
	A3E_OPERATOR_END,

	// Constants
	A3E_PI = 1200,			// No arguments
	A3E_BASE_E,
	A3E_CONSTANT_END,

	// Trigonometric functions
	A3E_SIN = 2000,	// Argument, 0: A3NumberType, 1:value
	A3E_COS,
	A3E_TAN,
	A3E_SINH,
	A3E_COSH,
	A3E_TANH,
	A3E_ASIN,
	A3E_ACOS,
	A3E_ATAN,
	A3E_ASINH,
	A3E_ACOSH,
	A3E_ATANH,	// Argument, 0: A3NumberType, 1:value
    A3E_COT,
    A3E_ACOT,
	A3E_TRIGONOMETRIC_END,

	// Single argument functions
	A3E_SQUARE = 3000,
	A3E_CUBE,
	A3E_POWER_2,
	A3E_SQUAREROOT,
	A3E_CUBEROOT,
	A3E_FACTORIAL,
	A3E_RANDOM,		// 0 argument or if it has one, max
	//A3E_POWER_E,
	A3E_POWER_10,
	A3E_LN,
	A3E_LOG_10,
	A3E_LOG_2,
	A3E_LOG_Y,
    A3E_PERCENT,
	A3E_SINGLE_ARG_END,
	

	// Double argument functions
	A3E_NTHROOT = 4000,	// 0:Value, 1:N
	A3E_POWER_XY,	// 0:X, 1:Y
	//A3E_POWER_YX,	// 0:Y, 1:X
	A3E_DOUBLE_ARG_END,

	// Numbers
	A3E_0 = 5000,
	A3E_1,
	A3E_2,
	A3E_3,
	A3E_4,
	A3E_5,
	A3E_6,
	A3E_7,
	A3E_8,
	A3E_9,
	//A3E_00,
	A3E_NUMBERS_END,

	// Special keys
	A3E_2ND = 10000,
	A3E_CLEAR,
	A3E_SIGN,
	A3E_BACKSPACE,
	A3E_DIVIDE_X,
	A3E_CALCULATE,
	A3E_RADIAN_DEGREE,
    A3E_00,
    A3E_DECIMAL_SEPARATOR,
	A3E_SPECIAL_KEYS_END,

};
