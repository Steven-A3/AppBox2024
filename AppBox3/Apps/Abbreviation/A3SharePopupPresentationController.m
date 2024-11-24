//
//  A3SharePopupPresentationController.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 1/14/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "A3SharePopupPresentationController.h"
#import "FXBlurView.h"

@interface A3SharePopupPresentationController ()

@property (nonatomic, strong) FXBlurView *blurView;
@property (nonatomic, strong) UIView *darkFilterView;

@end

@implementation A3SharePopupPresentationController

- (FXBlurView *)blurView {
	if (!_blurView) {
		_blurView = [FXBlurView new];
		_blurView.blurRadius = 10;
	}
	return _blurView;
}

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController {
	self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
	if (self) {
		self.blurView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	}

	return self;
}

- (void)presentationTransitionWillBegin {
	UIView *containerView = self.containerView;
	if (containerView) {
		self.blurView.frame = self.containerView.bounds;
		self.blurView.underlyingView = self.presentingViewController.view;
		_blurView.tintColor = [UIColor blackColor];
		_blurView.alpha = 0;
		_blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[containerView addSubview:_blurView];
		
		_darkFilterView = [UIView new];
		_darkFilterView.frame = self.containerView.bounds;
		_darkFilterView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
		_darkFilterView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[_blurView addSubview:_darkFilterView];
	}
	[self.presentingViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self->_blurView.alpha = 1.0;
	} completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
	}];
}

- (void)dismissalTransitionWillBegin {
	[self.presentingViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self->_blurView.alpha = 0;
	} completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self->_blurView removeFromSuperview];
        self->_blurView = nil;
        self->_darkFilterView = nil;
	}];
}

- (CGRect)frameOfPresentedViewInContainerView {
	return self.containerView.bounds;
}

- (void)removeBlurView {
}

@end
