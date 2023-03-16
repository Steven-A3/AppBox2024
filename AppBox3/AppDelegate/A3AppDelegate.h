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
#import "A3DataMigrationManager.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "RMStoreAppReceiptVerificator.h"
#import "A3HomeStyleMenuViewController.h"
#import "MMDrawerController.h"
#import "Reachability.h"
#import <CoreData/CoreData.h>

//#import "AppBox3-Swift.h"

@protocol A3PasscodeViewControllerProtocol;
@class Reachability;
@class A3MainMenuTableViewController;
@class RMAppReceipt;
@class A3HomeStyleMenuViewController;

extern NSString *const kA3ApplicationLastRunVersion;
extern NSString *const kA3ApplicationNumberOfDidBecomeActive;
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
extern NSString *const kA3AppsDoNotKeepAsRecent;

extern NSString *const kA3AppsMenuArray;
extern NSString *const kA3AppsDataUpdateDate;
extern NSString *const kA3AppsStartingAppName;
extern NSString *const kA3AppsOriginalStartingAppName;
extern NSString *const kA3AppsMenuNameForGrid;
extern NSString *const kA3AppsHideOtherAppLinks;
extern NSString *const kA3AppsUseGrayIconsOnGridMenu;

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
extern NSString *const A3NotificationsAdsWillDismissScreen;

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
extern NSString *const A3AppName_Level;
extern NSString *const A3AppName_QRCode;
extern NSString *const A3AppName_Pedometer;
extern NSString *const A3AppName_Abbreviation;
extern NSString *const A3AppName_Kaomoji;

extern NSString *const A3AppName_Settings;
extern NSString *const A3AppName_About;
extern NSString *const A3AppName_RemoveAds;
extern NSString *const A3AppName_RestorePurchase;
extern NSString *const A3AppName_None;

extern NSString *const A3InAppPurchaseRemoveAdsProductIdentifier;
extern NSString *const kA3AdsUserDidSelectPersonalizedAds;

/**
 *  메뉴 그룹별 컬러를 적용하기 위해서 그룹 이름을 Key로 사용하기 위하여 정의 하였다.
 */
extern NSString *const kA3AppsGroupName;

extern NSString *const A3AppGroupNameUtility;
extern NSString *const A3AppGroupNameCalculator;
extern NSString *const A3AppGroupNameConverter;
extern NSString *const A3AppGroupNameReference;
extern NSString *const A3AppGroupNameProductivity;
extern NSString *const A3AppGroupNameNone;

@protocol A3ViewControllerProtocol <NSObject>
@optional
- (NSUInteger)a3SupportedInterfaceOrientations;
- (void)prepareClose;
@end

@interface A3AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MMDrawerController *drawerController;
@property (strong, nonatomic) A3RootViewController_iPad *rootViewController_iPad;
@property (strong, nonatomic) UIViewController *rootViewController_iPhone;
@property (strong, nonatomic) UINavigationController *currentMainNavigationController;
@property (strong, nonatomic) A3MainMenuTableViewController *mainMenuViewController;
@property (strong, nonatomic) A3HomeStyleMenuViewController *homeStyleMainMenuViewController;

@property (strong, nonatomic) NSPersistentContainer *persistentContainer;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;     // It will be replaced with persistentContainer
@property (strong, nonatomic) NSDate *wakeUpTime;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (nonatomic, strong) MBProgressHUD *hudView;
@property (strong, nonatomic) UIViewController<A3PasscodeViewControllerProtocol> *passcodeViewController;
@property (strong, nonatomic) Reachability *reachability;
@property (strong, nonatomic) NSCalendar *calendar;
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
@property (nonatomic, assign) BOOL doneAskingRestorePurchase;

@property (nonatomic, copy) NSString *previousVersion;
@property (nonatomic, assign) NSTimeInterval passcodeFreeBegin;
@property (nonatomic, assign) BOOL isSettingsEvaluatingTouchID;
@property (nonatomic, assign) BOOL mainViewControllerDidInitialSetup;

@property (nonatomic, assign) BOOL touchIDEvaluationDidFinish;
@property (nonatomic, strong) A3DataMigrationManager *migrationManager;
@property (nonatomic, assign) BOOL migrationIsInProgress;
@property (nonatomic, assign) NSUInteger counterPassedDidBecomeActive;
@property (nonatomic, assign) BOOL appWillResignActive;

/**
 *  Settings에서 홈 화면 종류를 바꾼 경우, rootViewController가 초기화되면서
 *  StartApp 설정이 활성화 되지 않도록 하기 위해서 아래 값을 이용한다.
 */
@property (nonatomic, assign) BOOL isChangingRootViewController;

+ (A3AppDelegate *)instance;
- (void)updateStartOption;
- (void)pushStartingAppInfo;
- (void)popStartingAppInfo;

- (void)showReceivedLocalNotifications;
- (UINavigationController *)navigationController;
- (UIViewController *)visibleViewController;
- (void)downloadDataFiles;
- (void)setupContext;
- (NSURL *)storeURL;
- (NSString *)storeFileName;
- (NSString *)backupReceiptFilePath;
- (void)makeReceiptBackup;
- (RMAppReceipt *)appReceipt;
- (BOOL)receiptHasRemoveAds;
- (BOOL)isPaidAppVersionCustomer:(RMAppReceipt *)receipt;
- (BOOL)isIAPPurchasedCustomer:(RMAppReceipt *)receipt;
- (BOOL)presentInterstitialAds;
- (BOOL)shouldPresentWhatsNew;
- (void)alertWhatsNew;
- (void)updateHolidayNations;
- (void)askPersonalizedAdConsent;

@end

#import "A3AppDelegate+iCloud.h"
#import "A3AppDelegate+passcode.h"
#import "A3AppDelegate+appearance.h"
#import "A3AppDelegate+mainMenu.h"
