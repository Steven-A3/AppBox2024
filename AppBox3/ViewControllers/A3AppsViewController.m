//
//  A3AppsViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/13/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3AppsViewController.h"
#import "A3UIDevice.h"
#import "A3ActionMenuViewController_iPad.h"
#import "A3ActionMenuViewController_iPhone.h"
#import "UIView+Screenshot.h"

@interface A3AppsViewController ()

@property (nonatomic, strong) UIViewController *actionMenuViewController;

@end

@implementation A3AppsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define A3_ACTION_MENU_COVER_VIEW_TAG		79325

- (UIViewController *)actionMenuViewController {
	if (nil != _actionMenuViewController) return _actionMenuViewController;

	if (DEVICE_IPAD) {
		A3ActionMenuViewController_iPad *viewController = [[A3ActionMenuViewController_iPad alloc] initWithNibName:@"A3ActionMenuViewController_iPad" bundle:nil];
		_actionMenuViewController = viewController;
	} else {
		A3ActionMenuViewController_iPhone *viewController = [[A3ActionMenuViewController_iPhone alloc] initWithNibName:@"A3ActionMenuViewController_iPhone" bundle:nil];
		_actionMenuViewController = viewController;
	}
	return _actionMenuViewController;
}

- (void)presentActionMenuWithDelegate:(id<A3ActionMenuViewControllerDelegate>) delegate {
	CGRect frame = self.actionMenuViewController.view.frame;
	frame.origin.y = 34.0;
	_actionMenuViewController.view.frame = frame;

	if (DEVICE_IPAD) {
		((A3ActionMenuViewController_iPad *)_actionMenuViewController).delegate = delegate;
	} else {
		((A3ActionMenuViewController_iPhone *)_actionMenuViewController).delegate = delegate;
	}
	[self.navigationController.view insertSubview:[_actionMenuViewController view] belowSubview:self.view];

	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeActionMenuView)];
	UIImage *image = [self.view screenshotWithOptimization:NO];
	UIImageView *coverView = [[UIImageView alloc] initWithImage:image];
	coverView.tag = A3_ACTION_MENU_COVER_VIEW_TAG;
	coverView.frame = CGRectOffset(self.view.bounds, 0.0, 44.0);
	coverView.userInteractionEnabled = YES;
	coverView.backgroundColor = [UIColor clearColor];
	[coverView addGestureRecognizer:tapGestureRecognizer];
	[self.navigationController.view addSubview:coverView];

	[UIView animateWithDuration:0.3 animations:^{
		coverView.frame = CGRectOffset(coverView.frame, 0.0, 50.0);
	}];
}

- (void)closeActionMenuView {
	UIView *coverView = [self.navigationController.view viewWithTag:A3_ACTION_MENU_COVER_VIEW_TAG];
			[UIView animateWithDuration:0.3 animations:^{
		coverView.frame = CGRectOffset(coverView.frame, 0.0, -50.0);
	} completion:^(BOOL finished){
		[coverView removeFromSuperview];
		[[[self.navigationController.view subviews] lastObject] removeFromSuperview];	// remove menu view
	}];
}

- (void)addToolsButtonWithAction:(SEL)action {
	NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"tools" ofType:@"png"];
	UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setImage:image forState:UIControlStateNormal];
	[button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
	button.bounds = CGRectMake(0.0, 0.0, 42.0, 32.0);
	UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];

	self.navigationItem.rightBarButtonItem = barButtonItem;
}

@end
