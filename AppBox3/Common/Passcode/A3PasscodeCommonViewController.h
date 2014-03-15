//
//  A3PasscodeCommonViewController
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2014. 3. 15. 오후 9:22.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A3PasscodeViewControllerProtocol.h"


@interface A3PasscodeCommonViewController : UIViewController <A3PasscodeViewControllerProtocol>
{
	BOOL _beingDisplayedAsLockscreen;
}

@property (nonatomic, weak) id<A3PasscodeViewControllerDelegate> delegate;

- (void)statusBarFrameOrOrientationChanged:(NSNotification *)notification;

- (void)rotateAccordingToStatusBarOrientationAndSupportedOrientations;
@end
