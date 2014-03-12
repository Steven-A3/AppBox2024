//
//  A3CalculatorHistoryViewController.h
//  A3TeamWork
//
//  Created by Soon Gyu Kim on 12/30/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3Calculator.h"
#import "A3CalculatorViewController_iPad.h"
@interface A3CalculatorHistoryViewController : UITableViewController
@property (nonatomic, strong)   A3Calculator *calculator;
@property (nonatomic, strong)   A3CalculatorViewController_iPad *iPadViewController;
@end
