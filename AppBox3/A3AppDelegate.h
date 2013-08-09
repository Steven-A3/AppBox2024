//
//  A3AppDelegate.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/25/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMDrawerController.h"

@class A3RootViewController;

@protocol A3ViewControllerProtocol <NSObject>
- (NSUInteger)a3SupportedInterfaceOrientations;
@end

@interface A3AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) A3RootViewController *rootViewController;
//@property (strong, nonatomic) A3DrawerController *mm_drawerController;
//@property (strong, nonatomic) UINavigationController *navigationController;

+ (A3AppDelegate *)instance;

@end
