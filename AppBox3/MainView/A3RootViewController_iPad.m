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

	A3MainViewController *mainViewController = [[A3MainViewController alloc] initWithNibName:nil bundle:nil];
	_centerNavigationController = [[A3NavigationController alloc] initWithRootViewController:mainViewController];
	[self addChildViewController:_centerNavigationController];
	[self.view addSubview:_centerNavigationController.view];

	_leftNavigationController = [[A3NavigationController alloc] initWithRootViewController:self.mainMenuViewController];
	[self addChildViewController:_leftNavigationController];
	[self.view addSubview:_leftNavigationController.view];

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
	_centerCoverView.frame = _centerNavigationController.view.bounds;

    // KJH
    A3NavigationController *presentedViewController = [_presentViewControllers lastObject];
    if (presentedViewController) {
        if (![_centerCoverView.superview isEqual:presentedViewController.view]) {
            [presentedViewController.view addSubview:_centerCoverView];
        }
        [_centerNavigationController.view bringSubviewToFront:_centerCoverView];
    }
    else {
        if (![_centerCoverView.superview isEqual:_centerNavigationController.view]) {
            [_centerNavigationController.view addSubview:_centerCoverView];
        }
        [_centerNavigationController.view bringSubviewToFront:_centerCoverView];
    }
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

- (void)animateLeftView {
	if (_showLeftView) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO];
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

		[_leftNavigationController setNavigationBarHidden:YES];
		[_leftNavigationController setNavigationBarHidden:NO];
	}

	[UIView animateWithDuration:0.3 animations:^{
		CGRect frame = _leftNavigationController.view.frame;
		if (self.showLeftView) {
			frame.origin.x = 0;
			[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
			[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
		} else {
			if (IS_LANDSCAPE && ![self useFullScreenInLandscapeForCurrentTopViewController]) {
				frame.origin.x = 0;
			} else {
				frame.origin.x = -kSideViewWidth - 1;
			}
		}
		_leftNavigationController.view.frame = frame;

	} completion:^(BOOL finished) {
		[self layoutSubviews];
		if (self.showLeftView) {
			[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationMainMenuDidShow object:_mainMenuViewController];
		} else {
			[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationMainMenuDidHide object:_mainMenuViewController];
		}
	}];
}

- (void)animateHideLeftViewForFullScreenCenterView:(BOOL)fullScreenCenterView {
    if ([self isFullScreenCenterViewAlreadyIfDaysCounter]) {
        return;
    }
    
	[UIView animateWithDuration:0.3 animations:^{
        [_centerCoverView setHidden:YES];
        
		_showLeftView = NO;

        CGRect bounds = [self screenBoundsAdjustedWithOrientation];
        
		CGRect frame = _leftNavigationController.view.frame;
        if (IS_PORTRAIT || (IS_LANDSCAPE && fullScreenCenterView)) {
            frame.origin.x = -kSideViewWidth - 1;
        } else {    
            frame.origin.x = 0;
        }
		_leftNavigationController.view.frame = frame;

        CGFloat centerViewWidth;
        CGFloat centerViewPosition;
        if (IS_LANDSCAPE) {
            centerViewWidth = fullScreenCenterView ? bounds.size.width : 704;
            centerViewPosition = fullScreenCenterView ? 0.0 : kSideViewWidth + 1.0;
        } else {
            centerViewWidth = bounds.size.width;
            centerViewPosition = 0.0;
        }
        
        frame = CGRectMake(centerViewPosition, 0, centerViewWidth, bounds.size.height);
        _centerNavigationController.view.frame = frame;
        frame = CGRectMake(bounds.size.width, 0, kSideViewWidth, bounds.size.height);
        _rightNavigationController.view.frame = frame;

    } completion:^(BOOL finished) {
    }];
}

- (BOOL)isFullScreenCenterViewAlreadyIfDaysCounter {
    CGRect leftFrame = _leftNavigationController.view.frame;
    CGRect centerFrame = _centerNavigationController.view.frame;
    CGRect bounds = [self screenBoundsAdjustedWithOrientation];
    if (IS_IPAD && IS_LANDSCAPE && (leftFrame.origin.x == -kSideViewWidth - 1) && (centerFrame.origin.x == 0) && (centerFrame.size.width == bounds.size.width)) {
        return YES;
    }
    
    return NO;
}

- (void)toggleLeftMenuViewOnOff {
	self.showLeftView = !self.showLeftView;

	[self animateLeftView];
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
    viewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [sourceViewController presentViewController:viewController animated:YES completion:^{
        if (!_presentViewControllers) {
            _presentViewControllers = [NSMutableArray new];
        }
        [_presentViewControllers addObject:viewController];
        
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
        [_presentViewControllers removeLastObject];
    }];

}

- (void)presentRightSideViewController:(UIViewController *)viewController {
	_showRightView = YES;
    _showLeftView = NO;
    
    CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
	_rightNavigationController = [[A3NavigationController alloc] initWithRootViewController:viewController];
	CGRect frame = _centerNavigationController.view.frame;
	frame.origin.x = screenBounds.size.width;
	frame.size.width = kSideViewWidth;
	_rightNavigationController.view.frame = frame;
	[self.view addSubview:_rightNavigationController.view];
	[self addChildViewController:_rightNavigationController];

	[UIView animateWithDuration:0.3 animations:^{
		if (IS_LANDSCAPE) {
			CGRect centerViewFrame = _centerNavigationController.view.frame;
			centerViewFrame.origin.x = 0;
			_centerNavigationController.view.frame = centerViewFrame;
            // KJH
            A3NavigationController *presentedViewController = [_presentViewControllers lastObject];
            if (presentedViewController) {
                presentedViewController.view.frame = centerViewFrame;
            }
		}
		CGRect sideViewFrame = _rightNavigationController.view.frame;
		sideViewFrame.origin.x -= kSideViewWidth;
		_rightNavigationController.view.frame = sideViewFrame;
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
		if (IS_LANDSCAPE) {
			BOOL useFullScreenInLandscape = [self useFullScreenInLandscapeForCurrentTopViewController];
			if (!useFullScreenInLandscape) {
                CGRect frame = _leftNavigationController.view.frame;
                frame.origin.x -= kSideViewWidth;
                _leftNavigationController.view.frame = frame;
            }
			CGRect centerViewFrame = _centerNavigationController.view.frame;
			centerViewFrame.origin.x = 0;
			_centerNavigationController.view.frame = centerViewFrame;
            // KJH
            A3NavigationController *presentedViewController = [_presentViewControllers lastObject];
            if (presentedViewController) {
                presentedViewController.view.frame = centerViewFrame;
            }
		}
		CGRect sideViewFrame = _rightNavigationController.view.frame;
		//sideViewFrame.origin.x -= kSideViewWidth;
        sideViewFrame.origin.y = 0;
		_rightNavigationController.view.frame = sideViewFrame;
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
			_showRightView = NO;

			CGRect bounds = [self screenBoundsAdjustedWithOrientation];

			CGRect frame = _rightNavigationController.view.frame;
			frame.origin.x = bounds.size.width;
			_rightNavigationController.view.frame = frame;

		} completion:^(BOOL finished) {
			[_rightNavigationController.view removeFromSuperview];
			[_rightNavigationController removeFromParentViewController];
			[_rightNavigationController.childViewControllers[0] removeObserver];
			_rightNavigationController = nil;

			[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationRightSideViewDidDismiss object:nil];
		}];
	});
}

#ifdef __IPHONE_8_0
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
	[self willRotateToInterfaceOrientation:orientation duration: 0];
	
	[self layoutSubviews];
}
#endif

@end
