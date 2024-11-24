//
//  UIViewController(A3Addition)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/7/13 5:59 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "UIViewController+extension.h"
#import "A3AppDelegate.h"
#import "A3RootViewController_iPad.h"
#import "A3PasscodeViewController.h"
#import "A3PasswordViewController.h"
@import AppBoxKit;
#import "A3CenterViewDelegate.h"
#import "A3BasicWebViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3UserDefaults.h"
#import <objc/runtime.h>
#import "A3SyncManager.h"
#import "A3UserDefaults+A3Addition.h"
#import "AppBox3-Swift.h"

static char const *const key_adBannerView = "key_adBannerView";
static char const *const key_adNativeExpressView = "key_adNativeExpressView";

@implementation UIViewController (extension)

- (void)cleanUp {
    [self removeObserver];
}

- (BOOL)resignFirstResponder {
    [self.editingObject resignFirstResponder];
    return [super resignFirstResponder];
}

- (void)callPrepareCloseOnActiveMainAppViewController {
    UINavigationController *navigationController = A3AppDelegate.instance.navigationController;
    if ([navigationController.viewControllers count] > 1) {
        UIViewController<A3CenterViewDelegate> *activeMainAppViewController = navigationController.viewControllers[1];
        if ([activeMainAppViewController respondsToSelector:@selector(prepareClose)]) {
            [activeMainAppViewController prepareClose];
        }
    }
}

- (void)popToRootAndPushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UINavigationController *navigationController;
    A3AppDelegate *appDelegate = [A3AppDelegate instance];
    [appDelegate popStartingAppInfo];
    navigationController = appDelegate.currentMainNavigationController;

    if (IS_IPHONE) {// TODO: mainmenu가 리스트가 아닌경우 처리
        if ([appDelegate isMainMenuStyleList]) {
            [appDelegate.drawerController closeDrawerAnimated:YES completion:nil];
        }
    } else {
        A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController_iPad];
        [rootViewController dismissRightSideViewController];

        // KJH
        if (rootViewController.presentViewControllers && [rootViewController.presentViewControllers count] > 0) {
            [rootViewController dismissCenterViewController];
        }
    }

    // Modal 이 있는 경우, 제거한다.
    if (navigationController.presentedViewController) {
        UIViewController *presentedViewController = navigationController.presentedViewController;
        if ([presentedViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *presentedNavigationController = (UINavigationController *) presentedViewController;
            UIViewController *contentViewController = presentedNavigationController.viewControllers[0];
            if (![contentViewController isKindOfClass:[A3PasscodeCommonViewController class]]) {
                [presentedNavigationController dismissViewControllerAnimated:NO completion:nil];
            }
        } else {
            if (![presentedViewController isKindOfClass:[A3PasscodeCommonViewController class]]) {
                [presentedViewController dismissViewControllerAnimated:NO completion:NULL];
            }
        }
    }

    NSMutableArray *currentViewControllers = [[navigationController viewControllers] mutableCopy];
    // Xcode 5로 빌드하고 iOS 8에서 실행했을때, poppedVCs가 nil이 돌아옵니다. 다른 경우는 더 테스트가 필요합니다.
    // 이 경우에는 pop하기 전과 후의 뷰컨트롤러를 비교해서 없어진 뷰 컨트롤러들의 cleanUp을 호출해 주어야 합니다.
    NSArray *poppedVCs = [navigationController popToRootViewControllerAnimated:NO];
    if (![poppedVCs count]) {
        [currentViewControllers removeObjectsInArray:navigationController.viewControllers];
        for (UIViewController<A3CenterViewDelegate> *vc in currentViewControllers) {
            if ([vc respondsToSelector:@selector(cleanUp)]) {
                [vc performSelector:@selector(cleanUp)];
            }
        }
    } else {
        for (UIViewController<A3CenterViewDelegate> *vc in poppedVCs) {
            if ([vc respondsToSelector:@selector(cleanUp)]) {
                [vc performSelector:@selector(cleanUp)];
            }
        }
    }
    
    [navigationController setToolbarHidden:YES];
    [navigationController setNavigationBarHidden:NO animated:NO];

    BOOL hidesNavigationBar = NO;
    UIViewController<A3CenterViewDelegate> *targetViewController = (UIViewController <A3CenterViewDelegate> *) viewController;
    if ([viewController respondsToSelector:@selector(hidesNavigationBar)]) {
        hidesNavigationBar = [targetViewController hidesNavigationBar];
    }
    if (hidesNavigationBar) {
        [navigationController setNavigationBarHidden:YES animated:NO];
        [self setValuePrefersStatusBarHidden:YES];
        [self setValueStatusBarStyle:UIStatusBarStyleLightContent];
        [self setNeedsStatusBarAppearanceUpdate];

        UIImage *image = [UIImage new];
        [navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
        [navigationController.navigationBar setShadowImage:image];
    } else {
        UINavigationController *target = [[A3AppDelegate instance] currentMainNavigationController];
        [self showNavigationBarOn:target];
    }
    navigationController.navigationBar.tintColor = [[A3UserDefaults standardUserDefaults] themeColor];

    if (IS_IPAD) {
        A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController_iPad];
        [rootViewController animateHideLeftViewForFullScreenCenterView:YES];
    }

    if (viewController) {
        [navigationController pushViewController:viewController animated:animated];
    }
}

- (void)appsButtonAction:(UIBarButtonItem *)barButtonItem {
    [self.editingObject resignFirstResponder];
    if (IS_IPHONE) {
        if ([[A3AppDelegate instance] isMainMenuStyleList]) {
            [[A3AppDelegate instance].drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
        } else {
            UINavigationController *navigationController = [A3AppDelegate instance].currentMainNavigationController;
            id<A3ViewControllerProtocol> viewController = (id)[navigationController topViewController];
            [viewController prepareClose];
            [navigationController setNavigationBarHidden:YES];
            [navigationController popViewControllerAnimated:YES];
            [navigationController setToolbarHidden:YES];
            [A3AppDelegate instance].homeStyleMainMenuViewController.activeAppName = nil;
        }
    } else {
        [[[A3AppDelegate instance] rootViewController_iPad] toggleLeftMenuViewOnOff];
    }
    [[A3AppDelegate instance] presentInterstitialAds];
}

- (void)presentWebViewControllerWithURL:(NSURL *)url {
    if (![[A3AppDelegate instance].reachability isReachable]) {
        [self alertInternetConnectionIsNotAvailable];
        return;
    }
    A3BasicWebViewController *viewController = [[A3BasicWebViewController alloc] init];
    viewController.url = url;
    if (IS_IPHONE) {
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        [[[A3AppDelegate instance] rootViewController_iPad] presentViewController:navigationController animated:YES completion:NULL];
    }
}

#pragma mark -- Setup Banner view for gathering information

/**
 *  Create GADBannerView with given unitID, keywords, and gender
 *
 *  @param unitID   AdMob ad unit id
 *  @param keywords keywords list
 */
- (void)setupBannerViewForAdUnitID:(NSString *)unitID keywords:(NSArray *)keywords adSize:(GADAdSize)adSize delegate:(id<GADBannerViewDelegate>)delegate {
    [[A3AppDelegate instance] evaluateSubscriptionWithCompletion:^{
        if (![[A3AppDelegate instance] shouldPresentAd]) return;

        GAMRequest *adRequest = [GAMRequest request];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kA3AdsUserDidSelectPersonalizedAds]) {
            GADExtras *extras = [[GADExtras alloc] init];
            extras.additionalParameters = @{@"npa": @"1"};
            [adRequest registerAdNetworkExtras:extras];
        }
        adRequest.keywords = keywords;

        GADBannerView *bannerView = [[GADBannerView alloc] initWithAdSize:adSize];
        bannerView.adUnitID = unitID;
        bannerView.rootViewController = self;
        bannerView.delegate = delegate ? delegate : (id<GADBannerViewDelegate>)self;
        [bannerView loadRequest:adRequest];
        objc_setAssociatedObject(self, key_adBannerView, bannerView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }];
}

- (void)setupBannerViewForAdUnitID:(NSString *)unitID keywords:(NSArray *)keywords delegate:(id<GADBannerViewDelegate>)delegate {
    if (![[A3AppDelegate instance] shouldPresentAd]) return;

    [self setupBannerViewForAdUnitID:unitID keywords:keywords adSize:GADAdSizeBanner delegate:delegate];
}

- (CGFloat)bannerHeight {
    if (IS_IPAD) {
        return 90;
    }
    if (IS_IPHONE35) {
        return 50;
    } else if (IS_IPHONE_5_5_INCH) {
        return 65;
    } else if (IS_IPHONE_4_7_INCH) {
        return 60;
    } else {
        return 50;
    }
}

/**
 *  광고를 받으면 폐기한다.
 *  현재 이 요청의 목적은 광고 수요를 파악하는데 있으므로, 광고를 게재하지는 않는다.
 *
 *  @param bannerView <#bannerView description#>
 */
- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
    [bannerView removeFromSuperview];
    objc_setAssociatedObject(self, key_adBannerView, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    FNLOG(@"%@", error.localizedDescription);
}

- (GADBannerView *)bannerView {
    return objc_getAssociatedObject(self, key_adBannerView);
}

/*
 * Present subscription view controller
 * @param completionHandler completion handler
 * completionHandler will called when subscriptionview closed.
 * This code requires iOS 17.0 or later
 */
- (void)presentSubscriptionViewControllerWithCompletion:(void (^)(void))completionHandler {
    UIViewController *subscriptionShopViewController = [SubscriptionUtility subscriptionShopViewControllerWithExpirationDate:[A3AppDelegate instance].expirationDate completionHandler:completionHandler];
    subscriptionShopViewController.modalPresentationStyle = UIModalPresentationFullScreen;

    [self presentViewController:subscriptionShopViewController animated:YES completion:NULL];
}

@end
