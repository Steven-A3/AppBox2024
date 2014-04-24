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
#import "A3AppDelegate+iCloud.h"
#import "A3AppDelegate+passcode.h"
#import "A3AppDelegate+keyValueStore.h"
#import "A3AppDelegate+appearance.h"
#import "Reachability.h"
#import "A3CacheStoreManager.h"
#import "A3KeychainUtils.h"
#import "A3LaunchViewController.h"
#import "A3MainViewController.h"
#import "A3ImageToDataTransformer.h"

NSString *const A3DrawerStateChanged = @"A3DrawerStateChanged";
NSString *const A3DropboxLoginWithSuccess = @"A3DropboxLoginWithSuccess";
NSString *const A3DropboxLoginFailed = @"A3DropboxLoginFailed";

@interface A3AppDelegate () <UIAlertViewDelegate>

@property (nonatomic, strong) NSString *previousVersion;

@end

@implementation A3AppDelegate

@synthesize window = _window;

+ (A3AppDelegate *)instance {
	return (A3AppDelegate *) [[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	A3ImageToDataTransformer *transformer = [[A3ImageToDataTransformer alloc] init];
	[NSValueTransformer setValueTransformer:transformer forName:@"A3ImageToDataTransformer"];

	_previousVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kA3ApplicationVersion];
	if (!_previousVersion) {
		[A3KeychainUtils removePassword];
	}

	self.reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
	[self.reachability startNotifier];

	// Override point for customization after application launch.
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

		_drawerController = [[MMDrawerController alloc]
				initWithCenterViewController:navigationController leftDrawerViewController:menuNavigationController];
		[_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeBezelPanningCenterView];
		[_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
		[_drawerController setDrawerVisualStateBlock:[self slideAndScaleVisualStateBlock]];
		[_drawerController setCenterHiddenInteractionMode:MMDrawerOpenCenterInteractionModeFull];
		[_drawerController setGestureCompletionBlock:^(MMDrawerController *drawerController, UIGestureRecognizer *gesture) {
			[[NSNotificationCenter defaultCenter] postNotificationName:A3DrawerStateChanged object:nil];
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

	[[NSUserDefaults standardUserDefaults] setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:kA3ApplicationVersion];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"local noti" message:@"asdfasdf" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        alert.tag = 10;
        [alert show];
    }

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
	FNLOG();
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

#pragma mark Notification

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSString *notificationType = [notification.userInfo objectForKey:@"type"];
    
    // DaysCounter
    if ([notificationType isEqualToString:@"dc"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:[notification.userInfo objectForKey:@"alert"]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:@"Details", nil];
        alert.tag = 11;
        [alert show];
    }
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((alertView.tag == 10 && buttonIndex == 0) || (alertView.tag == 11 && buttonIndex == 1)) {
        NSLog(@"asdf");
    }
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


@end
