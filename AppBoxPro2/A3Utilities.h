//
//  A3Utilities.h
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 6/11/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

void addLeftGradientLayer8Point(UIView *targetView);
void addRightGradientLayer8Point(UIView *targetView);
void drawLinearGradient(CGContextRef context, CGRect rect, NSArray *colors);
BOOL UserInterfacePortrait();

extern float dash_line_pattern[];

@interface A3Utilities : NSObject

@end
