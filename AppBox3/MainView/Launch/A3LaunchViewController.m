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

NSString *const A3UserDefaultsDidShowWhatsNew_3_0 = @"A3UserDefaultsDidShowWhatsNew_3_0";
NSString *const A3UserDefaultsDidShowLeftViewOnceiPad = @"A3UserDefaultsDidShowLeftViewOnceiPad";

@interface A3LaunchViewController () <UIViewControllerTransitioningDelegate,
		UIAlertViewDelegate, A3DataMigrationManagerDelegate>

@property (nonatomic, strong) UIStoryboard *launchStoryboard;
@property (nonatomic, strong) A3LaunchSceneViewController *currentSceneViewController;
@property (nonatomic, strong) A3DataMigrationManager *migrationManager;

@end

@implementation A3LaunchViewController {
	NSUInteger _sceneNumber;
	BOOL _cloudButtonUsed;
    BOOL _migrationIsInProgress;
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
	backgroundImageView.image = [UIImage imageNamed:[[A3AppDelegate instance] getLaunchImageName]];
	[self.view addSubview:backgroundImageView];

//	if ([[A3AppDelegate instance] shouldMigrateV1Data]) {
//		[[A3UserDefaults standardUserDefaults] setBool:NO forKey:A3UserDefaultsDidShowWhatsNew_3_0];
//		[[A3UserDefaults standardUserDefaults] synchronize];
//	}
//
//	if (_showAsWhatsNew || ![[A3UserDefaults standardUserDefaults] boolForKey:A3UserDefaultsDidShowWhatsNew_3_0]) {
//		_sceneNumber = 0;
//
//		_launchStoryboard = [UIStoryboard storyboardWithName:IS_IPHONE ? @"Launch_iPhone" : @"Launch_iPad" bundle:nil];
//		_currentSceneViewController = [_launchStoryboard instantiateViewControllerWithIdentifier:@"LaunchScene0"];
//		_currentSceneViewController.sceneNumber = _sceneNumber;
//		_currentSceneViewController.delegate = self;
//		[self.view addSubview:_currentSceneViewController.view];
//		[self addChildViewController:_currentSceneViewController];
//	}
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
		
		if (!_migrationIsInProgress && [appDelegate shouldMigrateV1Data]) {
			_migrationIsInProgress = YES;
			self.migrationManager = [[A3DataMigrationManager alloc] init];
			self.migrationManager.delegate = self;
			if ([_migrationManager walletDataFileExists] && ![_migrationManager walletDataWithPassword:nil]) {
				_migrationManager.delegate = self;
				[_migrationManager askWalletPassword];
			} else {
				[_migrationManager migrateV1DataWithPassword:nil];
			}
		}
		
		if (![appDelegate showLockScreen]) {
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

			double delayInSeconds = 1.0;
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				[self askRestorePurchase];
			});
		}
	}
}

- (void)migrationManager:(A3DataMigrationManager *)manager didFinishMigration:(BOOL)success {
    [[A3UserDefaults standardUserDefaults] setBool:YES forKey:A3UserDefaultsDidShowWhatsNew_3_0];
    [[A3UserDefaults standardUserDefaults] synchronize];

	[_currentSceneViewController showButtons];

	A3AppDelegate *appDelegate = [A3AppDelegate instance];
	appDelegate.shouldMigrateV1Data = NO;
	_migrationManager = nil;

	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kA3ApplicationLastRunVersion];
	[[NSUserDefaults standardUserDefaults] synchronize];

    _migrationIsInProgress = NO;
}

#pragma mark - Ask Restore Purchase

- (void)askRestorePurchase {
	if ([A3AppDelegate instance].doneAskingRestorePurchase) return;
	
	// PreviousVersion이 있다면 다시 묻지 않는다.
	// 지우고 설치한 경우에만 물어본다. 업데이트 한 경우는 물어보지 않는다.
	if ([A3AppDelegate instance].previousVersion) {
		return;
	}
	NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
	if (receiptURL && [[NSFileManager defaultManager] fileExistsAtPath:[receiptURL path]]) {
		return;
	}
	
	NSString *backupReceiptFilepath = [[A3AppDelegate instance] backupReceiptFilePath];
	if ([[NSFileManager defaultManager] fileExistsAtPath:backupReceiptFilepath]) {
		return;
	}

	[A3AppDelegate instance].doneAskingRestorePurchase = YES;
	
	if (!IS_IOS7 && IS_IPAD) {
		UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Verification Required", @"Verification Required")
																				 message:nil
																		  preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction *paidCustomer = [UIAlertAction actionWithTitle:NSLocalizedString(@"Paid User", @"Paid User")
															   style:UIAlertActionStyleDefault
															 handler:^(UIAlertAction *action) {
																 [self proceedRestorePurchase];
															 }];
		UIAlertAction *boughtRemoveAds = [UIAlertAction actionWithTitle:NSLocalizedString(@"Bought Remove Ads", @"Bought Remove Ads")
															   style:UIAlertActionStyleDefault
															 handler:^(UIAlertAction *action) {
																 [self proceedRestorePurchase];
															 }];
		UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Continue without Verification", @"Continue without Verification")
															   style:UIAlertActionStyleCancel
															 handler:nil];

		[alertController addAction:paidCustomer];
		[alertController addAction:boughtRemoveAds];
		[alertController addAction:cancelAction];

		alertController.modalPresentationStyle = UIModalPresentationPopover;
		UIPopoverPresentationController *popoverPresentation = [alertController popoverPresentationController];
		popoverPresentation.sourceView = self.view;
		[self presentViewController:alertController animated:YES completion:NULL];
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Verification Required", @"Verification Required")
															message:nil
														   delegate:self
												  cancelButtonTitle:NSLocalizedString(@"Continue without Verification", @"Continue without Verification")
												  otherButtonTitles:NSLocalizedString(@"Paid User", @"Paid User"),
																	NSLocalizedString(@"Bought Remove Ads", @"Bought Remove Ads"),
																	nil];
		[alertView show];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != alertView.cancelButtonIndex) {
		[self proceedRestorePurchase];
	}
}

- (void)proceedRestorePurchase {
	[[A3AppDelegate instance] startRestorePurchase];
}

@end
