//
//  A3RootViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/9/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3RootViewController.h"
#import "MMDrawerController.h"
#import "A3MainMenuTableViewController.h"
#import "A3UIDevice.h"
#import "A3HomeViewController_iPad.h"
#import "A3HomeViewController_iPhone.h"
#import "A3MMDrawerController.h"
#import "UIViewController+A3AppCategory.h"

@interface A3RootViewController ()

@property (nonatomic, strong)	A3MainMenuTableViewController *leftMenuViewController;
@property (nonatomic, strong)	UINavigationController *rightSideNavigationController;
@property (nonatomic, strong)	UIView *drawerCoverView;
@property (nonatomic, strong)	CALayer *navigationBorderLayer;

@end

@implementation A3RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	_leftMenuViewController = [[A3MainMenuTableViewController alloc] initWithStyle:UITableViewStylePlain];

	UIViewController *rootViewController;
	if (IS_IPAD) {
		A3HomeViewController_iPad *viewController = [[A3HomeViewController_iPad alloc] initWithNibName:@"HomeView_iPad" bundle:nil];
		rootViewController = viewController;
	} else {
		A3HomeViewController_iPhone *viewController = [[A3HomeViewController_iPhone alloc] initWithNibName:@"HomeView_iPhone" bundle:nil];
		rootViewController = viewController;
	}

	_navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
	[self setupNavigationBorderLayer];

	_drawerController = [[A3MMDrawerController alloc]
			initWithCenterViewController:_navigationController leftDrawerViewController:_leftMenuViewController];
	[_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeBezelPanningCenterView];
	[_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
	[_drawerController setDrawerVisualStateBlock:[self slideAndScaleVisualStateBlock]];
	[_drawerController setCenterHiddenInteractionMode:MMDrawerOpenCenterInteractionModeFull];
	[_drawerController setShowsShadow:NO];

	[_drawerController setMaximumLeftDrawerWidth:320.0];

    _drawerController.view.frame = self.view.bounds;
	[self addChildViewController:_drawerController];
	[self.view addSubview:[_drawerController view] ];

}

- (CALayer *)navigationBorderLayer {
	if (!_navigationBorderLayer) {
		_navigationBorderLayer = [CALayer layer];
		[_navigationController.view.layer addSublayer:_navigationBorderLayer];
		_navigationBorderLayer.borderWidth = IS_RETINA ? 0.5 : 1.0;
		_navigationBorderLayer.borderColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0].CGColor;
	}
	return _navigationBorderLayer;
}


- (void)setupNavigationBorderLayer {
	self.navigationBorderLayer.frame = CGRectInset(_navigationController.view.bounds, -1.0, -1.0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MMDrawerControllerDrawerVisualStateBlock)slideAndScaleVisualStateBlock{
	MMDrawerControllerDrawerVisualStateBlock visualStateBlock =
			^(MMDrawerController * drawerController, MMDrawerSide drawerSide, CGFloat percentVisible){
				CGFloat minScale = .95;
				CGFloat scale = minScale + (percentVisible*(1.0-minScale));
				CATransform3D scaleTransform =  CATransform3DMakeScale(scale, scale, scale);

				CGFloat maxDistance = 10;
				CGFloat distance = maxDistance * percentVisible;
				CATransform3D translateTransform;
				UIViewController * sideDrawerViewController;
				if(drawerSide == MMDrawerSideLeft) {
					sideDrawerViewController = drawerController.leftDrawerViewController;
					translateTransform = CATransform3DMakeTranslation((maxDistance-distance), 0.0, 0.0);
				}
				else if(drawerSide == MMDrawerSideRight){
					sideDrawerViewController = drawerController.rightDrawerViewController;
					translateTransform = CATransform3DMakeTranslation(-(maxDistance-distance), 0.0, 0.0);
				}

				[sideDrawerViewController.view.layer setTransform:CATransform3DConcat(scaleTransform, translateTransform)];
				[sideDrawerViewController.view setAlpha:percentVisible];
			};
	return visualStateBlock;
}

- (void)viewWillLayoutSubviews {
	if (IS_IPHONE) {
		return;
	}

	if ( IS_LANDSCAPE )  {
        [_drawerController openDrawerSide:MMDrawerSideLeft animated:NO completion:nil];
        [_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
	} else {
        [_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
        [_drawerController closeDrawerAnimated:NO completion:nil];
	}

	CGRect frame = self.navigationController.view.frame;
	frame.size.width = IS_LANDSCAPE ? 704.0 : 768.0;
	self.navigationController.view.frame = frame;
	[self setupNavigationBorderLayer];
}

static const CGFloat kSideViewWidth = 320.0;
static const CGFloat kLandscapeHeight_iPad = 768.0;
static const CGFloat kPortraitHeight_iPad = 1024.0;
static const CGFloat kLandscapeWidth_iPad = 1024.0;
static const CGFloat kPortraitWidth_iPad = 768.0;

- (void)presentRightSideViewController:(UIViewController *)viewController {
	_rightSideNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	CGRect frame = IS_LANDSCAPE ? CGRectMake(kLandscapeWidth_iPad, 0.0, kSideViewWidth, kLandscapeHeight_iPad) :
			CGRectMake(kPortraitWidth_iPad, 0.0, kSideViewWidth, kPortraitHeight_iPad);
	_rightSideNavigationController.view.frame = frame;
	[self.view insertSubview:_rightSideNavigationController.view belowSubview:_drawerController.view];

	// Cover drawer View
	CGRect coverFrame = _drawerController.view.bounds;
	coverFrame = CGRectInset(coverFrame, 0.0, -1.0);
	_drawerCoverView = [[UIView alloc] initWithFrame:coverFrame];
	_drawerCoverView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];
	_drawerCoverView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[_drawerController.view addSubview:_drawerCoverView];

	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCoverViewHandler:)];
	[_drawerCoverView addGestureRecognizer:tapGestureRecognizer];

	[UIView animateWithDuration:0.3 animations:^{
		CGRect drawerFrame = _drawerController.view.frame;
		drawerFrame.origin.x -= kSideViewWidth;
		_drawerController.view.frame = drawerFrame;

		CGRect sideViewFrame = _rightSideNavigationController.view.frame;
		sideViewFrame.origin.x -= kSideViewWidth;
		_rightSideNavigationController.view.frame = sideViewFrame;
	} completion:^(BOOL finished) {
		UIView *view = _rightSideNavigationController.view;
		view.translatesAutoresizingMaskIntoConstraints = NO;

		[self.view addConstraint:[NSLayoutConstraint constraintWithItem:view
															  attribute:NSLayoutAttributeWidth
															  relatedBy:NSLayoutRelationEqual
																 toItem:nil
															  attribute:NSLayoutAttributeNotAnAttribute
															 multiplier:0.0
															   constant:kSideViewWidth]];
		[self.view addConstraint:[NSLayoutConstraint constraintWithItem:view
															  attribute:NSLayoutAttributeTop
															  relatedBy:NSLayoutRelationEqual
																 toItem:self.view
															  attribute:NSLayoutAttributeTop
															 multiplier:1.0
															   constant:0.0]];
		[self.view addConstraint:[NSLayoutConstraint constraintWithItem:view
															  attribute:NSLayoutAttributeRight
															  relatedBy:NSLayoutRelationEqual
																 toItem:self.view
															  attribute:NSLayoutAttributeRight
															 multiplier:1.0
															   constant:0.0]];
		[self.view addConstraint:[NSLayoutConstraint constraintWithItem:view
															  attribute:NSLayoutAttributeBottom
															  relatedBy:NSLayoutRelationEqual
																 toItem:self.view
															  attribute:NSLayoutAttributeBottom
															 multiplier:1.0
															   constant:0.0]];
	}];
}

- (void)tapCoverViewHandler:(UITapGestureRecognizer *)gestureRecognizer {
	UIViewController *controller = _rightSideNavigationController.viewControllers[0];
	if ([controller respondsToSelector:@selector(doneButtonAction:)]) {
		[controller doneButtonAction:nil];
	} else {
		[self dismissRightSideViewController];
	}
}

- (void)dismissRightSideViewController {
	[UIView animateWithDuration:0.3 animations:^{
		CGRect drawerFrame = _drawerController.view.frame;
		drawerFrame.origin.x += kSideViewWidth;
		_drawerController.view.frame = drawerFrame;
	} completion:^(BOOL finished) {
		[_drawerCoverView removeFromSuperview];
		_drawerCoverView = nil;
        [_rightSideNavigationController.view removeFromSuperview];

//		_rightSideNavigationController = nil;
	}];
}

@end
