//
//  A3PasscodeCommonViewController
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2014. 3. 15. 오후 9:22.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppBoxKit/A3PasscodeViewControllerProtocol.h>

@interface A3PasscodeCommonViewController : UIViewController <A3PasscodeViewControllerProtocol>
{
	BOOL _beingDisplayedAsLockscreen;
}

@property (nonatomic, weak, nullable) id<A3PasscodeViewControllerDelegate> delegate;
@property (copy, nullable) void (^completionBlock)(BOOL success);

- (void)rotateAccordingToStatusBarOrientationAndSupportedOrientations;

@end
