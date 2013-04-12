//
//  A3SalesCalcMainViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 1/31/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3SalesCalcMainViewController.h"
#import "A3UIDevice.h"
#import "CommonUIDefinitions.h"
#import "A3SalesCalcQuickDialogViewController.h"
#import "A3SalesCalcHistoryViewController.h"
#import "A3PaperFoldMenuViewController.h"
#import "A3AppDelegate.h"
#import "A3CurrencySelectViewController.h"
#import "A3UIKit.h"
#import "A3SalesCalcQuickDialogViewController_iPad.h"
#import "A3SalesCalcQuickDialogViewController_iPhone.h"
#import "common.h"

@interface A3SalesCalcMainViewController ()

@property (nonatomic, strong) A3SalesCalcQuickDialogViewController *quickDialogViewController;

@end

@implementation A3SalesCalcMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.title = @"Sales Calc";
		self.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
		[A3UIKit addTopGradientLayerToView:self.view];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	[self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
	self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];

	self.view.frame = [A3UIDevice appFrame];
	FNLOG(@"%f, %f", self.view.bounds.size.width, self.view.bounds.size.height);

	if (DEVICE_IPAD) {
		_quickDialogViewController = [[A3SalesCalcQuickDialogViewController_iPad alloc] initWithNibName:nil bundle:nil];
	} else {
		_quickDialogViewController = [[A3SalesCalcQuickDialogViewController_iPhone alloc] initWithNibName:nil bundle:nil];
	}
	_quickDialogViewController.view.frame = self.view.bounds;
	[self.view addSubview:_quickDialogViewController.view];
	[self addChildViewController:_quickDialogViewController];

	UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"History" style:UIBarButtonItemStyleBordered target:self action:@selector(presentHistoryViewController)];
	self.navigationItem.rightBarButtonItem = barButtonItem;
}

- (void)presentHistoryViewController {
	A3SalesCalcHistoryViewController *historyViewController = [[A3SalesCalcHistoryViewController alloc] init];
	historyViewController.salesCalcQuickDialogViewController = _quickDialogViewController;

	if (DEVICE_IPAD) {
		A3PaperFoldMenuViewController *paperFoldMenuViewController = [[A3AppDelegate instance] paperFoldMenuViewController];
		[paperFoldMenuViewController presentRightWingWithViewController:historyViewController onClose:^{
		}];
	} else {
		[self.navigationController pushViewController:historyViewController animated:YES];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
