//
//  A3RootViewController_iPad.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/9/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3RootViewController_iPad.h"
#import "A3MainMenuTableViewController.h"
#import "A3UIDevice.h"
#import "A3CenterViewDelegate.h"
#import "common.h"
#import "UIViewController+A3Addition.h"
#import "A3MainViewController.h"
#import "UIViewController+iPad_rightSideView.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3HexagonMenuViewController.h"
#import "A3GridMenuViewController.h"
#import "A3NavigationController.h"
#import "A3AppDelegate.h"
#import "A3UIDevice.h"

@interface A3RootViewController_iPad ()

@property (nonatomic, strong)	UIView *centerCoverView;

@end

@implementation A3RootViewController_iPad

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

	self.view.backgroundColor = [UIColor whiteColor];

	NSArray *menuTypes = [[A3AppDelegate instance] availableMenuTypes];
	NSString *mainMenuStyle = [[NSUserDefaults standardUserDefaults] objectForKey:kA3SettingsMainMenuStyle];
	NSInteger idx = [menuTypes indexOfObject:mainMenuStyle];
	switch (idx) {
		case 0:	{
			A3MainViewController *mainViewController = [[A3MainViewController alloc] initWithNibName:nil bundle:nil];
			_centerNavigationController = [[A3NavigationController alloc] initWithRootViewController:mainViewController];
			[self addChildViewController:_centerNavigationController];
			[self.view addSubview:_centerNavigationController.view];

			_leftNavigationController = [[UINavigationController alloc] initWithRootViewController:self.mainMenuViewController];
			[self addChildViewController:_leftNavigationController];
			[self.view addSubview:_leftNavigationController.view];
			break;
		}
		case 1: {
			A3HexagonMenuViewController *menuViewController = [A3HexagonMenuViewController new];
			_centerNavigationController = [[UINavigationController alloc] initWithRootViewController:menuViewController];
			[self addChildViewController:_centerNavigationController];
			[self.view addSubview:_centerNavigationController.view];
			break;
		}
		case 2:{
			A3GridMenuViewController *menuViewController = [A3GridMenuViewController new];
			_centerNavigationController = [[UINavigationController alloc] initWithRootViewController:menuViewController];
			[self addChildViewController:_centerNavigationController];
			[self.view addSubview:_centerNavigationController.view];
			break;
		}
		default:
			break;
	}

	[self centerCoverView];

	[self layoutSubviews];
}

- (A3MainMenuTableViewController *)mainMenuViewController {
	if (!_mainMenuViewController) {
		_mainMenuViewController = [[A3MainMenuTableViewController alloc] init];
	}
	return _mainMenuViewController;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

static const CGFloat kSideViewWidth = 320.0;

- (void)layoutSubviews {
	CGRect bounds = [self screenBoundsAdjustedWithOrientation];

	self.centerNavigationController.view.frame = bounds;
	// KJH
	A3NavigationController *presentedViewController = [_presentViewControllers lastObject];
	if (presentedViewController) {
		presentedViewController.view.frame = bounds;
	}

	if (self.showLeftView) {
		_leftNavigationController.view.frame = CGRectMake(0,0,kSideViewWidth, bounds.size.height);
		_rightNavigationController.view.frame = CGRectMake(bounds.size.width, 0, kSideViewWidth, bounds.size.height);
		[self bringUpCenterCoverView];
	} else if (self.showRightView) {
		_leftNavigationController.view.frame = CGRectMake(-kSideViewWidth - 1,0,kSideViewWidth, bounds.size.height);
		_rightNavigationController.view.frame = CGRectMake(bounds.size.width - kSideViewWidth, 0, kSideViewWidth, bounds.size.height);
		[self bringUpCenterCoverView];

		_modalPresentedInRightNavigationViewController.view.frame = _rightNavigationController.view.frame;
	} else {
		_leftNavigationController.view.frame = CGRectMake(-kSideViewWidth - 1,0,kSideViewWidth, bounds.size.height);
		_rightNavigationController.view.frame = CGRectMake(bounds.size.width, 0, kSideViewWidth, bounds.size.height);
		[_centerCoverView setHidden:YES];
	}
}

- (void)bringUpCenterCoverView {
	[self.centerCoverView setHidden:NO];
	UINavigationController *navigationController = _centerNavigationController;
	while ([navigationController.presentedViewController isKindOfClass:[UINavigationController class]]) {
		navigationController = (id)navigationController.presentedViewController;
	}
	_centerCoverView.frame = navigationController.view.bounds;
	[navigationController.view addSubview:self.centerCoverView];
	[navigationController.view bringSubviewToFront:_centerCoverView];
}

- (void)viewWillLayoutSubviews {
    [self layoutSubviews];
}

- (BOOL)useFullScreenInLandscapeForCurrentTopViewController {
	BOOL useFullScreenInLandscape = NO;
	id<A3CenterViewDelegate> centerViewController = (id <A3CenterViewDelegate>) [_centerNavigationController topViewController];
	if ([centerViewController respondsToSelector:@selector(usesFullScreenInLandscape)]) {
		useFullScreenInLandscape = [centerViewController usesFullScreenInLandscape];
	}
	return useFullScreenInLandscape;
}

- (void)setShowLeftView:(BOOL)showLeftView {
	_showLeftView = showLeftView;

	[self animateLeftView];
}

- (BOOL)prefersStatusBarHidden {
    return !_showLeftView;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)animateLeftView {
	if (_showLeftView) {
        [self setNeedsStatusBarAppearanceUpdate];

		[_leftNavigationController setNavigationBarHidden:YES];
		[_leftNavigationController setNavigationBarHidden:NO];
	}

	[UIView animateWithDuration:0.3 animations:^{
		CGRect frame = self.leftNavigationController.view.frame;
		if (self.showLeftView) {
			frame.origin.x = 0;
            [self setNeedsStatusBarAppearanceUpdate];
		} else {
			if ([UIWindow interfaceOrientationIsLandscape] && ![self useFullScreenInLandscapeForCurrentTopViewController]) {
				frame.origin.x = 0;
			} else {
				frame.origin.x = -kSideViewWidth - 1;
			}
		}
        self.leftNavigationController.view.frame = frame;

	} completion:^(BOOL finished) {
		[self layoutSubviews];
		if (self.showLeftView) {
			[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationMainMenuDidShow object:self.mainMenuViewController];
		} else {
			[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationMainMenuDidHide object:self.mainMenuViewController];
		}
	}];
}

- (void)animateHideLeftViewForFullScreenCenterView:(BOOL)fullScreenCenterView {
    if ([self isFullScreenCenterViewAlreadyIfDaysCounter]) {
        return;
    }
    
	[UIView animateWithDuration:0.3 animations:^{
        [self.centerCoverView setHidden:YES];
        
        self.showLeftView = NO;

        CGRect bounds = [self screenBoundsAdjustedWithOrientation];
        
		CGRect frame = self.leftNavigationController.view.frame;
        if ([UIWindow interfaceOrientationIsPortrait] || ([UIWindow interfaceOrientationIsLandscape] && fullScreenCenterView)) {
            frame.origin.x = -kSideViewWidth - 1;
        } else {    
            frame.origin.x = 0;
        }
        self.leftNavigationController.view.frame = frame;

        CGFloat centerViewWidth;
        CGFloat centerViewPosition;
        if ([UIWindow interfaceOrientationIsLandscape]) {
            centerViewWidth = fullScreenCenterView ? bounds.size.width : 704;
            centerViewPosition = fullScreenCenterView ? 0.0 : kSideViewWidth + 1.0;
        } else {
            centerViewWidth = bounds.size.width;
            centerViewPosition = 0.0;
        }
        
        frame = CGRectMake(centerViewPosition, 0, centerViewWidth, bounds.size.height);
        self.centerNavigationController.view.frame = frame;
        frame = CGRectMake(bounds.size.width, 0, kSideViewWidth, bounds.size.height);
        self.rightNavigationController.view.frame = frame;

    } completion:^(BOOL finished) {
    }];
}

- (BOOL)isFullScreenCenterViewAlreadyIfDaysCounter {
    CGRect leftFrame = _leftNavigationController.view.frame;
    CGRect centerFrame = _centerNavigationController.view.frame;
    CGRect bounds = [self screenBoundsAdjustedWithOrientation];
    if (IS_IPAD && [UIWindow interfaceOrientationIsLandscape] && (leftFrame.origin.x == -kSideViewWidth - 1) && (centerFrame.origin.x == 0) && (centerFrame.size.width == bounds.size.width)) {
        return YES;
    }
    
    return NO;
}

- (void)toggleLeftMenuViewOnOff {
	if (_leftNavigationController) {
		self.showLeftView = !self.showLeftView;
		
		[self animateLeftView];
	} else {
		id<A3ViewControllerProtocol> viewController = (id)[_centerNavigationController topViewController];
		if ([viewController respondsToSelector:@selector(prepareClose)]) {
			[viewController prepareClose];
		}
		[_centerNavigationController popViewControllerAnimated:YES];
		[_centerNavigationController setNavigationBarHidden:YES];
		[_centerNavigationController setToolbarHidden:YES];
		[A3AppDelegate instance].homeStyleMainMenuViewController.activeAppName = nil;
	}
}

- (UIView *)centerCoverView {
	if (!_centerCoverView) {
		_centerCoverView = [UIView new];
		_centerCoverView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_centerCoverView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.15];
		UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCoverViewHandler:)];
		[_centerCoverView addGestureRecognizer:gestureRecognizer];
		[self.centerNavigationController.view addSubview:_centerCoverView];
	}
	return _centerCoverView;
}

// KJH
- (void)presentCenterViewController:(UIViewController *)viewController fromViewController:(UIViewController *)sourceViewController {
    [self presentCenterViewController:viewController fromViewController:sourceViewController withCompletion:nil];
}

- (void)presentCenterViewController:(UIViewController *)viewController fromViewController:(UIViewController *)sourceViewController withCompletion:(void (^)(void))completion {
    viewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [sourceViewController presentViewController:viewController animated:YES completion:^{
        if (!self.presentViewControllers) {
            self.presentViewControllers = [NSMutableArray new];
        }
        [self.presentViewControllers addObject:viewController];
        
        if (completion) {
            completion();
        }
    }];
}

// KJH
- (void)dismissCenterViewController {
    if (!_presentViewControllers || [_presentViewControllers count] == 0) {
        return;
    }
    
    [[[[_presentViewControllers lastObject] childViewControllers] lastObject] dismissViewControllerAnimated:YES completion:^{
        [self.presentViewControllers removeLastObject];
    }];

}

- (void)presentRightSideViewController:(UIViewController *)viewController toViewController:(UIViewController *)targetVC {
	_showRightView = YES;
    _showLeftView = NO;
    
    UIViewController *presentingVC = targetVC != nil ? targetVC : self;
    
    CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
	_rightNavigationController = [[A3NavigationController alloc] initWithRootViewController:viewController];
	CGRect frame = _centerNavigationController.view.frame;
	frame.origin.x = screenBounds.size.width;
	frame.size.width = kSideViewWidth;
	_rightNavigationController.view.frame = frame;
    _rightNavigationController.view.tag = RIGHT_SIDE_VIEW_TAG;
    
    [presentingVC.view addSubview:_rightNavigationController.view];
    [presentingVC addChildViewController:_rightNavigationController];
    
	[UIView animateWithDuration:0.3 animations:^{
		if ([UIWindow interfaceOrientationIsLandscape]) {
			CGRect centerViewFrame = self.centerNavigationController.view.frame;
			centerViewFrame.origin.x = 0;
			self.centerNavigationController.view.frame = centerViewFrame;
            // KJH
            A3NavigationController *presentedViewController = [self.presentViewControllers lastObject];
            if (presentedViewController) {
                presentedViewController.view.frame = centerViewFrame;
            }
		}
		CGRect sideViewFrame = self.rightNavigationController.view.frame;
		sideViewFrame.origin.x -= kSideViewWidth;
		self.rightNavigationController.view.frame = sideViewFrame;
	} completion:^(BOOL finished) {
		[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationRightSideViewDidAppear object:nil];
	}];
}

- (void)presentDownSideViewController:(UIViewController *)viewController {
	_showRightView = YES;
    _showLeftView = NO;
    
    CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
	_rightNavigationController = [[A3NavigationController alloc] initWithRootViewController:viewController];
	CGRect frame = _centerNavigationController.view.frame;
	//frame.origin.x = screenBounds.size.width;
    //frame.origin.x = screenBounds.size.width;
    frame.origin.y = screenBounds.size.height;
	frame.size.width = kSideViewWidth;
	_rightNavigationController.view.frame = frame;
	[self addChildViewController:_rightNavigationController];
	[self.view addSubview:_rightNavigationController.view];
    
	[UIView animateWithDuration:0.3 animations:^{
		if ([UIWindow interfaceOrientationIsLandscape]) {
			BOOL useFullScreenInLandscape = [self useFullScreenInLandscapeForCurrentTopViewController];
			if (!useFullScreenInLandscape) {
                CGRect frame = self.leftNavigationController.view.frame;
                frame.origin.x -= kSideViewWidth;
                self.leftNavigationController.view.frame = frame;
            }
			CGRect centerViewFrame = self.centerNavigationController.view.frame;
			centerViewFrame.origin.x = 0;
            self.centerNavigationController.view.frame = centerViewFrame;
            // KJH
            A3NavigationController *presentedViewController = [self.presentViewControllers lastObject];
            if (presentedViewController) {
                presentedViewController.view.frame = centerViewFrame;
            }
		}
		CGRect sideViewFrame = self.rightNavigationController.view.frame;
		//sideViewFrame.origin.x -= kSideViewWidth;
        sideViewFrame.origin.y = 0;
        self.rightNavigationController.view.frame = sideViewFrame;
	} completion:^(BOOL finished) {
	}];
}

- (void)tapCoverViewHandler:(UITapGestureRecognizer *)gestureRecognizer {
	if (_showLeftView) {
		[self setShowLeftView:NO];
	} else {
        [self dismissRightSideViewController];
	}
}

- (void)dismissRightSideViewController {
	if (!_showRightView) return;

	self.modalPresentedInRightNavigationViewController = nil;

    id topViewController = [_rightNavigationController topViewController];
    if ( [topViewController respondsToSelector:@selector(willDismissFromRightSide)] ) {
        [topViewController performSelector:@selector(willDismissFromRightSide) withObject:nil];
    }
	[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationRightSideViewWillDismiss object:nil];

	double delayInSeconds = 0.01;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[UIView animateWithDuration:0.3 animations:^{
            self.showRightView = NO;

			CGRect bounds = [self screenBoundsAdjustedWithOrientation];

			CGRect frame = self.rightNavigationController.view.frame;
			frame.origin.x = bounds.size.width;
            self.rightNavigationController.view.frame = frame;

		} completion:^(BOOL finished) {
			[self.rightNavigationController.view removeFromSuperview];
			[self.rightNavigationController removeFromParentViewController];
			[self.rightNavigationController.childViewControllers[0] removeObserver];
            self.rightNavigationController = nil;

			[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationRightSideViewDidDismiss object:nil];
		}];
	});
}

/*! If you override this method in your custom view controllers, always call super at some point in
 *  your implementation so that UIKit can forward the size change message appropriately.
 *  View controllers forward the size change message to their views and child view controllers.
 *  Presentation controllers forward the size change to their presented view controller.
 * \param
 * \returns
 */
- (void)viewWillTransitionToSize:(CGSize)size	withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)transitionCoordinator {
	[super viewWillTransitionToSize:size withTransitionCoordinator:transitionCoordinator];
	UIInterfaceOrientation orientation;
	orientation = size.width < size.height ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeLeft;
	
	[self layoutSubviews];
}

@end
