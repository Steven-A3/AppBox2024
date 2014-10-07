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

#define kBottomToolBarHeight        74

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
    
    _isLEDAvailable = [A3UIDevice hasTorch];
    
    [self initializeCurrentFlashViewModeType];
    [self initializeBrightnessAndStorbeSpeedSliderRelated];
    [self initializeCurrentContentColorWithColorPickerView];
    [self initializeStrobeEffectList];
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(flashScreenTapped:)];
    [_contentImageView addGestureRecognizer:tapGesture];
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(flashScreenTapped:)];
    [_colorPickerView addGestureRecognizer:tapGesture2];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3DrawerStateChanged object:nil];
    if (IS_IPAD) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
    }
    
    
    self.flashBrightnessMinButton.image = [[UIImage imageNamed:@"f_flash_black"] tintedImageWithColor:[UIColor grayColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self isMovingToParentViewController]) {
        [self configureFlashViewMode:_currentFlashViewMode animation:NO];

        if (_currentFlashViewMode & A3FlashViewModeTypeLED) {
            _isTorchOn = YES;
            [self showHUD];
            [self initializeLED];
            [self setTorchOn];
        }
        
        if (_currentFlashViewMode & A3FlashViewModeTypeEffect) {
            [self startStrobeLightEffectForIndex:_selectedEffectIndex];
        }
    
        [self setupInstructionView];
	}
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
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    UIScreen *mainScreen = [UIScreen mainScreen];
    mainScreen.brightness = _deviceBrightnessBefore;
    
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

-(void)dealloc {
    [self saveUserDefaults];
	[self removeObservers];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    if (IS_IPAD) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:A3DrawerStateChanged object:nil];
    }
}

- (void)applicationWillResignActiveNotification:(NSNotification *)notification {
    if (_isTorchOn) {
        [self setTorchOff];
    }
    
    [self releaseStrobelight];
    [self saveUserDefaults];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
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

- (void)mainMenuDidHide {
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
}

- (void)saveUserDefaults {
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
            _currentFlashViewMode = A3FlashViewModeTypeLED;
            _isTorchOn = YES;
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
        _selectedColor = [UIColor colorWithHue:1.0 saturation:0.0 brightness:1.0 alpha:1.0];
    }
    
    _colorPickerView.delegate = self;
    _colorPickerView.backgroundColor = [UIColor clearColor];
    _colorPickerView.color = _selectedColor;
    
    if (IS_IPAD) {
        _colorPickerHeightConst.constant = 960;
        _colorPickerWidthConst.constant = 640;
    }
    else {
        _colorPickerHeightConst.constant = IS_IPHONE35 ? 366 : 480;
    }
    
    _pickerTopSeparatorHeightConst.constant = IS_RETINA ? 0.5 : 1.0;
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
    
    self.progressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
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
    [self releaseStrobelight];
    if (_isTorchOn) {
        [self setTorchOff];
    }
    
    if (IS_IPHONE) {
		[[self mm_drawerController] toggleDrawerSide:MMDrawerSideLeft animated:YES completion:NULL];
	}
    else {
		[[[A3AppDelegate instance] rootViewController] toggleLeftMenuViewOnOff];
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
    
    if (_currentFlashViewMode == A3FlashViewModeTypeColor) {
        _currentFlashViewMode = A3FlashViewModeTypeLED;
    }
    else {
        _currentFlashViewMode = _currentFlashViewMode ^ A3FlashViewModeTypeLED;
    }

    if (_currentFlashViewMode & A3FlashViewModeTypeLED) {
        _isTorchOn = YES;
        [self showHUD];
        [self initializeLED];
        [self setTorchOn];
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
    
    [self configureFlashViewMode:_currentFlashViewMode animation:YES];
    
    if (!(_currentFlashViewMode & A3FlashViewModeTypeEffect)) {
        [self releaseStrobelight];
        _contentImageView.backgroundColor = _selectedColor;
        if (_currentFlashViewMode == A3FlashViewModeTypeLED) {
            [self setTorchOn];
        }
        return;
    }
    if ((_currentFlashViewMode & A3FlashViewModeTypeEffect && !strobeTimer) || (_isEffectWorking && !strobeTimer) ) {
        [self startStrobeLightEffectForIndex:_selectedEffectIndex];
    }
}

- (void)alphaSliderValueChanged:(UISlider *)slider {
    if (slider) {
        _screenBrightnessValue = slider.value;
    }
    
    CGFloat offset = (_screenBrightnessValue / 100.0);
    UIScreen *mainScreen = [UIScreen mainScreen];
    
    mainScreen.brightness = MAX(0.3, offset);
    if (!_isTorchOn) {
        _contentImageView.backgroundColor = [UIColor colorWithRed:offset green:offset blue:offset alpha:1.0];
    }
    
    [self adjustToolBarColorToPreventVeryWhiteColor];
    
    NSLog(@"screen: %f", _screenBrightnessValue);
    NSLog(@"offset: %f", offset);
}

- (void)adjustToolBarColorToPreventVeryWhiteColor {
    CGFloat offset = (_screenBrightnessValue / 100.0);
    
    if (offset > 0.6 && _currentFlashViewMode == A3FlashViewModeTypeNone) {
        UIColor *adjustedColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.7 - fabs(1.0 - offset)];
        _topToolBar.backgroundColor = adjustedColor;
        _sliderToolBar.backgroundColor = adjustedColor;
        _pickerPanelView.backgroundColor = adjustedColor;
        _colorPickerView.backgroundColor = adjustedColor;
        _bottomToolBar.backgroundColor = adjustedColor;
    }
    else {
        _topToolBar.backgroundColor = [UIColor clearColor];
        _sliderToolBar.backgroundColor = [UIColor clearColor];
        _pickerPanelView.backgroundColor = [UIColor clearColor];
        _colorPickerView.backgroundColor = [UIColor clearColor];
        _bottomToolBar.backgroundColor = [UIColor clearColor];
    }
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
    
    [_sliderControl setMinimumValue:0.0];
    [_sliderControl setMaximumValue:100.0];
    [_sliderControl setValue:_screenBrightnessValue];
    
    if (_currentFlashViewMode == A3FlashViewModeTypeNone) {
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
        [self alphaSliderValueChanged:nil];
        return;
    }

    [self adjustToolBarColorToPreventVeryWhiteColor];
    
    if (_currentFlashViewMode & A3FlashViewModeTypeLED) {
        [_ledBarButton setImage:[[UIImage imageNamed:@"f_flash_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        _flashBrightnessSlider.value = _flashBrightnessValue;
    }
    else {
        [_ledBarButton setImage:[[UIImage imageNamed:@"f_flash_off"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    }


    if (_currentFlashViewMode & A3FlashViewModeTypeColor) {
        [_colorBarButton setImage:[[UIImage imageNamed:@"f_color_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [_sliderControl setMinimumValue:0.0];
        [_sliderControl setMaximumValue:100.0];
        [_sliderControl setValue:_screenBrightnessValue];
        
        if (IS_IPAD) {
            _colorPickerTopConst.constant = 5;
        }
        else {
            _colorPickerTopConst.constant = 30;
        }
        _pickerViewBottomConst.constant = -(CGRectGetHeight(_pickerPanelView.bounds) - kBottomToolBarHeight);
        _pickerPanelView.hidden = YES;
        _colorPickerView.hidden = NO;
        _contentImageView.backgroundColor = _selectedColor;
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
    if (_flashBrightnessValue == 0.0) {
        [myTorch setTorchMode:AVCaptureTorchModeOff];
    } else {
        [myTorch setTorchModeOnWithLevel:_flashBrightnessValue error:nil];
    }
	
	[myTorch unlockForConfiguration];

    if (_currentFlashViewMode == A3FlashViewModeTypeLED) {
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
	
    if (_currentFlashViewMode & A3FlashViewModeTypeColor) {
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
        
        if (!_isTorchOn || _flashBrightnessValue == 0.0) {
            [myTorch setTorchMode:AVCaptureTorchModeOff];
            [myTorch setTorchMode:AVCaptureTorchModeOff];
            [myTorch setFlashMode:AVCaptureFlashModeOff];
        } else {
            [myTorch setTorchModeOnWithLevel:_flashBrightnessValue error:nil];
            [myTorch setTorchMode:AVCaptureTorchModeOn];
            [myTorch setFlashMode:AVCaptureFlashModeOn];
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
    [self releaseHideMenuTimer];
}

-(void)NPColorPickerView:(NPColorPickerView *)view didSelectColor:(UIColor *)color {
    _selectedColor = color;
    _contentImageView.backgroundColor = _selectedColor;
    
    [[A3UserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_selectedColor] forKey:A3UserDefaultFlashSelectedColor];
    [[A3UserDefaults standardUserDefaults] synchronize];
    [self startTimerToHideMenu];
}

@end
