//
//  A3CurrencySelectViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 1/18/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3SearchViewController.h"

extern NSString *const A3NotificationCurrencyCodeSelected;	// Object has selected currency code

@interface A3CurrencySelectViewController : A3SearchViewController

@property (nonatomic, strong) NSString *selectedCurrencyCode;

- (instancetype)initWithPresentingViewController:(UIViewController *)modalPresentingParentViewController;

@end
