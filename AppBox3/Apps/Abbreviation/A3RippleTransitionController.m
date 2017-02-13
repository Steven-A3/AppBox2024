//
//  A3RippleTransitionController.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 1/24/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "A3RippleTransitionController.h"

@interface A3RippleTransitionController () <CAAnimationDelegate>

@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;
@property (nonatomic, weak) UIViewController *toViewController;
@property (nonatomic, weak) UIView *patternBackgroundView;

@end

@implementation A3RippleTransitionController

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
	return 1.0;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
	_transitionContext = transitionContext;
	UIView *containerView = transitionContext.containerView;
	UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
	_toViewController = toViewController;

	// Add pattern background
	UIView *patternBackgroundView = [UIView new];
	patternBackgroundView.frame = fromViewController.view.bounds;
	patternBackgroundView.opaque = 0.0;
	patternBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Pattern_Dots"]];
	patternBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[fromViewController.view addSubview:patternBackgroundView];
	_patternBackgroundView = patternBackgroundView;

	toViewController.view.transform = CGAffineTransformMakeScale(0.0, 0.0);
	[containerView addSubview:toViewController.view];
	[containerView bringSubviewToFront:fromViewController.view];
	
	[UIView animateWithDuration:1
						  delay:0
		 usingSpringWithDamping:0.5
		  initialSpringVelocity:0.5
						options:0
					 animations:^{
						 toViewController.view.transform = CGAffineTransformMakeScale(1, 1);
					 } completion:^(BOOL finished) {

					 }];

	[CATransaction begin];
	[self rippleAnimationForView:fromViewController.view];
	[self fadeInAnimationForView:_patternBackgroundView];
	[CATransaction commit];
}

- (void)rippleAnimationForView:(UIView *)view {
	CATransition *animation = [CATransition new];
	animation.delegate = self;
	animation.duration = [self transitionDuration:_transitionContext];
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	animation.type = @"rippleEffect";
	animation.beginTime = 0;
	[view.layer addAnimation:animation forKey:nil];
}

- (void)fadeInAnimationForView:(UIView *)view {
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	animation.delegate = self;
	animation.fromValue = @0;
	animation.toValue = @1;
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	animation.fillMode = kCAFillModeForwards;
	animation.removedOnCompletion = NO;
	animation.duration = [self transitionDuration:_transitionContext];
	animation.beginTime = 0;
	[view.layer addAnimation:animation forKey:nil];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
	[_transitionContext completeTransition:!_transitionContext.transitionWasCancelled];

	[_toViewController.view insertSubview:_patternBackgroundView atIndex:0];
}

@end
