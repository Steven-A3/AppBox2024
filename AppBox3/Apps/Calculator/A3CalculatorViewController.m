//
//  A3CalculatorViewController.m
//  AppBox3
//
//  Created by A3 on 3/28/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "HTCopyableLabel.h"
#import "A3CalculatorViewController.h"
#import "A3UserDefaults.h"

@implementation A3CalculatorViewController

- (instancetype)initWithPresentingViewController:(UIViewController *)modalPresentingParentViewController {
	self = [super initWithNibName:nil bundle:nil];
	if (self) {
		_modalPresentingParentViewController = modalPresentingParentViewController;
	}
	return self;
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
	[self dismissViewControllerAnimated:YES completion:nil];

	[_delegate calculatorDidDismissWithValue:self.evaluatedResultLabel.text];
}

- (void)cancelButtonAction:(UIBarButtonItem *)barButtonItem {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setRadian:(BOOL)radian {
	[[NSUserDefaults standardUserDefaults] setBool:radian forKey:A3CalculatorUserDefaultsRadianDegreeState];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)radian {
    return [[NSUserDefaults standardUserDefaults] boolForKey:A3CalculatorUserDefaultsRadianDegreeState];
}

@end
