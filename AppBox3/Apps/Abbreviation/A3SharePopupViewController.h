//
//  A3SharePopupViewController.h
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 1/7/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3SharePopupViewControllerDelegate;

@interface A3SharePopupViewController : UIViewController

@property (nonatomic, assign) BOOL presentationIsInteractive;
@property (nonatomic, assign) CGFloat interactiveTransitionProgress;
@property (nonatomic, weak) id<A3SharePopupViewControllerDelegate> delegate;

+ (A3SharePopupViewController *)storyboardInstance;

- (void)completeCurrentInteractiveTransition;
- (void)cancelCurrentInteractiveTransition;

@end

@protocol A3SharePopupViewControllerDelegate <NSObject>

- (void)sharePopupViewControllerWillDismiss:(A3SharePopupViewController *)viewController;

@end

