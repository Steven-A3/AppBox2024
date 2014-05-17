//
//  A3CalculatorViewController.m
//  AppBox3
//
//  Created by A3 on 3/28/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "HTCopyableLabel.h"
#import "A3CalculatorViewController.h"

NSString *const A3NotificationCalculatorDismissedWithValue = @"A3NotificationCalculatorDismissedWithValue";

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
	NSNumberFormatter *nf = [NSNumberFormatter new];
	[nf setNumberStyle:NSNumberFormatterDecimalStyle];
	[nf setUsesGroupingSeparator:NO];
	NSNumber *resultNumber = [nf numberFromString:self.evaluatedResultLabel.text];
	NSString *value = [nf stringFromNumber:resultNumber];

	[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationCalculatorDismissedWithValue object:value];
}

- (void)cancelButtonAction:(UIBarButtonItem *)barButtonItem {
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
