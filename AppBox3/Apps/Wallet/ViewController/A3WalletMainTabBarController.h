//
//  A3WalletMainTabBarController.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const A3WalletNotificationCategoryChanged;
extern NSString *const A3WalletNotificationCategoryDeleted;
extern NSString *const A3WalletNotificationCategoryAdded;

@interface A3WalletMainTabBarController : UITabBarController <UITabBarControllerDelegate>

- (void)setupTabBar;
@end
