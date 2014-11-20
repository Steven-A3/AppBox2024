//
//  A3LaunchViewController.h
//  AppBox3
//
//  Created by A3 on 3/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3PasscodeViewControllerProtocol;

@protocol A3LaunchSceneViewControllerDelegate <NSObject>
- (void)useICloudButtonPressedInViewController:(UIViewController *)viewController;
- (void)continueButtonPressedInViewController:(UIViewController *)viewController;
- (void)useAppBoxButtonPressedInViewController:(UIViewController *)viewController;
@end

@interface A3LaunchViewController : UIViewController <A3LaunchSceneViewControllerDelegate>

@property (nonatomic, assign) BOOL showAsWhatsNew;

@end
