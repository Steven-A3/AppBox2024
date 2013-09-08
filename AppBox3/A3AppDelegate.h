//
//  A3AppDelegate.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/25/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3RootViewController_iPad.h"

@class MMDrawerController;

@protocol A3ViewControllerProtocol <NSObject>
- (NSUInteger)a3SupportedInterfaceOrientations;
@end

@interface A3AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MMDrawerController *drawerController;
@property (strong, nonatomic) A3RootViewController_iPad *rootViewController;

+ (A3AppDelegate *)instance;

@end
