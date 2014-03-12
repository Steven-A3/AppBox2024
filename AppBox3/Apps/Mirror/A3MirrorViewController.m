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
#import "A3AppDelegate.h"
#import "common.h"
static const int MAX_ZOOM_FACTOR = 6;

@interface A3MirrorViewController() {
    GLKView *_videoPreviewViewNoFilter;     // OPEN GL ES Aware-View
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
	AVCaptureStillImageOutput *stillImageOutput;
    
    UITapGestureRecognizer *previewNoFilterGestureRecognizer;
    UITapGestureRecognizer *previewMonoFilterGestureRecognizer;
    UITapGestureRecognizer *previewTonalFilterGestureRecognizer;
    UITapGestureRecognizer *previewNoirFilterGestureRecognizer;
    UITapGestureRecognizer *previewFadeFilterGestureRecognizer;
    UITapGestureRecognizer *previewChromeFilterGestureRecognizer;
    UITapGestureRecognizer *previewProcessFilterGestureRecognizer;
    UITapGestureRecognizer *previewTransferFilterGestureRecognizer;
    UITapGestureRecognizer *previewInstantFilterGestureRecognizer;
    
    UILabel *monoLabel;
    UILabel *tonalLabel;
    UILabel *noirLabel;
    UILabel *fadeLabel;
    UILabel *noneLabel;
    UILabel *chromeLabel;
    UILabel *processLabel;
    UILabel *transferLabel;
    UILabel *instantLabel;
    
    UIButton *lastimageButton;
    dispatch_queue_t _captureSessionQueue;
    UIBackgroundTaskIdentifier _backgroundRecordingID;
    CIImage *ciimg;
    GLuint _renderBuffer;
    BOOL    bFlip;
    BOOL    bMultipleView;
    CGSize  originalsize;
    NSUInteger  nFilterIndex;
    CGFloat     effectiveScale;
    CGFloat     beginGestureScale;
    CMTime      currentMaxDuration;
    CMTime      currentMinDuration;
    AVFrameRateRange *slowFrameRateRange;

}

@property (nonatomic, strong) ALAssetsLibrary *assetLibrary;
@property (nonatomic, strong) ALAssetsGroup *assetrollGroup;
@property (nonatomic, strong) UIView *statusBarBackground;

@end


static CGColorSpaceRef sDeviceRgbColorSpace = NULL;

@implementation A3MirrorViewController {
    NSArray *filterViewCoordinate;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        // create the shared color space object once
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sDeviceRgbColorSpace = CGColorSpaceCreateDeviceRGB();
        });
        
        // create the dispatch queue for handling capture session delegate method calls
        _captureSessionQueue = dispatch_queue_create("capture_session_queue", DISPATCH_QUEUE_SERIAL);
        
        // create the coordiate for filter views
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
    }
    return self;
}

#pragma mark - video setup
- (void)viewDidLoad
{
    [super viewDidLoad];
	CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
    [self setNavigationBarHidden:YES];
    [self setToolBarsHidden:YES];
    [self.zoomToolBar setHidden:YES];   // it will show after _videoDevice Setup finish

    self.view.bounds = [[UIScreen mainScreen] bounds];
    [self.view setBackgroundColor:[UIColor blackColor]];

    
    self.statusBarBackground = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, screenBounds.size.width, 20)];
    [self.statusBarBackground setBackgroundColor:[UIColor blackColor]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.view addSubview:self.statusBarBackground];
    [self.statusBarBackground setHidden:YES];
    [self.filterButton setImage:[[UIImage imageNamed:@"m_color"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    // create the CIContext instance, note that this must be done after _videoPreviewView is properly set up
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    _ciContext = [CIContext contextWithEAGLContext:_eaglContext options:@{kCIContextWorkingColorSpace : [NSNull null], kCIContextUseSoftwareRenderer:@YES} ];
    
    _videoPreviewViewNoFilter = [[GLKView alloc] initWithFrame:self.view.bounds context:_eaglContext];
    [_videoPreviewViewNoFilter setDrawableDepthFormat:GLKViewDrawableDepthFormat24];
    [_videoPreviewViewNoFilter setDelegate:self];
    [_videoPreviewViewNoFilter setUserInteractionEnabled:YES];
    
    // because the native video image from the back camera is in UIDeviceOrientationLandscapeLeft (i.e. the home button is on the right), we need to apply a clockwise 90 degree transform so that we can draw the video preview as if we were in a landscape-oriented view; if you're using the front camera and you want to have a mirrored preview (so that the user is seeing themselves in the mirror), you need to apply an additional horizontal flip (by concatenating CGAffineTransformMakeScale(-1.0, 1.0) to the rotation transform)
    [self setFilterViewRotation:_videoPreviewViewNoFilter withScreenBounds:screenBounds];
    
    
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
    originalsize = _videoPreviewViewBounds.size;
    bMultipleView = NO;
    bFlip = NO;
    effectiveScale  = 1.0;
    nFilterIndex = A3MirrorNoFilter;
    [self _start];
    
    // create multi filter view with GestureRecognizer which should be done after AVCaptureSession initialize(_start)
    [self createFilterViews];
    [self setupGestureRecognizer];
    [self ShowOneFilterView:nFilterIndex];

    
    lastimageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,36,36)];
    [lastimageButton addTarget:_cameraRollButton.target action:_cameraRollButton.action forControlEvents:UIControlEventTouchUpInside];
    lastimageButton.layer.cornerRadius = 18.0;
    lastimageButton.layer.masksToBounds = YES;
    [self.bottomBar.items[0] setCustomView:lastimageButton];
    [self loadFirstPhoto];

}

- (void)viewWillLayoutSubviews {
    CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
    
    if (bMultipleView == YES) {
        [self setFilterViewRotation:_videoPreviewViewMonoFilter];
        [self setFilterViewRotation:_videoPreviewViewTonalFilter];
        [self setFilterViewRotation:_videoPreviewViewNoirFilter];
        [self setFilterViewRotation:_videoPreviewViewChromeFilter];
        [self setFilterViewRotation:_videoPreviewViewFadeFilter];
        [self setFilterViewRotation:_videoPreviewViewNoFilter];
        [self setFilterViewRotation:_videoPreviewViewProcessFilter];
        [self setFilterViewRotation:_videoPreviewViewInstantFilter];
        [self setFilterViewRotation:_videoPreviewViewTransferFilter];
        [self setLabelRotation:monoLabel];
        [self setLabelRotation:tonalLabel];
        [self setLabelRotation:noirLabel];
        [self setLabelRotation:chromeLabel];
        [self setLabelRotation:fadeLabel];
        [self setLabelRotation:noneLabel];
        [self setLabelRotation:processLabel];
        [self setLabelRotation:instantLabel];
        [self setLabelRotation:transferLabel];
        [self ShowMultipleViews:NO];
    }
    else {
        [self setFilterViewRotation:[self currentFilterView] withScreenBounds:screenBounds];
    }
    
    [self.statusBarBackground setFrame:CGRectMake(self.statusBarBackground.bounds.origin.x, self.statusBarBackground.bounds.origin.y , screenBounds.size.width , self.statusBarBackground.bounds.size.height)];
    [self.topBar setFrame:(CGRectMake(self.topBar.bounds.origin.x, 20 , screenBounds.size.width, self.topBar.bounds.size.height))];
    [self.bottomBar setFrame:(CGRectMake(self.bottomBar.bounds.origin.x, screenBounds.size.height - 44 , screenBounds.size.width, self.bottomBar.bounds.size.height))];
   // [self.brightnessslider setFrame:CGRectMake(self.brightnessToolBar.bounds.origin.x + 40, self.brightnessToolBar.bounds.origin.y + 20 , screenBounds.size.width - 110, 44)];
    //[self.magnifierslider setFrame:CGRectMake(self.magnifierToolBar.bounds.origin.x + 40, self.magnifierToolBar.bounds.origin.y + 20 , screenBounds.size.width - 110, 44)];
}
- (void) setFilterViewRotation:(GLKView *)filterView withScreenBounds:(CGRect)screenBounds{
    
    [self setFilterViewRotation:filterView];
    
    filterView.frame = screenBounds;
}

- (void) setFilterViewRotation:(GLKView *)filterView {
    if (IS_IPAD) {
        
        UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
        if (curDeviceOrientation == UIDeviceOrientationPortrait) {
            filterView.transform = CGAffineTransformMakeRotation(M_PI_2);
        } else if (curDeviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
            filterView.transform = CGAffineTransformMakeRotation(-M_PI_2);
        } else if (curDeviceOrientation == UIDeviceOrientationLandscapeRight) {
            filterView.transform = CGAffineTransformMakeRotation(M_PI);
        } else {
            filterView.transform = CGAffineTransformMakeRotation(0);
        }
    } else {
        filterView.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
}

- (void)setLabelRotation:(UILabel *)label {
    if (IS_IPAD) {
        
        UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
        if (curDeviceOrientation == UIDeviceOrientationPortrait) {
            label.transform = CGAffineTransformMakeRotation(-M_PI_2);
        } else if (curDeviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
            label.transform = CGAffineTransformMakeRotation(M_PI_2);
        } else if (curDeviceOrientation == UIDeviceOrientationLandscapeRight) {
            label.transform = CGAffineTransformMakeRotation(M_PI);
        } else {
            label.transform = CGAffineTransformMakeRotation(0);
        }
    } else {
        label.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }
}

- (BOOL)usesFullScreenInLandscape {
    return YES;
}

- (CGFloat) getMaxZoom {
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

- (void)_start
{
    
    NSError *error = nil;
    
    // get the input device and also validate the settings
    _videoDevice = [self deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionFront];
    // obtain device input
    AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_videoDevice error:&error];
    if (!videoDeviceInput)
    {
        FNLOG(@"Unable to obtain video device input, error: %@", error);
        return;
    }
    
    // create the capture session
    _captureSession = [AVCaptureSession new];
    
    // obtain the preset and validate the preset
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetHigh] == YES) {
            [_captureSession setSessionPreset:AVCaptureSessionPresetHigh];
        } else {
            [_captureSession setSessionPreset:AVCaptureSessionPreset640x480];
        }
    }
    else {
        [_captureSession setSessionPreset:AVCaptureSessionPresetPhoto];
    }
    
    // CoreImage wants BGRA pixel format
    NSDictionary *outputSettings = @{ (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInteger:kCVPixelFormatType_32BGRA]};
    
    
    // create and configure video data output
    AVCaptureVideoDataOutput *videoDataOutput = [AVCaptureVideoDataOutput new];
    videoDataOutput.videoSettings = outputSettings;
    videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
    [videoDataOutput setSampleBufferDelegate:self queue:_captureSessionQueue];
    
    
    // begin configure capture session
    [_captureSession beginConfiguration];
    
    if (![_captureSession canAddOutput:videoDataOutput])
    {
        FNLOG(@"Cannot add video data output");
        _captureSession = nil;
        return;
    }
    // Make a still image output
    stillImageOutput = [AVCaptureStillImageOutput new];
    if ( [_captureSession canAddOutput:stillImageOutput] )
        [_captureSession addOutput:stillImageOutput];
    
    
    // connect the video device input and video data and still image outputs
    [_captureSession addInput:videoDeviceInput];
    [_captureSession addOutput:videoDataOutput];
    
    [_captureSession commitConfiguration];
    if([_videoDevice lockForConfiguration:&error] == NO) {
        FNLOG(@"Device is locking failure : %@", error);
    }
    
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
    if ([self getMaxZoom] != 1) {   // support at loselessZoom
        [self setupZoomSlider];
    }
    
    
    // then start everything
    [_captureSession startRunning];
    
    
}

- (void) searchSlowCameraFrameRate {
    currentMaxDuration = _videoDevice.activeVideoMaxFrameDuration;
    currentMinDuration = _videoDevice.activeVideoMinFrameDuration;
    slowFrameRateRange = nil;
    
    for (AVFrameRateRange *range in _videoDevice.activeFormat.videoSupportedFrameRateRanges) {
        if (slowFrameRateRange == nil ) {
            slowFrameRateRange = range;
        }
        if(range.maxFrameRate < slowFrameRateRange.maxFrameRate) {
            slowFrameRateRange = range;
        }
    }
}

-(void) restoreOriginalFrameRate {
    _videoDevice.activeVideoMinFrameDuration = currentMaxDuration;
    _videoDevice.activeVideoMaxFrameDuration = currentMinDuration;
}

-(void) setSlowFrameRate {
    _videoDevice.activeVideoMinFrameDuration = slowFrameRateRange.minFrameDuration;
    _videoDevice.activeVideoMaxFrameDuration = slowFrameRateRange.maxFrameDuration;
}
- (void)_stop
{
    if (!_captureSession || !_captureSession.running)
        return;
    
    [_captureSession stopRunning];
    
    dispatch_sync(_captureSessionQueue, ^{
        NSLog(@"waiting for capture session to end");
    });
    
    [_videoDevice unlockForConfiguration];
    
    _captureSession = nil;
    _videoDevice = nil;
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    ciimg = [CIImage imageWithCVPixelBuffer:(CVPixelBufferRef)imageBuffer options:nil];
    CGRect sourceExtent = ciimg.extent;
    
    if (bFlip == NO) {
       // horizontal flip
      //  CGAffineTransform t = CGAffineTransformMake(-1, 0, 0, 1, sourceExtent.size.width,0);
       // ciimg = [ciimg imageByApplyingTransform:t];
            CGAffineTransform t = CGAffineTransformMake(1, 0, 0, -1, 0, sourceExtent.size.height);
            ciimg = [ciimg imageByApplyingTransform:t];
       
    }

    
    if(_eaglContext != [EAGLContext currentContext]) {
        [EAGLContext setCurrentContext:_eaglContext];
    }
    //setup the blend mode to "source over" so that CI will use that
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    if(bMultipleView == NO) {
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
    self.zoomSlider.maximumValue = [self getMaxZoom];
    self.zoomSlider.continuous = YES;
    FNLOG(@"minum = %f maximum = %f current = %f", self.zoomSlider.minimumValue, self.zoomSlider.maximumValue, self.zoomSlider.value);
}
#pragma GLKViewDelegate
- (void) glkView:(GLKView *)view drawInRect:(CGRect)rect {
    @autoreleasepool {
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
    
    CIImage *filteredImage = nil;

    if ([view isEqual:_videoPreviewViewMonoFilter]) {
        filteredImage = [CIFilter filterWithName:@"CIPhotoEffectMono" keysAndValues:kCIInputImageKey, ciimg, nil].outputImage;
    } else if ([view isEqual:_videoPreviewViewTonalFilter]) {
        filteredImage = [CIFilter filterWithName:@"CIPhotoEffectTonal" keysAndValues:kCIInputImageKey, ciimg, nil].outputImage;
        
    } else if ([view isEqual:_videoPreviewViewNoirFilter]) {
        filteredImage = [CIFilter filterWithName:@"CIPhotoEffectNoir" keysAndValues:kCIInputImageKey, ciimg, nil].outputImage;
        
    } else if ([view isEqual:_videoPreviewViewFadeFilter]) {
        filteredImage = [CIFilter filterWithName:@"CIPhotoEffectFade" keysAndValues:kCIInputImageKey, ciimg, nil].outputImage;
        
    } else if ([view isEqual:_videoPreviewViewChromeFilter]) {
        filteredImage = [CIFilter filterWithName:@"CIPhotoEffectChrome" keysAndValues:kCIInputImageKey, ciimg, nil].outputImage;
        
    } else if ([view isEqual:_videoPreviewViewProcessFilter]) {
        filteredImage = [CIFilter filterWithName:@"CIPhotoEffectProcess" keysAndValues:kCIInputImageKey, ciimg, nil].outputImage;
        
    } else if ([view isEqual:_videoPreviewViewTransferFilter]) {
        filteredImage = [CIFilter filterWithName:@"CIPhotoEffectTransfer" keysAndValues:kCIInputImageKey, ciimg, nil].outputImage;
        
    } else if([view isEqual:_videoPreviewViewInstantFilter]) {
        filteredImage = [CIFilter filterWithName:@"CIPhotoEffectInstant" keysAndValues:kCIInputImageKey, ciimg, nil].outputImage;
        
    }

    glClearColor(0.0f, 0.0f, 0.1f,0.1f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glFlush();
        
    if (filteredImage != nil) {
        [_ciContext drawImage:filteredImage inRect:_videoPreviewViewBounds fromRect:drawRect];
    } else {
       [_ciContext drawImage:ciimg inRect:_videoPreviewViewBounds fromRect:drawRect];
    }
    
    
    
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    [_eaglContext presentRenderbuffer:GL_RENDERBUFFER];
    }
    
}

#pragma mark - TapGesture setup
- (void)setupGestureRecognizer {
	@autoreleasepool {
        
        
		previewNoFilterGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnPreviewView:)];
		[_videoPreviewViewNoFilter addGestureRecognizer:previewNoFilterGestureRecognizer];
        
		previewMonoFilterGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnPreviewView:)];
        [_videoPreviewViewMonoFilter addGestureRecognizer:previewMonoFilterGestureRecognizer];
        
        
        
        previewTonalFilterGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnPreviewView:)];
        [_videoPreviewViewTonalFilter addGestureRecognizer:previewTonalFilterGestureRecognizer];
        
        
        previewNoirFilterGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnPreviewView:)];
        [_videoPreviewViewNoirFilter addGestureRecognizer:previewNoirFilterGestureRecognizer];
        
        
        previewFadeFilterGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnPreviewView:)];
        [_videoPreviewViewFadeFilter addGestureRecognizer:previewFadeFilterGestureRecognizer];
        
        
        previewChromeFilterGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnPreviewView:)];
        [_videoPreviewViewChromeFilter addGestureRecognizer:previewChromeFilterGestureRecognizer];
        
        
        previewProcessFilterGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnPreviewView:)];
        [_videoPreviewViewProcessFilter addGestureRecognizer:previewProcessFilterGestureRecognizer];
        
        
        
        previewTransferFilterGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnPreviewView:)];
        [_videoPreviewViewTransferFilter addGestureRecognizer:previewTransferFilterGestureRecognizer];
        
        previewInstantFilterGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnPreviewView:)];
        [_videoPreviewViewInstantFilter addGestureRecognizer:previewInstantFilterGestureRecognizer];
        
        
        if([self getMaxZoom] != 1) {
            UIGestureRecognizer *noFilterPinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFrom:)];
            noFilterPinchGesture.delegate = self;
            [_videoPreviewViewNoFilter addGestureRecognizer:noFilterPinchGesture];
            
            UIGestureRecognizer *monoFilterPinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFrom:)];
            monoFilterPinchGesture.delegate = self;
            [_videoPreviewViewMonoFilter addGestureRecognizer:monoFilterPinchGesture];
            
            UIGestureRecognizer *tonalFilterPinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFrom:)];
            tonalFilterPinchGesture.delegate = self;
            [_videoPreviewViewTonalFilter addGestureRecognizer:tonalFilterPinchGesture];
            
            UIGestureRecognizer *noirFilterPinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFrom:)];
            noirFilterPinchGesture.delegate = self;
            [_videoPreviewViewNoirFilter addGestureRecognizer:noirFilterPinchGesture];
            
            UIGestureRecognizer *fadeFilterPinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFrom:)];
            fadeFilterPinchGesture.delegate = self;
            [_videoPreviewViewFadeFilter addGestureRecognizer:fadeFilterPinchGesture];
            
            UIGestureRecognizer *chromeFilterPinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFrom:)];
            chromeFilterPinchGesture.delegate = self;
            [_videoPreviewViewChromeFilter addGestureRecognizer:chromeFilterPinchGesture];
            
            UIGestureRecognizer *processFilterPinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFrom:)];
            processFilterPinchGesture.delegate = self;
            [_videoPreviewViewProcessFilter addGestureRecognizer:processFilterPinchGesture];
            
            UIGestureRecognizer *transferFilterPinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFrom:)];
            transferFilterPinchGesture.delegate = self;
            [_videoPreviewViewTransferFilter addGestureRecognizer:transferFilterPinchGesture];
            
            UIGestureRecognizer *instantFilterPinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFrom:)];
            instantFilterPinchGesture.delegate = self;
            [_videoPreviewViewInstantFilter addGestureRecognizer:instantFilterPinchGesture];
            
        }
        
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
    if (effectiveScale < self.zoomSlider.minimumValue ) effectiveScale = self.zoomSlider.minimumValue;
    if(effectiveScale > self.zoomSlider.maximumValue) effectiveScale = self.zoomSlider.maximumValue;
    if(effectiveScale == self.zoomSlider.value) return;
    
    if (!_videoDevice.isRampingVideoZoom) {
        _videoDevice.videoZoomFactor = effectiveScale;
        self.zoomSlider.value = effectiveScale;
    }
}

- (void)tapOnPreviewView:(UITapGestureRecognizer *) tap {
	@autoreleasepool {
        if (bMultipleView == YES) {
            [self restoreOriginalFrameRate];
            if ([tap isEqual:previewNoFilterGestureRecognizer ]) {
                nFilterIndex = A3MirrorNoFilter;
                [self ShowOneFilterView:A3MirrorNoFilter];
            } else if ([tap isEqual:previewMonoFilterGestureRecognizer]) {
                nFilterIndex = A3MirrorMonoFilter;
                [self ShowOneFilterView:A3MirrorMonoFilter];
            } else if ([tap isEqual:previewTonalFilterGestureRecognizer]) {
                nFilterIndex = A3MirrorTonalFilter;
                [self ShowOneFilterView:A3MirrorTonalFilter];
            } else if ([tap isEqual:previewNoirFilterGestureRecognizer]) {
                nFilterIndex = A3MirrorNoirFilter;
                [self ShowOneFilterView:A3MirrorNoirFilter];
            } else if ([tap isEqual:previewFadeFilterGestureRecognizer]) {
                nFilterIndex = A3MirrorFadeFilter;
                [self ShowOneFilterView:A3MirrorFadeFilter];
            } else if ([tap isEqual:previewChromeFilterGestureRecognizer]) {
                nFilterIndex = A3MirrorChromeFilter;
                [self ShowOneFilterView:A3MirrorChromeFilter];
            } else if ([tap isEqual:previewProcessFilterGestureRecognizer]) {
                nFilterIndex = A3MirrorProcessFilter;
                [self ShowOneFilterView:A3MirrorProcessFilter];
            } else if ([tap isEqual:previewTransferFilterGestureRecognizer]) {
                nFilterIndex = A3MirrorTransferFilter;
                [self ShowOneFilterView:A3MirrorTransferFilter];
            } else if([tap isEqual:previewInstantFilterGestureRecognizer]) {
                nFilterIndex = A3MirrorInstantFilter;
                [self ShowOneFilterView:A3MirrorInstantFilter];
            }
            
            [self.filterButton setBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
            if (nFilterIndex == A3MirrorNoFilter) {
                [self.filterButton setImage:[[UIImage imageNamed:@"m_color"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            } else {
                [self.filterButton setImage:[[UIImage imageNamed:@"m_color_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            }
            self.bottomBar.hidden = NO;
            bMultipleView = NO;

        }
        else {
            BOOL toolBarHidden = self.topBar.hidden;
            [self setToolBarsHidden:!toolBarHidden];
            
        }
        
	}
}

- (void)setToolBarsHidden:(BOOL)hidden {
	@autoreleasepool {
        self.topBar.hidden = hidden;
        self.bottomBar.hidden = hidden;
        self.statusBarBackground.hidden = hidden;
        [[UIApplication sharedApplication] setStatusBarHidden:hidden];
        if ([self getMaxZoom] != 1) {
            if(hidden == YES) {
                [self.zoomToolBar setFrame:CGRectMake(self.zoomToolBar.frame.origin.x,
                                                      self.zoomToolBar.frame.origin.y + self.zoomToolBar.frame.size.height,
                                                      self.zoomToolBar.frame.size.width,
                                                      self.zoomToolBar.frame.size.height)];
            } else {
                [self.zoomToolBar setFrame:CGRectMake(self.zoomToolBar.frame.origin.x,
                                                      self.zoomToolBar.frame.origin.y - self.zoomToolBar.frame.size.height,
                                                      self.zoomToolBar.frame.size.width,
                                                      self.zoomToolBar.frame.size.height)];
            }
        }
	}
}

- (void)setNavigationBarHidden:(BOOL)hidden {
	@autoreleasepool {
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:nil];
		
		[self.navigationController setNavigationBarHidden:hidden];
	}
}

#pragma mark - Filter Setting

- (void)addAllFilterViews {
    [self.view addSubview:_videoPreviewViewMonoFilter];
    [self.view sendSubviewToBack:_videoPreviewViewMonoFilter];
    [self.view addSubview:_videoPreviewViewTonalFilter];
    [self.view sendSubviewToBack:_videoPreviewViewTonalFilter];
    [self.view addSubview:_videoPreviewViewNoirFilter];
    [self.view sendSubviewToBack:_videoPreviewViewNoirFilter];
    [self.view addSubview:_videoPreviewViewFadeFilter];
    [self.view sendSubviewToBack:_videoPreviewViewFadeFilter];
    [self.view addSubview:_videoPreviewViewChromeFilter];
    [self.view sendSubviewToBack:_videoPreviewViewChromeFilter];
    [self.view addSubview:_videoPreviewViewProcessFilter];
    [self.view sendSubviewToBack:_videoPreviewViewProcessFilter];
    [self.view addSubview:_videoPreviewViewTransferFilter];
    [self.view sendSubviewToBack:_videoPreviewViewTransferFilter];
    [self.view addSubview:_videoPreviewViewInstantFilter];
    [self.view sendSubviewToBack:_videoPreviewViewInstantFilter];
}
- (void)createFilterViews {
    GLKViewDrawableDepthFormat format = GLKViewDrawableDepthFormat24;
    
    _videoPreviewViewMonoFilter = [[GLKView alloc] initWithFrame:self.view.bounds context:_eaglContext];
    _videoPreviewViewMonoFilter.drawableDepthFormat = format;
    _videoPreviewViewMonoFilter.delegate = self;
    _videoPreviewViewNoFilter.userInteractionEnabled = YES;
    
    _videoPreviewViewTonalFilter = [[GLKView alloc] initWithFrame:self.view.bounds context:_eaglContext];
    _videoPreviewViewTonalFilter.drawableDepthFormat = format;
    _videoPreviewViewTonalFilter.delegate = self;
    _videoPreviewViewTonalFilter.userInteractionEnabled = YES;
    
    _videoPreviewViewNoirFilter = [[GLKView alloc] initWithFrame:self.view.bounds context:_eaglContext];
    _videoPreviewViewNoirFilter.drawableDepthFormat = format;
    _videoPreviewViewNoirFilter.delegate = self;
    _videoPreviewViewNoirFilter.userInteractionEnabled = YES;
    
    _videoPreviewViewFadeFilter = [[GLKView alloc] initWithFrame:self.view.bounds context:_eaglContext];
    _videoPreviewViewFadeFilter.drawableDepthFormat = format;
    _videoPreviewViewFadeFilter.delegate = self;
    _videoPreviewViewFadeFilter.userInteractionEnabled = YES;
    
    _videoPreviewViewChromeFilter = [[GLKView alloc] initWithFrame:self.view.bounds context:_eaglContext];
    _videoPreviewViewChromeFilter.drawableDepthFormat = format;
    _videoPreviewViewChromeFilter.delegate = self;
    _videoPreviewViewChromeFilter.userInteractionEnabled = YES;
    
    _videoPreviewViewProcessFilter = [[GLKView alloc] initWithFrame:self.view.bounds context:_eaglContext];
    _videoPreviewViewProcessFilter.drawableDepthFormat = format;
    _videoPreviewViewProcessFilter.delegate = self;
    _videoPreviewViewProcessFilter.userInteractionEnabled = YES;
    
    _videoPreviewViewTransferFilter = [[GLKView alloc] initWithFrame:self.view.bounds context:_eaglContext];
    _videoPreviewViewTransferFilter.drawableDepthFormat = format;
    _videoPreviewViewTransferFilter.delegate = self;
    _videoPreviewViewTransferFilter.userInteractionEnabled = YES;
    
    _videoPreviewViewInstantFilter = [[GLKView alloc] initWithFrame:self.view.bounds context:_eaglContext];
    _videoPreviewViewInstantFilter.drawableDepthFormat = format;
    _videoPreviewViewInstantFilter.delegate = self;
    _videoPreviewViewInstantFilter.userInteractionEnabled = YES;
    [self addAllFilterViews];
    monoLabel = [UILabel new];
    monoLabel.textColor = [UIColor whiteColor];
    monoLabel.backgroundColor = [UIColor clearColor];
    monoLabel.font = [UIFont fontWithName:@"Trebuchet MS" size: 10.0f];
    monoLabel.text = @"Mono";
    
    
    tonalLabel = [UILabel new];
    tonalLabel.textColor = [UIColor whiteColor];
    tonalLabel.backgroundColor = [UIColor clearColor];
    tonalLabel.font = [UIFont fontWithName:@"Trebuchet MS" size: 10.0f];
    tonalLabel.text = @"Tonal";
    
    noirLabel = [UILabel new];
    noirLabel.textColor = [UIColor whiteColor];
    noirLabel.backgroundColor = [UIColor clearColor];
    noirLabel.font = [UIFont fontWithName:@"Trebuchet MS" size: 10.0f];
    noirLabel.text = @"Noir";
    
    fadeLabel = [UILabel new];
    fadeLabel.textColor = [UIColor whiteColor];
    fadeLabel.backgroundColor = [UIColor clearColor];
    fadeLabel.font = [UIFont fontWithName:@"Trebuchet MS" size: 10.0f];
    fadeLabel.text = @"Fade";
    
    noneLabel = [UILabel new];
    noneLabel.textColor = [UIColor whiteColor];
    noneLabel.backgroundColor = [UIColor clearColor];
    noneLabel.font = [UIFont fontWithName:@"Trebuchet MS" size: 10.0f];
    noneLabel.text = @"None";
    
    chromeLabel = [UILabel new];
    chromeLabel.textColor = [UIColor whiteColor];
    chromeLabel.backgroundColor = [UIColor clearColor];
    chromeLabel.font = [UIFont fontWithName:@"Trebuchet MS" size: 10.0f];
    chromeLabel.text = @"Chrome";
    
    processLabel = [UILabel new];
    processLabel.textColor = [UIColor whiteColor];
    processLabel.backgroundColor = [UIColor clearColor];
    processLabel.font = [UIFont fontWithName:@"Trebuchet MS" size: 10.0f];
    processLabel.text = @"Process";
    
    transferLabel = [UILabel new];
    transferLabel.textColor = [UIColor whiteColor];
    transferLabel.backgroundColor = [UIColor clearColor];
    transferLabel.font = [UIFont fontWithName:@"Trebuchet MS" size: 10.0f];
    transferLabel.text = @"Transfer";
    
    instantLabel = [UILabel new];
    instantLabel.textColor = [UIColor whiteColor];
    instantLabel.backgroundColor = [UIColor clearColor];
    instantLabel.font = [UIFont fontWithName:@"Trebuchet MS" size: 10.0f];
    instantLabel.text = @"Transfer";
}


- (GLKView *) currentFilterView {
    switch (nFilterIndex) {
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
    
    FNLOG("nFilterIndex is invalide %ld", (unsigned long)nFilterIndex);
    return _videoPreviewViewNoFilter;
    
}
-(void) removeAllFilterViews {
    [_videoPreviewViewNoFilter removeFromSuperview];
    [_videoPreviewViewMonoFilter removeFromSuperview];
    [_videoPreviewViewTonalFilter removeFromSuperview];
    [_videoPreviewViewNoirFilter removeFromSuperview];
    [_videoPreviewViewFadeFilter removeFromSuperview];
    [_videoPreviewViewChromeFilter removeFromSuperview];
    [_videoPreviewViewProcessFilter removeFromSuperview];
    [_videoPreviewViewTransferFilter removeFromSuperview];
    [_videoPreviewViewInstantFilter removeFromSuperview];
}


- (void)cleanUp
{
    // remove the _videoPreviewNoFilter
    [self removeAllFilterViews];
    
    _videoPreviewViewNoFilter = nil;
    _videoPreviewViewMonoFilter = nil;
    _videoPreviewViewTonalFilter = nil;
    _videoPreviewViewNoirFilter = nil;
    _videoPreviewViewFadeFilter = nil;
    _videoPreviewViewChromeFilter = nil;
    _videoPreviewViewProcessFilter = nil;
    _videoPreviewViewTransferFilter = nil;
    _videoPreviewViewInstantFilter = nil;
    
    
    [self _stop];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // makes the UI more Camera.app like
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        [UIView setAnimationsEnabled:NO];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IB Action Buttons
- (IBAction)zoomIng:(id)sender {
    UISlider *zoomFactor = (UISlider *) sender;
    
    
    if (!_videoDevice.isRampingVideoZoom) {
        _videoDevice.videoZoomFactor = zoomFactor.value;
        effectiveScale = zoomFactor.value;
    }
    
}



- (IBAction)appsButton:(id)sender {
	if (IS_IPHONE) {
		[[self mm_drawerController] toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
	} else {
		[[[A3AppDelegate instance] rootViewController] toggleLeftMenuViewOnOff];
	}
}

- (IBAction)invertButton:(id)sender {
    
    [UIView transitionWithView:self.view duration:0.7 options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        if (bMultipleView == YES) {
                            [self removeAllFilterViews];
                        } else {
                            [[self currentFilterView] removeFromSuperview];
                        }
                        [_captureSession stopRunning];
                        bFlip = !bFlip;
                        [_captureSession startRunning];
                    }completion:^(BOOL finished) {
                        if (bMultipleView == YES) {
                            [self.view addSubview:_videoPreviewViewNoFilter];
                            [self.view sendSubviewToBack:_videoPreviewViewNoFilter];
                            [self addAllFilterViews];
                        } else {
                            [self.view addSubview:[self currentFilterView]];
                            [self.view sendSubviewToBack:[self currentFilterView]];
                        }
                    }];
}

- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
	AVCaptureVideoOrientation result = AVCaptureVideoOrientationLandscapeRight;
	if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
		result = AVCaptureVideoOrientationLandscapeRight;
	else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
		result = AVCaptureVideoOrientationLandscapeLeft;
    else if (deviceOrientation == UIDeviceOrientationPortrait)
        result = AVCaptureVideoOrientationPortrait;
    else if (deviceOrientation == UIDeviceOrientationPortraitUpsideDown)
        result = AVCaptureVideoOrientationPortraitUpsideDown;
	return result;
}

- (void) snapAnimation{
    @autoreleasepool {
        UIView *flashView = [[UIView alloc] initWithFrame:[_videoPreviewViewNoFilter frame]];
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

- (IBAction)captureButton:(id)sender {
    dispatch_async(_captureSessionQueue, ^{
		// Flash set to Auto for Still Capture
		// [self setFlashMode:AVCaptureFlashModeAuto forDevice:_videoDevice];
		
		// Capture a still image.
        
        //[self snapAnimation];
		[stillImageOutput captureStillImageAsynchronouslyFromConnection:[stillImageOutput connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            @autoreleasepool {
                if (imageDataSampleBuffer)
                {
                    NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                    CIImage *ciSaveImg = [[CIImage alloc] initWithData:imageData];
                    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
                    
                    if (bFlip == NO) {
                        CGAffineTransform f = CGAffineTransformMake(1, 0, 0, -1, 0, ciSaveImg.extent.size.height);
                        ciSaveImg = [ciSaveImg imageByApplyingTransform:f];
                    }
                    CGAffineTransform t;
                    
                    if (orientation == UIDeviceOrientationPortrait) {
                        t = CGAffineTransformMakeRotation(-M_PI / 2);
                    } else if (orientation == UIDeviceOrientationPortraitUpsideDown) {
                        t = CGAffineTransformMakeRotation(M_PI / 2);
                    } else if (orientation == UIDeviceOrientationLandscapeRight) {
                        t = CGAffineTransformMakeRotation(M_PI);
                    } else {
                        t = CGAffineTransformMakeRotation(0);
                    }
                    
                    
                    if (nFilterIndex == A3MirrorMonoFilter) {
                        ciSaveImg = [CIFilter filterWithName:@"CIPhotoEffectMono" keysAndValues:kCIInputImageKey, ciSaveImg, nil].outputImage;
                    } else if (nFilterIndex == A3MirrorTonalFilter) {
                        ciSaveImg = [CIFilter filterWithName:@"CIPhotoEffectTonal" keysAndValues:kCIInputImageKey, ciSaveImg, nil].outputImage;
                    } else if (nFilterIndex == A3MirrorNoirFilter) {
                        ciSaveImg = [CIFilter filterWithName:@"CIPhotoEffectNoir" keysAndValues:kCIInputImageKey, ciSaveImg, nil].outputImage;
                    } else if (nFilterIndex == A3MirrorFadeFilter) {
                        ciSaveImg = [CIFilter filterWithName:@"CIPhotoEffectFade" keysAndValues:kCIInputImageKey, ciSaveImg, nil].outputImage;
                    } else if (nFilterIndex == A3MirrorChromeFilter) {
                        ciSaveImg = [CIFilter filterWithName:@"CIPhotoEffectChrome" keysAndValues:kCIInputImageKey, ciSaveImg, nil].outputImage;
                    } else if (nFilterIndex == A3MirrorProcessFilter) {
                        ciSaveImg = [CIFilter filterWithName:@"CIPhotoEffectProcess" keysAndValues:kCIInputImageKey, ciSaveImg, nil].outputImage;
                    } else if (nFilterIndex == A3MirrorTransferFilter) {
                        ciSaveImg = [CIFilter filterWithName:@"CIPhotoEffectTransfer" keysAndValues:kCIInputImageKey, ciSaveImg, nil].outputImage;
                    } else if(nFilterIndex == A3MirrorInstantFilter) {
                        ciSaveImg = [CIFilter filterWithName:@"CIPhotoEffectInstant" keysAndValues:kCIInputImageKey, ciSaveImg, nil].outputImage;
                    }
                    
                    ciSaveImg = [ciSaveImg imageByApplyingTransform:t];
                    CGImageRef cgimg = [_ciContext createCGImage:ciSaveImg fromRect:[ciSaveImg extent]];
                    [[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:cgimg metadata:[ciimg properties] completionBlock:nil];
                    [self setImageOnCameraRollButton:[UIImage imageWithCGImage:cgimg]];
                }
            }
		}];
        
        
	});
}

#pragma mark - FIlter Control
- (IBAction)ColorButton:(id)sender {
    bMultipleView = !bMultipleView;
    
    if (bMultipleView == YES) {
        [self setSlowFrameRate];
        self.bottomBar.hidden = YES;
        if([self getMaxZoom] !=1) {
            self.zoomToolBar.hidden =  YES;
        }
        [self ShowMultipleViews:YES];
    }
}

- (void) ShowOneFilterView:(NSUInteger) nViewIndex {
    CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
    CGFloat width = screenBounds.size.width;
    CGFloat height = screenBounds.size.height;
    CGFloat x = width;
    CGFloat y = height;
    
    NSArray *coordinate = filterViewCoordinate[nViewIndex];
    
    [monoLabel removeFromSuperview];
    [tonalLabel removeFromSuperview];
    [noirLabel removeFromSuperview];
    [fadeLabel removeFromSuperview];
    [noneLabel removeFromSuperview];
    [chromeLabel removeFromSuperview];
    [processLabel removeFromSuperview];
    [transferLabel removeFromSuperview];
    [instantLabel removeFromSuperview];
    
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
                     completion:nil];
    
    _videoPreviewViewBounds.size = originalsize;
    if([self getMaxZoom] != 1) {
        self.zoomToolBar.hidden = NO;
    }
}

- (void) ShowMultipleViews:(BOOL)bSizeChange {
        CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
    CGFloat height = (screenBounds.size.height-84)/3;
    CGFloat width  = (screenBounds.size.width*height)/screenBounds.size.height;
    CGFloat orignialHeight =_videoPreviewViewBounds.size.height;
    if (bSizeChange == YES) {
    _videoPreviewViewBounds.size.height = (_videoPreviewViewBounds.size.height)*(height/screenBounds.size.height);
    _videoPreviewViewBounds.size.width = (_videoPreviewViewBounds.size.height * _videoPreviewViewBounds.size.width)/orignialHeight;
    }
    //FNLOG(@"_videoPreviewViewBounds height = %f, width = %f: height = %f, width = %f", _videoPreviewViewBounds.size.height, _videoPreviewViewBounds.size.width,height,width);
    CGFloat widthOffset = (self.view.bounds.size.width - (width*3 + 10))/2;
    [UIView animateWithDuration:0.3
						  delay:0
						options:UIViewAnimationOptionCurveEaseIn
					 animations:^{

                         CGFloat x,y;
                         x = widthOffset, y = 20+44;
                         [_videoPreviewViewMonoFilter setFrame:CGRectMake(x, y, width, height)];
                         //FNLOG("Mono = %f, %f",_videoPreviewViewMonoFilter.frame.origin.x, _videoPreviewViewMonoFilter.frame.origin.y);
                         x = x+ width + 5;
                         [_videoPreviewViewTonalFilter setFrame:CGRectMake(x, y, width, height)];
                         //FNLOG("Tonal = %f, %f",_videoPreviewViewTonalFilter.frame.origin.x, _videoPreviewViewTonalFilter.frame.origin.y);
                         x = x+width + 5;
                         [_videoPreviewViewNoirFilter setFrame:CGRectMake(x, y, width, height)];
                         //FNLOG("Noir = %f, %f",_videoPreviewViewNoirFilter.frame.origin.x, _videoPreviewViewNoirFilter.frame.origin.y);
                         x = widthOffset, y = y + height + 5;
                         [_videoPreviewViewFadeFilter setFrame:CGRectMake(x, y, width, height)];
                        // FNLOG("_videoPreviewViewFadeFilter = %f, %f",_videoPreviewViewFadeFilter.frame.origin.x, _videoPreviewViewFadeFilter.frame.origin.y);
                         x = x + width + 5;
                         [_videoPreviewViewNoFilter setFrame:CGRectMake(x, y, width, height)];
                         //FNLOG("_videoPreviewViewNoFilter = %f, %f",_videoPreviewViewNoFilter.frame.origin.x, _videoPreviewViewNoFilter.frame.origin.y);
                         x = x + width + 5;
                         [_videoPreviewViewChromeFilter setFrame:CGRectMake(x, y, width, height)];
                         //FNLOG("_videoPreviewViewChromeFilter = %f, %f",_videoPreviewViewChromeFilter.frame.origin.x, _videoPreviewViewChromeFilter.frame.origin.y);
                         
                         x = widthOffset, y = y + height +5;
                         [_videoPreviewViewProcessFilter setFrame:CGRectMake(x, y, width, height)];
                        // FNLOG("_videoPreviewViewProcessFilter = %f, %f",_videoPreviewViewProcessFilter.frame.origin.x, _videoPreviewViewProcessFilter.frame.origin.y);
                         x = x + width + 5;
                         [_videoPreviewViewTransferFilter setFrame:CGRectMake(x, y, width, height)];
                         //FNLOG("_videoPreviewViewTransferFilter = %f, %f",_videoPreviewViewTransferFilter.frame.origin.x, _videoPreviewViewTransferFilter.frame.origin.y);
                         x = x + width + 5;
                         [_videoPreviewViewInstantFilter setFrame:CGRectMake(x, y, width, height)];
                         //FNLOG("_videoPreviewViewInstantFilter = %f, %f",_videoPreviewViewInstantFilter.frame.origin.x, _videoPreviewViewInstantFilter.frame.origin.y);
                     }
     
                     completion:^(BOOL finised) {

                         [_videoPreviewViewMonoFilter addSubview:monoLabel];
                         [monoLabel makeConstraints:^(MASConstraintMaker *make) {
                             make.bottom.equalTo(_videoPreviewViewMonoFilter.top).with.offset(25);
                             make.right.equalTo(_videoPreviewViewMonoFilter.right);
                         }];
                         [_videoPreviewViewTonalFilter addSubview:tonalLabel];
                         [tonalLabel makeConstraints:^(MASConstraintMaker *make) {
                             make.bottom.equalTo(_videoPreviewViewTonalFilter.top).with.offset(25);
                             make.right.equalTo(_videoPreviewViewTonalFilter.right);
                         }];
                         [_videoPreviewViewNoirFilter addSubview:noirLabel];
                         [noirLabel makeConstraints:^(MASConstraintMaker *make) {
                             make.bottom.equalTo(_videoPreviewViewNoirFilter.top).with.offset(21);
                             make.right.equalTo(_videoPreviewViewNoirFilter.right);
                         }];
                         [_videoPreviewViewFadeFilter addSubview:fadeLabel];
                         [fadeLabel makeConstraints:^(MASConstraintMaker *make) {
                             make.bottom.equalTo(_videoPreviewViewFadeFilter.top).with.offset(24);
                             make.right.equalTo(_videoPreviewViewFadeFilter.right);
                         }];
                         [_videoPreviewViewNoFilter addSubview:noneLabel];
                         [noneLabel makeConstraints:^(MASConstraintMaker *make) {
                             make.bottom.equalTo(_videoPreviewViewNoFilter.top).with.offset(25);
                             make.right.equalTo(_videoPreviewViewNoFilter.right);
                         }];
                         [_videoPreviewViewChromeFilter addSubview:chromeLabel];
                         [chromeLabel makeConstraints:^(MASConstraintMaker *make) {
                             make.bottom.equalTo(_videoPreviewViewChromeFilter.top).with.offset(35);
                             make.right.equalTo(_videoPreviewViewChromeFilter.right);
                         }];
                         [_videoPreviewViewProcessFilter addSubview:processLabel];
                         [processLabel makeConstraints:^(MASConstraintMaker *make) {
                             make.bottom.equalTo(_videoPreviewViewProcessFilter.top).with.offset(35);
                             make.right.equalTo(_videoPreviewViewProcessFilter.right);
                         }];
                         [_videoPreviewViewTransferFilter addSubview:transferLabel];
                         [transferLabel makeConstraints:^(MASConstraintMaker *make) {
                             make.bottom.equalTo(_videoPreviewViewTransferFilter.top).with.offset(37);
                             make.right.equalTo(_videoPreviewViewTransferFilter.right);
                         }];
                         [_videoPreviewViewInstantFilter addSubview:instantLabel];
                         [instantLabel makeConstraints:^(MASConstraintMaker *make) {
                             make.bottom.equalTo(_videoPreviewViewInstantFilter.top).with.offset(37);
                             make.right.equalTo(_videoPreviewViewInstantFilter.right);
                         }];
                     }];
    
}

#pragma mark - load camera roll
- (IBAction)loadCameraRoll:(id)sender {
    // Create browser
	MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = NO;
    browser.displayNavArrows = YES;
    browser.displaySelectionButtons = NO;
    browser.alwaysShowControls = YES;
    //browser.wantsFullScreenLayout = YES; deprecated
    browser.zoomPhotosToFill = YES;
    browser.enableGrid = YES;
    browser.startOnGrid = NO;
    [browser setCurrentPhotoIndex:0];
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nc animated:YES completion:nil];
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

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
    NSLog(@"ACTION!");
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

#pragma mark - Load Assets

-(UIImage *)cropImageWithSquare:(UIImage *)source
{
    CGSize finalsize = CGSizeMake(36,36);
    
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
                                   FNLOG("NO GroupSavedPhotos:%@", error);
                               }
     ];
    
}

#pragma mark - set image icon
- (void) setImageOnCameraRollButton:(UIImage *)image {
    [lastimageButton setBackgroundImage:[self cropImageWithSquare:image] forState:UIControlStateNormal];
}
@end
