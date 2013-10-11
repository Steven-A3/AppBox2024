//
//  A3Expression.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/25/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A3ExpressionComponent.h"

@interface A3Expression : NSObject

/*
 * Indicates this expression is closed or not.
 * Expression could be closed by entering ")"
 * It will be used to determine weather new number input should add to this expression or not
 */
@property (assign, getter = isClosed) BOOL closed;

- (void)keyboardInput:(A3ExpressionKind)input;
- (NSMutableAttributedString *)mutableAttributedString;

@end
