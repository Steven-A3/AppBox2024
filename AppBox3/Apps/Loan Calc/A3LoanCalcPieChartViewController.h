//
//  A3LoanCalcPieChartViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/8/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@protocol A3LoanCalcPieChartViewDelegate <NSObject>
- (void)loanCalcPieChartViewButtonPressed;

@end

@interface A3LoanCalcPieChartViewController : UIViewController <CPTPlotDataSource>

@property (nonatomic)	NSNumber *principal, *totalInterest, *monthlyPayment, *monthlyAverageInterest, *totalAmount;
@property (nonatomic, weak) id<A3LoanCalcPieChartViewDelegate> delegate;

- (void)reloadData;

@end
