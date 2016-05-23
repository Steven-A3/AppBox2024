//
//  A3CalculatorUtil.h
//  A3TeamWork
//
//  Created by Soon Gyu Kim on 12/28/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface A3CalculatorUtil : NSObject

- (NSMutableAttributedString *)stringWithSuperscript:(NSString *)input location:(NSUInteger)loc length:(NSUInteger)len value:(NSNumber *)option;
- (NSMutableAttributedString *)stringArcTanh;
- (NSMutableAttributedString *)stringArcCosh;
- (NSMutableAttributedString *)stringArcSinh;
- (NSMutableAttributedString *)stringArcTan;
- (NSMutableAttributedString *)stringArcCos;
- (NSMutableAttributedString *)stringArcSin;
- (NSMutableAttributedString *)stringEx;
- (NSMutableAttributedString *)stringLog2;
- (NSMutableAttributedString *)stringLogy;
- (NSMutableAttributedString *)string2X;
- (NSMutableAttributedString *)stringYX;
- (NSMutableAttributedString *)stringLog10;
- (NSMutableAttributedString *)string10X;
- (NSMutableAttributedString *)string10XBigFont;
- (NSMutableAttributedString *)stringXY;
- (NSMutableAttributedString *)stringX3 ;
- (NSMutableAttributedString *)stringX2;
- (NSMutableAttributedString *)stringSecond;
- (NSMutableAttributedString *)stringSecondBigFont;
- (NSMutableAttributedString *)stringSquare;
- (NSMutableAttributedString *)stringSquareroot;
- (NSMutableAttributedString *)stringCube;
- (NSMutableAttributedString *)stringCuberoot;
- (NSMutableAttributedString *)stringArcCot;
- (NSMutableAttributedString *)stringWithSuperscriptMiddleFont:(NSString *)input location:(NSUInteger)loc length:(NSUInteger)len value:(NSNumber *) option;
- (NSMutableAttributedString *)stringWithSuperscriptSystemFont:(NSString *)input location:(NSUInteger)loc length:(NSUInteger)len value:(NSNumber *) option;
- (NSMutableAttributedString *)stringArcTanh_h;
- (NSMutableAttributedString *)stringArcCosh_h;
- (NSMutableAttributedString *)stringArcSinh_h;
- (NSMutableAttributedString *)stringArcTan_h;
- (NSMutableAttributedString *)stringArcCos_h ;
- (NSMutableAttributedString *)stringArcSin_h ;
- (NSMutableAttributedString *)stringArcCot_h;
- (NSMutableAttributedString *)stringEx_h;
- (NSMutableAttributedString *)stringLog2_h;
- (NSMutableAttributedString *)stringLogy_h ;
- (NSMutableAttributedString *)string2X_h;
- (NSMutableAttributedString *)stringYX_h;
- (NSMutableAttributedString *)stringLog10_h;
- (NSMutableAttributedString *)string10X_h;
- (NSMutableAttributedString *)string10XBigFont_h;
- (NSMutableAttributedString *)stringXY_h;
- (NSMutableAttributedString *)stringX3_h;
- (NSMutableAttributedString *)stringX2_h;
- (NSMutableAttributedString *)stringSquare_h;
- (NSMutableAttributedString *)stringCube_h;
- (NSMutableAttributedString *)stringCubeRoot_h;
- (NSMutableAttributedString *)stringSquareRoot_h;
- (NSMutableAttributedString *)invisibleString ;

@end
