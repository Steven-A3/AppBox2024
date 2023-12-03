//
//  A3PasswordViewController.h
//  AppBox3
//
//  Created by A3 on 12/28/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AppBoxKit/A3PasscodeCommonViewController.h>

@interface A3PasswordViewController : A3PasscodeCommonViewController

- (id)initWithDelegate:(id <A3PasscodeViewControllerDelegate>)delegate;
- (void)showEncryptionKeyScreenInViewController:(UIViewController *)viewController;
- (void)showEncryptionKeyCheckScreenInViewController:(UIViewController *)viewController;

@end
