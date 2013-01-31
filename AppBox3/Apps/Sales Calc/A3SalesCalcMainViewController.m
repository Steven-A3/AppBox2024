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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	[self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
	self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];

	self.view.frame = [A3UIDevice deviceOrientationIsPortrait] ? CGRectMake(0.0, 0.0, APP_VIEW_WIDTH, 960.0) : CGRectMake(0.0, 0.0, APP_VIEW_WIDTH, 704.0);

	_quickDialogViewController = [[A3SalesCalcQuickDialogViewController alloc] initWithNibName:nil bundle:nil];
	_quickDialogViewController.view.frame = self.view.bounds;
	[self.view addSubview:_quickDialogViewController.view];
	[self addChildViewController:_quickDialogViewController];

	UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:_quickDialogViewController action:@selector(onOrganize)];
	self.navigationItem.rightBarButtonItem = rightButtonItem;

	NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"PageCurl" ofType:@"png"];
	UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
	UIImageView *curlView = [[UIImageView alloc] initWithImage:image];
	curlView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
	curlView.userInteractionEnabled = YES;
	CGSize size = CGSizeMake(image.size.width / 2.0, image.size.height / 2.0);
	curlView.frame = CGRectMake(CGRectGetMaxX(self.view.bounds) - size.width + 1.0, CGRectGetMaxY(self.view.bounds) - size.height, size.width, size.height);
	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onHistory)];
	[curlView addGestureRecognizer:gestureRecognizer];
	[self.view addSubview:curlView];
}

- (void)onHistory {
	A3SalesCalcHistoryViewController *historyViewController = [[A3SalesCalcHistoryViewController alloc] init];
	UINavigationController *historyNavigationController = [[UINavigationController alloc] initWithRootViewController:historyViewController];
	CGRect frame = [A3UIDevice deviceOrientationIsPortrait] ? CGRectMake(768.0, 0.0, 320.0, 1004.0) : CGRectMake(1024.0, 0.0, 320.0, 748.0);
	[historyNavigationController.view setFrame:frame];
	historyNavigationController.view.layer.borderWidth = 1.0;
	historyNavigationController.view.layer.borderColor = [UIColor lightGrayColor].CGColor;

	A3PaperFoldMenuViewController *paperFoldMenuViewController = [[A3AppDelegate instance] paperFoldMenuViewController];
	[paperFoldMenuViewController presentRightWingWithViewController:historyNavigationController];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
