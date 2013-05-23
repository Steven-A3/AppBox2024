//
//  A3LoanCalcChartViewController_iPhone.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/21/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@class A3OnOffLeftRightButton;

@protocol A3LoanCalcChartViewControllerDelegate <NSObject>
- (void)loanCalcChartViewButtonPressed:(BOOL)left;
@end

@interface A3LoanCalcChartViewController_iPhone : UIViewController
@property (nonatomic, weak) IBOutlet UILabel *row_one_value_label;
@property (nonatomic, weak) IBOutlet UILabel *row_one_title_label;
@property (nonatomic, weak) IBOutlet UILabel *row_two_value_label;
@property (nonatomic, weak) IBOutlet UILabel *row_two_title_label;
@property (nonatomic, weak) IBOutlet UILabel *row_three_value_label;
@property (nonatomic, weak) IBOutlet UILabel *row_three_title_label;
@property (nonatomic, weak) IBOutlet A3OnOffLeftRightButton *leftButton;
@property (nonatomic, weak) IBOutlet A3OnOffLeftRightButton *rightButton;
@property (nonatomic, weak) IBOutlet CPTGraphHostingView *graphHostingView;

@property (nonatomic, weak) id<A3LoanCalcChartViewControllerDelegate> delegate;

@end
