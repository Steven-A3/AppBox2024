//
//  A3AppDelegate.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/25/11.
//  Copyright (c) 2011 ALLABOUTAPPS. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import "A3AppDelegate.h"
#import "A3MainMenuTableViewController.h"
#import "MMDrawerController.h"
#import "NSFileManager+A3Addition.h"
#import "Reachability.h"
#import "A3KeychainUtils.h"
#import "A3LaunchViewController.h"
#import "A3MainViewController.h"
#import "DaysCounterEvent.h"
#import "A3DaysCounterEventDetailViewController.h"
#import "A3DaysCounterModelManager.h"
#import "A3LadyCalendarDetailViewController.h"
#import "DaysCounterEvent+extension.h"
#import "NSString+conversion.h"
#import "WalletData.h"
#import "A3SettingsBackupRestoreViewController.h"
#import "HolidayData.h"
#import "HolidayData+Country.h"
#import "A3HolidaysFlickrDownloadManager.h"
#import "A3SyncManager.h"
#import "AFHTTPRequestOperation.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "A3UserDefaults.h"
#import "A3AppDelegate+migration.h"
#import "UIViewController+A3Addition.h"
#import "A3LadyCalendarModelManager.h"
#import "A3NavigationController.h"
#import "A3HomeStyleMenuViewController.h"
#import "WalletItem.h"
#import "WalletFieldItem+initialize.h"
#import "WalletCategory.h"
#import <CoreMotion/CoreMotion.h>
#import "TJDropbox.h"
#import "ACSimpleKeychain.h"
#import "UIView+SBExtras.h"
#import "FXBlurView.h"
#import "UIImage+imageWithColor.h"
#import "NYXImagesKit.h"
@import UserNotifications;
#import <FirebaseCore/FirebaseCore.h>
#import <PersonalizedAdConsent/PersonalizedAdConsent.h>
#import <AdSupport/AdSupport.h>
#import "TJDropboxAuthenticator.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import "Pedometer.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"
#import "AppBox3-swift.h"
#import <AppBoxKit/AppBoxKit.h>
#import "A3UIDevice.h"
#import "A3UserDefaults+A3Addition.h"

NSString *const A3UserDefaultsStartOptionOpenClockOnce = @"A3StartOptionOpenClockOnce";
NSString *const A3DrawerStateChanged = @"A3DrawerStateChanged";
NSString *const A3DropboxLoginWithSuccess = @"A3DropboxLoginWithSuccess";
NSString *const A3DropboxLoginFailed = @"A3DropboxLoginFailed";
NSString *const A3LocalNotificationOwner = @"A3LocalNotificationOwner";
NSString *const A3LocalNotificationDataID = @"A3LocalNotificationDataID";
NSString *const A3LocalNotificationFromLadyCalendar = @"Ladies Calendar";
NSString *const A3LocalNotificationFromDaysCounter = @"Days Counter";
NSString *const A3NotificationsUserNotificationSettingsRegistered = @"A3NotificationsUserNotificationSettingsRegistered";
NSString *const A3NotificationsAdsWillDismissScreen = @"A3NotificationAdsWillDismissScreen";
NSString *const A3InAppPurchaseRemoveAdsProductIdentifier = @"net.allaboutapps.AppBox3.removeAds";
NSString *const A3NumberOfTimesOpeningSubApp = @"A3NumberOfTimesOpeningSubApp";
NSString *const A3AdsDisplayTime = @"A3AdsDisplayTime";
NSString *const A3InterstitialAdUnitID = @"ca-app-pub-0532362805885914/2537692543";
NSString *const A3AppStoreReceiptBackupFilename = @"AppStoreReceiptBackup";
NSString *const A3AppStoreCloudDirectoryName = @"AppStore";
NSString *const kA3TheDateFirstRunAfterInstall = @"kA3TheDateFirstRunAfterInstall";

@interface A3AppDelegate () <UIAlertViewDelegate, NSURLSessionDownloadDelegate, CLLocationManagerDelegate, GADFullScreenContentDelegate, A3AppUIContextProtocol>

@property (nonatomic, strong) NSDictionary *localNotificationUserInfo;
@property (nonatomic, strong) UILocalNotification *storedLocalNotification;
@property (nonatomic, strong) NSMutableArray *downloadList;
@property (nonatomic, strong) NSURLSession *backgroundDownloadSession;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSTimer *locationUpdateTimer;
@property (nonatomic, copy) NSString *deviceToken;
@property (nonatomic, copy) NSString *alertURLString;
// TODO: 3D Touch 장비 입수후 테스트 필요
@property (nonatomic, strong) UIApplicationShortcutItem *shortcutItem;
@property (nonatomic, strong) GADRequest *adRequest;
@property (nonatomic, strong) GADBannerView *adBannerView;
@property (nonatomic, strong) GADInterstitialAd *adInterstitial;

@end

@implementation A3AppDelegate {
	BOOL _appIsNotActiveYet;
	BOOL _backgroundDownloadIsInProgress;
	BOOL _statusBarHiddenBeforeAdsAppear;
	UIStatusBarStyle _statusBarStyleBeforeAdsAppear;
}

@synthesize window = _window;

+ (A3AppDelegate *)instance {
	return (A3AppDelegate *) [[UIApplication sharedApplication] delegate];
}

- (void)updateStartOption {
	_startOptionOpenClockOnce = [[NSUserDefaults standardUserDefaults] boolForKey:A3UserDefaultsStartOptionOpenClockOnce];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:A3UserDefaultsStartOptionOpenClockOnce];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

// TODO: 3D Touch 장비 입수후 테스트 필요
- (BOOL)shouldPerformAdditionalDelegateHandling:(NSDictionary *)launchOptions {
    if (launchOptions) {
        _shortcutItem = launchOptions[UIApplicationLaunchOptionsShortcutItemKey];
    
        if (_shortcutItem) {
            [self pushStartingAppInfo];
            [[A3UserDefaults standardUserDefaults] setObject:_shortcutItem.userInfo[kA3AppsMenuName] forKey:kA3AppsStartingAppName];
            _shortcutItem = nil;
            
            return NO;
        }
    }
    return YES;
}

- (void)setDefaultValues {
    if (_previousVersion && [_previousVersion length] > 4 && [[_previousVersion substringToIndex:3] doubleValue] < 3.3) {
        FNLOG(@"%@", @([[_previousVersion substringToIndex:3] doubleValue]));
        // 3.3 이전버전에서 업데이트 한 경우
        // V3.3 부터 Touch ID가 추가되고 Touch ID 활성화가 기본
        // Touch ID가 활성화된 경우, passcode timer를 쓸 수 없도록 하였으므로 0으로 설정한다.
        // 3.3을 처음 설치한 경우에는 기본이 0이므로 별도 설정 불필요.
        [[A3UserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsKeyForPasscodeTimerDuration];
        [[A3UserDefaults standardUserDefaults] synchronize];
    }
    if (_previousVersion && [_previousVersion length] > 4 && [[_previousVersion substringToIndex:3] doubleValue] < 3.4) {
        if (!_shouldMigrateV1Data) {
            [self migrateToV3_4_Holidays];
        }
    }
    if (_previousVersion && [_previousVersion doubleValue] == 4.0) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:A3SettingsMainMenuHexagonShouldAddQRCodeMenu];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:A3SettingsMainMenuGridShouldAddQRCodeMenu];
    }
    if (_previousVersion && [_previousVersion doubleValue] <= 4.1) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:A3SettingsMainMenuHexagonShouldAddPedometerMenu];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:A3SettingsMainMenuGridShouldAddPedometerMenu];
    }
    // TODO: Abbreviation
    if (_previousVersion && [_previousVersion doubleValue] < 4.5) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:A3SettingsMainMenuHexagonShouldAddAbbreviationMenu];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:A3SettingsMainMenuGridShouldAddAbbreviationMenu];
    }
}

- (void)addNotificationObservers {
    self.reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
    [self.reachability startNotifier];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRemoveSecurityCoverView)
                                                 name:A3RemoveSecurityCoverViewNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(rotateAccordingToStatusBarOrientationAndSupportedOrientations)
                                                 name:A3RotateAccordingToDeviceOrientationNotification object:nil];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [FIRApp configure];
    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];
    A3SyncManager.sharedSyncManager.appUIContext = self;
    
    #ifdef DEBUG
    FNLOG(@"%@", [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]);
    FNLOG(@"%@", [NSLocale preferredLanguages]);
    FNLOG(@"%@", [[NSLocale currentLocale] currencyCode]);
    #endif
   
    BOOL shouldPerformAdditionalDelegateHandling = [self shouldPerformAdditionalDelegateHandling:launchOptions];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:@{kA3SettingsMainMenuStyle:A3SettingsMainMenuStyleIconGrid}];

    _shouldPresentAd = YES;
    _expirationDate = [NSDate distantPast];
    
    [self evaluateSubscriptionWithCompletion:NULL];
    
	_passcodeFreeBegin = [[NSDate distantPast] timeIntervalSinceReferenceDate];

	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];

	_appIsNotActiveYet = YES;

	CDESetCurrentLoggingLevel(CDELoggingLevelNone);

	[self prepareDirectories];
	[A3SyncManager sharedSyncManager];

	[[NSUbiquitousKeyValueStore defaultStore] removeObjectForKey:A3MainMenuDataEntityAllMenu];
	[[NSUbiquitousKeyValueStore defaultStore] removeObjectForKey:A3MainMenuDataEntityFavorites];
	[[NSUbiquitousKeyValueStore defaultStore] synchronize];

	[self setupContext];
	[self favoriteMenuDictionary];

	UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
	if (localNotification) {
		_localNotificationUserInfo = [localNotification.userInfo copy];
        [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
	}

	// Check if it is running first time after update from 1.x.x
	// 아래 값은 마이그레이션이 끝나면 지운다.
	_previousVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kA3ApplicationLastRunVersion];
	if (_previousVersion) {
		_shouldMigrateV1Data = YES;
		[A3KeychainUtils migrateV1Passcode];
	} else {
		// TODO: 지우고 새로 설치해도 암호가 지워지지 않는 오류 수정해야 함
		_previousVersion = [[A3UserDefaults standardUserDefaults] objectForKey:kA3ApplicationLastRunVersion];
		if (!_previousVersion) {
			_firstRunAfterInstall = YES;
			[A3KeychainUtils removePassword];
			[self initializePasscodeUserDefaults];
		}
	}
    [self setDefaultValues];

	// AppBox Pro V1.8.4까지는 Days Until 기능의 옵션에 의해서 남은 일자에 대한 배지 기능이 있었습니다.
	// AppBox Pro V3.0 이후로는 배지 기능을 제공하지 않습니다.
	// 이 값은 초기화 합니다.
	[self clearScheduledOldVersionLocalNotifications];

	// toolsconf.db가 library directory에 남아 있으면 마이그레이션이 끝나지 않았으므로 확실히 점검한다.
	NSString *oldFilePath = [@"toolsconf.db" pathInLibraryDirectory];
	if ([[NSFileManager defaultManager] fileExistsAtPath:oldFilePath]) {
		_shouldMigrateV1Data = YES;
	}

    [self addNotificationObservers];

    FNLOGRECT([[UIScreen mainScreen] nativeBounds]);
    
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[self setupMainMenuViewController];
	self.window.backgroundColor = [UIColor whiteColor];

    self.window.tintColor = [[A3UserDefaults standardUserDefaults] themeColor];

	[self.window makeKeyAndVisible];

    NSString *lastRunVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [[NSUserDefaults standardUserDefaults] setObject:lastRunVersion forKey:kA3ApplicationLastRunVersion];
	[[A3UserDefaults standardUserDefaults] setObject:lastRunVersion forKey:kA3ApplicationLastRunVersion];
    
	[[A3UserDefaults standardUserDefaults] synchronize];
    
	return shouldPerformAdditionalDelegateHandling;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    _appWillResignActive = YES;
    
	[self applicationWillResignActive_passcode];
	FNLOG();
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	[[A3UserDefaults standardUserDefaults] synchronize];

	[self applicationDidEnterBackground_passcode];

	__block UIBackgroundTaskIdentifier identifier;
	identifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
		[[UIApplication sharedApplication] endBackgroundTask:identifier];
		identifier = UIBackgroundTaskInvalid;
	}];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSManagedObjectContext *managedObjectContext = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
		[managedObjectContext performBlock:^{
			if (managedObjectContext.hasChanges) {
				BOOL shouldSaveChanges = NO;
				NSArray *insertedObjects = [[managedObjectContext insertedObjects] allObjects];
				for (id insertedObj in insertedObjects) {
					if ([insertedObj isKindOfClass:[WalletItem class]]) {
						WalletItem *insertedWalletItem = insertedObj;
						if 	(	[[insertedWalletItem.name stringByTrimmingSpaceCharacters] length] ||
								[[insertedWalletItem.note stringByTrimmingSpaceCharacters] length])
						{
							shouldSaveChanges = YES;
							break;
						}
					}
					if ([insertedObj isKindOfClass:[WalletFieldItem class]]) {
						WalletFieldItem *fieldItem = insertedObj;
						if (	[[fieldItem.value stringByTrimmingSpaceCharacters] length] ||
								fieldItem.hasImage || fieldItem.hasVideo || fieldItem.date)
						{
							shouldSaveChanges = YES;
							break;
						}
					}
					if ([insertedObj isKindOfClass:[WalletCategory class]]) {
						WalletCategory *category = insertedObj;
						if ([[category.name stringByTrimmingSpaceCharacters] length]) {
							shouldSaveChanges = YES;
							break;
						}
					}
					if ([insertedObj isKindOfClass:[DaysCounterEvent class]]) {
						DaysCounterEvent *event = insertedObj;
						if ([[event.eventName stringByTrimmingSpaceCharacters] length] ||
								[[event.notes stringByTrimmingSpaceCharacters] length] ||
								event.photoID )
						{
							shouldSaveChanges = YES;
							break;
						}
					}
				}
				FNLOG(@"Core data changes will be saved: %@", shouldSaveChanges ? @"YES" : @"NO");
				if (shouldSaveChanges) {
					[managedObjectContext save:NULL];
				}
			}

			[[A3SyncManager sharedSyncManager] synchronizeWithCompletion:^(NSError *error) {
				[[UIApplication sharedApplication] endBackgroundTask:identifier];
				identifier = UIBackgroundTaskInvalid;
			}];
		}];
	});
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    _appWillResignActive = NO;
	_adDisplayedAfterApplicationDidBecomeActive = NO;
	FNLOG();
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	[self applicationWillEnterForeground_passcode];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    _appWillResignActive = NO;
    NSInteger numberOfDidBecomeAcive = [[NSUserDefaults standardUserDefaults] integerForKey:kA3ApplicationNumberOfDidBecomeActive];
    [[NSUserDefaults standardUserDefaults] setInteger:numberOfDidBecomeAcive + 1 forKey:kA3ApplicationNumberOfDidBecomeActive];
	FNLOG(@"Number Of DidBecomeActive = %ld", (long)[[NSUserDefaults standardUserDefaults] integerForKey:kA3ApplicationNumberOfDidBecomeActive]);
	
	A3SyncManager *syncManager = [A3SyncManager sharedSyncManager];
	[syncManager synchronizeWithCompletion:NULL];
	if ([syncManager isCloudEnabled]) {
		[syncManager uploadMediaFilesToCloud];
		[syncManager downloadMediaFilesFromCloud];
	}

	// TODO: Dropbox V2 Pending work
//	UINavigationController *navigationController = [self navigationController];
//	UIViewController *topViewController = self.navigationController.topViewController;
//	if ([topViewController isKindOfClass:[A3SettingsBackupRestoreViewController class]] && ![[DBSession sharedSession] isLinked]) {
//		[navigationController popViewControllerAnimated:NO];
//	}
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	[self applicationDidBecomeActive_passcodeAfterLaunch:_appIsNotActiveYet];
	
	[self fetchPushNotification];

	if (_appIsNotActiveYet) {
		_appIsNotActiveYet = NO;
	}
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [A3SyncManager.sharedSyncManager.persistentContainer.viewContext saveContext];
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
	NSUInteger orientations;

	if (IS_IPAD) {
		orientations = UIInterfaceOrientationMaskAll;
	} else {
		id<A3ViewControllerProtocol>visibleViewController = (id <A3ViewControllerProtocol>) [_currentMainNavigationController visibleViewController];
		if ([visibleViewController respondsToSelector:@selector(a3SupportedInterfaceOrientations)]) {
			orientations = [visibleViewController a3SupportedInterfaceOrientations];
		} else {
			orientations = UIInterfaceOrientationMaskPortrait;
		}
	}

	return orientations;
}

#pragma mark - Handle Open URL

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [self handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self handleOpenURL:url];
}

- (BOOL)handleOpenURL:(NSURL *)url {
    if ([TJDropboxAuthenticator tryHandleAuthenticationCallbackWithURL:url]) {
        return YES;
    }
    if ([[[url absoluteString] lowercaseString] hasPrefix:@"appboxpro://"]) {
        FNLOG(@"%@", url);
        NSArray *components = [[url absoluteString] componentsSeparatedByString:@"://"];
        if ([components count] > 1) {
            NSString *moduleName = [[components lastObject] lowercaseString];
            NSArray *allMenus = [self allMenuItems];
            NSInteger indexOfMenu = [allMenus indexOfObjectPassingTest:^BOOL(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDictionary *appInfo = [self appInfoDictionary][obj[kA3AppsMenuName]];
                return [[appInfo[kA3AppsMenuImageName] lowercaseString] isEqualToString:moduleName];
            }];
            if (indexOfMenu != NSNotFound) {
                [self pushStartingAppInfo];
                
                NSDictionary *menuItem = allMenus[indexOfMenu];
                NSString *startingAppName = menuItem[kA3AppsMenuName];
                [[A3UserDefaults standardUserDefaults] setObject:startingAppName forKey:kA3AppsStartingAppName];
                
                BOOL shouldAskPassocodeForStarting = [self shouldAskPasscodeForStarting];
                if (shouldAskPassocodeForStarting || [self requirePasscodeForStartingApp]) {
                    [self presentLockScreenShowCancelButton:!shouldAskPassocodeForStarting];
                } else {
                    [self removeSecurityCoverView];
                    if ([self isMainMenuStyleList]) {
                        [self.mainMenuViewController openRecentlyUsedMenu:YES];
                    } else {
                        [self launchAppNamed:startingAppName verifyPasscode:NO animated:NO];
                        [self updateRecentlyUsedAppsWithAppName:startingAppName];
                        self.homeStyleMainMenuViewController.activeAppName = [startingAppName copy];
                    }
                }
            }
        }
        return YES;
    } else if ([url.absoluteString hasPrefix:@"db-ody0cjvmnaxvob4"]) {
        NSString *accessToken = [TJDropbox accessTokenFromDropboxAppAuthenticationURL:url];
        if (accessToken == nil) {
            accessToken = [TJDropbox accessTokenFromURL:url withRedirectURL:[NSURL URLWithString:@"db-ody0cjvmnaxvob4://"]];
        }
        if (accessToken) {
            [[ACSimpleKeychain defaultKeychain] storeUsername:@"dropboxUser" password:accessToken identifier:@"net.allaboutapps.AppBoxPro" forService:@"Dropbox"];
            FNLOG(@"App linked successfully!");
            [[NSNotificationCenter defaultCenter] postNotificationName:A3DropboxLoginWithSuccess object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:A3DropboxLoginFailed object:nil];
        }
        
        return YES;
    }
    return NO;
}

#pragma mark - UIApplicationShortcutItem 처리

// TODO: 3D Touch 장비 입수후 테스트 필요
- (void)application:(UIApplication * _Nonnull)application performActionForShortcutItem:(UIApplicationShortcutItem * _Nonnull)shortcutItem completionHandler:(void (^ _Nonnull)(BOOL succeeded))completionHandler {
	FNLOG();
    _shortcutItem = shortcutItem;
    completionHandler([self handleShortcutItem]);
}

- (BOOL)handleShortcutItem {
    if (!_shortcutItem) return NO;

    [self pushStartingAppInfo];
	NSString *startingAppName = (id)_shortcutItem.userInfo[kA3AppsMenuName];
    [[A3UserDefaults standardUserDefaults] setObject:startingAppName forKey:kA3AppsStartingAppName];
    _shortcutItem = nil;
    
//	if ([self shouldAskPasscodeForStarting] || [self requirePasscodeForStartingApp]) {
//		[self presentLockScreen:self];
//	} else {
//		[self removeSecurityCoverView];
//		if ([self isMainMenuStyleList]) {
//			[self.mainMenuViewController openRecentlyUsedMenu:YES];
//		} else {
//			[self launchAppNamed:startingAppName verifyPasscode:NO delegate:nil animated:NO];
//			self.homeStyleMainMenuViewController.activeAppName = [startingAppName copy];
//		}
//	}
	
    return YES;
}

- (void)pushStartingAppInfo {
    NSString *startAppName = [[A3UserDefaults standardUserDefaults] objectForKey:kA3AppsStartingAppName];
    if ([startAppName length]) {
        [[NSUserDefaults standardUserDefaults] setObject:startAppName forKey:kA3AppsOriginalStartingAppName];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kA3AppsOriginalStartingAppName];
    }
	if ([self isMainMenuStyleList]) {
		_mainMenuViewController.activeAppName = nil;
	} else {
		_homeStyleMainMenuViewController.activeAppName = nil;
	}
}

- (void)popStartingAppInfo {
    id originalStartingAppName = [[NSUserDefaults standardUserDefaults] objectForKey:kA3AppsOriginalStartingAppName];
    if (originalStartingAppName) {
        if ([originalStartingAppName length]) {
            [[A3UserDefaults standardUserDefaults] setObject:originalStartingAppName forKey:kA3AppsStartingAppName];
        } else {
            [[A3UserDefaults standardUserDefaults] removeObjectForKey:kA3AppsStartingAppName];
        }
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kA3AppsOriginalStartingAppName];
    }
}

#pragma mark - Notification

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
	FNLOG();
    [self handleActionForLocalNotification:notification application:application];
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler {
    [self handleActionForLocalNotification:notification application:application];
    
    completionHandler();
}
#endif

- (void)handleActionForLocalNotification:(UILocalNotification *)notification application:(UIApplication *)application {
    _localNotificationUserInfo = [notification.userInfo copy];
    self.storedLocalNotification = notification;
    
    if ([application applicationState] == UIApplicationStateInactive) {
        [self showReceivedLocalNotifications];
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
    }
    else {
        NSString *notificationOwner = [notification.userInfo objectForKey:A3LocalNotificationOwner];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:notificationOwner
                                                        message:notification.alertBody
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                              otherButtonTitles:NSLocalizedString(@"Details", @"Details"), nil];
        if ([notificationOwner isEqualToString:A3LocalNotificationFromDaysCounter]) {
            alert.tag = 11;
        } else if ([notificationOwner isEqualToString:A3LocalNotificationFromLadyCalendar]) {
            alert.tag = 21;
        }
        [alert show];
    }
}

- (void)showReceivedLocalNotifications {
	if (!_localNotificationUserInfo) return;

	NSString *notificationOwner = [_localNotificationUserInfo objectForKey:A3LocalNotificationOwner];

	if (IS_IPHONE) {
		[self.drawerController closeDrawerAnimated:NO completion:NULL];
	}

	if ([notificationOwner isEqualToString:A3LocalNotificationFromDaysCounter]) {
		[self showDaysCounterDetail];
	} else if ([notificationOwner isEqualToString:A3LocalNotificationFromLadyCalendar]) {
		[self showLadyCalendarDetailView];
	}
	_localNotificationUserInfo = nil;
}

- (void)clearScheduledOldVersionLocalNotifications {
	UIApplication *application = [UIApplication sharedApplication];
	application.applicationIconBadgeNumber = 0;
	NSArray *scheduledNotifications = [application scheduledLocalNotifications];
	[scheduledNotifications enumerateObjectsUsingBlock:^(UILocalNotification *localNotification, NSUInteger idx, BOOL *stop) {
		if (localNotification.userInfo[@"kABPLocalNotificationTypeDaysUntil"] || localNotification.applicationIconBadgeNumber) {
			[application cancelLocalNotification:localNotification];
		}
	}];
}

#pragma mark - UIAlertViewDelegate

#define	ABAD_ALERT_PUSH_ALERT		1000

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == alertView.cancelButtonIndex) {
		_localNotificationUserInfo = nil;
		return;
	}
	switch (alertView.tag) {
		case 11:
			[self showDaysCounterDetail];
			break;
		case 21:
			[self showLadyCalendarDetailView];
			break;
		case 31:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.allaboutapps.net/wordpress/archives/274"]];
			break;
		case ABAD_ALERT_PUSH_ALERT:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.alertURLString]];
			self.alertURLString = nil;
			break;
	}
    
	_localNotificationUserInfo = nil;
    if (_storedLocalNotification) {
        [[UIApplication sharedApplication] cancelLocalNotification:_storedLocalNotification];
    }
}

- (void)showDaysCounterDetail {
	if (!_localNotificationUserInfo[A3LocalNotificationDataID]) {
		return;
	}

	[A3DaysCounterModelManager reloadAlertDateListForLocalNotification];

	FNLOG(@"%@", _localNotificationUserInfo[A3LocalNotificationDataID]);

	DaysCounterEvent *eventItem = [DaysCounterEvent findFirstByAttribute:@"uniqueID" withValue:_localNotificationUserInfo[A3LocalNotificationDataID]];
	A3DaysCounterEventDetailViewController *viewController = [[A3DaysCounterEventDetailViewController alloc] init];
	viewController.isNotificationPopup = YES;
	viewController.eventItem = eventItem;
    A3DaysCounterModelManager *sharedManager = [[A3DaysCounterModelManager alloc] init];
    [sharedManager prepareToUse];
    viewController.sharedManager = sharedManager;

	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	[self.navigationController.visibleViewController presentViewController:navigationController animated:YES completion:NULL];
}

- (void)showLadyCalendarDetailView {
	A3LadyCalendarDetailViewController *viewController = [[A3LadyCalendarDetailViewController alloc] init];
	viewController.isFromNotification = YES;
	viewController.periodID = _localNotificationUserInfo[A3LocalNotificationDataID];

	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	[self.navigationController.visibleViewController presentViewController:navigationController animated:YES completion:NULL];
}

#pragma mark

- (UINavigationController *)navigationController {
	if (IS_IPHONE) {
		return self.currentMainNavigationController;
	} else {
		return self.rootViewController_iPad.centerNavigationController;
	}
}

- (UIViewController *)visibleViewController {
	UINavigationController *navigationController = [self navigationController];
	return [navigationController visibleViewController];
}

- (NSCalendar *)calendar {
	if (!_calendar) {
		_calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	}
	return _calendar;
}

- (NSMetadataQuery *)metadataQuery {
	if (!_metadataQuery) {
		_metadataQuery = [[NSMetadataQuery alloc] init];
		_metadataQuery.searchScopes = @[NSMetadataQueryUbiquitousDataScope];
		_metadataQuery.predicate = [NSPredicate predicateWithFormat:@"%K like %@", NSMetadataItemFSNameKey, @"*"];
	}
	return _metadataQuery;
}

#pragma mark - Prepare subdirectories

- (void)prepareDirectories {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *applicationSupportPath = [fileManager applicationSupportPath];
	if (![fileManager fileExistsAtPath:applicationSupportPath]) {
		[fileManager createDirectoryAtPath:applicationSupportPath withIntermediateDirectories:YES attributes:nil error:NULL];
	}
	if ( ![fileManager fileExistsAtPath:[A3DaysCounterModelManager thumbnailDirectory]] ) {
		[fileManager createDirectoryAtPath:[A3DaysCounterModelManager thumbnailDirectory] withIntermediateDirectories:YES attributes:nil error:NULL];
	}
	NSString *imageDirectory = [A3DaysCounterImageDirectory pathInLibraryDirectory];
	if (![fileManager fileExistsAtPath:imageDirectory]) {
		[fileManager createDirectoryAtPath:imageDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
	}
	[WalletData createDirectories];
	NSString *dataDirectory = [@"data" pathInCachesDirectory];
	if (![fileManager fileExistsAtPath:dataDirectory]) {
		[fileManager createDirectoryAtPath:dataDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
	}
}

#pragma mark - Download data files in background, 간지 데이터, Flick Recommendation, Message to customers.

- (NSURLSession *)backgroundDownloadSession {
	if (!_backgroundDownloadSession) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"net.allaboutapps.backgroundTransfer.backgroundSession"];
        _backgroundDownloadSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
	}
	return _backgroundDownloadSession;
}

- (void)reachabilityChanged:(NSNotification *)notification {
	if (![_downloadList count]) {
		_downloadList = nil;
		[[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
		return;
	}

	if (_backgroundDownloadSession) {
		// _backgroundDownloadSession이 있다는 것은 Download가 진행중이라는 의미
		return;
	}
	Reachability *reachability = notification.object;
	if ([_downloadList count] && [reachability isReachableViaWiFi]) {
		[self startDownloadDataFiles];
	}
}

- (void)downloadDataFiles {
	_downloadList = [NSMutableArray new];
//    [_downloadList addObject:[NSURL URLWithString:@"http://www.allaboutapps.net/data/FlickrRecommendation.json"]];
//    [_downloadList addObject:[NSURL URLWithString:@"http://www.allaboutapps.net/data/device_information.json"]];
//    [_downloadList addObject:[NSURL URLWithString:@"http://www.allaboutapps.net/data/IsraelHolidays.plist"]];
//    [_downloadList addObject:[NSURL URLWithString:@"http://www.allaboutapps.net/data/indian.plist"]];

	if ([A3UIDevice shouldSupportLunarCalendar]) {
        NSFileManager *fileManager = [NSFileManager new];
		NSString *kanjiDataFile = [@"data/LunarConverter.sqlite" pathInCachesDirectory];
		if (![fileManager fileExistsAtPath:kanjiDataFile]) {
			[_downloadList addObject:[NSURL URLWithString:@"https://www.allaboutapps.net/data/LunarConverter.sqlite"]];
		}
	}
//	[_downloadList addObject:[NSURL URLWithString:@"http://www.allaboutapps.net/data/message.plist"]];

    if ([_downloadList count] > 0) {
        [self startDownloadDataFiles];
    } else {
        _downloadList = nil;
    }
}

- (void)startDownloadDataFiles {
	if (_backgroundDownloadIsInProgress) {
		return;
	}
	_backgroundDownloadIsInProgress = YES;
	if (![_downloadList count]) {
		_downloadList = nil;
		_backgroundDownloadSession = nil;

		return;
	}
	if (![self.reachability isReachableViaWiFi]) {
		return;
	}
	double delayInSeconds = 2.0;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
		if ([_downloadList count]) {
			NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:_downloadList[0]];
			NSURLSessionDownloadTask *downloadTask = [self.backgroundDownloadSession downloadTaskWithRequest:downloadRequest];
			[downloadTask resume];
		}
	});
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    void (^completionBlock)(void) = ^() {
		_backgroundDownloadIsInProgress = NO;
		if ([self.reachability isReachableViaWiFi]) {
			[self startDownloadDataFiles];
		}
	};
	
	if ([_downloadList count]) {
		[_downloadList removeObjectAtIndex:0];
	}

	// Verify downloaded file contents.
	// device_information.json, FlickrRecommendation.json 모두 json이므로
	NSString *filename = [downloadTask.originalRequest.URL lastPathComponent];
	if ([[downloadTask.originalRequest.URL pathExtension] isEqualToString:@"json"]) {
		NSData *rawData = [NSData dataWithContentsOfURL:location];
		if (rawData) {
			NSError *error;
			NSArray *candidates = [NSJSONSerialization JSONObjectWithData:rawData options:0 error:&error];
			if (error || candidates == nil) {
				// File has error
				completionBlock();
				return;
			}
		} else {
			completionBlock();
			return;
		}
	} else if ([[downloadTask.originalRequest.URL pathExtension] isEqualToString:@"plist"]) {
		// indian.plist와 IsraelHolidays.plist는 모두 NSDictionary이다.
		
		NSDictionary *data = [NSDictionary dictionaryWithContentsOfURL:location];
		if (![data isKindOfClass:[NSDictionary class]]) {
			completionBlock();
			return;
		}
	}
	
	NSString *destinationPath =	[@"data" pathInCachesDirectory];
	destinationPath = [destinationPath stringByAppendingPathComponent:filename];
	FNLOG(@"%@", destinationPath);
	NSFileManager *fileManager = [NSFileManager new];
	NSError *error = nil;
	if ([fileManager fileExistsAtPath:destinationPath]) {
		[fileManager removeItemAtPath:destinationPath error:&error];
	}
	if (error) {
		FNLOG(@"%@, %@, %@, %@", error.localizedDescription, error.localizedFailureReason, error.localizedRecoveryOptions, error.localizedRecoverySuggestion);
	} else {
		[fileManager moveItemAtURL:location toURL:[NSURL fileURLWithPath:destinationPath] error:&error];
		if (error) {
			FNLOG(@"%@, %@, %@, %@", error.localizedDescription, error.localizedFailureReason, error.localizedRecoveryOptions, error.localizedRecoverySuggestion);
		}
	}
	
	completionBlock();
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {

}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {

}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
	_backgroundDownloadIsInProgress = NO;

	if (error) {
//		FNLOG(@"%ld, %@, %@, %@", (long)error.code, error.localizedDescription, error.localizedFailureReason, error.localizedRecoveryOptions);
		if (error.code == -1100) {
			[_downloadList removeObjectAtIndex:0];
		}
		if (error.code == -997) {
			_downloadList = nil;
			_backgroundDownloadSession = nil;
			return;
		}
		if ([self.reachability isReachableViaWiFi]) {
			[self startDownloadDataFiles];
		}
	}
}

#pragma mark - HolidayNations

- (void)updateHolidayNations {
	dispatch_async(dispatch_get_main_queue(), ^{
		if ([CLLocationManager locationServicesEnabled]) {
			if (!_locationManager) {
				_locationManager = [[CLLocationManager alloc] init];
				_locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
				_locationManager.delegate = self;
			}

			if ([CLLocationManager authorizationStatus] < kCLAuthorizationStatusAuthorizedAlways) {
				[HolidayData resetFirstCountryWithLocale];

                [_locationManager requestWhenInUseAuthorization];
			}

			[_locationManager startUpdatingLocation];

			if (_locationUpdateTimer) {
				[_locationUpdateTimer invalidate];
				_locationUpdateTimer = nil;
			}
 			_locationUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:120 target:self selector:@selector(locationDidNotRespond) userInfo:nil repeats:NO];
		} else {
			// 위치 정보 접근이 제한되어 있는 경우에는 autoupdatingCurrentLocale에서 정보를 읽어 휴일 국가 목록을 업데이트 한다.
			[HolidayData resetFirstCountryWithLocale];

			double delayInSeconds = 20.0;
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				[self addDownloadTasksForHolidayImages];
			});
		}
	});
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	FNLOG();
	[_locationUpdateTimer invalidate];
	_locationUpdateTimer = nil;

	[_locationManager stopMonitoringSignificantLocationChanges];
	_locationManager = nil;

	CLLocation *location = locations[0];
	CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
	NSMutableArray *countries = [[HolidayData userSelectedCountries] mutableCopy];
	[geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placeMarks, NSError *error) {
		NSString *_countryCodeOfCurrentLocation;
		for (CLPlacemark *placeMark in placeMarks) {
			_countryCodeOfCurrentLocation = [placeMark.addressDictionary[@"CountryCode"] lowercaseString];
		}

		if ([_countryCodeOfCurrentLocation length]) {
			NSArray *supportedCountries = [HolidayData supportedCountries];
			NSInteger indexOfCountry = [supportedCountries indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
				return [_countryCodeOfCurrentLocation isEqualToString:obj[kHolidayCountryCode]];
			}];

			if (indexOfCountry == NSNotFound)
				return;

			if (![countries[0] isEqualToString:_countryCodeOfCurrentLocation]) {
				
				[countries removeObject:_countryCodeOfCurrentLocation];
				[countries insertObject:_countryCodeOfCurrentLocation atIndex:0];

				[HolidayData setUserSelectedCountries:countries];

				[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationHolidaysCountryListChanged object:nil];
			}
		}
		double delayInSeconds = 20.0;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			[self addDownloadTasksForHolidayImages];
		});
	}];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	FNLOG();
	[_locationUpdateTimer invalidate];
	_locationUpdateTimer = nil;

	[_locationManager stopMonitoringSignificantLocationChanges];
	_locationManager = nil;
	
	[self addDownloadTasksForHolidayImages];
}

- (void)locationDidNotRespond {
	[_locationUpdateTimer invalidate];
	_locationUpdateTimer = nil;

	[_locationManager stopMonitoringSignificantLocationChanges];
	_locationManager = nil;
	[self addDownloadTasksForHolidayImages];
}

- (void)addDownloadTasksForHolidayImages {
	NSArray *holidayCountries = [HolidayData userSelectedCountries];
	A3HolidaysFlickrDownloadManager *downloadManager = [A3HolidaysFlickrDownloadManager sharedInstance];
	if ([holidayCountries count]) {
		NSString *countryCode = holidayCountries[0];
		NSString *imagePath = [downloadManager holidayImagePathForCountryCode:countryCode];
		if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
			[downloadManager addDownloadTaskForCountryCode:countryCode];
		}
	}
}

- (MBProgressHUD *)hud {
	if (!_hud) {
		UIView *targetViewForHud = [[self visibleViewController] view];
		_hud = [MBProgressHUD showHUDAddedTo:targetViewForHud animated:YES];
		_hud.minShowTime = 2;
		_hud.removeFromSuperViewOnHide = YES;
		__typeof(self) __weak weakSelf = self;
		self.hud.completionBlock = ^{
			weakSelf.hud = nil;
		};
	}
	return _hud;
}

#pragma mark - Setup Core Data Managed Object Context

- (void)setupAfterLoadCoredata {
    NSManagedObjectModel *model = [A3SyncManager sharedSyncManager].persistentContainer.managedObjectModel;
    if ([self deduplicateDatabaseWithModel:model]) {
        // 중복 데이터가 발견되었다면, 동기화를 끄고, 사용자에게 새로 시작하도록 안내를 한다.
        if ([[A3UserDefaults standardUserDefaults] boolForKey:A3SyncManagerCloudEnabled]) {
            A3SyncManager *sharedSyncManager = [A3SyncManager sharedSyncManager];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            sharedSyncManager.storePath = [[fileManager storeURL] path];
            [sharedSyncManager setupEnsemble];
            [sharedSyncManager disableCloudSync];
            
            [[A3UserDefaults standardUserDefaults] removeObjectForKey:A3SyncManagerCloudEnabled];
            [[A3UserDefaults standardUserDefaults] synchronize];
            
            UIAlertView *alertSyncDisabled = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
                                                                        message:NSLocalizedString(@"iCloud Sync is disabled due to duplicated records in your data. Tap Help to enable sync again.", nil)
                                                                       delegate:self
                                                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                              otherButtonTitles:NSLocalizedString(@"Help", @"Help"), nil];
            alertSyncDisabled.tag = 31;
            [alertSyncDisabled show];
        }
    } else {
        if ([[A3UserDefaults standardUserDefaults] boolForKey:A3SyncManagerCloudEnabled]) {
            A3SyncManager *sharedSyncManager = [A3SyncManager sharedSyncManager];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            sharedSyncManager.storePath = [[fileManager storeURL] path];
            [sharedSyncManager setupEnsemble];
            [sharedSyncManager synchronizeWithCompletion:NULL];
            [sharedSyncManager uploadMediaFilesToCloud];
            [sharedSyncManager downloadMediaFilesFromCloud];
        }
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:nil];
        
    [A3DaysCounterModelManager reloadAlertDateListForLocalNotification];
    [A3LadyCalendarModelManager setupLocalNotification];
    
    CredentialIdentityStoreManager *manager = [CredentialIdentityStoreManager new];
    [manager updateCredentialIdentityStore];
}

- (void)setupContext
{
    [self setupStoreFiles];
    
    A3SyncManager *syncManager = [A3SyncManager sharedSyncManager];
    if (!syncManager.persistentContainer) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:@[bundle]];
        syncManager.persistentContainer = [[NSPersistentContainer alloc] initWithName:@"AppBoxStore" managedObjectModel:model];
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSPersistentStoreDescription *storeDescription = [NSPersistentStoreDescription persistentStoreDescriptionWithURL:[fileManager storeURL]];
    syncManager.persistentContainer.persistentStoreDescriptions = @[storeDescription];
    [syncManager.persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription * _Nonnull psd, NSError * _Nullable error) {
        // Do nothing for the moment.
        if (error == nil) {
            self.isCoreDataReady = YES;
            [self setupAfterLoadCoredata];
        }
    }];
}

- (void)setupStoreFiles {
    // 2023년 3월 13일 - MagicalRecord 제거 시작
    // Library folder 아래로 AppBoxPro 폴더를 만들고, AppBoxStore.sqlite를 찾는다.
    // 만약 해당 파일이 없다면 oldStorePath를 찾아서 해당 파일이 있으면 옮기고 없으면 loadPersistentContainer를 할 때 새롭게 생성이 될거라고 믿는다.
    
    // 아래의 코드는 만약 예전 데이터가 존재한다는 의미는 4.7.0~4.7.1에서 데이터를 옮기지 못헀다는 것을 의미한다.
    // 만약 예전 데이터가 존재한다면 그것은 무조건 옮겨야 한다.
    
    // $containerURL/Library/AppBox 폴더를 찾는다.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *URL_after_V4_7 = [fileManager storeURL];
    
    // - URL-after-V4-7, URL-before-V4-7, URL before version
    NSURL *URL_before_V4_7 = [NSPersistentContainer defaultDirectoryURL];
    URL_before_V4_7 = [URL_before_V4_7 URLByAppendingPathComponent:@"AppBox3"];
    URL_before_V4_7 = [URL_before_V4_7 URLByAppendingPathComponent:[fileManager storeFileName]];
    
    // 만약 4_7 이전 파일이 존재한다면, 이 파일을 옮겨야 합니다.
    if ([fileManager fileExistsAtPath:[URL_before_V4_7 path]]) {
        // Move files (AppBoxStore.sqlite, AppBoxStore.sqlite-shm, AppBoxStore.sqlite-wal) to URL_after_V4_7
        NSString *path_after_V4_7 = [[URL_after_V4_7 URLByDeletingLastPathComponent] path];
        NSString *path_before_V4_7 = [[URL_before_V4_7 URLByDeletingLastPathComponent] path];
        NSError *createDirError = nil;
        if (![fileManager fileExistsAtPath:path_after_V4_7]) {
            [fileManager createDirectoryAtPath:path_after_V4_7 withIntermediateDirectories:YES attributes:nil error:&createDirError];
            if (createDirError) {
                FNLOG(@"%@", createDirError);
                return;
            }
        }
        
        // Move AppBoxStore.sqlite
        NSError *fileMoveError = nil;
        // 이동하기 전에 해당 파일이 있다면 지워준다.
        if ([fileManager fileExistsAtPath:[URL_after_V4_7 path]]) {
            [fileManager removeItemAtURL:URL_after_V4_7 error:&fileMoveError];
        }
        [fileManager moveItemAtURL:URL_before_V4_7 toURL:URL_after_V4_7 error:&fileMoveError];
        if (fileMoveError) {
            FNLOG(@"%@", fileMoveError);
            return;
        }
        
        // Move AppBoxStore.sqlite-shm
        NSString *storeFilename = [fileManager storeFileName];
        NSURL *URL_after_shm_file = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@-shm", path_after_V4_7, storeFilename]];
        if ([fileManager fileExistsAtPath:[URL_after_shm_file path]]) {
            [fileManager removeItemAtURL:URL_after_shm_file error:&fileMoveError];
        }
        NSURL *URL_before_shm_file = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@-shm", path_before_V4_7, storeFilename]];
        [fileManager moveItemAtURL:URL_before_shm_file toURL:URL_after_shm_file error:&fileMoveError];
        if (fileMoveError) {
            FNLOG(@"%@", fileMoveError);
            return;
        }
        
        NSURL *URL_after_wal_file = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@-wal", path_after_V4_7, storeFilename]];
        if ([fileManager fileExistsAtPath:[URL_after_wal_file path]]) {
            [fileManager removeItemAtURL:URL_after_wal_file error:&fileMoveError];
        }
        NSURL *URL_before_wal_file = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@-wal", path_before_V4_7, storeFilename]];
        [fileManager moveItemAtURL:URL_before_wal_file toURL:URL_after_wal_file error:&fileMoveError];
        if (fileMoveError) {
            FNLOG(@"%@", fileMoveError);
        }
    }
}

- (void)managedObjectContextDidSave:(NSNotification *)notification {
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10")) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            [self registerDeviceTokenToAPNServerWithToken:devToken
                                             userSettings:
             @[settings.badgeSetting == UNNotificationSettingEnabled ? @"enabled" : @"disabled",
               settings.alertSetting == UNNotificationSettingEnabled ? @"enabled" : @"disabled",
               settings.soundSetting == UNNotificationSettingEnabled ? @"enabled" : @"disabled",
               ]
             ];
        }];
    } else {
        UIUserNotificationSettings *settings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        [self registerDeviceTokenToAPNServerWithToken:devToken
                                         userSettings:
         @[settings.types & UIUserNotificationTypeBadge ? @"enabled" : @"disabled",
           settings.types & UIUserNotificationTypeAlert ? @"enabled" : @"disabled",
           settings.types & UIUserNotificationTypeSound ? @"enabled" : @"disabled",]
         ];
    }
}

- (void)registerDeviceTokenToAPNServerWithToken:(NSData *)deviceTokenData userSettings:(NSArray<NSString *> *)userSettings {
    // Get Bundle Info for Remote Registration (handy if you have more than one app)
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    NSString *urlString;
    
    // Prepare the Device Token for Registration (remove spaces and < >)
    NSString *deviceToken = [[[[deviceTokenData description]
                               stringByReplacingOccurrencesOfString:@"<"withString:@""]
                              stringByReplacingOccurrencesOfString:@">" withString:@""]
                             stringByReplacingOccurrencesOfString: @" " withString: @""];
    _deviceToken = deviceToken;
    
    // Get the users Device Model, Display Name, Unique ID, Token & Version Number
    UIDevice *device = [UIDevice currentDevice];
    NSString *identifierForVendor = [[device identifierForVendor] UUIDString];
    
    NSString *deviceName = [device name];
    NSString *deviceModel = [A3UIDevice platformString];
    NSString *deviceSystemVersion = device.systemVersion;
    NSString *localeIdentifier = [[NSLocale currentLocale] localeIdentifier];
    NSString *timezone = [[NSTimeZone systemTimeZone] description];
    
    urlString = [[NSString stringWithFormat:
                  @"https://apns.allaboutapps.net/apns/apns.php?task=%@&appname=%@&appversion=%@&deviceuid=%@&devicetoken=%@&devicename=%@&devicemodel=%@&deviceversion=%@&localeIdentifier=%@&timezone=%@&pushbadge=%@&pushalert=%@&pushsound=%@", @"register",
                  appName,
                  appVersion,
                  identifierForVendor,
                  deviceToken,
                  deviceName,
                  deviceModel,
                  deviceSystemVersion,
                  localeIdentifier,
                  timezone,
                  userSettings[0],  // Badge
                  userSettings[1],  // Alert
                  userSettings[2]   // Sound
                  ]
                 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    FNLOG(@"%@", urlString);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    AFHTTPRequestOperation *registerOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [registerOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self fetchPushNotification];
    } failure:NULL];
    
    [registerOperation start];
    
    /*
     // !!! CHANGE "/apns.php?" TO THE PATH TO WHERE apns.php IS INSTALLED
     // !!! ( MUST START WITH / AND END WITH ? ).
     // !!! SAMPLE: "/path/to/apns.php?"
     NSString *urlString = [NSString stringWithFormat:@"/apns/apns.php?task=%@&appname=%@&appversion=%@&deviceuid=%@&devicetoken=%@&devicename=%@&devicemodel=%@&deviceversion=%@&pushbadge=%@&pushalert=%@&pushsound=%@", @"register", appName,appVersion, deviceUuid, deviceToken, deviceName, deviceModel, deviceSystemVersion, pushBadge, pushAlert, pushSound];
     
     // Build URL String for Registration
     // !!! CHANGE "www.mywebsite.com" TO YOUR WEBSITE. Leave out the http://
     // !!! SAMPLE: "secure.awesomeapp.com"
     NSString *host = @"apns.allaboutapps.net";
     
     // Register the Device Data
     // !!! CHANGE "http" TO "https" IF YOU ARE USING HTTPS PROTOCOL
     NSURL *url = [[NSURL alloc] initWithScheme:@"http" host:host path:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
     NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
     NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
     NSLog(@"Register URL: %@", url);
     NSLog(@"Return Data: %@", returnData);
     */
}

- (void)fetchPushNotification {
	NSString *urlString = [NSString stringWithFormat:@"https://apns.allaboutapps.net/apns/apns.php?task=message&devicetoken=%@", _deviceToken];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	AFHTTPRequestOperation *fetchOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	fetchOperation.responseSerializer = [AFJSONResponseSerializer serializer];
	[fetchOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id message) {
		if (message) {
			[self application:[UIApplication sharedApplication] didReceiveRemoteNotification:message];
		}
	} failure:NULL];
	[fetchOperation start];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	FNLOG(@"Error in registration. Error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {

	FNLOG(@"remote notification: %@",[userInfo description]);
	NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];

#ifdef DEBUG
	NSString *alert = [apsInfo objectForKey:@"alert"];
	FNLOG(@"Received Push Alert: %@", alert);

	NSString *sound = [apsInfo objectForKey:@"sound"];
	FNLOG(@"Received Push Sound: %@", sound);

	NSString *badge = [apsInfo objectForKey:@"badge"];
	FNLOG(@"Received Push Badge: %@", badge);
#endif
	
	application.applicationIconBadgeNumber = 0;

	NSString *url = [userInfo objectForKey:@"url"];
	NSString *urlTitle = [userInfo objectForKey:@"urlTitle"];
	if (![urlTitle length]) {
		urlTitle = url;
	}
	self.alertURLString = url;
	NSString *alertTitle = [userInfo objectForKey:@"alertTitle"];

	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle message:[apsInfo objectForKey:@"alert"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	alertView.tag = ABAD_ALERT_PUSH_ALERT;
	if ([url length]) {
		[alertView addButtonWithTitle:urlTitle];
	}
	[alertView show];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    if (notificationSettings.types != UIUserNotificationTypeNone) {
        [application registerForRemoteNotifications];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationsUserNotificationSettingsRegistered object:notificationSettings];
}

- (void)applicationProtectedDataWillBecomeUnavailable:(UIApplication *)application {
	FNLOG();
}

- (void)applicationProtectedDataDidBecomeAvailable:(UIApplication *)application {
	FNLOG();
}

#pragma mark - Google AdMob

- (BOOL)shouldPresentAd {
	return _shouldPresentAd;
}

- (void)evaluateSubscriptionWithCompletion:(void (^)(void))completion {
    [AppTransactionManager isPaidForAppWithCompletionHandler:^(BOOL isPaid, NSDate *purchaseDate) {
        self->_isOldPaidUser = isPaid;
        self->_originalPurchaseDate = purchaseDate;
        
        // 3.5 포함 이전 버전 구매자의 경우에는 패스
        if (isPaid) {
            self->_shouldPresentAd = NO;
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion();
                });
            }
            return;
        }
        
        // RemoveAds 구매 여부와 Subscription 가입 여부를 확인한다.
        
        [AppTransactionManager checkSubscriptionStatusWithCompletionHandler:^(BOOL isPaymentActive, BOOL hasAdsFreePass, NSDate * _Nullable expiration, NSError * _Nullable error) {
            self->_isOldPaidUser = isPaymentActive;
            self->_hasAdsFreePass = hasAdsFreePass;
            self->_expirationDate = expiration;
            
            // 앱 구입한지 일주일이 안 되었다면 광고를 표출하지 않는다.
            // 매번 광고를 표시할 지 결정할 때, 두가지를 봐야 하는 구나.
            // 앱 구입일자, 마지막 광고를 표시한 날짜 - 왜냐하면 전면 광고는 한시간에 한 번만 표시하니까
            // 광고 표시 결정하는 코드에서 구입일자도 비교하도록 수정을 해야 겠다.
            if ([[NSDate date] timeIntervalSinceDate:purchaseDate] < 60*60*24*7) {
                self->_shouldPresentAd = NO;
            } else {
                self->_shouldPresentAd = !isPaymentActive && !hasAdsFreePass;
            }
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion();
                });
            }
        }];
        
    }];
}

#pragma mark - AdMob

- (GADRequest *)adRequestWithKeywords:(NSArray *)keywords {
	GADRequest *adRequest = [GADRequest request];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kA3AdsUserDidSelectPersonalizedAds]) {
        GADExtras *extras = [[GADExtras alloc] init];
        extras.additionalParameters = @{@"npa": @"1"};
        [adRequest registerAdNetworkExtras:extras];
    }
	adRequest.keywords = keywords;
	return adRequest;
}

- (void)setupAdInterstitialForAdUnitID:(NSString *)adUnitID keywords:(NSArray *)keywords {
	_adRequest = [self adRequestWithKeywords:keywords];
    [GADInterstitialAd loadWithAdUnitID:adUnitID
                                request:_adRequest
                      completionHandler:^(GADInterstitialAd * _Nullable interstitialAd, NSError * _Nullable error) {
        if (error) {
            FNLOG(@"%@", error.localizedDescription);
            return;
        }
        self.adInterstitial = interstitialAd;
        self.adInterstitial.fullScreenContentDelegate = self;
        
        if (self.passcodeViewController.view.superview) {
            FNLOG(@"Cancel presenting Interstitial ads. Visible view controller is Passcode View controller.");
            return;
        }
        UINavigationController *navigationController = self.currentMainNavigationController;
        while ([navigationController.presentedViewController isKindOfClass:[UINavigationController class]]) {
            navigationController = (id)navigationController.presentedViewController;
        }
        if (!navigationController.presentedViewController) {
            [self.adInterstitial presentFromRootViewController:navigationController];
        }
    }];
}

/// Tells the delegate that the ad will present full screen content.
- (void)adWillPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    _statusBarHiddenBeforeAdsAppear = [[UIApplication sharedApplication] isStatusBarHidden];
    _statusBarStyleBeforeAdsAppear = [[UIApplication sharedApplication] statusBarStyle];
    
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    });

    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:A3AdsDisplayTime];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:A3NumberOfTimesOpeningSubApp];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.adDisplayedAfterApplicationDidBecomeActive = YES;
}

/// Tells the delegate that the ad will dismiss full screen content.
- (void)adWillDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    [[UIApplication sharedApplication] setStatusBarHidden:_statusBarHiddenBeforeAdsAppear];
    [[UIApplication sharedApplication] setStatusBarStyle:_statusBarStyleBeforeAdsAppear];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationsAdsWillDismissScreen object:nil];
}

/// Tells the delegate that the ad dismissed full screen content.
- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    
}

- (void)presentInterstitialAds {
    [self evaluateSubscriptionWithCompletion:^{
        if (!self.shouldPresentAd) {
            return;
        }
        
        if (self.adDisplayedAfterApplicationDidBecomeActive) {
            return;
        }
        
        NSDate *adsDisplayTime = [[NSUserDefaults standardUserDefaults] objectForKey:A3AdsDisplayTime];
    //    NSInteger numberOfTimesOpeningSubApp = [[NSUserDefaults standardUserDefaults] integerForKey:A3NumberOfTimesOpeningSubApp];
        if (!adsDisplayTime || [[NSDate date] timeIntervalSinceDate:adsDisplayTime] > 60 * 60)
        {
            if (@available(iOS 14, *)) {
                [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                    [self setupAdInterstitialForAdUnitID:A3InterstitialAdUnitID keywords:@[@"shopping", @"currency", @"wallet", @"holidays", @"calendar"]];
                }];
            } else {
                [self setupAdInterstitialForAdUnitID:A3InterstitialAdUnitID keywords:@[@"shopping", @"currency", @"wallet", @"holidays", @"calendar"]];
            }
            return;
        }
    }];
}

- (void)increaseNumberOfTimesOpenedSubappCount {
	NSInteger numberOfTimesOpeningSubApp = [[NSUserDefaults standardUserDefaults] integerForKey:A3NumberOfTimesOpeningSubApp];
	numberOfTimesOpeningSubApp++;
	[[NSUserDefaults standardUserDefaults] setInteger:numberOfTimesOpeningSubApp forKey:A3NumberOfTimesOpeningSubApp];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (MBProgressHUD *)hudView {
	if (!_hudView) {
		_hudView = [MBProgressHUD showHUDAddedTo:[[self visibleViewController] view] animated:YES];
		_hudView.minShowTime = 2;
		_hudView.removeFromSuperViewOnHide = YES;
		_hudView.completionBlock = ^{
            self->_hudView = nil;
		};
	}
	return _hudView;
}

#pragma mark - Alert What's New

- (void)askPersonalizedAdConsent {
    if (@available(iOS 14.5, *)) {
        return;
    }
    
    if (![self shouldPresentAd])
        return;
    
//    PACConsentInformation.sharedInstance.debugIdentifiers =
//    @[ ASIdentifierManager.sharedManager.advertisingIdentifier.UUIDString ];
//
//    PACConsentInformation.sharedInstance.debugGeography = PACDebugGeographyEEA;
    
    [PACConsentInformation.sharedInstance
     requestConsentInfoUpdateForPublisherIdentifiers:@[ @"pub-0532362805885914" ]
     completionHandler:^(NSError *_Nullable error) {
         if (error) {
             // Consent info update failed.
         } else {
             // Consent info update succeeded. The shared PACConsentInformation
             // instance has been updated.
             if (PACConsentInformation.sharedInstance.consentStatus == PACConsentStatusUnknown) {
                 NSURL *privacyURL = [NSURL URLWithString:@"https://policies.google.com/privacy"];
                 PACConsentForm *form = [[PACConsentForm alloc] initWithApplicationPrivacyPolicyURL:privacyURL];
                 form.shouldOfferPersonalizedAds = YES;
                 form.shouldOfferNonPersonalizedAds = YES;
                 form.shouldOfferAdFree = NO;
                 [form loadWithCompletionHandler:^(NSError *_Nullable error) {
                     NSLog(@"Load complete. Error: %@", error);
                     if (error) {
                         // Handle error.
                     } else {
                         // Load successful.
                         [form presentFromViewController:IS_IPHONE ? self.rootViewController_iPhone : self.rootViewController_iPad
                                       dismissCompletion:^(NSError *_Nullable error, BOOL userPrefersAdFree) {
                                           if (error) {
                                               // Handle error.
                                           } else {
                                               // Check the user's consent choice.
                                               PACConsentStatus status = PACConsentInformation.sharedInstance.consentStatus;
                                               [[NSUserDefaults standardUserDefaults]
                                                setBool:status == PACConsentStatusPersonalized
                                                forKey:kA3AdsUserDidSelectPersonalizedAds];
                                           }
                                       }];
                     }
                 }];
                 
             }
         }
     }];
}

@end
