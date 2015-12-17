//
//  InclinometerViewController.m
//  CalcSuite#3
//
//  Created by Byeong-Kwon Kwak on 12/22/08.
//  Copyright 2008 ALLABOUTAPPS. All rights reserved.
//

#import "InclinometerViewController.h"
#import "InclinometerView.h"
#import "CalibrationView.h"
#import "UIViewController+MMDrawerController.h"
#import "A3AppDelegate.h"
#import "UIViewController+A3Addition.h"

@import CoreMotion;

#import <GoogleMobileAds/GoogleMobileAds.h>

#define kCalibrationOffsetKeyForBubble		@"kCalibrationOffsetKeyForBubble"
#define kCalibrationOffsetXKeyForSurface		@"kCalibrationOffsetXKeyForSurface"
#define kCalibrationOffsetYKeyForSurface		@"kCalibrationOffsetYKeyForSurface"

@interface InclinometerViewController () <ClinometerToolbarViewControllerDelegate>

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation InclinometerViewController {
	UIAccelerationValue accelerationX1, accelerationX2;
	UIAccelerationValue accelerationY1, accelerationY2;
	UIAccelerationValue accelerationZ1, accelerationZ2;
	
	// calibration support
	float firstCalibrationReading;
	float firstCalibrationReadingX;
	float firstCalibrationReadingY;
	float currentRawReading;
	float currentRawReadingX;
	float currentRawReadingY;
	float calibrationOffset;
	float calibrationOffsetX;
	float calibrationOffsetY;
	
	NSUInteger unit;
	NSUInteger inclinometerMode;	// 0:Surface, 1:Bubble
	
	InclinometerView  *surfaceView, *barView;
	CalibrationView *calibrationViewForSurface, *calibrationViewForBubble;
	
	BOOL	lockOnSurface, lockOnBubble;
	ClinometerToolbarViewController *toolbarVC;
}

@synthesize unit;

#define kUpdateFrequency 20  // Hz
#define kFilteringFactor 0.05
#define kNoReadingValue 999

- (instancetype)init {
	self = [super init];
	if (self) {
        firstCalibrationReading = kNoReadingValue;
		firstCalibrationReadingX = kNoReadingValue;
		firstCalibrationReadingY = kNoReadingValue;
		lockOnSurface = NO;
		lockOnBubble = NO;
		
		inclinometerMode = 0;		// Surface for initial
		
        NSNumber *defaultCalibrationOffset = [NSNumber numberWithFloat:0.0];
        NSDictionary *resourceDict = [NSDictionary dictionaryWithObject:defaultCalibrationOffset forKey:kCalibrationOffsetKeyForBubble];
		[[NSUserDefaults standardUserDefaults] registerDefaults:resourceDict];
        resourceDict = [NSDictionary dictionaryWithObject:defaultCalibrationOffset forKey:kCalibrationOffsetXKeyForSurface];
		[[NSUserDefaults standardUserDefaults] registerDefaults:resourceDict];
        resourceDict = [NSDictionary dictionaryWithObject:defaultCalibrationOffset forKey:kCalibrationOffsetYKeyForSurface];
		[[NSUserDefaults standardUserDefaults] registerDefaults:resourceDict];

		calibrationOffset = [[[NSUserDefaults standardUserDefaults] objectForKey:kCalibrationOffsetKeyForBubble] doubleValue];
		calibrationOffsetX = [[[NSUserDefaults standardUserDefaults] objectForKey:kCalibrationOffsetXKeyForSurface] doubleValue];
		calibrationOffsetY = [[[NSUserDefaults standardUserDefaults] objectForKey:kCalibrationOffsetYKeyForSurface] doubleValue];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	[self.navigationController setNavigationBarHidden:YES animated:YES];

	[self myLayoutSubviews];

	if ([[A3AppDelegate instance] shouldPresentAd]) {
		[self setupBannerViewForAdUnitID:AdMobAdUnitIDLevel keywords:@[@"House"] gender:kGADGenderUnknown];
		
		UIView *superview = self.view;
		[self.view addSubview:self.bannerView];
		[self.bannerView makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(superview.left);
			make.top.equalTo(superview.bottom);
			make.width.equalTo(@320);
			make.height.equalTo(@50);
		}];
	}
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
}

- (void)mainMenuDidHide {
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	
	[self setupMotionManager];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[self.motionManager stopAccelerometerUpdates];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];

	if ([self isMovingFromParentViewController]) {
		[self removeObserver];
	}
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidHide object:nil];
}

- (void)cleanUp {
	[self removeObserver];
}

- (void)dealloc {
	[self removeObserver];
}

- (void)myLayoutSubviews {
	CGRect frame = self.view.bounds;
	surfaceView = [[InclinometerView alloc] initWithFrame:frame mode:surfaceMode];
	surfaceView.viewController = self;
	[self.view addSubview:surfaceView];
	
	barView = [[InclinometerView alloc] initWithFrame:frame mode:bubbleMode];
	barView.viewController = self;

    calibrationViewForSurface = [[CalibrationView alloc] initWithMode:surfaceMode
														viewController:self];
    calibrationViewForBubble = [[CalibrationView alloc] initWithMode:bubbleMode
													   viewController:self];

	toolbarVC = [[ClinometerToolbarViewController alloc] init];
	toolbarVC.delegate = self;
	toolbarVC.view.frame = CGRectMake(0.0, 0.0, 320.0, 41.0);
	[self.view addSubview:[toolbarVC view]];
	
	[toolbarVC updateTimer];
}

- (void)setToDegree{
	unit = 0;
}

- (void)setToSlope {
	unit = 1;
}

- (void)setToPitch {
	unit = 2;
}

- (void)exitToHome {
	if (IS_IPHONE) {
		[[self mm_drawerController] toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	} else {
		[[[A3AppDelegate instance] rootViewController] toggleLeftMenuViewOnOff];
	}
}

- (void)gotoSurface {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kTransitionDuration];
	[UIView setAnimationTransition:([surfaceView superview] ? UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight) forView:self.view cache:YES];
	[barView removeFromSuperview];
	[self.view addSubview:surfaceView];
	[self.view bringSubviewToFront:toolbarVC.view];
	if (self.bannerView) {
		[self.view bringSubviewToFront:self.bannerView];
	}
	inclinometerMode = surfaceMode;
	[UIView commitAnimations];
	if (lockOnSurface) [toolbarVC setLockImage];
	else [toolbarVC setUnlockImage];
}

- (void)gotoBubble {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kTransitionDuration];
	[UIView setAnimationTransition:([surfaceView superview] ? UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight) forView:self.view cache:YES];
	[surfaceView removeFromSuperview];
	[self.view addSubview:barView];
	[self.view bringSubviewToFront:toolbarVC.view];
	if (self.bannerView) {
		[self.view bringSubviewToFront:self.bannerView];
	}
	inclinometerMode = bubbleMode;
	[UIView commitAnimations];
	if (lockOnBubble) [toolbarVC setLockImage];
	else [toolbarVC setUnlockImage];
}

- (void)calibration {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kTransitionDuration];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];

	if (inclinometerMode == surfaceMode) {
		[surfaceView removeFromSuperview];
		[calibrationViewForSurface resetToInitialState:self];
		[self.view addSubview:calibrationViewForSurface];
	}
	else {
		[barView removeFromSuperview];
		[calibrationViewForBubble resetToInitialState:self];
		[self.view addSubview:calibrationViewForBubble];
	}
	[UIView commitAnimations];
}

- (void) calibrateDoneAction:(id)sender {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kTransitionDuration];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
	
	if (inclinometerMode == surfaceMode) {
		[calibrationViewForSurface removeFromSuperview];
		[self.view addSubview:surfaceView];
	}
	else {
		[calibrationViewForBubble removeFromSuperview];
		[self.view addSubview:barView];

	}
	[self.view bringSubviewToFront:toolbarVC.view];
	if (self.bannerView) {
		[self.view bringSubviewToFront:self.bannerView];
	}
	[UIView commitAnimations];
}

- (void)lockUnlock {
	if (inclinometerMode == surfaceMode) {
		lockOnSurface = lockOnSurface==YES? NO:YES;
		if (lockOnSurface) [toolbarVC setLockImage];
		else [toolbarVC setUnlockImage];
	} else {
		lockOnBubble = lockOnBubble == YES? NO:YES;
		if (lockOnBubble) [toolbarVC setLockImage];
		else [toolbarVC setUnlockImage];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; 
	// Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[toolbarVC toggleViewWithMode:inclinometerMode];
}

#pragma mark -
#pragma mark === Responding to accelerations ===
#pragma mark -

// UIAccelerometer delegate method, which delivers the latest acceleration data.
- (void)accelerometerDidAccelerate:(CMAcceleration)acceleration {
	// Use a basic low-pass filter to only keep the gravity in the accelerometer values for the X and Y axes
	if (!lockOnBubble) {
		accelerationX1 = acceleration.x * kFilteringFactor + accelerationX1 * (1.0 - kFilteringFactor);
		accelerationY1 = acceleration.y * kFilteringFactor + accelerationY1 * (1.0 - kFilteringFactor);
		accelerationZ1 = acceleration.z * kFilteringFactor + accelerationZ1 * (1.0 - kFilteringFactor);
	}

	if (!lockOnSurface) {
		accelerationX2 = acceleration.x * kFilteringFactor + accelerationX2 * (1.0 - kFilteringFactor);
		accelerationY2 = acceleration.y * kFilteringFactor + accelerationY2 * (1.0 - kFilteringFactor);
		accelerationZ2 = acceleration.z * kFilteringFactor + accelerationZ2 * (1.0 - kFilteringFactor);
	}
	
	if ([barView superview]) {		// Bubble Level View
		// keep the raw reading, to use during calibrations
		currentRawReading = atan2(accelerationY1, accelerationX1);
		currentRawReadingX = atan2(accelerationX1, -accelerationZ1);
		currentRawReadingY = atan2(accelerationY1, -accelerationZ1);
		
		float calibratedAngle = currentRawReading + calibrationOffset;
		float calibratedAngleX = currentRawReadingX + calibrationOffsetX;
		float calibratedAngleY = currentRawReadingY + calibrationOffsetY;
		
		[barView updateToInclinationInRadians:calibratedAngle radianX:calibratedAngleX radianY:calibratedAngleY];
		if (!lockOnBubble && 
			(currentRawReadingX < 0.8)) 
		{
			[self gotoSurface];
		}
	} else if ([surfaceView superview]) {						// Surface Level View
		// keep the raw reading, to use during calibrations
		currentRawReading = atan2(accelerationY2, accelerationX2);
		currentRawReadingX = atan2(accelerationX2, -accelerationZ2);
		currentRawReadingY = atan2(accelerationY2, -accelerationZ2);
		
		float calibratedAngle = currentRawReading + calibrationOffset;
		float calibratedAngleX = currentRawReadingX + calibrationOffsetX;
		float calibratedAngleY = currentRawReadingY + calibrationOffsetY;
		
		[surfaceView updateToInclinationInRadians:calibratedAngle radianX:calibratedAngleX radianY:-calibratedAngleY];
		if (!lockOnSurface && 
			(currentRawReadingX > 0.8)) 
		{
			[self gotoBubble];
		}
	}
}

- (void)calibrate1Action:(id)sender {
    firstCalibrationReading = currentRawReading;	// Use this for bubble level calibration
	firstCalibrationReadingX = currentRawReadingX;	// Use this for Surface level on X
	firstCalibrationReadingY = currentRawReadingY;
}

- (void)calibrate2Action:(id)sender {
#ifdef TRACE_LOG
	NSLog(@"firstReading = %f, currentReading = %f", firstCalibrationReading, currentRawReading);
	NSLog(@"firstReadingX = %f, currentReadingX = %f", firstCalibrationReadingX, currentRawReadingY);
	NSLog(@"firstReadingY = %f, currentReadingY = %f", firstCalibrationReadingY, currentRawReadingX);
#endif
	
	if (inclinometerMode == bubbleMode) {
		// can't calibrate unless there's an initial reading
		if (firstCalibrationReading != kNoReadingValue) {
			// get the sign of the measurement with the max displacement. The offset will have the opposite sign.
			float maxDisplacement = (fabs(firstCalibrationReading) > fabs(currentRawReading)) ? firstCalibrationReading : currentRawReading;
			NSInteger sign = (maxDisplacement >= 0) ? -1 : 1;
			calibrationOffset = sign * (fabs(firstCalibrationReading) + fabs(currentRawReading)) / 2;
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:calibrationOffset] forKey:kCalibrationOffsetKeyForBubble];
		} else {
			NSLog(@" no initial reading, can't calculate offset");
		}
		// reset for next calibration
		firstCalibrationReading = kNoReadingValue;
	} else {
		if (firstCalibrationReadingX != kNoReadingValue) {
			// get the sign of the measurement with the max displacement. The offset will have the opposite sign.
			float maxDisplacement = (fabs(firstCalibrationReadingX) > fabs(currentRawReadingX)) ? firstCalibrationReadingX : currentRawReadingX;
			NSInteger sign = (maxDisplacement >= 0) ? -1 : 1;
			calibrationOffsetX = sign * (fabs(firstCalibrationReadingX) + fabs(currentRawReadingX)) / 2;
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:calibrationOffsetX] forKey:kCalibrationOffsetXKeyForSurface];
		} else {
			NSLog(@" no initial reading, can't calculate offset");
		}
		// reset for next calibration
		firstCalibrationReadingX = kNoReadingValue;
		
		if (firstCalibrationReadingY != kNoReadingValue) {
			// get the sign of the measurement with the max displacement. The offset will have the opposite sign.
			float maxDisplacement = (fabs(firstCalibrationReadingY) > fabs(currentRawReadingY)) ? firstCalibrationReadingY : currentRawReadingY;
			NSInteger sign = (maxDisplacement >= 0) ? -1 : 1;
			calibrationOffsetY = sign * (fabs(firstCalibrationReadingY) + fabs(currentRawReadingY)) / 2;
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:calibrationOffsetY] forKey:kCalibrationOffsetYKeyForSurface];
		} else {
			NSLog(@" no initial reading, can't calculate offset");
		}
		// reset for next calibration
		firstCalibrationReadingY = kNoReadingValue;
	}
#ifdef TRACE_LOG
	NSLog(@"calibrationOffset = %f", calibrationOffset);
	NSLog(@"calibrationOffsetX = %f", calibrationOffsetX);
	NSLog(@"calibrationOffsetY = %f", calibrationOffsetY);
#endif
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setupMotionManager {
	self.motionManager.accelerometerUpdateInterval = 1/ kUpdateFrequency;
	[self.motionManager startAccelerometerUpdatesToQueue:self.operationQueue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self accelerometerDidAccelerate:accelerometerData.acceleration];
		});
	}];
}

- (CMMotionManager *)motionManager {
	if (!_motionManager) {
		_motionManager = [CMMotionManager new];
	}
	return _motionManager;
}

- (NSOperationQueue *)operationQueue {
	if (!_operationQueue) {
		_operationQueue = [NSOperationQueue new];
	}
	return _operationQueue;
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
	[self.view bringSubviewToFront:bannerView];
	[bannerView setHidden:NO];
	[UIView animateWithDuration:0.3 animations:^{
		UIView *superview = self.view;
		[bannerView remakeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(superview.left);
			make.right.equalTo(superview.right);
			make.bottom.equalTo(superview.bottom);
		}];
		
		[self.view layoutIfNeeded];
	}];
}

@end
