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

@interface A3LoanCalcViewController ()

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

	[self addToolsButtonWithAction:@selector(onActionButton)];

	[self addChildViewController:self.quickDialogViewController];
	_quickDialogViewController.view.frame = self.contentsViewFrame;
	[self.view addSubview:_quickDialogViewController.view];

	_topGradientLayer = [A3UIKit addTopGradientLayerToView:self.view];

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
	_topGradientLayer = [A3UIKit addTopGradientLayerToView:self.view];
}

- (A3LoanCalcQuickDialogViewController *)quickDialogViewController {
	if (nil == _quickDialogViewController) {
		_quickDialogViewController = [[A3LoanCalcQuickDialogViewController alloc] initWithNibName:nil bundle:nil];
	}
	return _quickDialogViewController;
}

- (A3LoanCalcComparisonMainViewController *)comparisonViewController {
	if (nil == _comparisonViewController) {
		_comparisonViewController = [[A3LoanCalcComparisonMainViewController alloc] initWithNibName:@"A3LoanCalcComparisonMainViewController" bundle:nil];
	}
	return _comparisonViewController;
}


- (void)onActionButton {
	[self presentActionMenuWithDelegate:self];
}

#pragma mark - A3ActionMenuDelegate
- (void)settingsAction {
	A3LoanCalcSettingsViewController *viewController = [[A3LoanCalcSettingsViewController alloc] initWithNibName:nil bundle:nil];

	A3PaperFoldMenuViewController *paperFoldMenuViewController = [[A3AppDelegate instance] paperFoldMenuViewController];
	[paperFoldMenuViewController presentRightWingWithViewController:viewController onClose:^{
		[self.quickDialogViewController reloadContents];
	}];

	[self closeActionMenuView];
}

- (void)emailAction {

}

- (void)messageAction {

}

- (void)twitterAction {

}

- (void)facebookAction {

}


@end
