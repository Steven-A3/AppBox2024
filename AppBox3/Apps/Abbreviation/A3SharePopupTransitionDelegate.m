//
//  A3SharePopupTransitionDelegate.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 1/14/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "A3SharePopupTransitionDelegate.h"
#import "A3SharePopupPresentationController.h"

@interface A3SharePopupTransitionDelegate ()

@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *currentInteractionController;
@property (nonatomic, strong) A3SharePopupPresentationController *presentationController;

@end

@implementation A3SharePopupTransitionDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
	return nil;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
	return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
	if (_presentationIsInteractive) {
		_currentInteractionController = [UIPercentDrivenInteractiveTransition new];
		_currentInteractionController.completionSpeed = 0.5;
		return _currentInteractionController;
	}
	return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
	return nil;
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
	_presentationController = [[A3SharePopupPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
	return _presentationController;
}

- (void)setCurrentTransitionProgress:(CGFloat)currentTransitionProgress {
	_currentTransitionProgress = currentTransitionProgress;
	if (_currentInteractionController) {
		[_currentInteractionController updateInteractiveTransition:currentTransitionProgress];
	}
	[_presentationController updateBlurView:currentTransitionProgress];
}

- (void)setPresentationIsInteractive:(BOOL)presentationIsInteractive {
	_presentationIsInteractive = presentationIsInteractive;
	if (!presentationIsInteractive) {
		_currentInteractionController = nil;
	}
}

- (void)completeCurrentInteractiveTransition {
	[_currentInteractionController finishInteractiveTransition];
}

- (void)cancelCurrentInteractiveTransition {
	[_currentInteractionController cancelInteractiveTransition];
}

@end
