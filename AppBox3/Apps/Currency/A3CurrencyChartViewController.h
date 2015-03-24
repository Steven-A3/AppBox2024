//
//  A3CurrencyChartViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/31/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A3CurrencyChartViewController;
@class A3CurrencyDataManager;

@protocol A3CurrencyChartViewDelegate <NSObject>
- (void)chartViewControllerValueChangedChartViewController:(A3CurrencyChartViewController *)chartViewController valueChanged:(NSNumber *)newValue;

@end

@interface A3CurrencyChartViewController : UIViewController

@property (nonatomic, copy) NSString *originalSourceCode, *originalTargetCode;
@property (nonatomic, strong) NSNumber *initialValue;			// Assigned by caller, will not change, compare with textField
@property (nonatomic, weak) id<A3CurrencyChartViewDelegate> delegate;
@property (nonatomic, weak) A3CurrencyDataManager *currencyDataManager;

@end
