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

	self.view.frame = [A3UIDevice deviceOrientationIsPortrait] ? CGRectMake(0.0, 0.0, APP_VIEW_WIDTH_iPAD, 960.0) : CGRectMake(0.0, 0.0, APP_VIEW_WIDTH_iPAD, 704.0);

	_quickDialogViewController = [[A3SalesCalcQuickDialogViewController alloc] initWithNibName:nil bundle:nil];
	_quickDialogViewController.view.frame = self.view.bounds;
	[self.view addSubview:_quickDialogViewController.view];
	[self addChildViewController:_quickDialogViewController];

	UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"History" style:UIBarButtonItemStyleBordered target:self action:@selector(presentHistoryViewController)];
	self.navigationItem.rightBarButtonItem = barButtonItem;
}

- (void)presentHistoryViewController {
	A3SalesCalcHistoryViewController *historyViewController = [[A3SalesCalcHistoryViewController alloc] init];
	historyViewController.salesCalcQuickDialogViewController = _quickDialogViewController;

	A3PaperFoldMenuViewController *paperFoldMenuViewController = [[A3AppDelegate instance] paperFoldMenuViewController];
	[paperFoldMenuViewController presentRightWingWithViewController:historyViewController onClose:^{
	}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
