//  A3MagnifierViewController.h
//  A3TeamWork
//
//  Created by Soon Gyu Kim on 2/15/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <GLKit/GLKit.h>
#import "MWPhotoBrowser.h"

@interface A3MagnifierViewController : UIViewController <MWPhotoBrowserDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, UIGestureRecognizerDelegate>
- (IBAction)appsButton:(id)sender;
- (IBAction)invertButton:(id)sender;
- (IBAction)lightButton:(id)sender;
- (IBAction)brightSlider:(id)sender;
- (IBAction)manifierslider:(id)sender;
- (IBAction)snapButton:(id)sender;
- (IBAction)loadCameraRoll:(id)sender;
- (IBAction)flashbrightslider:(id)sender;
- (IBAction)showInstructionView:(id)sender;
@property (weak, nonatomic) IBOutlet UIToolbar *topToolBar;
@property (weak, nonatomic) IBOutlet UIToolbar *brightnessToolBar;
@property (weak, nonatomic) IBOutlet UIToolbar *magnifierToolBar;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraRollButton;
@property (weak, nonatomic) IBOutlet UISlider *magnifierslider;
@property (weak, nonatomic) IBOutlet UISlider *brightnessslider;
@property (weak, nonatomic) IBOutlet UISlider *flashbrightslider;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *lightButton;
@property (weak, nonatomic) IBOutlet UIToolbar *flashToolBar;


@end
