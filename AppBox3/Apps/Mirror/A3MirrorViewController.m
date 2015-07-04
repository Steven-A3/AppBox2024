//
//  A3MirrorViewController.m
//  A3TeamWork
//
//  Created by Soon Gyu Kim on 1/25/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3MirrorViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+MMDrawerController.h"
#import "FrameRateCalculator.h"
#import "A3InstructionViewController.h"
#import "A3UserDefaults.h"
#import "A3CameraViewController.h"

#define MAX_ZOOM_FACTOR 	6.0

NSString *const A3MirrorFirstLoadCameraRoll = @"A3MirrorFirstLoadCameraRoll";

@interface A3MirrorViewController() <A3InstructionViewControllerDelegate, A3ViewControllerProtocol>
{
	GLKView *_videoPreviewViewNoFilter;     // OPEN GLES Aware-View
	GLKView *_videoPreviewViewMonoFilter;
	GLKView *_videoPreviewViewTonalFilter;
	GLKView *_videoPreviewViewNoirFilter;
	GLKView *_videoPreviewViewFadeFilter;
	GLKView *_videoPreviewViewChromeFilter;
	GLKView *_videoPreviewViewProcessFilter;
	GLKView *_videoPreviewViewTransferFilter;
	GLKView *_videoPreviewViewInstantFilter;

	CIContext *_ciContext;
	EAGLContext *_eaglContext;
	CGRect _videoPreviewViewBounds;
	AVCaptureDevice *_videoDevice;
	AVCaptureSession *_captureSession;
	AVCaptureStillImageOutput *_stillImageOutput;

	UILabel *_monoLabel;
	UILabel *_tonalLabel;
	UILabel *_noirLabel;
	UILabel *_fadeLabel;
	UILabel *_noneLabel;
	UILabel *_chromeLabel;
	UILabel *_processLabel;
	UILabel *_transferLabel;
	UILabel *_instantLabel;

	dispatch_queue_t _captureSessionQueue;
	CIImage *_ciImage;
	//GLuint _renderBuffer;
	BOOL _isFlip;
	BOOL _isMultipleView;
	CGSize _originalsize;
	BOOL _isFiltersEnabled;
	BOOL _isLosslessZoom;
	NSUInteger _filterIndex;
	CGFloat _effectiveScale;
	CGFloat _beginGestureScale;
	CMTime _currentMaxDuration;
	CMTime _currentMinDuration;
	AVFrameRateRange *_slowFrameRateRange;
    CGPoint _center;
	FrameRateCalculator *_frameCalculator;
}

@property (nonatomic, strong) UIView *statusBarBackground;
@property (nonatomic, strong) A3InstructionViewController *instructionViewController;
@property (nonatomic, strong) NSMutableArray *filterViews;
@property (nonatomic, strong) NSMutableArray *filterLabels;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *snapButton;
@property (weak, nonatomic) IBOutlet UIToolbar *topBar;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraRollButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *filterButton;
@property (weak, nonatomic) IBOutlet UISlider *zoomSlider;
@property (weak, nonatomic) IBOutlet UIToolbar *zoomToolBar;

@end

@implementation A3MirrorViewController {
	NSArray *filterViewCoordinate;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// create the dispatch queue for handling capture session delegate method calls
		_captureSessionQueue = dispatch_queue_create("capture_session_queue", DISPATCH_QUEUE_SERIAL);

		// create coordinates for filter views
		filterViewCoordinate = @[ @[@[@0,@0],@[@1,@0],@[@2,@0],@[@0,@1],@[@1,@1],@[@2,@1],@[@0,@2],@[@1,@2],@[@2,@2]],
				@[@[@-1,@0],@[@0,@0],@[@1,@0],@[@-1,@1],@[@0,@1],@[@1,@1],@[@-1,@2],@[@0, @2],@[@1,@2]],
				@[@[@-2, @0],@[@-1, @0],@[@0,@0],@[@-2,@1],@[@-1,@1],@[@0,@1],@[@-2,@2],@[@-1,@2],@[@0,@2]],
				@[@[@0, @-1],@[@1,@-1],@[@2,@-1],@[@0,@0],@[@1,@0],@[@2,@0],@[@0,@1],@[@1,@1],@[@2,@1]],
				@[@[@-1,@-1],@[@0,@-1],@[@1,@-1],@[@-1,@0],@[@0,@0],@[@1,@0],@[@-1,@1],@[@0,@1],@[@1,@1]],
				@[@[@-2,@-1],@[@-1,@-1],@[@0,@-1],@[@-2,@0],@[@-1,@0],@[@0,@0],@[@-2,@1],@[@-1,@1],@[@0,@1]],
				@[@[@0,@-2],@[@1, @-2],@[@2,@-2],@[@0,@-1],@[@1,@-1],@[@2,@-1],@[@0,@0],@[@1,@0],@[@2,@0]],
				@[@[@-1,@-2],@[@0,@-2],@[@1,@-2],@[@-1,@-1],@[@0,@-1],@[@1,@-1],@[@-1,@0],@[@0,@0], @[@1,@0]],
				@[@[@-2,@-2],@[@1,@-2],@[@0,@-2],@[@-2,@-1],@[@-1,@-1],@[@0,@-1],@[@-2,@0],@[@-1,@0], @[@0,@0]]
		];
		_frameCalculator = [[FrameRateCalculator alloc] init];
	}
	return self;
}

#pragma mark - video setup

- (void)notifyCameraShotSaveRule
{
    if ([[A3UserDefaults standardUserDefaults] objectForKey:A3MirrorFirstLoadCameraRoll]) {
        return;
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
                                                        message:NSLocalizedString(@"The photos you take with Mirror are saved in your Camera Roll album in the Photos app.", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                              otherButtonTitles:nil];
    [alertView show];
    [[A3UserDefaults standardUserDefaults] setBool:YES forKey:A3MirrorFirstLoadCameraRoll];
    [[A3UserDefaults standardUserDefaults] synchronize];
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
	[self setNavigationBarHidden:YES];
	[self setToolBarsHidden:YES];
	[self.zoomToolBar setHidden:YES];   // it will show after _videoDevice Setup finish

	self.view.bounds = screenBounds;
	[self.view setBackgroundColor:[UIColor blackColor]];

	self.statusBarBackground = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, screenBounds.size.width, 20)];
	[self.statusBarBackground setBackgroundColor:[UIColor blackColor]];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	[self.view addSubview:self.statusBarBackground];
	[self.statusBarBackground setHidden:YES];
	_isFlip = YES;

	[self setupAVCaptureSession];
	
	[self setupPreview];

	[self setupFilterView];

	[self setupPhotoButton];

	[self setupTopToolbar];
	[self setupZoomSlider];
}

- (void)setupPhotoButton {
	self.lastimageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,47,47)];
	[self.lastimageButton addTarget:_cameraRollButton.target action:_cameraRollButton.action forControlEvents:UIControlEventTouchUpInside];
	self.lastimageButton.layer.cornerRadius = 23.5;
	self.lastimageButton.layer.masksToBounds = YES;
	[self.bottomBar.items[0] setCustomView:self.lastimageButton];
	[self loadFirstPhoto];
}

- (void)setupTopToolbar {
	[_topBar setTranslucent:YES];
	[_topBar setBackgroundImage:[UIImage new]
			 forToolbarPosition:UIBarPositionAny
					 barMetrics:UIBarMetricsDefault];
	[_topBar setShadowImage:[UIImage new]
		 forToolbarPosition:UIToolbarPositionAny];
}

- (void)setupPreview {
	_eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

	// create the CIContext instance, note that this must be done after _videoPreviewView is properly set up
	//glGenRenderbuffers(1, &_renderBuffer);
	//glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
	_ciContext = [CIContext contextWithEAGLContext:_eaglContext options:@{kCIContextWorkingColorSpace : [NSNull null]} ];

	_videoPreviewViewNoFilter = [[GLKView alloc] initWithFrame:self.view.bounds context:_eaglContext];
	[_videoPreviewViewNoFilter setDrawableDepthFormat:GLKViewDrawableDepthFormat24];
	[_videoPreviewViewNoFilter setDelegate:self];
	[_videoPreviewViewNoFilter setUserInteractionEnabled:YES];
	[_videoPreviewViewNoFilter setEnableSetNeedsDisplay:NO];
	CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
	[self setFilterViewRotation:_videoPreviewViewNoFilter withScreenBounds:screenBounds];
	// because the native video image from the back camera is in UIDeviceOrientationLandscapeLeft (i.e. the home button is on the right), we need to apply a clockwise 90 degree transform so that we can draw the video preview as if we were in a landscape-oriented view; if you're using the front camera and you want to have a mirrored preview (so that the user is seeing themselves in the mirror), you need to apply an additional horizontal flip (by concatenating CGAffineTransformMakeScale(-1.0, 1.0) to the rotation transform)
	[self.view addSubview:_videoPreviewViewNoFilter];
	[self.view sendSubviewToBack:_videoPreviewViewNoFilter];

	// bind the frame buffer to get the frame buffer width and height;
	// the bounds used by CIContext when drawing to a GLKView are in pixels (not points),
	// hence the need to read from the frame buffer's width and height;
	// in addition, since we will be accessing the bounds in another queue (_captureSessionQueue),
	// we want to obtain this piece of information so that we won't be
	// accessing _videoPreviewView's properties from another thread/queue
	[_videoPreviewViewNoFilter bindDrawable];

	_videoPreviewViewBounds = CGRectZero;
	_videoPreviewViewBounds.size.width = _videoPreviewViewNoFilter.drawableWidth;
	_videoPreviewViewBounds.size.height = _videoPreviewViewNoFilter.drawableHeight;
	// FNLOG(@"Filter Size:width = %f, height = %f, buffer size: width = %f, height = %f",
	//      _videoPreviewViewNoFilter.frame.size.width,
	//    _videoPreviewViewNoFilter.frame.size.height,
	//  _videoPreviewViewBounds.size.width,
	//_videoPreviewViewBounds.size.height);
	_originalsize = _videoPreviewViewBounds.size;
	_isMultipleView = NO;
	_isFiltersEnabled = NO;
	_effectiveScale = 1.0;
	_filterIndex = A3MirrorNoFilter;
}

- (void)setupFilterView {
	if(_isLosslessZoom == YES) _isFiltersEnabled = YES;
	if (_isFiltersEnabled == YES) {
		[self.filterButton setImage:[[UIImage imageNamed:@"m_color"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
	} else {
		[self.filterButton setImage:nil];
		[self.filterButton setEnabled:NO];
	}
	// create multi filter view with GestureRecognizer which should be done after AVCaptureSession initialize(setupAVCaptureSession)
	if (_isFiltersEnabled == YES) {
		[self createFilterViews];
		[self showOneFilterView:_filterIndex];
	}
	[self setupGestureRecognizer];
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

- (BOOL)resignFirstResponder {
	NSString *startingAppName = [[A3UserDefaults standardUserDefaults] objectForKey:kA3AppsStartingAppName];
	if ([startingAppName length] && ![startingAppName isEqualToString:A3AppName_Mirror]) {
		[self.instructionViewController.view removeFromSuperview];
		self.instructionViewController = nil;
	}
	return [super resignFirstResponder];
}

- (void)applicationDidBecomeActive {
	if ([A3UIDevice canAccessCamera]) {
		if (_captureSession) {
			[self setupAVCaptureSession];
			[self setupFilterView];
			[self setupZoomSlider];
			[self configureLayout];
		}
		[_captureSession startRunning];
		[self applyZoomFactor];
	} else {
		if (_isMultipleView) {
			[self showOneFilterView:_filterIndex];
		}
		[self requestAuthorizationForCamera:NSLocalizedString(A3AppName_Mirror, nil)];

		_captureSession = nil;
		_videoDevice = nil;
		_stillImageOutput = nil;
	}
	[self setupButtonEnabled];
}

- (void)applyZoomFactor {
	_zoomSlider.value = _effectiveScale;
	if (_isLosslessZoom) {
		if ([_videoDevice lockForConfiguration:nil]) {
			_videoDevice.videoZoomFactor = _effectiveScale;
			[_videoDevice unlockForConfiguration];
		} else {
			_effectiveScale = _videoDevice.videoZoomFactor;
			_zoomSlider.value = _effectiveScale;
		}
	} else {
		CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
		[self setFilterViewRotation:[self currentFilterView] withScreenBounds:screenBounds];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	FNLOG();
	if ([A3UIDevice canAccessCamera]) {
		double delayInSeconds = 1.0;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			[_captureSession startRunning];
		});
	} else {
		[self requestAuthorizationForCamera:NSLocalizedString(A3AppName_Mirror, nil)];
	}

	[self setupButtonEnabled];
	[self configureLayout];

	if ([self isMovingToParentViewController] || [self isBeingPresented]) {
		A3AppDelegate *appDelegate = [A3AppDelegate instance];
		if (appDelegate.shouldPresentAd && [appDelegate.googleAdInterstitial isReady]) {
			[appDelegate.googleAdInterstitial presentFromRootViewController:self];
		}
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	FNLOG(@"[self isMovingToParentViewController] = %@", @([self isMovingToParentViewController]));
	if ([self isMovingToParentViewController]) {
        [self setupInstructionView];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
	}
	if (IS_IPHONE && IS_LANDSCAPE) {
		[self setToolBarsHidden:YES];
	}
}

- (void)setupButtonEnabled {
	BOOL enabled = [A3UIDevice canAccessCamera];
	[self.snapButton setEnabled:enabled];
	[self.filterButton setEnabled:enabled && _isLosslessZoom];
}

- (void)configureLayout {
	CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	if (_isMultipleView == YES) {
		[self.zoomSlider setFrame:CGRectMake(self.zoomSlider.frame.origin.x, self.zoomSlider.frame.origin.y, screenBounds.size.width - 106, self.zoomSlider.frame.size.height)];
	}
	else {
		[self setFilterViewRotation:[self currentFilterView] withScreenBounds:screenBounds];
		[self.zoomSlider setFrame:CGRectMake(self.zoomSlider.frame.origin.x, self.zoomSlider.frame.origin.y, screenBounds.size.width - 98, self.zoomSlider.frame.size.height)];
	}
	[_topBar setItems:[self topToolBarBarButtons] animated:YES];

	[self.statusBarBackground setFrame:CGRectMake(self.statusBarBackground.bounds.origin.x, self.statusBarBackground.bounds.origin.y , screenBounds.size.width , self.statusBarBackground.bounds.size.height)];

	[self setToolBarsHidden:_topBar.hidden];
}

- (UIBarButtonItem *)appsBarButton {
    UIBarButtonItem *appButton = [[UIBarButtonItem alloc] initWithTitle:@"Apps" style:UIBarButtonItemStyleBordered target:self action:@selector(appsButton:)];
    return appButton;
}

- (NSArray *)topToolBarBarButtons {
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *help = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"help"] style:UIBarButtonItemStyleBordered target:self action:@selector(showInstructionView:)];
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = 24;
    UIBarButtonItem *flip = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"m_horizon"] style:UIBarButtonItemStyleBordered target:self action:@selector(flipButton:)];
    return @[[self appsBarButton], flexibleSpace, help, fixedSpace, flip];
}

- (void)setFilterViewRotation:(GLKView *)filterView withScreenBounds:(CGRect)frame {
	[self setViewRotation:filterView];

	if (IS_IPHONE) {
		if (_effectiveScale == 1.0) {
			filterView.frame = frame;
		}
	} else {
		filterView.frame = frame;
	}
}

- (void)setViewRotation:(UIView *)view {
    CGFloat scaleFactor = _isLosslessZoom ? 1.0 : _effectiveScale;
	CGAffineTransform scaleTransform;
	CGAffineTransform rotationTransform;
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	switch (orientation) {
		case UIInterfaceOrientationPortrait:
			scaleTransform = CGAffineTransformMakeScale(scaleFactor, _isFlip ? -scaleFactor : scaleFactor);
			rotationTransform = CGAffineTransformMakeRotation(_isFlip ? -M_PI_2 : M_PI_2);
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			scaleTransform = CGAffineTransformMakeScale(scaleFactor, _isFlip ? -scaleFactor : scaleFactor);
			rotationTransform = CGAffineTransformMakeRotation(_isFlip ? M_PI_2 : -M_PI_2);
			break;
		case UIInterfaceOrientationLandscapeLeft:
			scaleTransform = CGAffineTransformMakeScale(_isFlip ? -scaleFactor : scaleFactor, scaleFactor);
			rotationTransform = CGAffineTransformMakeRotation(0);
			break;
		case UIInterfaceOrientationLandscapeRight:
			scaleTransform = CGAffineTransformMakeScale(_isFlip ? -scaleFactor : scaleFactor, scaleFactor);
			rotationTransform = CGAffineTransformMakeRotation(M_PI);
			break;
		default:
			scaleTransform = CGAffineTransformMakeScale(_isFlip ? -scaleFactor : scaleFactor, scaleFactor);
			rotationTransform = CGAffineTransformMakeRotation(0);
	}
	[view setTransform:CGAffineTransformConcat(rotationTransform, scaleTransform)];
}

- (BOOL)usesFullScreenInLandscape {
	return YES;
}

- (CGFloat)getMaxZoom {
	return MIN( _videoDevice.activeFormat.videoMaxZoomFactor, MAX_ZOOM_FACTOR );
}

- (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
	AVCaptureDevice *captureDevice = [devices firstObject];

	for (AVCaptureDevice *device in devices)
	{
		if ([device position] == position)
		{
			captureDevice = device;
			break;
		}
	}

	return captureDevice;
}

- (void)setupAVCaptureSession
{
	if (![A3UIDevice canAccessCamera]) return;

	NSError *error = nil;

	// create the capture session
	_captureSession = [AVCaptureSession new];
	[_captureSession beginConfiguration];

	// get the input device and also validate the settings
	_videoDevice = [self deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionFront];

	// obtain device input
	AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_videoDevice error:&error];
	if (!videoDeviceInput)
	{
		FNLOG(@"Unable to obtain video device input, error: %@", error);
		return;
	}

	// CoreImage wants BGRA pixel format
	NSDictionary *outputSettings = @{ (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};

	// create and configure video data output
	AVCaptureVideoDataOutput *videoDataOutput = [AVCaptureVideoDataOutput new];
	videoDataOutput.videoSettings = outputSettings;
	videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
	[videoDataOutput setSampleBufferDelegate:self queue:_captureSessionQueue];

	if (![_captureSession canAddOutput:videoDataOutput])
	{
		FNLOG(@"Cannot add video data output");
		_captureSession = nil;
		return;
	}
	// Make a still image output
	_stillImageOutput = [AVCaptureStillImageOutput new];
	if (_stillImageOutput.stillImageStabilizationSupported) {
		_stillImageOutput.automaticallyEnablesStillImageStabilizationWhenAvailable = YES;
	}
	if ([_captureSession canAddOutput:_stillImageOutput] )
		[_captureSession addOutput:_stillImageOutput];

	// connect the video device input and video data and still image outputs
	[_captureSession addInput:videoDeviceInput];
	[_captureSession addOutput:videoDataOutput];
	// obtain the preset and validate the preset
	/*
	 Preset                          4 back      4 front

	 AVCaptureSessionPresetHigh     1280x720    640x480
	 AVCaptureSessionPresetMedium   480x360     480x360
	 AVCaptureSessionPresetLow     192x144     192x144
	 AVCaptureSessionPreset640x480   640x480     640x480
	 AVCaptureSessionPreset1280x720  1280x720    NA
	 AVCaptureSessionPresetPhoto     NA          NA
	 */

	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		if ([[A3UIDevice platform] isEqualToString:@"iPhone 4"] ||
				[[A3UIDevice platform] isEqualToString:@"iPhone 4s"]) {
			if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetMedium]) {
				[_captureSession setSessionPreset:AVCaptureSessionPresetMedium];
			} else {
				[_captureSession setSessionPreset:AVCaptureSessionPresetLow];
			}
		} else {
			if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetHigh]) {
				[_captureSession setSessionPreset:AVCaptureSessionPresetHigh];
			} else {
				[_captureSession setSessionPreset:AVCaptureSessionPresetMedium];
			}
		}
	} else {
		[_captureSession setSessionPreset:AVCaptureSessionPresetPhoto];
	}

	[_captureSession commitConfiguration];

	[_videoDevice lockForConfiguration:nil];

	[self searchSlowCameraFrameRate];

	/*
	 if (_videoDevice.isAdjustingFocus == YES) {
	 _videoDevice.focusMode = AVCaptureFocusModeAutoFocus;
	 }

	 if (_videoDevice.isAdjustingExposure == YES) {
	 _videoDevice.exposureMode = AVCaptureExposureModeAutoExpose;
	 }

	 if (_videoDevice.isAutoFocusRangeRestrictionSupported == YES) {
	 _videoDevice.autoFocusRangeRestriction = AVCaptureAutoFocusRangeRestrictionNear;
	 }

	 if (_videoDevice.smoothAutoFocusSupported == YES) {
	 _videoDevice.smoothAutoFocusEnabled = NO;
	 }
	 */
	FNLOG(@"FocusMode = %d, ExposureMode = %d, AVCaptureAutoFocusRangeRestriction = %d, smoothfocus = %d", (int)_videoDevice.focusMode, (int)_videoDevice.exposureMode, (int)_videoDevice.autoFocusRangeRestriction, _videoDevice.smoothAutoFocusEnabled);
	[_videoDevice unlockForConfiguration];

	FNLOG(@"_videoDevice.activeFormat.videoMaxZoomFactor = %f", _videoDevice.activeFormat.videoMaxZoomFactor);
	_isLosslessZoom = _videoDevice.activeFormat.videoMaxZoomFactor > 1;
	_effectiveScale = 1.0;

	// then start everything
	[_frameCalculator reset];

	double delayInSeconds = 0.1;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
		[_captureSession startRunning];
	});
}

- (void)searchSlowCameraFrameRate {
	_currentMaxDuration = _videoDevice.activeVideoMaxFrameDuration;
	_currentMinDuration = _videoDevice.activeVideoMinFrameDuration;
	_slowFrameRateRange = nil;

	for (AVFrameRateRange *range in _videoDevice.activeFormat.videoSupportedFrameRateRanges) {
		FNLOG(@"%f", range.maxFrameRate);
		if (_slowFrameRateRange == nil ) {
			_slowFrameRateRange = range;
		}
		if(range.maxFrameRate < _slowFrameRateRange.maxFrameRate) {
			_slowFrameRateRange = range;
		}
	}
}

-(void)restoreOriginalFrameRate {
	if ([_videoDevice lockForConfiguration:nil]) {
		_videoDevice.activeVideoMinFrameDuration = _currentMaxDuration;
		_videoDevice.activeVideoMaxFrameDuration = _currentMinDuration;
		[_videoDevice unlockForConfiguration];
	}
}

-(void)setSlowFrameRate {
	if ([_videoDevice lockForConfiguration:nil]) {
		_videoDevice.activeVideoMinFrameDuration = _slowFrameRateRange.minFrameDuration;
		_videoDevice.activeVideoMaxFrameDuration = _slowFrameRateRange.maxFrameDuration;
		[_videoDevice unlockForConfiguration];
	}
}

- (void)_stop
{
	if (!_captureSession || !_captureSession.running)
		return;

	[_captureSession stopRunning];

	dispatch_sync(_captureSessionQueue, ^{
		FNLOG(@"waiting for capture session to end");
	});

	[_videoDevice unlockForConfiguration];

	for(AVCaptureInput *input in _captureSession.inputs) {
		[_captureSession removeInput:input];
	}

	for(AVCaptureOutput *output in _captureSession.outputs) {
		[_captureSession removeOutput:output];
	}

	_captureSession = nil;
	_videoDevice = nil;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
	CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	_ciImage = [CIImage imageWithCVPixelBuffer:(CVPixelBufferRef)imageBuffer options:nil];

	CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
	[_frameCalculator calculateFramerateAtTimestamp:timestamp];

	if(_eaglContext != [EAGLContext currentContext]) {
		[EAGLContext setCurrentContext:_eaglContext];
	}

	if(_isMultipleView == NO) {
		GLKView *currentFilter = [self currentFilterView];
		[currentFilter bindDrawable];
		[currentFilter display];
	} else {
		[_videoPreviewViewMonoFilter bindDrawable];
		[_videoPreviewViewMonoFilter display];

		[_videoPreviewViewTonalFilter bindDrawable];
		[_videoPreviewViewTonalFilter display];
		[_videoPreviewViewNoirFilter bindDrawable];
		[_videoPreviewViewNoirFilter display];
		[_videoPreviewViewFadeFilter bindDrawable];
		[_videoPreviewViewFadeFilter display];

		[_videoPreviewViewNoFilter bindDrawable];
		[_videoPreviewViewNoFilter display];
		[_videoPreviewViewChromeFilter bindDrawable];
		[_videoPreviewViewChromeFilter display];
		[_videoPreviewViewProcessFilter bindDrawable];
		[_videoPreviewViewProcessFilter display];
		[_videoPreviewViewTransferFilter bindDrawable];
		[_videoPreviewViewTransferFilter display];

		[_videoPreviewViewInstantFilter bindDrawable];
		[_videoPreviewViewInstantFilter display];
	}
}

- (void)setupZoomSlider {
	self.zoomToolBar.hidden = NO;
	self.zoomSlider.minimumValue = 1.0;
	self.zoomSlider.value = 1;
	self.zoomSlider.continuous = YES;

	if (_isLosslessZoom) {
		self.zoomSlider.maximumValue = [self getMaxZoom];
	} else {
		CGFloat deviceMax = [[_stillImageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
		if (deviceMax == 1) {
			self.zoomSlider.maximumValue = MAX_ZOOM_FACTOR;
		} else {
			self.zoomSlider.maximumValue = MIN(MAX_ZOOM_FACTOR, deviceMax);
		}
	}
	FNLOG(@"minum = %f maximum = %f current = %f", self.zoomSlider.minimumValue, self.zoomSlider.maximumValue, self.zoomSlider.value);
}

#pragma mark Instruction Related

static NSString *const A3V3InstructionDidShowForMirror = @"A3V3InstructionDidShowForMirror";

- (void)setupInstructionView
{
    if (![[A3UserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForMirror]) {
        [self showInstructionView:nil];
    }
}

- (IBAction)showInstructionView:(id)sender
{
	[[A3UserDefaults standardUserDefaults] setBool:YES forKey:A3V3InstructionDidShowForMirror];
	[[A3UserDefaults standardUserDefaults] synchronize];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setToolBarsHidden:NO];
    });
    
    UIStoryboard *instructionStoryBoard = [UIStoryboard storyboardWithName:IS_IPHONE ? A3StoryboardInstruction_iPhone : A3StoryboardInstruction_iPad bundle:nil];
    _instructionViewController = [instructionStoryBoard instantiateViewControllerWithIdentifier:@"Mirror"];
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

#pragma GLKViewDelegate

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

	CIImage *filteredImage = nil;

	if (_isFiltersEnabled == YES) {
		if ([view isEqual:_videoPreviewViewMonoFilter]) {
			filteredImage = [CIFilter filterWithName:@"CIPhotoEffectMono" keysAndValues:kCIInputImageKey, _ciImage, nil].outputImage;
		} else if ([view isEqual:_videoPreviewViewTonalFilter]) {
			filteredImage = [CIFilter filterWithName:@"CIPhotoEffectTonal" keysAndValues:kCIInputImageKey, _ciImage, nil].outputImage;

		} else if ([view isEqual:_videoPreviewViewNoirFilter]) {
			filteredImage = [CIFilter filterWithName:@"CIPhotoEffectNoir" keysAndValues:kCIInputImageKey, _ciImage, nil].outputImage;

		} else if ([view isEqual:_videoPreviewViewFadeFilter]) {
			filteredImage = [CIFilter filterWithName:@"CIPhotoEffectFade" keysAndValues:kCIInputImageKey, _ciImage, nil].outputImage;

		} else if ([view isEqual:_videoPreviewViewChromeFilter]) {
			filteredImage = [CIFilter filterWithName:@"CIPhotoEffectChrome" keysAndValues:kCIInputImageKey, _ciImage, nil].outputImage;

		} else if ([view isEqual:_videoPreviewViewProcessFilter]) {
			filteredImage = [CIFilter filterWithName:@"CIPhotoEffectProcess" keysAndValues:kCIInputImageKey, _ciImage, nil].outputImage;

		} else if ([view isEqual:_videoPreviewViewTransferFilter]) {
			filteredImage = [CIFilter filterWithName:@"CIPhotoEffectTransfer" keysAndValues:kCIInputImageKey, _ciImage, nil].outputImage;

		} else if([view isEqual:_videoPreviewViewInstantFilter]) {
			filteredImage = [CIFilter filterWithName:@"CIPhotoEffectInstant" keysAndValues:kCIInputImageKey, _ciImage, nil].outputImage;

		}
	}
	//glClearColor(0.0f, 0.0f, 0.1f,0.1f);
	//glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	//glFlush();

	// dispatch_async(dispatch_get_main_queue(), ^(void) {
	if (filteredImage != nil) {
		[_ciContext drawImage:filteredImage inRect:_videoPreviewViewBounds fromRect:drawRect];
	} else {
		[_ciContext drawImage:_ciImage inRect:_videoPreviewViewBounds fromRect:drawRect];
	}
	// });

	//  glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
	//[_eaglContext presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark - TapGesture setup

- (void)setupGestureRecognizer {
	if (_isFiltersEnabled) {
		for (GLKView *filterView in _filterViews) {
			if (![[filterView gestureRecognizers] count]) {
				UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnPreviewView:)];
				UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFrom:)];
				pinchGestureRecognizer.delegate = self;
				[filterView addGestureRecognizer:tapGestureRecognizer];
				[filterView addGestureRecognizer:pinchGestureRecognizer];
			}
		}
	} else {
		if (![[_videoPreviewViewNoFilter gestureRecognizers] count]) {
			UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnPreviewView:)];
			UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFrom:)];
			pinchGestureRecognizer.delegate = self;
			[_videoPreviewViewNoFilter addGestureRecognizer:tapGestureRecognizer];
			[_videoPreviewViewNoFilter addGestureRecognizer:pinchGestureRecognizer];
		}
	}
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
	//FNLOG(@"effectiveScale = %f, beginGeustureScale = %f, recognizer.scale = %f", effectiveScale, beginGestureScale, recognizer.scale);

	if (_effectiveScale < self.zoomSlider.minimumValue ) {
		_effectiveScale = self.zoomSlider.minimumValue;
	}
	if(_effectiveScale > self.zoomSlider.maximumValue) {
		_effectiveScale = self.zoomSlider.maximumValue;
	}
	if(_effectiveScale == self.zoomSlider.value) {
		return;
	}

	[self applyZoomFactor];
}

- (void)tapOnPreviewView:(UITapGestureRecognizer *) tap {
	FNLOG();
	if (_isMultipleView) {
		[self restoreOriginalFrameRate];

		_filterIndex = [_filterViews indexOfObject:tap.view];
		if (_filterIndex != NSNotFound) {
			[self showOneFilterView:_filterIndex];
		}

		[self.filterButton setBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
		if (_filterIndex == A3MirrorNoFilter) {
			[self.filterButton setImage:[[UIImage imageNamed:@"m_color"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
		} else {
			[self.filterButton setImage:[[UIImage imageNamed:@"m_color_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
		}
		self.bottomBar.hidden = NO;
		_isMultipleView = NO;
		[self setToolBarsHidden:NO];
	}
	else
	{
		if (IS_IPHONE && IS_LANDSCAPE) return;

		BOOL toolBarHidden = self.topBar.hidden;
		[self setToolBarsHidden:!toolBarHidden];
	}
}

- (void)setToolBarsHidden:(BOOL)hidden {
	self.topBar.hidden = hidden;
	self.bottomBar.hidden = hidden;
	self.statusBarBackground.hidden = hidden;
	[[UIApplication sharedApplication] setStatusBarHidden:hidden];

	[self.bottomBar setFrame:CGRectMake(self.bottomBar.bounds.origin.x, self.view.frame.size.height - 74 , self.view.frame.size.width, 74)];
	if(hidden == YES) {
		[self.zoomToolBar setFrame:CGRectMake(self.zoomToolBar.frame.origin.x,
				self.view.frame.size.height - self.zoomToolBar.frame.size.height,
				self.zoomToolBar.frame.size.width,
				self.zoomToolBar.frame.size.height)];
	} else {
		[self.zoomToolBar setFrame:CGRectMake(self.zoomToolBar.frame.origin.x,
				self.view.frame.size.height - self.zoomToolBar.frame.size.height - self.bottomBar.frame.size.height,
				self.zoomToolBar.frame.size.width,
				self.zoomToolBar.frame.size.height)];
	}
}

- (void)setNavigationBarHidden:(BOOL)hidden {
	[self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
	[self.navigationController.navigationBar setShadowImage:nil];

	[self.navigationController setNavigationBarHidden:hidden];
}

#pragma mark - Filter Setting

- (void)addAllFilterViews {
	for (GLKView *filterView in _filterViews) {
		[self.view addSubview:filterView];
		[self.view sendSubviewToBack:filterView];
		[self setFilterViewRotation:filterView withScreenBounds:filterView.frame];
	}
}

- (void)createFilterViews {
	if ([_filterViews count]) return;

	_filterViews = [NSMutableArray new];

	_videoPreviewViewMonoFilter = [self filterView];
	_videoPreviewViewTonalFilter = [self filterView];
	_videoPreviewViewNoirFilter = [self filterView];
	_videoPreviewViewFadeFilter = [self filterView];
	_videoPreviewViewChromeFilter = [self filterView];
	_videoPreviewViewProcessFilter = [self filterView];
	_videoPreviewViewTransferFilter = [self filterView];
	_videoPreviewViewInstantFilter = [self filterView];

	[_filterViews addObject:_videoPreviewViewMonoFilter];
	[_filterViews addObject:_videoPreviewViewTonalFilter];
	[_filterViews addObject:_videoPreviewViewNoirFilter];
	[_filterViews addObject:_videoPreviewViewFadeFilter];
	[_filterViews addObject:_videoPreviewViewNoFilter];
	[_filterViews addObject:_videoPreviewViewChromeFilter];
	[_filterViews addObject:_videoPreviewViewProcessFilter];
	[_filterViews addObject:_videoPreviewViewTransferFilter];
	[_filterViews addObject:_videoPreviewViewInstantFilter];

	[self addAllFilterViews];

	_monoLabel = [self filterLabelWithText:NSLocalizedString(@"Mono", @"Mono")];
	_tonalLabel = [self filterLabelWithText:NSLocalizedString(@"Tonal", @"Tonal")];
	_noirLabel = [self filterLabelWithText:NSLocalizedString(@"Noir", @"Noir")];
	_fadeLabel = [self filterLabelWithText:NSLocalizedString(@"Fade", @"Fade")];
	_noneLabel = [self filterLabelWithText:NSLocalizedString(@"None_Mirror", nil)];
	_chromeLabel = [self filterLabelWithText:NSLocalizedString(@"Chrome", @"Chrome")];
	_processLabel = [self filterLabelWithText:NSLocalizedString(@"Process", @"Process")];
	_transferLabel = [self filterLabelWithText:NSLocalizedString(@"Transfer", @"Transfer")];
	_instantLabel = [self filterLabelWithText:NSLocalizedString(@"Instant", @"Instant")];

	_filterLabels = [NSMutableArray new];
	[_filterLabels addObjectsFromArray:@[_monoLabel, _tonalLabel, _noirLabel, _fadeLabel, _noneLabel, _chromeLabel, _processLabel, _transferLabel, _instantLabel]];
}

- (GLKView *)filterView {
	GLKView *filterView = [[GLKView alloc] initWithFrame:self.view.bounds context:_eaglContext];
	filterView.drawableDepthFormat = GLKViewDrawableDepthFormat24;;
	filterView.delegate = self;
	filterView.userInteractionEnabled = YES;

	return filterView;
}

- (UILabel *)filterLabelWithText:(NSString *)text {
	UILabel *label = [UILabel new];
	label.textColor = [UIColor whiteColor];
	label.font = [UIFont fontWithName:@"Trebuchet MS" size: 12.0];
	label.shadowColor = [UIColor blackColor];
	label.text = text;
	return label;
}

- (GLKView *)currentFilterView {
	switch (_filterIndex) {
		case A3MirrorMonoFilter: return _videoPreviewViewMonoFilter;
		case A3MirrorTonalFilter: return _videoPreviewViewTonalFilter;
		case A3MirrorNoirFilter: return  _videoPreviewViewNoirFilter;
		case A3MirrorFadeFilter: return _videoPreviewViewFadeFilter;
		case A3MirrorNoFilter:return _videoPreviewViewNoFilter;
		case A3MirrorChromeFilter: return _videoPreviewViewChromeFilter;
		case A3MirrorProcessFilter:return _videoPreviewViewProcessFilter;
		case A3MirrorTransferFilter:return _videoPreviewViewTransferFilter;
		case A3MirrorInstantFilter:return _videoPreviewViewInstantFilter;
	}

	FNLOG("nFilterIndex is invalide %ld", (unsigned long) _filterIndex);
	return _videoPreviewViewNoFilter;
}

-(void)removeAllFilterViews {
	[_videoPreviewViewNoFilter removeFromSuperview];
	if (_isFiltersEnabled == YES){
		[_videoPreviewViewMonoFilter removeFromSuperview];
		[_videoPreviewViewTonalFilter removeFromSuperview];
		[_videoPreviewViewNoirFilter removeFromSuperview];
		[_videoPreviewViewFadeFilter removeFromSuperview];
		[_videoPreviewViewChromeFilter removeFromSuperview];
		[_videoPreviewViewProcessFilter removeFromSuperview];
		[_videoPreviewViewTransferFilter removeFromSuperview];
		[_videoPreviewViewInstantFilter removeFromSuperview];
	}
}

- (void)cleanUp {
	[self dismissInstructionViewController:nil];

	// remove the _videoPreviewNoFilter
	[self removeAllFilterViews];

	_videoPreviewViewNoFilter = nil;
	if (_isFiltersEnabled) {
		_videoPreviewViewMonoFilter = nil;
		_videoPreviewViewTonalFilter = nil;
		_videoPreviewViewNoirFilter = nil;
		_videoPreviewViewFadeFilter = nil;
		_videoPreviewViewChromeFilter = nil;
		_videoPreviewViewProcessFilter = nil;
		_videoPreviewViewTransferFilter = nil;
		_videoPreviewViewInstantFilter = nil;
	}

	[self _stop];

	if (_isFiltersEnabled) {
		_filterViews = nil;
		_monoLabel = nil;
		_tonalLabel = nil;
		_noirLabel = nil;
		_fadeLabel = nil;
		_noneLabel = nil;
		_chromeLabel = nil;
		_processLabel = nil;
		_transferLabel = nil;
		_instantLabel = nil;
	}
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

	// makes the UI more Camera.app like
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
	{
		[UIView setAnimationsEnabled:NO];
	}
    else {
		if (_isLosslessZoom == YES) {
			_center.x = [self currentFilterView].center.y;
			_center.y = [self currentFilterView].center.x;
		}
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

	[self.navigationController.toolbar setHidden:YES];
	if (_isMultipleView) {
		for (GLKView *filterView in _filterViews) {
			[self setFilterViewRotation:filterView withScreenBounds:filterView.frame];
		}
		[self setupFilterViewFrameWithOption:NO];
		[self removeFilterLabelsFromSuperview];
		[self addFilterLabels];
	} else {
		CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
		[self setFilterViewRotation:self.currentFilterView withScreenBounds:screenBounds];
	}

	[self configureLayout];
	[self setToolBarsHidden:_topBar.hidden || _isMultipleView];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
		[UIView setAnimationsEnabled:YES];
		[UIView beginAnimations:@"reappear" context:NULL];
		[UIView setAnimationDuration:0.75];
		[UIView commitAnimations];
	}
	else {
	}
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - IB Action Buttons

- (IBAction)zoomSliderDidValueChange:(UISlider *)sliderControl {
	_effectiveScale = sliderControl.value;
	[self applyZoomFactor];
}

- (IBAction)appsButton:(id)sender {
	if (IS_IPHONE) {
		[[self mm_drawerController] toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
	} else {
		[[[A3AppDelegate instance] rootViewController] toggleLeftMenuViewOnOff];
	}
}

- (IBAction)flipButton:(id)sender {
	UIViewAnimationOptions option = UIViewAnimationOptionTransitionFlipFromLeft;
	[UIView transitionWithView:self.currentFilterView duration:0.7 options:option
					animations:^{
						_isFlip = !_isFlip;
						[self setViewRotation:[self currentFilterView]];
					}completion:^(BOOL finished) {
			}];
}

- (void)snapAnimation
{
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
    
    [self snapAnimation];
    
	dispatch_async(_captureSessionQueue, ^{
		// Flash set to Auto for Still Capture
		// [self setFlashMode:AVCaptureFlashModeAuto forDevice:_videoDevice];

		if (!_isLosslessZoom) {
			AVCaptureConnection *stillImageConnection = [_stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
			CGFloat scale = MIN(_effectiveScale, stillImageConnection.videoMaxScaleAndCropFactor);
			[stillImageConnection setVideoScaleAndCropFactor:scale];
		}
        
		[_stillImageOutput captureStillImageAsynchronouslyFromConnection:[_stillImageOutput connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
			if (imageDataSampleBuffer) {
				NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
				CIImage *ciSaveImg = [[CIImage alloc] initWithData:imageData];
				UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
				if (IS_IPHONE) {
					orientation = (UIInterfaceOrientation) [[UIDevice currentDevice] orientation];
				}

				if (_isFlip == YES) {
					if (IS_LANDSCAPE ||
							orientation == UIDeviceOrientationLandscapeRight ||
							orientation == UIDeviceOrientationLandscapeLeft) {
						CGAffineTransform f = CGAffineTransformMake(-1, 0, 0, 1, ciSaveImg.extent.size.width, 0);
						ciSaveImg = [ciSaveImg imageByApplyingTransform:f];
					} else {
						CGAffineTransform f = CGAffineTransformMake(1, 0, 0, -1, 0, ciSaveImg.extent.size.height);
						ciSaveImg = [ciSaveImg imageByApplyingTransform:f];
					}
				}

				CGAffineTransform t = [self getRotationTransformWithOption:NO];

				if (_filterIndex == A3MirrorMonoFilter) {
					ciSaveImg = [CIFilter filterWithName:@"CIPhotoEffectMono" keysAndValues:kCIInputImageKey, ciSaveImg, nil].outputImage;
				} else if (_filterIndex == A3MirrorTonalFilter) {
					ciSaveImg = [CIFilter filterWithName:@"CIPhotoEffectTonal" keysAndValues:kCIInputImageKey, ciSaveImg, nil].outputImage;
				} else if (_filterIndex == A3MirrorNoirFilter) {
					ciSaveImg = [CIFilter filterWithName:@"CIPhotoEffectNoir" keysAndValues:kCIInputImageKey, ciSaveImg, nil].outputImage;
				} else if (_filterIndex == A3MirrorFadeFilter) {
					ciSaveImg = [CIFilter filterWithName:@"CIPhotoEffectFade" keysAndValues:kCIInputImageKey, ciSaveImg, nil].outputImage;
				} else if (_filterIndex == A3MirrorChromeFilter) {
					ciSaveImg = [CIFilter filterWithName:@"CIPhotoEffectChrome" keysAndValues:kCIInputImageKey, ciSaveImg, nil].outputImage;
				} else if (_filterIndex == A3MirrorProcessFilter) {
					ciSaveImg = [CIFilter filterWithName:@"CIPhotoEffectProcess" keysAndValues:kCIInputImageKey, ciSaveImg, nil].outputImage;
				} else if (_filterIndex == A3MirrorTransferFilter) {
					ciSaveImg = [CIFilter filterWithName:@"CIPhotoEffectTransfer" keysAndValues:kCIInputImageKey, ciSaveImg, nil].outputImage;
				} else if (_filterIndex == A3MirrorInstantFilter) {
					ciSaveImg = [CIFilter filterWithName:@"CIPhotoEffectInstant" keysAndValues:kCIInputImageKey, ciSaveImg, nil].outputImage;
				}

				ciSaveImg = [ciSaveImg imageByApplyingTransform:t];
				CGImageRef cgimg = [_ciContext createCGImage:ciSaveImg fromRect:[ciSaveImg extent]];
				[self.assetLibrary writeImageToSavedPhotosAlbum:cgimg metadata:[_ciImage properties] completionBlock:^(NSURL *assetURL, NSError *error) {
					self.capturedPhotoURL = assetURL;
					[self setImageOnCameraRollButton:[UIImage imageWithCGImage:cgimg]];
					[_captureSession startRunning];
				}];
			}
		}];
	});
}

#pragma mark - Filter Control

- (IBAction)colorButton:(id)sender {
	_isMultipleView = !_isMultipleView;

	if (_isMultipleView) {
		[self setSlowFrameRate];
		self.bottomBar.hidden = YES;
		self.zoomToolBar.hidden =  YES;
		[self showMultipleViews:YES];
	}
}

- (void)showOneFilterView:(NSUInteger) nViewIndex {
	CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
	CGFloat width = screenBounds.size.width;
	CGFloat height = screenBounds.size.height;
	CGFloat x = width;
	CGFloat y = height;

	NSArray *coordinate = filterViewCoordinate[nViewIndex];

	[self removeFilterLabelsFromSuperview];

	[UIView animateWithDuration:0.3
						  delay:0
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 [_videoPreviewViewMonoFilter setFrame:CGRectMake(x*((NSNumber*)coordinate[A3MirrorMonoFilter][0]).intValue, y*((NSNumber*)coordinate[A3MirrorMonoFilter][1]).intValue, width, height)];
						 //FNLOG("Mono = %f, %f",_videoPreviewViewMonoFilter.frame.origin.x, _videoPreviewViewMonoFilter.frame.origin.y);
						 [_videoPreviewViewTonalFilter setFrame:CGRectMake(x*((NSNumber*)coordinate[A3MirrorTonalFilter][0]).intValue, y*((NSNumber*)coordinate[A3MirrorTonalFilter][1]).intValue, width, height)];
						 //FNLOG("Tonal = %f, %f",_videoPreviewViewTonalFilter.frame.origin.x, _videoPreviewViewTonalFilter.frame.origin.y);
						 [_videoPreviewViewNoirFilter setFrame:CGRectMake(x*((NSNumber*)coordinate[A3MirrorNoirFilter][0]).intValue, y*((NSNumber*)coordinate[A3MirrorNoirFilter][1]).intValue, width, height)];
						 //FNLOG("Noir = %f, %f",_videoPreviewViewNoirFilter.bounds.origin.x, _videoPreviewViewNoirFilter.bounds.origin.y);
						 [_videoPreviewViewFadeFilter setFrame:CGRectMake(x*((NSNumber*)coordinate[A3MirrorFadeFilter][0]).intValue, y*((NSNumber*)coordinate[A3MirrorFadeFilter][1]).intValue, width, height)];
						 //FNLOG("Fade = %f, %f",_videoPreviewViewFadeFilter.bounds.origin.x, _videoPreviewViewFadeFilter.bounds.origin.y);
						 [_videoPreviewViewNoFilter setFrame:CGRectMake(x*((NSNumber*)coordinate[A3MirrorNoFilter][0]).intValue, y*((NSNumber*)coordinate[A3MirrorNoFilter][1]).intValue, width, height)];
						 //FNLOG("No = %f, %f",_videoPreviewViewNoFilter.bounds.origin.x, _videoPreviewViewNoFilter.bounds.origin.y);
						 [_videoPreviewViewChromeFilter setFrame:CGRectMake(x*((NSNumber*)coordinate[A3MirrorChromeFilter][0]).intValue, y*((NSNumber*)coordinate[A3MirrorChromeFilter][1]).intValue, width, height)];
						 //FNLOG("Chrome = %f, %f",_videoPreviewViewChromeFilter.bounds.origin.x, _videoPreviewViewChromeFilter.bounds.origin.y);
						 [_videoPreviewViewProcessFilter setFrame:CGRectMake(x*((NSNumber*)coordinate[A3MirrorProcessFilter][0]).intValue, y*((NSNumber*)coordinate[A3MirrorProcessFilter][1]).intValue, width, height)];
						 //FNLOG("Process = %f, %f",_videoPreviewViewProcessFilter.bounds.origin.x, _videoPreviewViewProcessFilter.bounds.origin.y);
						 [_videoPreviewViewTransferFilter setFrame:CGRectMake(x*((NSNumber*)coordinate[A3MirrorTransferFilter][0]).intValue, y*((NSNumber*)coordinate[A3MirrorTransferFilter][1]).intValue, width, height)];
						 //FNLOG("Transfer = %f, %f",_videoPreviewViewTransferFilter.bounds.origin.x, _videoPreviewViewTransferFilter.bounds.origin.y);
						 [_videoPreviewViewInstantFilter setFrame:CGRectMake(x*((NSNumber*)coordinate[A3MirrorInstantFilter][0]).intValue, y*((NSNumber*)coordinate[A3MirrorInstantFilter][1]).intValue , width, height)];
						 //FNLOG("Instant = %f, %f",_videoPreviewViewInstantFilter.bounds.origin.x, _videoPreviewViewInstantFilter.bounds.origin.y);
					 }
					 completion:^(BOOL finished) {
						 [_filterViews enumerateObjectsUsingBlock:^(GLKView *view, NSUInteger idx, BOOL *stop) {
							 if (idx == nViewIndex) return;
							 [view setHidden:YES];
						 }];
					 }];

	_videoPreviewViewBounds.size = _originalsize;
	self.zoomToolBar.hidden = NO;
}

- (void)removeFilterLabelsFromSuperview {
	for (UILabel *label in _filterLabels) {
		[label removeFromSuperview];
	}
}

- (void)setupFilterView:(GLKView *)filterView frame:(CGRect)frame {
	[filterView setFrame:frame];
	FNLOGRECT(frame);
}

- (void)setupFilterViewFrameWithOption:(BOOL)smallOption {
	CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
	CGFloat height = (screenBounds.size.height-84)/3;
	CGFloat width  = (screenBounds.size.width*height)/screenBounds.size.height;
	CGFloat orignialHeight =_videoPreviewViewBounds.size.height;
	if (smallOption == YES) {
		_videoPreviewViewBounds.size.height = (_videoPreviewViewBounds.size.height)*(height/screenBounds.size.height);
		_videoPreviewViewBounds.size.width = (_videoPreviewViewBounds.size.height * _videoPreviewViewBounds.size.width)/orignialHeight;
	}

	CGFloat x,y;
	CGFloat widthOffset = (self.view.bounds.size.width - (width*3 + 10))/2;
	x = widthOffset, y = 20+44;
	[self setupFilterView:_videoPreviewViewMonoFilter frame:CGRectMake(x, y, width, height)];

	x = x+ width + 5;
	[self setupFilterView:_videoPreviewViewTonalFilter frame:CGRectMake(x, y, width, height)];

	x = x+width + 5;
	[self setupFilterView:_videoPreviewViewNoirFilter frame:CGRectMake(x, y, width, height)];

	x = widthOffset, y = y + height + 5;
	[self setupFilterView:_videoPreviewViewFadeFilter frame:CGRectMake(x, y, width, height)];

	x = x + width + 5;
	[self setupFilterView:_videoPreviewViewNoFilter frame:CGRectMake(x, y, width, height)];

	x = x + width + 5;
	[self setupFilterView:_videoPreviewViewChromeFilter frame:CGRectMake(x, y, width, height)];

	x = widthOffset, y = y + height +5;
	[self setupFilterView:_videoPreviewViewProcessFilter frame:CGRectMake(x, y, width, height)];

	x = x + width + 5;
	[self setupFilterView:_videoPreviewViewTransferFilter frame:CGRectMake(x, y, width, height)];

	x = x + width + 5;
	[self setupFilterView:_videoPreviewViewInstantFilter frame:CGRectMake(x, y, width, height)];
}

- (void)addFilterLabels {
	[self.view addSubview:_monoLabel];
	[_monoLabel makeConstraints:^(MASConstraintMaker *make) {
		make.bottom.equalTo(_videoPreviewViewMonoFilter.bottom);
		make.left.equalTo(_videoPreviewViewMonoFilter.left);
	}];
	[self.view addSubview:_tonalLabel];
	[_tonalLabel makeConstraints:^(MASConstraintMaker *make) {
		make.bottom.equalTo(_videoPreviewViewTonalFilter.bottom);
		make.left.equalTo(_videoPreviewViewTonalFilter.left);
	}];
	[self.view addSubview:_noirLabel];
	[_noirLabel makeConstraints:^(MASConstraintMaker *make) {
		make.bottom.equalTo(_videoPreviewViewNoirFilter.bottom);
		make.left.equalTo(_videoPreviewViewNoirFilter.left);
	}];
	[self.view addSubview:_fadeLabel];
	[_fadeLabel makeConstraints:^(MASConstraintMaker *make) {
		make.bottom.equalTo(_videoPreviewViewFadeFilter.bottom);
		make.left.equalTo(_videoPreviewViewFadeFilter.left);
	}];
	[self.view addSubview:_noneLabel];
	[_noneLabel makeConstraints:^(MASConstraintMaker *make) {
		make.bottom.equalTo(_videoPreviewViewNoFilter.bottom);
		make.left.equalTo(_videoPreviewViewNoFilter.left);
	}];
	[self.view addSubview:_chromeLabel];
	[_chromeLabel makeConstraints:^(MASConstraintMaker *make) {
		make.bottom.equalTo(_videoPreviewViewChromeFilter.bottom);
		make.left.equalTo(_videoPreviewViewChromeFilter.left);
	}];
	[self.view addSubview:_processLabel];
	[_processLabel makeConstraints:^(MASConstraintMaker *make) {
		make.bottom.equalTo(_videoPreviewViewProcessFilter.bottom);
		make.left.equalTo(_videoPreviewViewProcessFilter.left);
	}];
	[self.view addSubview:_transferLabel];
	[_transferLabel makeConstraints:^(MASConstraintMaker *make) {
		make.bottom.equalTo(_videoPreviewViewTransferFilter.bottom);
		make.left.equalTo(_videoPreviewViewTransferFilter.left);
	}];
	[self.view addSubview:_instantLabel];
	[_instantLabel makeConstraints:^(MASConstraintMaker *make) {
		make.bottom.equalTo(_videoPreviewViewInstantFilter.bottom);
		make.left.equalTo(_videoPreviewViewInstantFilter.left);
	}];

	[self.view layoutIfNeeded];
}

- (void)showMultipleViews:(BOOL)bSizeChange {

	[self setToolBarsHidden:YES];

	for (GLKView *filterView in _filterViews) {
		[filterView setHidden:NO];
		[self setFilterViewRotation:filterView withScreenBounds:filterView.frame];
	}

	[UIView animateWithDuration:0.3
						  delay:0
						options:UIViewAnimationOptionCurveEaseIn
					 animations:^{
						 [self setupFilterViewFrameWithOption:bSizeChange];
					 }
					 completion:^(BOOL finished) {
						 [self addFilterLabels];
					 }];
}

@end
