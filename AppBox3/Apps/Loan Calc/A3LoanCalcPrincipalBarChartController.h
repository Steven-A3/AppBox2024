//
//  A3LoanCalcPrincipalBarChartController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 3/20/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@class LoanCalcHistory;

@interface A3LoanCalcPrincipalBarChartController : NSObject <CPTPlotDataSource>

@property (nonatomic, strong) CPTGraphHostingView *graphHostingView;
@property (nonatomic, weak) LoanCalcHistory *objectA, *objectB;

- (void)configureBarChart;
- (void)reloadData;

@end
