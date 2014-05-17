//
//  A3CalculatorViewController.h
//  AppBox3
//
//  Created by A3 on 3/28/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//


@protocol A3CalculatorDelegate;
@class HTCopyableLabel;

extern NSString *const A3NotificationCalculatorDismissedWithValue;

@interface A3CalculatorViewController : UIViewController {
	UIViewController *_modalPresentingParentViewController;
}

@property (nonatomic, weak) id<A3CalculatorDelegate> delegate;
@property (nonatomic, strong) HTCopyableLabel *evaluatedResultLabel;

- (instancetype)initWithPresentingViewController:(UIViewController *)modalPresentingParentViewController;

@end
