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
#import "A3SettingsPasscodeViewController.h"
#import "A3SettingsRequireForViewController.h"
#import "A3AppDelegate.h"
#import "A3SyncManager.h"
#import "UIViewController+extension.h"
#import "A3UIDevice.h"
#import "A3AppDelegate+appearance.h"

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
    [[A3UserDefaults standardUserDefaults] synchronize];
	FNLOG(@"**************************************************************");
	FNLOG(@"%@", [NSDate date]);
	FNLOG(@"**************************************************************");
}

- (BOOL)didPasscodeTimerEnd {
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	FNLOG(@"%f", now - [self timerStartTime]);
    NSTimeInterval timerStartTime = [self timerStartTime];
    if (now - timerStartTime < 0) {
        return YES;
    }
	if (timerStartTime != -1 && (now - timerStartTime < 1.5)) {
		return NO;
	}
	if ((now - [self passcodeFreeBegin]) < 0.2) {
		return NO;
	}
	// startTime wasn't saved yet (first app use and it crashed, phone force closed, etc) if it returns -1.
	if (now - timerStartTime >= [self timerDuration] || timerStartTime == -1) return YES;
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

- (void)showLockScreenWithCompletion:(void (^)(BOOL showLockScreen))completion {
    // Lock screen을 무조건 뛰우고, 암호 검사 루틴을 dispatch_queue에 넣는다.
    // 암호 처리 여부에 따라 Lock을 제거하거나 Cancel버튼을 추가하거나 한다.
    
    dispatch_async(dispatch_get_main_queue(), ^{

        BOOL passwordEnabled = [A3KeychainUtils getPassword] != nil;
        BOOL passcodeTimerEnd = [self didPasscodeTimerEnd];
        
        if (!passwordEnabled || !passcodeTimerEnd) {
            if (completion) {
                completion(NO);
            }
            return;
        }

        BOOL presentLockScreen = [self shouldProtectScreen];
        if (presentLockScreen) {
            [self presentLockScreenShowCancelButton:![[A3UserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForAskPasscodeForStarting]];
        } else {
            [self showReceivedLocalNotifications];
        }
        if (completion) {
            completion(presentLockScreen);
        }
    });

    return;
}

- (void)presentLockScreenShowCancelButton:(BOOL)showCancelButton {
    if (self.appWillResignActive) {
        return;
    }
	if (![self didPasscodeTimerEnd]) {
		return;
	}
	if (self.passcodeViewController.view.superview) {
		[self removeSecurityCoverView];
		return;
	}
	if (self.isTouchIDEvaluationInProgress) return;

	[self prepareStartappBeforeEvaluate];

	void(^presentPasscodeViewControllerBlock)(BOOL showCancelButton) = ^(BOOL showCancelButton){
		self.passcodeViewController = [UIViewController passcodeViewControllerWithDelegate:self];
		
		if (showCancelButton) {
			UINavigationController *navigationController = self.currentMainNavigationController;
			while ([navigationController.presentedViewController isKindOfClass:[UINavigationController class]]) {
				navigationController = (id)navigationController.presentedViewController;
			}
			UIViewController *passcodeParentViewController = navigationController;
			if ([passcodeParentViewController isKindOfClass:[UINavigationController class]]) {
				UIViewController *visibleViewController = ((UINavigationController *)passcodeParentViewController).visibleViewController;
				NSString *className = NSStringFromClass([visibleViewController class]);
				if ([className isEqualToString:@"GADInterstitialViewController"]) {
					passcodeParentViewController = [((UINavigationController *)passcodeParentViewController) visibleViewController];
					FNLOG(@"%@", passcodeParentViewController);
				}
				self.parentOfPasscodeViewController = passcodeParentViewController;
				[self.passcodeViewController showLockScreenInViewController:passcodeParentViewController];
			}
			self.pushClockViewControllerIfFailPasscode = NO;
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
			self.touchIDEvaluationDidFinish = NO;
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
                                      if (success && !error) {
                                          [self saveTimerStartTime];
                                          [self passcodeViewControllerDidDismissWithSuccess:YES];
                                      } else {
                                          presentPasscodeViewControllerBlock(showCancelButton);
                                      }
                                      self.touchIDEvaluationDidFinish = YES;
                                  });
					}];
		} else {
			[self removeSecurityCoverView];
			presentPasscodeViewControllerBlock(showCancelButton);
			self.isTouchIDEvaluationInProgress = NO;
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
    self.firstRunAfterInstall = NO;
    
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
	}
	[self popStartingAppInfo];
}

- (void)applicationDidBecomeActive_passcodeAfterLaunch:(BOOL)isAfterLaunch {
    self.counterPassedDidBecomeActive++;
    FNLOG(@"counterPassedDidBecomeActive=%ld", (long) self.counterPassedDidBecomeActive);
    
    FNLOG();
    
	if (self.isSettingsEvaluatingTouchID) {
		self.isSettingsEvaluatingTouchID = NO;
		return;
	}

	if (self.isTouchIDEvaluationInProgress) {
		if (self.touchIDEvaluationDidFinish) {
			self.isTouchIDEvaluationInProgress = NO;
		}
        self.isTouchIDEvaluationInProgress = NO;
		return;
	}
    
	if (!isAfterLaunch) {
		if ([self didPasscodeTimerEnd] && [self shouldAskPasscodeForStarting]) {
			FNLOG(@"showLockScreen");
            [self showLockScreenWithCompletion:^(BOOL showLockScreen) {
                if (!showLockScreen) {
                    [self finalizeOpening];
                }
            }];
		}
		else
		{
			[self updateStartOption];
			
			if (self.startOptionOpenClockOnce) {
				[self removeSecurityCoverView];
				if ([self isMainMenuStyleList]) {
					[self.mainMenuViewController openClockApp];
				} else {
					[self launchAppNamed:A3AppName_Clock verifyPasscode:NO animated:NO];
					[self updateRecentlyUsedAppsWithAppName:A3AppName_Clock];
					self.homeStyleMainMenuViewController.activeAppName = [A3AppName_Clock copy];
				}
				[self setStartOptionOpenClockOnce:NO];
                [self finalizeOpening];
			} else {
				NSString *startingAppName = [[A3UserDefaults standardUserDefaults] objectForKey:kA3AppsStartingAppName];
				if ([startingAppName length]) {
					if ([self didPasscodeTimerEnd] && [self requirePasscodeForStartingApp]) {
						[self presentLockScreenShowCancelButton:YES];
					} else {
						[self removeSecurityCoverView];
						if ([self isMainMenuStyleList]) {
							[self.mainMenuViewController openRecentlyUsedMenu:NO];
						} else {
							[self launchAppNamed:startingAppName verifyPasscode:NO animated:NO];
							self.homeStyleMainMenuViewController.activeAppName = [startingAppName copy];
						}
						[self popStartingAppInfo];
					}
                    [self finalizeOpening];
				} else {
					[self popStartingAppInfo];
                    [self showLockScreenWithCompletion:^(BOOL showLockScreen) {
                        if (!showLockScreen) {
                            if ([self isMainMenuStyleList]) {
                                if (![self.mainMenuViewController openRecentlyUsedMenu:YES]) {
                                    [self.mainMenuViewController openClockApp];
                                }
                            }
                            [self finalizeOpening];
                        }
                    }];
				}
			}
		}
	} else {
		if (self.shouldMigrateV1Data) {
			self.migrationIsInProgress = YES;
			A3DataMigrationManager *migrationManager = [A3DataMigrationManager new];
			self.migrationManager = migrationManager;
			migrationManager.delegate = self;
			if ([migrationManager walletDataFileExists] && ![migrationManager walletDataWithPassword:nil]) {
				[migrationManager askWalletPassword];
			} else {
				[migrationManager migrateV1DataWithPassword:nil];
			}
			return;
		} else {
            if (!self.firstRunAfterInstall && ![self shouldPresentWhatsNew]) {
                [self presentInterstitialAds];
            }
            [self updateHolidayNations];
		}
	}
}

- (void)finalizeOpening {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.isTouchIDEvaluationInProgress && !self.passcodeViewController.view.superview) {
            [self removeSecurityCoverView];
            if (!self.firstRunAfterInstall && ![self shouldPresentWhatsNew]) {
                [self presentInterstitialAds];
            }
            FNLOG(@"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        } else {
            FNLOG(@"isTouchIDEvaluationInProgress = %ld", (long)self.isTouchIDEvaluationInProgress);
            FNLOG(@"%@", self.parentOfPasscodeViewController);
        }
    });
}

- (void)migrationManager:(A3DataMigrationManager *)manager didFinishMigration:(BOOL)success {
	self.shouldMigrateV1Data = NO;
	self.migrationManager = nil;
	
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kA3ApplicationLastRunVersion];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	self.migrationIsInProgress = NO;
	
	[self passcodeViewControllerDidDismissWithSuccess:YES];
}

- (void)applicationWillEnterForeground_passcode {
    FNLOG();
}

- (void)applicationWillResignActive_passcode {
    FNLOG();
    
	UIViewController *visibleViewController = [self.currentMainNavigationController visibleViewController];
//    if ([visibleViewController isKindOfClass:[A3PasscodeViewController class]]) {
//        [visibleViewController dismissViewControllerAnimated:NO completion:^{
//
//        }];
//    } else {
//        [visibleViewController resignFirstResponder];
//    }
    if ([self shouldProtectScreen]) {
        FNLOG(@"CoverView added to Window");
        [[UIApplication sharedApplication] ignoreSnapshotOnNextApplicationLaunch];
        
        [self addSecurityCoverView];
    }
	return;
}

- (void)addSecurityCoverView {
	FNLOG(@"Cover ADDED!");
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
#ifdef DEBUG
    NSArray *symbols = [NSThread callStackSymbols];
    for (NSString *symbol in symbols) {
        NSLog(@"%@", symbol);
    }
#endif

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
	[self updateStartOption];

	if (self.startOptionOpenClockOnce) {
		[self removeSecurityCoverView];
		
		if ([self isMainMenuStyleList]) {
			[self.mainMenuViewController openClockApp];
		} else {
			[self launchAppNamed:A3AppName_Clock verifyPasscode:NO animated:NO];
			[self updateRecentlyUsedAppsWithAppName:A3AppName_Clock];
			self.homeStyleMainMenuViewController.activeAppName = [A3AppName_Clock copy];
		}
		[self setStartOptionOpenClockOnce:NO];
        [self askPersonalizedAdConsent];

        return;
	}

	if (!success) {
		[self addSecurityCoverView];
		
		UIViewController *presentedViewController = self.currentMainNavigationController.presentedViewController;
		if ([presentedViewController isKindOfClass:[UINavigationController class]]) {
			UIViewController *viewController = ((UINavigationController *)presentedViewController).viewControllers[0];
			if (![viewController isKindOfClass:[A3PasscodeCommonViewController class]]) {
				[self.currentMainNavigationController dismissViewControllerAnimated:NO completion:nil];
			}
		}
		if ([self isMainMenuStyleList]) {
			if (IS_IPHONE) {
				[self.drawerController openDrawerSide:MMDrawerSideLeft animated:NO completion:nil];
				if ([self.currentMainNavigationController.viewControllers count] > 1) {
					UIViewController *appViewController = self.currentMainNavigationController.viewControllers[1];
					[self.currentMainNavigationController popToRootViewControllerAnimated:NO];
					[appViewController appsButtonAction:nil];
				}
			} else {
				[self.mainMenuViewController openClockApp];
				[self.rootViewController_iPad setShowLeftView:YES];
			}
			[self removeSecurityCoverView];
		} else {
			if ([self.currentMainNavigationController.viewControllers count] > 1) {
				UIViewController *appViewController = self.currentMainNavigationController.viewControllers[1];
				if (IS_IPAD) {
					[self.rootViewController_iPad dismissRightSideViewController];
				}
				[self.currentMainNavigationController popToRootViewControllerAnimated:NO];
				[appViewController appsButtonAction:nil];
			}
			double delayInSeconds = 0.3;
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				[self.currentMainNavigationController setNavigationBarHidden:YES];
				UIImage *image = [UIImage new];
				[self.currentMainNavigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
				[self.currentMainNavigationController.navigationBar setShadowImage:image];
				[self.currentMainNavigationController setToolbarHidden:YES];
				[self removeSecurityCoverView];
			});
		}
		[self askPersonalizedAdConsent];
		return;
	}

	[self removeSecurityCoverView];

	if ([self isMainMenuStyleList]) {
		if ([self.mainMenuViewController.selectedAppName length]) {
			[self.mainMenuViewController openAppNamed:self.mainMenuViewController.selectedAppName];
			self.mainMenuViewController.selectedAppName = nil;
		} else {
			if (![self.mainMenuViewController openRecentlyUsedMenu:NO]) {
				[self.mainMenuViewController openClockApp];
			} else {
				[self.currentMainNavigationController.topViewController viewWillAppear:YES];
				[self.currentMainNavigationController.topViewController viewDidAppear:YES];
			}
		}
	} else {
		NSString *selectedAppName = self.homeStyleMainMenuViewController.selectedAppName;
		if ([selectedAppName length]) {
			if (![self.homeStyleMainMenuViewController.activeAppName isEqualToString:selectedAppName]) {
				[self launchAppNamed:selectedAppName verifyPasscode:NO animated:NO];
				self.homeStyleMainMenuViewController.activeAppName = [selectedAppName copy];
				self.homeStyleMainMenuViewController.selectedAppName = nil;
			} else {
				[self.currentMainNavigationController.topViewController viewWillAppear:YES];
				[self.currentMainNavigationController.topViewController viewDidAppear:YES];
			}
		} else {
			[self.currentMainNavigationController.topViewController viewWillAppear:YES];
			[self.currentMainNavigationController.topViewController viewDidAppear:YES];
		}
	}
	// 전체광고가 떠 있는 상황에서 앱이 닫혔다가 다시 들어온 경우, StatusBar를 숨겨주어야 합니다.
	UINavigationController *navigationController = self.currentMainNavigationController;
	while ([navigationController.presentedViewController isKindOfClass:[UINavigationController class]]) {
		navigationController = (id)navigationController.presentedViewController;
	}
	UIViewController *visibleViewController = navigationController.visibleViewController;
	NSString *className = NSStringFromClass([visibleViewController class]);
	if ([className isEqualToString:@"GADInterstitialViewController"]) {
		[[UIApplication sharedApplication] setStatusBarHidden:YES];
	}
	
	if ([self.currentMainNavigationController.viewControllers count] == 1) {
		[self reloadRootViewController];
	}
	[self showReceivedLocalNotifications];
    if (!self.firstRunAfterInstall && ![self shouldPresentWhatsNew]) {
        [self presentInterstitialAds];
    }
	[self alertWhatsNew];
}

- (void)passcodeViewDidDisappearWithSuccess:(BOOL)success {
	FNLOG();
	self.passcodeViewController = nil;
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
	[[A3UserDefaults standardUserDefaults] setBool:NO forKey:kUserDefaultsKeyForAskPasscodeForStarting];
	[[A3UserDefaults standardUserDefaults] setBool:NO forKey:kUserDefaultsKeyForAskPasscodeForDaysCounter];
	[[A3UserDefaults standardUserDefaults] setBool:NO forKey:kUserDefaultsKeyForAskPasscodeForLadyCalendar];
	[[A3UserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultsKeyForAskPasscodeForWallet];
	[[A3UserDefaults standardUserDefaults] synchronize];
}

- (BOOL)shouldAskPasscodeForSettings {
    if (![A3KeychainUtils getPassword]) return NO;
	
    // 암호가 설정되어 있다면 설정 화면 진입 시, 내부에서든, 외부에서든 암호를 확인하여야 한다.
	return YES;
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
