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
#import "A3UserDefaults.h"
#import "A3InstructionViewController.h"
#import "MBProgressHUD.h"
#import "UIImage+imageWithColor.h"
#import <AVFoundation/AVFoundation.h>
#import "NPColorPickerView.h"

#define kBottomToolBarHeight        74

extern NSString *const A3UserDefaultFlashViewMode;
extern NSString *const A3UserDefaultFlashSelectedColor;
extern NSString *const A3UserDefaultFlashBrightnessValue;
extern NSString *const A3UserDefaultFlashLEDBrightnessValue;
extern NSString *const A3UserDefaultFlashEffectIndex;

typedef NS_ENUM(NSUInteger, A3FlashViewModeType) {
    A3FlashViewModeTypeNone = 0x00000000,
    A3FlashViewModeTypeLED = 0x00000001,
    A3FlashViewModeTypeColor = 0x00000002,
    A3FlashViewModeTypeEffect = 0x00000004
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
NSString *const A3UserDefaultFlashBlackWhiteValue = @"A3UserDefaultFlashBlackWhiteValue";
NSString *const A3UserDefaultFlashBrightnessValue = @"A3UserDefaultFlashBrightnessValue";
NSString *const A3UserDefaultFlashLEDBrightnessValue = @"A3UserDefaultFlashLEDBrightnessValue";
NSString *const A3UserDefaultFlashEffectIndex = @"A3UserDefaultFlashEffectIndex";
NSString *const A3UserDefaultFlashStrobeSpeedValue = @"A3UserDefaultFlashStrobeSpeedValue";

NSString *const cellID = @"flashEffectID";

@interface A3FlashViewController () <UIAlertViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, NPColorPickerViewDelegate, A3InstructionViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIToolbar *topToolBar;
@property (weak, nonatomic) IBOutlet UIToolbar *sliderToolBar;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolBar;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolBar2;
@property (weak, nonatomic) IBOutlet UIToolbar *LEDBrightnessToolBar;
@property (weak, nonatomic) IBOutlet UIView *pickerPanelView;
@property (weak, nonatomic) IBOutlet UIView *statusBarView;
@property (weak, nonatomic) IBOutlet NPColorPickerView *colorPickerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topToolBarTopConst;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomToolBarBottomConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomToolBar2BottomConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pickerViewBottomConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorPickerHeightConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorPickerWidthConst;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pickerTopSeparatorHeightConst;

@property (weak, nonatomic) IBOutlet UISlider *sliderControl;
@property (weak, nonatomic) IBOutlet UISlider *flashBrightnessSlider;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorPickerTopConst;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *ledBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *colorBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *effectBarButton;
@property (weak, nonatomic) IBOutlet UIPickerView *effectPickerView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *colorBarButton2;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *effectBarButton2;

@property (weak, nonatomic) IBOutlet UIImageView *screenBrightnessMinButton;
@property (weak, nonatomic) IBOutlet UIImageView *screenBrightnessMaxButton;
@property (weak, nonatomic) IBOutlet UIImageView *flashBrightnessMinButton;
@property (weak, nonatomic) IBOutlet UIImageView *flashBrightnessMaxButton;
@property (weak, nonatomic) IBOutlet UIView *pickerSeparatorView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *appsBarButton;

- (IBAction)sliderControlValueChanged:(UISlider *)sender;

- (IBAction)appsButtonTouchUp:(id)sender;
- (IBAction)detailInfoButtonTouchUp:(id)sender;

- (IBAction)LEDMenuButtonTouchUp:(id)sender;
- (IBAction)colorMenuButtonTouchUp:(id)sender;
- (IBAction)effectsMenuButtonTouchUp:(id)sender;

@property (strong, nonatomic) UIColor *selectedColor;
@property (strong, nonatomic) A3InstructionViewController *instructionViewController;
@property (strong, nonatomic) AVCaptureSession *LEDSession;
@property (strong, nonatomic) NSTimer *hideMenuTimer;
@property (strong, nonatomic) UITapGestureRecognizer *effectPickerViewTapGesture;
@property (strong, nonatomic) MBProgressHUD *progressHud;
@end

@implementation A3FlashViewController
{
    A3FlashViewModeType _currentFlashViewMode;
    CGFloat _blackWhiteValue;
    CGFloat _screenBrightnessValue;
    CGFloat _deviceBrightnessBefore;
    CGFloat _flashBrightnessValue;
    BOOL _isTorchOn;
    BOOL _LEDInitialized;
    BOOL _isLEDAvailable;
    BOOL LEDOnInSTROBE_mode;
    BOOL _isEffectWorking;
    NSArray *_flashEffectList;
	NSTimer		*strobeTimer;
	NSInteger	effectLoopCount;
	NSInteger	_selectedEffectIndex;
    CGFloat		_strobeSpeedFactor;
    BOOL    _showAllMenu;
	BOOL	_isBeingDismiss;
	BOOL	_willResignActive;
}

#pragma mark

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

	[self requestAuthorizationForCamera];

    // Do any additional setup after loading the view from its nib.
	[self setNavigationBarHidden:YES];
	[self.navigationController.toolbar setHidden:YES];

	_isLEDAvailable = [A3UIDevice hasTorch];
    
    [self initializeCurrentFlashViewModeType];
    [self initializeBrightnessAndStorbeSpeedSliderRelated];
    [self initializeCurrentContentColorWithColorPickerView];
    [self initializeStrobeEffectList];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(flashScreenTapped:)];
    [_contentImageView addGestureRecognizer:tapGesture];
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(flashScreenTapped:)];
    [_colorPickerView addGestureRecognizer:tapGesture2];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];

	UIImage *image = [UIImage toolbarBackgroundImage];
	[_topToolBar setBackgroundImage:image forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
	[_sliderToolBar setBackgroundImage:image forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
	[_LEDBrightnessToolBar setBackgroundImage:image forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
	[_bottomToolBar setBackgroundImage:image forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
	[_bottomToolBar2 setBackgroundImage:image forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
}

- (void)requestAuthorizationForCamera {
	if (![A3UIDevice hasTorch]) return;
	if (IS_IOS7) return;
	AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
	if (authorizationStatus == AVAuthorizationStatusAuthorized) return;
	if (authorizationStatus == AVAuthorizationStatusNotDetermined) {
		[AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:nil];
		return;
	}
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Camera access denied", nil)
																			 message:NSLocalizedString(@"To turn on the LED requires camera access.", nil)
																	  preferredStyle:UIAlertControllerStyleAlert];
	[alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
														style:UIAlertActionStyleCancel
													  handler:NULL]];
	[alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(A3AppName_Settings, nil)
														style:UIAlertActionStyleDefault
													  handler:^(UIAlertAction *action) {
														  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
													  }]];
	[self presentViewController:alertController
					   animated:YES
					 completion:NULL];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

	FNLOG();
	if (_isBeingDismiss) return;

	_showAllMenu = YES;
	if (_currentFlashViewMode & A3FlashViewModeTypeLED) {
		if (![A3UIDevice canAccessCamera]) {
			_currentFlashViewMode ^= A3FlashViewModeTypeLED;
			[self requestAuthorizationForCamera];
		}
	}
	[self configureFlashViewMode:_currentFlashViewMode animation:NO];

	FNLOG(@"[[UIApplication sharedApplication] setIdleTimerDisabled:YES];");
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if (_currentFlashViewMode & A3FlashViewModeTypeLED) {
		if ([A3UIDevice canAccessCamera]) {
			_isTorchOn = YES;
		}
		[self showHUD];
		[self initializeLED];
	}

	if (_currentFlashViewMode & A3FlashViewModeTypeEffect) {
		[self startStrobeLightEffectForIndex:_selectedEffectIndex];
	}
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
	if ([self isMovingToParentViewController] || [self isBeingPresented]) {
		[self setupBannerViewForAdUnitID:AdMobAdUnitIDFlashlight keywords:nil gender:kGADGenderUnknown];
	}
	[self setupInstructionView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
    if(!IS_IPHONE) {
        [self.sliderControl setFrame:CGRectMake(self.sliderControl.frame.origin.x, self.sliderControl.frame.origin.y, screenBounds.size.width - 106, self.sliderControl.frame.size.height)];
        [self.flashBrightnessSlider setFrame:CGRectMake(self.flashBrightnessSlider.frame.origin.x, self.flashBrightnessSlider.frame.origin.y , screenBounds.size.width - 106, self.flashBrightnessSlider.frame.size.height)];
    }
    else {
        [self.sliderControl setFrame:CGRectMake(self.sliderControl.frame.origin.x, self.sliderControl.frame.origin.y, screenBounds.size.width - 98, self.sliderControl.frame.size.height)];
        [self.flashBrightnessSlider setFrame:CGRectMake(self.flashBrightnessSlider.frame.origin.x, self.flashBrightnessSlider.frame.origin.y , screenBounds.size.width - 98, self.flashBrightnessSlider.frame.size.height)];
    }
    
    if (_currentFlashViewMode & A3FlashViewModeTypeColor) {
        if (_showAllMenu) {
            CGFloat offset = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(_topToolBar.bounds) - CGRectGetHeight(_sliderControl.bounds) - CGRectGetHeight(_bottomToolBar.bounds) - CGRectGetHeight(_colorPickerView.bounds) - 20;
            _colorPickerTopConst.constant = offset / 2 + CGRectGetHeight(_topToolBar.bounds) + 10;
        }
        else {
            _colorPickerTopConst.constant = CGRectGetHeight(self.view.bounds);
        }
	} else {
		_colorPickerTopConst.constant = CGRectGetHeight(self.view.bounds);
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    UIScreen *mainScreen = [UIScreen mainScreen];
    mainScreen.brightness = _deviceBrightnessBefore;
	FNLOG(@"Restoring with original Screen Brightness = %f", _deviceBrightnessBefore);

    if (_isTorchOn) {
        [self setTorchOff];
    }
    
    [self saveUserDefaults];
    [self releaseHideMenuTimer];
    [self releaseStrobelight];
	[self removeObservers];
    
#if !TARGET_IPHONE_SIMULATOR
	if (_LEDSession) {
		[_LEDSession stopRunning];
		_LEDSession = nil;
		
		_LEDInitialized = NO;
	}
#endif
}

-(void)cleanUp {
	FNLOG(@"Restoring with original Screen Brightness = %f", _deviceBrightnessBefore);
	[UIScreen mainScreen].brightness = _deviceBrightnessBefore;

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self saveUserDefaults];
	[self removeObservers];
}

- (void)prepareClose {
	FNLOG(@"[[UIApplication sharedApplication] setIdleTimerDisabled: NO ];");
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];

	_isBeingDismiss = YES;
}

- (BOOL)resignFirstResponder {
	NSString *startingAppName = [[A3UserDefaults standardUserDefaults] objectForKey:kA3AppsStartingAppName];
	if ([startingAppName length] && ![startingAppName isEqualToString:A3AppName_Flashlight]) {
		[self.instructionViewController.view removeFromSuperview];
		self.instructionViewController = nil;
	}
	return [super resignFirstResponder];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidHide object:nil];
}

- (void)applicationWillResignActiveNotification:(NSNotification *)notification {
	_willResignActive = YES;
	[UIScreen mainScreen].brightness = _deviceBrightnessBefore;
	FNLOG(@"Restoring with original Screen Brightness = %f", _deviceBrightnessBefore);
    if (_isTorchOn) {
        [self setTorchOff];
    }
    
    [self releaseStrobelight];
    [self saveUserDefaults];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
	FNLOG();
	if (_willResignActive) {
		_deviceBrightnessBefore = [UIScreen mainScreen].brightness;
		_willResignActive = NO;
		FNLOG(@"Saving original Screen Brightness = %f", _deviceBrightnessBefore);
	}

	if (_isTorchOn) {
		if ([A3UIDevice canAccessCamera]) {
			[self setTorchOn];
			double delayInSeconds = 1.0;
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (delayInSeconds * NSEC_PER_SEC));
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
				[self setTorchOn];
			});
		} else {
			_isTorchOn = NO;
			_currentFlashViewMode = A3FlashViewModeTypeNone;
			[self configureFlashViewMode:_currentFlashViewMode animation:NO];
		}
	}

	if (_currentFlashViewMode & A3FlashViewModeTypeEffect) {
		[self startStrobeLightEffectForIndex:_selectedEffectIndex];
	}

	UIScreen *mainScreen = [UIScreen mainScreen];
	CGFloat offset = (_screenBrightnessValue / 100.0);
	mainScreen.brightness = offset;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

	_showAllMenu = YES;
	[self flashScreenTapped:nil];
}

- (void)mainMenuDidHide {
	if (_isBeingDismiss) return;

	FNLOG(@"[[UIApplication sharedApplication] setIdleTimerDisabled: YES ];");
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];

    if (IS_IPHONE && ([self.mm_drawerController openSide] == MMDrawerSideLeft)) {
        if (_isTorchOn) {
            [self setTorchOff];
        }
        [self releaseStrobelight];
        return;
    }
    
    if (_isTorchOn) {
        [self setTorchOn];
    }
    
    if (_currentFlashViewMode & A3FlashViewModeTypeEffect) {
        [self startStrobeLightEffectForIndex:_selectedEffectIndex];
    }

	UIScreen *mainScreen = [UIScreen mainScreen];
	CGFloat offset = (_screenBrightnessValue / 100.0);
	mainScreen.brightness = offset;
}

- (void)saveUserDefaults {
    [[A3UserDefaults standardUserDefaults] setObject:@(_blackWhiteValue) forKey:A3UserDefaultFlashBlackWhiteValue];
    [[A3UserDefaults standardUserDefaults] setObject:@(_flashBrightnessValue) forKey:A3UserDefaultFlashLEDBrightnessValue];
    [[A3UserDefaults standardUserDefaults] setObject:@(_screenBrightnessValue) forKey:A3UserDefaultFlashBrightnessValue];
    [[A3UserDefaults standardUserDefaults] setObject:@(_strobeSpeedFactor) forKey:A3UserDefaultFlashStrobeSpeedValue];
    [[A3UserDefaults standardUserDefaults] synchronize];
}

#pragma mark

- (void)initializeCurrentFlashViewModeType {
    NSNumber *flashViewMode = [[A3UserDefaults standardUserDefaults] objectForKey:A3UserDefaultFlashViewMode];
    if (!flashViewMode) {
        if (_isLEDAvailable) {
			if ([A3UIDevice canAccessCamera]) {
				_isTorchOn = YES;
				_currentFlashViewMode = A3FlashViewModeTypeLED;
			} else {
				_isTorchOn = NO;
				_currentFlashViewMode = A3FlashViewModeTypeNone;
			}
        }
        else {
            _currentFlashViewMode = A3FlashViewModeTypeNone;
        }
    }
    else {
        _currentFlashViewMode = [flashViewMode integerValue];
    }
    
    if (!_isLEDAvailable) {
        _bottomToolBar.hidden = YES;
        _bottomToolBar = _bottomToolBar2;
        _colorBarButton = _colorBarButton2;
        _effectBarButton = _effectBarButton2;
        _bottomToolBarBottomConst = _bottomToolBar2BottomConst;
    }
    else {
        _bottomToolBar2.hidden = YES;
    }
}

- (void)initializeBrightnessAndStorbeSpeedSliderRelated {
    _deviceBrightnessBefore = [[UIScreen mainScreen] brightness];
	FNLOG(@"Saving original Screen Brightness = %f", _deviceBrightnessBefore);

    NSNumber *blackWhite = [[A3UserDefaults standardUserDefaults] objectForKey:A3UserDefaultFlashBlackWhiteValue];
    _blackWhiteValue = !blackWhite ? 100.0 : [blackWhite floatValue];
    
    NSNumber *ledBrightness = [[A3UserDefaults standardUserDefaults] objectForKey:A3UserDefaultFlashLEDBrightnessValue];
    _flashBrightnessValue = !ledBrightness ? 0.5 : [ledBrightness floatValue];
    
    NSNumber *screenBrightness = [[A3UserDefaults standardUserDefaults] objectForKey:A3UserDefaultFlashBrightnessValue];
    if (!screenBrightness) {
        _screenBrightnessValue = _deviceBrightnessBefore * 100.0;
    }
    else {
        _screenBrightnessValue = [screenBrightness floatValue];
        UIScreen *mainScreen = [UIScreen mainScreen];
        CGFloat offset = (_screenBrightnessValue / 100.0);
        mainScreen.brightness = MAX(0.3, offset);
    }
    
    NSLog(@"start screen: %f", _screenBrightnessValue);
    
    NSNumber *strobeSpeedValue = [[A3UserDefaults standardUserDefaults] objectForKey:A3UserDefaultFlashStrobeSpeedValue];
    _strobeSpeedFactor = !strobeSpeedValue ? 0.0 : [strobeSpeedValue floatValue];
    
    if (_currentFlashViewMode == A3FlashViewModeTypeNone) {
        [self alphaSliderValueChanged:nil];
    }
    else if (_currentFlashViewMode == A3FlashViewModeTypeColor) {
        [self colorModeSliderValueChanged:nil];
    }
}

- (void)initializeCurrentContentColorWithColorPickerView {
    NSNumber *effectIndex = [[A3UserDefaults standardUserDefaults] objectForKey:A3UserDefaultFlashEffectIndex];
    _selectedEffectIndex = !effectIndex ? 2 : [effectIndex integerValue];
    
    _selectedColor = [NSKeyedUnarchiver unarchiveObjectWithData:[[A3UserDefaults standardUserDefaults] objectForKey:A3UserDefaultFlashSelectedColor]];
    if (!_selectedColor) {
        _selectedColor = [UIColor colorWithHue:1.0 saturation:1.0 brightness:1.0 alpha:1.0];
    }
    
    _colorPickerView.delegate = self;
    _colorPickerView.backgroundColor = [UIColor clearColor];
    _colorPickerView.color = _selectedColor;
    
    if (IS_IPAD) {
        _colorPickerHeightConst.constant = 510;
        _colorPickerWidthConst.constant = 510;
    }
    else {
        _colorPickerHeightConst.constant = IS_IPHONE35 ? 366 : 480;
    }
    
    _pickerTopSeparatorHeightConst.constant = IS_RETINA ? 0.5 : 1.0;
    _pickerSeparatorView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.15];
}

- (void)initializeStrobeEffectList {
    _flashEffectList = @[NSLocalizedString(@"SOS", @"SOS"),
                         NSLocalizedString(@"Strobe", @"Strobe"),
                         NSLocalizedString(@"Trippy", @"Trippy"),
                         NSLocalizedString(@"Police Car", @"Police Car"),
                         NSLocalizedString(@"Fire Truck", @"Fire Truck"),
                         NSLocalizedString(@"Caution Flare", @"Caution Flare"),
                         NSLocalizedString(@"Traffic Light", @"Traffic Light")];
}


- (void)showHUD {
    [self hideHUD];
    
//    self.progressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES withTouchableUnderneath:YES];
    self.progressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.progressHud.userInteractionEnabled = NO;
    self.progressHud.mode = MBProgressHUDModeCustomView;
    self.progressHud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:_isTorchOn ? @"f_flash_on" : @"f_flash_off"]];
	self.progressHud.labelText = _isTorchOn ? NSLocalizedString(@"LED On", @"LED On") : NSLocalizedString(@"LED Off", @"LED Off");
	self.progressHud.minShowTime = 3;
	self.progressHud.removeFromSuperViewOnHide = YES;
	__typeof(self) __weak weakSelf = self;
	self.progressHud.completionBlock = ^{
		weakSelf.progressHud = nil;
	};
    [self.progressHud hide:YES afterDelay:3];
}

- (void)hideHUD {
    if (self.progressHud) {
        [self.progressHud hide:YES];
        self.progressHud = nil;
    }
}

- (void)checkTorchOnStartIfNeeded {
    if (_isLEDAvailable && (_currentFlashViewMode & A3FlashViewModeTypeLED)) {
        [self LEDMenuButtonTouchUp:nil];
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
#pragma mark Instruction Related

static NSString *const A3V3InstructionDidShowForFlash = @"A3V3InstructionDidShowForFlash";

- (void)setupInstructionView
{
    if (![[A3UserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForFlash]) {
        [self showInstructionView:nil];
    }
}

- (IBAction)showInstructionView:(id)sender
{
	[[A3UserDefaults standardUserDefaults] setBool:YES forKey:A3V3InstructionDidShowForFlash];
	[[A3UserDefaults standardUserDefaults] synchronize];
    
    UIStoryboard *instructionStoryBoard = [UIStoryboard storyboardWithName:IS_IPHONE ? A3StoryboardInstruction_iPhone : A3StoryboardInstruction_iPad bundle:nil];
    _instructionViewController = [instructionStoryBoard instantiateViewControllerWithIdentifier:@"Flashlight"];
    self.instructionViewController.delegate = self;
    [self.navigationController.view addSubview:self.instructionViewController.view];
    self.instructionViewController.view.frame = self.navigationController.view.frame;
    self.instructionViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
    
    [self flashScreenTapped:nil];
}

- (void)dismissInstructionViewController:(UIView *)view
{
    [self.instructionViewController.view removeFromSuperview];
    self.instructionViewController = nil;
}

#pragma mark -

- (void)flashScreenTapped:(UITapGestureRecognizer *)gesture {
    _showAllMenu = !_showAllMenu;
    
    if (_showAllMenu) {
        _statusBarView.hidden = NO;
        [self configureFlashViewMode:_currentFlashViewMode animation:YES];
    }
    else {
        _statusBarView.hidden = YES;
        [UIView beginAnimations:A3AnimationIDKeyboardWillShow context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:7];
        [UIView setAnimationDuration:0.25];
        
        _topToolBarTopConst.constant = -65;
        _bottomToolBarBottomConst.constant = -(kBottomToolBarHeight + 5);
        _pickerViewBottomConst.constant = -(CGRectGetHeight(_pickerPanelView.bounds) + 88);
        _colorPickerTopConst.constant = CGRectGetHeight(self.view.bounds);
        
        [_topToolBar layoutIfNeeded];
        [_bottomToolBar layoutIfNeeded];
        [_pickerPanelView layoutIfNeeded];
        [_colorPickerView layoutIfNeeded];
        
        [UIView commitAnimations];
    }
}

#pragma mark - menu bar actions
- (IBAction)effectBarButtonAction:(id)sender {
    [self configureFlashViewMode:A3FlashViewModeTypeEffect animation:YES];
}

- (IBAction)sliderControlValueChanged:(UISlider *)sender {
    if (_currentFlashViewMode == A3FlashViewModeTypeNone) {
        [self alphaSliderValueChanged:sender];
    }
    else if (_currentFlashViewMode == A3FlashViewModeTypeLED) {
        if (_flashBrightnessSlider == sender) {
            [self flashBrightnessSliderValueChanged:sender];
        }
        else {
            [self alphaSliderValueChanged:sender];
        }
    }
    else if (_currentFlashViewMode & A3FlashViewModeTypeColor) {
        [self colorModeSliderValueChanged:sender];
    }
    else if (_currentFlashViewMode & A3FlashViewModeTypeEffect) {
        [self effectModeSliderValueChanged:sender];
    }
    
    [self startTimerToHideMenu];
}

- (IBAction)appsButtonTouchUp:(id)sender {
	[UIScreen mainScreen].brightness = _deviceBrightnessBefore;
	FNLOG(@"Restoring with original Screen Brightness = %f", _deviceBrightnessBefore);

	FNLOG(@"[[UIApplication sharedApplication] setIdleTimerDisabled: NO ];");
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];

    [self releaseStrobelight];
    if (_isTorchOn) {
        [self setTorchOff];
    }
    
    if (IS_IPHONE) {
		if ([[A3AppDelegate instance] isMainMenuStyleList]) {
			[[A3AppDelegate instance].drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:NULL];
		} else {
			UINavigationController *navigationController = [A3AppDelegate instance].currentMainNavigationController;
			[navigationController popViewControllerAnimated:YES];
			[navigationController setToolbarHidden:YES];
		}
	}
    else {
		[[[A3AppDelegate instance] rootViewController_iPad] toggleLeftMenuViewOnOff];
	}
}

- (IBAction)detailInfoButtonTouchUp:(id)sender {
    [self showInstructionView:nil];
}

#pragma mark Menu Status Change
- (IBAction)LEDMenuButtonTouchUp:(id)sender {
    if (!(_currentFlashViewMode & A3FlashViewModeTypeEffect)) {
        [self releaseStrobelight];
        _isEffectWorking = NO;
    }
    
    _currentFlashViewMode = _currentFlashViewMode ^ A3FlashViewModeTypeLED;

    if (_currentFlashViewMode & A3FlashViewModeTypeLED) {
		if ([A3UIDevice canAccessCamera]) {
			_isTorchOn = YES;
			[self showHUD];
			[self initializeLED];
			[self setTorchOn];
		} else {
			_currentFlashViewMode = _currentFlashViewMode ^ A3FlashViewModeTypeLED;
			[self requestAuthorizationForCamera];
		}
	}
    else {
        _isTorchOn = NO;
        [self showHUD];
        [self setTorchOff];
    }
    
    [self configureFlashViewMode:_currentFlashViewMode animation:YES];
}

- (IBAction)colorMenuButtonTouchUp:(id)sender {
    if (_currentFlashViewMode & A3FlashViewModeTypeEffect) {
        [self releaseStrobelight];
        _isEffectWorking = NO;
    }
    
    _currentFlashViewMode = _currentFlashViewMode ^ A3FlashViewModeTypeColor;
    if (_currentFlashViewMode & A3FlashViewModeTypeEffect) {
        _currentFlashViewMode = _currentFlashViewMode & (_currentFlashViewMode ^ A3FlashViewModeTypeEffect);
    }
    if (_currentFlashViewMode & A3FlashViewModeTypeLED) {
        [self setTorchOn];
    }
    
    [self configureFlashViewMode:_currentFlashViewMode animation:YES];
}

- (IBAction)effectsMenuButtonTouchUp:(id)sender {
    _currentFlashViewMode = _currentFlashViewMode ^ A3FlashViewModeTypeEffect;
    if (_currentFlashViewMode & A3FlashViewModeTypeColor) {
        _currentFlashViewMode = _currentFlashViewMode & (_currentFlashViewMode ^ A3FlashViewModeTypeColor);
    }
    
    if (!(_currentFlashViewMode & A3FlashViewModeTypeEffect)) {
        [self releaseStrobelight];
        [self configureFlashViewMode:_currentFlashViewMode animation:YES];
        
        if (_currentFlashViewMode == A3FlashViewModeTypeLED) {
            [self setTorchOn];
        }
        return;
    }
    
    if ((_currentFlashViewMode & A3FlashViewModeTypeEffect && !strobeTimer) || (_isEffectWorking && !strobeTimer) ) {
        [self configureFlashViewMode:_currentFlashViewMode animation:YES];
        [self startStrobeLightEffectForIndex:_selectedEffectIndex];
    }
}

- (void)alphaSliderValueChanged:(UISlider *)slider {
    if (slider) {
        _blackWhiteValue = slider.value;
    }
    
    CGFloat offset = (_blackWhiteValue / 100.0);
    _contentImageView.backgroundColor = [UIColor colorWithRed:offset green:offset blue:offset alpha:1.0];
    
    [self adjustToolBarColorToPreventVeryWhiteColor];
    
    NSLog(@"screen: %f", _screenBrightnessValue);
    NSLog(@"offset: %f", offset);
}

- (void)adjustToolBarColorToPreventVeryWhiteColor {
    CGFloat whiteOffset = 0.0, alphaOffset = 0.0;
    [_contentImageView.backgroundColor getWhite:&whiteOffset alpha:&alphaOffset];
    CGFloat offset = 0.6 - (whiteOffset/2.0);
    UIColor *adjustedColor = [UIColor colorWithRed:offset green:offset blue:offset alpha:0.7 - (whiteOffset/10.0)];

    _topToolBar.backgroundColor = adjustedColor;
    _sliderToolBar.backgroundColor = adjustedColor;
    _pickerPanelView.backgroundColor = adjustedColor;
    _colorPickerView.backgroundColor = _currentFlashViewMode & A3FlashViewModeTypeColor ? [UIColor clearColor] : adjustedColor;
    _bottomToolBar.backgroundColor = adjustedColor;
    _LEDBrightnessToolBar.backgroundColor = adjustedColor;
    
    
//    if (_currentFlashViewMode == A3FlashViewModeTypeLED) {
//        UIColor *adjustedColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.7];
//        _topToolBar.backgroundColor = adjustedColor;
//        _sliderToolBar.backgroundColor = adjustedColor;
//        _pickerPanelView.backgroundColor = adjustedColor;
//        _colorPickerView.backgroundColor = [UIColor clearColor];
//        _bottomToolBar.backgroundColor = adjustedColor;
//    }
//    else {
//        _topToolBar.backgroundColor = [UIColor clearColor];
//        _sliderToolBar.backgroundColor = [UIColor clearColor];
//        _pickerPanelView.backgroundColor = [UIColor clearColor];
//        _colorPickerView.backgroundColor = [UIColor clearColor];
//        _bottomToolBar.backgroundColor = [UIColor clearColor];
//    }
    
    
//    CGFloat offset = (_screenBrightnessValue / 100.0);
//    CGFloat whiteOffset = 0.0, alphaOffset = 0.0;
//    [_contentImageView.backgroundColor getWhite:&whiteOffset alpha:&alphaOffset];
//
//    if (offset > 0.6 && _currentFlashViewMode == A3FlashViewModeTypeNone) {
//        UIColor *adjustedColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.7 - fabs(1.0 - offset)];
//        _topToolBar.backgroundColor = adjustedColor;
//        _sliderToolBar.backgroundColor = adjustedColor;
//        _pickerPanelView.backgroundColor = adjustedColor;
//        _colorPickerView.backgroundColor = adjustedColor;
//        _bottomToolBar.backgroundColor = adjustedColor;
//    }
//    else if (whiteOffset > 0.6 && _currentFlashViewMode == A3FlashViewModeTypeColor) {
//        UIColor *adjustedColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.7 - fabs(1.0 - whiteOffset)];
//        _topToolBar.backgroundColor = adjustedColor;
//        _sliderToolBar.backgroundColor = adjustedColor;
//        _pickerPanelView.backgroundColor = adjustedColor;
//        _colorPickerView.backgroundColor = [UIColor clearColor];
//        _bottomToolBar.backgroundColor = adjustedColor;
//    }
//    else {
//        _topToolBar.backgroundColor = [UIColor clearColor];
//        _sliderToolBar.backgroundColor = [UIColor clearColor];
//        _pickerPanelView.backgroundColor = [UIColor clearColor];
//        _colorPickerView.backgroundColor = [UIColor clearColor];
//        _bottomToolBar.backgroundColor = [UIColor clearColor];
//    }
}

- (void)colorModeSliderValueChanged:(UISlider *)slider {
    if (slider) {
        _screenBrightnessValue = slider.value;
    }
    
    UIScreen *mainScreen = [UIScreen mainScreen];
    CGFloat offset = (_screenBrightnessValue / 100.0);
    mainScreen.brightness = MAX(0.3, offset);
    
    NSLog(@"screen: %f", _screenBrightnessValue);
    NSLog(@"offset: %f", offset);
}

- (void)flashBrightnessSliderValueChanged:(UISlider *)slider {
    if (slider) {
        _flashBrightnessValue = [slider value];
    }
    
    NSLog(@"flash: %f", _flashBrightnessValue);
    
    if(_isLEDAvailable && [A3UIDevice canAccessCamera]) {
        AVCaptureDevice *myTorch = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        [myTorch lockForConfiguration:nil];
        
        if (slider.value == 0.0) {
            [myTorch setTorchMode:AVCaptureTorchModeOff];
        } else {
            [myTorch setTorchModeOnWithLevel:_flashBrightnessValue error:nil];
        }
        
        [myTorch unlockForConfiguration];
    }
}

- (void)effectModeSliderValueChanged:(UISlider *)slider {
    _strobeSpeedFactor = [slider value];
}

- (void)startTimerToHideMenu {
    [self releaseHideMenuTimer];
    
    _hideMenuTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(hideMenuTimerFireMethod:) userInfo:nil repeats:NO];
}

- (void)hideMenuTimerFireMethod:(NSTimer *)timer {
    [self releaseHideMenuTimer];
    
    _showAllMenu = YES;
    [self flashScreenTapped:nil];
}

#pragma mark -

- (void)configureFlashViewMode:(A3FlashViewModeType)type animation:(BOOL)animate {
    _currentFlashViewMode = type;

	self.appsBarButton.enabled = !(IS_IPHONE && IS_LANDSCAPE);

    [[A3UserDefaults standardUserDefaults] setObject:@(_currentFlashViewMode) forKey:A3UserDefaultFlashViewMode];
    [[A3UserDefaults standardUserDefaults] synchronize];
    
    if (animate) {  // RESERVED?
        [self adjustConfigurationLayoutValueForFlashViewMode:_currentFlashViewMode];
    }
    else {
        [self adjustConfigurationLayoutValueForFlashViewMode:_currentFlashViewMode];
    }
    
    [self startTimerToHideMenu];
}

- (void)adjustConfigurationLayoutValueForFlashViewMode:(A3FlashViewModeType)type {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    _topToolBarTopConst.constant = 20;
    
    if (_currentFlashViewMode == A3FlashViewModeTypeNone) {
        [_sliderControl setMinimumValue:0.0];
        [_sliderControl setMaximumValue:100.0];
        [_sliderControl setValue:_blackWhiteValue];
        
        _bottomToolBarBottomConst.constant = 0;
        _pickerViewBottomConst.constant = -(CGRectGetHeight(_pickerPanelView.bounds) - kBottomToolBarHeight);
        _colorPickerTopConst.constant = CGRectGetHeight(self.view.bounds);
        _sliderToolBar.hidden = NO;
        _LEDBrightnessToolBar.hidden = YES;
        _effectPickerView.hidden = YES;
        _pickerPanelView.hidden = YES;
        _colorPickerView.hidden = YES;
        
        [_ledBarButton setImage:[[UIImage imageNamed:@"f_flash_off"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [_colorBarButton setImage:[[UIImage imageNamed:@"f_color_off"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [_effectBarButton setImage:[[UIImage imageNamed:@"f_effect_off"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];

        _screenBrightnessMinButton.image = [UIImage imageNamed:@"f_flash_black"];
        _screenBrightnessMaxButton.image = [UIImage imageNamed:@"f_flash_white"];

        [self alphaSliderValueChanged:nil];
        return;
    }

    [self adjustToolBarColorToPreventVeryWhiteColor];
    
    if (_currentFlashViewMode & A3FlashViewModeTypeLED) {
        [_ledBarButton setImage:[[UIImage imageNamed:@"f_flash_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [_sliderControl setMinimumValue:0.0];
        [_sliderControl setMaximumValue:100.0];
        [_sliderControl setValue:_blackWhiteValue];
        
        _flashBrightnessSlider.value = _flashBrightnessValue;
        _screenBrightnessMinButton.image = [UIImage imageNamed:@"f_flash_black"];
        _screenBrightnessMaxButton.image = [UIImage imageNamed:@"f_flash_white"];
        
        [self alphaSliderValueChanged:nil];
    }
    else {
        [_ledBarButton setImage:[[UIImage imageNamed:@"f_flash_off"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    }

    if (_currentFlashViewMode & A3FlashViewModeTypeColor) {
        [_colorBarButton setImage:[[UIImage imageNamed:@"f_color_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [_sliderControl setMinimumValue:0.0];
        [_sliderControl setMaximumValue:100.0];
        [_sliderControl setValue:_screenBrightnessValue];

        _screenBrightnessMinButton.image = [UIImage imageNamed:@"f_color_brightness_left"];
        _screenBrightnessMaxButton.image = [UIImage imageNamed:@"f_color_brightness_right"];
        
        if (IS_IPAD) {
            CGFloat offset = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(_topToolBar.bounds) - CGRectGetHeight(_sliderControl.bounds) - CGRectGetHeight(_bottomToolBar.bounds) - CGRectGetHeight(_colorPickerView.bounds) - 20;
            _colorPickerTopConst.constant = offset / 2 + CGRectGetHeight(_topToolBar.bounds) + 10;
        }
        else {
            _colorPickerTopConst.constant = 30;
        }
        _pickerViewBottomConst.constant = -(CGRectGetHeight(_pickerPanelView.bounds) - kBottomToolBarHeight);
        _pickerPanelView.hidden = YES;
        _colorPickerView.hidden = NO;
        _contentImageView.backgroundColor = _selectedColor;
        [self adjustToolBarColorToPreventVeryWhiteColor];
    }
    else {
        [_colorBarButton setImage:[[UIImage imageNamed:@"f_color_off"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        _colorPickerTopConst.constant = CGRectGetHeight(self.view.bounds);
    }

    if (_currentFlashViewMode & A3FlashViewModeTypeEffect) {
        [_effectBarButton setImage:[[UIImage imageNamed:@"f_effect_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        
        [_sliderControl setMinimumValue:-80.0];
        [_sliderControl setMaximumValue:80.0];
        [_sliderControl setValue:_strobeSpeedFactor];
        _screenBrightnessMinButton.image = [UIImage imageNamed:@"m_zoomout"];
        _screenBrightnessMaxButton.image = [UIImage imageNamed:@"m_zoomin"];
        
        [_effectPickerView selectRow:_selectedEffectIndex inComponent:0 animated:NO];
        
        _pickerViewBottomConst.constant = kBottomToolBarHeight;
        _effectPickerView.hidden = NO;
        _pickerPanelView.hidden = NO;
        _colorPickerView.hidden = YES;
    }
    else {
        [_effectBarButton setImage:[[UIImage imageNamed:@"f_effect_off"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        _effectPickerView.hidden = YES;
        _pickerPanelView.hidden = YES;
    }

    if (_currentFlashViewMode == A3FlashViewModeTypeLED) {
        _pickerViewBottomConst.constant = -(CGRectGetHeight(_pickerPanelView.bounds) - kBottomToolBarHeight);
        _LEDBrightnessToolBar.hidden = NO;
        _sliderToolBar.hidden = NO;
    }
    else {
        _LEDBrightnessToolBar.hidden = YES;
    }
    _bottomToolBarBottomConst.constant = 0;
}

#pragma mark - LED Related
- (void)setTorchOn {
	if (![A3UIDevice canAccessCamera]) {
		[self requestAuthorizationForCamera];
		return;
	}
	AVCaptureDevice *myTorch = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	[myTorch lockForConfiguration:nil];

	if (_flashBrightnessValue == 0.0) {
		[myTorch setTorchMode:AVCaptureTorchModeOff];
	} else {
		[myTorch setTorchMode:AVCaptureTorchModeOn];
		[myTorch setTorchModeOnWithLevel:_flashBrightnessValue error:nil];
	}

	[myTorch unlockForConfiguration];
}

- (void)setTorchOff {
	AVCaptureDevice *myTorch = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	[myTorch lockForConfiguration:nil];
	
	[myTorch setTorchMode:AVCaptureTorchModeOff];
	
	[myTorch unlockForConfiguration];
	
    if (_currentFlashViewMode & A3FlashViewModeTypeColor) {
        _contentImageView.backgroundColor = _selectedColor;
    }
}

- (void)toggleTorch {
#if !TARGET_IPHONE_SIMULATOR
	if (_LEDSession) {
		if (_isTorchOn) {
			[self setTorchOff];
		} else {
			[self setTorchOn];
		}
	}
#endif
}

- (void)initializeLED {
	if (!_LEDInitialized && _isLEDAvailable) {
		if (![A3UIDevice canAccessCamera]) {
			[self requestAuthorizationForCamera];
			return;
		}

		AVCaptureDevice *myTorch = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
		AVCaptureDeviceInput *flashInput = [AVCaptureDeviceInput deviceInputWithDevice:myTorch error: nil];
		AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
		
		AVCaptureSession *_session = [[AVCaptureSession alloc] init];
		_LEDSession = _session;
		
		[_LEDSession beginConfiguration];
		
		[myTorch lockForConfiguration:nil];
        
        if (!_isTorchOn || _flashBrightnessValue == 0.0) {
            [myTorch setTorchMode:AVCaptureTorchModeOff];
        } else {
			[myTorch setTorchMode:AVCaptureTorchModeOn];
            [myTorch setTorchModeOnWithLevel:_flashBrightnessValue error:nil];
        }
		
		[_LEDSession addInput:flashInput];
		[_LEDSession addOutput:output];
		
		[myTorch unlockForConfiguration];
		
		[_LEDSession commitConfiguration];
		[_LEDSession startRunning];
		_LEDInitialized = YES;
	}
}

- (void)releaseStrobelight
{
    effectLoopCount = 0;
    
    if (strobeTimer) {
        [strobeTimer invalidate];
        strobeTimer = nil;
    }
}

- (void)releaseHideMenuTimer {
    if (_hideMenuTimer) {
        [_hideMenuTimer invalidate];
        _hideMenuTimer = nil;
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
	double speedFactor = strobeLoop_SOS[effectLoopCount][0] - (_strobeSpeedFactor/100.0 * strobeLoop_SOS[effectLoopCount][0]);
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
	
	double speedFactor = strobeLoop_STROBE[effectLoopCount][0] - (_strobeSpeedFactor/100.0 * strobeLoop_STROBE[effectLoopCount][0]);
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
	
	double speedFactor = strobeLoop_TRIPPIN[effectLoopCount][0] - (_strobeSpeedFactor/100.0 * strobeLoop_TRIPPIN[effectLoopCount][0]);
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
	
	double speedFactor = strobeLoop_POLICECAR[effectLoopCount][0] - (_strobeSpeedFactor/100.0 * strobeLoop_POLICECAR[effectLoopCount][0]);
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
	
	double speedFactor = strobeLoop_FIRETRUCK[effectLoopCount][0] - (_strobeSpeedFactor/100.0 * strobeLoop_FIRETRUCK[effectLoopCount][0]);
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
	
	double speedFactor = strobeLoop_CAUTINFLARE[effectLoopCount][0] - (_strobeSpeedFactor/100.0 * strobeLoop_CAUTINFLARE[effectLoopCount][0]);
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
	
	double speedFactor = strobeLoop_TRAFFICLIGHT[effectLoopCount][0] - (_strobeSpeedFactor/100.0 * strobeLoop_TRAFFICLIGHT[effectLoopCount][0]);
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

#pragma mark - UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [_flashEffectList count];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:[_flashEffectList objectAtIndex:row]
                                                                     attributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    return attrString;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _selectedEffectIndex = row;
    [[A3UserDefaults standardUserDefaults] setObject:@(_selectedEffectIndex) forKey:A3UserDefaultFlashEffectIndex];
    [[A3UserDefaults standardUserDefaults] synchronize];
    
    [self startStrobeLightEffectForIndex:_selectedEffectIndex];
    [self startTimerToHideMenu];
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
}

#pragma mark - NPColorPickerViewDelegate
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)NPColorPickerView:(NPColorPickerView *)view selecting:(UIColor *)color {
    _contentImageView.backgroundColor = color;
    
    [self adjustToolBarColorToPreventVeryWhiteColor];
    [self releaseHideMenuTimer];
}

-(void)NPColorPickerView:(NPColorPickerView *)view didSelectColor:(UIColor *)color {
    _selectedColor = color;
    _contentImageView.backgroundColor = _selectedColor;
    
    [self adjustToolBarColorToPreventVeryWhiteColor];
    
    [[A3UserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_selectedColor] forKey:A3UserDefaultFlashSelectedColor];
    [[A3UserDefaults standardUserDefaults] synchronize];
    [self startTimerToHideMenu];
}

@end
