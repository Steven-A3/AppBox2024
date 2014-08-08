//
//  A3PasscodeViewController.h
//  AppBox3
//
//  Created by A3 on 12/25/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3PasscodeViewControllerProtocol.h"
#import "A3PasscodeCommonViewController.h"

@interface A3PasscodeViewController : A3PasscodeCommonViewController

@property (nonatomic, assign) BOOL isCurrentlyOnScreen;

- (id)initWithDelegate:(id <A3PasscodeViewControllerDelegate>)delegate;

- (void)prepareAsLockscreen;
- (void)prepareForChangingPasscode;
- (void)prepareForTurningOffPasscode;
- (void)prepareForEnablingPasscode;

@end
