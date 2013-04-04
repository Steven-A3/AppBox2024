//
//  A3LoanCalcSingleBarChartController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/4/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"

@class LoanCalcHistory;

@interface A3LoanCalcSingleBarChartController : NSObject <CPTPlotDataSource>

@property (nonatomic, strong) CPTGraphHostingView *graphHostingView;
@property (nonatomic, weak) LoanCalcHistory *objectA, *objectB;

- (void)reloadData;

@end
