//
//  A3AppDelegate.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/25/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3RootViewController_iPad.h"
#import "UbiquityStoreManager.h"
#import "MBProgressHUD.h"

@class MMDrawerController;

@protocol A3ViewControllerProtocol <NSObject>
- (NSUInteger)a3SupportedInterfaceOrientations;
@end

@interface A3AppDelegate : UIResponder <UIApplicationDelegate> {
	UIAlertView *_cloudContentCorruptedAlert;
	UIAlertView *_cloudContentHealingAlert;
	UIAlertView *_handleCloudContentWarningAlert;
	UIAlertView *_handleLocalStoreAlert;
	MBProgressHUD *_hud;
	BOOL _needMigrateLocalDataToCloud;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MMDrawerController *drawerController;
@property (strong, nonatomic) A3RootViewController_iPad *rootViewController;
@property (strong, nonatomic) UbiquityStoreManager *ubiquityStoreManager;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

+ (A3AppDelegate *)instance;

@end
