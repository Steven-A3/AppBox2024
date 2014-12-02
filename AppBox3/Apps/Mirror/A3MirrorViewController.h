//
//  A3MirrorViewController.h
//  A3TeamWork
//
//  Created by Soon Gyu Kim on 1/25/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreText/CoreText.h>
#import <GLKit/GLKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MWPhotoBrowser.h"
#import "A3CameraViewController.h"

typedef NS_ENUM(NSUInteger, A3MirrorFilterType) {
    A3MirrorMonoFilter= 0,
    A3MirrorTonalFilter,
    A3MirrorNoirFilter,
    A3MirrorFadeFilter,
    A3MirrorNoFilter,
    A3MirrorChromeFilter,
    A3MirrorProcessFilter,
    A3MirrorTransferFilter,
    A3MirrorInstantFilter,
};

@interface A3MirrorViewController : A3CameraViewController <AVCaptureVideoDataOutputSampleBufferDelegate, GLKViewDelegate, UIGestureRecognizerDelegate>

@end
