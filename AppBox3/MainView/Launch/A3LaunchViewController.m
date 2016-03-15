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

NSString *const A3UserDefaultsDidShowWhatsNew_3_0 = @"A3UserDefaultsDidShowWhatsNew_3_0";

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

	if ([self isMovingToParentViewController] ) {
		A3AppDelegate *appDelegate = [A3AppDelegate instance];
		A3MainMenuTableViewController *mainMenuTableViewController = [[A3AppDelegate instance] mainMenuViewController];
		
		mainMenuTableViewController.pushClockViewControllerOnPasscodeFailure = YES;
		
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
			
			if ([[A3AppDelegate instance] isMainMenuStyleList]) {
				if ([[A3AppDelegate instance] startOptionOpenClockOnce] ||
					![[[A3AppDelegate instance] mainMenuViewController] openRecentlyUsedMenu:YES]) {
					[[A3AppDelegate instance] setStartOptionOpenClockOnce:NO];
					[mainMenuTableViewController openClockApp];
				}
			} else {
				NSString *startingApp = [[A3UserDefaults standardUserDefaults] objectForKey:kA3AppsStartingAppName];
				if (startingApp) {
					[appDelegate launchAppNamed:startingApp verifyPasscode:NO delegate:self animated:NO];
				}
			}
		}
		[appDelegate downloadDataFiles];
		[self askRestorePurchase];
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
	// previousVersion과 currentVersion을 비교하여 다르다면 앱이 설치/업데이트 후 최초 실행중임을 알 수 있다.
	NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	if ([currentVersion isEqualToString:[A3AppDelegate instance].previousVersion]) {
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
