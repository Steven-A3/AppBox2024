//
//  A3FlashViewController.m
//  AppBox3
//
//  Created by kimjeonghwan on 9/24/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3FlashViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+MMDrawerController.h"
#import "A3UIDevice.h"

typedef NS_ENUM(NSUInteger, A3FlashViewModeType) {
    A3FlashViewModeTypeColor = 0,
    A3FlashViewModeTypeEffect,
};

const CGFloat colorsForFlashlight[][4] = {
	{1.000, 1.000, 1.000, 1.0},
	{1.000, 0.039, 0.000, 1.0},
	{1.000, 0.290, 0.004, 1.0},
	{1.000, 0.529, 0.000, 1.0},
	{1.000, 0.792, 0.000, 1.0},
	{1.000, 0.984, 0.000, 1.0},
	{1.000, 0.831, 1.000, 1.0},
	{0.588, 1.000, 0.000, 1.0},
	{0.361, 1.000, 0.000, 1.0},
	{0.247, 0.976, 0.153, 1.0},
	{0.000, 1.000, 0.031, 1.0},
	{0.145, 1.000, 0.529, 1.0},
	{0.000, 1.000, 0.722, 1.0},
	{0.000, 1.000, 0.906, 1.0},
	{0.004, 0.878, 1.000, 1.0},
	{0.004, 0.675, 1.000, 1.0},
	{0.000, 0.396, 1.000, 1.0},
	{0.000, 0.137, 1.000, 1.0},
	{0.035, 0.000, 1.000, 1.0},
	{0.349, 0.004, 1.000, 1.0},
	{0.510, 0.000, 1.000, 1.0},
	{0.675, 0.000, 1.000, 1.0},
	{0.894, 0.004, 1.000, 1.0},
	{1.000, 0.000, 0.980, 1.0},
	{1.000, 0.004, 0.749, 1.0},
	{1.000, 0.004, 0.404, 1.0},
	{1.000, 0.000, 0.098, 1.0},
	{0.000, 0.000, 0.000, 1.0}
};

#define	STROBE_LOOP_SOS_COUNT	19

const CGFloat strobeLoop_SOS[][6] = {
	/* time, option(0 for use current color, 1 for use specified here), r,g,b,a */
	{1.0, 1, 0.0, 0.0, 0.0, 1.0},
	
	{0.2, 1, 1.0, 1.0, 1.0, 1.0},
	{0.4, 1, 0.0, 0.0, 0.0, 1.0},
	{0.2, 1, 1.0, 1.0, 1.0, 1.0},
	{0.4, 1, 0.0, 0.0, 0.0, 1.0},
	{0.2, 1, 1.0, 1.0, 1.0, 1.0},
	{0.4, 1, 0.0, 0.0, 0.0, 1.0},
    
	{0.6, 1, 1.0, 1.0, 1.0, 1.0},
	{0.4, 1, 0.0, 0.0, 0.0, 1.0},
	{0.6, 1, 1.0, 1.0, 1.0, 1.0},
	{0.4, 1, 0.0, 0.0, 0.0, 1.0},
	{0.6, 1, 1.0, 1.0, 1.0, 1.0},
	{0.4, 1, 0.0, 0.0, 0.0, 1.0},
    
	{0.2, 1, 1.0, 1.0, 1.0, 1.0},
	{0.4, 1, 0.0, 0.0, 0.0, 1.0},
	{0.2, 1, 1.0, 1.0, 1.0, 1.0},
	{0.4, 1, 0.0, 0.0, 0.0, 1.0},
	{0.2, 1, 1.0, 1.0, 1.0, 1.0},
	{0.4, 1, 0.0, 0.0, 0.0, 1.0},
	
};

#define STROBE_LOOP_STROBE_COUNT	2

const CGFloat strobeLoop_STROBE[][6] = {
	{0.15, 0, 0.0, 0.0, 0.0, 0.0},
	{0.15, 1, 1.0, 1.0, 1.0, 1.0},
};

#define STROBE_LOOP_TRIPPIN_COUNT	6

const CGFloat strobeLoop_TRIPPIN[][6] = {
	{0.15, 1, 1.0, 0.0, 0.0, 1.0},
	{0.15, 1, 1.0, 1.0, 0.0, 1.0},
	{0.15, 1, 1.0, 1.0, 0.0, 1.0},
	{0.15, 1, 0.247, 0.976, 0.153, 1.0},
	{0.15, 1, 0.0, 1.0, 0.906, 1.0},
	{0.15, 1, 0.0, 0.0, 1.0, 1.0}
};

#define STROBE_LOOP_POLICECAR_COUNT	2

const CGFloat strobeLoop_POLICECAR[][6] = {
	{0.15, 1, 1.0, 0.0, 0.0, 1.0},
	{0.15, 1, 0.0, 0.0, 1.0, 1.0},
};

#define STROBE_LOOP_FIRETRUCK_COUNT	3

const CGFloat strobeLoop_FIRETRUCK[][6] = {
	{0.15, 1, 1.0, 0.0, 0.0, 1.0},
	{0.15, 1, 0.0, 0.0, 1.0, 1.0},
	{0.15, 1, 1.0, 1.0, 1.0, 1.0},
};

#define STROBE_LOOP_CAUTINFLARE_COUNT	2

const CGFloat strobeLoop_CAUTINFLARE[][6] = {
	{0.15, 1, 1.0, 1.0, 0.0, 1.0},
	{0.15, 1, 0.0, 0.0, 0.0, 1.0},
};

#define STROBE_LOOP_TRAFFICLIGHT_COUNT	3

const CGFloat strobeLoop_TRAFFICLIGHT[][6] = {
	{0.15, 1, 1.0, 0.0, 0.0, 1.0},
	{0.15, 1, 0.247, 0.976, 0.153, 1.0},
	{0.15, 1, 1.0, 1.0, 0.0, 1.0}
};


NSString *const A3UserDefaultFlashViewMode = @"A3UserDefaultFlashViewMode";
NSString *const A3UserDefaultFlashSelectedColor = @"A3UserDefaultFlashSelectedColor";
NSString *const A3UserDefaultFlashBrightnessValue = @"A3UserDefaultFlashBrightnessValue";
NSString *const A3UserDefaultFlashEffectIndex = @"A3UserDefaultFlashEffectIndex";
NSString *const A3UserDefaultFlashTurnLEDOnAtStart = @"A3UserDefaultFlashTurnLEDOnAtStart";
NSString *const cellID = @"flashEffectID";

@interface A3FlashViewController () <UIAlertViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, NPColorPickerViewDelegate>
@property (strong, nonatomic) UIColor *selectedColor;
@end

@implementation A3FlashViewController
{
    A3FlashViewModeType _currentFlashViewMode;
    CGFloat _currentBrightnessValue;
    CGFloat _deviceBrightnessBefore;
    CGFloat _effectSpeedValue;
    BOOL _isTorchOn;
    BOOL _LEDInitialized;
    BOOL _isLEDAvailable;
    BOOL LEDOnInSTROBE_mode;
    BOOL _isEffectWorking;
    NSArray *_flashEffectList;
	NSTimer		*strobeTimer;
	NSInteger	effectLoopCount;
	NSInteger	_selectedEffectIndex;
    CGFloat		strobeSpeedFactor;
    BOOL    _showAllMenu;
}

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
	[self setNavigationBarHidden:YES];
    
    [self initializeStatus];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(flashScreenTapped:)];
    [_contentImageView addGestureRecognizer:tapGesture];
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(flashScreenTapped:)];
    [_colorPickerView addGestureRecognizer:tapGesture2];
    
    [self checkTorchOnStartIfNeeded];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
#if !TARGET_IPHONE_SIMULATOR
	if (_LEDSession) {
		[_LEDSession stopRunning];
		_LEDSession = nil;
		
		_LEDInitialized = NO;
	}
#endif
}

- (void)initializeStatus
{
    _currentFlashViewMode = [[NSUserDefaults standardUserDefaults] integerForKey:A3UserDefaultFlashViewMode];
    
    _selectedColor = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:A3UserDefaultFlashSelectedColor]];
    if (!_selectedColor) {
        _selectedColor = [UIColor blackColor];
    }
    
    _deviceBrightnessBefore = [[UIScreen mainScreen] brightness];
    _colorPickerView.delegate = self;
    _colorPickerView.backgroundColor = [UIColor clearColor];
    
    _flashEffectList = @[NSLocalizedString(@"SOS", @"SOS"),
                         NSLocalizedString(@"Strobe", @"Strobe"),
                         NSLocalizedString(@"Trippy", @"Trippy"),
                         NSLocalizedString(@"Police Car", @"Police Car"),
                         NSLocalizedString(@"Fire Truck", @"Fire Truck"),
                         NSLocalizedString(@"Caution Flare", @"Caution Flare"),
                         NSLocalizedString(@"Traffic Light", @"Traffic Light")];
    
    [self configureFlashViewMode:_currentFlashViewMode animation:NO];
    [_contentImageView setBackgroundColor:_selectedColor];
}

- (void)checkTorchOnStartIfNeeded {
    NSNumber *isLedOnStart = [[NSUserDefaults standardUserDefaults] objectForKey:A3UserDefaultFlashTurnLEDOnAtStart];
    if (!isLedOnStart) {
        UIAlertView *question = [[UIAlertView alloc] initWithTitle:nil
                                                           message:NSLocalizedStringFromTable(@"Turn LED on always? You can change it in the Settings.", @"common", @"Messagews")
                                                          delegate:self
                                                 cancelButtonTitle:NSLocalizedStringFromTable(@"NO", @"common", @"Messages")
                                                 otherButtonTitles:NSLocalizedStringFromTable(@"YES", @"common", @"Messages"), nil];
        question.delegate = self;
        [question show];
        
        return;
    }
    
    if ([isLedOnStart boolValue]) {
        [self LEDlightOnButtonTouchUp:nil];
    }
}

- (UIColor *)currentColor {
    return self.selectedColor;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNavigationBarHidden:(BOOL)hidden {
	[self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
	[self.navigationController.navigationBar setShadowImage:nil];
	[self.navigationController setNavigationBarHidden:hidden];
}

- (void)flashScreenTapped:(UITapGestureRecognizer *)gesture {
//    _topMenuToolbar.hidden = !_topMenuToolbar.hidden;
    _showAllMenu = !_showAllMenu;
    
    
    if (_showAllMenu) {
        _sliderToolBarBottomConst.constant = 44;
        [self configureFlashViewMode:_currentFlashViewMode animation:YES];
    }
    else {
        [UIView beginAnimations:A3AnimationIDKeyboardWillShow context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:7];
        [UIView setAnimationDuration:0.25];
        
        _topToolBarTopConst.constant = -65;
        _sliderToolBarBottomConst.constant = 0;
        _bottomToolBarBottomConst.constant = -44;
        _pickerViewBottomConst.constant = -162;
        _colorPickerViewBottomConst.constant = -CGRectGetHeight(_colorPickerView.bounds);
        
        [_topToolBar layoutIfNeeded];
        [_sliderToolBar layoutIfNeeded];
        [_bottomToolBar layoutIfNeeded];
        
        [UIView commitAnimations];
    }
}

#pragma mark - menu bar actions
- (IBAction)effectBarButtonAction:(id)sender {
    [self configureFlashViewMode:A3FlashViewModeTypeEffect animation:YES];
}

- (IBAction)sliderControlValueChanged:(UISlider *)sender {
    
    switch (_currentFlashViewMode) {
        case A3FlashViewModeTypeColor:
        {
            [self colorModeSliderValueChanged:sender];
        }
            break;
            
        case A3FlashViewModeTypeEffect:
        {
            [self effectModeSliderValueChanged:sender];
        }
            break;
            
        default:
            break;
    }
}

- (IBAction)LEDlightOnButtonTouchUp:(id)sender {
	Class myClass = NSClassFromString(@"AVCaptureDevice");
	if (!myClass) {
		return;
	}
	
	AVCaptureDevice *myTorch = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	if (myTorch) {
		if ([myTorch isTorchModeSupported:AVCaptureTorchModeOn]) {
			if (_isTorchOn) {
				[self setTorchOff];
				_isTorchOn = NO;
			} else {
				[self initializeLED];
				[self setTorchOn];
				_isTorchOn = YES;
			}
		}
	}
}

- (IBAction)appsButtonTouchUp:(id)sender {
    [self releaseStrobelight];
    
    if (IS_IPHONE) {
		[[self mm_drawerController] toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
	} else {
		[[[A3AppDelegate instance] rootViewController] toggleLeftMenuViewOnOff];
	}
}

- (IBAction)detailInfoButtonTouchUp:(id)sender {
}

- (IBAction)LEDonOffButtonTouchUp:(id)sender {
	Class myClass = NSClassFromString(@"AVCaptureDevice");
	if (!myClass) {
		return;
	}
	
	AVCaptureDevice *myTorch = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	if (myTorch) {
		if ([myTorch isTorchModeSupported:AVCaptureTorchModeOn]) {
			if (_isTorchOn) {
				[self setTorchOff];
				_isTorchOn = NO;
			} else {
				[self initializeLED];
				[self setTorchOn];
				_isTorchOn = YES;
			}
		}
	}
}

- (IBAction)colorMenuButtonTouchUp:(id)sender {
    [self releaseStrobelight];
    [self configureFlashViewMode:A3FlashViewModeTypeColor animation:YES];
    _isEffectWorking = NO;
}

- (IBAction)effectsMenuButtonTouchUp:(id)sender {
    if ((_currentFlashViewMode == A3FlashViewModeTypeEffect && !strobeTimer) || (_isEffectWorking && !strobeTimer) ) {
        [self startStrobeLightEffectForIndex:_selectedEffectIndex];
    }
    else {
        [self releaseStrobelight];
    }
    
    [self configureFlashViewMode:A3FlashViewModeTypeEffect animation:YES];
}

- (IBAction)effectPauseButtonTouchUp:(id)sender {
    if ((_currentFlashViewMode == A3FlashViewModeTypeEffect && !strobeTimer) || (_isEffectWorking && !strobeTimer) ) {
        [self startStrobeLightEffectForIndex:_selectedEffectIndex];
    }
    else {
        [self releaseStrobelight];
    }
}


- (void)colorModeSliderValueChanged:(UISlider *)slider {
    _currentBrightnessValue = (slider.maximumValue - slider.value);
    NSInteger brightnessIndex = floor(_currentBrightnessValue / (slider.maximumValue / 25.0));
    UIScreen *mainScreen = [UIScreen mainScreen];
    [mainScreen setBrightness:1.0 - (brightnessIndex / 25.0)];
}

- (void)effectModeSliderValueChanged:(UISlider *)slider {
    strobeSpeedFactor = [slider value];
}

#pragma mark -

- (void)configureFlashViewMode:(A3FlashViewModeType)type animation:(BOOL)animate {
    _currentFlashViewMode = type;
    [[NSUserDefaults standardUserDefaults] setInteger:_currentFlashViewMode forKey:A3UserDefaultFlashViewMode];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (animate) {
//        [UIView beginAnimations:A3AnimationIDKeyboardWillShow context:nil];
//        [UIView setAnimationBeginsFromCurrentState:YES];
//        [UIView setAnimationCurve:7];
//        [UIView setAnimationDuration:0.25];
        
        [self adjustConfigurationLayoutValueForFlashViewMode:_currentFlashViewMode];
        
//        [_topToolBar layoutIfNeeded];
//        [_sliderToolBar layoutIfNeeded];
//        [_bottomToolBar layoutIfNeeded];
//        [_pickerPanelView layoutIfNeeded];
//        [_colorPickerView layoutIfNeeded];
//        
//        [UIView commitAnimations];
    }
    else {
        [self adjustConfigurationLayoutValueForFlashViewMode:_currentFlashViewMode];
    }
}

- (void)adjustConfigurationLayoutValueForFlashViewMode:(A3FlashViewModeType)type {
    _topToolBarTopConst.constant = 20;
    
    switch (_currentFlashViewMode) {
        case A3FlashViewModeTypeColor:
        {
            [_sliderControl setMinimumValue:0.0];
            [_sliderControl setMaximumValue:100.0];
            [_sliderControl setValue:_sliderControl.maximumValue - _currentBrightnessValue];
            
            _contentImageView.backgroundColor = _selectedColor;
            _sliderToolBarBottomConst.constant = 44;
            _pickerViewBottomConst.constant = -162;
            _bottomToolBarBottomConst.constant = 0;
            _colorPickerViewBottomConst.constant = IS_IPHONE35 ? 61 : 88;
        }
            break;

        case A3FlashViewModeTypeEffect:
        {
            [_sliderControl setMinimumValue:-80.0];
            [_sliderControl setMaximumValue:80.0];
            [_sliderControl setValue:0.0];
            
            _sliderToolBarBottomConst.constant = 44 + 162;
            _pickerViewBottomConst.constant = 44;
            _bottomToolBarBottomConst.constant = 0;
            _colorPickerViewBottomConst.constant = -CGRectGetHeight(_colorPickerView.bounds);
        }
            break;
            
        default:
            break;
    }
    
    if (_isEffectWorking) {
        _pauseSwitchButton.hidden = _currentFlashViewMode == A3FlashViewModeTypeEffect ? NO : YES;
        _pauseSwitchButton.alpha = _currentFlashViewMode == A3FlashViewModeTypeEffect ? 1.0 : 0.0;
    }
    else {
        _pauseSwitchButton.hidden = YES;
        _pauseSwitchButton.alpha = 0.0;
    }
}

#pragma mark - LED Related
- (void)setTorchOn {
#if !TARGET_IPHONE_SIMULATOR
	Class myClass = NSClassFromString(@"AVCaptureDevice");
	if (!myClass) {
		return;
	}
	
	NSLog(@"%s", __FUNCTION__);
	
	AVCaptureDevice *myTorch = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	[myTorch lockForConfiguration:nil];
	
	[myTorch setTorchMode:AVCaptureTorchModeOn];
	[myTorch setFlashMode:AVCaptureFlashModeOn];
	
	[myTorch unlockForConfiguration];

    if (_currentFlashViewMode != A3FlashViewModeTypeEffect) {
        _contentImageView.backgroundColor = [UIColor blackColor];
    }
#endif
}

- (void)setTorchOff {
//#if !TARGET_IPHONE_SIMULATOR
	Class myClass = NSClassFromString(@"AVCaptureDevice");
	if (!myClass) {
		return;
	}

	AVCaptureDevice *myTorch = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	[myTorch lockForConfiguration:nil];
	
	[myTorch setTorchMode:AVCaptureTorchModeOff];
	[myTorch setFlashMode:AVCaptureFlashModeOff];
	
	[myTorch unlockForConfiguration];
	
    if (_currentFlashViewMode != A3FlashViewModeTypeEffect) {
        _contentImageView.backgroundColor = _selectedColor;
    }
//#endif
}

- (void)toggleTorch {
#if !TARGET_IPHONE_SIMULATOR
	Class myClass = NSClassFromString(@"AVCaptureDevice");
	if (!myClass) {
		return;
	}
	
	if (_LEDSession) {
		if (_isTorchOn) {
			[self setTorchOff];
			_isTorchOn = NO;
		} else {
			[self setTorchOn];
			_isTorchOn = YES;
		}
	}
#endif
}

- (void)initializeLED {
	if (!_LEDInitialized) {
		AVCaptureDevice *myTorch = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
		AVCaptureDeviceInput *flashInput = [AVCaptureDeviceInput deviceInputWithDevice:myTorch error: nil];
		AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
		
		AVCaptureSession *_session = [[AVCaptureSession alloc] init];
		_LEDSession = _session;
		
		[_LEDSession beginConfiguration];
		
		[myTorch lockForConfiguration:nil];
		
		[myTorch setTorchMode:AVCaptureTorchModeOn];
		[myTorch setFlashMode:AVCaptureFlashModeOn];
		
		[_LEDSession addInput:flashInput];
		[_LEDSession addOutput:output];
		
		[myTorch unlockForConfiguration];
		
		[_LEDSession commitConfiguration];
		[_LEDSession startRunning];
		_LEDInitialized = YES;
        
        _isLEDAvailable = [A3UIDevice hasTorch];
	}
}

- (void)turnOnLED {
	NSLog(@"%s", __FUNCTION__);
	
	AVCaptureDevice *myTorch = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	if (myTorch) {
		if ([myTorch isTorchModeSupported:AVCaptureTorchModeOn]) {
			[self initializeLED];
			[self setTorchOn];
			_isTorchOn = YES;
		}
	}
}

- (void)applicationWillResignActive {
#ifdef TRACE_LOG
	NSLog(@"%s", __func__);
#endif
	if (_isTorchOn) {
		[self LEDlightOnButtonTouchUp:nil];
	}
    
	[_LEDSession stopRunning];
	_LEDSession = nil;
    
	_LEDInitialized = NO;
}

- (void)releaseStrobelight
{
    effectLoopCount = 0;
    
    if (strobeTimer) {
        [strobeTimer invalidate];
        strobeTimer = nil;
    }
}

#pragma mark - Effects
- (void)effectSOS:(NSTimer *)timer {
	UIImageView *contentsView = (UIImageView *)[self.view viewWithTag:1003];
	if (strobeLoop_SOS[effectLoopCount][1] == 0) {
		[contentsView setBackgroundColor:_selectedColor];
	} else {
		[contentsView setBackgroundColor: [UIColor colorWithRed:strobeLoop_SOS[effectLoopCount][2]
                                                          green:strobeLoop_SOS[effectLoopCount][3]
                                                           blue:strobeLoop_SOS[effectLoopCount][4]
                                                          alpha:strobeLoop_SOS[effectLoopCount][5]] ];
	}
#if !TARGET_IPHONE_SIMULATOR
	if (_isTorchOn) {
		if (_isLEDAvailable && _LEDSession) {
			if ((strobeLoop_SOS[effectLoopCount][2] == 1.0) &&
				(strobeLoop_SOS[effectLoopCount][3] == 1.0) &&
				(strobeLoop_SOS[effectLoopCount][4] == 1.0) &&
				(strobeLoop_SOS[effectLoopCount][5] == 1.0)) {
				[self setTorchOn];
			} else {
				[self setTorchOff];
			}
		}
	}
#endif
	double speedFactor = strobeLoop_SOS[effectLoopCount][0] - (strobeSpeedFactor/100.0 * strobeLoop_SOS[effectLoopCount][0]);
	NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:speedFactor];
	strobeTimer = [[NSTimer alloc] initWithFireDate:fireDate
                                           interval:0.0
                                             target:self
                                           selector:@selector(effectSOS:)
                                           userInfo:nil
                                            repeats:NO];
	
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	[runLoop addTimer:strobeTimer forMode:NSDefaultRunLoopMode];
	effectLoopCount = (effectLoopCount + 1) % STROBE_LOOP_SOS_COUNT;
}

- (void)effectSTROBE:(NSTimer *)timer {
	UIImageView *contentsView = (UIImageView *)[self.view viewWithTag:1003];
	if (strobeLoop_STROBE[effectLoopCount][1] == 0) {
		const CGFloat *components = CGColorGetComponents([self.currentColor CGColor]);
		if ((components[0] == 1.0) &&
			(components[1] == 1.0) &&
			(components[2] == 1.0)) {
			contentsView.backgroundColor = [UIColor blackColor];
		} else {
			[contentsView setBackgroundColor: self.currentColor];
		}
	} else {
		contentsView.backgroundColor = [UIColor colorWithRed:strobeLoop_STROBE[effectLoopCount][2]
													   green:strobeLoop_STROBE[effectLoopCount][3]
														blue:strobeLoop_STROBE[effectLoopCount][4]
													   alpha:strobeLoop_STROBE[effectLoopCount][5]];
	}
    
	if (_isTorchOn) {
		LEDOnInSTROBE_mode = !LEDOnInSTROBE_mode;
		if (LEDOnInSTROBE_mode)
			[self setTorchOn];
		else
			[self setTorchOff];
	}
	
	double speedFactor = strobeLoop_STROBE[effectLoopCount][0] - (strobeSpeedFactor/100.0 * strobeLoop_STROBE[effectLoopCount][0]);
	NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:speedFactor];
	strobeTimer = [[NSTimer alloc] initWithFireDate:fireDate
										   interval:0.0
											 target:self
										   selector:@selector(effectSTROBE:)
										   userInfo:nil
											repeats:NO];
	
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	[runLoop addTimer:strobeTimer forMode:NSDefaultRunLoopMode];
	effectLoopCount = (effectLoopCount + 1) % STROBE_LOOP_STROBE_COUNT;
}

- (void)effectTRIPPIN:(NSTimer *)timer {
	UIImageView *contentsView = (UIImageView *)[self.view viewWithTag:1003];
	if (strobeLoop_TRIPPIN[effectLoopCount][1] == 0) {
		[contentsView setBackgroundColor: self.currentColor];
	} else {
		[contentsView setBackgroundColor: [UIColor colorWithRed:strobeLoop_TRIPPIN[effectLoopCount][2]
                                                          green:strobeLoop_TRIPPIN[effectLoopCount][3]
                                                           blue:strobeLoop_TRIPPIN[effectLoopCount][4]
                                                          alpha:strobeLoop_TRIPPIN[effectLoopCount][5]] ];
	}
    
	if (_isTorchOn) {
		LEDOnInSTROBE_mode = !LEDOnInSTROBE_mode;
		if (LEDOnInSTROBE_mode)
			[self setTorchOn];
		else
			[self setTorchOff];
	}
	
	double speedFactor = strobeLoop_TRIPPIN[effectLoopCount][0] - (strobeSpeedFactor/100.0 * strobeLoop_TRIPPIN[effectLoopCount][0]);
	NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:speedFactor];
	strobeTimer = [[NSTimer alloc] initWithFireDate:fireDate
										   interval:0.0
											 target:self
										   selector:@selector(effectTRIPPIN:)
										   userInfo:nil
											repeats:NO];
	
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	[runLoop addTimer:strobeTimer forMode:NSDefaultRunLoopMode];
	effectLoopCount = (effectLoopCount + 1) % STROBE_LOOP_TRIPPIN_COUNT;
}

- (void)effectPOLICECAR:(NSTimer *)timer {
	UIImageView *contentsView = (UIImageView *)[self.view viewWithTag:1003];
	if (strobeLoop_POLICECAR[effectLoopCount][1] == 0) {
		[contentsView setBackgroundColor: self.currentColor];
	} else {
		[contentsView setBackgroundColor: [UIColor colorWithRed:strobeLoop_POLICECAR[effectLoopCount][2]
                                                          green:strobeLoop_POLICECAR[effectLoopCount][3]
                                                           blue:strobeLoop_POLICECAR[effectLoopCount][4]
                                                          alpha:strobeLoop_POLICECAR[effectLoopCount][5]] ];
	}
	
	if (_isTorchOn) {
		LEDOnInSTROBE_mode = !LEDOnInSTROBE_mode;
		if (LEDOnInSTROBE_mode)
			[self setTorchOn];
		else
			[self setTorchOff];
	}
	
	double speedFactor = strobeLoop_POLICECAR[effectLoopCount][0] - (strobeSpeedFactor/100.0 * strobeLoop_POLICECAR[effectLoopCount][0]);
	NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:speedFactor];
	strobeTimer = [[NSTimer alloc] initWithFireDate:fireDate
										   interval:0.0
											 target:self
										   selector:@selector(effectPOLICECAR:)
										   userInfo:nil
											repeats:NO];
	
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	[runLoop addTimer:strobeTimer forMode:NSDefaultRunLoopMode];
	effectLoopCount = (effectLoopCount + 1) % STROBE_LOOP_POLICECAR_COUNT;
}

- (void)effectFIRETRUCK:(NSTimer *)timer {
	UIImageView *contentsView = (UIImageView *)[self.view viewWithTag:1003];
	if (strobeLoop_FIRETRUCK[effectLoopCount][1] == 0) {
		[contentsView setBackgroundColor: self.currentColor];
	} else {
		[contentsView setBackgroundColor: [UIColor colorWithRed:strobeLoop_FIRETRUCK[effectLoopCount][2]
                                                          green:strobeLoop_FIRETRUCK[effectLoopCount][3]
                                                           blue:strobeLoop_FIRETRUCK[effectLoopCount][4]
                                                          alpha:strobeLoop_FIRETRUCK[effectLoopCount][5]] ];
	}
	
	if (_isTorchOn) {
		LEDOnInSTROBE_mode = !LEDOnInSTROBE_mode;
		if (LEDOnInSTROBE_mode)
			[self setTorchOn];
		else
			[self setTorchOff];
	}
	
	double speedFactor = strobeLoop_FIRETRUCK[effectLoopCount][0] - (strobeSpeedFactor/100.0 * strobeLoop_FIRETRUCK[effectLoopCount][0]);
	NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:speedFactor];
	strobeTimer = [[NSTimer alloc] initWithFireDate:fireDate
										   interval:0.0
											 target:self
										   selector:@selector(effectFIRETRUCK:)
										   userInfo:nil
											repeats:NO];
	
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	[runLoop addTimer:strobeTimer forMode:NSDefaultRunLoopMode];
	effectLoopCount = (effectLoopCount + 1) % STROBE_LOOP_FIRETRUCK_COUNT;
}

- (void)effectCAUTINFLARE:(NSTimer *)timer {
	UIImageView *contentsView = (UIImageView *)[self.view viewWithTag:1003];
	if (strobeLoop_CAUTINFLARE[effectLoopCount][1] == 0) {
		[contentsView setBackgroundColor: self.currentColor];
	} else {
		[contentsView setBackgroundColor: [UIColor colorWithRed:strobeLoop_CAUTINFLARE[effectLoopCount][2]
                                                          green:strobeLoop_CAUTINFLARE[effectLoopCount][3]
                                                           blue:strobeLoop_CAUTINFLARE[effectLoopCount][4]
                                                          alpha:strobeLoop_CAUTINFLARE[effectLoopCount][5]] ];
	}
	
	if (_isTorchOn) {
		LEDOnInSTROBE_mode = !LEDOnInSTROBE_mode;
		if (LEDOnInSTROBE_mode)
			[self setTorchOn];
		else
			[self setTorchOff];
	}
	
	double speedFactor = strobeLoop_CAUTINFLARE[effectLoopCount][0] - (strobeSpeedFactor/100.0 * strobeLoop_CAUTINFLARE[effectLoopCount][0]);
	NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:speedFactor];
	strobeTimer = [[NSTimer alloc] initWithFireDate:fireDate
										   interval:0.0
											 target:self
										   selector:@selector(effectCAUTINFLARE:)
										   userInfo:nil
											repeats:NO];
	
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	[runLoop addTimer:strobeTimer forMode:NSDefaultRunLoopMode];
	effectLoopCount = (effectLoopCount + 1) % STROBE_LOOP_CAUTINFLARE_COUNT;
}

- (void)effectTRAFFICLIGHT:(NSTimer *)timer {
	UIImageView *contentsView = (UIImageView *)[self.view viewWithTag:1003];
	if (strobeLoop_TRAFFICLIGHT[effectLoopCount][1] == 0) {
		[contentsView setBackgroundColor: self.currentColor];
	} else {
		[contentsView setBackgroundColor: [UIColor colorWithRed:strobeLoop_TRAFFICLIGHT[effectLoopCount][2]
                                                          green:strobeLoop_TRAFFICLIGHT[effectLoopCount][3]
                                                           blue:strobeLoop_TRAFFICLIGHT[effectLoopCount][4]
                                                          alpha:strobeLoop_TRAFFICLIGHT[effectLoopCount][5]] ];
	}
	
	if (_isTorchOn) {
		LEDOnInSTROBE_mode = !LEDOnInSTROBE_mode;
		if (LEDOnInSTROBE_mode)
			[self setTorchOn];
		else
			[self setTorchOff];
	}
	
	double speedFactor = strobeLoop_TRAFFICLIGHT[effectLoopCount][0] - (strobeSpeedFactor/100.0 * strobeLoop_TRAFFICLIGHT[effectLoopCount][0]);
	NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:speedFactor];
	strobeTimer = [[NSTimer alloc] initWithFireDate:fireDate
										   interval:0.0
											 target:self
										   selector:@selector(effectTRAFFICLIGHT:)
										   userInfo:nil
											repeats:NO];
	
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	[runLoop addTimer:strobeTimer forMode:NSDefaultRunLoopMode];
	effectLoopCount = (effectLoopCount + 1) % STROBE_LOOP_TRAFFICLIGHT_COUNT;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [[NSUserDefaults standardUserDefaults] setObject:@(buttonIndex) forKey:A3UserDefaultFlashTurnLEDOnAtStart];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (buttonIndex == 1) {
        [self LEDlightOnButtonTouchUp:nil];
    }
}

#pragma mark - UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [_flashEffectList count];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:[_flashEffectList objectAtIndex:row]
                                                                     attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    return attrString;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _selectedEffectIndex = row;
    [self startStrobeLightEffectForIndex:_selectedEffectIndex];
}


- (void)startStrobeLightEffectForIndex:(NSInteger)selectedIndex {
    [self releaseStrobelight];
    if (!_LEDSession) {
        [self initializeLED];
    }
    
	switch (selectedIndex) {
		case 0: {
			// SOS
			NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:0.0];
			strobeTimer = [[NSTimer alloc] initWithFireDate:fireDate
                                                   interval:0.0
                                                     target:self
                                                   selector:@selector(effectSOS:)
                                                   userInfo:nil
                                                    repeats:NO];
			break;
		}
		case 1: {
			NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:0.0];
			strobeTimer = [[NSTimer alloc] initWithFireDate:fireDate
												   interval:0.0
													 target:self
												   selector:@selector(effectSTROBE:)
												   userInfo:nil
													repeats:NO];
			break;
		}
		case 2: {
			NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:0.0];
			strobeTimer = [[NSTimer alloc] initWithFireDate:fireDate
												   interval:0.0
													 target:self
												   selector:@selector(effectTRIPPIN:)
												   userInfo:nil
													repeats:NO];
			break;
		}
		case 3: {
			NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:0.0];
			strobeTimer = [[NSTimer alloc] initWithFireDate:fireDate
												   interval:0.0
													 target:self
												   selector:@selector(effectPOLICECAR:)
												   userInfo:nil
													repeats:NO];
			break;
		}
		case 4: {
			NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:0.0];
			strobeTimer = [[NSTimer alloc] initWithFireDate:fireDate
												   interval:0.0
													 target:self
												   selector:@selector(effectFIRETRUCK:)
												   userInfo:nil
													repeats:NO];
			break;
		}
		case 5: {
			NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:0.0];
			strobeTimer = [[NSTimer alloc] initWithFireDate:fireDate
												   interval:0.0
													 target:self
												   selector:@selector(effectCAUTINFLARE:)
												   userInfo:nil
													repeats:NO];
			break;
		}
		case 6: {
			NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:0.0];
			strobeTimer = [[NSTimer alloc] initWithFireDate:fireDate
												   interval:0.0
													 target:self
												   selector:@selector(effectTRAFFICLIGHT:)
												   userInfo:nil
													repeats:NO];
			break;
		}
	}
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	[runLoop addTimer:strobeTimer forMode:NSDefaultRunLoopMode];
    _isEffectWorking = YES;

    
    [UIView beginAnimations:A3AnimationIDKeyboardWillShow context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationCurve:7];
    [UIView setAnimationDuration:0.25];
    
    _pauseSwitchButton.hidden = NO;
    _pauseSwitchButton.alpha = 1.0;
    
    [UIView commitAnimations];
}

#pragma mark - NPColorPickerViewDelegate
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)NPColorPickerView:(NPColorPickerView *)view didSelectColor:(UIColor *)color {
    _selectedColor = color;
    _contentImageView.backgroundColor = _selectedColor;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_selectedColor] forKey:A3UserDefaultFlashSelectedColor];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
