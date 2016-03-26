//
//  A3AppDelegate+passcode.m
//  AppBox3
//
//  Created by A3 on 12/25/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <LocalAuthentication/LocalAuthentication.h>
#import "A3AppDelegate+passcode.h"
#import "A3PasscodeViewController.h"
#import "A3KeychainUtils.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+MMDrawerController.h"
#import "A3SettingsViewController.h"
#import "A3DaysCounterSlideShowMainViewController.h"
#import "A3DaysCounterCalendarListMainViewController.h"
#import "A3DaysCounterReminderListViewController.h"
#import "A3DaysCounterFavoriteListViewController.h"
#import "A3LadyCalendarViewController.h"
#import "A3WalletMainTabBarController.h"
#import "A3UserDefaults.h"
#import "A3MainMenuTableViewController.h"
#import "A3HomeStyleMenuViewController.h"

@implementation A3AppDelegate (passcode)

- (double)timerDuration {
	return [[A3UserDefaults standardUserDefaults] doubleForKey:kUserDefaultsKeyForPasscodeTimerDuration];
}

- (NSTimeInterval)timerStartTime {
	NSDate *date = [[A3UserDefaults standardUserDefaults] objectForKey:kUserDefaultTimerStart];
	if (!date) return -1;
	return [date timeIntervalSinceReferenceDate];
}

- (void)saveTimerStartTime {
	[[A3UserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kUserDefaultTimerStart];
	FNLOG(@"**************************************************************");
	FNLOG(@"%@", [NSDate date]);
	FNLOG(@"**************************************************************");
}

- (BOOL)didPasscodeTimerEnd {
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	FNLOG(@"%f", now - [self timerStartTime]);
	if ([self timerStartTime] != -1 && (now - [self timerStartTime] < 1.0)) {
		return NO;
	}
	if ((now - [self passcodeFreeBegin]) < 0.2) {
		return NO;
	}
	// startTime wasn't saved yet (first app use and it crashed, phone force closed, etc) if it returns -1.
	if (now - [self timerStartTime] >= [self timerDuration] || [self timerStartTime] == -1) return YES;
	return NO;
}

- (BOOL)isSimplePasscode {
	NSNumber *obj = [[A3UserDefaults standardUserDefaults] objectForKey:kUserDefaultsKeyForUseSimplePasscode];
	if (obj) {
		return [obj boolValue];
	}
	return NO;
}

- (BOOL)useTouchID {
	if (IS_IOS7) return NO;

	LAContext *context = [LAContext new];
	NSError *error;
	if (![context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
		return NO;
	}
	NSNumber *object = [[A3UserDefaults standardUserDefaults] objectForKey:kUserDefaultsKeyForUseTouchID];
	if (object) {
		return [object boolValue];
	}
	return YES;
}

- (void)setUseTouchID:(BOOL)use {
	[[A3UserDefaults standardUserDefaults] setBool:use forKey:kUserDefaultsKeyForUseTouchID];
	[[A3UserDefaults standardUserDefaults] synchronize];
}

- (BOOL)showLockScreen {
	BOOL passwordEnabled = [A3KeychainUtils getPassword] != nil;
	BOOL passcodeTimerEnd = [self didPasscodeTimerEnd];

	if (!passwordEnabled || !passcodeTimerEnd) return NO;

	BOOL presentLockScreen = [self shouldProtectScreen];
	if (presentLockScreen) {
        [self presentLockScreen:self showCancelButton:![[A3UserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForAskPasscodeForStarting]];
        return YES;
	} else {
		[self showReceivedLocalNotifications];
	}
    return NO;
}

- (void)presentLockScreen:(id <A3PasscodeViewControllerDelegate>)delegate showCancelButton:(BOOL)showCancelButton {
	if (![self didPasscodeTimerEnd]) {
		return;
	}
	if (self.passcodeViewController || self.isTouchIDEvaluationInProgress) return;

	if (delegate != self) {
		self.otherPasscodeDelegate = delegate;
	}
	[self prepareStartappBeforeEvaluate];

	void(^presentPasscodeViewControllerBlock)(BOOL showCancelButton) = ^(BOOL showCancelButton){
		self.passcodeViewController = [UIViewController passcodeViewControllerWithDelegate:self];
		if (showCancelButton) {
			UIViewController *passcodeParentViewController = [self.navigationController topViewController];
			NSString *className = NSStringFromClass([passcodeParentViewController class]);
			if ([className isEqualToString:@"GADInterstitialViewController"]) {
				passcodeParentViewController = [self.currentMainNavigationController topViewController];
				FNLOG(@"%@", passcodeParentViewController);
			}
			self.parentOfPasscodeViewController = passcodeParentViewController;
			[self.passcodeViewController showLockScreenInViewController:passcodeParentViewController];
			self.pushClockViewControllerIfFailPasscode = YES;
		} else {
			[self.passcodeViewController showLockScreenWithAnimation:NO showCacelButton:showCancelButton];
		}
		double delayInSeconds = 1.0;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			[self removeSecurityCoverView];
		});
	};
	if (IS_IOS7 || ![self useTouchID]) {
		presentPasscodeViewControllerBlock(showCancelButton);
	} else {
		LAContext *context = [LAContext new];
		NSError *error;
		if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
			[self addSecurityCoverView];

			self.isTouchIDEvaluationInProgress = YES;
			[[UIApplication sharedApplication] setStatusBarHidden:YES];
			[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

			self.touchIDBackgroundViewController = [UIViewController new];
			[self.rootViewController_iPad presentViewController:self.touchIDBackgroundViewController animated:NO completion:NULL];

			[context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
					localizedReason:NSLocalizedString(@"Unlock AppBox Pro", @"Unlock AppBox Pro")
							  reply:^(BOOL success, NSError *error) {
						dispatch_async(dispatch_get_main_queue(), ^{
							[[UIApplication sharedApplication] setStatusBarHidden:NO];
							[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
							[self.touchIDBackgroundViewController dismissViewControllerAnimated:NO completion:NULL];
							if (success) {
								[self saveTimerStartTime];
								[self passcodeViewControllerDidDismissWithSuccess:YES];
							} else {
								presentPasscodeViewControllerBlock(showCancelButton);
							}
						});
					}];
		} else {
			[self removeSecurityCoverView];
			presentPasscodeViewControllerBlock(showCancelButton);
		}
	}
}

- (BOOL)shouldProtectScreen {
	if ([A3KeychainUtils getPassword] == nil) return NO;

	BOOL presentLockScreen = NO;
	BOOL shouldAskForStarting = [[A3UserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForAskPasscodeForStarting];
	if (shouldAskForStarting) {
		presentLockScreen = YES;
	} else {
		if ([self requirePasscodeForStartingApp]) return YES;

		NSString *activeAppName;
		if ([self isMainMenuStyleList]) {
			activeAppName = self.mainMenuViewController.activeAppName;
		} else {
			activeAppName = self.homeStyleMainMenuViewController.activeAppName;
		}

		if ([activeAppName isEqualToString:A3AppName_Settings]) {
			presentLockScreen = [self shouldAskPasscodeForSettings];
		}
		else if ([activeAppName isEqualToString:A3AppName_DaysCounter])
		{
			presentLockScreen = [self shouldAskPasscodeForDaysCounter];
		}
		else if ([activeAppName isEqualToString:A3AppName_LadiesCalendar]) {
			presentLockScreen = [self shouldAskPasscodeForLadyCalendar];
		}
		else if ([activeAppName isEqualToString:A3AppName_Wallet]) {
			presentLockScreen = [self shouldAskPasscodeForWallet];
		}
	}
	return presentLockScreen;
}

#pragma mark - Notification Observers

- (void)applicationDidEnterBackground_passcode {
	if (IS_IPHONE) {
		[self.drawerController closeDrawerAnimated:NO completion:nil];
	} else {
		if (IS_PORTRAIT && self.rootViewController_iPad.showLeftView) {
			[self.rootViewController_iPad toggleLeftMenuViewOnOff];
		}
	}
}

- (void)prepareStartappBeforeEvaluate {
	NSString *startingAppName = [[A3UserDefaults standardUserDefaults] objectForKey:kA3AppsStartingAppName];
	if ([startingAppName length]) {
		if ([self isMainMenuStyleList]) {
			self.mainMenuViewController.selectedAppName = [startingAppName copy];
		} else {
			self.homeStyleMainMenuViewController.selectedAppName = [startingAppName copy];
		}
		self.otherPasscodeDelegate = nil;
	}
	[self popStartingAppInfo];
}

- (void)applicationDidBecomeActive_passcodeAfterLaunch:(BOOL)isAfterLaunch {
	if (self.isSettingsEvaluatingTouchID) {
		self.isSettingsEvaluatingTouchID = NO;
		return;
	}

	if (self.isTouchIDEvaluationInProgress) {
		self.isTouchIDEvaluationInProgress = NO;
		return;
	}
	if (!isAfterLaunch) {
		if ([self didPasscodeTimerEnd] && [self shouldAskPasscodeForStarting]) {
			FNLOG(@"showLockScreen");
			[self showLockScreen];
		}
		else
		{
			[self updateStartOption];
			
			if (self.startOptionOpenClockOnce) {
				[self removeSecurityCoverView];
				if ([self isMainMenuStyleList]) {
					[self.mainMenuViewController openClockApp];
				} else {
					[self launchAppNamed:A3AppName_Clock verifyPasscode:NO delegate:nil animated:NO];
					[self updateRecentlyUsedAppsWithAppName:A3AppName_Clock];
					self.homeStyleMainMenuViewController.activeAppName = [A3AppName_Clock copy];
				}
				[self setStartOptionOpenClockOnce:NO];
			} else {
				NSString *startingAppName = [[A3UserDefaults standardUserDefaults] objectForKey:kA3AppsStartingAppName];
				if ([startingAppName length]) {
					if ([self didPasscodeTimerEnd] && [self requirePasscodeForStartingApp]) {
						[self presentLockScreen:self showCancelButton:YES];
					} else {
						[self popStartingAppInfo];
						[self removeSecurityCoverView];
						if ([self isMainMenuStyleList]) {
							[self.mainMenuViewController openRecentlyUsedMenu:NO];
						} else {
							[self launchAppNamed:startingAppName verifyPasscode:NO delegate:nil animated:NO];
							self.homeStyleMainMenuViewController.activeAppName = [startingAppName copy];
						}
					}
				} else {
					[self popStartingAppInfo];
					if (![self showLockScreen]) {
						if ([self isMainMenuStyleList]) {
							if (![self.mainMenuViewController openRecentlyUsedMenu:YES]) {
								[self.mainMenuViewController openClockApp];
							}
						}
					}
				}
			}
		}
	}
	dispatch_async(dispatch_get_main_queue(), ^{
		if (!self.isTouchIDEvaluationInProgress && self.passcodeViewController == nil && self.mainMenuViewController.passcodeViewController == nil) {
			[self removeSecurityCoverView];
			[self presentInterstitialAds];
			FNLOG(@"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
		}
	});
}

- (void)applicationWillEnterForeground_passcode {
}

- (void)applicationWillResignActive_passcode {
	if ([self shouldProtectScreen]) {
		FNLOG(@"CoverView added to Window");
		[[UIApplication sharedApplication] ignoreSnapshotOnNextApplicationLaunch];

		[self addSecurityCoverView];
	}
	UIViewController *visibleViewController = [self.currentMainNavigationController visibleViewController];
	[visibleViewController resignFirstResponder];
	return;
}

- (void)addSecurityCoverView {
	// 암호 대화 상자가 열려 있다면 커버를 추가하지 않는다.
	if (self.passcodeViewController || self.isTouchIDEvaluationInProgress) return;

	if (self.coverView.superview) {
		[self.coverView removeFromSuperview];
		self.coverView = nil;
	}
	CGRect screenBounds = [[UIScreen mainScreen] bounds];
	if (IS_IPHONE && IS_LANDSCAPE && IS_IOS7) {
		CGFloat height = screenBounds.size.height;
		screenBounds.size.height = screenBounds.size.width;
		screenBounds.size.width = height;
	}
	self.coverView = [[UIImageView alloc] initWithFrame:screenBounds];
	self.coverView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.coverView.image = [UIImage imageNamed:[self getLaunchImageName]];
	[self.window addSubview:self.coverView];

	if (IS_IPHONE && IS_LANDSCAPE) {
		CGFloat angle;
		switch ([[UIApplication sharedApplication] statusBarOrientation]) {
			case UIInterfaceOrientationPortraitUpsideDown:
				angle = M_PI;
				break;
			case UIInterfaceOrientationLandscapeLeft:
				angle = M_PI_2;
				break;
			case UIInterfaceOrientationLandscapeRight:
				angle = -M_PI_2;
				break;
			default:
				angle = 0;
		}
		self.coverView.transform = CGAffineTransformMakeRotation(angle);
		self.coverView.frame = screenBounds;
		FNLOGRECT(self.coverView.frame);
	}

	if (IS_IPAD && IS_IOS7) {
		[self rotateAccordingToStatusBarOrientationAndSupportedOrientations];

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(statusBarFrameOrOrientationChanged:)
													 name:UIApplicationDidChangeStatusBarOrientationNotification
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameOrOrientationChanged:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
	}
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder {
	return NO;
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder {
	NSNumber *flag = [[A3UserDefaults standardUserDefaults] objectForKey:kUserDefaultsKeyForAskPasscodeForStarting];

	if ([flag boolValue] && [A3KeychainUtils getPassword]) {
		[application ignoreSnapshotOnNextApplicationLaunch];
	}
	return NO;
}

- (void)removeSecurityCoverView {
	FNLOG();
	if (self.coverView) {
		[self.coverView removeFromSuperview];
		self.coverView = nil;

		[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
	}
}

#pragma mark - A3PasscodeViewControllerDelegate
/**
 *  Home Screen에서 앱이 열릴때, 암호 확인 후 호출이 된다.
 *  Default App 설정이 있는 경우에 Default App을 실행해야 한다.
 *
 *  @param success 암호 확인이 성공했는지 여부를 알려준다.
 */
- (void)passcodeViewControllerDidDismissWithSuccess:(BOOL)success {
	[self removeSecurityCoverView];
	
	if (self.otherPasscodeDelegate) {
		id <A3PasscodeViewControllerDelegate> o = self.otherPasscodeDelegate;
		if ([o respondsToSelector:@selector(passcodeViewControllerDidDismissWithSuccess:)]) {
			[o passcodeViewControllerDidDismissWithSuccess:success];
		}
		return;
	}

	[self updateStartOption];

	if (self.startOptionOpenClockOnce) {
		if ([self isMainMenuStyleList]) {
			[self.mainMenuViewController openClockApp];
		} else {
			[self launchAppNamed:A3AppName_Clock verifyPasscode:NO delegate:nil animated:NO];
			[self updateRecentlyUsedAppsWithAppName:A3AppName_Clock];
			self.homeStyleMainMenuViewController.activeAppName = [A3AppName_Clock copy];
		}
		[self setStartOptionOpenClockOnce:NO];
		return;
	}

	if (!success) {
		if ([self isMainMenuStyleList]) {
			[self.mainMenuViewController openClockApp];
			double delayInSeconds = 0.3;
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				if (IS_IPHONE) {
					[self.drawerController openDrawerSide:MMDrawerSideLeft animated:NO completion:nil];
				} else {
					[self.rootViewController_iPad setShowLeftView:NO];
				}
			});

		} else {
			if ([self.currentMainNavigationController.viewControllers count] > 1) {
				UIViewController *appViewController = self.currentMainNavigationController.viewControllers[1];
				[self.currentMainNavigationController popViewControllerAnimated:NO];
				[appViewController appsButtonAction:nil];
				
				double delayInSeconds = 0.1;
				dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
				dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
					[self.currentMainNavigationController setNavigationBarHidden:YES];
					UIImage *image = [UIImage new];
					[self.currentMainNavigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
					[self.currentMainNavigationController.navigationBar setShadowImage:image];
				});
			}
		}
		return;
	}
	// 이곳은 확인 후 성공/실패시 처리를 하는 곳
	// 선택된 app이 없다면, 커버 만 제거하면 된다.
	// 리스트 방식인 경우에는 현재 Active 앱이 없는 경우, Clock을 실행한다.

	if ([self isMainMenuStyleList]) {
		if ([self.mainMenuViewController.selectedAppName length]) {
			[self.mainMenuViewController openAppNamed:self.mainMenuViewController.selectedAppName];
			self.mainMenuViewController.selectedAppName = nil;
		} else {
			if (![self.mainMenuViewController openRecentlyUsedMenu:NO]) {
				[self.mainMenuViewController openClockApp];
			}
		}
	} else {
		NSString *selectedAppName = self.homeStyleMainMenuViewController.selectedAppName;
		if ([selectedAppName length]) {
			if (![self.homeStyleMainMenuViewController.activeAppName isEqualToString:selectedAppName]) {
				[self launchAppNamed:selectedAppName verifyPasscode:NO delegate:nil animated:YES];
				self.homeStyleMainMenuViewController.activeAppName = [selectedAppName copy];
				self.homeStyleMainMenuViewController.selectedAppName = nil;
			} else {
				[self.navigationController.topViewController viewDidAppear:NO];
			}
		}
	}
	if ([self.currentMainNavigationController.viewControllers count] > 1) {
		[self.currentMainNavigationController.topViewController viewDidAppear:NO];
	} else {
		[self reloadRootViewController];
	}
	[self showReceivedLocalNotifications];
	[self presentInterstitialAds];
}

- (void)passcodeViewDidDisappearWithSuccess:(BOOL)success {
	FNLOG();
	self.passcodeViewController = nil;
	id <A3PasscodeViewControllerDelegate> otherPasscodeDelegate = self.otherPasscodeDelegate;
	if (otherPasscodeDelegate && [otherPasscodeDelegate respondsToSelector:@selector(passcodeViewDidDisappearWithSuccess:)]) {
		[otherPasscodeDelegate passcodeViewDidDisappearWithSuccess:success];
	}
	self.otherPasscodeDelegate = nil;
}

- (BOOL)requirePasscodeForStartingApp {
    BOOL requirePasscodeForStartingApp = NO;
    NSArray *appsRequirePasscode = @[A3AppName_Settings, A3AppName_DaysCounter, A3AppName_LadiesCalendar, A3AppName_Wallet];
    NSString *startingAppName = [[A3UserDefaults standardUserDefaults] objectForKey:kA3AppsStartingAppName];
	if (![startingAppName length]) return NO;
    NSInteger idx = [appsRequirePasscode indexOfObject:startingAppName];
    if (idx != NSNotFound) {
        switch (idx) {
            case 0:
                if ([self shouldAskPasscodeForSettings]) requirePasscodeForStartingApp = YES;
                break;
            case 1:
                if ([self shouldAskPasscodeForDaysCounter]) requirePasscodeForStartingApp = YES;
                break;
            case 2:
                if ([self shouldAskPasscodeForLadyCalendar]) requirePasscodeForStartingApp = YES;
                break;
            case 3:
                if ([self shouldAskPasscodeForWallet]) requirePasscodeForStartingApp = YES;
                break;
        }
    }
    return requirePasscodeForStartingApp;
}

- (BOOL)shouldAskPasscodeForStarting {
    if (![A3KeychainUtils getPassword]) return NO;

	if (![self didPasscodeTimerEnd]) return NO;

	NSNumber *number = [[A3UserDefaults standardUserDefaults] objectForKey:kUserDefaultsKeyForAskPasscodeForStarting];
	if (number) {
		FNLOG("처음 시작 시 암호 물어보기 확인 됨");
		return [number boolValue];
	} else {
		// Initialize Value with NO
		[[A3UserDefaults standardUserDefaults] setBool:NO forKey:kUserDefaultsKeyForAskPasscodeForStarting];
		[[A3UserDefaults standardUserDefaults] synchronize];
		return NO;
	}
}

- (void)setEnableAskPasscodeForStarting:(BOOL)enable {
	[[A3UserDefaults standardUserDefaults] setBool:enable forKey:kUserDefaultsKeyForAskPasscodeForStarting];
	[[A3UserDefaults standardUserDefaults] synchronize];
}

- (void)initializePasscodeUserDefaults {
    [[A3UserDefaults standardUserDefaults] setBool:NO forKey:kUserDefaultsKeyForUseSimplePasscode];
	[[A3UserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultsKeyForAskPasscodeForStarting];
	[[A3UserDefaults standardUserDefaults] setBool:NO forKey:kUserDefaultsKeyForAskPasscodeForSettings];
	[[A3UserDefaults standardUserDefaults] setBool:NO forKey:kUserDefaultsKeyForAskPasscodeForDaysCounter];
	[[A3UserDefaults standardUserDefaults] setBool:NO forKey:kUserDefaultsKeyForAskPasscodeForLadyCalendar];
	[[A3UserDefaults standardUserDefaults] setBool:NO forKey:kUserDefaultsKeyForAskPasscodeForWallet];
	[[A3UserDefaults standardUserDefaults] synchronize];
}

- (BOOL)shouldAskPasscodeForSettings {
    if (![A3KeychainUtils getPassword]) return NO;
	return [[A3UserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForAskPasscodeForSettings];
}

- (BOOL)shouldAskPasscodeForDaysCounter {
    if (![A3KeychainUtils getPassword]) return NO;
	return [[A3UserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForAskPasscodeForDaysCounter];
}

- (BOOL)shouldAskPasscodeForLadyCalendar {
    if (![A3KeychainUtils getPassword]) return NO;
	return [[A3UserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForAskPasscodeForLadyCalendar];
}

- (BOOL)shouldAskPasscodeForWallet {
    if (![A3KeychainUtils getPassword]) return NO;
	return [[A3UserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForAskPasscodeForWallet];
}

#pragma mark - Security Cover View orientation change handling

- (NSUInteger)supportedInterfaceOrientations {
	if (IS_IPHONE) {
		return UIInterfaceOrientationMaskPortrait;
	} else {
		return UIInterfaceOrientationMaskAll;
	}
}

- (void)statusBarFrameOrOrientationChanged:(NSNotification *)notification {
	/*
	 This notification is most likely triggered inside an animation block,
	 therefore no animation is needed to perform this nice transition.
	 */
	[self rotateAccordingToStatusBarOrientationAndSupportedOrientations];
}

// And to his AGWindowView: https://github.com/hfossli/AGWindowView
// Without the 'desiredOrientation' method, using showLockscreen in one orientation,
// then presenting it inside a modal in another orientation would display the view in the first orientation.
- (UIInterfaceOrientation)desiredOrientation {
	UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
	UIInterfaceOrientationMask statusBarOrientationAsMask = UIInterfaceOrientationMaskFromOrientation(statusBarOrientation);
	if(self.supportedInterfaceOrientations & statusBarOrientationAsMask) {
		return statusBarOrientation;
	}
	else {
		if(self.supportedInterfaceOrientations & UIInterfaceOrientationMaskPortrait) {
			return UIInterfaceOrientationPortrait;
		}
		else if(self.supportedInterfaceOrientations & UIInterfaceOrientationMaskLandscapeLeft) {
			return UIInterfaceOrientationLandscapeLeft;
		}
		else if(self.supportedInterfaceOrientations & UIInterfaceOrientationMaskLandscapeRight) {
			return UIInterfaceOrientationLandscapeRight;
		}
		else {
			return UIInterfaceOrientationPortraitUpsideDown;
		}
	}
}

- (void)rotateAccordingToStatusBarOrientationAndSupportedOrientations {
	UIInterfaceOrientation orientation = [self desiredOrientation];
	CGFloat angle = UIInterfaceOrientationAngleOfOrientation(orientation);
	CGAffineTransform transform = CGAffineTransformMakeRotation(angle);

	[self setIfNotEqualTransform: transform
						   frame: self.coverView.window.bounds];
}


- (void)setIfNotEqualTransform:(CGAffineTransform)transform frame:(CGRect)frame {
	if(!CGAffineTransformEqualToTransform(self.coverView.transform, transform)) {
		self.coverView.transform = transform;
	}
	if(!CGRectEqualToRect(self.coverView.frame, frame)) {
		self.coverView.frame = frame;
	}
}


CGFloat UIInterfaceOrientationAngleOfOrientation(UIInterfaceOrientation orientation) {
	CGFloat angle;

	switch (orientation) {
		case UIInterfaceOrientationPortraitUpsideDown:
			angle = M_PI;
			break;
		case UIInterfaceOrientationLandscapeLeft:
			angle = -M_PI_2;
			break;
		case UIInterfaceOrientationLandscapeRight:
			angle = M_PI_2;
			break;
		default:
			angle = 0.0;
			break;
	}

	return angle;
}

UIInterfaceOrientationMask UIInterfaceOrientationMaskFromOrientation(UIInterfaceOrientation orientation) {
	return 1 << orientation;
}

@end
