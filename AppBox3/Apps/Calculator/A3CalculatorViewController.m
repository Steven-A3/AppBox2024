//
//  A3CalculatorViewController.m
//  AppBox3
//
//  Created by A3 on 3/28/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "HTCopyableLabel.h"
#import "A3CalculatorViewController.h"
#import "A3CalculatorDelegate.h"

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
	id <A3CalculatorDelegate> delegate = self.delegate;
	if ([delegate respondsToSelector:@selector(calculatorViewController:didDismissWithValue:)]) {
		NSNumberFormatter *nf = [NSNumberFormatter new];
		[nf setNumberStyle:NSNumberFormatterDecimalStyle];
		NSNumber *resultNumber = [nf numberFromString:self.evaluatedResultLabel.text];
		if ([resultNumber doubleValue] != 0.0) {
			[nf setUsesGroupingSeparator:NO];
			[delegate calculatorViewController:self didDismissWithValue:[nf stringFromNumber:resultNumber]];
		}
	}
}

- (void)cancelButtonAction:(UIBarButtonItem *)barButtonItem {
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
