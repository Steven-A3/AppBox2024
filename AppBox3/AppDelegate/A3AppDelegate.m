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
#import "A3AppDelegate+passcode.h"
#import "UIViewController+A3Addition.h"
#import "A3LadyCalendarModelManager.h"
#import "A3NavigationController.h"
#import "A3HomeStyleMenuViewController.h"
#import "WalletFieldItem+initialize.h"
#import <CoreMotion/CoreMotion.h>
#import "TJDropbox.h"
#import "ACSimpleKeychain.h"
#import "UIView+SBExtras.h"
#import "FXBlurView.h"
#import "UIImage+imageWithColor.h"
#import "NYXImagesKit.h"
@import UserNotifications;
#import <FirebaseCore/FirebaseCore.h>
#import <AdSupport/AdSupport.h>
#import "TJDropboxAuthenticator.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"
#import "AppBox3-Swift.h"
#import <AppBoxKit/AppBoxKit.h>
#import <AppBoxKit/AppBoxKit-Swift.h>
#import "A3UIDevice.h"
#import "A3UserDefaults+A3Addition.h"
#import "UIViewController+extension.h"

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

@interface A3AppDelegate () <UIAlertViewDelegate, NSURLSessionDownloadDelegate, CLLocationManagerDelegate, GADFullScreenContentDelegate, UNUserNotificationCenterDelegate>

@property (nonatomic, strong) NSDictionary *localNotificationUserInfo;
@property (nonatomic, strong) NSMutableArray *downloadList;
@property (nonatomic, strong) NSURLSession *backgroundDownloadSession;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSTimer *locationUpdateTimer;
@property (nonatomic, copy) NSString *deviceToken;
@property (nonatomic, copy) NSString *alertURLString;
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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#ifdef  DEBUG
    [self experiments];
#endif

    [FIRApp configure];
    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];
    
    BOOL shouldPerformAdditionalDelegateHandling = [self shouldPerformAdditionalDelegateHandling:launchOptions];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{kA3SettingsMainMenuStyle:A3SettingsMainMenuStyleIconGrid}];

    _shouldPresentAd = YES;
    _expirationDate = [NSDate distantPast];
    _passcodeFreeBegin = [[NSDate distantPast] timeIntervalSinceReferenceDate];
    _appIsNotActiveYet = YES;

    _previousVersion = [[A3UserDefaults standardUserDefaults] objectForKey:kA3ApplicationLastRunVersion];
    NSString *activeVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryAmbient error:nil];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.tintColor = [[A3UserDefaults standardUserDefaults] themeColor];

    [self prepareDirectories];
    
    CoreDataStack *stack = [CoreDataStack shared];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRemoteChange:) name:NSPersistentStoreRemoteChangeNotification object:nil];
    
    [stack setupStackWithCompletion:^{
        FNLOG(@"Completion of setupStackWithCompletion");
        
        if (!self->_previousVersion) {
            // 이 값이 없다는 것은 설치되고 나서 실행된 적이 없다는 것을 의미함
            // 한번이라도 실행이 되었다면 이 값이 설정되어야 한다.
            self->_firstRunAfterInstall = YES;
            [A3KeychainUtils removePassword];
            [self initializePasscodeUserDefaults];
            
            [self favoriteMenuDictionary];
            
            [self setDefaultValues];
            
            [[A3UserDefaults standardUserDefaults] setObject:activeVersion forKey:kA3ApplicationLastRunVersion];
            [[A3UserDefaults standardUserDefaults] synchronize];
            
            iCloudFileManager *fileManager = [[iCloudFileManager alloc] init];
            [fileManager downloadMediaFilesToAppGroupWithProgressHandler:^(NSNumber * _Nonnull progress) {
                
            } completion:^(NSError * _Nullable error) {
                
            }];
            
            [self setupMainMenuViewController];
            [self handleNotification:launchOptions];
            [self addNotificationObservers];
        } else if (![self->_previousVersion isEqualToString:activeVersion]) {
            // First run after update.
            
            if ([self->_previousVersion compare:@"4.7.7" options:NSNumericSearch] == NSOrderedAscending) {
                [self migrateV47StoreFilesToAfterV48];
            }
            if ([self->_previousVersion compare:@"4.8" options:NSNumericSearch] == NSOrderedAscending) {
                [self migratePre2024MediaFiles];
            }

            NSURL *storeURL = [stack V47StoreURL];
            NSPersistentContainer *container = [stack loadPersistentContainerWithModelName:@"AppBox3" storeURL:storeURL];
            MigrationHostingViewController *vc =
            [[MigrationHostingViewController alloc] initWithOldPersistentContainer:container
                                                                        completion:^{
                [self setupMainMenuViewController];
                [self handleNotification:launchOptions];
                [self addNotificationObservers];
                
                [[A3UserDefaults standardUserDefaults] setObject:activeVersion forKey:kA3ApplicationLastRunVersion];
                [[A3UserDefaults standardUserDefaults] synchronize];
            }];
            self.window.rootViewController = vc;
        } else {
            [self setupMainMenuViewController];
            [self handleNotification:launchOptions];
            [self addNotificationObservers];
        }
        
        [self.window makeKeyAndVisible];
    }];

    return shouldPerformAdditionalDelegateHandling;
}

- (void)updateStartOption {
    _startOptionOpenClockOnce = [[NSUserDefaults standardUserDefaults] boolForKey:A3UserDefaultsStartOptionOpenClockOnce];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:A3UserDefaultsStartOptionOpenClockOnce];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

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
    if (!_previousVersion) {
        return;
    }
    if ([_previousVersion length] > 4 && [[_previousVersion substringToIndex:3] doubleValue] < 3.3) {
        FNLOG(@"%@", @([[_previousVersion substringToIndex:3] doubleValue]));
        // 3.3 이전버전에서 업데이트 한 경우
        // V3.3 부터 Touch ID가 추가되고 Touch ID 활성화가 기본
        // Touch ID가 활성화된 경우, passcode timer를 쓸 수 없도록 하였으므로 0으로 설정한다.
        // 3.3을 처음 설치한 경우에는 기본이 0이므로 별도 설정 불필요.
        [[A3UserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsKeyForPasscodeTimerDuration];
        [[A3UserDefaults standardUserDefaults] synchronize];
    }
    if ([_previousVersion length] > 4 && [[_previousVersion substringToIndex:3] doubleValue] < 3.4) {
        if (!_shouldMigrateV1Data) {
            [self migrateToV3_4_Holidays];
        }
    }
    if ([_previousVersion doubleValue] == 4.0) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:A3SettingsMainMenuHexagonShouldAddQRCodeMenu];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:A3SettingsMainMenuGridShouldAddQRCodeMenu];
    }
    if ([_previousVersion doubleValue] <= 4.1) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:A3SettingsMainMenuHexagonShouldAddPedometerMenu];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:A3SettingsMainMenuGridShouldAddPedometerMenu];
    }
    if ([_previousVersion doubleValue] < 4.5) {
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

- (void)handleNotification:(NSDictionary * _Nullable)launchOptions {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    
    // Check if the app was launched due to a notification
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        // Process the notification data if the app was launched by tapping the notification
        UNNotificationResponse *response = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        NSDictionary *userInfo = response.notification.request.content.userInfo;
        _localNotificationUserInfo = [userInfo copy];
        
        // Optionally handle the notification (e.g., cancel any pending actions)
        [self showReceivedLocalNotifications];
    }
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

//    __block UIBackgroundTaskIdentifier identifier;
//    identifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
//        [[UIApplication sharedApplication] endBackgroundTask:identifier];
//        identifier = UIBackgroundTaskInvalid;
//    }];
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
    
    // TODO: Dropbox V2 Pending work
//    UINavigationController *navigationController = [self navigationController];
//    UIViewController *topViewController = self.navigationController.topViewController;
//    if ([topViewController isKindOfClass:[A3SettingsBackupRestoreViewController class]] && ![[DBSession sharedSession] isLinked]) {
//        [navigationController popViewControllerAnimated:NO];
//    }
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self applicationDidBecomeActive_passcodeAfterLaunch:_appIsNotActiveYet];
    
    if (_appIsNotActiveYet) {
        _appIsNotActiveYet = NO;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
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

// Handle notification while app is in the foreground
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    completionHandler(UNNotificationPresentationOptionBanner|UNNotificationPresentationOptionSound);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    _localNotificationUserInfo = [response.notification.request.content.userInfo copy];
    [self showReceivedLocalNotifications];
    
    completionHandler();
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

#pragma mark - UIAlertViewDelegate

- (void)showDaysCounterDetail {
    if (!_localNotificationUserInfo[A3LocalNotificationDataID]) {
        return;
    }

    [A3DaysCounterModelManager reloadAlertDateListForLocalNotification];

    FNLOG(@"%@", _localNotificationUserInfo[A3LocalNotificationDataID]);

    DaysCounterEvent_ *eventItem = [DaysCounterEvent_ findFirstByAttribute:@"uniqueID" withValue:_localNotificationUserInfo[A3LocalNotificationDataID]];
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
    
    // Prepairing app group container and iCloud container.
    NSURL *appGroupContainerURL = [fileManager containerURLForSecurityApplicationGroupIdentifier:iCloudConstants.APP_GROUP_CONTAINER_IDENTIFIER];
    NSLog(@"App Group Container URL: %@", appGroupContainerURL);
    NSURL *iCloudContainerURL = [fileManager URLForUbiquityContainerIdentifier:iCloudConstants.ICLOUD_CONTAINER_IDENTIFIER];
    NSLog(@"iCloud container URL: %@", iCloudContainerURL);
    
    NSString *applicationSupportPath = [fileManager applicationSupportPath];
    if (![fileManager fileExistsAtPath:applicationSupportPath]) {
        [fileManager createDirectoryAtPath:applicationSupportPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    if ( ![fileManager fileExistsAtPath:[A3DaysCounterModelManager thumbnailDirectory]] ) {
        [fileManager createDirectoryAtPath:[A3DaysCounterModelManager thumbnailDirectory] withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    NSString *imageDirectory = [A3DaysCounterImageDirectory pathInAppGroupContainer];
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
//    [_downloadList addObject:[NSURL URLWithString:@"http://www.allaboutapps.net/data/message.plist"]];

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
        if ([self->_downloadList count]) {
            NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:self->_downloadList[0]];
            NSURLSessionDownloadTask *downloadTask = [self.backgroundDownloadSession downloadTaskWithRequest:downloadRequest];
            [downloadTask resume];
        }
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    void (^completionBlock)(void) = ^() {
        self->_backgroundDownloadIsInProgress = NO;
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
    
    NSString *destinationPath =    [@"data" pathInCachesDirectory];
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
//        FNLOG(@"%ld, %@, %@, %@", (long)error.code, error.localizedDescription, error.localizedFailureReason, error.localizedRecoveryOptions);
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
        // 위치 정보 접근이 제한되어 있는 경우에는 autoupdatingCurrentLocale에서 정보를 읽어 휴일 국가 목록을 업데이트 한다.
        [HolidayData resetFirstCountryWithLocale];
        
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self addDownloadTasksForHolidayImages];
        });
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
        NSString *countryCodeOfCurrentLocation;
        CLPlacemark *placeMark = [placeMarks lastObject];
        countryCodeOfCurrentLocation = [placeMark.ISOcountryCode lowercaseString];

        if ([countryCodeOfCurrentLocation length]) {
            NSArray *supportedCountries = [HolidayData supportedCountries];
            NSInteger indexOfCountry = [supportedCountries indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                return [countryCodeOfCurrentLocation isEqualToString:obj[kHolidayCountryCode]];
            }];

            if (indexOfCountry == NSNotFound)
                return;

            if (![countries[0] isEqualToString:countryCodeOfCurrentLocation]) {
                
                [countries removeObject:countryCodeOfCurrentLocation];
                [countries insertObject:countryCodeOfCurrentLocation atIndex:0];

                [HolidayData setUserSelectedCountries:countries];

                [[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationHolidaysCountryListChanged object:nil];
            }
        }
        double delayInSeconds = 10.0;
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
    NSPersistentContainer *container = CoreDataStack.shared.persistentContainer;
    if (!container) {
        return;
    }

    NSManagedObjectModel *model = container.managedObjectModel;
    if (!model) {
        return;
    }
    if ([self deduplicateDatabaseWithModel:model]) {
        FNLOG("Duplicated data has been detected and managed.");
    }

    [A3DaysCounterModelManager reloadAlertDateListForLocalNotification];
    [A3LadyCalendarModelManager setupLocalNotification];
    
    CredentialIdentityStoreManager *manager = [CredentialIdentityStoreManager new];
    [manager updateCredentialIdentityStore];
}

- (void)migrateV47StoreFilesToAfterV48 {
    // 2023년 3월 13일 - MagicalRecord 제거 시작
    // Library folder 아래로 AppBoxPro 폴더를 만들고, AppBoxStore.sqlite를 찾는다.
    // 만약 해당 파일이 없다면 oldStorePath를 찾아서 해당 파일이 있으면 옮기고 없으면 loadPersistentContainer를 할 때 새롭게 생성이 될거라고 믿는다.
    
    // 아래의 코드는 만약 예전 데이터가 존재한다는 의미는 4.7.0~4.7.1에서 데이터를 옮기지 못헀다는 것을 의미한다.
    // 만약 예전 데이터가 존재한다면 그것은 무조건 옮겨야 한다.
    
    // $containerURL/Library/AppBox 폴더를 찾는다.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *URL_after_V4_7 = [fileManager storeURL];
    URL_after_V4_7 = [URL_after_V4_7 URLByDeletingLastPathComponent];
    URL_after_V4_7 = [URL_after_V4_7 URLByAppendingPathComponent:[fileManager before2024StoreFilename]];
    // file:///Users/bkk/Library/Developer/CoreSimulator/Devices/0C8A79CE-B8F8-4A11-8A9E-8E9051C79CB5/data/Containers/Shared/AppGroup/CFE53790-05F4-46DD-9E02-7B000C7CB20A/Library/AppBox/AppBoxStore.sqlite
    
    // - URL-after-V4-7, URL-before-V4-7, URL before version
    NSURL *URL_before_V4_7 = [NSPersistentContainer defaultDirectoryURL];
    URL_before_V4_7 = [URL_before_V4_7 URLByAppendingPathComponent:@"AppBox3"];
    URL_before_V4_7 = [URL_before_V4_7 URLByAppendingPathComponent:[fileManager before2024StoreFilename]];
    // file:///Users/bkk/Library/Developer/CoreSimulator/Devices/0C8A79CE-B8F8-4A11-8A9E-8E9051C79CB5/data/Containers/Data/Application/BE9779CB-4DAE-467D-91CC-DCA9ED97E0F9/Library/Application%20Support/AppBox3/AppBoxStore.sqlite
    
    // Case 이전 버전 파일이 존재, 새 버전 파일도 존재 - 새 버전을 존중, 이전 버전 파일은 삭제
    // Case 이전 버전 파일이 존재, 새 버전 파일 없음 - 파일 이동

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
        // 새 버전 파일이 있다면, 기존 파일을 삭제하고 종료한다.
        if ([fileManager fileExistsAtPath:[URL_after_V4_7 path]]) {
            NSError *fileRemoveError = nil;
            [fileManager removeItemAtURL:URL_before_V4_7 error:&fileRemoveError];
            return;
        }
        
        // Move AppBoxStore.sqlite
        [fileManager moveItemAtURL:URL_before_V4_7 toURL:URL_after_V4_7 error:&fileMoveError];
        if (fileMoveError) {
            FNLOG(@"%@", fileMoveError);
            return;
        }
        
        // Move AppBoxStore.sqlite-shm
        NSString *storeFilename = [fileManager before2024StoreFilename];
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

- (void)migratePre2024MediaFiles {
    @try {
        MediaFileMover *mover = [[MediaFileMover alloc] init];
        
        NSError *error = nil;
        NSURL *libraryURL = [NSURL fileURLWithPath:NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0]];
        [mover moveMediaFilesFrom:libraryURL error:&error];
        
        if (error) {
            NSLog(@"Failed to move media files: %@", error.localizedDescription);
        } else {
            NSLog(@"Media files moved successfully.");
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception occurred: %@, %@", exception.name, exception.reason);
    }
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
    [AppTransactionManager isPaidForAppWithCompletionHandler:^(BOOL isPaid, NSString *originalAppVersion, NSDate *purchaseDate) {
        self->_isOldPaidUser = isPaid;
        self->_originalPurchaseDate = purchaseDate;
        self->_originalAppVersion = originalAppVersion;
        
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
            self->_removeAdsActive = isPaymentActive;
            self->_hasAdsFreePass = hasAdsFreePass;
            self->_expirationDate = expiration;
            
            // 앱 구입한지 3일이 안 되었다면 광고를 표출하지 않는다.
            // 매번 광고를 표시할 지 결정할 때, 두가지를 봐야 하는 구나.
            // 앱 구입일자, 마지막 광고를 표시한 날짜 - 왜냐하면 전면 광고는 한시간에 한 번만 표시하니까
            // 광고 표시 결정하는 코드에서 구입일자도 비교하도록 수정을 해야 겠다.
//            if ([[NSDate date] timeIntervalSinceDate:purchaseDate] < 0) {
            if ([[NSDate date] timeIntervalSinceDate:purchaseDate] < 60*60*24*3) {
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
    // Get the active window scene from the connected scenes
    UIWindowScene *windowScene = (UIWindowScene *)[UIApplication sharedApplication].connectedScenes.allObjects.firstObject;
    
    // Check if we have a valid window scene and status bar manager
    if (windowScene.statusBarManager != nil) {
        // Set the status bar style to light content
        _statusBarHiddenBeforeAdsAppear = windowScene.statusBarManager.statusBarHidden;
        _statusBarStyleBeforeAdsAppear = windowScene.statusBarManager.statusBarStyle;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:A3AdsDisplayTime];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:A3NumberOfTimesOpeningSubApp];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.adDisplayedAfterApplicationDidBecomeActive = YES;
}

/// Tells the delegate that the ad will dismiss full screen content.
- (void)adWillDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
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
        // 광고를 표시하기 전에 무조건 가입 화면을 제시하고, 가입하지 않으면 광고로 진입하게 한다.
        
        NSDate *adsDisplayTime = [[NSUserDefaults standardUserDefaults] objectForKey:A3AdsDisplayTime];
        if (nil == adsDisplayTime) {
            adsDisplayTime = [NSDate date];
            [[NSUserDefaults standardUserDefaults] setObject:adsDisplayTime forKey:A3AdsDisplayTime];
        }
        
        if ([[NSDate date] timeIntervalSinceDate:adsDisplayTime] > 60 * 60)
        {
            if (ATTrackingManager.trackingAuthorizationStatus == ATTrackingManagerAuthorizationStatusNotDetermined) {
                [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                }];
            } else {
                void (^setupAdInterstitialBlock)(void) = ^{
                    [self setupAdInterstitialForAdUnitID:A3InterstitialAdUnitID keywords:@[@"shopping", @"currency", @"wallet", @"holidays", @"calendar"]];
                };
                if (@available(iOS 17.0, *)) {
                    UIViewController *visibleViewController = [self visibleViewController];
                    [visibleViewController presentSubscriptionViewControllerWithCompletion:^{
                        [self evaluateSubscriptionWithCompletion:^{
                            if (!self.shouldPresentAd) {
                                return;
                            }
                            setupAdInterstitialBlock();
                        }];
                    }];
                } else {
                    setupAdInterstitialBlock();
                }
            }
            return;
        }
    }];
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

#ifdef  DEBUG
- (void)experiments {
    NSURL *targetBaseURL = [NSURL fileURLWithPath:NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0]];
    NSLog(@"%@", targetBaseURL);
}
#endif

@end
