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
#import "UIImage+imageWithColor.h"
#import "UIViewController+extension.h"
#import "A3AppDelegate.h"
#import "A3SyncManager.h"

#define MAX_ZOOM_FACTOR 	6.0

NSString *const A3MagnifierFirstLoadCameraRoll = @"MagnifierFirstLoadCameraRoll";

@interface A3MagnifierViewController () <A3InstructionViewControllerDelegate, GLKViewDelegate, A3ViewControllerProtocol, GADBannerViewDelegate>
{
    GLKView                     *_previewLayer;
    CIContext                   *_ciContext;
    EAGLContext                 *_eaglContext;
    CGRect                      _videoPreviewViewBounds;
	AVCaptureVideoDataOutput    *_videoDataOutput;
    AVCaptureSession            *_captureSession;
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

@property (nonatomic, strong) A3InstructionViewController *instructionViewController;
@property (nonatomic, strong) AVCaptureDevice *videoDevice;
@property (weak, nonatomic) IBOutlet UIToolbar *statusToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *lightButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *snapButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraRollButton;
@property (weak, nonatomic) IBOutlet UIToolbar *topToolBar;
@property (weak, nonatomic) IBOutlet UIToolbar *brightnessToolBar;
@property (weak, nonatomic) IBOutlet UIToolbar *magnifierToolBar;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolBar;
@property (weak, nonatomic) IBOutlet UISlider *zoomSlider;
@property (weak, nonatomic) IBOutlet UISlider *brightnessSlider;
@property (weak, nonatomic) IBOutlet UISlider *flashBrightSlider;
@property (weak, nonatomic) IBOutlet UIToolbar *flashToolBar;

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
	
    [self setNavigationBarHidden:YES];
    [self setToolBarsHidden:YES];

    self.lastimageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,47,47)];
    [self.lastimageButton addTarget:_cameraRollButton.target action:_cameraRollButton.action forControlEvents:UIControlEventTouchUpInside];
	self.lastimageButton.layer.cornerRadius = 23.5;
	self.lastimageButton.layer.masksToBounds = YES;
    [self.bottomToolBar.items[0] setCustomView:self.lastimageButton];
    [self loadFirstPhoto];

	_effectiveScale = 1.0;
	[self setToolbarTransparent];
    [self setupPreview];
    [self setupAVCapture];
    [self setupGestureRecognizer];
    [self setupBrightness];
    [self setupTorchLevelBar];
    
	[self setupZoomSlider];
    
    _isInvertedColor = NO;
    _isLightOn = NO;
    self.flashBrightSlider.value = 0.5;
    [self setupInstructionView];

    [self configureLayout];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc {
	[self removeObserver];
}

- (void)prepareClose {
	[self removeObserver];
}

- (void)setToolbarTransparent {
	UIImage *image = [UIImage toolbarBackgroundImage];
	[_statusToolbar setBackgroundImage:image forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
	[_topToolBar setBackgroundImage:image forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
	[_topToolBar setShadowImage:[UIImage new] forToolbarPosition:UIBarPositionAny];
	[_brightnessToolBar setBackgroundImage:image forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
	[_magnifierToolBar setBackgroundImage:image forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
	[_bottomToolBar setBackgroundImage:image forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
	[_flashToolBar setBackgroundImage:image forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
}

- (BOOL)resignFirstResponder {
	NSString *startingAppName = [[A3UserDefaults standardUserDefaults] objectForKey:kA3AppsStartingAppName];
	if ([startingAppName length] && ![startingAppName isEqualToString:A3AppName_Magnifier]) {
		[self.instructionViewController.view removeFromSuperview];
		self.instructionViewController = nil;
	}
	return [super resignFirstResponder];
}

- (BOOL)usesFullScreenInLandscape {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

    [self setToolBarsHidden:_topToolBar.hidden];

	if ([A3UIDevice canAccessCamera]) {
#if !TARGET_IPHONE_SIMULATOR
		[_captureSession startRunning];
#endif
	} else {
		[self requestAuthorizationForCamera:NSLocalizedString(A3AppName_Magnifier, nil) afterAuthorizedHandler:NULL];
	}
	[self setupButtonEnabled];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
	[self setupBannerViewForAdUnitID:AdMobAdUnitIDMagnifier keywords:@[@"magnifier", @"glasses"] delegate:self];
}

- (void)applicationDidBecomeActive {
	[self setupButtonEnabled];

	if ([A3UIDevice canAccessCamera]) {
		if (!_captureSession) {
			[self setupAVCapture];
			[self setupBrightness];
			[self setupZoomSlider];
		}
#if !TARGET_IPHONE_SIMULATOR
		[_captureSession startRunning];
#endif
		[self applyZoomScale];

		if (_isLightOn) {
			[self applyLED];
		}
	} else {
		_captureSession = nil;
		_videoDevice = nil;
		_stillImageOutput = nil;
		_videoDataOutput = nil;
		_videoDataOutputQueue = nil;

		[self requestAuthorizationForCamera:NSLocalizedString(A3AppName_Magnifier, nil) afterAuthorizedHandler:NULL];
	}
}

- (void)setupButtonEnabled {
	BOOL enable = [A3UIDevice canAccessCamera];
	[self.snapButton setEnabled:enable];
	[self.lightButton setEnabled:enable];
}

- (CGAffineTransform)getMagnifierRotationTransform {
	CGAffineTransform   transform;

	UIInterfaceOrientation curDeviceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
	if (curDeviceOrientation == UIDeviceOrientationPortrait) {
		transform = CGAffineTransformMakeRotation(M_PI_2);
	} else if (curDeviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
		transform = CGAffineTransformMakeRotation(-M_PI_2);
	} else if (curDeviceOrientation == UIDeviceOrientationLandscapeRight) {
		transform = CGAffineTransformMakeRotation(M_PI);
	} else {
		transform = CGAffineTransformMakeRotation(0);
	}

	return transform;
}

- (void)setPreviewRotation:(CGRect)screenBounds {
	if (!_isLosslessZoom) {
		[_previewLayer setTransform:CGAffineTransformScale([self getMagnifierRotationTransform], _effectiveScale, _effectiveScale)];
	} else {
		CGAffineTransform   transform = [self getMagnifierRotationTransform];
		[_previewLayer setTransform:transform];
	}
	if (IS_IPHONE) {
		if (_effectiveScale == 1.0) {
			_previewLayer.frame = screenBounds;
		}
	} else {
		_previewLayer.frame = screenBounds;
	}
}

- (void)configureLayout {
    CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
    CGFloat verticalBottomOffset = 0;
    UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] myKeyWindow] safeAreaInsets];
    if (safeAreaInsets.top > 20) {
        verticalBottomOffset = -safeAreaInsets.bottom;
        _topToolBar.frame = CGRectMake(0, safeAreaInsets.top, screenBounds.size.width, 44);
        _bottomToolBar.frame = CGRectMake(0, screenBounds.size.height - verticalBottomOffset, screenBounds.size.width, 44);
    }
    if(!IS_IPHONE) {
        [self setPreviewRotation:screenBounds];
        [self.flashBrightSlider setFrame:CGRectMake(self.flashBrightSlider.frame.origin.x, self.flashBrightSlider.frame.origin.y, screenBounds.size.width - 106, self.flashBrightSlider.frame.size.height)];
        [self.brightnessSlider setFrame:CGRectMake(self.brightnessSlider.frame.origin.x, self.brightnessSlider.frame.origin.y, screenBounds.size.width - 106, self.brightnessSlider.frame.size.height)];
        [self.zoomSlider setFrame:CGRectMake(self.zoomSlider.frame.origin.x, self.zoomSlider.frame.origin.y, screenBounds.size.width - 106, self.zoomSlider.frame.size.height)];

    }
    else {
		[self setPreviewRotation:screenBounds];
        [self.flashBrightSlider setFrame:CGRectMake(self.flashBrightSlider.frame.origin.x, self.flashBrightSlider.frame.origin.y + verticalBottomOffset, screenBounds.size.width - 98, self.flashBrightSlider.frame.size.height)];
        [self.brightnessSlider setFrame:CGRectMake(self.brightnessSlider.frame.origin.x, self.brightnessSlider.frame.origin.y + verticalBottomOffset, screenBounds.size.width - 98, self.brightnessSlider.frame.size.height)];
        [self.zoomSlider setFrame:CGRectMake(self.zoomSlider.frame.origin.x, self.zoomSlider.frame.origin.y + verticalBottomOffset, screenBounds.size.width - 98, self.zoomSlider.frame.size.height)];
    }
 
    _statusToolbar.frame = CGRectMake(0, 0, screenBounds.size.width, safeAreaInsets.top);
	[self setToolBarsHidden:_topToolBar.hidden];
}

- (void)setupPreview {
    CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
    _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    _previewLayer = [[GLKView alloc] initWithFrame:self.view.bounds context:_eaglContext];
	_previewLayer.delegate = self;
    _previewLayer.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    _previewLayer.enableSetNeedsDisplay = NO;
    _previewLayer.userInteractionEnabled = YES;
    
    // because the native video image from the back camera is in UIDeviceOrientationLandscapeLeft (i.e. the home button is on the right), we need to apply a clockwise 90 degree transform so that we can draw the video preview as if we were in a landscape-oriented view; if you're using the front camera and you want to have a mirrored preview (so that the user is seeing themselves in the mirror), you need to apply an additional horizontal flip (by concatenating CGAffineTransformMakeScale(-1.0, 1.0) to the rotation transform)

    [self setPreviewRotation:screenBounds];

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

- (void)setupZoomSlider {
    self.zoomSlider.minimumValue = 1;
    self.zoomSlider.continuous = YES;
    self.zoomSlider.value = 1;

    if (!_isLosslessZoom) {
		if (_stillImageOutput) {
			CGFloat deviceMax = [[_stillImageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
			if (deviceMax == 1) {
				self.zoomSlider.maximumValue = MAX_ZOOM_FACTOR;
			} else {
				self.zoomSlider.maximumValue = MIN(MAX_ZOOM_FACTOR, deviceMax);
			}
		} else {
			self.zoomSlider.maximumValue = 1.0;
		}
	} else {
        self.zoomSlider.maximumValue = [self getMaxZoom];
    }
}

- (void)setupBrightness {
    self.brightnessSlider.minimumValue = -1.0;
    self.brightnessSlider.maximumValue = 1.0;
    self.brightnessSlider.continuous = YES;
    self.brightnessSlider.value = 0.0;
}

- (void)notifyCameraShotSaveRule
{
    if (![[A3UserDefaults standardUserDefaults] boolForKey:A3MagnifierFirstLoadCameraRoll]) {
        [self presentAlertWithTitle:NSLocalizedString(@"Info", @"Info")
                            message:NSLocalizedString(@"The photos you take with Magnifier are saved in your Camera Roll album in the Photos app.", @"The photos you take with Magnifier are saved in your Camera Roll album in the Photos app.")];
        [[A3UserDefaults standardUserDefaults] setBool:YES forKey:A3MagnifierFirstLoadCameraRoll];
    }
}

- (void)tapOnPreviewView {
	if (IS_IPHONE && [UIWindow interfaceOrientationIsLandscape]) return;

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

- (void)handlePinchFrom:(UIPinchGestureRecognizer *)recognizer {
    _effectiveScale = _beginGestureScale *recognizer.scale;
    FNLOG(@"effectiveScale = %f, beginGeustureScale = %f, recognizer.scale = %f", _effectiveScale, _beginGestureScale, recognizer.scale);

    if (_effectiveScale < self.zoomSlider.minimumValue ) {
		_effectiveScale = self.zoomSlider.minimumValue;
	}
    if(_effectiveScale > self.zoomSlider.maximumValue) {
		_effectiveScale = self.zoomSlider.maximumValue;
	}
    if(_effectiveScale == self.zoomSlider.value) {
		return;
	}
	self.zoomSlider.value = _effectiveScale;

	[self applyZoomScale];
}

- (void)applyZoomScale {
	if (_isLosslessZoom) {
		if (!_videoDevice.isRampingVideoZoom) {
			[_videoDevice lockForConfiguration:nil];
			_videoDevice.videoZoomFactor = _effectiveScale;
			[_videoDevice unlockForConfiguration];
		}
	} else {
		[_previewLayer setTransform:CGAffineTransformScale([self getMagnifierRotationTransform], _effectiveScale, _effectiveScale)];
		CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
		if (IS_IPHONE) {
			if (_effectiveScale == 1.0) {
				_previewLayer.frame = screenBounds;
			}
		} else {
			_previewLayer.frame = screenBounds;
		}
	}
}

- (void)setNavigationBarHidden:(BOOL)hidden {
	[self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
	[self.navigationController.navigationBar setShadowImage:nil];

	[self.navigationController setNavigationBarHidden:hidden];
}

- (void)setToolBarsHidden:(BOOL)hidden {
	self.topToolBar.hidden = hidden;
	self.bottomToolBar.hidden = hidden;

    CGFloat verticalBottomOffset = 0;
    UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] myKeyWindow] safeAreaInsets];
    verticalBottomOffset = -safeAreaInsets.bottom;
    
	[self.bottomToolBar setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.size.height - 74 + verticalBottomOffset , self.view.frame.size.width, 74 + safeAreaInsets.bottom)];
	if (hidden == YES) {
		[self.flashToolBar setFrame:CGRectMake(self.flashToolBar.frame.origin.x,
				self.view.frame.size.height - self.magnifierToolBar.frame.size.height - self.brightnessToolBar.frame.size.height - self.flashToolBar.frame.size.height + verticalBottomOffset,
				self.flashToolBar.frame.size.width,
				self.flashToolBar.frame.size.height)];
		[self.brightnessToolBar setFrame:CGRectMake(self.brightnessToolBar.frame.origin.x,
				self.view.frame.size.height - self.magnifierToolBar.frame.size.height - self.brightnessToolBar.frame.size.height + verticalBottomOffset,
				self.brightnessToolBar.frame.size.width,
				self.brightnessToolBar.frame.size.height)];
		[self.magnifierToolBar setFrame:CGRectMake(self.magnifierToolBar.frame.origin.x,
				self.view.frame.size.height - self.magnifierToolBar.frame.size.height + verticalBottomOffset,
				self.magnifierToolBar.frame.size.width,
				self.magnifierToolBar.frame.size.height)];
	} else {
		[self.flashToolBar setFrame:CGRectMake(self.flashToolBar.frame.origin.x,
				self.view.frame.size.height - self.magnifierToolBar.frame.size.height - self.brightnessToolBar.frame.size.height - self.bottomToolBar.frame.size.height-self.flashToolBar.frame.size.height + verticalBottomOffset,
				self.flashToolBar.frame.size.width,
				self.flashToolBar.frame.size.height)];
		[self.brightnessToolBar setFrame:CGRectMake(self.brightnessToolBar.frame.origin.x,
				self.view.frame.size.height - self.magnifierToolBar.frame.size.height - self.brightnessToolBar.frame.size.height - self.bottomToolBar.frame.size.height + verticalBottomOffset,
				self.brightnessToolBar.frame.size.width,
				self.brightnessToolBar.frame.size.height)];
		[self.magnifierToolBar setFrame:CGRectMake(self.magnifierToolBar.frame.origin.x,
				self.view.frame.size.height - self.magnifierToolBar.frame.size.height - self.bottomToolBar.frame.size.height + verticalBottomOffset,
				self.magnifierToolBar.frame.size.width,
				self.magnifierToolBar.frame.size.height)];
    }
    FNLOGRECT(_flashToolBar.frame);
    FNLOGRECT(_brightnessToolBar.frame);
    FNLOGRECT(_magnifierToolBar.frame);
	_statusToolbar.hidden = hidden;
	[[UIApplication sharedApplication] setStatusBarHidden:hidden];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)appsButtonAction:(id)sender {
    if (IS_IPHONE) {
		if ([[A3AppDelegate instance] isMainMenuStyleList]) {
			[[A3AppDelegate instance].drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
		} else {
			UINavigationController *navigationController = [A3AppDelegate instance].currentMainNavigationController;
			[navigationController popViewControllerAnimated:YES];
			[navigationController setToolbarHidden:YES];
		}
	} else {
		[[[A3AppDelegate instance] rootViewController_iPad] toggleLeftMenuViewOnOff];
	}
}

- (IBAction)invertButtonAction:(id)sender {
    _isInvertedColor = !_isInvertedColor;
}

- (IBAction)lightButtonAction:(id)sender {
    _isLightOn = !_isLightOn;
    [self applyLED];
}

- (void)applyLED {
	if ([_videoDevice hasTorch]) {
		[_videoDevice lockForConfiguration:nil];
		NSError *error = nil;
		if (_isLightOn) {
			if (self.flashBrightSlider.value != 0.0) {
				[_videoDevice setTorchMode:AVCaptureTorchModeOn];
				if([_videoDevice setTorchModeOnWithLevel:self.flashBrightSlider.value error:&error]!= YES) {
					FNLOG(@"setTorchModeOnWithLevel error: %@", error);
				}
			} else {
				[_videoDevice setTorchMode:AVCaptureTorchModeOff];
			}
			self.flashToolBar.hidden = NO;
			[self.lightButton setImage:[UIImage imageNamed:@"m_flash_on"]];
		}
		else {
			[_videoDevice setTorchMode:AVCaptureTorchModeOff];
			self.flashToolBar.hidden = YES;
			[self.lightButton setImage:[UIImage imageNamed:@"m_flash_off"]];
		}
		[_videoDevice unlockForConfiguration];
	}
}

#pragma mark - Brightness & Zoom Slider

- (IBAction)brightSliderAction:(id)sender {
    UISlider *bright = (UISlider *) sender;
    
    _brightFactor = bright.value;
}

- (IBAction)magnifierSliderAction:(UISlider *)zoomSlider {
	_effectiveScale = zoomSlider.value;
	[self applyZoomScale];
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

- (CIImage *)applyFilters:(CIImage *) sourceImage {
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
	UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (IS_IPHONE) {
        interfaceOrientation = (UIInterfaceOrientation)[[UIDevice currentDevice] orientation];
    }
	AVCaptureVideoOrientation avCaptureOrientation = [self avOrientationForDeviceOrientation:interfaceOrientation];
	[stillImageConnection setVideoOrientation:avCaptureOrientation];
	if (!_isLosslessZoom) {
		CGFloat scale = MIN(_effectiveScale, stillImageConnection.videoMaxScaleAndCropFactor);
		[stillImageConnection setVideoScaleAndCropFactor:scale];
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

														   ciSaveImg = [self applyFilters:ciSaveImg];

														   CGAffineTransform t = [self getRotationTransformWithOption:NO];
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
	if(_videoDevice.torchAvailable && [_videoDevice lockForConfiguration:nil]) {
		if (flashslider.value == 0.0) {
			[_videoDevice setTorchMode:AVCaptureTorchModeOff];
		} else {
			[_videoDevice setTorchModeOnWithLevel:flashslider.value error:nil];
		}
		[_videoDevice unlockForConfiguration];
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
	if (![A3UIDevice canAccessCamera]) return;

    NSError *error = nil;

	_captureSession = [AVCaptureSession new];
    [_captureSession beginConfiguration];

    // Select a video device, make an input
	_videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	_isLosslessZoom = _videoDevice.activeFormat.videoMaxZoomFactor > 1.0;
    [_videoDevice lockForConfiguration:nil];

    if (!_videoDevice.hasTorch) {
        [self.lightButton setImage:nil];
        [self.lightButton  setEnabled:NO];
    }

	AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_videoDevice error:&error];
    if ( [_captureSession canAddInput:deviceInput] )
		[_captureSession addInput:deviceInput];

	if (_videoDevice.isAdjustingFocus) {
		_videoDevice.focusMode = AVCaptureFocusModeAutoFocus;
	}

	if (_videoDevice.isAdjustingExposure && [_videoDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
		_videoDevice.exposureMode = AVCaptureExposureModeAutoExpose;
	}

	if (_videoDevice.smoothAutoFocusSupported) {
		_videoDevice.smoothAutoFocusEnabled = YES;
	}
	// _device.autoFocusRangeRestriction = AVCaptureAutoFocusRangeRestrictionFar;
	FNLOG(@"FocusMode = %d, ExposureMode = %d, AVCaptureAutoFocusRangeRestriction = %d, smoothfocus = %d", (int) _videoDevice.focusMode, (int) _videoDevice.exposureMode, (int) _videoDevice.autoFocusRangeRestriction, _videoDevice.smoothAutoFocusEnabled);
    
    //	  [self configureCameraForHighestFrameRate:_device];

	[_videoDevice unlockForConfiguration];

    // Make a still image output
    
	_stillImageOutput = [AVCaptureStillImageOutput new];
    if (_stillImageOutput.stillImageStabilizationSupported) {
        _stillImageOutput.automaticallyEnablesStillImageStabilizationWhenAvailable = YES;
    }
	if ([_captureSession canAddOutput:_stillImageOutput] )
		[_captureSession addOutput:_stillImageOutput];
	
    // Make a video data output
	_videoDataOutput = [AVCaptureVideoDataOutput new];
	
    // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
	NSDictionary *rgbOutputSettings = @{(id) kCVPixelBufferPixelFormatTypeKey : @(kCMPixelFormat_32BGRA)};
	[_videoDataOutput setVideoSettings:rgbOutputSettings];
	[_videoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked (as we process the still image)
    
    // create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured
    // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
    // see the header doc for setSampleBufferDelegate:queue: for more information
	_videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
	[_videoDataOutput setSampleBufferDelegate:self queue:_videoDataOutputQueue];

    if ([_captureSession canAddOutput:_videoDataOutput] )
		[_captureSession addOutput:_videoDataOutput];

	NSString *deviceModel = [A3UIDevice platform];
	if (	[deviceModel isEqualToString:@"iPhone 4"] ||
			[deviceModel isEqualToString:@"iPhone 4s"])
	{
		if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetMedium]) {
			[_captureSession setSessionPreset:AVCaptureSessionPresetMedium];
		} else {
			[_captureSession setSessionPreset:AVCaptureSessionPresetLow];
		}
	} else {
		if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetHigh]) {
			[_captureSession setSessionPreset:AVCaptureSessionPresetHigh];
		} else {
			if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetMedium]) {
				[_captureSession setSessionPreset:AVCaptureSessionPresetMedium];
			} else {
				[_captureSession setSessionPreset:AVCaptureSessionPresetLow];
			}
		}
	}

	[_captureSession commitConfiguration];
	_effectiveScale = 1.0;
    
    [_frameCalculator reset];
#if !TARGET_IPHONE_SIMULATOR
	[_captureSession startRunning];
#endif
}

- (void)cleanUp
{
	[self dismissInstructionViewController:nil];

    [_captureSession stopRunning];
    for(AVCaptureInput *input in _captureSession.inputs) {
        [_captureSession removeInput:input];
    }
    
    for(AVCaptureOutput *output in _captureSession.outputs) {
        [_captureSession removeOutput:output];
    }
    _captureSession = nil;
    _videoDevice = nil;
    [_previewLayer removeFromSuperview];
    _previewLayer = nil;
    
    _videoDevice = nil;
    self.lastimageButton = nil;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (CGFloat)getMaxZoom {
	return MIN( _videoDevice.activeFormat.videoMaxZoomFactor, MAX_ZOOM_FACTOR );
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

	[_previewLayer bindDrawable];
	[_previewLayer display];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
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

	_ciImage = [self applyFilters:_ciImage];

	[_ciContext drawImage:_ciImage inRect:_videoPreviewViewBounds fromRect:drawRect];
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

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

	CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
	[self setPreviewRotation:screenBounds];

	[self configureLayout];
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
}

- (NSUInteger)a3SupportedOrientations {
	return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortrait;
}

@end
