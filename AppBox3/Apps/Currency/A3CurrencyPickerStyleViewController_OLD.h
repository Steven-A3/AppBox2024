//
//  A3CurrencyPickerStyleViewController_OLD.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/29/15.
//  Copyright © 2015 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A3CurrencyDataManager;
@class A3CurrencyViewController;

@interface A3CurrencyPickerStyleViewController_OLD : UIViewController

@property (weak, nonatomic) A3CurrencyDataManager *currencyDataManager;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) A3CurrencyViewController *mainViewController;

- (void)resetIntermediateState;
- (void)shareButtonAction:(id)sender;

@end
