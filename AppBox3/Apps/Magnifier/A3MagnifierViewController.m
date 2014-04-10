//
//  A3MagnifierViewController.m
//  A3TeamWork
//
//  Created by Soon Gyu Kim on 2/15/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3MagnifierViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+MMDrawerController.h"
#import "A3AppDelegate.h"
#import "common.h"
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import <AssertMacros.h>
#import <AssetsLibrary/AssetsLibrary.h>

static const NSString *AVCaptureStillImageIsCapturingStillImageContext = @"AVCaptureStillImageIsCapturingStillImageContext";
static const int MAX_ZOOM_FACTOR = 6;

@interface A3MagnifierViewController () {
    UIButton                    *lastimageButton;
    GLKView                     *previewLayer;
    CIContext                   *_ciContext;
    EAGLContext                 *_eaglContext;
    CGRect                      _videoPreviewViewBounds;
	AVCaptureVideoDataOutput    *videoDataOutput;
    AVCaptureSession            *session;
	dispatch_queue_t            videoDataOutputQueue;
	AVCaptureStillImageOutput   *stillImageOutput;
	BOOL                        isUsingFrontFacingCamera;
    CIImage                     *ciimg;
	CGFloat                     effectiveScale;
    CGFloat                     brightFactor;
    BOOL                        bInvertedColor;
    BOOL                        bLightOn;
    BOOL                        bLosslessZoom;
    CGFloat                     beginGestureScale;
}

@property (nonatomic, strong) ALAssetsLibrary *assetLibrary;
@property (nonatomic, strong) ALAssetsGroup *assetrollGroup;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) UIView *statusBarBackground;

@end

@implementation A3MagnifierViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self.view setBounds:[[UIScreen mainScreen] bounds]];
    [self setStatusBarBackground:[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 20)]];
    [self.statusBarBackground setBackgroundColor:[UIColor blackColor]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.view addSubview:self.statusBarBackground];
    
    [self setNavigationBarHidden:YES];
    [self setToolBarsHidden:YES];
    
    lastimageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,47,47)];
    [lastimageButton addTarget:_cameraRollButton.target action:_cameraRollButton.action forControlEvents:UIControlEventTouchUpInside];
    lastimageButton.layer.cornerRadius = 23.5;
    lastimageButton.layer.masksToBounds = YES;
    [self.bottomToolBar.items[0] setCustomView:lastimageButton];
    [self loadFirstPhoto];
    
    [self setupPreview];
    [self setupAVCapture];
    [self setupGestureRecognizer];
    [self setupBrightness];
    [self setupTorchLevelBar];
    

    if ([self getMaxZoom] == 1) {
        bLosslessZoom = NO;
    } else {
        bLosslessZoom = YES;
    }
    [self setupMagnifier];
    
    bInvertedColor = NO;
    bLightOn = NO;
    self.flashbrightslider.value = 0.0;
}

- (BOOL)usesFullScreenInLandscape {
    return YES;
}

- (void) setPreviewRotation:(CGRect)screenBounds {
    if (IS_IPAD) {
        UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
        if (curDeviceOrientation == UIDeviceOrientationPortrait) {
            previewLayer.transform = CGAffineTransformMakeRotation(M_PI_2);
        } else if (curDeviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
            previewLayer.transform = CGAffineTransformMakeRotation(-M_PI_2);
        } else if (curDeviceOrientation == UIDeviceOrientationLandscapeRight||
                   curDeviceOrientation == UIDeviceOrientationFaceUp) {
            previewLayer.transform = CGAffineTransformMakeRotation(M_PI);
        } else {
            previewLayer.transform = CGAffineTransformMakeRotation(0);
        }
    } else {
        previewLayer.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
    
    previewLayer.frame = screenBounds;
}

- (void)viewWillLayoutSubviews {
    CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
    if(IS_IPAD) {
        [self setPreviewRotation:screenBounds];
        [self.flashbrightslider setFrame:CGRectMake(self.flashbrightslider.frame.origin.x, self.flashbrightslider.frame.origin.y, screenBounds.size.width - 106, self.flashbrightslider.frame.size.height)];
        [self.brightnessslider setFrame:CGRectMake(self.brightnessslider.frame.origin.x, self.brightnessslider.frame.origin.y , screenBounds.size.width - 106, self.brightnessslider.frame.size.height)];
        [self.magnifierslider setFrame:CGRectMake(self.magnifierslider.frame.origin.x, self.magnifierslider.frame.origin.y  , screenBounds.size.width - 106, self.magnifierslider.frame.size.height)];

    }
    else {
        [self.flashbrightslider setFrame:CGRectMake(self.flashbrightslider.frame.origin.x, self.flashbrightslider.frame.origin.y, screenBounds.size.width - 98, self.flashbrightslider.frame.size.height)];
        [self.brightnessslider setFrame:CGRectMake(self.brightnessslider.frame.origin.x, self.brightnessslider.frame.origin.y , screenBounds.size.width - 98, self.brightnessslider.frame.size.height)];
        [self.magnifierslider setFrame:CGRectMake(self.magnifierslider.frame.origin.x, self.magnifierslider.frame.origin.y  , screenBounds.size.width - 98, self.magnifierslider.frame.size.height)];
        
    }
 
    [self.statusBarBackground setFrame:CGRectMake(self.statusBarBackground.bounds.origin.x, self.statusBarBackground.bounds.origin.y , screenBounds.size.width , self.statusBarBackground.bounds.size.height)];
    [self.bottomToolBar setFrame:CGRectMake(self.bottomToolBar.bounds.origin.x, screenBounds.size.height - 74 , screenBounds.size.width, 74)];

}

- (void) setupPreview {
    CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
    _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    previewLayer = [[GLKView alloc] initWithFrame:self.view.bounds context:_eaglContext];
    previewLayer.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    previewLayer.delegate = self;
    //_videoPreviewView.enableSetNeedsDisplay = NO;
    previewLayer.userInteractionEnabled = YES;
    
    // because the native video image from the back camera is in UIDeviceOrientationLandscapeLeft (i.e. the home button is on the right), we need to apply a clockwise 90 degree transform so that we can draw the video preview as if we were in a landscape-oriented view; if you're using the front camera and you want to have a mirrored preview (so that the user is seeing themselves in the mirror), you need to apply an additional horizontal flip (by concatenating CGAffineTransformMakeScale(-1.0, 1.0) to the rotation transform)


    [self setPreviewRotation:screenBounds];
    //
    //
    //
    [self.view addSubview:previewLayer];
    [self.view sendSubviewToBack:previewLayer];
    
    // create the CIContext instance, note that this must be done after _videoPreviewView is properly set up
    //glGenRenderbuffers(1, &_renderBuffer);
    //glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    _ciContext = [CIContext contextWithEAGLContext:_eaglContext options:@{kCIContextWorkingColorSpace : [NSNull null]} ];
    
    // bind the frame buffer to get the frame buffer width and height;
    // the bounds used by CIContext when drawing to a GLKView are in pixels (not points),
    // hence the need to read from the frame buffer's width and height;
    // in addition, since we will be accessing the bounds in another queue (_captureSessionQueue),
    // we want to obtain this piece of information so that we won't be
    // accessing _videoPreviewView's properties from another thread/queue
    [previewLayer bindDrawable];
    
    
    _videoPreviewViewBounds = CGRectZero;
    _videoPreviewViewBounds.size.width = previewLayer.drawableWidth;
    _videoPreviewViewBounds.size.height = previewLayer.drawableHeight;

}

- (void)setupTorchLevelBar {
    self.flashToolBar.hidden = YES;
}

- (void)setupGestureRecognizer {
	@autoreleasepool {
        UIGestureRecognizer *recognizer;
        recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnPreviewView)];
		[previewLayer addGestureRecognizer:recognizer];
        
        recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFrom:)];
        recognizer.delegate = self;
        [previewLayer addGestureRecognizer:recognizer];
        
	}
}

- (void)setupMagnifier {
    self.magnifierslider.minimumValue = 1;
    self.magnifierslider.continuous = YES;
    self.magnifierslider.value = 1;

    if (bLosslessZoom == NO) {
        if ([[stillImageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor] > MAX_ZOOM_FACTOR) {
            self.magnifierslider.maximumValue = MAX_ZOOM_FACTOR;
        } else {
            self.magnifierslider.maximumValue = [[stillImageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
        }
    } else {
        self.magnifierslider.maximumValue = [self getMaxZoom];
        NSError *err;
        [_device lockForConfiguration:&err];
    }

}

- (void) setupBrightness {
    self.brightnessslider.minimumValue = -1.0;
    self.brightnessslider.maximumValue = 1.0;
    self.brightnessslider.continuous = YES;
    self.brightnessslider.value = 0.0;
}

- (void)tapOnPreviewView {
	@autoreleasepool {
		BOOL toolBarsHidden = self.topToolBar.hidden;
		[self setToolBarsHidden:!toolBarsHidden];
	}
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
		beginGestureScale = effectiveScale;
	}
	return YES;
}

- (void) handlePinchFrom:(UIPinchGestureRecognizer *)recognizer {
    effectiveScale = beginGestureScale*recognizer.scale;
    //FNLOG(@"effectiveScale = %f, beginGeustureScale = %f, recognizer.scale = %f", effectiveScale, beginGestureScale, recognizer.scale);
    if (effectiveScale < self.magnifierslider.minimumValue ) effectiveScale = self.magnifierslider.minimumValue;
    if(effectiveScale > self.magnifierslider.maximumValue) effectiveScale = self.magnifierslider.maximumValue;
    if(effectiveScale == self.magnifierslider.value) return;
    if (bLosslessZoom == YES) {
        if (!_device.isRampingVideoZoom) {
            _device.videoZoomFactor = effectiveScale;
        }
        
    } else {
        if (!IS_IPAD) {
            [previewLayer setTransform:CGAffineTransformScale(CGAffineTransformMakeRotation(M_PI_2), effectiveScale, effectiveScale)];
        }
        else {
            UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
            if (curDeviceOrientation == UIDeviceOrientationPortrait) {
                [previewLayer setTransform:CGAffineTransformScale(CGAffineTransformMakeRotation(M_PI_2), effectiveScale, effectiveScale)];
            } else if (curDeviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
                [previewLayer setTransform:CGAffineTransformScale(CGAffineTransformMakeRotation(-M_PI_2), effectiveScale, effectiveScale)];
            } else if (curDeviceOrientation == UIDeviceOrientationLandscapeRight ||
                       curDeviceOrientation == UIDeviceOrientationFaceUp) {
                [previewLayer setTransform:CGAffineTransformScale(CGAffineTransformMakeRotation(M_PI), effectiveScale, effectiveScale)];
            } else {
                [previewLayer setTransform:CGAffineTransformScale(CGAffineTransformMakeRotation(0), effectiveScale, effectiveScale)];
            }
        }
    }
    
    self.magnifierslider.value = effectiveScale;
}

- (void)setNavigationBarHidden:(BOOL)hidden {
	@autoreleasepool {
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:nil];
		
		[self.navigationController setNavigationBarHidden:hidden];
	}
}

- (void)setToolBarsHidden:(BOOL)hidden {
	@autoreleasepool {
        self.topToolBar.hidden = hidden;
        self.bottomToolBar.hidden = hidden;
        if (hidden == YES) {
            [self.flashToolBar setFrame:CGRectMake(self.flashToolBar.frame.origin.x,
                                                        self.view.frame.size.height - self.magnifierToolBar.frame.size.height - self.brightnessToolBar.frame.size.height - self.flashToolBar.frame.size.height,
                                                        self.flashToolBar.frame.size.width,
                                                        self.flashToolBar.frame.size.height)];
            [self.brightnessToolBar setFrame:CGRectMake(self.brightnessToolBar.frame.origin.x,
                                                        self.view.frame.size.height - self.magnifierToolBar.frame.size.height - self.brightnessToolBar.frame.size.height,
                                                        self.brightnessToolBar.frame.size.width,
                                                        self.brightnessToolBar.frame.size.height)];
            [self.magnifierToolBar setFrame:CGRectMake(self.magnifierToolBar.frame.origin.x,
                                                        self.view.frame.size.height - self.magnifierToolBar.frame.size.height,
                                                        self.magnifierToolBar.frame.size.width,
                                                        self.magnifierToolBar.frame.size.height)];
        } else {
            [self.flashToolBar setFrame:CGRectMake(self.flashToolBar.frame.origin.x,
                                                        self.view.frame.size.height - self.magnifierToolBar.frame.size.height - self.brightnessToolBar.frame.size.height - self.bottomToolBar.frame.size.height-self.flashToolBar.frame.size.height,
                                                        self.flashToolBar.frame.size.width,
                                                        self.flashToolBar.frame.size.height)];
            [self.brightnessToolBar setFrame:CGRectMake(self.brightnessToolBar.frame.origin.x,
                                                        self.view.frame.size.height - self.magnifierToolBar.frame.size.height - self.brightnessToolBar.frame.size.height - self.bottomToolBar.frame.size.height,
                                                        self.brightnessToolBar.frame.size.width,
                                                        self.brightnessToolBar.frame.size.height)];
            [self.magnifierToolBar setFrame:CGRectMake(self.magnifierToolBar.frame.origin.x,
                                                       self.view.frame.size.height - self.magnifierToolBar.frame.size.height - self.bottomToolBar.frame.size.height,
                                                       self.magnifierToolBar.frame.size.width,
                                                       self.magnifierToolBar.frame.size.height)];        }
        self.statusBarBackground.hidden = hidden;
        [[UIApplication sharedApplication] setStatusBarHidden:hidden];
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)appsButton:(id)sender {
    if (IS_IPHONE) {
		[[self mm_drawerController] toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
	} else {
		[[[A3AppDelegate instance] rootViewController] toggleLeftMenuViewOnOff];
	}
}

- (IBAction)invertButton:(id)sender {
    bInvertedColor = !bInvertedColor;
}

- (IBAction)lightButton:(id)sender {
    bLightOn = !bLightOn;
    
    if ([_device hasTorch]) {
        NSError *error = nil;
       // if ([_device lockForConfiguration:&error]) {
            
            if (bLightOn == YES) {
                if (self.flashbrightslider.value != 0.0) {
                    [_device setTorchMode:AVCaptureTorchModeOn];
                    if([_device setTorchModeOnWithLevel:self.flashbrightslider.value error:&error]!= YES) {
                            FNLOG(@"setTorchModeOnWithLevel error: %@", error);
                    }
                } else {
                    [_device setTorchMode:AVCaptureTorchModeOff];
                }
                self.flashToolBar.hidden = NO;
                [self.lightButton setImage:[UIImage imageNamed:@"m_flash_on"]];
               // [_device setFlashMode:AVCaptureFlashModeOn];
            }
            else {
                [_device setTorchMode:AVCaptureTorchModeOff];
                self.flashToolBar.hidden = YES;
                                [self.lightButton setImage:[UIImage imageNamed:@"m_flash_off"]];
                //[_device setFlashMode:AVCaptureFlashModeOff];
            }
         //   [_device unlockForConfiguration];
        //} else {
          //  FNLOG(@"FlashOffButton %@", error);
        //}
    }
}

- (IBAction)brightSlider:(id)sender {
    UISlider *bright = (UISlider *) sender;
    
    brightFactor = bright.value;
}

- (IBAction)manifierslider:(id)sender {
    UISlider *magnify = (UISlider *) sender;
   // FNLOG(@"slider value = %f", magnify.value);
    if (bLosslessZoom == YES) {
        if (!_device.isRampingVideoZoom) {
                //CGFloat sliderValue = pow( [self getMaxZoom], magnify.value );
                //FNLOG(@"max slider value = %f", sliderValue);
                _device.videoZoomFactor = magnify.value;
                    effectiveScale = magnify.value;
        }
        
    } else {
        effectiveScale = magnify.value;
        [previewLayer setTransform:CGAffineTransformScale(CGAffineTransformMakeRotation(M_PI_2), effectiveScale, effectiveScale)];
    }

}

- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
	AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
	if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
		result = AVCaptureVideoOrientationLandscapeRight;
	else if ( deviceOrientation == UIDeviceOrientationLandscapeRight ||
             deviceOrientation == UIDeviceOrientationFaceUp)
		result = AVCaptureVideoOrientationLandscapeLeft;
	return result;
}

// utility routine to display error aleart if takePicture fails
- (void)displayErrorOnMainQueue:(NSError *)error withMessage:(NSString *)message
{
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ (%d)", message, (int)[error code]]
															message:[error localizedDescription]
														   delegate:nil
												  cancelButtonTitle:@"Dismiss"
												  otherButtonTitles:nil];
		[alertView show];
	});
}

- (CIImage *) ApplyFilters:(CIImage *) sourceImage {
    if (brightFactor != 0.0) {
        sourceImage = [CIFilter filterWithName:@"CIColorControls" keysAndValues:
                         kCIInputImageKey, sourceImage,
                         @"inputBrightness", [NSNumber numberWithFloat:brightFactor],
                         nil].outputImage;
    }
    if (bInvertedColor == YES) {
        sourceImage = [CIFilter filterWithName:@"CIColorInvert" keysAndValues:
                         kCIInputImageKey, sourceImage,
                         nil].outputImage;
    }
    
    return sourceImage;
}

- (void) snapAnimation{
    @autoreleasepool {
        UIView *flashView = [[UIView alloc] initWithFrame:[previewLayer frame]];
        [flashView setBackgroundColor:[UIColor whiteColor]];
        [flashView setAlpha:0.f];
        [[[self view] window] addSubview:flashView];
        
        [UIView animateWithDuration:.4f
                         animations:^{
                             [flashView setAlpha:1.f];
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:.4f
                                              animations:^{
                                                  [flashView setAlpha:0.f];
                                              }
                                              completion:^(BOOL finished){
                                                  [flashView removeFromSuperview];
                                              }
                              ];
                         }
         ];
    }
}


- (IBAction)snapButton:(id)sender {
    // Find out the current orientation and tell the still image output.
    @autoreleasepool {
        
	AVCaptureConnection *stillImageConnection = [stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
	UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
	AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
	[stillImageConnection setVideoOrientation:avcaptureOrientation];
        if (bLosslessZoom == NO) {
            [stillImageConnection setVideoScaleAndCropFactor:effectiveScale];
        }
	
	[stillImageOutput setOutputSettings:[NSDictionary dictionaryWithObject:AVVideoCodecJPEG
																		forKey:AVVideoCodecKey]];
    [self snapAnimation];
	[stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection
                                                  completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                      if (error) {
                                                          [self displayErrorOnMainQueue:error withMessage:@"Take picture failed"];
                                                      }
                                                      else {
                                                          // trivial simple JPEG case
                                                          NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                         // CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault,
                                                         //                                                             imageDataSampleBuffer,
                                                          //                                                            kCMAttachmentMode_ShouldPropagate);
                                                          
                                                          CIImage *ciSaveImg = [[CIImage alloc] initWithData:jpegData];
                                                          
                                                          ciSaveImg = [self ApplyFilters:ciSaveImg];
                                                          
                                                          CGAffineTransform t;
                                                          
                                                          if (curDeviceOrientation == UIDeviceOrientationPortrait) {
                                                              t = CGAffineTransformMakeRotation(-M_PI / 2);
                                                          } else if (curDeviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
                                                              t = CGAffineTransformMakeRotation(M_PI / 2);
                                                          } else if (curDeviceOrientation == UIDeviceOrientationLandscapeRight ||
                                                                     curDeviceOrientation == UIDeviceOrientationFaceUp) {
                                                              t = CGAffineTransformMakeRotation(M_PI);
                                                          } else {
                                                              t = CGAffineTransformMakeRotation(0);
                                                          }
                                                          
                                                          CGImageRef cgimgRef = [_ciContext createCGImage:ciSaveImg fromRect:[ciSaveImg extent]];
                                                          
                                                          
                                                          ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                                                          [library writeImageToSavedPhotosAlbum:cgimgRef metadata:[ciSaveImg properties]/*CFBridgingRelease(attachments)*/ completionBlock:^(NSURL *assetURL, NSError *error) {
                                                              if (error) {
                                                                  [self displayErrorOnMainQueue:error withMessage:@"Save to camera roll failed"];
                                                              } else {
                                                                  [self setImageOnCameraRollButton:[UIImage imageWithCIImage:[ciSaveImg imageByApplyingTransform:t]]];
                                                              }
                                                          }];
                                                          
                                                             // if (attachments)
                                                               //   CFRelease(attachments);
                                                          }
                                                  }
	 ];
    }
}

- (IBAction)loadCameraRoll:(id)sender {
    // Create browser
	MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = NO;
    browser.displayNavArrows = YES;
    browser.displaySelectionButtons = NO;
    browser.alwaysShowControls = NO;
    //browser.wantsFullScreenLayout = YES; deprecated
    browser.zoomPhotosToFill = YES;
    browser.enableGrid = YES;
    browser.startOnGrid = NO;
    [browser setCurrentPhotoIndex:0];
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nc animated:YES completion:nil];
}

- (IBAction)flashbrightslider:(id)sender {
    UISlider  *flashslider = (UISlider  *)sender;
    if(_device.torchAvailable == YES) {
        if (flashslider.value == 0.0) {
            [_device setTorchMode:AVCaptureTorchModeOff];
        } else {
            [_device setTorchModeOnWithLevel:flashslider.value error:nil];
        }
    }
}

#pragma mark - AVCapture Setup
- (void)setupAVCapture {
    NSError *error = nil;
	
	session = [AVCaptureSession new];
    [session beginConfiguration];
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if ([session canSetSessionPreset:AVCaptureSessionPreset1920x1080] == YES) {
            [session setSessionPreset:AVCaptureSessionPreset1920x1080];
        } else if([session canSetSessionPreset:AVCaptureSessionPreset1280x720] == YES) {
            [session setSessionPreset:AVCaptureSessionPreset1280x720];
        }
        else {
            [session setSessionPreset:AVCaptureSessionPreset640x480];
        }
    }
	else
	    [session setSessionPreset:AVCaptureSessionPresetPhoto];
	
    // Select a video device, make an input
	_device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if([_device lockForConfiguration:&error] != YES)
    {
        FNLOG(@"Lock failure %@", error);
    }
    
    if (!_device.hasTorch) {
        [self.lightButton setImage:nil];
        [self.lightButton  setEnabled:NO];
    }
    if (_device.isAdjustingFocus == YES) {
        _device.focusMode = AVCaptureFocusModeAutoFocus;
    }
    
    if (_device.isAdjustingExposure == YES) {
        _device.exposureMode = AVCaptureExposureModeAutoExpose;
    }
    
    if (_device.smoothAutoFocusSupported == YES) {
        _device.smoothAutoFocusEnabled = YES;
    }
   // _device.autoFocusRangeRestriction = AVCaptureAutoFocusRangeRestrictionFar;
    FNLOG(@"FocusMode = %d, ExposureMode = %d, AVCaptureAutoFocusRangeRestriction = %d, smoothfocus = %d", (int)_device.focusMode, (int)_device.exposureMode, (int)_device.autoFocusRangeRestriction, _device.smoothAutoFocusEnabled);
    
	AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
	
    isUsingFrontFacingCamera = NO;
	if ( [session canAddInput:deviceInput] )
		[session addInput:deviceInput];
	
    // Make a still image output
	stillImageOutput = [AVCaptureStillImageOutput new];
    if (stillImageOutput.stillImageStabilizationSupported == YES) {
        stillImageOutput.automaticallyEnablesStillImageStabilizationWhenAvailable = YES;
    }
	if ( [session canAddOutput:stillImageOutput] )
		[session addOutput:stillImageOutput];
	
    // Make a video data output
	videoDataOutput = [AVCaptureVideoDataOutput new];
	
    // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
	NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:
									   [NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
	[videoDataOutput setVideoSettings:rgbOutputSettings];
	[videoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked (as we process the still image)
    
    // create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured
    // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
    // see the header doc for setSampleBufferDelegate:queue: for more information
	videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
	[videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
	
    if ( [session canAddOutput:videoDataOutput] )
		[session addOutput:videoDataOutput];
	[session commitConfiguration];
	effectiveScale = 1.0;
    
	[session startRunning];
}

- (void)cleanUp
{
    [session stopRunning];
    session = nil;
    [_device unlockForConfiguration];
    _device = nil;
    [previewLayer removeFromSuperview];
    previewLayer = nil;
    
    _assetLibrary = nil;
    _assetrollGroup = nil;
    _device = nil;
    _statusBarBackground = nil;
    lastimageButton = nil;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}
- (CGFloat) getMaxZoom {
	return MIN( _device.activeFormat.videoMaxZoomFactor, MAX_ZOOM_FACTOR );
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
	// got an image
	CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    ciimg = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:CFBridgingRelease(attachments)];

    [previewLayer display];

}

#pragma mark - AVCapture Setup End
#pragma GLKViewDelegate
- (void) glkView:(GLKView *)view drawInRect:(CGRect)rect {
    CGRect sourceExtent = ciimg.extent;
    
    CGFloat sourceAspect = sourceExtent.size.width / sourceExtent.size.height;
    CGFloat previewAspect = _videoPreviewViewBounds.size.width  / _videoPreviewViewBounds.size.height;
    
    // we want to maintain the aspect radio of the screen size, so we clip the video image
    CGRect drawRect = sourceExtent;
    if (sourceAspect > previewAspect)
    {
        // use full height of the video image, and center crop the width
        drawRect.origin.x += (drawRect.size.width - drawRect.size.height * previewAspect) / 2.0;
        drawRect.size.width = drawRect.size.height * previewAspect;
        
    }
    else
    {
        // use full width of the video image, and center crop the height
        drawRect.origin.y += (drawRect.size.height - drawRect.size.width / previewAspect) / 2.0;
        drawRect.size.height = drawRect.size.width / previewAspect;
        
    }

    ciimg = [self ApplyFilters:ciimg];
    
    
    [_ciContext drawImage:ciimg inRect:_videoPreviewViewBounds fromRect:drawRect];
    
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return [_assetrollGroup numberOfAssets];
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    @autoreleasepool {
        NSMutableArray *assetArray = [NSMutableArray new];
        if (index < [_assetrollGroup numberOfAssets])
        {
            [_assetrollGroup enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:[_assetrollGroup numberOfAssets] - index-1] options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger i, BOOL *stop) {
                if (result != nil) {
                    [assetArray addObject:result];
                    *stop = YES;
                }
            }];
            ALAsset *asset = [assetArray objectAtIndex:0];
            return [MWPhoto photoWithURL:asset.defaultRepresentation.url];
        }
    }
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    @autoreleasepool {
        NSMutableArray *assetArray = [NSMutableArray new];
        if (index < [_assetrollGroup numberOfAssets])
        {
            [_assetrollGroup enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:[_assetrollGroup numberOfAssets] - index-1] options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger i, BOOL *stop) {
                if (result != nil) {
                    [assetArray addObject:result];
                    *stop = YES;
                }
            }];
            ALAsset *asset = [assetArray objectAtIndex:0];
            return [MWPhoto photoWithImage:[UIImage imageWithCGImage:asset.thumbnail]];
        }
    }
    return nil;
}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}

//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
//    NSLog(@"ACTION!");
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    //  NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

#pragma mark - Load Assets
-(UIImage *)cropImageWithSquare:(UIImage *)source
{
    CGSize finalsize = CGSizeMake(47,47);
    
    CGFloat scale = MAX(
                        finalsize.width/source.size.width,
                        finalsize.height/source.size.height);
    CGFloat width = source.size.width * scale;
    CGFloat height = source.size.height * scale;
    
    CGRect rr = CGRectMake( 0, 0, width, height);
    
    UIGraphicsBeginImageContextWithOptions(finalsize, NO, 0);
    [source drawInRect:rr];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


- (void) loadFirstPhoto {
    _assetLibrary = [ALAssetsLibrary new];
    [_assetLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                 usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                     if (group != nil) {
                                         [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                                         _assetrollGroup = group;
                                         [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
                                             if (alAsset) {
                                                 ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                                                 UIImage *latestPhoto = [UIImage imageWithCGImage:[representation fullScreenImage]];
                                                 // Stop the enumerations
                                                 *innerStop = YES;
                                                 [self setImageOnCameraRollButton:latestPhoto];
                                             }
                                         }];
                                     }
                                 }
                               failureBlock:^(NSError *error) {
                                   FNLOG("NO GroupSavedPhotos");
                               }
     ];
    
}

#pragma mark - set image icon
- (void) setImageOnCameraRollButton:(UIImage *)image {
    [lastimageButton setBackgroundImage:[self cropImageWithSquare:image] forState:UIControlStateNormal];
}

@end
