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
#import "A3HomeStyleMenuViewController.h"
#import "MMDrawerController.h"
#import "Reachability.h"
#import <CoreData/CoreData.h>

//#import "AppBox3-Swift.h"

@protocol A3PasscodeViewControllerProtocol;
@class Reachability;
@class A3MainMenuTableViewController;
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
extern NSString *const A3NotificationsUserNotificationSettingsRegistered;
extern NSString *const A3NotificationsAdsWillDismissScreen;

/* Global Settings */
extern NSString *const A3LocalNotificationOwner;
extern NSString *const A3LocalNotificationDataID;
extern NSString *const A3LocalNotificationFromLadyCalendar;
extern NSString *const A3LocalNotificationFromDaysCounter;

extern NSString *const A3InAppPurchaseRemoveAdsProductIdentifier;
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
@property (nonatomic, strong) NSDate *appOpenTime;
@property (nonatomic, assign) BOOL firstRunAfterInstall;
@property (nonatomic, assign) BOOL adDisplayedAfterApplicationDidBecomeActive;

@property (nonatomic, copy) NSString *previousVersion;
@property (nonatomic, assign) NSTimeInterval passcodeFreeBegin;
@property (nonatomic, assign) BOOL isSettingsEvaluatingTouchID;
@property (nonatomic, assign) BOOL mainViewControllerDidInitialSetup;

@property (nonatomic, assign) BOOL touchIDEvaluationDidFinish;
@property (nonatomic, strong) A3DataMigrationManager *migrationManager;
@property (nonatomic, assign) BOOL migrationIsInProgress;
@property (nonatomic, assign) NSUInteger counterPassedDidBecomeActive;
@property (nonatomic, assign) BOOL appWillResignActive;
@property (nonatomic, strong) NSDate *originalPurchaseDate;
@property (nonatomic, assign) BOOL isOldPaidUser;   // 3.5 버전 이전 유료앱 구매자
@property (nonatomic, assign) BOOL hasAdsFreePass;  // Subscription이 유효한 사용자
@property (nonatomic, strong) NSDate *expirationDate;
@property (nonatomic, strong) NSString *originalAppVersion;
@property (nonatomic, assign) BOOL removeAdsActive; // Remove Ads를 구매한 사용자

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
- (void)presentInterstitialAds;
- (void)updateHolidayNations;

/**
 Evaluates the subscription status of the user and decides whether to present ads.

 completion() is the call to your completion block, now safely nested inside the dispatch_async call to ensure it runs on the main thread.
 @param completion A completion block that will be called once the evaluation is complete. It has no return value and takes no parameters.

*/
- (void)evaluateSubscriptionWithCompletion:(void (^)(void))completion;

@end

#import "A3AppDelegate+iCloud.h"
#import "A3AppDelegate+passcode.h"
#import "A3AppDelegate+mainMenu.h"
