//
//  A3Expression.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/25/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3Expression.h"
#import "A3ExpressionElement.h"
#import "CoreText/CoreText.h"

@interface A3Expression () <NSCoding>

@property (nonatomic, strong) NSMutableArray *elements;
@property (nonatomic) BOOL lastHasDot;
@property (nonatomic) NSUInteger numberOfTrailingZero;

@end

NSString *kA3ExpressionAttributeElements = @"keyA3ExpressionAttributeElements";
NSString *kA3ExpressionAttributeLastHasDot = @"keyA3ExpressionAttributeLastHasDot";
NSString *kA3ExpressionAttributeNumberOfTrailingZero = @"keyA3ExpressionAttributeNumberOfTrailingZero";

@implementation A3Expression

- (id)init {
	self = [super init];
	if (self) {
		_lastHasDot = NO;
		_numberOfTrailingZero = 0;
	}

	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	if (self) {
		_elements = [[coder decodeObjectForKey:kA3ExpressionAttributeElements] mutableCopy];
		_lastHasDot = [coder decodeBoolForKey:kA3ExpressionAttributeLastHasDot];
		_numberOfTrailingZero = (NSUInteger) [coder decodeIntegerForKey:kA3ExpressionAttributeNumberOfTrailingZero];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.elements forKey:kA3ExpressionAttributeElements];
	[coder encodeBool:_lastHasDot forKey:kA3ExpressionAttributeLastHasDot];
	[coder encodeInteger:_numberOfTrailingZero forKey:kA3ExpressionAttributeNumberOfTrailingZero];
}

- (void)addNumber:(NSString *)inputString {
	if (![self.elements count]) {
		A3ExpressionElement *element = [A3ExpressionElement new];
		element.expressionKind = A3E_Number;
		[element.arguments addObject:@([inputString doubleValue])];
		[self addElement:element];
		return;
	}

	A3ExpressionElement *lastElement = [_elements lastObject];
	id existingNumber;
	switch (lastElement.expressionKind) {
		case A3E_Number:
		case A3E_PERCENT:
		case A3E_SIN:
		case A3E_COSH:
		case A3E_COS:
		case A3E_TAN:
		case A3E_SINH:
		case A3E_TANH:
		case A3E_ASIN:
		case A3E_ACOS:
		case A3E_ATAN:
		case A3E_ASINH:
		case A3E_ACOSH:
		case A3E_ATANH:
		case A3E_SQUARE:
		case A3E_CUBE:
		case A3E_POWER_10:
		case A3E_LN:
		case A3E_LOG_2:
		case A3E_LOG_10:
		case A3E_LOG_Y:
		case A3E_SQUAREROOT:
		case A3E_CUBEROOT:
		case A3E_FACTORIAL:
		case A3E_POWER_E:
		case A3E_E_Number:
		case A3E_POWER_XY:
		case A3E_NTHROOT:
			if ([lastElement.arguments count]) {
				existingNumber = lastElement.arguments[[lastElement.arguments count] - 1];
			} else {
				existingNumber = @0;
			}
			break;
		default:;
//		case A3E_PI:
//		case A3E_BASE_E:
//		case A3E_RANDOM:
//		case A3E_PLUS:
//		case A3E_MINUS:
//		case A3E_MULTIPLY:
//		case A3E_DIVIDE:
//		case A3E_LEFT_PARENTHESIS:
//		case A3E_RIGHT_PARENTHESIS:
	}
	NSString *numberInString = [NSString stringWithFormat:@"%@%@%@", existingNumber, _lastHasDot ? @".": @"", inputString];
	if ([inputString isEqualToString:@"0"] && [numberInString rangeOfString:@"."].location != NSNotFound) {
		_numberOfTrailingZero++;
	} else {
		NSNumber *newValue = @([numberInString doubleValue]);
		[_elements removeLastObject];
		[_elements addObject:newValue];
		_lastHasDot = NO;
		_numberOfTrailingZero = 0;
	}
}

- (void)addDecimalSeparator {
	_lastHasDot = YES;
	_numberOfTrailingZero = 0;
}

- (void)addElement:(A3ExpressionElement *)element {
	[self.elements addObject:element];
	_lastHasDot = NO;
	_numberOfTrailingZero = 0;
}

- (void)delete {
	if (_lastHasDot) {
		_lastHasDot = NO;
		return;
	}
	if (![_elements count]) {
		return;
	}
	A3ExpressionElement *element = [self.elements lastObject];
	switch (element.expressionKind) {
		case A3E_Number:
		case A3E_PERCENT:
		case A3E_SIN:
		case A3E_COSH:
		case A3E_COS:
		case A3E_TAN:
		case A3E_SINH:
		case A3E_TANH:
		case A3E_ASIN:
		case A3E_ACOS:
		case A3E_ATAN:
		case A3E_ASINH:
		case A3E_ACOSH:
		case A3E_ATANH:
		case A3E_SQUARE:
		case A3E_CUBE:
		case A3E_POWER_10:
		case A3E_LN:
		case A3E_LOG_10:
		case A3E_LOG_2:
		case A3E_LOG_Y:
		case A3E_SQUAREROOT:
		case A3E_CUBEROOT:
		case A3E_FACTORIAL:
		case A3E_POWER_E:
		case A3E_E_Number:
		case A3E_POWER_XY:
		case A3E_NTHROOT:
		{
			if (![element.arguments count]) {
				[self.elements removeLastObject];
			} else {
				NSString *numberInString = [NSString stringWithFormat:@"%@", element.arguments[[element.arguments count] - 1] ];
				if ([numberInString length]) {
					double newNumber = [[numberInString substringToIndex:[numberInString length] - 2] doubleValue];
					[element.arguments removeLastObject];
					if (newNumber != 0.0) {
					} else {
						[element.arguments addObject:@(newNumber)];
					}
				}
			}
			break;
		}
		case A3E_PI:
		case A3E_BASE_E:
		case A3E_RANDOM:
		case A3E_PLUS:
		case A3E_MINUS:
		case A3E_MULTIPLY:
		case A3E_DIVIDE:
		case A3E_LEFT_PARENTHESIS:
		case A3E_RIGHT_PARENTHESIS:
			[self.elements removeLastObject];
			break;
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

- (NSAttributedString *)attributedString {
	NSMutableAttributedString *out = [NSMutableAttributedString new];
	NSNumberFormatter *nf = [NSNumberFormatter new];
	[nf setNumberStyle:NSNumberFormatterDecimalStyle];

	for (A3ExpressionElement *element in self.elements) {
		NSMutableAttributedString *stringToAdd;
		switch (element.expressionKind) {
			case A3E_Number:
				stringToAdd = [[NSMutableAttributedString alloc] initWithString:[nf stringFromNumber:element.arguments[0]] attributes:[self expressionAttribute]];
				break;
			case A3E_E_Number:{
				NSString *head = @"", *tail = @"";

				if ([self.elements count] >= 1) {
					head = [nf stringFromNumber:element.arguments[0]];
				}
				if ([self.elements count] >= 2) {
					tail = [NSString stringWithFormat:@"%d", [element.arguments[1] integerValue] ];
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
			{
				NSString *number = @"";
				if ([element.arguments count]) {
					number = [nf stringFromNumber:element.arguments[0]];
				}
				stringToAdd = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%%", number] attributes:[self expressionAttribute]];
				break;
			}
			case A3E_LEFT_PARENTHESIS:
				stringToAdd = [[NSMutableAttributedString alloc] initWithString:@"(" attributes:[self expressionAttribute]];
				break;
			case A3E_RIGHT_PARENTHESIS:
				stringToAdd = [[NSMutableAttributedString alloc] initWithString:@")" attributes:[self expressionAttribute]];
				break;
			case A3E_SIN:
				stringToAdd = [self attributedStringForElement1:element format:@"sin(%@)" nf:nf];
				break;
			case A3E_COS:
				stringToAdd = [self attributedStringForElement1:element format:@"cos(%@)" nf:nf];
				break;
			case A3E_TAN:
				stringToAdd = [self attributedStringForElement1:element format:@"tan(%@)" nf:nf];
				break;
			case A3E_SINH:
				stringToAdd = [self attributedStringForElement1:element format:@"sinh(%@)" nf:nf];
				break;
			case A3E_COSH:
				stringToAdd = [self attributedStringForElement1:element format:@"cosh(%@)" nf:nf];
				break;
			case A3E_TANH:
				stringToAdd = [self attributedStringForElement1:element format:@"tanh(%@)" nf:nf];
				break;
			case A3E_ASIN:
				stringToAdd = [self attributedStringForElement1:element format:@"sin-1(%@)" nf:nf];
				[self superscriptString:stringToAdd Range:NSMakeRange(3,2) value:@1];
				break;
			case A3E_ACOS:
				stringToAdd = [self attributedStringForElement1:element format:@"cos-1(%@)" nf:nf];
				[self superscriptString:stringToAdd Range:NSMakeRange(3,2) value:@1];
				break;
			case A3E_ATAN:
				stringToAdd = [self attributedStringForElement1:element format:@"tan-1(%@)" nf:nf];
				[self superscriptString:stringToAdd Range:NSMakeRange(3,2) value:@1];
				break;
			case A3E_ASINH:
				stringToAdd = [self attributedStringForElement1:element format:@"sinh-1(%@)" nf:nf];
				[self superscriptString:stringToAdd Range:NSMakeRange(4,2) value:@1];
				break;
			case A3E_ACOSH:
				stringToAdd = [self attributedStringForElement1:element format:@"cosh-1(%@)" nf:nf];
				[self superscriptString:stringToAdd Range:NSMakeRange(4,2) value:@1];
				break;
			case A3E_ATANH:
				stringToAdd = [self attributedStringForElement1:element format:@"tanh-1(%@)" nf:nf];
				[self superscriptString:stringToAdd Range:NSMakeRange(4,2) value:@1];
				break;
			case A3E_SQUARE:
				stringToAdd = [self attributedStringForElement1:element format:@"%@2" nf:nf];
				[self superscriptString:stringToAdd Range:NSMakeRange([stringToAdd length] - 1, 1) value:@1];
				break;
			case A3E_CUBE:
				stringToAdd = [self attributedStringForElement1:element format:@"%@3" nf:nf];
				[self superscriptString:stringToAdd Range:NSMakeRange([stringToAdd length] - 1, 1) value:@1];
				break;
			case A3E_POWER_XY:
				stringToAdd = [self attributedStringForElement2:element format:@"%@%@" nf:nf];
				[self superscriptString:stringToAdd Range:NSMakeRange([stringToAdd length] - 1, 1) value:@1];
				break;
			case A3E_SQUAREROOT:
				stringToAdd = [self attributedStringForElement1:element format:@"SQRT(%@)" nf:nf];
				break;
			case A3E_CUBEROOT:
				stringToAdd = [self attributedStringForElement1:element format:@"CubeRoot(%@)" nf:nf];
				break;
			case A3E_NTHROOT:
				stringToAdd = [self attributedStringForElement1:element format:@"NthRoot(%@,%@)" nf:nf];
				break;
			case A3E_FACTORIAL:
				stringToAdd = [self attributedStringForElement1:element format:@"%@!" nf:nf];
				break;
			case A3E_PI:
				stringToAdd = [[NSMutableAttributedString alloc] initWithString:@"π" attributes:[self expressionAttribute]];
                break;
			case A3E_BASE_E:
				stringToAdd = [[NSMutableAttributedString alloc] initWithString:@"e" attributes:[self expressionAttribute]];
                break;
			case A3E_RANDOM:
				stringToAdd = [[NSMutableAttributedString alloc] initWithString:@"random()" attributes:[self expressionAttribute]];
                break;
			case A3E_POWER_E:
				stringToAdd = [self attributedStringForElement1:element format:@"e%@" nf:nf];
				[self superscriptString:stringToAdd Range:NSMakeRange(1,1) value:@1];
				break;
			case A3E_POWER_10:
				stringToAdd = [self attributedStringForElement1:element format:@"10%@" nf:nf];
				[self superscriptString:stringToAdd Range:NSMakeRange(2,1) value:@1];
				break;
			case A3E_LN:
				stringToAdd = [self attributedStringForElement1:element format:@"ln(%@)" nf:nf];
				break;
			case A3E_LOG_10:
				stringToAdd = [self attributedStringForElement1:element format:@"log10(%@)" nf:nf];
				[self superscriptString:stringToAdd Range:NSMakeRange(3,2) value:@-1];
                break;
			case A3E_LOG_2:
				stringToAdd = [self attributedStringForElement1:element format:@"log2(%@)" nf:nf];
				[self superscriptString:stringToAdd Range:NSMakeRange(3,1) value:@-1];
				break;
			case A3E_LOG_Y:
			{
				NSString *number1 = @"", *number2 = @"";
				if ([element.arguments count]) {
					number1 = [nf stringFromNumber:element.arguments[0]];
				}
				if ([element.arguments count] >= 2) {
					number2 = [NSString stringWithFormat:@"%d", [element.arguments[1] integerValue]];
				}
				stringToAdd = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"log%@(%@)", number2, number1] attributes:[self expressionAttribute]];
				[self superscriptString:stringToAdd Range:NSMakeRange(3, [number2 length]) value:@-1];
				break;
			}
		}
		[out appendAttributedString:stringToAdd];
		[out appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:[self expressionAttribute]]];
	}
	return out;
}

- (NSMutableAttributedString *)attributedStringForElement1:(A3ExpressionElement *)element format:(NSString *)format nf:(NSNumberFormatter *)nf
{
	NSString *number = @"";
	if ([element.arguments count]) {
		number = [nf stringFromNumber:element.arguments[0]];
	}
	return [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:format, number] attributes:[self expressionAttribute]];
}

- (NSMutableAttributedString *)attributedStringForElement2:(A3ExpressionElement *)element format:(NSString *)format nf:(NSNumberFormatter *)nf
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

- (NSMutableArray *)elements {
	if (!_elements) {
		_elements = [NSMutableArray new];
	}
	return _elements;
}

@end
