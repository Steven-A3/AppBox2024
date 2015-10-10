//
//  A3AppDelegate.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/25/11.
//  Copyright (c) 2011 ALLABOUTAPPS. All rights reserved.
//

#import "A3RootViewController_iPad.h"
#import "MBProgressHUD.h"
#import "A3PasscodeViewControllerProtocol.h"
#import "A3CacheStoreManager.h"
#import "A3DataMigrationManager.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "RMStoreAppReceiptVerificator.h"

@class MMDrawerController;
@protocol A3PasscodeViewControllerProtocol;
@class Reachability;
@class A3DataMigrationManager;
@class A3MainMenuTableViewController;
@class RMAppReceipt;

extern NSString *const kA3ApplicationLastRunVersion;
extern NSString *const kA3AppsMenuName;
extern NSString *const kA3AppsMenuCollapsed;
extern NSString *const kA3AppsMenuImageName;
extern NSString *const kA3AppsExpandableChildren;
extern NSString *const kA3AppsClassName_iPhone;
extern NSString *const kA3AppsClassName_iPad;
extern NSString *const kA3AppsNibName_iPhone;
extern NSString *const kA3AppsNibName_iPad;
extern NSString *const kA3AppsStoryboard_iPhone;
extern NSString *const kA3AppsStoryboard_iPad;
extern NSString *const kA3AppsMenuExpandable;
extern NSString *const kA3AppsMenuNeedSecurityCheck;

extern NSString *const kA3AppsMenuArray;
extern NSString *const kA3AppsDataUpdateDate;
extern NSString *const kA3AppsStartingAppName;
extern NSString *const kA3AppsOriginalStartingAppName;

/* Notifications */
extern NSString *const A3NotificationAppsMainMenuContentsChanged;
extern NSString *const A3DrawerStateChanged;
extern NSString *const A3MainMenuBecameFirstResponder;
extern NSString *const A3NotificationMainMenuDidShow;
extern NSString *const A3NotificationMainMenuDidHide;
extern NSString *const A3DropboxLoginWithSuccess;
extern NSString *const A3DropboxLoginFailed;
extern NSString *const A3NotificationCloudKeyValueStoreDidImport;
extern NSString *const A3NotificationCloudCoreDataStoreDidImport;
extern NSString *const A3NotificationsUserNotificationSettingsRegistered;

/* Global Settings */
extern NSString *const A3LocalNotificationOwner;
extern NSString *const A3LocalNotificationDataID;
extern NSString *const A3LocalNotificationFromLadyCalendar;
extern NSString *const A3LocalNotificationFromDaysCounter;

extern NSString *const A3AppName_DateCalculator;
extern NSString *const A3AppName_LoanCalculator;
extern NSString *const A3AppName_SalesCalculator;
extern NSString *const A3AppName_TipCalculator;
extern NSString *const A3AppName_UnitPrice;
extern NSString *const A3AppName_Calculator;
extern NSString *const A3AppName_PercentCalculator;
extern NSString *const A3AppName_CurrencyConverter;
extern NSString *const A3AppName_LunarConverter;
extern NSString *const A3AppName_Translator;
extern NSString *const A3AppName_UnitConverter;
extern NSString *const A3AppName_DaysCounter;
extern NSString *const A3AppName_LadiesCalendar;
extern NSString *const A3AppName_Wallet;
extern NSString *const A3AppName_ExpenseList;
extern NSString *const A3AppName_Holidays;
extern NSString *const A3AppName_Clock;
extern NSString *const A3AppName_BatteryStatus;
extern NSString *const A3AppName_Mirror;
extern NSString *const A3AppName_Magnifier;
extern NSString *const A3AppName_Flashlight;
extern NSString *const A3AppName_Random;
extern NSString *const A3AppName_Ruler;
extern NSString *const A3AppName_Settings;

extern NSString *const A3InAppPurchaseRemoveAdsProductIdentifier;

@protocol A3ViewControllerProtocol <NSObject>
@optional
- (NSUInteger)a3SupportedInterfaceOrientations;
- (BOOL)shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier;
- (void)prepareClose;
@end

@interface A3AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MMDrawerController *drawerController;
@property (strong, nonatomic) A3RootViewController_iPad *rootViewController;
@property (strong, nonatomic) UIViewController *rootViewController_iPhone;
@property (strong, nonatomic) UINavigationController *currentMainNavigationController;
@property (strong, nonatomic) A3MainMenuTableViewController *mainMenuViewController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSDate *wakeUpTime;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) UIViewController<A3PasscodeViewControllerProtocol> *passcodeViewController;
@property (strong, nonatomic) Reachability *reachability;
@property (strong, nonatomic) NSCalendar *calendar;
@property (strong, nonatomic) A3CacheStoreManager *cacheStoreManager;
@property (strong, nonatomic) UIImageView *coverView;
@property (assign, nonatomic) BOOL shouldMigrateV1Data;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSMetadataQuery *metadataQuery;
@property (nonatomic, assign) BOOL pushClockViewControllerIfFailPasscode;
@property (nonatomic, weak) UIViewController *parentOfPasscodeViewController;
@property (nonatomic, assign) BOOL startOptionOpenClockOnce;
@property (nonatomic, assign) BOOL isCoreDataReady;
@property (nonatomic, assign) BOOL isTouchIDEvaluationInProgress;
@property (nonatomic, strong) UIViewController *touchIDBackgroundViewController;
@property (nonatomic, assign) BOOL shouldPresentAd;
@property (nonatomic, assign) BOOL isIAPRemoveAdsAvailable;
@property (nonatomic, copy) SKProduct *IAPRemoveAdsProductFromiTunes;
@property (nonatomic, strong) RMStoreAppReceiptVerificator *receiptVerificator;
@property (nonatomic, strong) NSDate *appOpenTime;
@property (nonatomic, assign) BOOL inAppPurchaseInProgress;
@property (nonatomic, assign) BOOL firstRunAfterInstall;
@property (nonatomic, assign) BOOL adDisplayedAfterApplicationDidBecomeActive;

+ (A3AppDelegate *)instance;
- (void)updateStartOption;

- (void)popStartingAppInfo;

- (void)showReceivedLocalNotifications;
- (UINavigationController *)navigationController;
- (UIViewController *)visibleViewController;
- (void)downloadDataFiles;
- (void)setupContext;
- (NSURL *)storeURL;
- (NSString *)storeFileName;
- (void)didFinishPushViewController;
- (BOOL)receiptHasRemoveAds;
- (BOOL)isPaidAppVersionCustomer:(RMAppReceipt *)receipt;
- (BOOL)isIAPPurchasedCustomer:(RMAppReceipt *)receipt;

- (BOOL)presentInterstitialAds;
@end

#import "A3AppDelegate+iCloud.h"
#import "A3AppDelegate+passcode.h"
#import "A3AppDelegate+appearance.h"
#import "A3AppDelegate+mainMenu.h"
