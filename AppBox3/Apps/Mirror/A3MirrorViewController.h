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

@property (weak, nonatomic) IBOutlet UIToolbar *topBar;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraRollButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *filterButton;
@property (weak, nonatomic) IBOutlet UISlider *zoomSlider;
@property (weak, nonatomic) IBOutlet UIToolbar *zoomToolBar;

- (IBAction)zoomIng:(id)sender;
- (IBAction)appsButton:(id)sender;
- (IBAction)flipButton:(id)sender;
- (IBAction)showInstructionView:(id)sender;
- (IBAction)captureButtonAction:(id)sender;
- (IBAction)colorButton:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *viewOutlet;

@end
