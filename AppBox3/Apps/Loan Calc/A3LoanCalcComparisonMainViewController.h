//
//  A3LoanCalcComparisonMainViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 3/21/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3AppViewController.h"
#import "DDPageControl.h"
#import "LoanCalcHistory+calculation.h"
#import "A3HistoryViewController.h"

@class A3LoanCalcComparisonTableViewDataSource;
@class A3CircleView;

@interface A3LoanCalcComparisonMainViewController : A3AppViewController <UIScrollViewDelegate, A3HistoryViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *topScrollView;
@property (nonatomic, strong) LoanCalcHistory *leftObject, *rightObject;
@property (nonatomic, weak) IBOutlet DDPageControl *pageControl;

@property (nonatomic, weak) IBOutlet UIScrollView *mainScrollView;
@property (nonatomic, weak) IBOutlet UITableView *leftTableView;
@property (nonatomic, weak) IBOutlet UITableView *rightTableView;
@property (nonatomic, weak) IBOutlet A3CircleView *loanACircleView, *loanBCircleView;

@property (nonatomic, strong) A3LoanCalcComparisonTableViewDataSource *leftTableViewDataSource, *rightTableViewDataSource;

- (void)configureTopScrollView;

- (void)loanCalcComparisonTableViewValueChanged;

- (void)reloadData;
@end
