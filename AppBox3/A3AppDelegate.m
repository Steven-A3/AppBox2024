//
//  A3AppDelegate.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/25/11.
//  Copyright (c) 2011 ALLABOUTAPPS. All rights reserved.
//

#import "A3AppDelegate.h"
#import "A3UIDevice.h"
#import "A3MainMenuTableViewController.h"
#import "MMDrawerController.h"
#import "A3MainViewController.h"
#import "NSFileManager+A3Addtion.h"
#import "A3AppDelegate+iCloud.h"
#import "A3AppDelegate+passcode.h"
#import "A3PasscodeViewControllerProtocol.h"

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

		A3MainViewController *centerViewController = [[A3MainViewController alloc] initWithNibName:nil bundle:nil];
		A3NavigationController *navigationController = [[A3NavigationController alloc] initWithRootViewController:centerViewController];

		_drawerController = [[MMDrawerController alloc]
				initWithCenterViewController:navigationController leftDrawerViewController:menuNavigationController];
		[_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeBezelPanningCenterView];
		[_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
		[_drawerController setDrawerVisualStateBlock:[self slideAndScaleVisualStateBlock]];
		[_drawerController setCenterHiddenInteractionMode:MMDrawerOpenCenterInteractionModeFull];

		[_drawerController setMaximumLeftDrawerWidth:266.0];

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
	[self applicationWillResignActive_passcode];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	[self applicationDidEnterBackground_passcode];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	[self applicationWillEnterForeground_passcode];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	[self applicationDidBecomeActive_passcode];
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

- (UINavigationController *)navigationController {
	if (IS_IPHONE) {
		return (UINavigationController *)self.drawerController.centerViewController;
	} else {
		return self.rootViewController.centerNavigationController;
	}
}

- (UIViewController *)visibleViewController {
	UINavigationController *navigationController = [self navigationController];
	UIViewController *topViewController = [navigationController topViewController];
	FNLOG(@"%@,%@", topViewController, [navigationController visibleViewController]);
	return [navigationController visibleViewController];
}

NSString *const kA3AppsMenuName = @"kA3AppsMenuName";
NSString *const kA3AppsMenuCollapsed = @"kA3AppsMenuCollapsed";
NSString *const kA3AppsMenuImageName = @"kA3AppsMenuImageName";
NSString *const kA3AppsExpandableChildren = @"kA3AppsExpandableChildren";
NSString *const kA3AppsClassName = @"kA3AppsClassName";
NSString *const kA3AppsNibName = @"kA3AppsNibName";
NSString *const kA3AppsStoryboardName = @"kA3AppsStoryboardName";
NSString *const kA3AppsMenuExpandable = @"kA3AppsMenuExpandable";
NSString *const kA3AppsMenuNeedSecurityCheck = @"kA3AppsMenuNeedSecurityCheck";

- (NSArray *)allMenu {
	return @[
			@{
					kA3AppsMenuExpandable : @YES,
					kA3AppsMenuCollapsed : @YES,
					kA3AppsMenuName : @"Calculator",
					kA3AppsExpandableChildren :	@[
					@{kA3AppsMenuName : @"Date Calculator", kA3AppsClassName : @"", kA3AppsMenuImageName : @"DateCalculator"},
					@{kA3AppsMenuName : @"Loan Calculator", kA3AppsClassName : @"A3LoanCalc2ViewController", kA3AppsMenuImageName : @"LoanCalculator"},
					@{kA3AppsMenuName : @"Sales Calculator", kA3AppsClassName : @"", kA3AppsMenuImageName : @"SalesCalculator"},
					@{kA3AppsMenuName : @"Tip Calculator", kA3AppsClassName : @"", kA3AppsMenuImageName : @"TipCalculator"},
					@{kA3AppsMenuName : @"Unit Price", kA3AppsClassName : @"", kA3AppsMenuImageName : @"UnitPrice"},
					@{kA3AppsMenuName : @"Calculator", kA3AppsClassName : @"", kA3AppsMenuImageName : @"Calculator"},
					@{kA3AppsMenuName : @"Percent Calculator", kA3AppsClassName : @"", kA3AppsMenuImageName : @"PercentCalculator"}
			]
			},
			@{
					kA3AppsMenuExpandable : @YES,
					kA3AppsMenuCollapsed : @YES,
					kA3AppsMenuName : @"Converter",
					kA3AppsExpandableChildren : @[
					@{kA3AppsMenuName : @"Currency", kA3AppsClassName : @"A3CurrencyViewController", kA3AppsMenuImageName : @"Currency"},
					@{kA3AppsMenuName : @"Lunar Converter", kA3AppsClassName : @"", kA3AppsMenuImageName : @"LunarConverter"},
					@{kA3AppsMenuName : @"Translator", kA3AppsClassName : @"A3TranslatorViewController", kA3AppsMenuImageName : @"Translator"},
					@{kA3AppsMenuName : @"Unit Converter", kA3AppsClassName : @"", kA3AppsMenuImageName : @"UnitConverter"},
			]
			},
			@{
					kA3AppsMenuExpandable : @YES,
					kA3AppsMenuCollapsed : @YES,
					kA3AppsMenuName : @"Productivity",
					kA3AppsExpandableChildren : @[
					@{kA3AppsMenuName : @"Days Counter", kA3AppsClassName : @"", kA3AppsMenuImageName : @"DaysCounter", kA3AppsMenuNeedSecurityCheck : @YES},
					@{kA3AppsMenuName : @"Lady Calendar", kA3AppsClassName : @"", kA3AppsMenuImageName : @"LadyCalendar", kA3AppsMenuNeedSecurityCheck : @YES},
					@{kA3AppsMenuName : @"Wallet", kA3AppsClassName : @"", kA3AppsMenuImageName : @"Wallet", kA3AppsMenuNeedSecurityCheck : @YES},
					@{kA3AppsMenuName : @"Expense List", kA3AppsClassName : @"", kA3AppsMenuImageName : @"ExpenseList"},
			]
			},
			@{
					kA3AppsMenuExpandable : @YES,
					kA3AppsMenuCollapsed : @YES,
					kA3AppsMenuName : @"Reference",
					kA3AppsExpandableChildren : @[
					@{kA3AppsMenuName : @"Holidays", kA3AppsClassName : @"A3HolidaysPageViewController", kA3AppsMenuImageName : @"Holidays"},
			]
			},
			@{
					kA3AppsMenuExpandable : @YES,
					kA3AppsMenuCollapsed : @YES,
					kA3AppsMenuName : @"Utility",
					kA3AppsExpandableChildren : @[
					@{kA3AppsMenuName : @"Clock", kA3AppsClassName : @"", kA3AppsMenuImageName : @"Clock"},
					@{kA3AppsMenuName : @"Battery Status", kA3AppsClassName : @"", kA3AppsMenuImageName : @"BatteryStatus"},
					@{kA3AppsMenuName : @"Mirror", kA3AppsClassName : @"", kA3AppsMenuImageName : @"Mirror"},
					@{kA3AppsMenuName : @"Magnifier", kA3AppsClassName : @"", kA3AppsMenuImageName : @"Magnifier"},
			]
			},
	];
}

@end
