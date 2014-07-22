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

@interface A3LaunchViewController () <UIViewControllerTransitioningDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) UIStoryboard *launchStoryboard;
@property (nonatomic, strong) A3LaunchSceneViewController *currentSceneViewController;
@property (nonatomic, strong) id migrationFinishObserver;

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

//			if (IS_IPHONE && IS_PORTRAIT) {
//				double delayInSeconds = 0.5;
//				dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//				dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//					[[UIApplication sharedApplication] setStatusBarHidden:NO];
//					[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
//					[self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
//				});
//			}
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
				[_currentSceneViewController hideButtons];
				_migrationFinishObserver = [[NSNotificationCenter defaultCenter] addObserverForName:A3NotificationDataMigrationFinished object:nil queue:nil usingBlock:^(NSNotification *note) {
					[_currentSceneViewController showButtons];
					[[NSNotificationCenter defaultCenter] removeObserver:_migrationFinishObserver];
					_migrationFinishObserver = nil;
				}];
				[self checkMigrationFinished];
			}
		}
	}
}

- (void)checkMigrationFinished {
	FNLOG();
	if ([[A3AppDelegate instance] shouldMigrateV1Data]) {
		double delayInSeconds = 1.0;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			[self checkMigrationFinished];
		});
	} else {
		[_currentSceneViewController showButtons];
	}
}

- (void)useICloudButtonPressedInViewController:(UIViewController *)viewController {
	if (!_cloudButtonUsed) {
		_cloudButtonUsed = YES;
		[_currentSceneViewController.rightButton setTitle:NSLocalizedString(@"Continue", @"Continue") forState:UIControlStateNormal];
		[_currentSceneViewController.leftButton setTitle:NSLocalizedString(@"Use AppBox Pro", @"Use AppBox Pro") forState:UIControlStateNormal];
		[_currentSceneViewController.leftButton removeTarget:_currentSceneViewController action:NULL forControlEvents:UIControlEventTouchUpInside];
		[_currentSceneViewController.leftButton addTarget:_currentSceneViewController action:NSSelectorFromString(@"useAppBoxProAction:") forControlEvents:UIControlEventTouchUpInside];

		if (![[A3AppDelegate instance].ubiquityStoreManager cloudAvailable]) {
			[self alertCloudNotEnabled];
			return;
		}

		NSUbiquitousKeyValueStore *keyValueStore = [NSUbiquitousKeyValueStore defaultStore];
		[keyValueStore synchronize];

		if ([keyValueStore boolForKey:A3CloudHasData]) {
			// Ask user to delete iCloud or not
			UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Setup AppBox Pro data stored in iCloud", nil)
																	 delegate:self
															cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
													   destructiveButtonTitle:NSLocalizedString(@"Delete and start over", nil)
															otherButtonTitles:NSLocalizedString(@"Use data stored in iCloud", nil), nil];
			[actionSheet showInView:self.view];
			return;
		}
		[[A3AppDelegate instance] setCloudEnabled:YES deleteCloud:NO ];
	} else {
		[self continueButtonPressedInViewController:_currentSceneViewController];
	}
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.cancelButtonIndex) return;
	BOOL deleteCloud = buttonIndex == actionSheet.destructiveButtonIndex;

	[[A3AppDelegate instance] setCloudEnabled:YES deleteCloud:deleteCloud ];
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
