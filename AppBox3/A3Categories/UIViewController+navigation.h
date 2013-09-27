//
//  UIViewController+navigation.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 6/26/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3ActionMenuViewControllerDelegate.h"

@interface UIViewController (navigation)

@property (nonatomic, strong) UIViewController *actionMenuViewController;

- (void)popToRootAndPushViewController:(UIViewController *)viewController;

- (void)showRightDrawerViewController:(UIViewController *)viewController;

- (void)presentActionMenuWithDelegate:(id <A3ActionMenuViewControllerDelegate>)delegate;

- (void)presentEmptyActionMenu;

- (void)closeActionMenuViewWithAnimation:(BOOL)animate;

- (void)addToolsButtonWithAction:(SEL)action;

- (CAGradientLayer *)addTopGradientLayerToView:(UIView *)view position:(CGFloat)position;

- (CAGradientLayer *)addTopGradientLayerToWhiteView:(UIView *)view position:(CGFloat)position;

- (void)alertCheck;

- (UIBarButtonItem *)barButtonItemWithTitle:(NSString *)title action:(SEL)selector;

- (UIBarButtonItem *)blackBarButtonItemWithTitle:(NSString *)title action:(SEL)selector;

- (void)addActionIcon:(NSString *)iconName title:(NSString *)title selector:(SEL)selector atIndex:(NSInteger)index1;

- (CGRect)boundsForRightSideView;

- (void)leftBarButtonAppsButton;

- (UIView *)moreMenuViewWithButtons:(NSArray *)buttonsArray;

- (UIView *)presentMoreMenuWithButtons:(NSArray *)buttons tableView:(UITableView *)tableView;

- (void)dismissMoreMenuView:(UIView *)moreMenuView tableView:(UITableView *)tableView;

- (void)moreMenuDismissAction:(UITapGestureRecognizer *)gestureRecognizer;

- (UIButton *)shareButton;

- (void)shareButtonAction:(id)sender;

- (UIButton *)historyButton;

- (void)historyButtonAction:(UIButton *)button;

- (UIButton *)settingsButton;

- (void)settingsButtonAction:(UIButton *)button;

- (void)presentSubViewController:(UIViewController *)viewController;

- (void)rightBarButtonDoneButton;

- (void)doneButtonAction:(UIBarButtonItem *)button;

- (void)rightButtonMoreButton;

- (void)moreButtonAction:(UIBarButtonItem *)button;

- (void)makeBackButtonEmptyArrow;

- (CGRect)screenBoundsAdjustedWithOrientation;

- (UIPopoverController *)presentActivityViewControllerWithActivityItems:(id)items fromBarButtonItem:(UIBarButtonItem *)barButtonItem;
@end
