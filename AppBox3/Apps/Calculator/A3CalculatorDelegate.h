//
//  A3CalculatorDelegate
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 3/28/14 12:34 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol A3CalculatorDelegate <NSObject>

- (void)calculatorViewController:(UIViewController *)viewController didDismissWithValue:(NSString *)value;

@end
