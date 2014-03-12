//
//  A3CalculatorUtil.h
//  A3TeamWork
//
//  Created by Soon Gyu Kim on 12/28/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface A3CalculatorUtil : NSObject
- (id)stringWithSuperscript:(NSString *)input location:(NSUInteger)loc length:(NSUInteger)len value:(id) index;
- (id)stringArcTanh;
- (id)stringArcCosh;
- (id)stringArcSinh;
- (id)stringArcTan;
- (id)stringArcCos;
- (id)stringArcSin;
- (id)stringEx;
- (id)stringLog2;
- (id)stringLogy;
- (id)string2X;
- (id)stringYX;
- (id)stringLog10;
- (id)string10X;
- (id)string10XBigFont;
- (id)stringXY;
- (id)stringX3 ;
- (id)stringX2;
- (id)stringSecond;
- (id)stringSecondBigFont;
- (id)stringSquare;
- (id) stringSquareroot;
- (id)stringCube;
- (id)stringCuberoot;
- (id)stringArcCot;
- (id)stringWithSuperscriptMiddleFont:(NSString *)input location:(NSUInteger)loc length:(NSUInteger)len value:(id) index;
@end
