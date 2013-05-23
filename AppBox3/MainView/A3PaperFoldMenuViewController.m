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
#import "UIViewController+A3AppCategory.h"

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
		_keepNarrowWidthOnHorizontalOrientation = YES;
	}
    return self;
}

- (PaperFoldView *)paperFoldView {
	if (nil == _paperFoldView) {
		CGRect paperFoldViewFrame = [[UIScreen mainScreen] bounds];
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
			paperFoldViewFrame.origin.x += self.hotMenuViewController.view.frame.size.width;
			paperFoldViewFrame.size.width = APP_VIEW_WIDTH_iPAD;
		} else {
			paperFoldViewFrame.size.width = APP_VIEW_WIDTH_iPHONE;
		}

		_paperFoldView = [[PaperFoldView alloc] initWithFrame:paperFoldViewFrame];
		[_paperFoldView setDelegate:self];
		[_paperFoldView setUseOptimizedScreenshot:NO];
	}
	return _paperFoldView;
}

- (UIView *)contentView {
	if (nil == _contentView) {
		_contentView = [[UIView alloc] initWithFrame:_paperFoldView.bounds];
		[_contentView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin];
	}
	return _contentView;
}

- (UINavigationController *)myNavigationController {
	if (nil == _myNavigationController) {
		id rootViewController;
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
			A3HomeViewController_iPad *viewController = [[A3HomeViewController_iPad alloc] initWithNibName:@"HomeView_iPad" bundle:nil];
			viewController.paperFoldView = self.paperFoldView;
			rootViewController = viewController;
		} else {
			A3HomeViewController_iPhone *viewController = [[A3HomeViewController_iPhone alloc] initWithNibName:@"HomeView_iPhone" bundle:nil];
			viewController.paperFoldView = self.paperFoldView;
			rootViewController = viewController;
		}
		_myNavigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
	}
	return _myNavigationController;
}

- (A3HotMenuViewController *)hotMenuViewController {
	if (nil == _hotMenuViewController) {
		_hotMenuViewController = [[A3HotMenuViewController alloc] initWithNibName:@"MenuView" bundle:nil];
		_hotMenuViewController.myNavigationController = self.myNavigationController;
		_hotMenuViewController.paperFoldView = self.paperFoldView;
	}
	return _hotMenuViewController;
}

- (A3iPhoneMenuTableViewController *)sideMenuTableViewController {
	if (nil == _sideMenuTableViewController) {
		UIView *sideMenuView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, A3_MENU_TABLE_VIEW_WIDTH, CGRectGetHeight(_paperFoldView.frame))];
		_sideMenuTableViewController = [[A3iPhoneMenuTableViewController alloc] initWithStyle:UITableViewStylePlain];
		_sideMenuTableViewController.paperFoldMenuViewController = self;
		[_sideMenuTableViewController.view setFrame:sideMenuView.frame];
		[sideMenuView addSubview:_sideMenuTableViewController.view];
		[_paperFoldView setLeftFoldContentView:sideMenuView foldCount:3 pullFactor:0.9];
	}
	return _sideMenuTableViewController;
}

- (A3NotificationTableViewController *)notificationViewController {
	if (nil == _notificationViewController) {
		_notificationViewController = [[A3NotificationTableViewController alloc] initWithStyle:UITableViewStylePlain];
		[_notificationViewController.view setFrame:CGRectMake(0.0, 0.0, NOTIFICATION_VIEW_WIDTH, self.view.bounds.size.height)];
		[_paperFoldView setRightFoldContentView:_notificationViewController.view foldCount:3 pullFactor:0.9];
	}
	return _notificationViewController;
}

- (PaperFoldView *)paperFoldView2 {
	if (nil == _paperFoldView2) {
		_paperFoldView2 = [[PaperFoldView alloc] initWithFrame:self.paperFoldView.frame];
		[_paperFoldView2 setDelegate:self];
		[_paperFoldView2 setUseOptimizedScreenshot:NO];
		[self.view addSubview:_paperFoldView2];
	}
	return _paperFoldView2;
}

- (A3NotificationTableViewController *)notificationViewController2 {
	if (nil == _notificationViewController2) {
		_notificationViewController2 = [[A3NotificationTableViewController alloc] initWithStyle:UITableViewStylePlain];
		[_notificationViewController2.view setFrame:CGRectMake(0.0, 0.0, 256.0, self.view.bounds.size.height)];
		[_paperFoldView2 setRightFoldContentView:_notificationViewController2.view foldCount:3 pullFactor:0.9];
		[_paperFoldView2.contentView setBackgroundColor:[UIColor blackColor]];
	}
	return _notificationViewController2;
}

- (void)configureiPadHomeScreen {
	[self.view addSubview:self.paperFoldView];
	[_paperFoldView setCenterContentView:self.contentView];

	[_contentView addSubview:[self.myNavigationController view]];
	[self addChildViewController:_myNavigationController];

	[self.view addSubview:[self.hotMenuViewController view]];
	[self addChildViewController:_hotMenuViewController];

	[self sideMenuTableViewController];

	if (![A3UIDevice deviceOrientationIsPortrait]) {
		[_paperFoldView setPaperFoldState:PaperFoldStateLeftUnfolded];
	}
	[self notificationViewController];

//	[self paperFoldView2];
//	[self notificationViewController2];
}

- (void)configureiPhoneHomeScreen {
	[self.view addSubview:self.paperFoldView];
	[_paperFoldView setCenterContentView:self.contentView];

	[_contentView addSubview:[self.myNavigationController view]];
	[self addChildViewController:_myNavigationController];

	[self sideMenuTableViewController];
	[self notificationViewController];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[self layoutNavigationController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view.
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		[self configureiPadHomeScreen];
	} else {
		[self configureiPhoneHomeScreen];
	}
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
		CGFloat leftOffset = _hotMenuViewController != nil ? _hotMenuViewController.view.bounds.size.width : 0.0;
		CGFloat viewWidth;
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
			viewWidth = [A3UIDevice deviceOrientationIsPortrait] ? APP_VIEW_WIDTH_iPAD : A3_APP_LANDSCAPE_FULL_WIDTH;
			viewWidth = _keepNarrowWidthOnHorizontalOrientation ? APP_VIEW_WIDTH_iPAD : viewWidth;
		} else {
			viewWidth = APP_VIEW_WIDTH_iPHONE;
		}
		CGRect screenBounds = [A3UIDevice appFrame];
		screenBounds.size.height += 44.0;

		if ([A3UIDevice deviceOrientationIsPortrait]) {
			// Moved to portrait
			newState = PaperFoldStateDefault;
			_paperFoldView.enableRightFoldDragging = YES;
		} else {
			// Moved to landscape
			newState = PaperFoldStateLeftUnfolded;
			_paperFoldView.enableRightFoldDragging = NO;
		}
		newNavigationViewFrame = CGRectMake(0.0, 0.0, viewWidth, screenBounds.size.height);
		foldViewFrame = CGRectMake(leftOffset, 0.0, viewWidth + 310.0, screenBounds.size.height);
		[_hotMenuViewController.view setFrame:CGRectMake(0.0, 0.0, HOT_MENU_VIEW_WIDTH, screenBounds.size.height)];

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
	return HOT_MENU_VIEW_WIDTH + A3_MENU_TABLE_VIEW_WIDTH + APP_VIEW_WIDTH_iPAD;
}

- (void)presentRightWingWithViewController:(UIViewController *)viewController onClose:(void (^)())onCloseBlock {
	self.onCloseRightWingView = onCloseBlock;

	CGRect frame = [A3UIDevice deviceOrientationIsPortrait] ? CGRectMake(0.0, 0.0, 320.0, 1004.0) : CGRectMake(0.0, 0.0, 320.0, 748.0);
	[viewController.view setFrame:frame];

	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	[self applySilverNavigationBarStyleToNavigationVC:navigationController];
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
	_paperFoldViewOffset = _rightWingViewOffset;

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
