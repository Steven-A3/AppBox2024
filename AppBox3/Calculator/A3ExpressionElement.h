//
//  A3ExpressionElement.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/24/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, A3ExpressionKind) {
	A3E_Number = 1,
	A3E_E_Number,
	A3E_PLUS,
	A3E_MINUS,
	A3E_MULTIPLY,
	A3E_DIVIDE,
	A3E_PERCENT,
	A3E_LEFT_PARENTHESIS,
	A3E_RIGHT_PARENTHESIS,
	A3E_SIN,
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
	A3E_ATANH,
	A3E_SQUARE,
	A3E_CUBE,
	A3E_POWER_XY,
	A3E_POWER_YX,
	A3E_POWER_2,
	A3E_SQUAREROOT,
	A3E_CUBEROOT,
	A3E_NTHROOT,
	A3E_FACTORIAL,
	A3E_PI,
	A3E_BASE_E,
	A3E_RANDOM,
	A3E_POWER_E,
	A3E_POWER_10,
	A3E_LN,
	A3E_LOG_10,
	A3E_LOG_2,
	A3E_LOG_Y,

	A3E_2ND = 1001,
	A3E_CLEAR,
	A3E_SIGN,
	A3E_BACKSPACE,
	A3E_DIVIDE_X,
	A3E_CALCULATE,
	A3E_RADIAN_DEGREE,
	A3E_DECIMAL_SEPARATOR
};


@interface A3ExpressionElement : NSObject

@property (assign)	A3ExpressionKind	expressionKind;
@property (nonatomic, strong) NSMutableArray *arguments;

@end
