//
//  A3StatisticsViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/19/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface A3StatisticsViewController : UIViewController <CPTPlotDataSource, CPTPlotDelegate>
@property (nonatomic)	BOOL 			showPieChart;

@end
