//
//  A3AppDelegate.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/25/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3AppDelegate.h"
#import "A3UIDevice.h"
#import "A3AppDelegate+data.h"
#import "A3HomeViewController_iPhone.h"
#import "A3MainMenuTableViewController.h"
#import "MMDrawerController.h"

@interface A3AppDelegate ()

@end

@implementation A3AppDelegate

@synthesize window = _window;

+ (A3AppDelegate *)instance {
	return (A3AppDelegate *) [[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Override point for customization after application launch.

	[MagicalRecord setupAutoMigratingStackWithSQLiteStoreNamed:@"AppBox3.sqlite"];

	dispatch_async(dispatch_get_main_queue(), ^{
		[self prepareDatabase];
	});

	UIViewController *rootViewController;
	if (IS_IPAD) {
		_rootViewController = [[A3RootViewController_iPad alloc] initWithNibName:nil bundle:nil];
		rootViewController = _rootViewController;
	} else {
		A3MainMenuTableViewController *leftMenuViewController = [[A3MainMenuTableViewController alloc] initWithStyle:UITableViewStylePlain];
		UINavigationController *menuNavigationController = [[UINavigationController alloc] initWithRootViewController:leftMenuViewController];

		A3HomeViewController_iPhone *centerViewController = [[A3HomeViewController_iPhone alloc] initWithNibName:@"HomeView_iPhone" bundle:nil];

		A3NavigationController *navigationController = [[A3NavigationController alloc] initWithRootViewController:centerViewController];

		_drawerController = [[MMDrawerController alloc]
				initWithCenterViewController:navigationController leftDrawerViewController:menuNavigationController];
		[_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeBezelPanningCenterView];
		[_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
		[_drawerController setDrawerVisualStateBlock:[self slideAndScaleVisualStateBlock]];
		[_drawerController setCenterHiddenInteractionMode:MMDrawerOpenCenterInteractionModeFull];
		[_drawerController setShowsShadow:NO];

		[_drawerController setMaximumLeftDrawerWidth:320.0];

		_drawerController.view.frame = [[UIScreen mainScreen] bounds];

		rootViewController = _drawerController;
	}

	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.rootViewController = rootViewController;
	[self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
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

@end
