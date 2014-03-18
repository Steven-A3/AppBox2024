//
//  A3LaunchSceneTransitionManager.m
//  AppBox3
//
//  Created by A3 on 3/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3LaunchSceneTransitionManager.h"

@implementation A3LaunchSceneTransitionManager

#pragma mark - UIViewControllerAnimatedTransitioning -

//Define the transition duration
-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 1.0;
}

//Define the transition
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    CGRect sourceRect = [transitionContext initialFrameForViewController:fromVC];
   
	// Insert the toVC view...........................
	UIView *container = [transitionContext containerView];
	[container addSubview:toVC.view];
    
	toVC.view.frame = CGRectMake(sourceRect.size.width, 0, sourceRect.size.width, sourceRect.size.height);
    
	//3.Perform the animation...............................
	[UIView animateWithDuration:1.0
						  delay:0.0
		 usingSpringWithDamping:.8
		  initialSpringVelocity:6.0
						options:UIViewAnimationOptionCurveEaseIn
					 animations:^{
						 fromVC.view.frame = CGRectMake(-sourceRect.size.width, 0, sourceRect.size.width, sourceRect.size.height);
						 toVC.view.frame = sourceRect;
					 } completion:^(BOOL finished) {
						 //When the animation is completed call completeTransition
						 [transitionContext completeTransition:YES];
						 
					 }];
	
}

@end
