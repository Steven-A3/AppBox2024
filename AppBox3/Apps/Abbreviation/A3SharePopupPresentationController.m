//
//  A3SharePopupPresentationController.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 1/14/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "A3SharePopupPresentationController.h"

@interface A3SharePopupPresentationController ()

@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) UIViewPropertyAnimator *blurAnimator;

@end

@implementation A3SharePopupPresentationController

- (UIVisualEffectView *)blurView {
	if (!_blurView) {
		_blurView = [UIVisualEffectView new];
	}
	return _blurView;
}

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController {
	self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
	if (self) {
//		self.blurView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	}

	return self;
}

- (void)presentationTransitionWillBegin {
//	if (self.containerView) {
//		self.blurView.frame = self.containerView.bounds;
//		[self.containerView insertSubview:self.blurView atIndex:0];
//	}
//	[self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context) {
//		self.blurView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//	} completion:^(id <UIViewControllerTransitionCoordinatorContext> context) {
//	}];
}

- (void)dismissalTransitionWillBegin {
//	[self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
//		self.blurView.effect = nil;
//	} completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
//	}];
}

- (CGRect)frameOfPresentedViewInContainerView {
	return self.containerView.bounds;
}

- (void)updateBlurView:(CGFloat)progress {
}

@end
