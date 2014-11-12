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
#import <AssetsLibrary/AssetsLibrary.h>
#import "FrameRateCalculator.h"
#import "A3InstructionViewController.h"
#import "A3UserDefaults.h"

static const NSString *AVCaptureStillImageIsCapturingStillImageContext = @"AVCaptureStillImageIsCapturingStillImageContext";
static const int MAX_ZOOM_FACTOR = 6;

NSString *const A3MagnifierFirstLoadCameraRoll = @"MagnifierFirstLoadCameraRoll";

@interface A3MagnifierViewController () <A3InstructionViewControllerDelegate>
{
    GLKView                     *_previewLayer;
    CIContext                   *_ciContext;
    EAGLContext                 *_eaglContext;
    CGRect                      _videoPreviewViewBounds;
	AVCaptureVideoDataOutput    *_videoDataOutput;
    AVCaptureSession            *_session;
	dispatch_queue_t 			_videoDataOutputQueue;
	AVCaptureStillImageOutput   *_stillImageOutput;
    CIImage                     *_ciImage;
	CGFloat 					_effectiveScale;
    CGFloat 					_brightFactor;
    BOOL 						_isInvertedColor;
    BOOL 						_isLightOn;
    BOOL						_isLosslessZoom;
    CGFloat						_beginGestureScale;
    CGPoint 					_centerXY;
    FrameRateCalculator 		*_frameCalculator;
}

@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) UIView *statusBarBackground;
@property (nonatomic, strong) A3InstructionViewController *instructionViewController;

@end

@implementation A3MagnifierViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _frameCalculator = [[FrameRateCalculator alloc] init];
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

    self.lastimageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,47,47)];
    [self.lastimageButton addTarget:_cameraRollButton.target action:_cameraRollButton.action forControlEvents:UIControlEventTouchUpInside];
	self.lastimageButton.layer.cornerRadius = 23.5;
	self.lastimageButton.layer.masksToBounds = YES;
    [self.bottomToolBar.items[0] setCustomView:self.lastimageButton];
    [self loadFirstPhoto];
    
    [self setupPreview];
    [self setupAVCapture];
    [self setupGestureRecognizer];
    [self setupBrightness];
    [self setupTorchLevelBar];
    
    if ([self getMaxZoom] == 1) {
        _isLosslessZoom = NO;
    } else {
        _isLosslessZoom = YES;
    }
    [self setupMagnifier];
    
    _isInvertedColor = NO;
    _isLightOn = NO;
    self.flashBrightSlider.value = 0.5;
    [self setupInstructionView];
}

- (BOOL)usesFullScreenInLandscape {
    return YES;
}


- (void)setPreviewRotation:(CGRect)screenBounds {
	CGAffineTransform   transform;
	UIInterfaceOrientation curInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
	if (curInterfaceOrientation == UIDeviceOrientationPortrait) {
		transform = CGAffineTransformMakeRotation(M_PI_2);
	} else if (curInterfaceOrientation == UIDeviceOrientationPortraitUpsideDown) {
		transform = CGAffineTransformMakeRotation(-M_PI_2);
	} else if (curInterfaceOrientation == UIDeviceOrientationLandscapeRight) {
		transform = CGAffineTransformMakeRotation(M_PI);
	} else {
		transform = CGAffineTransformMakeRotation(0);
	}
	if (_isLosslessZoom == NO &&
			_effectiveScale > 1) {
		[_previewLayer setTransform:CGAffineTransformScale(transform, _effectiveScale, _effectiveScale)];
	} else {
		[_previewLayer setTransform:transform];
	}

    if (_effectiveScale <= 1) {
        _previewLayer.frame = screenBounds;
    }
}

- (void)viewWillLayoutSubviews {
    CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
    if(!IS_IPHONE) {
        [self setPreviewRotation:screenBounds];
        [self.flashBrightSlider setFrame:CGRectMake(self.flashBrightSlider.frame.origin.x, self.flashBrightSlider.frame.origin.y, screenBounds.size.width - 106, self.flashBrightSlider.frame.size.height)];
        [self.brightnessSlider setFrame:CGRectMake(self.brightnessSlider.frame.origin.x, self.brightnessSlider.frame.origin.y, screenBounds.size.width - 106, self.brightnessSlider.frame.size.height)];
        [self.magnifierSlider setFrame:CGRectMake(self.magnifierSlider.frame.origin.x, self.magnifierSlider.frame.origin.y, screenBounds.size.width - 106, self.magnifierSlider.frame.size.height)];

    }
    else {
		[self setPreviewRotation:screenBounds];
        [self.flashBrightSlider setFrame:CGRectMake(self.flashBrightSlider.frame.origin.x, self.flashBrightSlider.frame.origin.y, screenBounds.size.width - 98, self.flashBrightSlider.frame.size.height)];
        [self.brightnessSlider setFrame:CGRectMake(self.brightnessSlider.frame.origin.x, self.brightnessSlider.frame.origin.y, screenBounds.size.width - 98, self.brightnessSlider.frame.size.height)];
        [self.magnifierSlider setFrame:CGRectMake(self.magnifierSlider.frame.origin.x, self.magnifierSlider.frame.origin.y, screenBounds.size.width - 98, self.magnifierSlider.frame.size.height)];
    }
 
    [self.statusBarBackground setFrame:CGRectMake(self.statusBarBackground.bounds.origin.x, self.statusBarBackground.bounds.origin.y , screenBounds.size.width , self.statusBarBackground.bounds.size.height)];
    [self.bottomToolBar setFrame:CGRectMake(self.bottomToolBar.bounds.origin.x, screenBounds.size.height - 74 , screenBounds.size.width, 74)];

}

- (void)setupPreview {
    CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
    _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    _previewLayer = [[GLKView alloc] initWithFrame:self.view.bounds context:_eaglContext];
    _previewLayer.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    _previewLayer.enableSetNeedsDisplay = NO;
    _previewLayer.userInteractionEnabled = YES;
    
    // because the native video image from the back camera is in UIDeviceOrientationLandscapeLeft (i.e. the home button is on the right), we need to apply a clockwise 90 degree transform so that we can draw the video preview as if we were in a landscape-oriented view; if you're using the front camera and you want to have a mirrored preview (so that the user is seeing themselves in the mirror), you need to apply an additional horizontal flip (by concatenating CGAffineTransformMakeScale(-1.0, 1.0) to the rotation transform)


    [self setPreviewRotation:screenBounds];
    //
    //
    //
	[self.view addSubview:_previewLayer];
	[self.view sendSubviewToBack:_previewLayer];
    
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
    [_previewLayer bindDrawable];
    
    
    _videoPreviewViewBounds = CGRectZero;
    _videoPreviewViewBounds.size.width = _previewLayer.drawableWidth;
    _videoPreviewViewBounds.size.height = _previewLayer.drawableHeight;

}

- (void)setupTorchLevelBar {
    self.flashToolBar.hidden = YES;
}

- (void)setupGestureRecognizer {
	UIGestureRecognizer *recognizer;
	recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnPreviewView)];
	[_previewLayer addGestureRecognizer:recognizer];

	recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFrom:)];
	recognizer.delegate = self;
	[_previewLayer addGestureRecognizer:recognizer];
}

- (void)setupMagnifier {
    self.magnifierSlider.minimumValue = 1;
    self.magnifierSlider.continuous = YES;
    self.magnifierSlider.value = 1;

    if (_isLosslessZoom == NO) {
        if ([[_stillImageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor] > MAX_ZOOM_FACTOR) {
            self.magnifierSlider.maximumValue = MAX_ZOOM_FACTOR;
        } else {
            self.magnifierSlider.maximumValue = [[_stillImageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
        }
    } else {
        self.magnifierSlider.maximumValue = [self getMaxZoom];
    }

}

- (void) setupBrightness {
    self.brightnessSlider.minimumValue = -1.0;
    self.brightnessSlider.maximumValue = 1.0;
    self.brightnessSlider.continuous = YES;
    self.brightnessSlider.value = 0.0;
}

- (void)notifyCameraShotSaveRule
{
    if (![[A3UserDefaults standardUserDefaults] boolForKey:A3MagnifierFirstLoadCameraRoll]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
                                                            message:NSLocalizedString(@"The photos you take with Magnifier are saved in your Camera Roll album in the Photos app.", @"The photos you take with Magnifier are saved in your Camera Roll album in the Photos app.")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil];
        [alertView show];
        [[A3UserDefaults standardUserDefaults] setBool:YES forKey:A3MagnifierFirstLoadCameraRoll];
    }
}

- (void)tapOnPreviewView {
	if (IS_IPHONE && IS_LANDSCAPE) return;

	BOOL toolBarsHidden = self.topToolBar.hidden;
	[self setToolBarsHidden:!toolBarsHidden];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
		_beginGestureScale = _effectiveScale;
	}
	return YES;
}

- (void) handlePinchFrom:(UIPinchGestureRecognizer *)recognizer {
    _effectiveScale = _beginGestureScale *recognizer.scale;
    FNLOG(@"effectiveScale = %f, beginGeustureScale = %f, recognizer.scale = %f", _effectiveScale, _beginGestureScale, recognizer.scale);
    if (_effectiveScale < self.magnifierSlider.minimumValue ) _effectiveScale = self.magnifierSlider.minimumValue;
    if(_effectiveScale > self.magnifierSlider.maximumValue) _effectiveScale = self.magnifierSlider.maximumValue;
    if(_effectiveScale == self.magnifierSlider.value) return;
    if (_isLosslessZoom == YES) {
        if (!_device.isRampingVideoZoom) {
            _device.videoZoomFactor = _effectiveScale;
        }
        
    } else {
        if (IS_IPHONE) {
            [_previewLayer setTransform:CGAffineTransformScale(CGAffineTransformMakeRotation(M_PI_2), _effectiveScale, _effectiveScale)];
        }
        else {
            UIInterfaceOrientation curDeviceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
            if (curDeviceOrientation == UIDeviceOrientationPortrait) {
                [_previewLayer setTransform:CGAffineTransformScale(CGAffineTransformMakeRotation(M_PI_2), _effectiveScale, _effectiveScale)];
            } else if (curDeviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
                [_previewLayer setTransform:CGAffineTransformScale(CGAffineTransformMakeRotation(-M_PI_2), _effectiveScale, _effectiveScale)];
            } else if (curDeviceOrientation == UIDeviceOrientationLandscapeRight) {
                [_previewLayer setTransform:CGAffineTransformScale(CGAffineTransformMakeRotation(M_PI), _effectiveScale, _effectiveScale)];
            } else {
                [_previewLayer setTransform:CGAffineTransformScale(CGAffineTransformMakeRotation(0), _effectiveScale, _effectiveScale)];
            }
        }
    }
    
    self.magnifierSlider.value = _effectiveScale;
}

- (void)setNavigationBarHidden:(BOOL)hidden {
	[self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
	[self.navigationController.navigationBar setShadowImage:nil];

	[self.navigationController setNavigationBarHidden:hidden];
}

- (void)setToolBarsHidden:(BOOL)hidden {
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)appsButtonAction:(id)sender {
    if (IS_IPHONE) {
		[[self mm_drawerController] toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
	} else {
		[[[A3AppDelegate instance] rootViewController] toggleLeftMenuViewOnOff];
	}
}

- (IBAction)invertButtonAction:(id)sender {
    _isInvertedColor = !_isInvertedColor;
}

- (IBAction)lightButtonAction:(id)sender {
    _isLightOn = !_isLightOn;
    
    if ([_device hasTorch]) {
        NSError *error = nil;
       // if ([_device lockForConfiguration:&error]) {
            
            if (_isLightOn == YES) {
                if (self.flashBrightSlider.value != 0.0) {
                    [_device setTorchMode:AVCaptureTorchModeOn];
                    if([_device setTorchModeOnWithLevel:self.flashBrightSlider.value error:&error]!= YES) {
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

- (IBAction)brightSliderAction:(id)sender {
    UISlider *bright = (UISlider *) sender;
    
    _brightFactor = bright.value;
}

- (IBAction)magnifierSliderAction:(id)sender {
    UISlider *magnify = (UISlider *) sender;
   // FNLOG(@"slider value = %f", magnify.value);
    if (_isLosslessZoom == YES) {
        if (!_device.isRampingVideoZoom) {
                //CGFloat sliderValue = pow( [self getMaxZoom], magnify.value );
                //FNLOG(@"max slider value = %f", sliderValue);
                _device.videoZoomFactor = magnify.value;
                    _effectiveScale = magnify.value;
        }
        
    } else {
        _effectiveScale = magnify.value;
        [_previewLayer setTransform:CGAffineTransformScale(CGAffineTransformMakeRotation(M_PI_2), _effectiveScale, _effectiveScale)];
    }

}

- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIInterfaceOrientation)deviceOrientation
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
												  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
												  otherButtonTitles:nil];
		[alertView show];
	});
}

- (CIImage *) ApplyFilters:(CIImage *) sourceImage {
    if (_brightFactor != 0.0) {
        sourceImage = [CIFilter filterWithName:@"CIColorControls" keysAndValues:
                         kCIInputImageKey, sourceImage,
                         @"inputBrightness", [NSNumber numberWithFloat:_brightFactor],
                         nil].outputImage;
    }
    if (_isInvertedColor == YES) {
        sourceImage = [CIFilter filterWithName:@"CIColorInvert" keysAndValues:
                         kCIInputImageKey, sourceImage,
                         nil].outputImage;
    }
    
    return sourceImage;
}

- (void)snapAnimation{
	UIView *flashView = [[UIView alloc] initWithFrame:[self screenBoundsAdjustedWithOrientation]];
	[flashView setBackgroundColor:[UIColor blackColor]];
	[flashView setAlpha:0.f];
	[[self view] addSubview:flashView];

	[UIView animateWithDuration:.1f
					 animations:^{
						 [flashView setAlpha:1.f];
					 }
					 completion:^(BOOL finished) {
						 [UIView animateWithDuration:.1f
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

- (IBAction)snapButtonAction:(id)sender {
    if (![self hasAuthorizationToAccessPhoto]) {
        return;
    }
    
	// Find out the current orientation and tell the still image output.
	AVCaptureConnection *stillImageConnection = [_stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
	UIInterfaceOrientation curDeviceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (IS_IPHONE) {
        curDeviceOrientation = (UIInterfaceOrientation)[[UIDevice currentDevice] orientation];
    }
	AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
	[stillImageConnection setVideoOrientation:avcaptureOrientation];
	if (_isLosslessZoom == NO) {
		[stillImageConnection setVideoScaleAndCropFactor:_effectiveScale];
	}

	[_stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
	[self snapAnimation];
	[_stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection
												   completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
													   if (error) {
														   [self displayErrorOnMainQueue:error withMessage:NSLocalizedString(@"Take picture failed.", @"Take picture failed.")];
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

														   ciSaveImg = [ciSaveImg imageByApplyingTransform:t];
														   CGImageRef cgimg = [_ciContext createCGImage:ciSaveImg fromRect:[ciSaveImg extent]];
														   [self.assetLibrary writeImageToSavedPhotosAlbum:cgimg metadata:[_ciImage properties] completionBlock:^(NSURL *assetURL, NSError *error) {
															   if (error) {
																   [self displayErrorOnMainQueue:error withMessage:NSLocalizedString(@"Save to camera roll failed.", @"Save to camera roll failed.")];
															   } else {
																   self.capturedPhotoURL = assetURL;
																   [self setImageOnCameraRollButton:[UIImage imageWithCGImage:cgimg]];
															   }
														   }];

														   // if (attachments)
														   //   CFRelease(attachments);
													   }
												   }
	];
}

- (IBAction)flashBrightSliderAction:(id)sender {
    UISlider  *flashslider = (UISlider  *)sender;
    if(_device.torchAvailable == YES) {
        if (flashslider.value == 0.0) {
            [_device setTorchMode:AVCaptureTorchModeOff];
        } else {
            [_device setTorchModeOnWithLevel:flashslider.value error:nil];
        }
    }
}

#pragma mark Instruction Related

static NSString *const A3V3InstructionDidShowForMagnifier = @"A3V3InstructionDidShowForMagnifier";

- (void)setupInstructionView
{
    if (![[A3UserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForMagnifier]) {
        [self showInstructionView:nil];
    }
}

- (IBAction)showInstructionView:(id)sender
{
	[[A3UserDefaults standardUserDefaults] setBool:YES forKey:A3V3InstructionDidShowForMagnifier];
	[[A3UserDefaults standardUserDefaults] synchronize];

    UIStoryboard *instructionStoryBoard = [UIStoryboard storyboardWithName:IS_IPHONE ? A3StoryboardInstruction_iPhone : A3StoryboardInstruction_iPad bundle:nil];
    _instructionViewController = [instructionStoryBoard instantiateViewControllerWithIdentifier:@"Magnifier"];
    self.instructionViewController.delegate = self;
    [self.navigationController.view addSubview:self.instructionViewController.view];
    self.instructionViewController.view.frame = self.navigationController.view.frame;
    self.instructionViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
}

- (void)dismissInstructionViewController:(UIView *)view
{
    [self.instructionViewController.view removeFromSuperview];
    self.instructionViewController = nil;
}

#pragma mark - AVCapture Setup

- (void)configureCameraForHighestFrameRate:(AVCaptureDevice *)device
{
    AVCaptureDeviceFormat *bestFormat = nil;
    AVFrameRateRange *bestFrameRateRange = nil;
    for ( AVCaptureDeviceFormat *format in [device formats] ) {
        for ( AVFrameRateRange *range in format.videoSupportedFrameRateRanges ) {
            if ( range.maxFrameRate > bestFrameRateRange.maxFrameRate ) {
                bestFormat = format;
                bestFrameRateRange = range;
            }
        }
    }
    if ( bestFormat ) {
            device.activeFormat = bestFormat;
            device.activeVideoMinFrameDuration = bestFrameRateRange.minFrameDuration;
            device.activeVideoMaxFrameDuration = bestFrameRateRange.maxFrameDuration;

    }
}


- (void)setupAVCapture {
    NSError *error = nil;
	
	_session = [AVCaptureSession new];
    [_session beginConfiguration];


	
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

    
    
	AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if ( [_session canAddInput:deviceInput] )
		[_session addInput:deviceInput];
    
    if ([_device supportsAVCaptureSessionPreset:AVCaptureSessionPresetHigh] == YES) {
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
    } else {
        [_session setSessionPreset:AVCaptureSessionPresetMedium];
    }
  
     if (_device.isAdjustingFocus == YES) {
     _device.focusMode = AVCaptureFocusModeAutoFocus;
     }
     
     if (_device.isAdjustingExposure == YES && [_device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
     _device.exposureMode = AVCaptureExposureModeAutoExpose;
     }
     
     if (_device.smoothAutoFocusSupported == YES) {
     _device.smoothAutoFocusEnabled = YES;
     }
     // _device.autoFocusRangeRestriction = AVCaptureAutoFocusRangeRestrictionFar;
     FNLOG(@"FocusMode = %d, ExposureMode = %d, AVCaptureAutoFocusRangeRestriction = %d, smoothfocus = %d", (int)_device.focusMode, (int)_device.exposureMode, (int)_device.autoFocusRangeRestriction, _device.smoothAutoFocusEnabled);
    
    //	  [self configureCameraForHighestFrameRate:_device];
    
    // Make a still image output
    
	_stillImageOutput = [AVCaptureStillImageOutput new];
    if (_stillImageOutput.stillImageStabilizationSupported == YES) {
        _stillImageOutput.automaticallyEnablesStillImageStabilizationWhenAvailable = YES;
    }
	if ([_session canAddOutput:_stillImageOutput] )
		[_session addOutput:_stillImageOutput];
	
    // Make a video data output
	_videoDataOutput = [AVCaptureVideoDataOutput new];
	
    // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
	NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:
									   [NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
	[_videoDataOutput setVideoSettings:rgbOutputSettings];
	[_videoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked (as we process the still image)
    
    // create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured
    // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
    // see the header doc for setSampleBufferDelegate:queue: for more information
	_videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
	[_videoDataOutput setSampleBufferDelegate:self queue:_videoDataOutputQueue];

    
    if ([_session canAddOutput:_videoDataOutput] )
		[_session addOutput:_videoDataOutput];
	[_session commitConfiguration];
	_effectiveScale = 1.0;
    
    [_frameCalculator reset];
	[_session startRunning];
}

- (void)cleanUp
{
	[self dismissInstructionViewController:nil];

    [_session stopRunning];
    for(AVCaptureInput *input in _session.inputs) {
        [_session removeInput:input];
    }
    
    for(AVCaptureOutput *output in _session.outputs) {
        [_session removeOutput:output];
    }
    _session = nil;
    [_device unlockForConfiguration];
    _device = nil;
    [_previewLayer removeFromSuperview];
    _previewLayer = nil;
    
    _device = nil;
    _statusBarBackground = nil;
    self.lastimageButton = nil;
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
    _ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:CFBridgingRelease(attachments)];

    CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    [_frameCalculator calculateFramerateAtTimestamp:timestamp];
    //FNLOG(@"%f fps",frameCalculator.frameRate);

    CGRect sourceExtent = _ciImage.extent;
    
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
        _ciImage = [self ApplyFilters:_ciImage];
    //dispatch_async(dispatch_get_main_queue(), ^(void) {

	[_ciContext drawImage:_ciImage inRect:_videoPreviewViewBounds fromRect:drawRect];
           [_previewLayer display];
   // });


}

#pragma mark - AVCapture Setup End

#pragma mark - set view rotate

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // makes the UI more Camera.app like
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        [UIView setAnimationsEnabled:NO];
    }
    if (_isLosslessZoom == YES) {
        _centerXY.x = _previewLayer.center.y;
        _centerXY.y = _previewLayer.center.x;
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [UIView setAnimationsEnabled:YES];
        [UIView beginAnimations:@"reappear" context:NULL];
        [UIView setAnimationDuration:0.75];
        [UIView commitAnimations];
    }
    if (_isLosslessZoom == YES) {
        _previewLayer.center = _centerXY;
    }
    
    CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
    [self setPreviewRotation:screenBounds];
}

@end
