//
//  A3LoanCalcComparisonTopLeftViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 3/19/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoanCalcHistory;

@interface A3LoanCalcComparisonTopLeftViewController : UIViewController

@property (nonatomic, weak)	LoanCalcHistory *leftObject, *rightObject;

- (void)updateLabels;
@end
