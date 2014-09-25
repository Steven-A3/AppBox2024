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

#define kAccelerometerFrequency			25 //Hz
#define kFilteringFactorForErase		0.1
#define kMinEraseInterval				0.5
#define kEraseAccelerationThreshold		2.0

const NSInteger MINCOLUMN = 0;
const NSInteger MAXCOLUMN = 1;

@interface A3RandomViewController () <UIAccelerometerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property (strong, nonatomic) CMMotionManager *motionManager;
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
    [_limitNumberPickerView selectRow:1 inComponent:MINCOLUMN animated:YES];
    [_limitNumberPickerView selectRow:100 inComponent:MAXCOLUMN animated:YES];
    
    [self setupMotionManager];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupMotionManager];
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
            [self randomButtonTouchUp:nil];
            lastTime = CFAbsoluteTimeGetCurrent();
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(releaseMotionManager)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)releaseMotionManager {
    if (!_motionManager) {
        return;
    }
    
    [_motionManager stopAccelerometerUpdates];
    _motionManager = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
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
        
		return;
	}
    
	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	[nf setNumberStyle:NSNumberFormatterDecimalStyle];
	
	NSInteger minNumber = [_limitNumberPickerView selectedRowInComponent:MINCOLUMN];
	NSInteger maxNumber = [_limitNumberPickerView selectedRowInComponent:MAXCOLUMN];
	
    //	srand(time(NULL));
	NSInteger	newNum = arc4random() % (maxNumber - minNumber + 1) + minNumber;
    _resultPrintLabel.text = [NSString stringWithFormat:@"%ld", (long)newNum];
}

@end
