//
//  A3LoanCalcPieChartViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/8/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3AppViewController.h"
@class A3LoanCalcPieChartController;

@protocol A3LoanCalcPieChartViewDelegate <NSObject>
- (void)loanCalcPieChartViewButtonPressed;

@end

@interface A3LoanCalcPieChartViewController : A3AppViewController

@property (nonatomic, weak) id<A3LoanCalcPieChartViewDelegate> delegate;
@property (nonatomic, weak) A3LoanCalcPieChartController *chartController;

- (void)reloadData;

@end
