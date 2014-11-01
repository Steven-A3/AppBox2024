//
//  A3MainMenuTableViewController.h
//  AppBox3
//
//  Created by A3 on 11/20/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//


#import "A3TableViewController.h"
#import "A3SelectTableViewController.h"

@interface A3MainMenuTableViewController : A3TableViewController

@property (nonatomic, assign) BOOL pushClockViewControllerOnPasscodeFailure;
@property (nonatomic, copy) NSString *activeAppName;

- (void)openClockApp;

- (BOOL)openRecentlyUsedMenu:(BOOL)verifyPasscode;

@end
