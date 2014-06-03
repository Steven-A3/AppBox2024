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

NSString *const A3UserDefaultsDidShowWhatsNew_3_0 = @"A3UserDefaultsDidShowWhatsNew_3_0";

@interface A3LaunchViewController () <UIViewControllerTransitioningDelegate, A3DataMigrationManagerDelegate>

@property (nonatomic, strong) UIStoryboard *launchStoryboard;
@property (nonatomic, strong) A3LaunchSceneViewController *currentSceneViewController;
@property (nonatomic, strong) A3DataMigrationManager *migrationManager;
@property (nonatomic, strong) id coreDataReadyObserver;

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

	if (!_showAsWhatsNew && [[NSUserDefaults standardUserDefaults] boolForKey:A3UserDefaultsDidShowWhatsNew_3_0]) {
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
		if (!_showAsWhatsNew && [[NSUserDefaults standardUserDefaults] boolForKey:A3UserDefaultsDidShowWhatsNew_3_0]) {
			A3ClockMainViewController *clockVC = [A3ClockMainViewController new];
			[self.navigationController pushViewController:clockVC animated:NO];

			if (IS_IPHONE && IS_PORTRAIT) {
				double delayInSeconds = 0.5;
				dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
				dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
					[[UIApplication sharedApplication] setStatusBarHidden:NO];
					[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
					[self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
				});
			}
			[[A3AppDelegate instance] showLockScreen];
		}
		else
		{
			[self.navigationController setNavigationBarHidden:YES animated:NO];
			[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
			[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
			
			UIImage *image = [UIImage new];
			[self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
			[self.navigationController.navigationBar setShadowImage:image];
			
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:A3UserDefaultsDidShowWhatsNew_3_0];
			[[NSUserDefaults standardUserDefaults] synchronize];

			if ([[A3AppDelegate instance] shouldMigrateV1Data]) {
				if ([[A3AppDelegate instance] coreDataReadyToUse]) {
					FNLOG(@"Core Data Already Ready!");
					[self migrateV1Data];
				} else {
					[_currentSceneViewController hideButtons];
					_coreDataReadyObserver =
							[[NSNotificationCenter defaultCenter] addObserverForName:A3NotificationCoreDataReady object:nil queue:nil usingBlock:^(NSNotification *notification) {
								FNLOG(@"Received Core Data Ready Notification");
								[self migrateV1Data];
								[[NSNotificationCenter defaultCenter] removeObserver:_coreDataReadyObserver];
								_coreDataReadyObserver = nil;
							}];
				}
			}
		}
	}
}

- (void)migrateV1Data {
	A3DataMigrationManager *migrationManager = [[A3DataMigrationManager alloc] initWithPersistentStoreCoordinator:[[A3AppDelegate instance] persistentStoreCoordinator]];
	if ([migrationManager walletDataFileExists] && ![migrationManager walletDataWithPassword:nil]) {
		_migrationManager = migrationManager;
		_migrationManager.delegate = self;
		[migrationManager askWalletPassword];
	} else {
		[migrationManager migrateV1DataWithPassword:nil];
		[_currentSceneViewController showButtons];
	}
}

- (void)migrationManager:(A3DataMigrationManager *)manager didFinishMigration:(BOOL)success {
	[_currentSceneViewController showButtons];
	_migrationManager = nil;
}

- (void)useICloudButtonPressedInViewController:(UIViewController *)viewController {
	if (!_cloudButtonUsed) {
		_cloudButtonUsed = YES;
		[_currentSceneViewController.rightButton setTitle:@"Continue" forState:UIControlStateNormal];

		if (![[A3AppDelegate instance].ubiquityStoreManager cloudAvailable]) {
			[self alertCloudNotEnabled];
			return;
		}
		[[A3AppDelegate instance] setCloudEnabled:YES];
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

	CGRect currentViewFrame = _currentSceneViewController.view.frame;

	nextSceneViewController.view.frame = CGRectMake(currentViewFrame.size.width, 0, currentViewFrame.size.width, currentViewFrame.size.height);
	[self.view addSubview:nextSceneViewController.view];

	[UIView animateWithDuration:1.0
						  delay:0.0
		 usingSpringWithDamping:.8
		  initialSpringVelocity:6.0
						options:UIViewAnimationOptionCurveEaseIn
					 animations:^{
						 _currentSceneViewController.view.frame = CGRectMake(-currentViewFrame.size.width, 0, currentViewFrame.size.width, currentViewFrame.size.height);
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
