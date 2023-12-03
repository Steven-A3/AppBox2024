//
//  A3PasscodeCommonViewController
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2014. 3. 15. 오후 9:22.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3PasscodeCommonViewController.h"
#import "A3AppDelegate.h"
#import "A3UserDefaults.h"
#import "A3UIDevice.h"
#import "A3KeychainUtils.h"
#import "Masonry.h"

@implementation A3PasscodeCommonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)applicationWillEnterForeground {
    if ([[A3UserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForAskPasscodeForStarting]) {
        [self.navigationController setNavigationBarHidden:YES];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	if (IS_IPHONE) {
		return UIInterfaceOrientationMaskPortrait;
	} else {
		return UIInterfaceOrientationMaskAll;
	}
}

- (void)rotateAccordingToStatusBarOrientationAndSupportedOrientations {
    [[NSNotificationCenter defaultCenter] postNotificationName:A3RotateAccordingToDeviceOrientationNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

    [[NSNotificationCenter defaultCenter] postNotificationName:A3RemoveSecurityCoverViewNotification object:nil];
}

@end
