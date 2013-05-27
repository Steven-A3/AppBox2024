//
//  A3LoanCalcViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/8/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3ActionMenuViewControllerDelegate.h"
#import "A3LoanCalcViewController.h"
#import "A3UIKit.h"
#import "A3LoanCalcQuickDialogViewController.h"
#import "A3LoanCalcSettingsViewController.h"
#import "A3AppDelegate.h"
#import "A3LoanCalcComparisonMainViewController.h"
#import "UIViewController+A3AppCategory.h"
#import "A3UIDevice.h"
#import "A3LoanCalcQuickDialogViewController_iPad.h"
#import "A3LoanCalcQuickDialogViewController_iPhone.h"
#import "A3LoanCalcComparisonMainViewController_iPad.h"
#import "A3LoanCalcComparisonMainViewController_iPhone.h"
#import "A3HistoryViewController.h"
#import "A3LoanCalcHistoryViewController.h"
#import "A3LoanCalcCompareHistoryViewController.h"

@interface A3LoanCalcViewController () <A3ActionMenuViewControllerDelegate, A3HistoryViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) A3LoanCalcQuickDialogViewController *quickDialogViewController;
@property (nonatomic, strong) A3LoanCalcComparisonMainViewController *comparisonViewController;
@property (nonatomic, strong) CAGradientLayer *topGradientLayer;

@end

@implementation A3LoanCalcViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.title = NSLocalizedString(@"Loan Calc", @"Loan Calc");
	}
    return self;
}

- (CGRect)contentsViewFrame {
	CGRect frame = self.view.bounds;
	frame.size.height -= 44.0;

	return frame;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

	[self addToolsButtonWithAction:@selector(onActionButton:)];

	[self addChildViewController:self.quickDialogViewController];
	_quickDialogViewController.view.frame = self.contentsViewFrame;
	[self.view addSubview:_quickDialogViewController.view];

	_topGradientLayer = [self addTopGradientLayerToView:self.view position:1.0];

	_segmentedControl.selectedSegmentIndex = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)segmentedControlValueChagend:(UISegmentedControl *)segmentedControl {
	[_topGradientLayer removeFromSuperlayer];

	if (segmentedControl.selectedSegmentIndex == 1) {
		[self.quickDialogViewController removeFromParentViewController];
		[self.quickDialogViewController.view removeFromSuperview];

		[self addChildViewController:self.comparisonViewController];
		_comparisonViewController.view.frame = self.contentsViewFrame;
		[self.view addSubview:_comparisonViewController.view];
	} else {
		[_comparisonViewController removeFromParentViewController];
		[_comparisonViewController.view removeFromSuperview];

		[self addChildViewController:self.quickDialogViewController];
		_quickDialogViewController.view.frame = self.contentsViewFrame;
		[self.view addSubview:_quickDialogViewController.view];
	}
	_topGradientLayer = [self addTopGradientLayerToView:self.view position:1.0];
}

- (A3LoanCalcQuickDialogViewController *)quickDialogViewController {
	if (nil == _quickDialogViewController) {
		if (DEVICE_IPAD) {
			_quickDialogViewController = [[A3LoanCalcQuickDialogViewController_iPad alloc] initWithNibName:nil bundle:nil];
		} else {
			_quickDialogViewController = [[A3LoanCalcQuickDialogViewController_iPhone alloc] initWithNibName:nil bundle:nil];
		}
	}
	return _quickDialogViewController;
}

- (A3LoanCalcComparisonMainViewController *)comparisonViewController {
	if (nil == _comparisonViewController) {
		if (DEVICE_IPAD) {
			_comparisonViewController = [[A3LoanCalcComparisonMainViewController_iPad alloc] initWithNibName:@"A3LoanCalcComparisonMainViewController_iPad" bundle:nil];
		} else {
			_comparisonViewController = [[A3LoanCalcComparisonMainViewController_iPhone alloc] initWithNibName:@"A3LoanCalcComparisonMainViewController_iPhone" bundle:nil];
		}
	}
	return _comparisonViewController;
}


- (void)onActionButton:(UIButton *)button {
	if (DEVICE_IPAD) {
		[self presentEmptyActionMenu];
		[self addActionIcon:@"t_history" title:@"History" selector:@selector(showHistoryAction) atIndex:0];
		[self addActionIcon:@"t_settings" title:@"Settings" selector:@selector(settingsAction) atIndex:1];
		[self addActionIcon:@"t_share" title:@"Share" selector:@selector(shareAction) atIndex:2];
	} else {
		[self presentActionMenuWithDelegate:self];
	}
}

#pragma mark - A3ActionMenuDelegate
- (void)settingsAction {
	A3LoanCalcSettingsViewController *viewController = [[A3LoanCalcSettingsViewController alloc] initWithNibName:nil bundle:nil];

	A3PaperFoldMenuViewController *paperFoldMenuViewController = [[A3AppDelegate instance] paperFoldMenuViewController];
	[paperFoldMenuViewController presentRightWingWithViewController:viewController onClose:^{
		[self.quickDialogViewController reloadContents];
	}];

	[self closeActionMenuViewWithAnimation:NO ];
}

- (void)showHistoryAction {
	[self closeActionMenuViewWithAnimation:YES];

	UIViewController *viewController;
	if (self.segmentedControl.selectedSegmentIndex == 0) {
		A3LoanCalcHistoryViewController *aviewController = [[A3LoanCalcHistoryViewController alloc] initWithNibName:nil bundle:nil];
		aviewController.delegate = self;
		viewController = aviewController;
	} else {
		A3LoanCalcCompareHistoryViewController *aviewController = [[A3LoanCalcCompareHistoryViewController alloc] initWithNibName:nil bundle:nil];
		aviewController.delegate = self;
		viewController = aviewController;
	}

	if (DEVICE_IPAD){
		A3PaperFoldMenuViewController *paperFoldMenuViewController = [[A3AppDelegate instance] paperFoldMenuViewController];
		[paperFoldMenuViewController presentRightWingWithViewController:viewController onClose:nil];
	} else {
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
		[self applySilverNavigationBarStyleToNavigationVC:navController];
		[self presentViewController:navController animated:YES completion:nil];
	}
}

- (void)shareAction {

}

- (void)historySelected:(id)object {

}

@end
