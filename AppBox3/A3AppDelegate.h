//
//  A3AppDelegate.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/25/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3PaperFoldMenuViewController.h"

@interface A3AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) A3PaperFoldMenuViewController *paperFoldMenuViewController;

+ (A3AppDelegate *)instance;

@end
