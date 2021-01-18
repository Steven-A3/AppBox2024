//
//  A3CalcKeyboardView_iPhone.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/22/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3CalcKeyboardViewDelegate <NSObject>

- (void)keyboardButtonPressed:(NSUInteger)key;
- (BOOL)radian;

@end

@class A3KeyboardButton_iOS7_iPhone;

@interface A3CalcKeyboardView_iPhone : UIView

@property (nonatomic, weak) id<A3CalcKeyboardViewDelegate> delegate;
@property (nonatomic, strong) A3KeyboardButton_iOS7_iPhone *radianDegreeButton;

- (CGFloat)scaleToDesignForCalculator;

@end
