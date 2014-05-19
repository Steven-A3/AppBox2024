//
//  A3CalculatorViewController.h
//  AppBox3
//
//  Created by A3 on 3/28/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

@protocol A3CalculatorViewControllerDelegate <NSObject>

- (void)calculatorDidDismissWithValue:(NSString *)value;

@end

@class HTCopyableLabel;

@interface A3CalculatorViewController : UIViewController {
	UIViewController *_modalPresentingParentViewController;
}

@property (nonatomic, strong) HTCopyableLabel *evaluatedResultLabel;
@property (nonatomic, weak) id<A3CalculatorViewControllerDelegate> delegate;

- (instancetype)initWithPresentingViewController:(UIViewController *)modalPresentingParentViewController;

@end
