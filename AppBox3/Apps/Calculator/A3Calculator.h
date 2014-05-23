//
//  A3Calculator.h
//  A3TeamWork
//
//  Created by Soon Gyu Kim on 12/26/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTCopyableLabel.h"
@protocol A3CalcMessagShowDelegate<NSObject>
-(void)ShowMessage:(NSString *) message;
@end

@interface A3Calculator : NSObject
@property (nonatomic, weak) id<A3CalcMessagShowDelegate> delegate;
@property BOOL isLandScape;
- (void)keyboardButtonPressed:(NSUInteger)key;
- (id) initWithLabel:(HTCopyableLabel *) expression result:(HTCopyableLabel *) result;
- (void) setLabel:(HTCopyableLabel *) expression result:(HTCopyableLabel *) result;
- (void) setRadian:(bool) bRadian;
- (NSAttributedString *) getExpressionWith:(NSString *)mathExpression;
- (NSString *) getMathExpression;
- (NSAttributedString *) getMathAttributedExpression;
- (void) evaluateAndSet;
- (NSString *) getResultString;
- (void) setMathExpression:(NSString *) mathExpression;
@end
