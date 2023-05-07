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
#import "Calculation.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"
#import "UIViewController+extension.h"

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

	if ([self isMovingToParentViewController] || [self isBeingPresented]) {
		[self setupBannerViewForAdUnitID:AdMobAdUnitIDCalculator keywords:@[@"calculator"] delegate:self];
	}
	if (IS_IPHONE && IS_PORTRAIT && [self.navigationController.navigationBar isHidden]) {
		[self showNavigationBarOn:self.navigationController];
	}
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)putCalculationHistoryWithExpression:(NSString *)expression {
    NSArray *results = [Calculation findAllSortedBy:@"updateDate" ascending:NO];
    Calculation *lastcalculation = results.firstObject;
    NSString *mathExpression = [self.calculator getMathExpression];
    // Compare code and value.
    if (lastcalculation) {
        if ([lastcalculation.expression isEqualToString:mathExpression]) {
            return;
        }
    }

    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    Calculation *calculation = [[Calculation alloc] initWithContext:context];
    calculation.uniqueID = [[NSUUID UUID] UUIDString];
    NSDate *keyDate = [NSDate date];
    calculation.expression = mathExpression;
    calculation.result = self.evaluatedResultLabel.text;
    calculation.updateDate = keyDate;

    [context saveContext];
}

@end
