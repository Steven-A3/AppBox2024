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

@interface A3LoanCalcViewController ()

@property (nonatomic, strong) A3ActionMenuViewController *actionMenuViewController;
@property (nonatomic, strong) A3LoanCalcQuickDialogViewController *quickDialogViewController;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(onActionButton)];
	self.navigationItem.rightBarButtonItem = buttonItem;

	[self addChildViewController:self.quickDialogViewController];
	[self.view addSubview:self.quickDialogViewController.view];
	CGRect frame = self.view.bounds;
	frame.size.height -= 44.0;
	[_quickDialogViewController.view setFrame:frame];

	[A3UIKit addTopGradientLayerToView:self.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (A3LoanCalcQuickDialogViewController *)quickDialogViewController {
	if (nil == _quickDialogViewController) {
		_quickDialogViewController = [[A3LoanCalcQuickDialogViewController alloc] initWithNibName:nil bundle:nil];
	}
	return _quickDialogViewController;
}

- (void)onActionButton {
	_actionMenuViewController = [[A3ActionMenuViewController alloc] initWithNibName:@"A3ActionMenuViewController" bundle:nil];
	_actionMenuViewController.view.frame = CGRectMake(0.0, 34.0, 714.0, 60.0);
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

@end
