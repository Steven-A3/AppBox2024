//
//  A3AbbreviationCopiedTransitionDelegate.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 1/24/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "A3AbbreviationCopiedTransitionDelegate.h"
#import "A3RippleTransitionController.h"

@interface A3AbbreviationCopiedTransitionDelegate ()

@property (nonatomic, strong) A3RippleTransitionController *transitionController;

@end

@implementation A3AbbreviationCopiedTransitionDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
	return self.transitionController;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
	return self.transitionController;
}

- (A3RippleTransitionController *)transitionController {
	if (!_transitionController) {
		_transitionController = [A3RippleTransitionController new];
	}
	return _transitionController;
}

@end
