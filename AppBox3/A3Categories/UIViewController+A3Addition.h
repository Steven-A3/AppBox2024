//
//  UIViewController(A3Addition)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/7/13 5:59 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A3AppDelegate+passcode.h"
#import "A3PasscodeViewController.h"
#import "A3PasswordViewController.h"

extern NSString *const AdMobAdUnitIDBattery;
extern NSString *const AdMobAdUnitIDCalculator;
extern NSString *const AdMobAdUnitIDClock;
extern NSString *const AdMobAdUnitIDCurrencyList;
extern NSString *const AdMobAdUnitIDCurrencyPicker;
extern NSString *const AdMobAdUnitIDDateCalc;
extern NSString *const AdMobAdUnitIDDaysCounter;
extern NSString *const AdMobAdUnitIDExpenseList;
extern NSString *const AdMobAdUnitIDFlashlight;
extern NSString *const AdMobAdUnitIDHolidays;
extern NSString *const AdMobAdUnitIDLadiesCalendar;
extern NSString *const AdMobAdUnitIDLunarConverter;
extern NSString *const AdMobAdUnitIDMagnifier;
extern NSString *const AdMobAdUnitIDMirror;
extern NSString *const AdMobAdUnitIDPercentCalc;
extern NSString *const AdMobAdUnitIDRandom;
extern NSString *const AdMobAdUnitIDRuler;
extern NSString *const AdMobAdUnitIDSalesCalc;
extern NSString *const AdMobAdUnitIDTipCalc;
extern NSString *const AdMobAdUnitIDTranslator;
extern NSString *const AdMobAdUnitIDUnitConverter;
extern NSString *const AdMobAdUnitIDUnitPrice;
extern NSString *const AdMobAdUnitIDWallet;
extern NSString *const AdMobAdUnitIDLevel;

typedef NS_ENUM(NSInteger, A3RightBarButtonTag) {
	A3RightBarButtonTagComposeButton = 1,
	A3RightBarButtonTagShareButton,
	A3RightBarButtonTagHistoryButton,
	A3RightBarButtonTagSettingsButton,
    A3RightBarButtonTagHelpButton,
};

@interface UIViewController (A3Addition)

- (void)cleanUp;
- (CGRect)screenBoundsAdjustedWithOrientation;
- (void)callPrepareCloseOnActiveMainAppViewController;
- (void)dismissModalViewControllerOnMainViewController;

- (void)popToRootAndPushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)leftBarButtonAppsButton;
- (void)appsButtonAction:(UIBarButtonItem *)barButtonItem;
- (void)leftBarButtonCancelButton;
- (void)cancelButtonAction:(UIBarButtonItem *)barButtonItem;
- (void)addThreeButtons:(NSArray *)buttons toView:(UIView *)view;
- (void)addFourButtons:(NSArray *)buttons toView:(UIView *)view;
- (UIView *)moreMenuViewWithButtons:(NSArray *)buttonsArray;
- (UIView *)presentMoreMenuWithButtons:(NSArray *)buttons pullDownView:(UIView *)pullDownView;

- (void)dismissMoreMenuView:(UIView *)moreMenuView pullDownView:(UIView *)pullDownView completion:(void (^)())completion;
- (void)moreMenuDismissAction:(UITapGestureRecognizer *)gestureRecognizer;
- (UIButton *)shareButton;
- (void)shareButtonAction:(id)sender;
- (UIButton *)historyButton:(Class)managedObject;
- (UIBarButtonItem *)historyBarButton:(Class)managedObject;
- (void)historyButtonAction:(UIButton *)button;
- (UIButton *)settingsButton;
- (void)settingsButtonAction:(UIButton *)button;
- (UIButton *)instructionHelpButton;
- (UIBarButtonItem *)instructionHelpBarButton;
- (void)instructionHelpButtonAction:(id)sender;
- (UIButton *)composeButton;
- (void)composeButtonAction:(UIButton *)button;
- (void)rightBarButtonDoneButton;
- (void)doneButtonAction:(UIBarButtonItem *)button;
- (void)rightButtonMoreButton;
- (void)moreButtonAction:(UIBarButtonItem *)button;
- (void)makeBackButtonEmptyArrow;
- (UIPopoverController *)presentActivityViewControllerWithActivityItems:(id)items fromBarButtonItem:(UIBarButtonItem *)barButtonItem completionHandler:(UIActivityViewControllerCompletionHandler)completionHandler;
- (UIPopoverController *)presentActivityViewControllerWithActivityItems:(id)items fromSubView:(UIView *)subView completionHandler:(UIActivityViewControllerCompletionHandler)completionHandler;
- (void)alertInternetConnectionIsNotAvailable;
+ (UIViewController <A3PasscodeViewControllerProtocol> *)passcodeViewControllerWithDelegate:(id <A3PasscodeViewControllerDelegate>)delegate;
- (void)willDismissFromRightSide;
- (void)alertCloudNotEnabled;
- (UIActionSheet *)actionSheetAskingImagePickupWithDelete:(BOOL)deleteEnable delegate:(id <UIActionSheetDelegate>)delegate;

#pragma mark - Custom Date String Related

- (NSString *)fullStyleDateStringFromDate:(NSDate *)date withShortTime:(BOOL)shortTime;
- (NSString *)customFullStyleDateStringFromDate:(NSDate *)date withShortTime:(BOOL)shortTime;
- (NSString *)shareMessageFormat;
- (NSString *)commonShareFooter;
- (NSString *)appITunesURL;
- (void)alertLocationDisabled;
- (NSString *)shareMailMessageWithHeader:(NSString *)header contents:(NSString *)contents tail:(NSString *)tail;
- (void)setFirstActionSheet:(UIActionSheet *)actionSheet;
- (UIActionSheet *)firstActionSheet;
- (void)rotateFirstActionSheet;
- (void)requestAuthorizationForCamera:(NSString *)appName;
- (void)setupBannerViewForAdUnitID:(NSString *)unitID keywords:(NSArray *)keywords gender:(GADGender)gender adSize:(GADAdSize)adSize;
- (void)setupBannerViewForAdUnitID:(NSString *)unitID keywords:(NSArray *)keywords gender:(GADGender)gender;
- (void)setupBannerViewForAdUnitID:(NSString *)unitID keywords:(NSArray *)keywords;
- (GADBannerView *)bannerView;

@end
