//
//  A3CalculatorUtil.m
//  A3TeamWork
//
//  Created by Soon Gyu Kim on 12/28/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CalculatorUtil.h"
#import <CoreText/CoreText.h>

@implementation A3CalculatorUtil
- (UIFont *)superscriptFont {
	return [UIFont fontWithName:@".HelveticaNeueInterface-M3" size:11];
}

- (UIFont *)superscriptBigFont {
	return [UIFont fontWithName:@".HelveticaNeueInterface-M3" size:20];
}

- (UIFont *)superscriptMiddleFont {
	return [UIFont fontWithName:@".HelveticaNeueInterface-M3" size:IS_IPAD?15:12];
}
- (id)stringWithSuperscript:(NSString *)input location:(NSUInteger)loc length:(NSUInteger)len value:(id) index{
	NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:input];
	[string addAttribute:(NSString *)kCTSuperscriptAttributeName value:index   range:NSMakeRange(loc,len)];
	[string addAttribute:(NSString *)kCTFontAttributeName value:[self superscriptFont] range:NSMakeRange(loc,len)];
	return string;
}

- (id)stringWithSuperscriptBigFont:(NSString *)input location:(NSUInteger)loc length:(NSUInteger)len value:(id) index{
	NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:input];
	[string addAttribute:(NSString *)kCTSuperscriptAttributeName value:index   range:NSMakeRange(loc,len)];
	[string addAttribute:(NSString *)kCTFontAttributeName value:[self superscriptBigFont] range:NSMakeRange(loc,len)];
	return string;
}

- (id)stringWithSuperscriptMiddleFont:(NSString *)input location:(NSUInteger)loc length:(NSUInteger)len value:(id) index{
	NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:input];
	[string addAttribute:(NSString *)kCTSuperscriptAttributeName value:index   range:NSMakeRange(loc,len)];
	[string addAttribute:(NSString *)kCTFontAttributeName value:[self superscriptMiddleFont] range:NSMakeRange(loc,len)];
	return string;
}

- (id)stringArcTanh {
	return [self stringWithSuperscript:@"tanh-1" location:4 length:2 value:@1];
}

- (id)stringArcCosh {
	return [self stringWithSuperscript:@"cosh-1" location:4 length:2 value:@1];
}

- (id)stringArcSinh {
	return [self stringWithSuperscript:@"sinh-1" location:4 length:2 value:@1];
}

- (id)stringArcTan {
	return [self stringWithSuperscript:@"tan-1" location:3 length:2 value:@1];
}

- (id)stringArcCos {
	return [self stringWithSuperscript:@"cos-1" location:3 length:2 value:@1];
}

- (id)stringArcSin {
	return [self stringWithSuperscript:@"sin-1" location:3 length:2 value:@1];
}

- (id)stringArcCot {
    return [self stringWithSuperscript:@"cot-1" location:3 length:2 value:@1];
}

- (id)stringEx {
	return [self stringWithSuperscript:@"ex" location:1 length:1 value:@1];
}

- (id)stringLog2 {
	return [self stringWithSuperscript:@"log2" location:3 length:1 value:@-1];
}

- (id)stringLogy {
	return [self stringWithSuperscript:@"logy" location:3 length:1 value:@-1];
}

- (id)string2X {
	return [self stringWithSuperscript:@"2x" location:1 length:1 value:@1];
}

- (id)stringYX {
	return [self stringWithSuperscript:@"yx" location:1 length:1 value:@1];
}

- (id)stringLog10 {
	return [self stringWithSuperscript:@"log10" location:3 length:2 value:@-1];
}

- (id)string10X {
	return [self stringWithSuperscriptMiddleFont:@"10x" location:2 length:1 value:@1];
}

- (id)string10XBigFont {
	return [self stringWithSuperscriptBigFont:@"10x" location:2 length:1 value:@1];
}

- (id)stringXY {
	return [self stringWithSuperscriptMiddleFont:@"xy" location:1 length:1 value:@1];
}

- (id)stringX3 {
	return [self stringWithSuperscriptMiddleFont:@"x3" location:1 length:1 value:@1];
}

- (id)stringX2 {
	return [self stringWithSuperscriptMiddleFont:@"x2" location:1 length:1 value:@1];
}

- (id)stringSecond {
	return [self stringWithSuperscript:@"2nd" location:1 length:2 value:@1];
}

- (id)stringSecondBigFont {
	return [self stringWithSuperscriptBigFont:@"2nd" location:1 length:2 value:@1];
}

- (id)stringSquare {
    return [self stringWithSuperscript:@"2" location:0 length:1 value:@1];
}

- (id)stringCube {
    return [self stringWithSuperscript:@"3" location:0 length:1 value:@1];
}

- (id) stringCuberoot {
    return [self stringWithSuperscript:@"3√(" location:0 length:1 value:@1];
}

- (id) stringSquareroot{
    return [self stringWithSuperscript:@"2√(" location:0 length:1 value:@1];
}
@end
