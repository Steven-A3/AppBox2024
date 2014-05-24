//
//  A3PasscodeCommonViewController
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2014. 3. 15. 오후 9:22.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3PasscodeCommonViewController.h"
#import "A3AppDelegate.h"

@implementation A3PasscodeCommonViewController {

}

- (NSUInteger)supportedInterfaceOrientations {
	if (IS_IPHONE) {
		return UIInterfaceOrientationMaskPortrait;
	} else {
		return UIInterfaceOrientationMaskAll;
	}
	if (_beingDisplayedAsLockscreen) return UIInterfaceOrientationMaskAll;
	// I'll be honest and mention I have no idea why this line of code below works.
	// Without it, if you present the passcode view as lockscreen (directly on the window)
	// and then inside of a modal, the orientation will be wrong.

	// Feel free to explain why, I'd be more than grateful :)
	return UIInterfaceOrientationPortraitUpsideDown;
}


// All of the rotation handling is thanks to Håvard Fossli's - https://github.com/hfossli
// answer: http://stackoverflow.com/a/4960988/793916
#pragma mark - Handling rotation
- (void)statusBarFrameOrOrientationChanged:(NSNotification *)notification {
	/*
	 This notification is most likely triggered inside an animation block,
	 therefore no animation is needed to perform this nice transition.
	 */
	[self rotateAccordingToStatusBarOrientationAndSupportedOrientations];
}


// And to his AGWindowView: https://github.com/hfossli/AGWindowView
// Without the 'desiredOrientation' method, using showLockscreen in one orientation,
// then presenting it inside a modal in another orientation would display the view in the first orientation.
- (UIInterfaceOrientation)desiredOrientation {
	UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
	UIInterfaceOrientationMask statusBarOrientationAsMask = UIInterfaceOrientationMaskFromOrientation(statusBarOrientation);
	if(self.supportedInterfaceOrientations & statusBarOrientationAsMask) {
		return statusBarOrientation;
	}
	else {
		if(self.supportedInterfaceOrientations & UIInterfaceOrientationMaskPortrait) {
			return UIInterfaceOrientationPortrait;
		}
		else if(self.supportedInterfaceOrientations & UIInterfaceOrientationMaskLandscapeLeft) {
			return UIInterfaceOrientationLandscapeLeft;
		}
		else if(self.supportedInterfaceOrientations & UIInterfaceOrientationMaskLandscapeRight) {
			return UIInterfaceOrientationLandscapeRight;
		}
		else {
			return UIInterfaceOrientationPortraitUpsideDown;
		}
	}
}

- (void)rotateAccordingToStatusBarOrientationAndSupportedOrientations {
	UIInterfaceOrientation orientation = [self desiredOrientation];
	CGFloat angle = UIInterfaceOrientationAngleOfOrientation(orientation);
	CGAffineTransform transform = CGAffineTransformMakeRotation(angle);

	[self setIfNotEqualTransform: transform
						   frame: self.view.window.bounds];
}


- (void)setIfNotEqualTransform:(CGAffineTransform)transform frame:(CGRect)frame {
	if(!CGAffineTransformEqualToTransform(self.view.transform, transform)) {
		self.view.transform = transform;
	}
	if(!CGRectEqualToRect(self.view.frame, frame)) {
		self.view.frame = frame;
	}
}


+ (CGFloat)getStatusBarHeight {
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if(UIInterfaceOrientationIsLandscape(orientation)) {
		return [UIApplication sharedApplication].statusBarFrame.size.width;
	}
	else {
		return [UIApplication sharedApplication].statusBarFrame.size.height;
	}
}

@end
