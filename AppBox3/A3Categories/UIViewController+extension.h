//
//  UIViewController(A3Addition)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/7/13 5:59 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

@import UIKit;
#import "A3PasscodeViewControllerProtocol.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface UIViewController (extension)

- (void)callPrepareCloseOnActiveMainAppViewController;
- (void)popToRootAndPushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)appsButtonAction:(UIBarButtonItem *)barButtonItem;
- (void)presentWebViewControllerWithURL:(NSURL *)url;
- (void)setupBannerViewForAdUnitID:(NSString *)unitID keywords:(NSArray *)keywords adSize:(GADAdSize)adSize delegate:(id<GADBannerViewDelegate>)delegate;
- (void)setupBannerViewForAdUnitID:(NSString *)unitID keywords:(NSArray *)keywords delegate:(id<GADBannerViewDelegate>)delegate;
- (GADBannerView *)bannerView;
- (CGFloat)bannerHeight;
- (void)cleanUp;
- (void)presentSubscriptionViewControllerWithCompletion:(void (^)(void))completionHandler API_AVAILABLE(ios(17.0));

@end
