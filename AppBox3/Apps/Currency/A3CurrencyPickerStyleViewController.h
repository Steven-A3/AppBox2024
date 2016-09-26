//
//  A3CurrencyPickerStyleViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 12/9/15.
//  Copyright © 2015 ALLABOUTAPPS. All rights reserved.
//

@class A3CurrencyDataManager, A3CurrencyViewController;

@interface A3CurrencyPickerStyleViewController : UIViewController

@property (nonatomic, weak) A3CurrencyDataManager *currencyDataManager;
@property (nonatomic, weak) A3CurrencyViewController *mainViewController;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

- (void)resetIntermediateState;
- (void)shareButtonAction:(id)sender;
- (void)showInstructionView;

@end
