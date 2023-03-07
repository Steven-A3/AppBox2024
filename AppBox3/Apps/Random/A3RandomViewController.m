//
//  A3RandomViewController.m
//  AppBox3
//
//  Created by kimjeonghwan on 9/24/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3RandomViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIViewController+A3Addition.h"
#import <CoreMotion/CoreMotion.h>
#import "A3AppDelegate+appearance.h"
#import "A3DefaultColorDefines.h"
#import "A3UserDefaults.h"
#import "A3NumberKeyboardViewController.h"
#import "UIViewController+NumberKeyboard.h"

#define kAccelerometerFrequency			25 //Hz
#define kFilteringFactorForErase		0.1
#define kMinEraseInterval				0.5
#define kEraseAccelerationThreshold		2.0

const NSInteger MINCOLUMN = 0;
const NSInteger MAXCOLUMN = 1;

NSString *const A3RandomLastValueKey = @"A3RandomLastValueKey";
NSString *const A3RandomRangeMinimumKey = @"A3RandomRangeMinimumKey";
NSString *const A3RandomRangeMaximumKey = @"A3RandomRangeMaximumKey";

@interface A3RandomViewController () <UIAccelerometerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIScrollViewDelegate, UITextFieldDelegate, A3KeyboardDelegate, GADBannerViewDelegate>

- (IBAction)randomButtonTouchUp:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *resultPanelView;
@property (weak, nonatomic) IBOutlet UILabel *resultPrintLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *limitNumberPickerView;
@property (weak, nonatomic) IBOutlet UIButton *generatorButton;
@property (weak, nonatomic) IBOutlet UITextField *minimumValueTextField;
@property (weak, nonatomic) IBOutlet UITextField *maximumValueTextField;
@property (weak, nonatomic) IBOutlet UILabel *minimumValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *maximumValueLabel;
@property (weak, nonatomic) IBOutlet UIView *pickerContainerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *limitPickerViewSeparatorWidthConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *limitPickerViewSeparatorTopHeightConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *limitPickerViewSeparatorBottomHeightConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *minValueTopLineHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *maxValueTopLineHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *resultViewTopConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *generateButtonBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *generateButtonHeightConstraint;

@property (strong, nonatomic) NSNumberFormatter *numberFormatter;
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) A3NumberKeyboardViewController *simpleNormalNumberKeyboard;
@property (copy, nonatomic) NSString *textBeforeEditingTextField;
@property (copy, nonatomic) UIColor *textColorBeforeEditing;
@property (weak, nonatomic) UITextField *editingTextField;
@property (assign, nonatomic) BOOL isNumberKeyboardVisible;
@property (assign, nonatomic) CGFloat viewFrameOffset;

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
	CGFloat _viewFrameOffset;
	
	BOOL _isNumberKeyboardVisible;
	BOOL _didPressClearKey;
	BOOL _didPressNumberKey;
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
    self.title = NSLocalizedString(A3AppName_Random, nil);
    
    [self makeNavigationBarAppearanceDefault];
	[self makeBackButtonEmptyArrow];
	if (IS_IPAD || IS_PORTRAIT) {
		[self leftBarButtonAppsButton];
	} else {
		self.navigationItem.leftBarButtonItem = nil;
		self.navigationItem.hidesBackButton = YES;
	}

	[_generatorButton setTitle:NSLocalizedString(@"TAP OR SHAKE TO GENERATE", @"TAP OR SHAKE TO GENERATE") forState:UIControlStateNormal];
	_minimumValueLabel.text = NSLocalizedString(@"Minimum Value", @"Minimum Value");
	_maximumValueLabel.text = NSLocalizedString(@"Maximum Value", @"Maximum Value");

	UIColor *themeColor = [[A3AppDelegate instance] themeColor];
	_generatorButton.backgroundColor = themeColor;
	_minimumValueTextField.textColor = themeColor;
	_maximumValueTextField.textColor = themeColor;

    _resultPanelView.backgroundColor = COLOR_HEADERVIEW_BG;

	NSInteger minimum = 1, maximum = 100;
	id minimumObj = [[A3UserDefaults standardUserDefaults] objectForKey:A3RandomRangeMinimumKey];
	if (minimumObj) {
		minimum = [minimumObj integerValue];
	}
	id maximumObj = [[A3UserDefaults standardUserDefaults] objectForKey:A3RandomRangeMaximumKey];
	if (maximumObj) {
		maximum = [maximumObj integerValue];
	}
    [_limitNumberPickerView selectRow:minimum inComponent:MINCOLUMN animated:YES];
    [_limitNumberPickerView selectRow:maximum inComponent:MAXCOLUMN animated:YES];
	_minimumValueTextField.text = [self.numberFormatter stringFromNumber:@(minimum)];
	_maximumValueTextField.text = [self.numberFormatter stringFromNumber:@(maximum)];

    _resultPrintLabel.adjustsFontSizeToFitWidth = YES;
    _resultPrintLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:80];

	NSNumber *lastResult = [[A3UserDefaults standardUserDefaults] objectForKey:A3RandomLastValueKey];
	if (lastResult) {
		_resultPrintLabel.text = [NSString stringWithFormat:@"%ld", [lastResult longValue]];
	}

	CGFloat scale = [UIScreen mainScreen].scale;
	_limitPickerViewSeparatorWidthConst.constant = 1.0 / scale;
    _limitPickerViewSeparatorTopHeightConst.constant = 1.0 / scale;
    _limitPickerViewSeparatorBottomHeightConst.constant = 1.0 / scale;
	_minValueTopLineHeightConstraint.constant = 1.0 / scale;
	_maxValueTopLineHeightConstraint.constant = 1.0 / scale;
    
    UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets];
    _generateButtonHeightConstraint.constant = 44 + safeAreaInsets.bottom;

    if (IS_IPAD) {
        _generatorButton.titleLabel.font = [UIFont systemFontOfSize:22];
        _resultPrintLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:152.0];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setupMotionManager)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(releaseMotionManager)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupMotionManager];

	_resultViewTopConst.constant = CGRectGetHeight(self.navigationController.navigationBar.bounds);
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	
	if (IS_IPHONE && IS_PORTRAIT) {
		[self leftBarButtonAppsButton];
	}
    [self setupBannerViewForAdUnitID:AdMobAdUnitIDRandom keywords:@[@"random", @"lottery"] delegate:self];
	
	if ([self.navigationController.navigationBar isHidden]) {
		[self showNavigationBarOn:self.navigationController];
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

- (void)prepareClose {
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    }
}

- (BOOL)resignFirstResponder {
	[self dismissNumberKeyboard];
	return [super resignFirstResponder];
}

- (void)cleanUp {
    [self removeObserver];
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
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)setNavigationBarHidden:(BOOL)hidden {
	[self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
	[self.navigationController.navigationBar setShadowImage:nil];
    
	[self.navigationController setNavigationBarHidden:hidden];
}

- (void)appsButtonAction:(UIBarButtonItem *)barButtonItem {
	[super appsButtonAction:barButtonItem];
	
	[self dismissNumberKeyboard];
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
    return 1000000;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [self.numberFormatter stringFromNumber:@(row)];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSInteger maxValue = [pickerView selectedRowInComponent:1];
    NSInteger minValue = [pickerView selectedRowInComponent:0];
    if (minValue > maxValue) {
        [pickerView selectRow:minValue inComponent:MAXCOLUMN animated:YES];
        [pickerView selectRow:maxValue inComponent:MINCOLUMN animated:YES];
		NSInteger temp = minValue;
		minValue = maxValue;
		maxValue = temp;
    }
	[[A3UserDefaults standardUserDefaults] setObject:@(minValue) forKey:A3RandomRangeMinimumKey];
	[[A3UserDefaults standardUserDefaults] setObject:@(maxValue) forKey:A3RandomRangeMaximumKey];
	[[A3UserDefaults standardUserDefaults] synchronize];
	
	_minimumValueTextField.text = [self.numberFormatter stringFromNumber:@(minValue)];
	_maximumValueTextField.text = [self.numberFormatter stringFromNumber:@(maxValue)];
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
	_resultPrintLabel.text = [nf stringFromNumber:@(newNum)];

	[[A3UserDefaults standardUserDefaults] setObject:@(newNum) forKey:A3RandomLastValueKey];
	[[A3UserDefaults standardUserDefaults] synchronize];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if (IS_IPHONE && IS_LANDSCAPE) {
            [self leftBarButtonAppsButton];

            CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
            CGRect frame = self.limitNumberPickerView.frame;
            frame.size.width = screenBounds.size.height;
            self.limitNumberPickerView.frame = frame;
        }

        if (self.isNumberKeyboardVisible && self.numberKeyboardViewController.view.superview) {
            UIView *keyboardView = self.numberKeyboardViewController.view;
            CGFloat keyboardHeight = self.numberKeyboardViewController.keyboardHeight;
            
            FNLOGRECT(self.view.bounds);
            FNLOG(@"%f", keyboardHeight);
            CGRect bounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
            keyboardView.frame = CGRectMake(0, bounds.size.height - keyboardHeight, bounds.size.width, keyboardHeight);
            UIInterfaceOrientation interfaceOrientation = size.width > size.height ? UIInterfaceOrientationLandscapeLeft : UIInterfaceOrientationPortrait;
            [self.numberKeyboardViewController rotateToInterfaceOrientation:interfaceOrientation];
            
            UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets];
            self.generateButtonHeightConstraint.constant = 44 + safeAreaInsets.bottom;
        }
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    }];
}

- (NSNumberFormatter *)numberFormatter {
	if (!_numberFormatter) {
		_numberFormatter = [NSNumberFormatter new];
		[_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	}
	return _numberFormatter;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	if (_isNumberKeyboardVisible) {
		[self textFieldDidEndEditing:_editingTextField];
		[self textFieldDidBeginEditing:textField];
	} else {
		[self presentNumberKeyboardForTextField:textField];
	}
	return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	_editingTextField = textField;
	self.textBeforeEditingTextField = textField.text;
	textField.text = [self.decimalFormatter stringFromNumber:@0];

	if (textField == _minimumValueTextField) {
		_maximumValueTextField.textColor = [UIColor colorWithRed:201.0/255.0 green:201.0/255.0 blue:201.0/255.0 alpha:1.0];
	} else {
		_minimumValueTextField.textColor = [UIColor colorWithRed:201.0/255.0 green:201.0/255.0 blue:201.0/255.0 alpha:1.0];
	}

	[self.numberKeyboardViewController reloadPrevNextButtons];
	self.numberKeyboardViewController.textInputTarget = textField;
	_didPressClearKey = NO;
	_didPressNumberKey = NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if (!_didPressNumberKey && !_didPressClearKey) {
		textField.text = _textBeforeEditingTextField;
	}

	_minimumValueTextField.textColor = [[A3AppDelegate instance] themeColor];
	_maximumValueTextField.textColor = [[A3AppDelegate instance] themeColor];

	NSInteger number = [[self.numberFormatter numberFromString:textField.text] integerValue];
	NSInteger component = textField == _minimumValueTextField ? 0 : 1;
	[_limitNumberPickerView selectRow:number inComponent:component animated:YES];
	[self pickerView:_limitNumberPickerView didSelectRow:number inComponent:component];
}

- (void)presentNumberKeyboardForTextField:(UITextField *)textField {
	if (_isNumberKeyboardVisible) {
		return;
	}
	_editingTextField = textField;

	[self textFieldDidBeginEditing:textField];

	A3NumberKeyboardViewController *keyboardVC = [self simplePrevNextClearNumberKeyboard];
	self.numberKeyboardViewController = keyboardVC;
	keyboardVC.keyboardType = A3NumberKeyboardTypeInteger;
	keyboardVC.textInputTarget = textField;
	keyboardVC.delegate = self;
	
	CGRect bounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	CGFloat keyboardHeight = keyboardVC.keyboardHeight;
	UIView *keyboardView = keyboardVC.view;
	[self.view addSubview:keyboardView];

	_didPressClearKey = NO;
	_didPressNumberKey = NO;
	_isNumberKeyboardVisible = YES;

	keyboardView.frame = CGRectMake(0, bounds.size.height, bounds.size.width, keyboardHeight);
	[UIView animateWithDuration:0.3 animations:^{
		CGRect frame = keyboardView.frame;
		frame.origin.y -= keyboardHeight;
		keyboardView.frame = frame;
		
		if (IS_IPAD) {
			self.generateButtonBottomConstraint.constant = (keyboardHeight - (bounds.size.height - _pickerContainerView.frame.origin.y));
		}
	} completion:^(BOOL finished) {
		[self addNumberKeyboardNotificationObservers];
	}];
}

- (void)dismissNumberKeyboard {
	if (!_isNumberKeyboardVisible) {
		return;
	}
	[self textFieldDidEndEditing:_editingTextField];
	
	A3NumberKeyboardViewController *keyboardViewController = self.numberKeyboardViewController;
	UIView *keyboardView = keyboardViewController.view;
	[UIView animateWithDuration:0.3 animations:^{
		CGRect frame = keyboardView.frame;
		frame.origin.y += keyboardViewController.keyboardHeight;
		keyboardView.frame = frame;
		
        UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets];
        self.generateButtonBottomConstraint.constant = safeAreaInsets.top > 20 ? safeAreaInsets.bottom : 0;
	} completion:^(BOOL finished) {
		[keyboardView removeFromSuperview];
		self.numberKeyboardViewController = nil;
		self.isNumberKeyboardVisible = NO;
	}];
}

#pragma mark - Keyboard Delegate

- (void)A3KeyboardController:(A3NumberKeyboardViewController *)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
	_didPressClearKey = YES;
	_didPressNumberKey = NO;
	UITextField *textField = (id)controller.textInputTarget;
	textField.text = [self.decimalFormatter stringFromNumber:@0];
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate {
	[self dismissNumberKeyboard];
}

- (void)keyboardViewControllerDidValueChange:(A3NumberKeyboardViewController *)vc {
	_didPressClearKey = NO;
	_didPressNumberKey = YES;
}

- (BOOL)isPreviousEntryExists {
	return _editingTextField == _maximumValueTextField;
}

- (BOOL)isNextEntryExists{
	return _editingTextField == _minimumValueTextField;
}

- (void)prevButtonPressed{
	if (_editingTextField == _maximumValueTextField) {
		[self textFieldDidEndEditing:_editingTextField];
		[self textFieldDidBeginEditing:_minimumValueTextField];
	}
}

- (void)nextButtonPressed{
	if (_editingTextField == _minimumValueTextField) {
		[self textFieldDidEndEditing:_editingTextField];
		[self textFieldDidBeginEditing:_maximumValueTextField];
	}
}

#pragma mark - UIKeyboard Notification

- (void)keyboardWillShow:(NSNotification *)notification {
	[self makeTextFieldVisibleWithNotification:notification];
}

- (void)keyboardWillHide:(NSNotification *)notification {
	double duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	[UIView animateWithDuration:duration animations:^{
		CGRect frameEnd = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
		frameEnd = [self.view convertRect:frameEnd fromView:[A3AppDelegate instance].window];
		FNLOGRECT(frameEnd);
		FNLOGRECT(self.view.frame);
		CGRect viewFrame = self.view.frame;
		viewFrame.origin.y = 0;
		self.view.frame = viewFrame;
	}];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
	[self makeTextFieldVisibleWithNotification:notification];
}

- (void)makeTextFieldVisibleWithNotification:(NSNotification *)notification {
	double duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	[UIView animateWithDuration:duration animations:^{
		CGRect frameEnd = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
		frameEnd = [self.view convertRect:frameEnd fromView:[A3AppDelegate instance].window];
		CGRect textFieldFrame = [self.minimumValueTextField isFirstResponder] ? self.minimumValueTextField.frame : self.maximumValueTextField.frame;
		CGFloat diff = textFieldFrame.origin.y + textFieldFrame.size.height - frameEnd.origin.y;
		if (diff > 0) {
			self.viewFrameOffset = diff;
			CGRect viewFrame = self.view.frame;
			viewFrame.origin.y -= self.viewFrameOffset;
			self.view.frame = viewFrame;
		}
	}];
}

@end
