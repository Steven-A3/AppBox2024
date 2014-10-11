//
//  A3RandomViewController.m
//  AppBox3
//
//  Created by kimjeonghwan on 9/24/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3RandomViewController.h"
#import <AVFoundation/AVAudioPlayer.h>
#import "UIViewController+A3Addition.h"
#import <CoreMotion/CoreMotion.h>
#import "A3AppDelegate+appearance.h"
#import "A3DefaultColorDefines.h"
#import "A3UserDefaults.h"

#define kAccelerometerFrequency			25 //Hz
#define kFilteringFactorForErase		0.1
#define kMinEraseInterval				0.5
#define kEraseAccelerationThreshold		2.0

const NSInteger MINCOLUMN = 0;
const NSInteger MAXCOLUMN = 1;

NSString *const A3RandomLastValueKey = @"A3RandomLastValueKey";

@interface A3RandomViewController () <UIAccelerometerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIScrollViewDelegate>

- (IBAction)randomButtonTouchUp:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *resultPanelView;
@property (weak, nonatomic) IBOutlet UIView *controlPanelView;
@property (weak, nonatomic) IBOutlet UILabel *resultPrintLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *limitNumberPickerView;
@property (weak, nonatomic) IBOutlet UIButton *generatorButton;
@property (weak, nonatomic) IBOutlet UILabel *orShakeLabel;

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *controlPanelViewHeightConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *limitPickerViewSeparatorWidthConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *limitPickerViewSeparatorTopHeightConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *limitPickerViewSeparatorBottomHeightConst;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *generateButtonWidthConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *generateButtonHeightConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *resultViewTopConst;

@end

@implementation A3RandomViewController
{
	NSArray *arrayOfInputs;
	
	UIView *currentInputIndicator;
	int currentInput;
	NSTimer *animationTimer;
    
	UIAccelerationValue	myAccelerometer[3];
	CFTimeInterval		lastTime;
    
    AVAudioPlayer *audioPlayer;
	
	NSTimer *randomNumberTimer;
	double	numGen;
	int		numRepeat;
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
    self.title = NSLocalizedString(@"Random", @"Random");
    
	[self makeBackButtonEmptyArrow];
	[self leftBarButtonAppsButton];

    [_generatorButton setTitle:NSLocalizedString(@"Tap", nil) forState:UIControlStateNormal];
    _orShakeLabel.text = NSLocalizedString(@"or Shake!", nil);
    
    _resultPanelView.backgroundColor = COLOR_HEADERVIEW_BG;
    [_limitNumberPickerView selectRow:1 inComponent:MINCOLUMN animated:YES];
    [_limitNumberPickerView selectRow:100 inComponent:MAXCOLUMN animated:YES];
    _resultPrintLabel.adjustsFontSizeToFitWidth = YES;
    _resultPrintLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-UltraLightP2" size:80];

	NSNumber *lastResult = [[A3UserDefaults standardUserDefaults] objectForKey:A3RandomLastValueKey];
	if (lastResult) {
		_resultPrintLabel.text = [NSString stringWithFormat:@"%ld", [lastResult longValue]];
	}

    _limitPickerViewSeparatorWidthConst.constant =IS_RETINA ? 0.5 : 1.0;
    _limitPickerViewSeparatorTopHeightConst.constant =IS_RETINA ? 0.5 : 1.0;
    _limitPickerViewSeparatorBottomHeightConst.constant =IS_RETINA ? 0.5 : 1.0;
    [_generatorButton setTitleColor:[A3AppDelegate instance].themeColor forState:UIControlStateNormal];
    
    _controlPanelView.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1.0];
    _controlPanelViewHeightConst.constant = 103;
    
    if (IS_IPAD) {
        _generateButtonWidthConst.constant = 111;
        _generateButtonHeightConst.constant = 111;
        _generatorButton.titleLabel.font = [UIFont systemFontOfSize:22];
        _orShakeLabel.font = [UIFont systemFontOfSize:22];
        _controlPanelViewHeightConst.constant = 226;
        _resultPrintLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-UltraLightP2" size:152.0];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setupMotionManager)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(releaseMotionManager)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupMotionManager];
    if (self.isMovingToParentViewController) {
        _generatorButton.layer.cornerRadius = CGRectGetHeight(_generatorButton.bounds) / 2.0;
        _generatorButton.layer.borderColor = [[A3AppDelegate instance].themeColor CGColor];
        _generatorButton.layer.borderWidth = 1.5;
        _generatorButton.backgroundColor = [UIColor whiteColor];

        _resultViewTopConst.constant = CGRectGetHeight(self.navigationController.navigationBar.bounds) + 20;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self releaseMotionManager];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    [self removeObserver];
    if (randomNumberTimer && [randomNumberTimer isValid]) {
        [randomNumberTimer invalidate];
        randomNumberTimer = nil;
    }
}

- (void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)setNavigationBarHidden:(BOOL)hidden {
	[self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
	[self.navigationController.navigationBar setShadowImage:nil];
    
	[self.navigationController setNavigationBarHidden:hidden];
}

#pragma mark - accelerometer Related
- (void)setupMotionManager {
    if (_motionManager) {
        return;
    }
    
    _motionManager = [[CMMotionManager alloc] init];
    if (!_motionManager.isAccelerometerAvailable) {
        return;
    }
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    _motionManager.accelerometerUpdateInterval = (1.0 / kAccelerometerFrequency);
    [_motionManager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        UIAccelerationValue length,
        x,
        y,
        z;
        
        //Use a basic high-pass filter to remove the influence of the gravity
        myAccelerometer[0] = accelerometerData.acceleration.x * kFilteringFactorForErase + myAccelerometer[0] * (1.0 - kFilteringFactorForErase);
        myAccelerometer[1] = accelerometerData.acceleration.y * kFilteringFactorForErase + myAccelerometer[1] * (1.0 - kFilteringFactorForErase);
        myAccelerometer[2] = accelerometerData.acceleration.z * kFilteringFactorForErase + myAccelerometer[2] * (1.0 - kFilteringFactorForErase);
        // Compute values for the three axes of the acceleromater
        x = accelerometerData.acceleration.x - myAccelerometer[0];
        y = accelerometerData.acceleration.y - myAccelerometer[0];
        z = accelerometerData.acceleration.z - myAccelerometer[0];
        
        //Compute the intensity of the current acceleration
        length = sqrt(x * x + y * y + z * z);
        // If above a given threshold, play the erase sounds and erase the drawing view
        if((length >= kEraseAccelerationThreshold) && (CFAbsoluteTimeGetCurrent() > lastTime + kMinEraseInterval)) {
            
            // Reset Value to zero
            dispatch_async(dispatch_get_main_queue(), ^{
                [self randomButtonTouchUp:nil];
                lastTime = CFAbsoluteTimeGetCurrent();
            });
        }
    }];
}

- (void)releaseMotionManager {
    if (!_motionManager) {
        return;
    }
    
    [_motionManager stopAccelerometerUpdates];
    _motionManager = nil;
}

#pragma mark - 

- (IBAction)randomButtonTouchUp:(id)sender {
    if (!audioPlayer) {
        NSString *wavPath = [[NSBundle mainBundle] pathForResource:@"Erase" ofType:@"caf"];
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:wavPath] error:NULL];
    }
    [audioPlayer play];
	
	numGen = 0.0;
	_generatorButton.enabled = NO;
    _limitNumberPickerView.userInteractionEnabled = NO;
//    [self setNavigationBarHidden:YES];
    
	NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:0.1];
	randomNumberTimer = [[NSTimer alloc] initWithFireDate:fireDate
                                                 interval:0.1
                                                   target:self
                                                 selector:@selector(setRandomNumber:)
                                                 userInfo:nil
                                                  repeats:YES];
	
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	[runLoop addTimer:randomNumberTimer forMode:NSDefaultRunLoopMode];
	
	numRepeat = arc4random() % 3 + 8;
}


// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 9999;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%ld", (long)row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSInteger maxValue = [pickerView selectedRowInComponent:1];
    NSInteger minValue = [pickerView selectedRowInComponent:0];
    if (minValue > maxValue) {
        [pickerView selectRow:minValue inComponent:MAXCOLUMN animated:YES];
        [pickerView selectRow:maxValue inComponent:MINCOLUMN animated:YES];
    }
}

- (void)setRandomNumber:(NSTimer *)timer {
	numGen = numGen + 1.0;
	if (numGen > numRepeat) {
		[randomNumberTimer invalidate];

		randomNumberTimer = nil;
		_generatorButton.enabled = YES;
        _limitNumberPickerView.userInteractionEnabled = YES;
//        [self setNavigationBarHidden:NO];

		return;
	}
    
	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	[nf setNumberStyle:NSNumberFormatterDecimalStyle];
	
	NSInteger minNumber = [_limitNumberPickerView selectedRowInComponent:MINCOLUMN];
	NSInteger maxNumber = [_limitNumberPickerView selectedRowInComponent:MAXCOLUMN];
	
    //	srand(time(NULL));
	NSInteger	newNum = arc4random() % (maxNumber - minNumber + 1) + minNumber;
    _resultPrintLabel.text = [NSString stringWithFormat:@"%ld", (long)newNum];

	[[A3UserDefaults standardUserDefaults] setObject:@(newNum) forKey:A3RandomLastValueKey];
	[[A3UserDefaults standardUserDefaults] synchronize];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
}

@end
