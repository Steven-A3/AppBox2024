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
#import "NSFileManager+A3Addtion.h"
#import "Reachability.h"
#import "A3KeychainUtils.h"
#import "A3LaunchViewController.h"
#import "A3MainViewController.h"
#import "DaysCounterEvent.h"
#import "A3DaysCounterEventDetailViewController.h"
#import "A3DaysCounterModelManager.h"

#import "A3LadyCalendarDetailViewController.h"

NSString *const A3DrawerStateChanged = @"A3DrawerStateChanged";
NSString *const A3DropboxLoginWithSuccess = @"A3DropboxLoginWithSuccess";
NSString *const A3DropboxLoginFailed = @"A3DropboxLoginFailed";
NSString *const A3LocalNotificationOwner = @"A3LocalNotificationOwner";
NSString *const A3LocalNotificationDataID = @"A3LocalNotificationDataID";
NSString *const A3LocalNotificationFromLadyCalendar = @"Lady Calendar";
NSString *const A3LocalNotificationFromDaysCounter = @"Days Counter";

NSString *const A3CloudSeedDataCreated = @"A3CloudSeedDataCreated";

@interface A3AppDelegate () <UIAlertViewDelegate, A3DataMigrationManagerDelegate>

@property (nonatomic, strong) NSString *previousVersion;
@property (nonatomic, strong) NSDictionary *localNotificationUserInfo;

@end

@implementation A3AppDelegate

@synthesize window = _window;

+ (A3AppDelegate *)instance {
	return (A3AppDelegate *) [[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification) {
		_localNotificationUserInfo = localNotification.userInfo;
    }
    
	_previousVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kA3ApplicationLastRunVersion];
	if (_previousVersion) {
		if ([_previousVersion floatValue] < 3.0) {
			_shouldMigrateV1Data = YES;
			[A3KeychainUtils migrateV1Passcode];
		}
	} else {
		[A3KeychainUtils removePassword];
	}
	// TODO: 아래 한줄은 테스트 종료 후에는 반드시 삭제
//	_shouldMigrateV1Data = YES;

	self.reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
	[self.reachability startNotifier];

	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager setupCacheStoreFile];
	[self setupCloud];

	UIViewController *rootViewController;
	if (IS_IPAD) {
		_rootViewController = [[A3RootViewController_iPad alloc] initWithNibName:nil bundle:nil];
		rootViewController = _rootViewController;
	} else {
		A3MainMenuTableViewController *leftMenuViewController = [[A3MainMenuTableViewController alloc] init];
		UINavigationController *menuNavigationController = [[UINavigationController alloc] initWithRootViewController:leftMenuViewController];

		UIViewController *viewController = [A3MainViewController new];
		A3NavigationController *navigationController = [[A3NavigationController alloc] initWithRootViewController:viewController];

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

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyValueStoreDidChangeExternally:) name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:[NSUbiquitousKeyValueStore defaultStore]];

	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.rootViewController = rootViewController;
	self.window.backgroundColor = [UIColor whiteColor];

	NSNumber *selectedColor = [[NSUserDefaults standardUserDefaults] objectForKey:kA3ThemeColorIndex];
	if (selectedColor) {
		self.window.tintColor = self.themeColors[[selectedColor unsignedIntegerValue]];
	}

	[self.window makeKeyAndVisible];

	[[NSUserDefaults standardUserDefaults] setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:kA3ApplicationLastRunVersion];
	[[NSUserDefaults standardUserDefaults] synchronize];

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
	[self applicationDidEnterBackground_passcode];
	FNLOG();
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	[self applicationWillEnterForeground_passcode];
	FNLOG();
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	[self applicationDidBecomeActive_passcode];

	FNLOG();
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
			NSLog(@"App linked successfully!");
			[[NSNotificationCenter defaultCenter] postNotificationName:A3DropboxLoginWithSuccess object:nil];
		} else {
			[[NSNotificationCenter defaultCenter] postNotificationName:A3DropboxLoginFailed object:nil];
		}
		return YES;
	}
	// Add whatever other url handling code your app requires here
	return NO;
}

- (void)coreDataReady {
	FNLOG();
	double delayInSeconds = 0.01;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			if (self.shouldMigrateV1Data) {
				A3DataMigrationManager *migrationManager = [[A3DataMigrationManager alloc] initWithPersistentStoreCoordinator:[[A3AppDelegate instance] persistentStoreCoordinator]];
				if ([migrationManager walletDataFileExists] && ![migrationManager walletDataWithPassword:nil]) {
					self.migrationManager = migrationManager;
					self.migrationManager.delegate = self;
					[migrationManager askWalletPassword];
				} else {
					[migrationManager migrateV1DataWithPassword:nil];
					self.shouldMigrateV1Data = NO;
					[self resetCoreDataStack];
				}
			}
			[self showReceivedLocalNotifications];
		});
	});
}

- (void)migrationManager:(A3DataMigrationManager *)manager didFinishMigration:(BOOL)success {
	[self resetCoreDataStack];
	self.shouldMigrateV1Data = NO;
	self.migrationManager = nil;
}

#pragma mark Notification

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
	FNLOG();
	_localNotificationUserInfo = notification.userInfo;

    NSString *notificationOwner = [notification.userInfo objectForKey:A3LocalNotificationOwner];
    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:notificationOwner
													message:notification.alertBody
												   delegate:self
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:@"Details", nil];
    if ([notificationOwner isEqualToString:A3LocalNotificationFromDaysCounter]) {
        alert.tag = 11;
    } else if ([notificationOwner isEqualToString:A3LocalNotificationFromLadyCalendar]) {
		alert.tag = 21;
	}
	[alert show];
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
	}
	_localNotificationUserInfo = nil;
}

- (void)showDaysCounterDetail {
	if (!_localNotificationUserInfo[A3LocalNotificationDataID]) {
		return;
	}

	[A3DaysCounterModelManager reloadAlertDateListForLocalNotification];
	FNLOG(@"%@", _localNotificationUserInfo[A3LocalNotificationDataID]);

	DaysCounterEvent *eventItem = [DaysCounterEvent MR_findFirstByAttribute:@"uniqueID" withValue:_localNotificationUserInfo[A3LocalNotificationDataID]];
	A3DaysCounterEventDetailViewController *viewController = [[A3DaysCounterEventDetailViewController alloc] initWithNibName:@"A3DaysCounterEventDetailViewController" bundle:[NSBundle mainBundle]];
	viewController.isModal = YES;
	viewController.eventItem = eventItem;
    A3DaysCounterModelManager *sharedManager = [[A3DaysCounterModelManager alloc] init];
    [sharedManager prepareInContext:[[MagicalRecordStack defaultStack] context] ];
    viewController.sharedManager = sharedManager;

	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	[self.navigationController presentViewController:navigationController animated:YES completion:NULL];
}

- (void)showLadyCalendarDetailView {
	A3LadyCalendarDetailViewController *viewController = [[A3LadyCalendarDetailViewController alloc] initWithNibName:@"A3LadyCalendarDetailViewController" bundle:nil];
	viewController.isFromNotification = YES;
	viewController.periodID = _localNotificationUserInfo[A3LocalNotificationDataID];

	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	[self.navigationController presentViewController:navigationController animated:YES completion:NULL];
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

@end
