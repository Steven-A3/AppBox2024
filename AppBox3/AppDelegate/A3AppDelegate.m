//
//  A3AppDelegate.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/25/11.
//  Copyright (c) 2011 ALLABOUTAPPS. All rights reserved.
//

#import <DropboxSDK/DropboxSDK.h>
#import <CoreLocation/CoreLocation.h>
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

NSString *const A3UserDefaultsStartOptionOpenClockOnce = @"A3StartOptionOpenClockOnce";
NSString *const A3DrawerStateChanged = @"A3DrawerStateChanged";
NSString *const A3DropboxLoginWithSuccess = @"A3DropboxLoginWithSuccess";
NSString *const A3DropboxLoginFailed = @"A3DropboxLoginFailed";
NSString *const A3LocalNotificationOwner = @"A3LocalNotificationOwner";
NSString *const A3LocalNotificationDataID = @"A3LocalNotificationDataID";
NSString *const A3LocalNotificationFromLadyCalendar = @"Ladies Calendar";
NSString *const A3LocalNotificationFromDaysCounter = @"Days Counter";
NSString *const A3NotificationCloudKeyValueStoreDidImport = @"A3CloudKeyValueStoreDidImport";
NSString *const A3NotificationCloudCoreDataStoreDidImport = @"A3CloudCoreDataStoreDidImport";
NSString *const A3NotificationsUserNotificationSettingsRegistered = @"A3NotificationsUserNotificationSettingsRegistered";

@interface A3AppDelegate () <UIAlertViewDelegate, NSURLSessionDownloadDelegate, CLLocationManagerDelegate
		#ifdef APPBOX3_FREE
		, GADInterstitialDelegate
		#endif
		>

@property (nonatomic, strong) NSString *previousVersion;
@property (nonatomic, strong) NSDictionary *localNotificationUserInfo;
@property (nonatomic, strong) UILocalNotification *storedLocalNotification;
@property (nonatomic, strong) NSMutableArray *downloadList;
@property (nonatomic, strong) NSURLSession *backgroundDownloadSession;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSTimer *locationUpdateTimer;
@property (nonatomic, copy) NSString *deviceToken;
@property (nonatomic, copy) NSString *alertURLString;

@end

@implementation A3AppDelegate {
	BOOL _appIsNotActiveYet;
	BOOL _backgroundDownloadIsInProgress;
	BOOL _needShowAlertV3_4NewFeature;
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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#ifdef DEBUG
	UIScreen *mainScreen = [UIScreen mainScreen];
	if ([mainScreen respondsToSelector:@selector(nativeBounds)]) {
		FNLOGRECT(mainScreen.nativeBounds);
		FNLOG(@"%f", mainScreen.nativeScale);
	}
	FNLOGRECT(mainScreen.bounds);
	FNLOG(@"%f", mainScreen.scale);
	FNLOG(@"%@", [NSLocale preferredLanguages][0]);
#endif
	
	_appIsNotActiveYet = YES;

	CDESetCurrentLoggingLevel(CDELoggingLevelNone);

	#ifdef APPBOX3_FREE
	self.googleAdInterstitial = [self createAndLoadInterstitial];
	#endif

	[self prepareDirectories];
	[A3SyncManager sharedSyncManager];

	[[NSUbiquitousKeyValueStore defaultStore] synchronize];

	[self setupContext];

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
			[A3KeychainUtils removePassword];
			[self initializePasscodeUserDefaults];
		}
	}
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
		if ([[_previousVersion substringToIndex:3] doubleValue] >= 3.0) {
			_needShowAlertV3_4NewFeature = YES;
		}
	}

	// AppBox Pro V1.8.4까지는 Days Until 기능의 옵션에 의해서 남은 일자에 대한 배지 기능이 있었습니다.
	// AppBox Pro V3.0 이후로는 배지 기능을 제공하지 않습니다.
	// 이 값은 초기화 합니다.
	[self clearScheduledOldVersionLocalNotifications];

	// toolsconf.db가 library directory에 남아 있으면 마이그레이션이 끝나지 않았으므로 확실히 점검한다.
	NSString *oldFilePath = [@"toolsconf.db" pathInLibraryDirectory];
	if ([[NSFileManager defaultManager] fileExistsAtPath:oldFilePath]) {
		_shouldMigrateV1Data = YES;
	}

	self.reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
	[self.reachability startNotifier];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];

	NSFileManager *fileManager = [NSFileManager new];
	[fileManager setupCacheStoreFile];

	UIViewController *rootViewController;
	if (IS_IPAD) {
		_rootViewController = [[A3RootViewController_iPad alloc] initWithNibName:nil bundle:nil];
		rootViewController = _rootViewController;
		_mainMenuViewController = _rootViewController.mainMenuViewController;
		[_rootViewController view];
		_currentMainNavigationController = _rootViewController.centerNavigationController;
	} else {
		_mainMenuViewController = [[A3MainMenuTableViewController alloc] init];
		UINavigationController *menuNavigationController = [[UINavigationController alloc] initWithRootViewController:_mainMenuViewController];

		UIViewController *viewController = [A3MainViewController new];
		A3NavigationController *navigationController = [[A3NavigationController alloc] initWithRootViewController:viewController];
		_currentMainNavigationController = navigationController;

		_drawerController = [[MMDrawerController alloc] initWithCenterViewController:navigationController leftDrawerViewController:menuNavigationController];
		_rootViewController_iPhone = _drawerController;

		[_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeBezelPanningCenterView];
		[_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
		[_drawerController setDrawerVisualStateBlock:[self slideAndScaleVisualStateBlock]];
		[_drawerController setCenterHiddenInteractionMode:MMDrawerOpenCenterInteractionModeFull];
		[_drawerController setGestureCompletionBlock:^(MMDrawerController *drawerController, UIGestureRecognizer *gesture) {
			[[NSNotificationCenter defaultCenter] postNotificationName:A3DrawerStateChanged object:nil];
			if (drawerController.openSide != MMDrawerSideLeft) {
				[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationMainMenuDidHide object:nil];
			}
		}];
		[_drawerController setMaximumLeftDrawerWidth:320.0];
		[_drawerController setShowsShadow:NO];

		_drawerController.view.frame = [[UIScreen mainScreen] bounds];

		rootViewController = _drawerController;
	}

	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.rootViewController = rootViewController;
	self.window.backgroundColor = [UIColor whiteColor];

	NSNumber *selectedColor = [[A3SyncManager sharedSyncManager] objectForKey:A3SettingsUserDefaultsThemeColorIndex];
	if (selectedColor) {
		self.window.tintColor = self.themeColors[[selectedColor unsignedIntegerValue]];
	}

	[self.window makeKeyAndVisible];

	[[A3UserDefaults standardUserDefaults] setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:kA3ApplicationLastRunVersion];
	[[A3UserDefaults standardUserDefaults] synchronize];

	[application registerForRemoteNotificationTypes:
			(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];

	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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
		NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_defaultContext];
		[managedObjectContext performBlock:^{
			if (managedObjectContext.hasChanges) {
				[managedObjectContext save:NULL];
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
	FNLOG();
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	[self applicationWillEnterForeground_passcode];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	_appIsNotActiveYet = NO;

	FNLOG();
	A3SyncManager *syncManager = [A3SyncManager sharedSyncManager];
	[syncManager synchronizeWithCompletion:NULL];
	if ([syncManager isCloudEnabled]) {
		[syncManager uploadMediaFilesToCloud];
		[syncManager downloadMediaFilesFromCloud];
	}

	UINavigationController *navigationController = [self navigationController];
	UIViewController *topViewController = self.navigationController.topViewController;
	if ([topViewController isKindOfClass:[A3SettingsBackupRestoreViewController class]] && ![[DBSession sharedSession] isLinked]) {
		[navigationController popViewControllerAnimated:NO];
	}
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	[self applicationDidBecomeActive_passcode];

	[self fetchPushNotification];

	[self updateHolidayNations];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
	[MagicalRecord cleanUp];
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {

	NSUInteger orientations;

	if (IS_IPAD) {
		orientations = UIInterfaceOrientationMaskAll;
	} else {
		A3NavigationController *navigationController = (A3NavigationController *) _drawerController.centerViewController;

		id<A3ViewControllerProtocol>visibleViewController = (id <A3ViewControllerProtocol>) [navigationController visibleViewController];
		if ([visibleViewController respondsToSelector:@selector(a3SupportedInterfaceOrientations)]) {
			orientations = [visibleViewController a3SupportedInterfaceOrientations];
		} else {
			orientations = UIInterfaceOrientationMaskPortrait;
		}
	}

	return orientations;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    FNLOG();
	if ([[DBSession sharedSession] handleOpenURL:url]) {
		if ([[DBSession sharedSession] isLinked]) {
			FNLOG(@"App linked successfully!");
			[[NSNotificationCenter defaultCenter] postNotificationName:A3DropboxLoginWithSuccess object:nil];
		} else {
			[[NSNotificationCenter defaultCenter] postNotificationName:A3DropboxLoginFailed object:nil];
		}
		return YES;
	}
	// Add whatever other url handling code your app requires here
	return NO;
}

#pragma mark Notification

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
	FNLOG(@"%@", [application scheduledLocalNotifications]);
	[scheduledNotifications enumerateObjectsUsingBlock:^(UILocalNotification *localNotification, NSUInteger idx, BOOL *stop) {
		if (localNotification.userInfo[@"kABPLocalNotificationTypeDaysUntil"] || localNotification.applicationIconBadgeNumber) {
			[application cancelLocalNotification:localNotification];
		}
	}];
	FNLOG(@"%@", [application scheduledLocalNotifications]);
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

	[A3DaysCounterModelManager reloadAlertDateListForLocalNotification:[NSManagedObjectContext MR_rootSavingContext]];

	FNLOG(@"%@", _localNotificationUserInfo[A3LocalNotificationDataID]);

	DaysCounterEvent *eventItem = [DaysCounterEvent MR_findFirstByAttribute:@"uniqueID" withValue:_localNotificationUserInfo[A3LocalNotificationDataID]];
	A3DaysCounterEventDetailViewController *viewController = [[A3DaysCounterEventDetailViewController alloc] init];
	viewController.isNotificationPopup = YES;
	viewController.eventItem = eventItem;
    A3DaysCounterModelManager *sharedManager = [[A3DaysCounterModelManager alloc] init];
    [sharedManager prepareInContext:[NSManagedObjectContext MR_defaultContext] ];
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

- (MMDrawerControllerDrawerVisualStateBlock)slideAndScaleVisualStateBlock{
	MMDrawerControllerDrawerVisualStateBlock visualStateBlock =
			^(MMDrawerController * drawerController, MMDrawerSide drawerSide, CGFloat percentVisible){
				CGFloat minScale = .95;
				CGFloat scale = minScale + (percentVisible*(1.0-minScale));
				CATransform3D scaleTransform =  CATransform3DMakeScale(scale, scale, scale);

				CGFloat maxDistance = 10;
				CGFloat distance = maxDistance * percentVisible;
				CATransform3D translateTransform;
				UIViewController * sideDrawerViewController;
				if(drawerSide == MMDrawerSideLeft) {
					sideDrawerViewController = drawerController.leftDrawerViewController;
					translateTransform = CATransform3DMakeTranslation((maxDistance-distance), 0.0, 0.0);
				}
				else if(drawerSide == MMDrawerSideRight){
					sideDrawerViewController = drawerController.rightDrawerViewController;
					translateTransform = CATransform3DMakeTranslation(-(maxDistance-distance), 0.0, 0.0);
				}

				[sideDrawerViewController.view.layer setTransform:CATransform3DConcat(scaleTransform, translateTransform)];
				[sideDrawerViewController.view setAlpha:percentVisible];
			};
	return visualStateBlock;
}

- (UINavigationController *)navigationController {
	if (IS_IPHONE) {
		return (UINavigationController *)self.drawerController.centerViewController;
	} else {
		return self.rootViewController.centerNavigationController;
	}
}

- (UIViewController *)visibleViewController {
	UINavigationController *navigationController = [self navigationController];
	return [navigationController visibleViewController];
}

- (NSCalendar *)calendar {
	if (!_calendar) {
		_calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	}
	return _calendar;
}

- (A3CacheStoreManager *)cacheStoreManager {
	if (!_cacheStoreManager) {
		_cacheStoreManager = [A3CacheStoreManager new];
	}
	return _cacheStoreManager;
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
		if (IS_IOS7) {
			NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"net.allaboutapps.backgroundTransfer.backgroundSession"];
			_backgroundDownloadSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
		} else {
			NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"net.allaboutapps.backgroundTransfer.backgroundSession"];
			_backgroundDownloadSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
		}
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
	[_downloadList addObject:[NSURL URLWithString:@"http://www.allaboutapps.net/data/FlickrRecommendation.json"]];
	[_downloadList addObject:[NSURL URLWithString:@"http://www.allaboutapps.net/data/device_information.json"]];

	NSFileManager *fileManager = [NSFileManager new];
	if ([A3UIDevice shouldSupportLunarCalendar]) {
		NSString *kanjiDataFile = [@"data/LunarConverter.sqlite" pathInCachesDirectory];
		if (![fileManager fileExistsAtPath:kanjiDataFile]) {
			[_downloadList addObject:[NSURL URLWithString:@"http://www.allaboutapps.net/data/LunarConverter.sqlite"]];
		}
	}
//	[_downloadList addObject:[NSURL URLWithString:@"http://www.allaboutapps.net/data/message.plist"]];

	[self startDownloadDataFiles];
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
	double delayInSeconds = IS_IOS7 ? 20.0 : 2.0;
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
	if ([_downloadList count]) {
		[_downloadList removeObjectAtIndex:0];
	}

	// Verify downloaded file contents.
	// device_information.json, FlickrRecommendation.json 모두 json이므로
	NSData *rawData = [NSData dataWithContentsOfURL:location];
	if (rawData) {
		NSError *error;
		NSArray *candidates = [NSJSONSerialization JSONObjectWithData:rawData options:0 error:&error];
		if (!error || candidates != nil) {
			NSString *filename = [downloadTask.originalRequest.URL lastPathComponent];
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
		}
	}
	
	_backgroundDownloadIsInProgress = NO;
	if ([self.reachability isReachableViaWiFi]) {
		[self startDownloadDataFiles];
	}
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

			if ([CLLocationManager authorizationStatus] < kCLAuthorizationStatusAuthorized) {
				[HolidayData resetFirstCountryWithLocale];

				if (!IS_IOS7 && [_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
					[_locationManager requestWhenInUseAuthorization];
				}
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

- (void)setupContext
{
	NSManagedObjectModel *model = [NSManagedObjectModel MR_newManagedObjectModelNamed:@"AppBox3.momd"];
	[NSManagedObjectModel MR_setDefaultManagedObjectModel:model];

	[MagicalRecord setShouldAutoCreateManagedObjectModel:NO];
	[MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:[self storeFileName]];

	self.managedObjectContext = [NSManagedObjectContext MR_defaultContext];

	if ([[A3UserDefaults standardUserDefaults] boolForKey:A3SyncManagerCloudEnabled]) {
		A3SyncManager *sharedSyncManager = [A3SyncManager sharedSyncManager];
		sharedSyncManager.storePath = [[self storeURL] path];
		[sharedSyncManager setupEnsemble];
		[sharedSyncManager synchronizeWithCompletion:NULL];
		[sharedSyncManager uploadMediaFilesToCloud];
		[sharedSyncManager downloadMediaFilesFromCloud];
	}

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:nil];
	
	_isCoreDataReady = YES;
}

- (void)managedObjectContextDidSave:(NSNotification *)notification {
	if (notification.object == self.cacheStoreManager.context) return;

    if (notification.object == [NSManagedObjectContext MR_defaultContext]) {
        NSManagedObjectContext *rootContext = [NSManagedObjectContext MR_rootSavingContext];
        [rootContext performBlockAndWait:^{
            [rootContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    } else if (notification.object == [NSManagedObjectContext MR_rootSavingContext]) {
        NSManagedObjectContext *mainContext = [NSManagedObjectContext MR_defaultContext];
        [mainContext performBlockAndWait:^{
            [mainContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
}

- (NSURL *)storeURL
{
	return [NSPersistentStore MR_urlForStoreName:[self storeFileName]];
}

- (NSString *)storeFileName {
	return @"AppBoxStore.sqlite";
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
	// Get Bundle Info for Remote Registration (handy if you have more than one app)
	NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
	NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	
	// Check what Notifications the user has turned on.  We registered for all three, but they may have manually disabled some or all of them.
	NSUInteger rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
	
	// Set the defaults to disabled unless we find otherwise...
	NSString *pushBadge = (rntypes & UIRemoteNotificationTypeBadge) ? @"enabled" : @"disabled";
	NSString *pushAlert = (rntypes & UIRemoteNotificationTypeAlert) ? @"enabled" : @"disabled";
	NSString *pushSound = (rntypes & UIRemoteNotificationTypeSound) ? @"enabled" : @"disabled";
	
	// Get the users Device Model, Display Name, Unique ID, Token & Version Number
	UIDevice *device = [UIDevice currentDevice];
	NSString *identifierForVendor = [[device identifierForVendor] UUIDString];

	NSString *deviceName = [device name];
	NSString *deviceModel = [A3UIDevice platformString];
	NSString *deviceSystemVersion = device.systemVersion;
	
	// Prepare the Device Token for Registration (remove spaces and < >)
	NSString *deviceToken = [[[[devToken description]
							   stringByReplacingOccurrencesOfString:@"<"withString:@""]
							  stringByReplacingOccurrencesOfString:@">" withString:@""]
							 stringByReplacingOccurrencesOfString: @" " withString: @""];
	_deviceToken = deviceToken;

	NSString *urlString = [[NSString stringWithFormat:@"http://apns.allaboutapps.net/apns/apns.php?task=%@&appname=%@&appversion=%@&deviceuid=%@&devicetoken=%@&devicename=%@&devicemodel=%@&deviceversion=%@&pushbadge=%@&pushalert=%@&pushsound=%@", @"register",
					appName,
					appVersion,
					identifierForVendor,
					deviceToken,
					deviceName,
					deviceModel,
					deviceSystemVersion,
					pushBadge,
					pushAlert,
					pushSound] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

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
	NSString *urlString = [NSString stringWithFormat:@"http://apns.allaboutapps.net/apns/apns.php?task=message&devicetoken=%@", _deviceToken];
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

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationsUserNotificationSettingsRegistered object:notificationSettings];
}
#endif

- (BOOL)application:(UIApplication *)application shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier {
	if (_appIsNotActiveYet) {
		FNLOG(@"NO");
		return NO;
	}

	if (self.passcodeViewController) {
		return NO;
	}

	UINavigationController *navigationController = [self navigationController];
	UIViewController <A3ViewControllerProtocol> *visibleViewController = (UIViewController <A3ViewControllerProtocol> *) [navigationController visibleViewController];
	if ([visibleViewController respondsToSelector:@selector(shouldAllowExtensionPointIdentifier:)]) {
		BOOL shouldAllow = [visibleViewController shouldAllowExtensionPointIdentifier:extensionPointIdentifier];
		FNLOG(@"%@, %@", visibleViewController, shouldAllow ? @"YES" : @"NO");
		return shouldAllow;
	}
	FNLOG(@"YES");
	return YES;
}

- (void)applicationProtectedDataWillBecomeUnavailable:(UIApplication *)application {
	FNLOG();
}

- (void)applicationProtectedDataDidBecomeAvailable:(UIApplication *)application {
	FNLOG();
}

- (void)didFinishPushViewController {
	if (_needShowAlertV3_4NewFeature) {
		_needShowAlertV3_4NewFeature = NO;
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
															message:[NSString stringWithFormat:NSLocalizedString(@"'%@' is back.", @"'%@' is back to AppBox Pro."), NSLocalizedString(@"Ruler", @"Ruler")]
														   delegate:nil
												  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
												  otherButtonTitles:nil];
		[alertView show];
	}
}

#ifdef APPBOX3_FREE

#pragma mark - Google AdMob

- (GADInterstitial *)createAndLoadInterstitial {
	GADInterstitial *interstitial = [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-0532362805885914/2537692543"];
	interstitial.delegate = self;
	[interstitial loadRequest:[GADRequest request]];
	return interstitial;
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
	self.googleAdInterstitial = [self createAndLoadInterstitial];
}

#endif

@end
