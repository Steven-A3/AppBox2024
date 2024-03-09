//
//  A3LaunchViewController.m
//  AppBox3
//
//  Created by A3 on 3/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <LocalAuthentication/LocalAuthentication.h>
#import "A3LaunchViewController.h"
#import "A3ClockMainViewController.h"
#import "A3LaunchSceneViewController.h"
#import "A3AppDelegate.h"
#import "UIViewController+A3Addition.h"
#import "A3SyncManager.h"
#import "A3MainMenuTableViewController.h"
#import "A3UserDefaults.h"
#import "A3KeychainUtils.h"
#import "MMDrawerController.h"
#import "A3UIDevice.h"
#import "A3AppDelegate+appearance.h"
#import "AppBox3-swift.h"

NSString *const A3UserDefaultsDidShowLeftViewOnceiPad = @"A3UserDefaultsDidShowLeftViewOnceiPad";

@interface A3LaunchViewController () <UIViewControllerTransitioningDelegate,
		UIAlertViewDelegate>

@property (nonatomic, strong) UIStoryboard *launchStoryboard;
@property (nonatomic, strong) A3LaunchSceneViewController *currentSceneViewController;

@end

@implementation A3LaunchViewController {
	NSUInteger _sceneNumber;
	BOOL _cloudButtonUsed;
}

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

	[self.navigationController setNavigationBarHidden:YES];
	UIImage *image = [UIImage new];
	[self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
	[self.navigationController.navigationBar setShadowImage:image];

	UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	backgroundImageView.image = [UIImage imageNamed:[[A3AppDelegate instance] getLaunchImageNameForOrientation:[UIWindow interfaceOrientationIsPortrait]]];
	[self.view addSubview:backgroundImageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	A3AppDelegate *appDelegate = [A3AppDelegate instance];
	if ([A3AppDelegate instance].isChangingRootViewController) {
		[A3AppDelegate instance].isChangingRootViewController = NO;
		if ([[A3AppDelegate instance] isMainMenuStyleList]) {
			if (IS_IPHONE) {
				[appDelegate.drawerController openDrawerSide:MMDrawerSideLeft animated:NO completion:nil];
			} else {
				if (![appDelegate.mainMenuViewController openRecentlyUsedMenu:YES]) {
					[appDelegate.mainMenuViewController openClockApp];
				}
				[appDelegate.rootViewController_iPad setShowLeftView:YES];
			}
		}
		return;
	}
	if (!appDelegate.mainViewControllerDidInitialSetup) {
		appDelegate.mainViewControllerDidInitialSetup = YES;
		A3MainMenuTableViewController *mainMenuTableViewController = [[A3AppDelegate instance] mainMenuViewController];
		
		mainMenuTableViewController.pushClockViewControllerOnPasscodeFailure = NO;

        [appDelegate showLockScreenWithCompletion:^(BOOL showLockScreen) {
            if (showLockScreen) {
                [appDelegate downloadDataFiles];
            } else {
                [self setupMainViewController];
            }
        }];
	}
}

- (void)setupMainViewController {
	A3AppDelegate *appDelegate = [A3AppDelegate instance];
	[appDelegate updateStartOption];
	
	if (appDelegate.startOptionOpenClockOnce) {
		if ([appDelegate isMainMenuStyleList]) {
			[appDelegate.mainMenuViewController openClockApp];
		} else {
			[appDelegate launchAppNamed:A3AppName_Clock verifyPasscode:NO animated:NO];
			[appDelegate updateRecentlyUsedAppsWithAppName:A3AppName_Clock];
			appDelegate.homeStyleMainMenuViewController.activeAppName = [A3AppName_Clock copy];
		}
		[appDelegate setStartOptionOpenClockOnce:NO];
	} else {
		if ([appDelegate isMainMenuStyleList]) {
			if (![[appDelegate mainMenuViewController] openRecentlyUsedMenu:YES]) {
				[appDelegate setStartOptionOpenClockOnce:NO];
				if (![appDelegate.mainMenuViewController openRecentlyUsedMenu:YES]) {
					[appDelegate.mainMenuViewController openClockApp];
				}
			}
			if (IS_IPAD) {
				/**
				 *  설치 후 처음 한번 Menu 방식을 사용할 때, 왼쪽 메뉴를 보여준다.
				 */
				if (![[NSUserDefaults standardUserDefaults] boolForKey:A3UserDefaultsDidShowLeftViewOnceiPad]) {
					[appDelegate.rootViewController_iPad setShowLeftView:YES];
					[[NSUserDefaults standardUserDefaults] setBool:YES forKey:A3UserDefaultsDidShowLeftViewOnceiPad];
					[[NSUserDefaults standardUserDefaults] synchronize];
				}
			}
		} else {
			NSString *startingApp = [[A3UserDefaults standardUserDefaults] objectForKey:kA3AppsStartingAppName];
			[appDelegate popStartingAppInfo];
			if ([startingApp length]) {
				[appDelegate launchAppNamed:startingApp verifyPasscode:NO animated:NO];
				appDelegate.homeStyleMainMenuViewController.activeAppName = [startingApp copy];
			}
		}
	}
    [appDelegate downloadDataFiles];
}

@end
