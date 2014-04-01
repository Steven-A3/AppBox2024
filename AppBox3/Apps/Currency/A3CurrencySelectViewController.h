//
//  A3CurrencySelectViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 1/18/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3SearchViewController.h"


@interface A3CurrencySelectViewController : A3SearchViewController

@property (assign, nonatomic) BOOL showCancelButton;

- (instancetype)initWithPresentingViewController:(UIViewController *)modalPresentingParentViewController;
@end
