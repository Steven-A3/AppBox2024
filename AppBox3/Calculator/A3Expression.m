//
//  A3Expression.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/25/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3Expression.h"
#import "A3ExpressionComponent.h"
#import "CoreText/CoreText.h"
#import "common.h"

@interface A3Expression () <NSCoding>

@property (nonatomic, strong) NSMutableArray *components;

@end

NSString *kA3ExpressionAttributeElements = @"keyA3ExpressionAttributeElements";

@implementation A3Expression

- (id)init {
	self = [super init];
	if (self) {
	}

	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	if (self) {
		_components = [[coder decodeObjectForKey:kA3ExpressionAttributeElements] mutableCopy];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.components forKey:kA3ExpressionAttributeElements];
}


- (void)keyboardInput:(A3ExpressionKind)input {
	switch (input) {
		case A3E_RIGHT_PARENTHESIS:
			[self rightParenthesis];
		case A3E_E_Number:
			[self handleENumberInput];
			break;
		case A3E_BACKSPACE:
			[self backspace];
			break;
		case A3E_SIGN:
			[self handleSignInput];
			break;
		case A3E_DIVIDE_X:
			[self handleDivideXInput];
			break;
		case A3E_CALCULATE:
			[self calculate];
			break;
		case A3E_RADIAN_DEGREE:
			[self handleRadianDegreeInput];
			break;
		case A3E_CLEAR:
			[self handleClearInput];
			break;
		default:
			[self handleInputExpressionComponent:input];
			break;
	}
}

- (void)rightParenthesis {

}

- (void)handleClearInput {

}

- (void)handleRadianDegreeInput {

}

- (void)calculate {

}

- (void)handleDivideXInput {

}

- (void)handleSignInput {

}

- (void)handleENumberInput {

}

- (void)handleInputExpressionComponent:(A3ExpressionKind)input {
	NSAssert(input != A3E_2ND, @"It is not a element.");
	NSAssert(input != A3E_CLEAR, @"It is not a element.");
	NSAssert(input != A3E_CALCULATE, @"It is not a element.");
	NSAssert(input != A3E_RADIAN_DEGREE, @"It is not a element.");
	NSAssert(input != A3E_E_Number, @"It is not a element.");

	if (![self.components count]) {
		A3ExpressionComponent *component = [A3ExpressionComponent new];
		if (IS_NUMBER(input)) {
			component.expressionKind = A3E_Number;
			component.arguments = [NSMutableArray new];
			[component.arguments addObject:@(input - A3E_0)];
		} else {
			component.expressionKind = input;
		}
		[self.components addObject:component];
		return;
	}

	A3ExpressionComponent *lastComponent = nil;
	A3ExpressionComponent *targetComponent = [self.components lastObject];
	A3Expression *targetExpression = self;
	while (!lastComponent) {
		if (HAS_ARGUMENTS(targetComponent.expressionKind) && [targetComponent.arguments count] && ![targetComponent isClosed]) {
			targetExpression = [targetComponent.arguments lastObject];
			targetComponent = [targetExpression.components lastObject];
		} else {
			lastComponent = targetComponent;
		}
	}

	if (IS_NUMBER(input)) {
		if (lastComponent.expressionKind == A3E_Number) {
			double existingValue = 0;
			if ([lastComponent.arguments count]) {
				existingValue = [lastComponent.arguments[0] doubleValue];
			}
			double newValue = existingValue * 10 + input - A3E_0;
			lastComponent.arguments[0] = @(newValue);
		} else if (lastComponent.expressionKind == A3E_E_Number) {
			if ([lastComponent.arguments count] == 2) {
				NSInteger power = [lastComponent.arguments[1] integerValue];
				power = [[NSString stringWithFormat:@"%d%d", power, input - A3E_0] integerValue];
				lastComponent.arguments[1] = @(power);
			}
			else {
				FNLOG(@"Error");
			}
		} else {
			[targetExpression addNumberComponentWithValue:@(input - A3E_0)];
		}
	} else {
		switch (input) {
			case A3E_SIN: case A3E_COS:	case A3E_TAN:case A3E_SINH:case A3E_COSH:case A3E_TANH:case A3E_ASIN:
			case A3E_ACOS: case A3E_ATAN: case A3E_ASINH: case A3E_ACOSH: case A3E_ATANH:
			case A3E_SQUARE: case A3E_CUBE:	case A3E_SQUAREROOT: case A3E_CUBEROOT:	case A3E_FACTORIAL:
			case A3E_LN: case A3E_LOG_10: case A3E_LOG_2: case A3E_LOG_Y: case A3E_SINGLE_ARG_END: case A3E_PERCENT:
			case A3E_NTHROOT: case A3E_POWER_XY: case A3E_POWER_YX:
				if (lastComponent.expressionKind == A3E_Number ||
						lastComponent.expressionKind == A3E_E_Number) {
					
				}
				break;
			default:
				break;
		}

		A3ExpressionComponent *element = [A3ExpressionComponent new];
		element.expressionKind = input;
		[targetExpression.components addObject:element];
	}
}

/*! Add Number element with value.
 * \param
 */
- (void)addNumberComponentWithValue:(NSNumber *)value {
	A3ExpressionComponent *component = [A3ExpressionComponent new];
	component.expressionKind = A3E_Number;
	component.arguments = [NSMutableArray new];
	[component.arguments addObject:value];

	[self.components addObject:component];
}

- (void)backspace {
	if (![self.components count]) {
		return;
	}
	A3ExpressionComponent *component = nil;
	A3ExpressionComponent *targetComponent = [self.components lastObject];
	A3Expression *targetExpression = self;
	A3Expression *parentExpression = nil;
	while (!component) {
		if (HAS_ARGUMENTS(targetComponent.expressionKind) && [targetComponent.arguments count] && ![targetComponent isClosed]) {
			parentExpression = targetExpression;
			targetExpression = [targetComponent.arguments lastObject];
			targetComponent = [targetExpression.components lastObject];
		} else {
			component = targetComponent;
		}
	}

	if (HAS_ARGUMENTS(component.expressionKind)) {
		if (![component.arguments count]) {
			[self.components removeLastObject];
		} else {
			NSString *numberInString = [NSString stringWithFormat:@"%@", component.arguments[[component.arguments count] - 1] ];
			if ([numberInString length]) {
				double newNumber = [[numberInString substringToIndex:[numberInString length] - 2] doubleValue];
				[component.arguments removeLastObject];
				if (newNumber != 0.0) {
				} else {
					[component.arguments addObject:@(newNumber)];
				}
			}
		}
	} else {
		[targetExpression.components removeObject:targetComponent];
		if ([targetExpression.components count] == 0 && parentExpression) {

		}
	}
}

- (NSString *)evaluated {
	return @"";
}

- (NSDictionary *)expressionAttribute {
	return @{
			NSFontAttributeName:[UIFont fontWithName:@".HelveticaNeueInterface-M3" size:18],
			NSForegroundColorAttributeName:[UIColor blackColor]
	};
}

- (NSDictionary *)superscriptAttribute {
	return @{
			NSFontAttributeName:[UIFont fontWithName:@".HelveticaNeueInterface-M3" size:12],
			NSForegroundColorAttributeName:[UIColor blackColor],
	};
}

- (NSMutableAttributedString *)mutableAttributedString {
	NSMutableAttributedString *out = [NSMutableAttributedString new];
	NSNumberFormatter *nf = [NSNumberFormatter new];
	[nf setNumberStyle:NSNumberFormatterDecimalStyle];

	for (A3ExpressionComponent *component in self.components) {
		NSMutableAttributedString *stringToAdd;
		switch (component.expressionKind) {
			case A3E_Number:
				stringToAdd = [[NSMutableAttributedString alloc] initWithString:[nf stringFromNumber:component.arguments[0]] attributes:[self expressionAttribute]];
				break;
			case A3E_E_Number:{
				NSString *head = @"", *tail = @"";

				if ([self.components count] >= 1) {
					head = [nf stringFromNumber:component.arguments[0]];
				}
				if ([self.components count] >= 2) {
					tail = [NSString stringWithFormat:@"%d", [component.arguments[1] integerValue] ];
				}
				stringToAdd = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@E%@", head, tail] attributes:[self expressionAttribute]];
				break;
			}
			case A3E_PLUS:
				stringToAdd = [[NSMutableAttributedString alloc] initWithString:@"+" attributes:[self expressionAttribute]];
				break;
			case A3E_MINUS:
				stringToAdd = [[NSMutableAttributedString alloc] initWithString:@"−" attributes:[self expressionAttribute]];
				break;
			case A3E_MULTIPLY:
				stringToAdd = [[NSMutableAttributedString alloc] initWithString:@"×" attributes:[self expressionAttribute]];
				break;
			case A3E_DIVIDE:
				stringToAdd = [[NSMutableAttributedString alloc] initWithString:@"÷" attributes:[self expressionAttribute]];
				break;
			case A3E_PERCENT:
				stringToAdd = [self getStringOf1stArgumentForComponent:component];
				[stringToAdd appendAttributedString:[self attributedStringFromString:@"%%"]];
				break;
			case A3E_LEFT_PARENTHESIS:
				stringToAdd = [self attributedStringFromString:@"("];
				for (A3Expression *expression in component.arguments) {
					[stringToAdd appendAttributedString:expression.mutableAttributedString];
				}
				[stringToAdd appendAttributedString:[self attributedStringFromString:@")"]];
				break;
			case A3E_RIGHT_PARENTHESIS:
				stringToAdd = [[NSMutableAttributedString alloc] initWithString:@")" attributes:[self expressionAttribute]];
				break;
			case A3E_SIN:
				stringToAdd = [self attributedStringForFunction:@"sin(" component:component];
				break;
			case A3E_COS:
				stringToAdd = [self attributedStringForFunction:@"cos(" component:component];
				break;
			case A3E_TAN:
				stringToAdd = [self attributedStringForFunction:@"tan(" component:component];
				break;
			case A3E_SINH:
				stringToAdd = [self attributedStringForFunction:@"sinh(" component:component];
				break;
			case A3E_COSH:
				stringToAdd = [self attributedStringForFunction:@"cosh(" component:component];
				break;
			case A3E_TANH:
				stringToAdd = [self attributedStringForFunction:@"tanh(" component:component];
				break;
			case A3E_ASIN:
				stringToAdd = [self attributedStringForFunction:@"sin-1(" component:component];
				[self superscriptString:stringToAdd Range:NSMakeRange(3,2) value:@1];
				break;
			case A3E_ACOS:
				stringToAdd = [self attributedStringForFunction:@"cos-1(" component:component];
				[self superscriptString:stringToAdd Range:NSMakeRange(3,2) value:@1];
				break;
			case A3E_ATAN:
				stringToAdd = [self attributedStringForFunction:@"tan-1(" component:component];
				[self superscriptString:stringToAdd Range:NSMakeRange(3,2) value:@1];
				break;
			case A3E_ASINH:
				stringToAdd = [self attributedStringForFunction:@"sinh-1(" component:component];
				[self superscriptString:stringToAdd Range:NSMakeRange(4,2) value:@1];
				break;
			case A3E_ACOSH:
				stringToAdd = [self attributedStringForFunction:@"cosh-1(" component:component];
				[self superscriptString:stringToAdd Range:NSMakeRange(4,2) value:@1];
				break;
			case A3E_ATANH:
				stringToAdd = [self attributedStringForFunction:@"tanh-1(" component:component];
				[self superscriptString:stringToAdd Range:NSMakeRange(4,2) value:@1];
				break;
			case A3E_SQUARE:
				stringToAdd = [self getStringOf1stArgumentForComponent:component];
				[stringToAdd appendAttributedString:[self attributedStringFromString:@"2"]];
				[self superscriptString:stringToAdd Range:NSMakeRange([stringToAdd length] - 1, 1) value:@1];
				break;
			case A3E_CUBE:
				stringToAdd = [self getStringOf1stArgumentForComponent:component];
				[stringToAdd appendAttributedString:[self attributedStringFromString:@"3"]];
				[self superscriptString:stringToAdd Range:NSMakeRange([stringToAdd length] - 1, 1) value:@1];
				break;
			case A3E_POWER_XY:
			{
				if ([component.arguments count] > 1) {
					A3Expression *arg0 = component.arguments[0];
					stringToAdd = [arg0 mutableAttributedString];

					if ([component.arguments count] == 2) {
						A3Expression *arg1 = component.arguments[1];
						NSMutableAttributedString *exponent = [arg1 mutableAttributedString];
						[self superscriptString:exponent Range:NSMakeRange(0, [exponent length]) value:@1];
						[stringToAdd appendAttributedString:exponent];
					}
				} else {
					stringToAdd = [self attributedStringForFunction:@"Power(" component:component];
				}
				break;
			}
			case A3E_SQUAREROOT:
				stringToAdd = [self attributedStringForFunction:@"SQRT(" component:component];
				break;
			case A3E_CUBEROOT:
				stringToAdd = [self attributedStringForFunction:@"CubeRoot(" component:component];
				break;
			case A3E_NTHROOT:
				stringToAdd = [self attributedStringForFunction:@"NthRoot(" component:component];
				break;
			case A3E_FACTORIAL:
				stringToAdd = [self getStringOf1stArgumentForComponent:component];
				[stringToAdd appendAttributedString:[self attributedStringFromString:@"!"]];
				break;
			case A3E_PI:
				stringToAdd = [self attributedStringFromString:@"π"];
                break;
			case A3E_BASE_E:
				stringToAdd = [self attributedStringFromString:@"e"];
                break;
			case A3E_RANDOM:
				stringToAdd = [self attributedStringForFunction:@"random(" component:component];
                break;
			case A3E_POWER_E:
				stringToAdd= [self getPowerString:component base:@"e"];
				break;
			case A3E_POWER_10:
				stringToAdd = [self getPowerString:component base:@"10"];
				break;
			case A3E_LN:
				stringToAdd = [self attributedStringForFunction:@"ln(" component:component];
				break;
			case A3E_LOG_10:
				stringToAdd = [self attributedStringForFunction:@"log10(" component:component];
				[self superscriptString:stringToAdd Range:NSMakeRange(3,2) value:@-1];
                break;
			case A3E_LOG_2:
				stringToAdd = [self attributedStringForFunction:@"log2(" component:component];
				[self superscriptString:stringToAdd Range:NSMakeRange(3,1) value:@-1];
				break;
			case A3E_LOG_Y: {
				stringToAdd = [self attributedStringFromString:@"log"];
				NSMutableAttributedString *base = [self getStringOf1stArgumentForComponent:component];
				[self superscriptString:base Range:NSMakeRange(0, [base length]) value:@-1];
				[stringToAdd appendAttributedString:base];
				[stringToAdd appendAttributedString:[self attributedStringFromString:@"("]];

				if ([component.arguments count] == 2) {
					A3Expression *argumentExpression = component.arguments[1];
					[stringToAdd appendAttributedString:[argumentExpression mutableAttributedString]];
					if ([argumentExpression isClosed]) {
						[stringToAdd appendAttributedString:[self attributedStringFromString:@")"]];
					}
				}
				break;
			}
			default:
				break;
//			case A3E_OPERATOR_END:break;
//			case A3E_CONSTANT_END:break;
//			case A3E_TRIGONOMETRIC_END:break;
//			case A3E_POWER_2:break;
//			case A3E_SINGLE_ARG_END:break;
//			case A3E_POWER_YX:break;
//			case A3E_DOUBLE_ARG_END:break;
//			case A3E_DECIMAL_SEPARATOR:break;
//			case A3E_0:break;
//			case A3E_1:break;
//			case A3E_2:break;
//			case A3E_3:break;
//			case A3E_4:break;
//			case A3E_5:break;
//			case A3E_6:break;
//			case A3E_7:break;
//			case A3E_8:break;
//			case A3E_9:break;
//			case A3E_NUMBERS_END:break;
//			case A3E_2ND:break;
//			case A3E_CLEAR:break;
//			case A3E_SIGN:break;
//			case A3E_BACKSPACE:break;
//			case A3E_DIVIDE_X:break;
//			case A3E_CALCULATE:break;
//			case A3E_RADIAN_DEGREE:break;
//			case A3E_SPECIAL_KEYS_END:break;
		}
		if (stringToAdd) {
			[out appendAttributedString:stringToAdd];
			[out appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:[self expressionAttribute]]];
		}
	}
	return out;
}

- (NSMutableAttributedString *)getPowerString:(A3ExpressionComponent *)component base:(NSString *)base {
	NSMutableAttributedString *stringToReturn = [self attributedStringFromString:base];
	NSMutableAttributedString *exponent = [self getStringOf1stArgumentForComponent:component];
	[stringToReturn appendAttributedString:exponent];
	[self superscriptString:stringToReturn Range:NSMakeRange([base length], [exponent length]) value:@1];
	return stringToReturn;
}

- (NSMutableAttributedString *)getStringOf1stArgumentForComponent:(A3ExpressionComponent *)component {
	NSMutableAttributedString *stringToReturn = nil;
	if ([self isNumberArg0:component]) {
		stringToReturn = [self mutableAttributedString];
	} else {
		if ([component.arguments count]) {
			stringToReturn = [self attributedStringFromString:@"("];
			[stringToReturn appendAttributedString:[component.arguments[0] mutableAttributedString]];
			[stringToReturn appendAttributedString:[self attributedStringFromString:@")"]];
		}
	}
	return stringToReturn;
}

- (BOOL)isNumberArg0:(A3ExpressionComponent *)component {
	if ([component.arguments count] >= 1) {
		A3Expression *arg0 = component.arguments[0];
		if ([arg0.components count] >= 1) {
			A3ExpressionComponent *argComponent = arg0.components[0];
			if (argComponent.expressionKind == A3E_Number || argComponent.expressionKind == A3E_E_Number) {
				return YES;
			}
		}
	}
	return NO;
}

- (NSMutableAttributedString *)attributedStringForFunction:(NSString *)function component:(A3ExpressionComponent *)component {
	NSMutableAttributedString *stringToReturn = [self attributedStringFromString:function];
	if ([component.arguments count]) {
		A3Expression *argumentExpression = component.arguments[0];
		NSAttributedString *centerString = [argumentExpression mutableAttributedString];
		[stringToReturn insertAttributedString:centerString atIndex:1];

		if ([component.arguments count] >= 2) {
			[stringToReturn appendAttributedString:[self attributedStringFromString:@", "]];
			A3Expression *arg1 = component.arguments[1];
			[stringToReturn appendAttributedString:[arg1 mutableAttributedString]];
		}
		if ([argumentExpression isClosed]) {
			[stringToReturn appendAttributedString:[self attributedStringFromString:@")"]];
		}
	}
	return stringToReturn;
}

- (NSMutableAttributedString *)attributedStringFromString:(NSString *)string {
	return [[NSMutableAttributedString alloc] initWithString:string attributes:[self expressionAttribute]];
}

- (NSMutableAttributedString *)attributedStringForElement1:(A3ExpressionComponent *)element format:(NSString *)format nf:(NSNumberFormatter *)nf
{
	NSString *number = @"";
	if ([element.arguments count]) {
		number = [nf stringFromNumber:element.arguments[0]];
	}
	return [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:format, number] attributes:[self expressionAttribute]];
}

- (NSMutableAttributedString *)attributedStringForElement2:(A3ExpressionComponent *)element format:(NSString *)format nf:(NSNumberFormatter *)nf
{
	NSString *number1 = @"", *number2 = @"";
	if ([element.arguments count]) {
		number1 = [nf stringFromNumber:element.arguments[0]];
	}
    if ([element.arguments count] >= 2) {
        number2 = [NSString stringWithFormat:@"%d", [element.arguments[1] integerValue]];
    }
	return [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:format, number1, number2] attributes:[self expressionAttribute]];
}

- (void)superscriptString:(NSMutableAttributedString *)string Range:(NSRange)range value:(id) value {
	[string addAttribute:(NSString *)kCTSuperscriptAttributeName value:value range:range];
	[string addAttribute:(NSString *)kCTFontAttributeName value:[UIFont fontWithName:@".HelveticaNeueInterface-M3" size:12] range:range];
}

- (NSString *)expressionStringForEvaluation {
	return @"";
}

- (NSMutableArray *)components {
	if (!_components) {
		_components = [NSMutableArray new];
	}
	return _components;
}

@end
