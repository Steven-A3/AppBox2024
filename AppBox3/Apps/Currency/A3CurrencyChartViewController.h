//
//  A3CurrencyChartViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/31/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A3CacheStoreManager;

@protocol A3CurrencyChartViewDelegate <NSObject>
- (void)chartViewControllerValueChanged:(NSNumber *)newValue;

@end

@interface A3CurrencyChartViewController : UIViewController

@property (nonatomic, copy) NSString *sourceCurrencyCode, *targetCurrencyCode;
@property (nonatomic, strong) NSNumber *initialValue;			// Assigned by caller, will not change, compare with textField
@property (nonatomic, weak) id<A3CurrencyChartViewDelegate> delegate;

@property (nonatomic, weak) A3CacheStoreManager *cacheStoreManager;
@end
