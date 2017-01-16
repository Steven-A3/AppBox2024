//
//  A3SharePopupTransitionDelegate.h
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 1/14/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface A3SharePopupTransitionDelegate : NSObject <UIViewControllerTransitioningDelegate>

@property (nonatomic, assign) BOOL presentationIsInteractive;
@property (nonatomic, assign) CGFloat currentTransitionProgress;

- (void)completeCurrentInteractiveTransition;
- (void)cancelCurrentInteractiveTransition;

@end
