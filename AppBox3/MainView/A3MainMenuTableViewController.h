//
//  A3MainMenuTableViewController.h
//  AppBox3
//
//  Created by A3 on 11/20/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//


#import "A3TableViewController.h"
#import "A3SelectTableViewController.h"

@protocol A3PasscodeViewControllerProtocol;

@interface A3MainMenuTableViewController : A3TableViewController

@property (nonatomic, assign) BOOL pushClockViewControllerOnPasscodeFailure;
@property (nonatomic, copy) NSString *activeAppName;
@property (nonatomic, copy) NSString *selectedAppName;

@property (nonatomic, strong) UIViewController<A3PasscodeViewControllerProtocol> *passcodeViewController;

- (void)openAppNamed:(NSString *)appName;

- (void)openClockApp;
- (BOOL)openRecentlyUsedMenu:(BOOL)verifyPasscode;

@end
