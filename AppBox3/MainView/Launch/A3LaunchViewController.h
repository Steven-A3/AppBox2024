//
//  A3LaunchViewController.h
//  AppBox3
//
//  Created by A3 on 3/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3PasscodeViewControllerProtocol.h"

@protocol A3LaunchSceneViewControllerDelegate <NSObject>
- (void)useICloudButtonPressedInViewController:(UIViewController *)viewController;
- (void)continueButtonPressedInViewController:(UIViewController *)viewController;
- (void)useAppBoxButtonPressedInViewController:(UIViewController *)viewController;
@end

@interface A3LaunchViewController : UIViewController <A3PasscodeViewControllerDelegate>

@property (nonatomic, assign) BOOL showAsWhatsNew;

@end
