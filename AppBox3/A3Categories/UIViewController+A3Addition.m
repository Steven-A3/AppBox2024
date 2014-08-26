//
//  UIViewController(A3Addition)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/7/13 5:59 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "A3WalletItemEditViewController.h"
#import "A3AppDelegate.h"
#import "UIViewController+MMDrawerController.h"
#import "A3CenterViewDelegate.h"
#import "UIViewController+A3Addition.h"
#import "A3KeychainUtils.h"
#import "UIViewController+NumberKeyboard.h"
#import "NSDate+formatting.h"
#import "NSDateFormatter+A3Addition.h"
#import "A3UserDefaultsKeys.h"
#import "A3UserDefaults.h"

@implementation UIViewController (A3Addition)

/*! MainMenuViewController에서 app switch 할 때 popToRootViewController를 한 뒤에, 각 ViewController에 cleanUp을 호출합니다.
 *  이때 removeObserver와 nil을 할당하면 메모리를 효율적으로 제거할 수 있습니다.
 *  개별 viewController 에서 cleanUp을 구현하지 않은 경우, removeObserver 는 기본적으로 실행이 됩니다.
 *  만약 별도 구현한 경우에는 필요한 조치를 개별 구현하던가, [super cleanUp]을 호출해 주면 되겠습니다.
 */

- (void)cleanUp {
	[self removeObserver];
}

- (CGRect)screenBoundsAdjustedWithOrientation {
	CGRect bounds = [[UIScreen mainScreen] bounds];
	if (IS_IOS7 && IS_LANDSCAPE) {
		CGFloat width = bounds.size.width;
		bounds.size.width = bounds.size.height;
		bounds.size.height = width;
	}
	return bounds;
}

- (void)popToRootAndPushViewController:(UIViewController *)viewController {
	UINavigationController *navigationController;

	if (IS_IPHONE) {
		navigationController = (UINavigationController *) self.mm_drawerController.centerViewController;
		[self.mm_drawerController closeDrawerAnimated:YES completion:nil];
	} else {
		A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController];
		navigationController = [rootViewController centerNavigationController];
        // KJH
        if (rootViewController.presentViewControllers && [rootViewController.presentViewControllers count] > 0) {
            [rootViewController dismissCenterViewController];
        }
	}

	NSArray *poppedVCs = [navigationController popToRootViewControllerAnimated:NO];
	for (UIViewController<A3CenterViewDelegate> *vc in poppedVCs) {
		if ([vc respondsToSelector:@selector(cleanUp)]) {
			[vc performSelector:@selector(cleanUp)];
		}
	}
	[navigationController setToolbarHidden:YES];
	[navigationController setNavigationBarHidden:NO animated:NO];

	BOOL hidesNavigationBar = NO;
	UIViewController<A3CenterViewDelegate> *targetViewController = (UIViewController <A3CenterViewDelegate> *) viewController;
	if ([viewController respondsToSelector:@selector(hidesNavigationBar)]) {
		hidesNavigationBar = [targetViewController hidesNavigationBar];
	}
    if (hidesNavigationBar) {
        [navigationController setNavigationBarHidden:YES animated:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];

        UIImage *image = [UIImage new];
        [navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
        [navigationController.navigationBar setShadowImage:image];
    } else {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];

		[navigationController setNavigationBarHidden:NO animated:YES];
		[navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
		[navigationController.navigationBar setShadowImage:nil];

		[navigationController setToolbarHidden:NO];
		[navigationController setNavigationBarHidden:YES animated:NO];

		[navigationController setToolbarHidden:YES];
		[navigationController setNavigationBarHidden:NO animated:NO];

	}
    navigationController.navigationBar.tintColor = [A3AppDelegate instance].themeColor;

	if (IS_IPAD) {
		A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController];
		[rootViewController animateHideLeftViewForFullScreenCenterView:YES];
	}

    if (viewController) {
        [navigationController pushViewController:viewController animated:NO];
    }
}

- (void)popToRootAndPushViewController:(UIViewController *)viewController animate:(BOOL)animate
{
    UINavigationController *navigationController;
    
	if (IS_IPHONE) {
		navigationController = (UINavigationController *) self.mm_drawerController.centerViewController;
		[self.mm_drawerController closeDrawerAnimated:animate completion:nil];
	} else {
		A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController];
		navigationController = [rootViewController centerNavigationController];
	}
    
	[navigationController setToolbarHidden:YES];
    
	BOOL hidesNavigationBar = NO;
	UIViewController<A3CenterViewDelegate> *targetViewController = (UIViewController <A3CenterViewDelegate> *) viewController;
	if ([viewController respondsToSelector:@selector(hidesNavigationBar)]) {
		hidesNavigationBar = [targetViewController hidesNavigationBar];
	}
    if (hidesNavigationBar) {
        [navigationController setNavigationBarHidden:YES animated:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
        
        UIImage *image = [UIImage new];
        [navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
        [navigationController.navigationBar setShadowImage:image];
    } else {
        [navigationController setNavigationBarHidden:NO animated:animate];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:(animate ? UIStatusBarAnimationSlide : UIStatusBarAnimationNone)];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animate];
        
        [navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [navigationController.navigationBar setShadowImage:nil];
    }
    
	NSArray *poppedVCs = [navigationController popToRootViewControllerAnimated:NO];
	for (UIViewController<A3CenterViewDelegate> *vc in poppedVCs) {
		if ([vc respondsToSelector:@selector(cleanUp)]) {
			[vc performSelector:@selector(cleanUp)];
		}
	}
    
	if (IS_IPAD) {
		BOOL usesFullScreenInLandscape = NO;
		if ([viewController respondsToSelector:@selector(usesFullScreenInLandscape)]) {
			usesFullScreenInLandscape = [targetViewController usesFullScreenInLandscape];
		}
		A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController];
        [rootViewController animateHideLeftViewForFullScreenCenterView:usesFullScreenInLandscape];
	}
    
    if (viewController) {
        [navigationController pushViewController:viewController animated:animate];
    }
}

- (void)leftBarButtonAppsButton {
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Apps", @"Apps") style:UIBarButtonItemStylePlain target:self action:@selector(appsButtonAction:)];
}

- (void)appsButtonAction:(UIBarButtonItem *)barButtonItem {
	[self.firstResponder resignFirstResponder];
	if (IS_IPHONE) {
		[[self mm_drawerController] toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
	} else {
		[[[A3AppDelegate instance] rootViewController] toggleLeftMenuViewOnOff];
	}
}

- (void)leftBarButtonCancelButton {
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonAction:)];
}

- (void)cancelButtonAction:(UIBarButtonItem *)barButtonItem {

}

- (void)addTwoButtons:(NSArray *)buttons toView:(UIView *)view {
	NSAssert([buttons count] == 2, @"The number of buttons must 2 but it is %lu", (unsigned long)[buttons count]);
	UIButton *button1 = buttons[0];
	UIButton *button2 = buttons[1];
	for (UIButton *button in buttons) {
		[view addSubview:button];
		[button setTranslatesAutoresizingMaskIntoConstraints:NO];
	}
	[view addConstraint:[NSLayoutConstraint constraintWithItem:button1
													 attribute:NSLayoutAttributeBottom
													 relatedBy:NSLayoutRelationEqual
														toItem:view
													 attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-10.0]];
	[view addConstraint:[NSLayoutConstraint constraintWithItem:button2
													 attribute:NSLayoutAttributeBottom
													 relatedBy:NSLayoutRelationEqual
														toItem:view
													 attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-10.0]];
	[view addConstraint:[NSLayoutConstraint constraintWithItem:button1
													 attribute:NSLayoutAttributeCenterX
													 relatedBy:NSLayoutRelationEqual
														toItem:view
													 attribute:NSLayoutAttributeCenterX multiplier:2.0 * 1.0 / 3.0 constant:0.0]];
	[view addConstraint:[NSLayoutConstraint constraintWithItem:button2
													 attribute:NSLayoutAttributeCenterX
													 relatedBy:NSLayoutRelationEqual
														toItem:view
													 attribute:NSLayoutAttributeCenterX multiplier:2.0 * 2.0 / 3.0 constant:0.0]];
}

- (void)addThreeButtons:(NSArray *)buttons toView:(UIView *)view {
	NSAssert([buttons count] == 3, @"The number of buttons must 3 but it is %lu", (unsigned long)[buttons count]);
	UIButton *button1 = buttons[0];
	UIButton *button2 = buttons[1];
	UIButton *button3 = buttons[2];
	for (UIButton *button in buttons) {
		[view addSubview:button];
		[button setTranslatesAutoresizingMaskIntoConstraints:NO];
	}
	NSDictionary *views = NSDictionaryOfVariableBindings(button1, button2, button3);
	[view addConstraint:[NSLayoutConstraint constraintWithItem:button1
													 attribute:NSLayoutAttributeBottom
													 relatedBy:NSLayoutRelationEqual
														toItem:view
													 attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-10.0]];
	[view addConstraint:[NSLayoutConstraint constraintWithItem:button2
													 attribute:NSLayoutAttributeCenterX
													 relatedBy:NSLayoutRelationEqual
														toItem:view
													 attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
	[view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[button1]-[button2]-[button3]-|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:views]];
}

- (void)addFourButtons:(NSArray *)buttons toView:(UIView *)view {
	NSAssert([buttons count] == 4, @"The number of buttons must 4 but it is %lu", (unsigned long)[buttons count]);
	NSInteger numberOfButtons = [buttons count];
	CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	CGFloat width = (screenBounds.size.width + 40) / (numberOfButtons + 1);
	NSInteger buttonIndex = 1;
	for (UIButton *button in buttons) {
		[view addSubview:button];

		[button makeConstraints:^(MASConstraintMaker *make) {
			make.bottom.equalTo(view.bottom).with.offset(-10);
			make.width.equalTo(@44.0);
			make.centerX.equalTo(view.left).with.offset(width * buttonIndex - 20);
		}];
		buttonIndex++;
	}
}

- (UIView *)moreMenuViewWithButtons:(NSArray *)buttonsArray {
	CGRect frame;
	frame = self.view.frame;
	frame.size.height = 44.0;
	frame.origin.y = -1.0;
	UIView *moreMenuView = [[UIView alloc] initWithFrame:frame];
	moreMenuView.backgroundColor = [UIColor colorWithRed:247.0 / 255.0 green:247.0 / 255.0 blue:247.0 / 255.0 alpha:1.0];
    //frame.origin.y += 44.0;
	frame.origin.y += 45.0; // kjh
	frame.size.height = 0.5;    // kjh
	UIView *bottomLineView = [[UIView alloc] initWithFrame:frame];
	bottomLineView.backgroundColor = [UIColor colorWithRed:178.0 / 255.0 green:178.0 / 255.0 blue:178.0 / 255.0 alpha:1.0];
	[moreMenuView addSubview:bottomLineView];

	switch ([buttonsArray count]) {
		case 2:
			[self addTwoButtons:buttonsArray toView:moreMenuView];
			break;
		case 3:
			[self addThreeButtons:buttonsArray toView:moreMenuView];
			break;
		case 4:
			[self addFourButtons:buttonsArray toView:moreMenuView];
			break;
	}

	return moreMenuView;
}

- (UIView *)presentMoreMenuWithButtons:(NSArray *)buttons tableView:(UITableView *)tableView {
	UIView *moreMenuView = [self moreMenuViewWithButtons:buttons];
	CGRect clippingViewFrame = moreMenuView.frame;
	clippingViewFrame.origin.y = 20.0 + 44.0 - 1.0;
    clippingViewFrame.size.height = clippingViewFrame.size.height + 0.5;//kjh
	UIView *clippingView = [[UIView alloc] initWithFrame:clippingViewFrame];
	clippingView.clipsToBounds = YES;
	CGRect frame = clippingView.bounds;
	frame.origin.y -= frame.size.height;
	moreMenuView.frame = frame;
	[clippingView addSubview:moreMenuView];

	[self.navigationController.view insertSubview:clippingView belowSubview:self.view];

	[UIView animateWithDuration:0.3 animations:^{
		CGRect newFrame = moreMenuView.frame;
		newFrame.origin.y = 0.0;
		moreMenuView.frame = newFrame;

		if (tableView) {
			UIEdgeInsets insets = tableView.contentInset;
			insets.top += clippingViewFrame.size.height;
			tableView.contentInset = insets;

			if (tableView.contentOffset.y == -64.0) {
				CGPoint offset = tableView.contentOffset;
				offset.y = -108.0;
				tableView.contentOffset = offset;
			}
		}
	}];

	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moreMenuDismissAction:)];
	[self.view addGestureRecognizer:gestureRecognizer];
	[self.navigationItem.leftBarButtonItem setEnabled:NO];

	return clippingView;
}

- (void)dismissMoreMenuView:(UIView *)moreMenuView scrollView:(UIScrollView *)scrollView {
	UIView *menuView = moreMenuView.subviews[0];
    
	[UIView animateWithDuration:0.3 animations:^{
		CGRect frame = menuView.frame;
		frame = CGRectOffset(frame, 0.0, -44.0);
		menuView.frame = frame;

		if (scrollView) {
			UIEdgeInsets insets = scrollView.contentInset;
			insets.top -= moreMenuView.frame.size.height;
			scrollView.contentInset = insets;
		} /*else {  KJH
			frame = CGRectOffset(self.view.frame, 0.0, moreMenuView.frame.size.height);
			self.view.frame = frame;
		}*/
	} completion:^(BOOL finished) {
		[moreMenuView removeFromSuperview];
		[self.navigationItem.leftBarButtonItem setEnabled:YES];
	}];
}

- (void)moreMenuDismissAction:(UITapGestureRecognizer *)gestureRecognizer {
	FNLOG(@"You have to override this method to close moreMenuView properly.");
}

- (UIButton *)shareButton {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
	[button setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
	[button addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	return button;
}

- (void)shareButtonAction:(id)sender {

}

- (UIButton *)historyButton:(Class)managedObjectClass {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
	[button setImage:[UIImage imageNamed:@"history"] forState:UIControlStateNormal];
	[button addTarget:self action:@selector(historyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	if (managedObjectClass) {
		[button setEnabled:[managedObjectClass MR_countOfEntitiesWithContext:[NSManagedObjectContext MR_defaultContext] ] > 0 ];
	}
	return button;
}

- (UIBarButtonItem *)historyBarButton:(Class)managedObjectClass {
	UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"history"] style:UIBarButtonItemStylePlain target:self action:@selector(historyButtonAction:)];
	[barButtonItem setEnabled:[managedObjectClass MR_countOfEntitiesWithContext:[NSManagedObjectContext MR_defaultContext] ] > 0 ];
	return barButtonItem;
}

- (void)historyButtonAction:(UIButton *)button {

}

- (UIButton *)settingsButton {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
	[button setImage:[UIImage imageNamed:@"general"] forState:UIControlStateNormal];
	[button addTarget:self action:@selector(settingsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	return button;
}

- (void)settingsButtonAction:(UIButton *)button {

}

- (UIButton *)instructionHelpButton {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
	[button setImage:[UIImage imageNamed:@"help"] forState:UIControlStateNormal];
	[button addTarget:self action:@selector(instructionHelpButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	return button;
}

- (UIBarButtonItem *)instructionHelpBarButton {
	UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"help"] style:UIBarButtonItemStylePlain target:self action:@selector(instructionHelpButtonAction:)];
	return barButtonItem;
}

- (void)instructionHelpButtonAction:(id)sender {
    [self showInstructionView];
}

- (UIButton *)composeButton {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
	[button setImage:[UIImage imageNamed:@"add07"] forState:UIControlStateNormal];
	[button addTarget:self action:@selector(composeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	return button;
	return button;
}

- (void)composeButtonAction:(UIButton *)button {

}

- (void)rightBarButtonDoneButton {
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonAction:)];
}

- (void)doneButtonAction:(UIBarButtonItem *)button {

}

- (void)rightButtonMoreButton {
	UIImage *image = [UIImage imageNamed:@"more"];
	UIBarButtonItem *moreButtonItem = [[UIBarButtonItem alloc] initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(moreButtonAction:)];

	self.navigationItem.rightBarButtonItem = moreButtonItem;
}

- (void)moreButtonAction:(UIBarButtonItem *)button {

}

/*! This will make back bar button title @"" and this will effective for child view controllers
 * \returns void
 */
- (void)makeBackButtonEmptyArrow {
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

/*! iOS 7 : iPad 에서는 UIPopoverController 를 만들고 이를 돌려준다.
 *  iOS 8 : 항상 nil 을 돌려준다.
 * \param
 * completionBlock 은 iOS 8 에서만 유효하다.
 * \returns
 */
- (UIPopoverController *)presentActivityViewControllerWithActivityItems:(id)items fromBarButtonItem:(UIBarButtonItem *)barButtonItem completion:(void (^)())completionBlock {
	UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
	if (IS_IOS7) {
		if (IS_IPHONE) {
			[self presentViewController:activityController animated:YES completion:NULL];
		} else {
			UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:activityController];
			[popoverController presentPopoverFromBarButtonItem:barButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
			return popoverController;
		}
	} else {
		activityController.modalPresentationStyle = UIModalPresentationPopover;
		[self presentViewController:activityController animated:YES completion:completionBlock];
		UIPopoverPresentationController *presentationController = [activityController popoverPresentationController];
		presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
		presentationController.sourceView = self.view;
		presentationController.barButtonItem = barButtonItem;
	}
	return nil;
}

- (UIPopoverController *)presentActivityViewControllerWithActivityItems:(id)items fromSubView:(UIView *)subView {
	UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    [activityController setCompletionHandler:^(NSString *activityType, BOOL completed) {
        FNLOG(@"completed dialog - activity: %@ - finished flag: %d", activityType, completed);
    }];
    
	if (IS_IPHONE) {
		[self presentViewController:activityController animated:YES completion:NULL];
	} else {
		UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:activityController];
        CGRect viewRect = [subView convertRect:subView.bounds toView:self.view];
        [popoverController presentPopoverFromRect:viewRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		return popoverController;
	}
	return nil;
}

+ (UIViewController<A3PasscodeViewControllerProtocol> *)passcodeViewControllerWithDelegate:(id<A3PasscodeViewControllerDelegate>)delegate {
	UIViewController<A3PasscodeViewControllerProtocol> *passcodeViewController;

	if ([[A3UserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForUseSimplePasscode]) {
		passcodeViewController = [[A3PasscodeViewController alloc] initWithDelegate:delegate];
	} else {
		passcodeViewController = [[A3PasswordViewController alloc] initWithDelegate:delegate];
	}
	return passcodeViewController;
}

- (BOOL)checkPasscode {
	return ([[A3KeychainUtils getPassword] length] && [[A3AppDelegate instance] didPasscodeTimerEnd]);
}

- (void)alertInternetConnectionIsNotAvailable {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
														message:NSLocalizedString(@"Internet connection is not available.", nil)
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	[alertView show];
}

- (void)willDismissFromRightSide
{

}
- (void)alertCloudNotEnabled {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"iCloud", @"iCloud")
														message:NSLocalizedString(@"iCloud_goto_settings", @"Please goto Settings of your device. Enable iCloud and Documents and Data storages in your Settings to gain access to this feature.")
													   delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	[alertView show];
}

- (UIActionSheet *)actionSheetAskingImagePickupWithDelete:(BOOL)deleteEnable delegate:(id <UIActionSheetDelegate>)delegate {
    UIActionSheet *actionSheet;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:delegate
                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                    destructiveButtonTitle:deleteEnable ? NSLocalizedString(@"Delete Photo", nil) : nil
                                         otherButtonTitles:NSLocalizedString(@"Take Photo", nil),
                       NSLocalizedString(@"Choose Existing", nil),
                       NSLocalizedString(@"Choose and Resize", nil), nil];
        
    }
    else {
        if (deleteEnable) {
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                      delegate:delegate
                                             cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                        destructiveButtonTitle:NSLocalizedString(@"Delete Photo", nil)
                                             otherButtonTitles:
                           NSLocalizedString(@"Choose Existing", nil),
                           NSLocalizedString(@"Choose and Resize", nil), nil];
        }
        else {
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                      delegate:delegate
                                             cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:NSLocalizedString(@"Choose Existing", nil),
                           NSLocalizedString(@"Choose and Resize", nil), nil];
        }
    }

	return actionSheet;
}

#pragma mark - Custom Date String Related

- (NSString *)fullStyleDateStringFromDate:(NSDate *)date withShortTime:(BOOL)shortTime
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateStyle = NSDateFormatterFullStyle;
    if (shortTime) {
        formatter.timeStyle = NSDateFormatterShortStyle;
    }
    
    return [formatter stringFromDate:date];
}

- (NSString *)customFullStyleDateStringFromDate:(NSDate *)date withShortTime:(BOOL)shortTime
{
    NSDateFormatter *formatter = [NSDateFormatter new];

    if ([NSDate isFullStyleLocale]) {
        formatter.dateStyle = NSDateFormatterFullStyle;
        if (shortTime) {
            formatter.timeStyle = NSDateFormatterShortStyle;
        }
    }
    else {
        if (shortTime) {
            formatter.dateFormat = [formatter customFullWithTimeStyleFormat];
        }
        else {
            formatter.dateFormat = [formatter customFullStyleFormat];
        }
    }

    return [formatter stringFromDate:date];
}

#pragma mark - Instruction

- (void)showInstructionView {
    
}

#pragma mark - Share Format

- (NSString *)shareMailMessageWithHeader:(NSString *)header contents:(NSString *)contents tail:(NSString *)tail {
	NSMutableString *txt = [NSMutableString new];
	[txt appendFormat:@"<html><body>%@<br/><br/>", header];
	[txt appendString:contents];

	[txt appendFormat:[self shareMessageFormat], tail];
	return txt;
}

/*! [NSString stringWithFormat:] 에서 사용할 수 있는 문자열을 돌려주며, 하나의 파라메터를 허용하는 포맷으로, 파라메터로는 공유할 내용을 전달함
 * \param 없음
 * \returns
 */
- (NSString *)shareMessageFormat {
	return [NSString stringWithFormat:@"<br/>%%@<br/>%@", [self commonShareFooter]];
}

- (NSString *)commonShareFooter {
	return [NSString stringWithFormat:@"<img style='border:0;' src='http://apns.allaboutapps.net/allaboutapps/appboxIcon60.png' alt='AppBox Pro'><br/><a href='https://itunes.apple.com/app/id318404385'>%@</a></body></html>",
									  NSLocalizedString(@"Download from AppStore", nil)];
}

- (NSString *)appITunesURL {
	return @"https://itunes.apple.com/app/id318404385";
}

- (void)alertLocationDisabled {
	NSString *message = ![CLLocationManager locationServicesEnabled] ? NSLocalizedString(@"Location Services not enabled. Go to Settings > Privacy > Location Services. Location services must enabled and AppBox Pro authorized to show weather.", nil) :
			NSLocalizedString(@"Location services enabled, but AppBox Pro is not authorized to access location services. Go to Settings > Privacy > Location Services and authorize it to show weather.", nil);
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info") message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
	[alertView show];
}


@end
