//
//  A3LoanCalcViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/8/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcViewController.h"
#import "A3ActionMenuViewController.h"
#import "UIView+Screenshot.h"
#import "A3UIKit.h"
#import "A3LoanCalcQuickDialogViewController.h"
#import "A3LoanCalcSettingsViewController.h"
#import "A3AppDelegate.h"
#import "A3LoanCalcComparisonMainViewController.h"

@interface A3LoanCalcViewController ()

@property (nonatomic, strong) A3ActionMenuViewController *actionMenuViewController;
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

	NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"tools" ofType:@"png"];
	UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
	UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(onActionButton)];

	self.navigationItem.rightBarButtonItem = barButtonItem;

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
	_actionMenuViewController = [[A3ActionMenuViewController alloc] initWithNibName:@"A3ActionMenuViewController" bundle:nil];
	_actionMenuViewController.view.frame = CGRectMake(0.0, 34.0, 714.0, 60.0);
	_actionMenuViewController.delegate = self;
	[self.navigationController.view insertSubview:[_actionMenuViewController view] belowSubview:self.view];

	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapCoverView)];
	UIImage *image = [self.view screenshotWithOptimization:NO];
	UIImageView *coverView = [[UIImageView alloc] initWithImage:image];
	coverView.frame = CGRectOffset(self.view.bounds, 0.0, 44.0);
	coverView.userInteractionEnabled = YES;
	coverView.backgroundColor = [UIColor clearColor];
	[coverView addGestureRecognizer:tapGestureRecognizer];
	[self.navigationController.view addSubview:coverView];

	[UIView animateWithDuration:0.3 animations:^{
		coverView.frame = CGRectOffset(coverView.frame, 0.0, 50.0);
	}];
}

- (void)onTapCoverView {
	UIView *coverView = [[self.navigationController.view subviews] lastObject];
	[UIView animateWithDuration:0.3 animations:^{
		coverView.frame = CGRectOffset(coverView.frame, 0.0, -50.0);
	} completion:^(BOOL finished){
		[coverView removeFromSuperview];
		[[[self.navigationController.view subviews] lastObject] removeFromSuperview];	// remove menu view
	}];
}

#pragma mark - A3ActionMenuDelegate
- (void)settingsAction {
	A3LoanCalcSettingsViewController *viewController = [[A3LoanCalcSettingsViewController alloc] initWithNibName:nil bundle:nil];

	A3PaperFoldMenuViewController *paperFoldMenuViewController = [[A3AppDelegate instance] paperFoldMenuViewController];
	[paperFoldMenuViewController presentRightWingWithViewController:viewController onClose:^{
		[self.quickDialogViewController reloadContents];
	}];

	[self onTapCoverView];
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
