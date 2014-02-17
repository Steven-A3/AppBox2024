//
//  A3AppDelegate.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/25/11.
//  Copyright (c) 2011 ALLABOUTAPPS. All rights reserved.
//

#import "A3RootViewController_iPad.h"
#import "UbiquityStoreManager.h"
#import "MBProgressHUD.h"
#import "A3PasscodeViewControllerProtocol.h"

@class MMDrawerController;
@protocol A3PasscodeViewControllerProtocol;
@class Reachability;

extern NSString *const kA3AppsMenuName;
extern NSString *const kA3AppsMenuCollapsed;
extern NSString *const kA3AppsMenuImageName;
extern NSString *const kA3AppsExpandableChildren;
extern NSString *const kA3AppsClassName;
extern NSString *const kA3AppsNibName;
extern NSString *const kA3AppsStoryboardName;
extern NSString *const kA3AppsMenuExpandable;
extern NSString *const kA3AppsMenuNeedSecurityCheck;

extern NSString *const kA3AppsMenuArray;
extern NSString *const kA3AppsDataUpdateDate;

/* Key for User Defaults */
extern NSString *const kA3MainMenuFavorites;			// Store NSDictionary
extern NSString *const kA3MainMenuAllMenu;				// Store NSArray
extern NSString *const kA3MainMenuMaxRecentlyUsed;		// Store NSNumber
extern NSString *const kA3MainMenuRecentlyUsed;

/* Notifications */
extern NSString *const A3AppsMainMenuContentsChangedNotification;
extern NSString *const A3DrawerStateChanged;
extern NSString *const A3MainMenuBecameFirstResponder;
extern NSString *const A3MainMenuResignFirstResponder;

/* Global Settings */
extern NSString *const kA3ThemeColorIndex;

@protocol A3ViewControllerProtocol <NSObject>
- (NSUInteger)a3SupportedInterfaceOrientations;
@end

@interface A3AppDelegate : UIResponder <UIApplicationDelegate> {
	UIAlertView *_cloudContentCorruptedAlert;
	UIAlertView *_cloudContentHealingAlert;
	UIAlertView *_handleCloudContentWarningAlert;
	UIAlertView *_handleLocalStoreAlert;
	BOOL _needMigrateLocalDataToCloud;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MMDrawerController *drawerController;
@property (strong, nonatomic) A3RootViewController_iPad *rootViewController;
@property (strong, nonatomic) UbiquityStoreManager *ubiquityStoreManager;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSDate *wakeUpTime;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) UIViewController<A3PasscodeViewControllerProtocol> *passcodeViewController;
@property (assign, nonatomic) BOOL coreDataReadyToUse;
@property (strong, nonatomic) Reachability *reachability;
@property (strong, nonatomic) NSCalendar *calendar;

+ (A3AppDelegate *)instance;

- (UINavigationController *)navigationController;
- (UIViewController *)visibleViewController;

@end
