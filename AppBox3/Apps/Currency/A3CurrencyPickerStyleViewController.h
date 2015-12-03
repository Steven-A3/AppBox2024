//
//  A3CurrencyPickerStyleViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/29/15.
//  Copyright © 2015 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A3CurrencyDataManager;

@interface A3CurrencyPickerStyleViewController : UIViewController

@property (weak, nonatomic) A3CurrencyDataManager *currencyDataManager;

- (void)resetIntermediateState;

@end
