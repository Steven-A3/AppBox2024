//  A3MagnifierViewController.h
//  A3TeamWork
//
//  Created by Soon Gyu Kim on 2/15/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MWPhotoBrowser.h"
#import "A3CameraViewController.h"

@interface A3MagnifierViewController : A3CameraViewController <AVCaptureVideoDataOutputSampleBufferDelegate, UIGestureRecognizerDelegate>
- (IBAction)appsButtonAction:(id)sender;
- (IBAction)invertButtonAction:(id)sender;
- (IBAction)lightButtonAction:(id)sender;
- (IBAction)brightSliderAction:(id)sender;
- (IBAction)magnifierSliderAction:(id)sender;
- (IBAction)snapButtonAction:(id)sender;
- (IBAction)flashBrightSliderAction:(id)sender;
- (IBAction)showInstructionView:(id)sender;

@property (weak, nonatomic) IBOutlet UIToolbar *topToolBar;
@property (weak, nonatomic) IBOutlet UIToolbar *brightnessToolBar;
@property (weak, nonatomic) IBOutlet UIToolbar *magnifierToolBar;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraRollButton;
@property (weak, nonatomic) IBOutlet UISlider *magnifierSlider;
@property (weak, nonatomic) IBOutlet UISlider *brightnessSlider;
@property (weak, nonatomic) IBOutlet UISlider *flashBrightSlider;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *lightButton;
@property (weak, nonatomic) IBOutlet UIToolbar *flashToolBar;

@end
