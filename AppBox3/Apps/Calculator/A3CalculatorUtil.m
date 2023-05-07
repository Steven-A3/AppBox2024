//
//  A3CalculatorUtil.m
//  A3TeamWork
//
//  Created by Soon Gyu Kim on 12/28/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CalculatorUtil.h"
#import <CoreText/CoreText.h>
#import "A3UIDevice.h"

@implementation A3CalculatorUtil

- (UIFont *)superscriptFont {
	return [UIFont systemFontOfSize:10];
}

- (UIFont *)superscriptBigFont {
	return [UIFont fontWithName:@"HelveticaNeue-Medium" size:20];
}

- (UIFont *)superscriptMiddleFont {
	return [UIFont fontWithName:@"HelveticaNeue-Medium" size:IS_IPAD?17:12];
}

- (UIFont *)superscriptSystemFont {
	return [UIFont systemFontOfSize:11];
}

- (void)addSuperSubscriptToAttributedString:(NSMutableAttributedString *)attributedString location:(NSUInteger)loc length:(NSUInteger)length option:(NSNumber *)option {
	if (IS_IPHONE) {
		[attributedString addAttribute:NSBaselineOffsetAttributeName value:[option isEqualToNumber:@1] ? @5 : @-5 range:NSMakeRange(loc,length)];
	} else {
		[attributedString addAttribute:NSBaselineOffsetAttributeName value:[option isEqualToNumber:@1] ? @8 : @-8 range:NSMakeRange(loc,length)];
	}
}

- (NSMutableAttributedString *)stringWithSuperscript:(NSString *)input location:(NSUInteger)loc length:(NSUInteger)len value:(NSNumber *)option {
	NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:input];
	[self addSuperSubscriptToAttributedString:string location:loc length:len option:option];
	[string addAttribute:(NSString *)kCTFontAttributeName value:[self superscriptFont] range:NSMakeRange(loc,len)];
	return string;
}

- (NSMutableAttributedString *)stringWithSuperscriptBigFont:(NSString *)input location:(NSUInteger)loc length:(NSUInteger)len value:(NSNumber *)option {
	NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:input];
	[self addSuperSubscriptToAttributedString:string location:loc length:len option:option];
	[string addAttribute:(NSString *)kCTFontAttributeName value:[self superscriptBigFont] range:NSMakeRange(loc,len)];
	return string;
}

- (NSMutableAttributedString *)stringWithSuperscriptMiddleFont:(NSString *)input location:(NSUInteger)loc length:(NSUInteger)len value:(NSNumber *)option {
	NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:input];
	[self addSuperSubscriptToAttributedString:string location:loc length:len option:option];
	[string addAttribute:(NSString *)kCTFontAttributeName value:[self superscriptMiddleFont] range:NSMakeRange(loc,len)];
	return string;
}

- (NSMutableAttributedString *)stringWithSuperscriptSystemFont:(NSString *)input location:(NSUInteger)loc length:(NSUInteger)len value:(NSNumber *)option {
	NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:input];
	[self addSuperSubscriptToAttributedString:string location:loc length:len option:option];
	[string addAttribute:(NSString *)kCTFontAttributeName value:[self superscriptSystemFont] range:NSMakeRange(loc,len)];
	return string;
}

- (NSMutableAttributedString *)invisibleString {
	NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"lll"];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor clearColor] range:NSMakeRange(0,3)];
   // [string addAttribute: NSBaselineOffsetAttributeName value: [NSNumber numberWithFloat: -10.0] range:NSMakeRange(0,1)];
    	[string addAttribute:(NSString *)kCTSuperscriptAttributeName value:@(-1)   range:NSMakeRange(0,1)];
    [string addAttribute:(NSString *)kCTSuperscriptAttributeName value:@(1)   range:NSMakeRange(2,1)];

//        [string addAttribute: NSBaselineOffsetAttributeName value: [NSNumber numberWithFloat: 10.0] range:NSMakeRange(2,1)];
	//[string addAttribute:NSFontAttributeName value:[self superscriptSystemFont] range:NSMakeRange(0, 3)];
	return string;
}

- (NSMutableAttributedString *)stringArcTanh {
	return [self stringWithSuperscript:@"tanh-1" location:4 length:2 value:@1];
}

- (NSMutableAttributedString *)stringArcCosh {
	return [self stringWithSuperscript:@"cosh-1" location:4 length:2 value:@1];
}

- (NSMutableAttributedString *)stringArcSinh {
	return [self stringWithSuperscript:@"sinh-1" location:4 length:2 value:@1];
}

- (NSMutableAttributedString *)stringArcTan {
	return [self stringWithSuperscript:@"tan-1" location:3 length:2 value:@1];
}

- (NSMutableAttributedString *)stringArcCos {
	return [self stringWithSuperscript:@"cos-1" location:3 length:2 value:@1];
}

- (NSMutableAttributedString *)stringArcSin {
	return [self stringWithSuperscript:@"sin-1" location:3 length:2 value:@1];
}

- (NSMutableAttributedString *)stringArcCot {
    return [self stringWithSuperscript:@"cot-1" location:3 length:2 value:@1];
}

- (NSMutableAttributedString *)stringEx {
	return [self stringWithSuperscript:@"ex" location:1 length:1 value:@1];
}

- (NSMutableAttributedString *)stringLog2 {
	return [self stringWithSuperscript:@"log2" location:3 length:1 value:@-1];
}

- (NSMutableAttributedString *)stringLogy {
	return [self stringWithSuperscript:@"logy" location:3 length:1 value:@-1];
}

- (NSMutableAttributedString *)string2X {
	return [self stringWithSuperscript:@"2x" location:1 length:1 value:@1];
}

- (NSMutableAttributedString *)stringYX {
	return [self stringWithSuperscript:@"yx" location:1 length:1 value:@1];
}

- (NSMutableAttributedString *)stringLog10 {
	return [self stringWithSuperscriptMiddleFont:@"log10" location:3 length:2 value:@-1];
}

- (NSMutableAttributedString *)string10X {
	return [self stringWithSuperscriptMiddleFont:@"10x" location:2 length:1 value:@1];
}

- (NSMutableAttributedString *)string10XBigFont {
	return [self stringWithSuperscriptBigFont:@"10x" location:2 length:1 value:@1];
}

- (NSMutableAttributedString *)stringXY {
	return [self stringWithSuperscriptMiddleFont:@"xy" location:1 length:1 value:@1];
}

- (NSMutableAttributedString *)stringX3 {
	return [self stringWithSuperscriptMiddleFont:@"x3" location:1 length:1 value:@1];
}

- (NSMutableAttributedString *)stringX2 {
	return [self stringWithSuperscriptMiddleFont:@"x2" location:1 length:1 value:@1];
}

- (NSMutableAttributedString *)stringSecond {
	return [self stringWithSuperscript:@"2nd" location:1 length:2 value:@-1];
}

- (NSMutableAttributedString *)stringSecondBigFont {
	return [self stringWithSuperscriptBigFont:@"2nd" location:1 length:2 value:@-1];
}

- (NSMutableAttributedString *)stringSquare {
    return [self stringWithSuperscriptMiddleFont:@"2" location:0 length:1 value:@1];
}

- (NSMutableAttributedString *)stringCube {
    return [self stringWithSuperscriptMiddleFont:@"3" location:0 length:1 value:@1];
}

- (NSMutableAttributedString *)stringCuberoot {
    return [self stringWithSuperscriptMiddleFont:@"3√(" location:0 length:1 value:@1];
}

- (NSMutableAttributedString *)stringSquareroot{
    return [self stringWithSuperscriptMiddleFont:@"2√(" location:0 length:1 value:@1];
}

- (NSMutableAttributedString *)stringArcTanh_h {
	return [self stringWithSuperscriptSystemFont:@"tanh-1" location:4 length:2 value:@1];
}

- (NSMutableAttributedString *)stringArcCosh_h {
	return [self stringWithSuperscriptSystemFont:@"cosh-1" location:4 length:2 value:@1];
}

- (NSMutableAttributedString *)stringArcSinh_h {
	return [self stringWithSuperscriptSystemFont:@"sinh-1" location:4 length:2 value:@1];
}

- (NSMutableAttributedString *)stringArcTan_h {
	return [self stringWithSuperscriptSystemFont:@"tan-1" location:3 length:2 value:@1];
}

- (NSMutableAttributedString *)stringArcCos_h {
	return [self stringWithSuperscriptSystemFont:@"cos-1" location:3 length:2 value:@1];
}

- (NSMutableAttributedString *)stringArcSin_h {
	return [self stringWithSuperscriptSystemFont:@"sin-1" location:3 length:2 value:@1];
}

- (NSMutableAttributedString *)stringArcCot_h {
    return [self stringWithSuperscriptSystemFont:@"cot-1" location:3 length:2 value:@1];
}

- (NSMutableAttributedString *)stringEx_h {
	return [self stringWithSuperscriptSystemFont:@"ex" location:1 length:1 value:@1];
}

- (NSMutableAttributedString *)stringLog2_h {
	return [self stringWithSuperscriptSystemFont:@"log2" location:3 length:1 value:@-1];
}

- (NSMutableAttributedString *)stringLogy_h {
	return [self stringWithSuperscriptSystemFont:@"logy" location:3 length:1 value:@-1];
}

- (NSMutableAttributedString *)string2X_h {
	return [self stringWithSuperscriptSystemFont:@"2x" location:1 length:1 value:@1];
}

- (NSMutableAttributedString *)stringYX_h {
	return [self stringWithSuperscriptSystemFont:@"yx" location:1 length:1 value:@1];
}

- (NSMutableAttributedString *)stringLog10_h {
	return [self stringWithSuperscriptSystemFont:@"log10" location:3 length:2 value:@-1];
}

- (NSMutableAttributedString *)string10X_h {
	return [self stringWithSuperscriptSystemFont:@"10x" location:2 length:1 value:@1];
}

- (NSMutableAttributedString *)string10XBigFont_h {
	return [self stringWithSuperscriptSystemFont:@"10x" location:2 length:1 value:@1];
}

- (NSMutableAttributedString *)stringXY_h {
	return [self stringWithSuperscriptSystemFont:@"xy" location:1 length:1 value:@1];
}

- (NSMutableAttributedString *)stringX3_h {
	return [self stringWithSuperscriptSystemFont:@"x3" location:1 length:1 value:@1];
}

- (NSMutableAttributedString *)stringX2_h {
	return [self stringWithSuperscriptMiddleFont:@"x2" location:1 length:1 value:@1];
}

- (NSMutableAttributedString *)stringSquare_h {
    return [self stringWithSuperscriptSystemFont:@"2" location:0 length:1 value:@1];
}

- (NSMutableAttributedString *)stringCube_h {
    return [self stringWithSuperscriptSystemFont:@"3" location:0 length:1 value:@1];
}

- (NSMutableAttributedString *)stringCubeRoot_h {
    return [self stringWithSuperscriptSystemFont:@"3√(" location:0 length:1 value:@1];
}

- (NSMutableAttributedString *)stringSquareRoot_h {
    return [self stringWithSuperscriptSystemFont:@"2√(" location:0 length:1 value:@1];
}

@end
