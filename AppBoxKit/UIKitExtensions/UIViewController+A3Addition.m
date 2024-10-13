//
//  UIViewController(A3Addition)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/7/13 5:59 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "UIViewController+A3Addition.h"
#import <CoreLocation/CoreLocation.h>
#import "NSDate+formatting.h"
#import "NSDateFormatter+A3Addition.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"
#import "A3UIDevice.h"
#import "A3SyncManager.h"
#import "common.h"
#import <objc/runtime.h>
@import AVKit;
@import Photos;
#import "A3UserDefaults.h"
#import "A3UserDefaultsKeys.h"
#import "A3PasscodeViewController.h"
#import "A3PasswordViewController.h"
#import "A3AppDelegate.h"
#import "AppBoxKit/AppBoxKit-swift.h"

#define MAS_SHORTHAND
#import "Masonry.h"

NSString *const AdMobAdUnitIDBattery = @"ca-app-pub-0532362805885914/2432956543";
NSString *const AdMobAdUnitIDCalculator = @"ca-app-pub-0532362805885914/2712158144";
NSString *const AdMobAdUnitIDClock = @"ca-app-pub-0532362805885914/2851758945";
NSString *const AdMobAdUnitIDCurrencyList = @"ca-app-pub-0532362805885914/7281958549";
NSString *const AdMobAdUnitIDCurrencyPicker = @"ca-app-pub-0532362805885914/1644430548";
NSString *const AdMobAdUnitIDDateCalc = @"ca-app-pub-0532362805885914/4188891345";
NSString *const AdMobAdUnitIDDaysCounter = @"ca-app-pub-0532362805885914/7002756948";
NSString *const AdMobAdUnitIDExpenseList = @"ca-app-pub-0532362805885914/8479490142";
NSString *const AdMobAdUnitIDFlashlight = @"ca-app-pub-0532362805885914/3909689745";
NSString *const AdMobAdUnitIDHolidays = @"ca-app-pub-0532362805885914/9956223343";
NSString *const AdMobAdUnitIDLadiesCalendar = @"ca-app-pub-0532362805885914/5805225347";
NSString *const AdMobAdUnitIDLunarConverter = @"ca-app-pub-0532362805885914/5526023743";
NSString *const AdMobAdUnitIDMagnifier = @"ca-app-pub-0532362805885914/5386422940";
NSString *const AdMobAdUnitIDMirror = @"ca-app-pub-0532362805885914/6863156141";
NSString *const AdMobAdUnitIDPercentCalc = @"ca-app-pub-0532362805885914/7142357749";
NSString *const AdMobAdUnitIDRandom = @"ca-app-pub-0532362805885914/8339889346";
NSString *const AdMobAdUnitIDRuler = @"ca-app-pub-0532362805885914/9816622546";
NSString *const AdMobAdUnitIDSalesCalc = @"ca-app-pub-0532362805885914/8619090941";
NSString *const AdMobAdUnitIDTipCalc = @"ca-app-pub-0532362805885914/1095824149";
NSString *const AdMobAdUnitIDTranslator = @"ca-app-pub-0532362805885914/1235424945";
NSString *const AdMobAdUnitIDUnitConverter = @"ca-app-pub-0532362805885914/4049290542";
NSString *const AdMobAdUnitIDUnitPrice = @"ca-app-pub-0532362805885914/2572557342";
NSString *const AdMobAdUnitIDWallet = @"ca-app-pub-0532362805885914/4328492143";
NSString *const AdMobAdUnitIDLevel = @"ca-app-pub-0532362805885914/6920738140";
NSString *const AdMobAdUnitIDQRCode = @"ca-app-pub-0532362805885914/7248371747";

static char const *const key_firstActionSheet = "key_firstActionSheet";

@implementation UIViewController (A3Addition)

/*! MainMenuViewController에서 app switch 할 때 popToRootViewController를 한 뒤에, 각 ViewController에 cleanUp을 호출합니다.
 *  이때 removeObserver와 nil을 할당하면 메모리를 효율적으로 제거할 수 있습니다.
 *  개별 viewController 에서 cleanUp을 구현하지 않은 경우, removeObserver 는 기본적으로 실행이 됩니다.
 *  만약 별도 구현한 경우에는 필요한 조치를 개별 구현하던가, [super cleanUp]을 호출해 주면 되겠습니다.
 */

#pragma mark - Common UI methods

- (void)prepareClose {
	[self dismissInstructionViewController:nil];
}

- (void)dismissInstructionViewController:(id)sender {

}

- (CGRect)screenBoundsAdjustedWithOrientation {
    CGRect bounds = [[UIScreen mainScreen] bounds];
	return bounds;
}

- (void)showNavigationBarOn:(UINavigationController *)targetController {
	FNLOG();
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];

	[targetController setNavigationBarHidden:NO animated:YES];
	[targetController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
	[targetController.navigationBar setShadowImage:nil];

	[targetController setToolbarHidden:NO];
	[targetController setNavigationBarHidden:YES animated:NO];

	[targetController setToolbarHidden:YES];
	[targetController setNavigationBarHidden:NO animated:NO];
}

- (void)leftBarButtonAppsButton {
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Apps", @"Apps") style:UIBarButtonItemStylePlain target:self action:@selector(appsButtonAction:)];
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
	UIView *moreMenuView = [[UIToolbar alloc] initWithFrame:frame];
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

- (UIView *)presentMoreMenuWithButtons:(NSArray *)buttons pullDownView:(UIView *)pullDownView {
	UIView *moreMenuView = [self moreMenuViewWithButtons:buttons];
	CGRect clippingViewFrame = moreMenuView.frame;
    
    CGFloat vertifcalOffset = 0;
    UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] myKeyWindow] safeAreaInsets];
    if (safeAreaInsets.top == 59) {
        clippingViewFrame.origin.y = 38.7 + safeAreaInsets.top;
    } else {
        vertifcalOffset = safeAreaInsets.top;
        
        clippingViewFrame.origin.y = 44.0 - 1.0 + vertifcalOffset;
    }
    clippingViewFrame.size.height = clippingViewFrame.size.height + 0.5;//kjh

	UIView *clippingView = [[UIView alloc] initWithFrame:clippingViewFrame];
    FNLOG(@"%@", clippingView.userInteractionEnabled ? @"YES" : @"NO");
    
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

		if ([pullDownView isKindOfClass:[UIScrollView class]]) {
			UIScrollView *scrollView = (UIScrollView *) pullDownView;
			FNLOGINSETS(scrollView.contentInset);
			UIEdgeInsets insets = scrollView.contentInset;
			insets.top += clippingViewFrame.size.height;
			scrollView.contentInset = insets;
			FNLOGINSETS(scrollView.contentInset);

			if (scrollView.contentOffset.y == -64.0) {
				CGPoint offset = scrollView.contentOffset;
				offset.y = -108.0;
				scrollView.contentOffset = offset;
			}
		} else if (pullDownView) {
			CGRect frame = pullDownView.frame;
			frame.origin.y += moreMenuView.bounds.size.height;
			pullDownView.frame = frame;
		}
    } completion:^(BOOL finished) {
        if (![[moreMenuView.subviews lastObject] isKindOfClass:[UIButton class]]) {
            UIView *lastView = [moreMenuView.subviews lastObject];
            lastView.userInteractionEnabled = NO;
        }
    }];

	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moreMenuDismissAction:)];
	[self.view addGestureRecognizer:gestureRecognizer];
	[self.navigationItem.leftBarButtonItem setEnabled:NO];

	return clippingView;
}

- (void)dismissMoreMenuView:(UIView *)moreMenuView pullDownView:(UIView *)pullDownView completion:(void (^)(void))completion {
	UIView *menuView = moreMenuView.subviews[0];
    
	[UIView animateWithDuration:0.3 animations:^{
		CGRect frame = menuView.frame;
		frame = CGRectOffset(frame, 0.0, -44.0);
		menuView.frame = frame;

		if ([pullDownView isKindOfClass:[UIScrollView class]]) {
			UIScrollView *scrollView = (UIScrollView *) pullDownView;
			UIEdgeInsets insets = scrollView.contentInset;
			insets.top -= moreMenuView.frame.size.height;
			scrollView.contentInset = insets;
		} else if (pullDownView) {
			CGRect frame = pullDownView.frame;
			frame.origin.y -= menuView.bounds.size.height;
			pullDownView.frame = frame;
		}
	} completion:^(BOOL finished) {
		[moreMenuView removeFromSuperview];
		[self.navigationItem.leftBarButtonItem setEnabled:YES];
		if (completion) {
			completion();
		}
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
        [button setEnabled:[managedObjectClass countOfEntities] > 0 ];
	}
	return button;
}

- (UIBarButtonItem *)historyBarButton:(Class)managedObjectClass {
	UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"history"] style:UIBarButtonItemStylePlain target:self action:@selector(historyButtonAction:)];
    [barButtonItem setEnabled:[managedObjectClass countOfEntities] > 0 ];
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

- (UIBarButtonItem *)searchBarButtonItem {
    UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchAction:)];
    return search;
}

- (void)searchAction:(id)sender {
    
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
 *  returns void
 */
- (void)makeBackButtonEmptyArrow {
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)makeNavigationBarAppearanceDefault {
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *defaultAppearance = [UINavigationBarAppearance new];
        [defaultAppearance configureWithDefaultBackground];
        self.navigationController.navigationBar.standardAppearance = defaultAppearance;
        self.navigationController.navigationBar.compactAppearance = defaultAppearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = defaultAppearance;
    }
}

- (void)makeNavigationBarAppearanceTransparent {
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *transparentAppearance = [UINavigationBarAppearance new];
        [transparentAppearance configureWithTransparentBackground];
        self.navigationController.navigationBar.standardAppearance = transparentAppearance;
        self.navigationController.navigationBar.compactAppearance = transparentAppearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = transparentAppearance;
    }
}

- (UIPopoverController *)presentActivityViewControllerWithActivityItems:(id)items fromBarButtonItem:(UIBarButtonItem *)barButtonItem completionHandler:(void (^)(void))completionHandler {
	UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
	activityController.completionWithItemsHandler = ^(UIActivityType activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        if (completionHandler) {
            completionHandler();
        }
	};
	if (IS_IPHONE) {
		[self presentViewController:activityController animated:YES completion:NULL];
	} else {
		UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:activityController];
		[popoverController presentPopoverFromBarButtonItem:barButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		return popoverController;
	}
	return nil;
}

- (UIPopoverController *)presentActivityViewControllerWithActivityItems:(id)items fromSubView:(UIView *)subView completionHandler:(UIActivityViewControllerCompletionHandler)completionHandler {
	UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    if (!completionHandler) {
        activityController.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
            FNLOG(@"completed dialog - activity: %@ - finished flag: %d", activityType, completed);
        };
    }
    else {
		activityController.completionWithItemsHandler = ^(UIActivityType activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
			completionHandler(activityType, completed);
		};
    }
    
    
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

- (void)alertInternetConnectionIsNotAvailable {
    [self presentAlertWithTitle:NSLocalizedString(@"Info", @"Info")
                        message:NSLocalizedString(@"Internet connection is not available.", nil)];
}

- (void)willDismissFromRightSide
{

}
- (void)alertCloudNotEnabled {
    [self presentAlertWithTitle:NSLocalizedString(@"iCloud", @"iCloud")
                        message:NSLocalizedString(@"iCloud_goto_settings", @"Please goto Settings of your device. Enable iCloud and Documents and Data storages in your Settings to gain access to this feature.")];
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
	[txt appendFormat:@"<html><body>%@<br/><br/>%@<br/><br/>", header, contents];
	[txt appendFormat:[self shareMessageFormat], tail];
	return txt;
}

/*! [NSString stringWithFormat:] 에서 사용할 수 있는 문자열을 돌려주며, 하나의 파라메터를 허용하는 포맷으로, 파라메터로는 공유할 내용을 전달함
 * \returns None
 */
- (NSString *)shareMessageFormat {
	return [NSString stringWithFormat:@"<br/>%%@<br/>%@", [self commonShareFooter]];
}

- (NSString *)commonShareFooter {
	return [NSString stringWithFormat:@"<img style='border:0;' src='http://apns.allaboutapps.net/allaboutapps/appboxIcon60.png' alt='AppBox Pro'><br/><a href='https://itunes.apple.com/app/id318404385'>%@</a></body></html>",
									  NSLocalizedString(@"Download from AppStore", nil)];
}

- (void)alertLocationDisabled {
	NSString *message = ![CLLocationManager locationServicesEnabled] ? NSLocalizedString(@"Location Services not enabled. Go to Settings > Privacy > Location Services. Location services must enabled and AppBox Pro authorized to show weather.", nil) :
			NSLocalizedString(@"Location services enabled, but AppBox Pro is not authorized to access location services. Go to Settings > Privacy > Location Services and authorize it to show weather.", nil);
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info") message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
	[alertView show];
}

- (UIActionSheet *)firstActionSheet {
	return objc_getAssociatedObject(self, key_firstActionSheet);
}

- (void)setFirstActionSheet:(UIActionSheet *)actionSheet {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    if (actionSheet) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotateFirstActionSheet) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    
	objc_setAssociatedObject(self, key_firstActionSheet, actionSheet, OBJC_ASSOCIATION_ASSIGN);
}

- (void)rotateFirstActionSheet {
    [[self firstActionSheet] dismissWithClickedButtonIndex:[self.firstActionSheet cancelButtonIndex] animated:NO];
}

- (void)requestAuthorizationForCamera:(NSString *)appName afterAuthorizedHandler:(void (^)(BOOL granted))afterAuthorizedHandler {
	AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
	if (authorizationStatus == AVAuthorizationStatusAuthorized) return;
	if (authorizationStatus == AVAuthorizationStatusNotDetermined) {
		[AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:afterAuthorizedHandler];
		return;
	}
	UIAlertController *alertController =
			[UIAlertController alertControllerWithTitle:NSLocalizedString(@"Camera access not authorized.", nil)
												message:[NSString stringWithFormat:NSLocalizedString(@"%@ requires camera access.", nil), appName]
										 preferredStyle:UIAlertControllerStyleAlert];
	[alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
														style:UIAlertActionStyleCancel
													  handler:NULL]];
	[alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(A3AppName_Settings, nil)
														style:UIAlertActionStyleDefault
													  handler:^(UIAlertAction *action) {
														  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                                                                             options:@{UIApplicationOpenURLOptionUniversalLinksOnly:@NO}
                                                                                   completionHandler:NULL];
													  }]];
	[self presentViewController:alertController
					   animated:YES
					 completion:NULL];
}

- (void)requestAuthorizationForPhotoLibrary:(NSString *)appName afterAuthorizationHandler:(void (^)(BOOL granted))afterAuthorizationHandler {
    PHAuthorizationStatus authorizationStatus = [PHPhotoLibrary authorizationStatus];
    if (authorizationStatus == PHAuthorizationStatusAuthorized) return;

    if (authorizationStatus == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (afterAuthorizationHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    afterAuthorizationHandler(status == PHAuthorizationStatusAuthorized);
                });
            }
        }];
    } else {
        UIAlertController *alertController =
				[UIAlertController alertControllerWithTitle:NSLocalizedString(@"Photo Library access not authorized.", nil)
													message:[NSString stringWithFormat:NSLocalizedString(@"%@ requires Photo Library access.", nil), appName]
											 preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
                                                            style:UIAlertActionStyleCancel
                                                          handler:NULL]];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(A3AppName_Settings, nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                                                                                 options:@{UIApplicationOpenURLOptionUniversalLinksOnly:@NO}
                                                                                       completionHandler:NULL];
                                                          }]];
        [self presentViewController:alertController
                           animated:YES
                         completion:NULL];
    }
}

- (UIAlertController *)alertControllerWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          [alertController dismissViewControllerAnimated:YES completion:NULL];
                                                      }]];
    return alertController;
}

- (void)presentAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [self alertControllerWithTitle:title message:message];
    [self.navigationController presentViewController:alertController animated:YES completion:NULL];
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

@end
