//
//  A3CalculatorViewController_iPad.h
//  A3TeamWork
//
//  Created by Soon Gyu Kim on 12/24/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3CalculatorViewController.h"
#import "A3CalculatorButtonsViewController_iPad.h"

@protocol A3CalculatorDelegate;

@interface A3CalculatorViewController_iPad : A3CalculatorViewController<UIActivityItemSource>

- (void) checkRightButtonDisable;

@end
