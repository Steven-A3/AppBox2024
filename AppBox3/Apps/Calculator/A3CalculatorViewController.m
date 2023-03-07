//
//  A3CalculatorViewController.m
//  AppBox3
//
//  Created by A3 on 3/28/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "HTCopyableLabel.h"
#import "A3CalculatorViewController.h"
#import "A3UserDefaultsKeys.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "UIViewController+A3Addition.h"

@interface A3CalculatorViewController () <GADBannerViewDelegate>

@end

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
	[[A3SyncManager sharedSyncManager] setBool:radian forKey:A3CalculatorUserDefaultsRadianDegreeState state:A3DataObjectStateModified];
}

- (BOOL)radian {
    return [[A3SyncManager sharedSyncManager] boolForKey:A3CalculatorUserDefaultsRadianDegreeState];
}

- (void)viewDidLoad {
	[super viewDidLoad];

    [self makeNavigationBarAppearanceDefault];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

	if ([self isMovingToParentViewController] || [self isBeingPresented]) {
		[self setupBannerViewForAdUnitID:AdMobAdUnitIDCalculator keywords:@[@"calculator"] delegate:self];
	}
	if (IS_IPHONE && IS_PORTRAIT && [self.navigationController.navigationBar isHidden]) {
		[self showNavigationBarOn:self.navigationController];
	}
}

@end
