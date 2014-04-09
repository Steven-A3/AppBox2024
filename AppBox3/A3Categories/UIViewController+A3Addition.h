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

@interface UIViewController (A3Addition)

- (void)cleanUp;
- (CGRect)screenBoundsAdjustedWithOrientation;
- (void)popToRootAndPushViewController:(UIViewController *)viewController;
- (void)popToRootAndPushViewController:(UIViewController *)viewController animate:(BOOL)animate;
- (void)leftBarButtonAppsButton;

- (void)appsButtonAction:(UIBarButtonItem *)barButtonItem;
- (void)leftBarButtonCancelButton;
- (void)cancelButtonAction:(UIBarButtonItem *)barButtonItem;

- (UIView *)moreMenuViewWithButtons:(NSArray *)buttonsArray;
- (UIView *)presentMoreMenuWithButtons:(NSArray *)buttons tableView:(UITableView *)tableView;
- (void)dismissMoreMenuView:(UIView *)moreMenuView scrollView:(UIScrollView *)scrollView;
- (void)moreMenuDismissAction:(UITapGestureRecognizer *)gestureRecognizer;
- (UIButton *)shareButton;
- (void)shareButtonAction:(id)sender;

- (UIButton *)historyButton:(Class)managedObject;
- (UIBarButtonItem *)historyBarButton:(Class)managedObject;
- (void)historyButtonAction:(UIButton *)button;
- (UIButton *)settingsButton;
- (void)settingsButtonAction:(UIButton *)button;
- (void)presentSubViewController:(UIViewController *)viewController;
- (void)rightBarButtonDoneButton;
- (void)doneButtonAction:(UIBarButtonItem *)button;
- (void)rightButtonMoreButton;
- (void)moreButtonAction:(UIBarButtonItem *)button;
- (void)makeBackButtonEmptyArrow;
- (UIPopoverController *)presentActivityViewControllerWithActivityItems:(id)items fromBarButtonItem:(UIBarButtonItem *)barButtonItem;
- (UIPopoverController *)presentActivityViewControllerWithActivityItems:(id)items subject:(NSString *)subject fromBarButtonItem:(UIBarButtonItem *)barButtonItem; // kjh
- (UIPopoverController *)presentActivityViewControllerWithActivityItems:(id)items activities:(id)activities excludedType:(NSArray *)excludedActivityTypes fromBarButtonItem:(UIBarButtonItem *)barButtonItem; // kjh
- (UIPopoverController *)presentActivityViewControllerWithActivityItems:(id)items fromSubView:(UIView *)subView;

- (void)alertInternetConnectionIsNotAvailable;
+ (UIViewController <A3PasscodeViewControllerProtocol> *)passcodeViewControllerWithDelegate:(id <A3PasscodeViewControllerDelegate>)delegate;
- (BOOL)checkPasscode;
- (void)willDismissFromRightSide;
- (void)alertCloudNotEnabled;

@end
