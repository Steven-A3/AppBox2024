//
//  A3PaperFoldMenuViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 11/9/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3PaperFoldMenuViewController.h"
#import "A3iPhoneMenuTableViewController.h"
#import "A3HomeViewController_iPhone.h"
#import "CommonUIDefinitions.h"
#import "A3HotMenuViewController.h"
#import "A3HomeViewController_iPad.h"
#import "A3UIDevice.h"
#import "common.h"
#import "A3NotificationTableViewController.h"
#import "A3UIKit.h"
#import "A3SalesCalcMainViewController.h"

@interface A3PaperFoldMenuViewController ()
@property (nonatomic, strong)	UINavigationController *myNavigationController;
@property (nonatomic, strong)	A3HotMenuViewController *hotMenuViewController;
@property (nonatomic, strong)	A3NotificationTableViewController *notificationViewController, *notificationViewController2;
@property (nonatomic, weak)		UIViewController *rightWingViewController;
@property (nonatomic)			CGFloat paperFoldViewOffset, rightWingViewOffset;
@property (nonatomic) BOOL keepNarrowWidthOnHorizontalOrientation;
@property (nonatomic, copy)		void(^onCloseRightWingView)(void);

@end

@implementation A3PaperFoldMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

	}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

	CGRect paperFoldViewFrame = [[UIScreen mainScreen] bounds];
	paperFoldViewFrame.origin.x += _hotMenuViewController.view.frame.size.width;
	paperFoldViewFrame.size.width = 714.0f;

	_paperFoldView = [[PaperFoldView alloc] initWithFrame:paperFoldViewFrame];
	[_paperFoldView setDelegate:self];
	[_paperFoldView setUseOptimizedScreenshot:NO];

	[self.view addSubview:_paperFoldView];

	_contentView = [[UIView alloc] initWithFrame:_paperFoldView.bounds];
	[_contentView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin];
	[_paperFoldView setCenterContentView:_contentView];

	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		A3HomeViewController_iPad *homeViewController_iPad = [[A3HomeViewController_iPad alloc] initWithNibName:@"HomeView_iPad" bundle:nil];
		homeViewController_iPad.paperFoldView = _paperFoldView;
		self.myNavigationController = [[UINavigationController alloc] initWithRootViewController:homeViewController_iPad];
		[_contentView addSubview:[_myNavigationController view]];
		[self addChildViewController:_myNavigationController];
	} else {
		A3HomeViewController_iPhone *homeViewController_iPhone = [[A3HomeViewController_iPhone alloc] initWithNibName:@"HomeView_iPhone" bundle:nil];
		homeViewController_iPhone.paperFoldView = _paperFoldView;
		self.myNavigationController = [[UINavigationController alloc] initWithRootViewController:homeViewController_iPhone];
		[_contentView addSubview:[_myNavigationController view]];
		[self addChildViewController:_myNavigationController];
	}

	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		self.hotMenuViewController = [[A3HotMenuViewController alloc] initWithNibName:@"MenuView_iPad" bundle:nil];
		[self.view addSubview:[_hotMenuViewController view]];
		[self addChildViewController:_hotMenuViewController];
	}

	self.hotMenuViewController.myNavigationController = _myNavigationController;
	self.hotMenuViewController.paperFoldView = _paperFoldView;

	self.myNavigationController.navigationBar.tintColor = [UIColor blackColor];
	[A3UIKit setBackgroundImageForNavigationBar:self.myNavigationController.navigationBar];

	UIView *sideMenuView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, A3_MENU_TABLE_VIEW_WIDTH, CGRectGetHeight(_paperFoldView.frame))];
	_sideMenuTableViewController = [[A3iPhoneMenuTableViewController alloc] initWithStyle:UITableViewStylePlain];
	_sideMenuTableViewController.paperFoldMenuViewController = self;
	[_sideMenuTableViewController.view setFrame:sideMenuView.frame];
	[sideMenuView addSubview:_sideMenuTableViewController.view];
	[_paperFoldView setLeftFoldContentView:sideMenuView foldCount:3 pullFactor:0.9];

	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		if (![A3UIDevice deviceOrientationIsPortrait]) {
			[_paperFoldView setPaperFoldState:PaperFoldStateLeftUnfolded];
		}
	}

	self.notificationViewController = [[A3NotificationTableViewController alloc] initWithStyle:UITableViewStylePlain];
	[_notificationViewController.view setFrame:CGRectMake(0.0, 0.0, NOTIFICATION_VIEW_WIDTH, self.view.bounds.size.height)];
	[_paperFoldView setRightFoldContentView:_notificationViewController.view foldCount:3 pullFactor:0.9];

	_paperFoldView2 = [[PaperFoldView alloc] initWithFrame:paperFoldViewFrame];
	[_paperFoldView2 setDelegate:self];
	[_paperFoldView2 setUseOptimizedScreenshot:NO];

	self.notificationViewController2 = [[A3NotificationTableViewController alloc] initWithStyle:UITableViewStylePlain];
	[_notificationViewController2.view setFrame:CGRectMake(0.0, 0.0, 256.0, self.view.bounds.size.height)];
	[_paperFoldView2 setRightFoldContentView:_notificationViewController2.view foldCount:3 pullFactor:0.9];
	[_paperFoldView2.contentView setBackgroundColor:[UIColor blackColor]];
	[self.view addSubview:_paperFoldView2];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[self layoutNavigationController];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushViewControllerToNavigationController:(UIViewController *)viewController withOption:(BOOL)keepWidth {
	[self pushViewControllerToNavigationController:viewController];
	_keepNarrowWidthOnHorizontalOrientation = keepWidth;
}

- (void)pushViewControllerToNavigationController:(UIViewController *)viewController {
	_keepNarrowWidthOnHorizontalOrientation = YES;
	[self.myNavigationController popToRootViewControllerAnimated:NO];
	[self.myNavigationController pushViewController:viewController animated:YES];
	PaperFoldState paperFoldState = [A3UIDevice deviceOrientationIsPortrait] ? PaperFoldStateDefault : PaperFoldStateLeftUnfolded;
	[self.paperFoldView setPaperFoldState:paperFoldState];
}

- (void)layoutNavigationController {
	if ([self resizeNavigationViewOnRotation]) {
		PaperFoldState newState;
		CGRect newNavigationViewFrame, foldViewFrame;
		if ([A3UIDevice deviceOrientationIsPortrait]) {
			// Moved to portrait
			newState = PaperFoldStateDefault;
			newNavigationViewFrame = CGRectMake(0.0, 0.0, 714.0, 1004.0);
			foldViewFrame = CGRectMake(54.0, 0.0, 714.0, 1004.0);;
			[_hotMenuViewController.view setFrame:CGRectMake(0.0, 0.0, 54.0, 1004.0)];
			_paperFoldView.enableRightFoldDragging = YES;
		} else {
			// Moved to landscape
			newState = PaperFoldStateLeftUnfolded;
			newNavigationViewFrame = CGRectMake(0.0, 0.0, 714.0, 748.0);
			foldViewFrame = CGRectMake(54.0, 0.0, 970.0, 748.0);
			[_hotMenuViewController.view setFrame:CGRectMake(0.0, 0.0, 54.0, 748.0)];
			_paperFoldView.enableRightFoldDragging = NO;
		}
		[_paperFoldView setFrame:foldViewFrame];
		[_contentView setFrame:newNavigationViewFrame];
		[_myNavigationController.view setFrame:_contentView.bounds];
		[_paperFoldView setPaperFoldState:newState];

		[_paperFoldView.rightFoldView setHidden:YES];
		[_paperFoldView2 setFrame:CGRectMake(1024.0, 0.0, 0.0, self.view.bounds.size.height)];
		[_paperFoldView2 setPaperFoldState:PaperFoldStateDefault];
	}
}

- (BOOL)resizeNavigationViewOnRotation {
	return ([self.myNavigationController topViewController] == [self.myNavigationController.viewControllers objectAtIndex:0] ||
			_keepNarrowWidthOnHorizontalOrientation);

}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	FNLOG(@"check");
	UIViewAutoresizing autoResizing = [self resizeNavigationViewOnRotation] ? UIViewAutoresizingFlexibleHeight : UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_contentView.autoresizingMask = autoResizing;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

	[self layoutNavigationController];
}

- (CGRect)getHiddenNotificationViewFrame {
	CGRect paperFoldViewFrame = [self getPaperFoldViewFrame];
	CGFloat originX = CGRectGetMaxX(paperFoldViewFrame);
	CGFloat viewWidth = 320.0;
	return [A3UIDevice deviceOrientationIsPortrait] ? CGRectMake(originX, 0.0, viewWidth, 1004) :
			CGRectMake(originX, 0.0, viewWidth, 748.0);
}

- (CGRect)getNotificationViewFrame {
	CGFloat viewWidth = 320.0;
	return [A3UIDevice deviceOrientationIsPortrait] ? CGRectMake(768.0 - viewWidth, 0.0, viewWidth, 1004):
			CGRectMake(1024.0 - viewWidth, 0.0, viewWidth, 748);
}

- (CGRect)getPaperFoldViewFrame {
	UIViewController *visibleViewController = [self.myNavigationController visibleViewController];
	CGFloat width = CGRectGetWidth(_paperFoldView.contentView.bounds) + (_paperFoldView.state == PaperFoldStateLeftUnfolded ? CGRectGetWidth(_paperFoldView.leftFoldView.bounds) : 0.0);
	if ([visibleViewController isKindOfClass:[A3HomeViewController_iPad class]]) {
		return [A3UIDevice deviceOrientationIsPortrait] ? CGRectMake(54.0, 0.0, width, 1004.0):
				CGRectMake(54.0, 0.0, 714.0, 748.0);
	}
	return [A3UIDevice deviceOrientationIsPortrait] ? CGRectMake(54.0, 0.0, width, 1004.0) :
			CGRectMake(54.0, 0.0, 970.0, 748.0);
}

- (void)presentNotificationView {
	[UIView beginAnimations:nil context:NULL];
	[_notificationViewController.view setFrame:[self getNotificationViewFrame]];
	[_paperFoldView setFrame:CGRectOffset(_paperFoldView.frame, -320.0, 0.0)];
	[UIView commitAnimations];
}

- (void)hideNotificationView {
	[UIView beginAnimations:nil context:NULL];
	[_notificationViewController.view setFrame:[self getHiddenNotificationViewFrame]];
	[_paperFoldView setFrame:[self getPaperFoldViewFrame]];
	[UIView commitAnimations];
}

- (void)paperFoldView:(id)paperFoldView didFoldAutomatically:(BOOL)automated toState:(PaperFoldState)paperFoldState {
//	FNLOG(@"Check %d, %d", automated, paperFoldState);
	if ((paperFoldView == _paperFoldView) && (paperFoldState == PaperFoldStateLeftUnfolded)) {
		[_paperFoldView2 setPaperFoldState:PaperFoldStateDefault animated:NO];
	}
}

// callback when paper fold view is offset
- (void)paperFoldView:(PaperFoldView *)paperFoldView viewDidOffset:(CGPoint)offset {
	if ((paperFoldView == _paperFoldView) && ![A3UIDevice deviceOrientationIsPortrait]) {
//		CGFloat myX = (offset.x - 256.0)/256.0 * 320.0;
		CGFloat myX = (offset.x - 256.0);
//		FNLOG(@"%f, %f", offset.x, myX);
		[_paperFoldView2.rightFoldView setHidden:NO];
		[_paperFoldView.rightFoldView setHidden:YES];
		[_paperFoldView2 animateWithContentOffset:CGPointMake(myX, 0.0) panned:YES];
	}
}

- (CGFloat)displacementOfMultiFoldView:(id)multiFoldView {
	return HOT_MENU_VIEW_WIDTH + A3_MENU_TABLE_VIEW_WIDTH + APP_VIEW_WIDTH;
}

- (void)presentRightWingWithViewController:(UIViewController *)viewController onClose:(void (^)())onCloseBlock {
	self.onCloseRightWingView = onCloseBlock;

	CGRect frame = [A3UIDevice deviceOrientationIsPortrait] ? CGRectMake(0.0, 0.0, 320.0, 1004.0) : CGRectMake(0.0, 0.0, 320.0, 748.0);
	[viewController.view setFrame:frame];

	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	frame = [A3UIDevice deviceOrientationIsPortrait] ? CGRectMake(768.0, 0.0, 320.0, 1004.0) : CGRectMake(1024.0, 0.0, 320.0, 748.0);
	[navigationController.view setFrame:frame];
	navigationController.view.layer.borderWidth = 1.0;
	navigationController.view.layer.borderColor = [UIColor lightGrayColor].CGColor;

	_rightWingViewController = navigationController;

	[self.view addSubview:_rightWingViewController.view];
	[self addChildViewController:_rightWingViewController];

	UIView *coverView = [[UIView alloc] initWithFrame:_paperFoldView.bounds];
	coverView.backgroundColor = [UIColor clearColor];
	[_paperFoldView addSubview:coverView];

	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCoverTapGesture:)];
	[coverView addGestureRecognizer:tapGestureRecognizer];

	_rightWingViewOffset = CGRectGetWidth(navigationController.view.bounds);
	UIViewController *topViewController = [_myNavigationController topViewController];
	if (![A3UIDevice deviceOrientationIsPortrait] &&
			[topViewController isKindOfClass:[A3SalesCalcMainViewController class]]) {
		_paperFoldViewOffset = 288.0;
	} else {
		_paperFoldViewOffset = _rightWingViewOffset;
	}

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	_paperFoldView.frame = CGRectOffset(_paperFoldView.frame, -1.0 * _paperFoldViewOffset, 0.0);
	_rightWingViewController.view.frame = CGRectOffset(_rightWingViewController.view.frame, -1 * _rightWingViewOffset, 0.0);
	[UIView commitAnimations];
}

- (void)removeRightWingViewController {
	[UIView animateWithDuration:0.3
					 animations:^{
						 _paperFoldView.frame = CGRectOffset(_paperFoldView.frame, _paperFoldViewOffset, 0.0);
						 _rightWingViewController.view.frame = CGRectOffset(_rightWingViewController.view.frame, _rightWingViewOffset, 0.0);
					 }
					 completion:^(BOOL finished){
						 // Remove cover view
						 [[_paperFoldView.subviews lastObject] removeFromSuperview];
						 [_rightWingViewController.view removeFromSuperview];
						 [_rightWingViewController removeFromParentViewController];
					 }];
}

- (void)handleCoverTapGesture:(UITapGestureRecognizer *)sender {
	if (self.onCloseRightWingView) {
		self.onCloseRightWingView();
	}
	[self removeRightWingViewController];
}

@end
