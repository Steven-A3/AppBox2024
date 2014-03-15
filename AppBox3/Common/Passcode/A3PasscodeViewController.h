//
//  A3PasscodeViewController.h
//  AppBox3
//
//  Created by A3 on 12/25/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3PasscodeViewControllerProtocol.h"

@interface A3PasscodeViewController : UIViewController <A3PasscodeViewControllerProtocol>

@property (nonatomic, weak) id<A3PasscodeViewControllerDelegate> delegate;
@property (assign) BOOL isCurrentlyOnScreen;

- (id)initWithDelegate:(id <A3PasscodeViewControllerDelegate>)delegate;

- (void)prepareAsLockscreen;
- (void)prepareForChangingPasscode;
- (void)prepareForTurningOffPasscode;
- (void)prepareForEnablingPasscode;

@end
