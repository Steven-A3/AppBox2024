//
//  A3LoanCalcBarPlotItem.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 3/20/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface A3LoanCalcBarPlotItem : NSObject <CPTPlotDataSource>

@property (nonatomic, strong) NSNumber *principal_A, *principal_B;
@property (nonatomic, strong) NSNumber *totalInterest_A, *totalInterest_B;
@property (nonatomic, strong) NSNumber *monthlyPayment_A, *monthlyPayment_B;
@property (nonatomic, strong) CPTGraphHostingView *graphHostingView;

- (void)addBarPlotForPrincipal;
- (void)reloadData;
- (void)addBarPlotForMonthlyPaymentWithFrame:(CGRect)frame;

@end
