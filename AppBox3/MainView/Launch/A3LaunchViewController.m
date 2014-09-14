//
//  A3LaunchViewController.m
//  AppBox3
//
//  Created by A3 on 3/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3LaunchViewController.h"
#import "A3ClockMainViewController.h"
#import "A3LaunchSceneViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "A3AppDelegate.h"
#import "UIViewController+A3Addition.h"
#import "A3DataMigrationManager.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "A3MainMenuTableViewController.h"
#import "A3UserDefaults.h"

NSString *const A3UserDefaultsDidShowWhatsNew_3_0 = @"A3UserDefaultsDidShowWhatsNew_3_0";

@interface A3LaunchViewController () <UIViewControllerTransitioningDelegate, UIActionSheetDelegate, A3DataMigrationManagerDelegate>

@property (nonatomic, strong) UIStoryboard *launchStoryboard;
@property (nonatomic, strong) A3LaunchSceneViewController *currentSceneViewController;
@property (nonatomic, strong) A3DataMigrationManager *migrationManager;

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

	if ([[A3AppDelegate instance] shouldMigrateV1Data]) {
		[[A3UserDefaults standardUserDefaults] setBool:NO forKey:A3UserDefaultsDidShowWhatsNew_3_0];
		[[A3UserDefaults standardUserDefaults] synchronize];
	}

	if (!_showAsWhatsNew && [[A3UserDefaults standardUserDefaults] boolForKey:A3UserDefaultsDidShowWhatsNew_3_0]) {
		return;
	}
	
	_sceneNumber = 0;

	_launchStoryboard = [UIStoryboard storyboardWithName:IS_IPHONE ? @"Launch_iPhone" : @"Launch_iPad" bundle:nil];
	_currentSceneViewController = [_launchStoryboard instantiateViewControllerWithIdentifier:@"LaunchScene0"];
	_currentSceneViewController.sceneNumber = _sceneNumber;
	_currentSceneViewController.delegate = self;
	[self.view addSubview:_currentSceneViewController.view];
	[self addChildViewController:_currentSceneViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if ([self isMovingToParentViewController]) {
		A3AppDelegate *appDelegate = [A3AppDelegate instance];
		if (!_showAsWhatsNew && [[A3UserDefaults standardUserDefaults] boolForKey:A3UserDefaultsDidShowWhatsNew_3_0]) {

			if (![[[A3AppDelegate instance] mainMenuViewController] openRecentlyUsedMenu]) {
				A3ClockMainViewController *clockVC = [A3ClockMainViewController new];
				[self.navigationController pushViewController:clockVC animated:NO];
			}

			[appDelegate showLockScreen];
			[appDelegate downloadDataFiles];
		}
		else
		{
			[self.navigationController setNavigationBarHidden:YES animated:NO];
			[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
			[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
			
			UIImage *image = [UIImage new];
			[self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
			[self.navigationController.navigationBar setShadowImage:image];
			
			[[A3UserDefaults standardUserDefaults] setBool:YES forKey:A3UserDefaultsDidShowWhatsNew_3_0];
			[[A3UserDefaults standardUserDefaults] synchronize];

			A3AppDelegate *appDelegate = [A3AppDelegate instance];
			if ([appDelegate shouldMigrateV1Data]) {
				self.migrationManager = [[A3DataMigrationManager alloc] init];
				self.migrationManager.delegate = self;
				if ([_migrationManager walletDataFileExists] && ![_migrationManager walletDataWithPassword:nil]) {
					_migrationManager.delegate = self;
					[_migrationManager askWalletPassword];
				} else {
					[_migrationManager migrateV1DataWithPassword:nil];
				}

				[_currentSceneViewController hideButtons];
			} else {
				[appDelegate downloadDataFiles];
			}
		}
	}
}

- (void)migrationManager:(A3DataMigrationManager *)manager didFinishMigration:(BOOL)success {
	[_currentSceneViewController showButtons];
	A3AppDelegate *appDelegate = [A3AppDelegate instance];
	appDelegate.shouldMigrateV1Data = NO;
	_migrationManager = nil;

	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kA3ApplicationLastRunVersion];
	[[NSUserDefaults standardUserDefaults] synchronize];

	[appDelegate downloadDataFiles];
}

- (void)useICloudButtonPressedInViewController:(UIViewController *)viewController {
	if (!_cloudButtonUsed) {
		_cloudButtonUsed = YES;
		[_currentSceneViewController.rightButton setTitle:NSLocalizedString(@"Continue", @"Continue") forState:UIControlStateNormal];
		[_currentSceneViewController.leftButton setTitle:NSLocalizedString(@"Use AppBox Pro", @"Use AppBox Pro") forState:UIControlStateNormal];
		[_currentSceneViewController.leftButton removeTarget:_currentSceneViewController action:NULL forControlEvents:UIControlEventTouchUpInside];
		[_currentSceneViewController.leftButton addTarget:_currentSceneViewController action:NSSelectorFromString(@"useAppBoxProAction:") forControlEvents:UIControlEventTouchUpInside];

		if (![[A3SyncManager sharedSyncManager] isCloudAvailable]) {
			[self alertCloudNotEnabled];
			return;
		}

		NSUbiquitousKeyValueStore *keyValueStore = [NSUbiquitousKeyValueStore defaultStore];
		[keyValueStore synchronize];

		if (![[A3SyncManager sharedSyncManager] canSyncStart]) return;

		[[A3AppDelegate instance] setCloudEnabled:YES ];
	} else {
		[self continueButtonPressedInViewController:_currentSceneViewController];
	}
}

- (void)continueButtonPressedInViewController:(UIViewController *)viewController {
	_sceneNumber++;
	A3LaunchSceneViewController *nextSceneViewController = [_launchStoryboard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"LaunchScene%ld", (long) _sceneNumber]];
	nextSceneViewController.sceneNumber = _sceneNumber;
	nextSceneViewController.delegate = self;
	nextSceneViewController.showAsWhatsNew = _showAsWhatsNew;

	self.view.backgroundColor = [nextSceneViewController.view backgroundColor];
	CGRect currentViewFrame = _currentSceneViewController.view.frame;

	nextSceneViewController.view.frame = CGRectMake(currentViewFrame.size.width, 0, currentViewFrame.size.width, currentViewFrame.size.height);
	[self.view addSubview:nextSceneViewController.view];

	[UIView animateWithDuration:1.0
						  delay:0.0
		 usingSpringWithDamping:.8
		  initialSpringVelocity:6.0
						options:UIViewAnimationOptionCurveEaseIn
					 animations:^{
						 nextSceneViewController.view.frame = currentViewFrame;
					 }
			completion:^(BOOL finished) {
				[_currentSceneViewController.view removeFromSuperview];
				[_currentSceneViewController removeFromParentViewController];
				_currentSceneViewController = nil;

				[self addChildViewController:nextSceneViewController];
				_currentSceneViewController = nextSceneViewController;
			}
	];
}

- (void)useAppBoxButtonPressedInViewController:(UIViewController *)viewController {
	if (!_showAsWhatsNew) {
		[viewController.view removeFromSuperview];
		_currentSceneViewController = nil;
		_launchStoryboard = nil;

		A3ClockMainViewController *clockVC = [A3ClockMainViewController new];
		[self.navigationController pushViewController:clockVC animated:NO];
	} else {
		[self dismissViewControllerAnimated:YES completion:NULL];
	}
}

- (BOOL)hidesNavigationBar {
	return YES;
}

@end
