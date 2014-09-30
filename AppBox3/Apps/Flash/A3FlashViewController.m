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

#define kBottomToolBarHeight        74

typedef NS_ENUM(NSUInteger, A3FlashViewModeType) {
    A3FlashViewModeTypeLED = 0,
    A3FlashViewModeTypeColor,
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
NSString *const A3UserDefaultFlashLEDBrightnessValue = @"A3UserDefaultFlashLEDBrightnessValue";
NSString *const A3UserDefaultFlashEffectIndex = @"A3UserDefaultFlashEffectIndex";
NSString *const cellID = @"flashEffectID";

@interface A3FlashViewController () <UIAlertViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, NPColorPickerViewDelegate, A3InstructionViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIToolbar *topToolBar;
@property (weak, nonatomic) IBOutlet UIToolbar *sliderToolBar;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolBar;
@property (weak, nonatomic) IBOutlet UIToolbar *LEDBrightnessToolBar;
@property (weak, nonatomic) IBOutlet UIView *pickerPanelView;
@property (weak, nonatomic) IBOutlet NPColorPickerView *colorPickerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topToolBarTopConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sliderToolBarBottomConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomToolBarBottomConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pickerViewBottomConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorPickerHeightConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *flashBrightnessSliderBottomConst;

@property (weak, nonatomic) IBOutlet UISlider *sliderControl;
@property (weak, nonatomic) IBOutlet UISlider *flashBrightnessSlider;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorPickerTopConst;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *ledBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *colorBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *effectBarButton;
@property (weak, nonatomic) IBOutlet UIPickerView *effectPickerView;

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
@end

@implementation A3FlashViewController
{
    A3FlashViewModeType _currentFlashViewMode;
    CGFloat _screenBrightnessValue;
    CGFloat _deviceBrightnessBefore;
    CGFloat _effectSpeedValue;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [self checkTorchOnStartIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self isMovingToParentViewController]) {
        [self configureFlashViewMode:_currentFlashViewMode animation:NO];
        [_contentImageView setBackgroundColor:_selectedColor];
        
        [self setupInstructionView];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self saveUserDefaults];
    [self releaseHideMenuTimer];
    [self releaseStrobelight];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
#if !TARGET_IPHONE_SIMULATOR
	if (_LEDSession) {
		[_LEDSession stopRunning];
		_LEDSession = nil;
		
		_LEDInitialized = NO;
	}
#endif
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [self saveUserDefaults];
}

- (void)saveUserDefaults {
    [[NSUserDefaults standardUserDefaults] setObject:@(_flashBrightnessValue) forKey:A3UserDefaultFlashLEDBrightnessValue];
    [[NSUserDefaults standardUserDefaults] setObject:@(_screenBrightnessValue) forKey:A3UserDefaultFlashBrightnessValue];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark

- (void)initializeStatus
{
    _currentFlashViewMode = [[NSUserDefaults standardUserDefaults] integerForKey:A3UserDefaultFlashViewMode];
    _deviceBrightnessBefore = [[UIScreen mainScreen] brightness];
    
    NSNumber *ledBrightness = [[NSUserDefaults standardUserDefaults] objectForKey:A3UserDefaultFlashLEDBrightnessValue];
    _flashBrightnessValue = !ledBrightness ? 1.0 : [ledBrightness floatValue];
    NSNumber *screenBrightness = [[NSUserDefaults standardUserDefaults] objectForKey:A3UserDefaultFlashBrightnessValue];
    _screenBrightnessValue = !screenBrightness ? _deviceBrightnessBefore : [screenBrightness floatValue];
    NSNumber *effectIndex = [[NSUserDefaults standardUserDefaults] objectForKey:A3UserDefaultFlashEffectIndex];
    _selectedEffectIndex = !effectIndex ? 2 : [effectIndex integerValue];
    
    _selectedColor = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:A3UserDefaultFlashSelectedColor]];
    if (!_selectedColor) {
        _selectedColor = [UIColor blackColor];
    }
    
    _isLEDAvailable = [A3UIDevice hasTorch];
    
    _colorPickerView.delegate = self;
    _colorPickerView.backgroundColor = [UIColor clearColor];
    _colorPickerView.color = _selectedColor;
    _colorPickerHeightConst.constant = IS_IPHONE35 ? 390 : 480;
    
    _flashEffectList = @[NSLocalizedString(@"SOS", @"SOS"),
                         NSLocalizedString(@"Strobe", @"Strobe"),
                         NSLocalizedString(@"Trippy", @"Trippy"),
                         NSLocalizedString(@"Police Car", @"Police Car"),
                         NSLocalizedString(@"Fire Truck", @"Fire Truck"),
                         NSLocalizedString(@"Caution Flare", @"Caution Flare"),
                         NSLocalizedString(@"Traffic Light", @"Traffic Light")];
}

- (void)checkTorchOnStartIfNeeded {
    if (_isLEDAvailable) {
        [self ledTorchONOFF];
    }
    else {
        _ledBarButton.enabled = NO;
        [_ledBarButton setImage:[UIImage imageNamed:@"f_flash_off"]];
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
        _sliderToolBarBottomConst.constant = kBottomToolBarHeight;
        [self configureFlashViewMode:_currentFlashViewMode animation:YES];
    }
    else {
        
        [UIView beginAnimations:A3AnimationIDKeyboardWillShow context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:7];
        [UIView setAnimationDuration:0.25];
        
        _topToolBarTopConst.constant = -65;
        _sliderToolBarBottomConst.constant = -44;
        _flashBrightnessSliderBottomConst.constant = -44;
        _bottomToolBarBottomConst.constant = -kBottomToolBarHeight;
        _pickerViewBottomConst.constant = -CGRectGetHeight(_pickerPanelView.bounds);
        _colorPickerTopConst.constant = CGRectGetHeight(self.view.bounds);
        
        [_topToolBar layoutIfNeeded];
        [_sliderToolBar layoutIfNeeded];
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
    
    switch (_currentFlashViewMode) {
        case A3FlashViewModeTypeLED:
        case A3FlashViewModeTypeColor:
        {
            if (_flashBrightnessSlider == sender) {
                [self flashBrightnessSliderValueChanged:sender];
            }
            else {
                [self colorModeSliderValueChanged:sender];
            }
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

- (IBAction)appsButtonTouchUp:(id)sender {
    [self releaseStrobelight];
    
    if (IS_IPHONE) {
		[[self mm_drawerController] toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
	} else {
		[[[A3AppDelegate instance] rootViewController] toggleLeftMenuViewOnOff];
	}
}

- (IBAction)detailInfoButtonTouchUp:(id)sender {
    [self showInstructionView:nil];
}

- (void)ledTorchONOFF {
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

#pragma mark Menu Status Change
- (IBAction)LEDMenuButtonTouchUp:(id)sender {
    [self releaseStrobelight];
    _isEffectWorking = NO;
    [self configureFlashViewMode:A3FlashViewModeTypeLED animation:YES];
    [self ledTorchONOFF];
}

- (IBAction)colorMenuButtonTouchUp:(id)sender {
    [self releaseStrobelight];
    _isEffectWorking = NO;
    [self configureFlashViewMode:A3FlashViewModeTypeColor animation:YES];
}

- (IBAction)effectsMenuButtonTouchUp:(id)sender {
    if ((_currentFlashViewMode == A3FlashViewModeTypeEffect && !strobeTimer) || (_isEffectWorking && !strobeTimer) ) {
        [self startStrobeLightEffectForIndex:_selectedEffectIndex];
    }
    else {
        [self releaseStrobelight];
        _contentImageView.backgroundColor = _selectedColor;
    }
    
    [self configureFlashViewMode:A3FlashViewModeTypeEffect animation:YES];
}

- (void)colorModeSliderValueChanged:(UISlider *)slider {
    _screenBrightnessValue = (slider.maximumValue - slider.value);
    NSInteger brightnessIndex = floor(_screenBrightnessValue / (slider.maximumValue / 25.0));
    UIScreen *mainScreen = [UIScreen mainScreen];
    [mainScreen setBrightness:1.0 - (brightnessIndex / 25.0)];
}

- (void)flashBrightnessSliderValueChanged:(UISlider *)slider {
    _flashBrightnessValue = [slider value];
    if(_isLEDAvailable == YES) {
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
    strobeSpeedFactor = [slider value];
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
    [[NSUserDefaults standardUserDefaults] setInteger:_currentFlashViewMode forKey:A3UserDefaultFlashViewMode];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (animate) {  // RESERVED?
        [self adjustConfigurationLayoutValueForFlashViewMode:_currentFlashViewMode];
    }
    else {
        [self adjustConfigurationLayoutValueForFlashViewMode:_currentFlashViewMode];
    }
    
    [self startTimerToHideMenu];
}

- (void)adjustConfigurationLayoutValueForFlashViewMode:(A3FlashViewModeType)type {
    _currentFlashViewMode = type;
    if ((_currentFlashViewMode != A3FlashViewModeTypeLED) && !_isEffectWorking) {
        [self setTorchOff];
    }
    
    _topToolBarTopConst.constant = 20;
    
    switch (_currentFlashViewMode) {
        case A3FlashViewModeTypeLED:
        {
            _ledBarButton.image = [UIImage imageNamed:@"f_flash_on"];
            _colorBarButton.image = [UIImage imageNamed:@"f_color_off"];
            _effectBarButton.image = [UIImage imageNamed:@"f_effect_off"];
            
            _flashBrightnessSlider.value = _flashBrightnessValue;
            _LEDBrightnessToolBar.hidden = NO;
            
            _pickerViewBottomConst.constant = -162;
            _colorPickerTopConst.constant = CGRectGetHeight(self.view.bounds);
            _sliderToolBarBottomConst.constant = kBottomToolBarHeight;
            _bottomToolBarBottomConst.constant = 0;
            _flashBrightnessSliderBottomConst.constant = 74 + 44;
        }
            break;
            
        case A3FlashViewModeTypeColor:
        {
            [_sliderControl setMinimumValue:0.0];
            [_sliderControl setMaximumValue:100.0];
            [_sliderControl setValue:_sliderControl.maximumValue - _screenBrightnessValue];
            
            _contentImageView.backgroundColor = _selectedColor;
            _sliderToolBarBottomConst.constant = kBottomToolBarHeight;
            _pickerViewBottomConst.constant = -162;
            _bottomToolBarBottomConst.constant = 0;
            if (IS_IPAD) {
                _colorPickerTopConst.constant = 74;
            }
            else {
                _colorPickerTopConst.constant = 30;
            }
            _flashBrightnessSliderBottomConst.constant = -44;

            _ledBarButton.image = [UIImage imageNamed:@"f_flash_off"];
            _colorBarButton.image = [UIImage imageNamed:@"f_color_on"];
            _effectBarButton.image = [UIImage imageNamed:@"f_effect_off"];
            
            _LEDBrightnessToolBar.hidden = YES;
        }
            break;

        case A3FlashViewModeTypeEffect:
        {
            [_sliderControl setMinimumValue:-80.0];
            [_sliderControl setMaximumValue:80.0];
            [_sliderControl setValue:0.0];
            
            [_effectPickerView selectRow:_selectedEffectIndex inComponent:0 animated:NO];
            
            _sliderToolBarBottomConst.constant = kBottomToolBarHeight + 162;
            _pickerViewBottomConst.constant = kBottomToolBarHeight;
            _bottomToolBarBottomConst.constant = 0;
            _colorPickerTopConst.constant = CGRectGetHeight(self.view.bounds);
            _flashBrightnessSliderBottomConst.constant = -44;
            
            _ledBarButton.image = [UIImage imageNamed:@"f_flash_off"];
            _colorBarButton.image = [UIImage imageNamed:@"f_color_off"];
            _effectBarButton.image = [UIImage imageNamed:@"f_effect_on"];
            
            _LEDBrightnessToolBar.hidden = YES;
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - LED Related
- (void)setTorchOn {
    _isTorchOn = YES;
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
    _isTorchOn = NO;
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
		} else {
			[self setTorchOn];
		}
	}
#endif
}

- (void)initializeLED {
	if (!_LEDInitialized && _isLEDAvailable) {
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
        [self ledTorchONOFF];
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
    [[NSUserDefaults standardUserDefaults] setObject:@(_selectedEffectIndex) forKey:A3UserDefaultFlashEffectIndex];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
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
}

#pragma mark - NPColorPickerViewDelegate
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)NPColorPickerView:(NPColorPickerView *)view selecting:(UIColor *)color {
    _contentImageView.backgroundColor = color;
}

-(void)NPColorPickerView:(NPColorPickerView *)view didSelectColor:(UIColor *)color {
    _selectedColor = color;
    _contentImageView.backgroundColor = _selectedColor;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_selectedColor] forKey:A3UserDefaultFlashSelectedColor];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
