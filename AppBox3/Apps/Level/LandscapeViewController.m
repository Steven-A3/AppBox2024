//
//  LandscapeViewController.m
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 3/14/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//

#import "LandscapeViewController.h"

@implementation LandscapeViewController

// Override supported interface orientations
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

// Override preferred interface orientation for when the view controller is presented
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft; // or UIInterfaceOrientationLandscapeRight, as preferred
}

// Force landscape orientation on load
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
    // Check if the device is not already in a landscape orientation
    if (currentOrientation != UIDeviceOrientationLandscapeLeft && currentOrientation != UIDeviceOrientationLandscapeRight) {
        // Force change to landscape orientation
        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    }
}

@end
