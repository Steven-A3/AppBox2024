//
//  A3RulerViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2015. 2. 23..
//  Copyright (c) 2015년 ALLABOUTAPPS. All rights reserved.
//

#import "A3RulerViewController.h"
#import "A3MarkingsView.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+extension.h"
#import "A3UIDevice.h"
#import "A3AppDelegate.h"
#import "A3UserDefaults+A3Addition.h"

NSString *const A3RulerCentimeterPositionRightBottom = @"A3RulerCentemeterPositionRightBottom";
NSString *const A3RulerScrollDirectionReverse = @"A3RulerScrollDirectionReverse";

@interface A3RulerViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate, GADBannerViewDelegate>

@property (nonatomic, strong) NSMutableArray *centimetersMarkingViews;
@property (nonatomic, strong) NSMutableArray *centimeterLabels;
@property (nonatomic, strong) NSMutableArray *inchesMarkingViews;
@property (nonatomic, strong) NSMutableArray *inchLabels;
@property (nonatomic, strong) UIScrollView *rulerScrollView;
@property (assign) CGFloat centimeterAsPoints;
@property (assign) CGFloat inchAsPoints;
@property (assign) CGFloat screenWidth;
@property (assign) CGFloat screenHeight;
@property (assign) CGFloat markingsWidth;
@property (assign) NSInteger numberOfCentimetersInScreen;
@property (assign) NSInteger numberOfInchesInScreen;
@property (nonatomic, strong) UIView *redLineView;
@property (nonatomic, strong) UIView *redLineGlassView;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;
@property (nonatomic, strong) UILabel *topValueLabel;
@property (nonatomic, strong) UILabel *bottomValueLabel;
@property (assign) CGFloat resetPosition;
@property (nonatomic, strong) UIButton *advanceButton;
@property (nonatomic, strong) UIButton *resetButton;
@property (nonatomic, strong) UIButton *appsButton;
@property (nonatomic, strong) UIButton *flipScrollDirectionButton;
@property (nonatomic, strong) UIButton *flipUnitButton;
@property (assign) CGFloat redLineWidth;
@property (assign) BOOL needsSnapToGrid;
@property (assign) BOOL needsResetRedLinePosition;
@property (nonatomic, strong) UIImageView *fingerDragView;
@property (nonatomic, strong) UIPanGestureRecognizer *fingerDragViewGestureRecognizer;
@property (nonatomic, strong) UIImageView *rulerDragView;

@end

@implementation A3RulerViewController {
	NSInteger _oldMarkingsStartIndex;
	BOOL _centimeterPositionRightBottom;
	BOOL _rulerScrollDirectionReverse;
}

- (instancetype)init {
	self = [super init];
	if (self) {
		_numberFormatter = [NSNumberFormatter new];
		[_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[_numberFormatter setMinimumFractionDigits:2];
		[_numberFormatter setMaximumFractionDigits:2];
		_oldMarkingsStartIndex = NSNotFound;

		NSNumber *prefValue = [[NSUserDefaults standardUserDefaults] objectForKey:A3RulerCentimeterPositionRightBottom];
		if (prefValue) {
			_centimeterPositionRightBottom = [prefValue boolValue];
		} else {
			_centimeterPositionRightBottom = [[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue];
		}
		NSNumber *prefScrollDirection = [[NSUserDefaults standardUserDefaults] objectForKey:A3RulerScrollDirectionReverse];
		if (prefScrollDirection) {
			_rulerScrollDirectionReverse = [prefScrollDirection boolValue];
		}
	}

	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

	self.automaticallyAdjustsScrollViewInsets = NO;
	
	UIImage *image = [[UIImage alloc] init];
	[self.navigationController.navigationBar setBackgroundImage:image forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
	[self.navigationController.navigationBar setShadowImage:image];

    [self setValuePrefersStatusBarHidden:YES];
    [self setNeedsStatusBarAppearanceUpdate];
	[self.navigationController setNavigationBarHidden:YES];

	self.view.backgroundColor = [UIColor whiteColor];
	
	[self setupBasicMeasureForInterfaceOrientation:[UIWindow interfaceOrientationIsPortrait]];
	[self setupSubviews];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(drawerStateChanged) name:A3DrawerStateChanged object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
}

- (void)mainMenuDidHide {
    [self setValuePrefersStatusBarHidden:YES];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)drawerStateChanged {
    [self setValuePrefersStatusBarHidden:YES];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3DrawerStateChanged object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidHide object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		[self removeObserver];
	}
}

- (void)prepareClose {
	[self removeObserver];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([self isMovingToParentViewController] || [self isBeingPresented]) {
		[self resetButtonAction];
		[self setupBannerViewForAdUnitID:AdMobAdUnitIDRuler keywords:@[@"ruler", @"size", @"length"] delegate:self];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupBasicMeasureForiPhone:(BOOL)toPortrait model:(NSString *)model {
    CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
    CGFloat screenHeight = MAX(screenBounds.size.width, screenBounds.size.height);

    if ([model isEqualToString:@"iPhone 16 Plus"] ||
        [model isEqualToString:@"iPhone 15 Plus"] ||
        [model isEqualToString:@"iPhone 15 Pro Max"] ||
        [model isEqualToString:@"iPhone 14 Pro Max"])
    {
        CGFloat pixelsInInch = 460;
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 2796.0) * pixelsInCentimeter;
        _inchAsPoints = (screenHeight / 2796.0) * pixelsInInch;
        _resetPosition = _centimeterPositionRightBottom ? 11.0 : 4.0;
        _redLineWidth = 0.5;
        return;
    }
    if ([model isEqualToString:@"iPhone 16 Pro Max"])
    {
        CGFloat pixelsInInch = 460;
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 2868.0) * pixelsInCentimeter;
        _inchAsPoints = (screenHeight / 2868.0) * pixelsInInch;
        _resetPosition = _centimeterPositionRightBottom ? 11.0 : 4.0;
        _redLineWidth = 0.5;
        return;
    }
    if ([model isEqualToString:@"iPhone 16"] ||
        [model isEqualToString:@"iPhone 15"] ||
        [model isEqualToString:@"iPhone 15 Pro"] ||
        [model isEqualToString:@"iPhone 14 Pro"])
    {
        CGFloat pixelsInInch = 460;
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 2556.0) * pixelsInCentimeter;
        _inchAsPoints = (screenHeight / 2556.0) * pixelsInInch;
        _resetPosition = _centimeterPositionRightBottom ? 11.0 : 4.0;
        _redLineWidth = 0.5;
        return;
    }
    if ([model isEqualToString:@"iPhone 16 Pro"]) {
        CGFloat pixelsInInch = 460;
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 2622.0) * pixelsInCentimeter;
        _inchAsPoints = (screenHeight / 2622.0) * pixelsInInch;
        _resetPosition = _centimeterPositionRightBottom ? 11.0 : 4.0;
        _redLineWidth = 0.5;
        return;
    }
    if ([model isEqualToString:@"iPhone 13 mini"] ||
        [model isEqualToString:@"iPhone 12 mini"]) {
        CGFloat pixelsInInch = 476;
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 2340.0) * pixelsInCentimeter;
        _inchAsPoints = (screenHeight / 2340.0) * pixelsInInch;
        _resetPosition = _centimeterPositionRightBottom ? 11.0 : 4.0;
        _redLineWidth = 0.5;
        return;
    }
    if ([model isEqualToString:@"iPhone 13 Pro"] ||
        [model isEqualToString:@"iPhone 12 Pro"] ||
        [model isEqualToString:@"iPhone 14"] ||
        [model isEqualToString:@"iPhone 13"] ||
        [model isEqualToString:@"iPhone 12"] ||
        [model isEqualToString:@"iPhone (Latest)"]) {
        CGFloat pixelsInInch = 460;    // Original value = 458
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 2532.0) * pixelsInCentimeter;
        _inchAsPoints = (screenHeight / 2532.0) * pixelsInInch;
        _resetPosition = _centimeterPositionRightBottom ? 11.0 : 4.0;
        _redLineWidth = 0.5;
        return;
    }
    if ([model isEqualToString:@"iPhone 13 Pro Max"] ||
        [model isEqualToString:@"iPhone 12 Pro Max"] ||
        [model isEqualToString:@"iPhone 14 Plus"]) {
        CGFloat pixelsInInch = 458;     // Original value = 326
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 2778.0) * pixelsInCentimeter;
        _inchAsPoints = (screenHeight / 2778.0) * pixelsInInch;
        _resetPosition = _centimeterPositionRightBottom ? 11.0 : 4.0;
        _redLineWidth = 0.5;
        return;
    }
    if ([model isEqualToString:@"iPhone 11 Pro Max"]) {
        CGFloat pixelsInInch = 458;     // Original value = 326
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 2688.0) * pixelsInCentimeter;
        _inchAsPoints = (screenHeight / 2688.0) * pixelsInInch;
        _resetPosition = _centimeterPositionRightBottom ? 11.0 : 4.0;
        _redLineWidth = 0.5;
        return;
    }
    if ([model isEqualToString:@"iPhone 11 Pro"] ||
        [model isEqualToString:@"iPhone (Latest)"]) {
        CGFloat pixelsInInch = 458;    // Original value = 458
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 2436.0) * pixelsInCentimeter;
        _inchAsPoints = (screenHeight / 2436.0) * pixelsInInch;
        _resetPosition = _centimeterPositionRightBottom ? 11.0 : 4.0;
        _redLineWidth = 0.5;
        return;
    }
    if ([model isEqualToString:@"iPhone 11"]) {
        CGFloat pixelsInInch = 326;    // Original value = 458
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 1792.0) * pixelsInCentimeter;
        _inchAsPoints = (screenHeight / 1792.0) * pixelsInInch;
        _resetPosition = _centimeterPositionRightBottom ? 11.0 : 4.0;
        _redLineWidth = 0.5;
        return;
    }
    if ([model isEqualToString:@"iPhone XR"]) {
        CGFloat pixelsInInch = 326;     // Original value = 326
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 1792.0) * pixelsInCentimeter;
        _inchAsPoints = (screenHeight / 1792.0) * pixelsInInch;
        _resetPosition = _centimeterPositionRightBottom ? 11.0 : 4.0;
        _redLineWidth = 0.5;
        return;
    }
    if ([model isEqualToString:@"iPhone XS Max"]) {
        CGFloat pixelsInInch = 459.3;    // Original value = 458
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 2688.0) * pixelsInCentimeter;
        _inchAsPoints = (screenHeight / 2688.0) * pixelsInInch;
        _resetPosition = _centimeterPositionRightBottom ? 11.0 : 4.0;
        _redLineWidth = 0.5;
        return;
    }
    if ([model isEqualToString:@"iPhone XS"]) {
        CGFloat pixelsInInch = 459.3;    // Original value = 458
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 2436.0) * pixelsInCentimeter;
        _inchAsPoints = (screenHeight / 2436.0) * pixelsInInch;
        _resetPosition = _centimeterPositionRightBottom ? 11.0 : 4.0;
        _redLineWidth = 0.5;
        return;
    }
    if ([model isEqualToString:@"iPhone X"]) {
        CGFloat pixelsInInch = 459.3;    // Original value = 458
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 2436.0) * pixelsInCentimeter;
        _inchAsPoints = (screenHeight / 2436.0) * pixelsInInch;
        _resetPosition = _centimeterPositionRightBottom ? 11.0 : 4.0;
        _redLineWidth = 0.5;
        return;
    }
    if ([model isEqualToString:@"iPhone SE"]) {
        // iPhone SE
        CGFloat pixelsInInch = 326.5;
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 1136.0) * pixelsInCentimeter; // or (568.0 / 1136.0) * pixelsInCentimeter
        _inchAsPoints = (screenHeight / 1136.0) * pixelsInInch;
        _redLineWidth = 0.5;
        _resetPosition = _centimeterPositionRightBottom ? 8.0 : 3.0;
        return;
    }
    if ([@[@"iPhone 6",
           @"iPhone 6s",
           @"iPhone 7",
           @"iPhone 8",
           @"iPhone SE 2nd Gen",
           @"iPhone SE 3rd Gen"
         ] containsObject:model]) {
        CGFloat pixelsInInch = 326;
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 1334.0) * pixelsInCentimeter;
        _inchAsPoints = (screenHeight / 1334.0) * pixelsInInch;
        _resetPosition = _centimeterPositionRightBottom ? 9.5 : 3.5;
        _redLineWidth = 0.5;
        return;
    }
    if ([@[@"iPhone 6 Plus",
           @"iPhone 6s Plus",
           @"iPhone 7 Plus",
           @"iPhone 8 Plus"] containsObject:model])
    {
        // iPhone 6 Plus
        CGFloat pixelsInInch = 401;    // Original value = 401
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 1920.0) * pixelsInCentimeter;
        _inchAsPoints = (screenHeight / 1920.0) * pixelsInInch;
        _resetPosition = _centimeterPositionRightBottom ? 11.0 : 4.0;
        _redLineWidth = 0.5;
        return;
    }
    if ([model isEqualToString:@"iPhone 5s"]) {
        // iPhone 5s
        CGFloat pixelsInInch = 326.5;
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 1136.0) * pixelsInCentimeter; // or (568.0 / 1136.0) * pixelsInCentimeter
        _inchAsPoints = (screenHeight / 1136.0) * pixelsInInch;
        _redLineWidth = 0.5;
        _resetPosition = _centimeterPositionRightBottom ? 8.0 : 3.0;
        return;
    }
    if ([model isEqualToString:@"iPhone 5"]) {
        // iPhone 5
        CGFloat pixelsInInch = 327.0;
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 1136.0) * pixelsInCentimeter; // or (568.0 / 1136.0) * pixelsInCentimeter
        _inchAsPoints = (screenHeight / 1136.0) * pixelsInInch;
        _redLineWidth = 0.5;
        _resetPosition = _centimeterPositionRightBottom ? 8.0 : 3.0;
        return;
    }
    if ([model isEqualToString:@"iPhone 4"])    {
        // iPhone 4
        // 326 PPI, 960 pixels, 480 points
        CGFloat pixelsInInch = 326.5;
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 960.0) * pixelsInCentimeter; // or (568.0 / 1136.0) * pixelsInCentimeter
        _inchAsPoints = (screenHeight / 960.0) * pixelsInInch;
        _redLineWidth = 0.5;
        _resetPosition = _centimeterPositionRightBottom ? 6.5 : 2.5;
        return;
    }
    if ([model isEqualToString:@"iPhone 4s"])    {
        // iPhone 4s
        // 326 PPI, 960 pixels, 480 points
        CGFloat pixelsInInch = 326.7;
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 960.0) * pixelsInCentimeter; // or (568.0 / 1136.0) * pixelsInCentimeter
        _inchAsPoints = (screenHeight / 960.0) * pixelsInInch;
        _redLineWidth = 0.5;
        _resetPosition = _centimeterPositionRightBottom ? 6.5 : 2.5;
        return;
    }
}

- (void)setupBasicMeasureForiPad:(BOOL)toPortrait model:(NSString *)model {
    CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
    CGFloat screenHeight = MAX(screenBounds.size.width, screenBounds.size.height);

    if ([@[@"iPad 2",
           @"iPad 2 (Wi-Fi)"] containsObject:model])
    {
        // iPad 2
        CGFloat pixelsInInch = 132.7;    // Announced PPI: 132
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 1024.0) * pixelsInCentimeter;
        _inchAsPoints = (screenHeight / 1024.0) * pixelsInInch;
        _resetPosition = _centimeterPositionRightBottom ? 18.0 : 7.0;
        _redLineWidth = 1.0;
        return;
    }
    if ([@[@"iPad 3rd Gen (GSM)",
           @"iPad 3rd Gen (CDMA)",
           @"iPad 3rd Gen (Wi-Fi)",
           @"iPad 4th Gen (Wi-Fi)",
           @"iPad 4th Gen (GSM+LTE)",
           @"iPad 4th Gen (CDMA+LTE)",
           @"iPad Pro 9.7 \" (Wi-Fi)",
           @"iPad Pro 9.7 \" (Wi-Fi+Cellular)",
           @"iPad 5th Gen (Wi-Fi)",
           @"iPad 5th Gen (Wi-Fi+Cellular)",
           @"iPad 6th Gen (Wi-Fi)",
           @"iPad 6th Gen (Wi-Fi+Cellular)",
           @"iPad Air 1st Gen (GSM+CDMA)",
           @"iPad Air 1st Gen (Wi-Fi)",
           @"iPad Air 1st Gen (Wi-Fi+Cellular)",
           @"iPad Air (Wi-Fi)",
           @"iPad Air 2nd Gen (Wi-Fi+Cellular)",
           @"iPad Air 2nd Gen (Wi-Fi)"] containsObject:model])
    {
        // iPad Air
        CGFloat pixelsInInch = 265.3;    // Original ppi = 264
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 2048.0) * pixelsInCentimeter;
        _inchAsPoints = (screenHeight / 2048.0) * pixelsInInch;
        _resetPosition = _centimeterPositionRightBottom ? 18.0 : 7.0;
        _redLineWidth = 0.5;
        return;
    }
    if ([@[@"iPad Air 3rd Gen (Wi-Fi)",
           @"iPad Air 3rd Gen (Wi-Fi+Cellular)"
           ] containsObject:model])
    {
        CGFloat pixelsInInch = 264;
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 2224.0) * pixelsInCentimeter;
        _inchAsPoints = (screenHeight / 2224.0) * pixelsInInch;
        _resetPosition = _centimeterPositionRightBottom ? 18.0 : 7.0;
        _redLineWidth = 0.5;
        return;
    }
    if ([@[@"iPad Air 4th Gen (Wi-Fi)",
           @"iPad Air 4th Gen (Wi-Fi+Cellular)",
           @"iPad Air 5th Gen (Wi-Fi)",
           @"iPad Air 5th Gen (Wi-Fi+Cellular)",
           @"iPad Air 11-inch (M2)",
           @"iPad Air 11-inch (M2) Cellular",
           @"iPad 10th Gen",
         ] containsObject:model])
    {
        CGFloat pixelsInInch = 264;
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 2360.0) * pixelsInCentimeter;
        _inchAsPoints = (screenHeight / 2360.0) * pixelsInInch;
        _resetPosition = _centimeterPositionRightBottom ? 15.0 : 6.0;
        _redLineWidth = 0.5;
        return;
    }
    if ([@[@"iPad mini 1st Gen (CDMA+LTE)",
           @"iPad mini 1st Gen (GSM+LTE)",
           @"iPad mini 1st Gen (Wi-Fi)"] containsObject:model])
    {
        // iPad mini
        CGFloat pixelsInInch = 163.4;
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 1024.0) * pixelsInCentimeter;
        _inchAsPoints = (screenHeight / 1024.0) * pixelsInInch;
        _resetPosition = _centimeterPositionRightBottom ? 14.0 : 5.5;
        _redLineWidth = 1.0;
        return;
    }
    if ([@[@"iPad mini 2nd Gen (Wi-Fi)",
           @"iPad mini 2nd Gen (Wi-Fi+Cellular)"] containsObject:model])
    {
        // iPad mini Retina
        CGFloat pixelsInInch = 326.8;               // 326
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 2048.0) * pixelsInCentimeter;
        _inchAsPoints = (screenHeight / 2048.0) * pixelsInInch;
        _resetPosition = _centimeterPositionRightBottom ? 14.0 : 5.5;
        _redLineWidth = 0.5;
        return;
    }
    if ([@[@"iPad mini 3rd Gen (Wi-Fi)",
           @"iPad mini 3rd Gen (Wi-Fi+Cellular)",
           @"iPad mini 4th Gen (Wi-Fi)",
           @"iPad mini 4th Gen (Wi-Fi+Cellular)",
           @"iPad mini 5th Gen (Wi-Fi)",
           @"iPad mini 5th Gen (Wi-Fi+Cellular)"] containsObject:model])
    {
        // iPad mini 3
        CGFloat pixelsInInch = 327.2;
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 2048.0) * pixelsInCentimeter;
        _inchAsPoints = (screenHeight / 2048.0) * pixelsInInch;
        _resetPosition = _centimeterPositionRightBottom ? 14.0 : 5.5;
        _redLineWidth = 0.5;
        return;
    }
    if ([@[@"iPad mini 6th Gen (Wi-Fi)",
           @"iPad mini 6th Gen (Wi-Fi+Cellular)",
           @"iPad mini A17 Pro (Wi-Fi)",
           @"iPad mini A17 Pro (Wi-Fi+Cellular)",
         ] containsObject:model])
    {
        // iPad mini 6th
        CGFloat pixelsInInch = 326;
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 2266.0) * pixelsInCentimeter;
        _inchAsPoints = (screenHeight / 2266.0) * pixelsInInch;
        _resetPosition = _centimeterPositionRightBottom ? 15.0 : 6.0;
        _redLineWidth = 0.5;
        return;
    }
    if ([@[@"iPad Pro 12.9 \" 1st Gen (Wi-Fi)",
           @"iPad Pro 12.9 \" 1st Gen (Wi-Fi+Cellular)",
           @"iPad Pro 12.9 \" 2nd Gen (Wi-Fi)",
           @"iPad Pro 12.9 \" 2nd Gen (Wi-Fi+Cellular)",
           @"iPad Pro 12.9 \" 3rd Gen (Wi-Fi)",
           @"iPad Pro 12.9 \" 3rd Gen (Wi-Fi, 1TB)",
           @"iPad Pro 12.9 \" 3rd Gen (Wi-Fi+Cellular)",
           @"iPad Pro 12.9 \" 3rd Gen (Wi-Fi+Cellular, 1TB)",
           @"iPad Pro 12.9 \" 4th Gen (Wi-Fi)",
           @"iPad Pro 12.9 \" 4th Gen (Wi-Fi+Cellular)",
           @"iPad Pro 12.9 inch 5th Gen",
           @"iPad Pro 12.9 inch 6th Gen",
           @"iPad Air 13-inch (M2)",
           @"iPad Air 13-inch (M2) Cellular",
         ] containsObject:model]
        )
    {
        // iPad Pro
        CGFloat pixelsInInch = 264.7;
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 2732.0) * pixelsInCentimeter;
        _inchAsPoints = (screenHeight / 2732.0) * pixelsInInch;
        _resetPosition = _centimeterPositionRightBottom ? 23.0 : 9.0;
        _redLineWidth = 0.5;
        return;
    }
    if ([@[@"iPad Pro M4 13 inch (Wi-Fi)",
           @"iPad Pro M4 13 inch (Wi-Fi+Cellular)",
         ] containsObject:model]
        )
    {
        // iPad Pro
        CGFloat pixelsInInch = 264.0;
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 2752.0) * pixelsInCentimeter;
        _inchAsPoints = (screenHeight / 2752.0) * pixelsInInch;
        _resetPosition = _centimeterPositionRightBottom ? 23.0 : 9.0;
        _redLineWidth = 0.5;
        return;
    }
    if ([@[@"iPad Pro 10.5 \" (Wi-Fi)",
           @"iPad Pro 10.5 \" (Wi-Fi+Cellular)"] containsObject:model])
    {
        // iPad Pro
        CGFloat pixelsInInch = 264.7;
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 2224.0) * pixelsInCentimeter;
        _inchAsPoints = (screenHeight / 2224.0) * pixelsInInch;
        _resetPosition = _centimeterPositionRightBottom ? 18.0 : 7.0;
        _redLineWidth = 0.5;
        return;
    }
    if ([@[@"iPad Pro 11 \" 1st Gen (Wi-Fi)",
           @"iPad Pro 11 \" 1st Gen (Wi-Fi, 1TB)",
           @"iPad Pro 11 \" 1st Gen (Wi-Fi+Cellular)",
           @"iPad Pro 11 \" 1st Gen (Wi-Fi+Cellular, 1TB)",
           @"iPad Pro 11 \" 2nd Gen (Wi-Fi)",
           @"iPad Pro 11 \" 2nd Gen (Wi-Fi+Cellular)",
           @"iPad Pro 11 inch 3rd Gen",
           @"iPad Pro 11 inch 4th Gen",
         ] containsObject:model])
    {
        // iPad Pro
        CGFloat pixelsInInch = 264.7;
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 2388.0) * pixelsInCentimeter;
        _inchAsPoints = (screenHeight / 2388.0) * pixelsInInch;
        _resetPosition = _centimeterPositionRightBottom ? 15.0 : 6.0;
        _redLineWidth = 0.5;
        return;
    }
    if ([@[@"iPad Pro M4 11 inch (Wi-Fi)",
           @"iPad Pro M4 11 inch (Wi-Fi+Cellular)",
         ] containsObject:model])
    {
        // iPad Pro
        CGFloat pixelsInInch = 264.0;
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 2420.0) * pixelsInCentimeter;
        _inchAsPoints = (screenHeight / 2420.0) * pixelsInInch;
        _resetPosition = _centimeterPositionRightBottom ? 15.0 : 6.0;
        _redLineWidth = 0.5;
        return;
    }
    if ([@[@"iPad 7th Gen 10.2 \" (Wi-Fi)",
           @"iPad 7th Gen 10.2 \" (Wi-Fi+Cellular)",
           @"iPad 8th Gen (Wi-Fi)",
           @"iPad 8th Gen (Wi-Fi+Cellular)",
           @"iPad 9th Gen (Wi-Fi)",
           @"iPad 9th Gen (Wi-Fi+Cellular)",
         ] containsObject:model]
        )
    {
        CGFloat pixelsInInch = 264.7;
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 2160.0) * pixelsInCentimeter;
        _inchAsPoints = (screenHeight / 2160.0) * pixelsInInch;
        _resetPosition = _centimeterPositionRightBottom ? 18.0 : 7.0;
        _redLineWidth = 0.5;
        return;
    }
}

- (void)setupBasicMeasureForiPod:(BOOL)toPortrait model:(NSString *)model {
    CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
    CGFloat screenHeight = MAX(screenBounds.size.width, screenBounds.size.height);
    
    if ([@[@"iPod Touch (5th generation)",
           @"iPod Touch (6th generation)",
           @"iPod Touch (7th generation)"] containsObject:model])
    {
        // iPod touch 5
        CGFloat pixelsInInch = 326.7;
        CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
        _centimeterAsPoints = (screenHeight / 1136.0) * pixelsInCentimeter; // or (568.0 / 1136.0) * pixelsInCentimeter
        _inchAsPoints = (screenHeight / 1136.0) * pixelsInInch;
        _redLineWidth = 0.5;
        _resetPosition = _centimeterPositionRightBottom ? 8.0 : 3.0;
    }
}

- (void)setupBasicMeasureForInterfaceOrientation:(BOOL)toPortrait {
	NSString *model = [A3UIDevice platformString];
    CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
    CGFloat screenHeight = MAX(screenBounds.size.width, screenBounds.size.height);

    if ([model hasPrefix:@"iPhone"]) {
        [self setupBasicMeasureForiPhone:toPortrait model:model];
    } else if ([model hasPrefix:@"iPad"]) {
        [self setupBasicMeasureForiPad:toPortrait model:model];
    } else {
        [self setupBasicMeasureForiPod:toPortrait model:model];
    }

	if (([UIWindow interfaceOrientationIsPortrait] && toPortrait) || ([UIWindow interfaceOrientationIsLandscape] && !toPortrait)) {
		_screenWidth = screenBounds.size.width;
		_screenHeight = screenBounds.size.height;
		
	} else {
		_screenWidth = screenBounds.size.height;
		_screenHeight = screenBounds.size.width;
	}
	if (toPortrait) {
		_numberOfCentimetersInScreen = floor(_screenHeight / _centimeterAsPoints) + 2;
		_numberOfInchesInScreen = floor(_screenHeight) / _inchAsPoints + 2;
	} else {
		_numberOfCentimetersInScreen = floor(_screenWidth / _centimeterAsPoints) + 2;
		_numberOfInchesInScreen = floor(_screenWidth) / _inchAsPoints + 2;
	}
	_markingsWidth = _centimeterAsPoints;

	FNLOG(@"centimeter in points = %f, inch in points = %f", _centimeterAsPoints, _inchAsPoints);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setupSubviews {
	CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	_rulerScrollView = [[UIScrollView alloc] initWithFrame:screenBounds];
	_rulerScrollView.scrollsToTop = NO;
	[self setupScrollViewContentSizeToInterfaceOrientation:[UIWindow interfaceOrientationIsPortrait]];
	_rulerScrollView.contentOffset = CGPointMake(0, _rulerScrollView.contentSize.height - _screenHeight);
	_rulerScrollView.delegate = self;
	_rulerScrollView.showsVerticalScrollIndicator = NO;
	_rulerScrollView.showsHorizontalScrollIndicator = NO;
	[self.view addSubview:_rulerScrollView];

	[_rulerScrollView makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.view);
	}];

	_centimetersMarkingViews = [NSMutableArray new];
	_centimeterLabels = [NSMutableArray new];

	for (NSInteger idx = 0; idx < _numberOfCentimetersInScreen; idx++) {
		A3MarkingsView *centimeterMarkingView = [A3MarkingsView new];
		centimeterMarkingView.clipsToBounds = NO;
		centimeterMarkingView.horizontalDirection = _centimeterPositionRightBottom ? A3MarkingsDirectionRight : A3MarkingsDirectionLeft;
		centimeterMarkingView.markingsType = A3MarkingsTypeCentimeters;
		[_rulerScrollView addSubview:centimeterMarkingView];
		[_centimetersMarkingViews addObject:centimeterMarkingView];

		UILabel *markLabel = [UILabel new];
		markLabel.textColor = [UIColor blackColor];
		markLabel.font = [UIFont systemFontOfSize:10.0];
		markLabel.transform = CGAffineTransformMakeRotation(-M_PI / 2);
		[centimeterMarkingView addSubview:markLabel];

		[_centimeterLabels addObject:markLabel];
	}

	_inchesMarkingViews = [NSMutableArray new];
	_inchLabels = [NSMutableArray new];

	for (NSInteger idx = 0; idx < _numberOfInchesInScreen; idx++) {
		A3MarkingsView *inchMarkingView = [A3MarkingsView new];
		inchMarkingView.clipsToBounds = NO;
		inchMarkingView.horizontalDirection = _centimeterPositionRightBottom ? A3MarkingsDirectionLeft : A3MarkingsDirectionRight;
		inchMarkingView.markingsType = A3MarkingsTypeInches;
		[_rulerScrollView addSubview:inchMarkingView];
		[_inchesMarkingViews addObject:inchMarkingView];

		UILabel *markLabel = [UILabel new];
		markLabel.textColor = [UIColor blackColor];
		markLabel.font = [UIFont systemFontOfSize:10];
		markLabel.transform = CGAffineTransformMakeRotation(-M_PI / 2);
		[inchMarkingView addSubview:markLabel];

		[_inchLabels addObject:markLabel];
	}

	_redLineView = [UIView new];
	_redLineView.backgroundColor = [UIColor redColor];
	[self.view addSubview:_redLineView];
	[self resetRedLinePositionForInterfaceOrientation:[UIWindow interfaceOrientationIsPortrait]];

	_redLineGlassView = [UIView new];
	_redLineGlassView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:128.0/255.0 blue:1.0/255.0 alpha:0.3];
	_redLineGlassView.layer.borderWidth = 1.0;
	_redLineGlassView.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.05].CGColor;
	[self.view addSubview:_redLineGlassView];

	_topValueLabel = [UILabel new];
	_topValueLabel.font = [UIFont systemFontOfSize:18.0];
	_topValueLabel.textAlignment = NSTextAlignmentRight;
	_topValueLabel.textColor = [UIColor blackColor];
	[_redLineView addSubview:_topValueLabel];

	_bottomValueLabel = [UILabel new];
	_bottomValueLabel.font = [UIFont systemFontOfSize:18.0];
	_bottomValueLabel.textAlignment = NSTextAlignmentRight;
	_bottomValueLabel.textColor = [UIColor blackColor];
	[_redLineView addSubview:_bottomValueLabel];

	[self updateLabelsForInterfaceOrientation:[UIWindow interfaceOrientationIsPortrait]];

	_fingerDragView = [UIImageView new];
    _fingerDragView.image = [UIImage imageNamed:@"finger_drag"];
	[self.view addSubview:_fingerDragView];

	_fingerDragViewGestureRecognizer = [UIPanGestureRecognizer new];
	[_fingerDragViewGestureRecognizer addTarget:self action:@selector(handleDrag:)];
	[_redLineGlassView addGestureRecognizer:_fingerDragViewGestureRecognizer];

	_rulerDragView = [UIImageView new];
    UIImage *image = [[UIImage imageNamed:@"horizontal_drag"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _rulerDragView.image = image;

	[_rulerScrollView addSubview:_rulerDragView];
	[self layoutRulerDragViewToInterfaceOrientation:[UIWindow interfaceOrientationIsPortrait]];

	[self addButtons];

	[self layoutMarkingsToInterfaceOrientation:[UIWindow interfaceOrientationIsPortrait]];
}

- (void)setupScrollViewContentSizeToInterfaceOrientation:(BOOL)toPortrait {
	if (toPortrait) {
		_rulerScrollView.contentSize = CGSizeMake(_screenWidth, [self rulerSize]);
	} else {
		_rulerScrollView.contentSize = CGSizeMake([self rulerSize], _screenHeight);
	}
}

- (CGFloat)rulerSize {
	return _centimeterAsPoints * 100;
}

- (CGFloat)hiddenSpace {
	if ([UIWindow interfaceOrientationIsPortrait]) {
		if (_rulerScrollDirectionReverse) {
			return _rulerScrollView.contentOffset.y;
		} else {
			return ([self rulerSize] - _screenHeight) - _rulerScrollView.contentOffset.y;
		}
	} else {
		if (_rulerScrollDirectionReverse) {
			return ([self rulerSize] - _screenWidth) - _rulerScrollView.contentOffset.x;
		} else {
			return _rulerScrollView.contentOffset.x;
		}
	}
}

- (void)setHiddenSpace:(CGFloat)hiddenSpace interfaceOrientation:(BOOL)isPortrait {
	if (isPortrait) {
		if (_rulerScrollDirectionReverse) {
			_rulerScrollView.contentOffset = CGPointMake(0, hiddenSpace);
		} else {
			_rulerScrollView.contentOffset = CGPointMake(0, [self rulerSize] - _screenHeight - hiddenSpace);
		}
	} else {
		if (_rulerScrollDirectionReverse) {
			_rulerScrollView.contentOffset = CGPointMake([self rulerSize] - _screenWidth - hiddenSpace, 0);
		} else {
			_rulerScrollView.contentOffset = CGPointMake(hiddenSpace, 0);
		}
	}
}

- (void)moveRedLineToPosition:(double)position interfaceOrientation:(BOOL)isPortrait {
	CGFloat activeUnit;
	if (_centimeterPositionRightBottom) {
		activeUnit = _centimeterAsPoints;
	} else {
		activeUnit = _inchAsPoints;
	}
	if (isPortrait) {
		CGFloat y;
		if (_rulerScrollDirectionReverse) {
			y = position * activeUnit - _rulerScrollView.contentOffset.y;
		} else {
			y = _rulerScrollView.contentSize.height - position * activeUnit - _rulerScrollView.contentOffset.y - 0.5;
		}
		_redLineView.frame = CGRectMake(0, y, _screenWidth, _redLineWidth);
		_fingerDragView.frame = CGRectMake(_screenWidth * 0.6, _redLineView.frame.origin.y - 21.0, 42.0, 42.0);
	} else {
		CGFloat x;
		if (_rulerScrollDirectionReverse) {
			x = _rulerScrollView.contentSize.width - position * activeUnit - _rulerScrollView.contentOffset.x - 1.0;
		} else {
			x = position * activeUnit - _rulerScrollView.contentOffset.x - 1.0;
		}
		_redLineView.frame = CGRectMake(x, 0, _redLineWidth, _screenHeight);
		_fingerDragView.frame = CGRectMake(_redLineView.frame.origin.x - 21.0, _screenHeight * 0.6, 42.0, 42.0);
	}
}

- (void)resetRedLinePositionForInterfaceOrientation:(BOOL)isPortrait {
	// moveRedLineToCentimeter 와 거의 유사하지만 portrait 일 때 hiddenSpace (scrollView.contentOffset)을 고려하지 않는 점이 다르다.
	// 초기화할때 scrollView 의 contentOffset 을 변경하는데, animation 이 함께 일어나는 경우, offset 이 정확하지 않아 초기화 위치를 얻을 수가 없어
	// 별도로 고려하지 않는 멤버를 추가했다. 물론 원래의 멤버에 옵션을 주는 방법도 있었지만, 복잡도를 낮추기 위해서 중복을 감수했다.
	CGFloat activeUnit;
	if (_centimeterPositionRightBottom) {
		activeUnit = _centimeterAsPoints;
	} else {
		activeUnit = _inchAsPoints;
	}
	if (isPortrait) {
		CGFloat y;
		if (_rulerScrollDirectionReverse) {
			y = _resetPosition * activeUnit + _rulerScrollView.contentOffset.y;
		} else {
			y = _rulerScrollView.contentSize.height - _resetPosition * activeUnit - _rulerScrollView.contentOffset.y - 0.5;
		}
		_redLineView.frame = CGRectMake(0, y, _screenWidth, _redLineWidth);
		FNLOGRECT(_redLineView.frame);
	} else {
		CGFloat x;
		x = _resetPosition * activeUnit - 1.0;
		if (_rulerScrollDirectionReverse) {
			x = _rulerScrollView.contentSize.width - _resetPosition * activeUnit - _rulerScrollView.contentOffset.x - 1.0;
		} else {
			x = _resetPosition * activeUnit - 1.0;
		}
		_redLineView.frame = CGRectMake(x, 0, _redLineWidth, _screenHeight);
	}
	[self updateLabelsForInterfaceOrientation:isPortrait];
}

- (CGFloat)currentPositionForInterfaceOrientation:(BOOL)isPortrait {
	CGFloat currentPosition;
	if (_centimeterPositionRightBottom) {
		currentPosition = [self currentCentimeterForInterfaceOrientation:isPortrait];
	} else {
		currentPosition = [self currentInchesForInterfaceOrientation:isPortrait];
	}
	return round(currentPosition * 100.0) / 100.0;
}

- (CGFloat)currentCentimeterForInterfaceOrientation:(BOOL)isPortrait {
	if (isPortrait) {
		if (_rulerScrollDirectionReverse) {
			return (_rulerScrollView.contentOffset.y + _redLineView.frame.origin.y) / _centimeterAsPoints;
		} else {
			return (_rulerScrollView.contentSize.height - (_rulerScrollView.contentOffset.y + _screenHeight) + (_screenHeight - _redLineView.frame.origin.y - 0.5)) / _centimeterAsPoints;
		}
	} else {
		if (_rulerScrollDirectionReverse) {
			return (_rulerScrollView.contentSize.width - (_rulerScrollView.contentOffset.x + _screenWidth) + (_screenWidth - _redLineView.frame.origin.x) - 1.0) / _centimeterAsPoints;
		} else {
			return (_rulerScrollView.contentOffset.x + _redLineView.frame.origin.x + 1.0) / _centimeterAsPoints;
		}
	}
}

- (CGFloat)currentInchesForInterfaceOrientation:(BOOL)isPortrait {
	if (isPortrait) {
		if (_rulerScrollDirectionReverse) {
			return (_rulerScrollView.contentOffset.y + _redLineView.frame.origin.y) / _inchAsPoints;
		} else {
			return (_rulerScrollView.contentSize.height - (_rulerScrollView.contentOffset.y + _screenHeight) + (_screenHeight - _redLineView.frame.origin.y)) / _inchAsPoints;
		}
	} else {
		if (_rulerScrollDirectionReverse) {
			return (_rulerScrollView.contentSize.width - (_rulerScrollView.contentOffset.x + _screenWidth) + (_screenWidth - _redLineView.frame.origin.x) - 1.0) / _inchAsPoints;
		} else {
			return (_rulerScrollView.contentOffset.x + _redLineView.frame.origin.x + 1.0) / _inchAsPoints;
		}
	}
}

- (void)handleDrag:(UIPanGestureRecognizer *)gestureRecognizer {
	CGPoint location = [gestureRecognizer locationInView:self.view];

	if ([UIWindow interfaceOrientationIsPortrait]) {
		_redLineView.frame = CGRectMake(0, location.y, _screenWidth, _redLineWidth);
	} else {
		_redLineView.frame = CGRectMake(location.x, 0, _redLineWidth, _screenHeight);
	}
	CGFloat currentPosition = [self currentPositionForInterfaceOrientation:[UIWindow interfaceOrientationIsPortrait]];
	CGFloat roundBySecondFraction = floor(currentPosition * 100.0)/100.0;
	if ((round(currentPosition) ==  roundBySecondFraction + 0.01) ||
		(round(currentPosition) == roundBySecondFraction - 0.01)) {
		[self moveRedLineToPosition:round(currentPosition) interfaceOrientation:[UIWindow interfaceOrientationIsPortrait]];
	}

	[self updateLabelsForInterfaceOrientation:[UIWindow interfaceOrientationIsPortrait]];
}

- (NSString *)centimeterValueString:(BOOL)isPortrait {
	CGFloat centimeter = [self currentCentimeterForInterfaceOrientation:isPortrait];
	return [NSString stringWithFormat:@"%@ cm",
									  [_numberFormatter stringFromNumber:@(centimeter)]];
}

- (NSString *)inchesValueString:(BOOL)isPortrait {
	CGFloat inch = [self currentInchesForInterfaceOrientation:isPortrait];
	double fraction = inch - floor(inch);
	NSString *inchFractionString = [self fractionForInches:fraction];
	if ([inchFractionString length]) {
		inchFractionString = [NSString stringWithFormat:@"(%@)", inchFractionString];
	}
	return [NSString stringWithFormat:@"%@%@ %@",
									  [_numberFormatter stringFromNumber:@(inch)],
									  inchFractionString,
					NSLocalizedStringFromTable(@"inches", @"unit", nil)];
}

- (void)updateLabelsForInterfaceOrientation:(BOOL)isPortrait {
	_topValueLabel.text = _centimeterPositionRightBottom ? [self inchesValueString:isPortrait] : [self centimeterValueString:isPortrait];
	_bottomValueLabel.text = _centimeterPositionRightBottom ? [self centimeterValueString:isPortrait] : [self inchesValueString:isPortrait];

	if (isPortrait) {
		_topValueLabel.transform = CGAffineTransformMakeRotation(-M_PI / 2);
		_bottomValueLabel.transform = CGAffineTransformMakeRotation(-M_PI / 2);
		_fingerDragView.transform = CGAffineTransformMakeRotation(-M_PI / 2);

		if (_redLineView.frame.origin.y > _screenHeight / 2.0) {
			_topValueLabel.frame = CGRectMake(_screenWidth / 2 - 25, -5 - 240, 24, 240);
			_topValueLabel.textAlignment = NSTextAlignmentLeft;

			_bottomValueLabel.frame = CGRectMake(_screenWidth / 2, -5 - 240, 24, 240);
			_bottomValueLabel.textAlignment = NSTextAlignmentLeft;
		} else {
			_topValueLabel.frame = CGRectMake(_screenWidth / 2 - 25, 5, 24, 240);
			_topValueLabel.textAlignment = NSTextAlignmentRight;

			_bottomValueLabel.frame = CGRectMake(_screenWidth / 2, 5, 24, 240);
			_bottomValueLabel.textAlignment = NSTextAlignmentRight;
		}
		_fingerDragView.frame = CGRectMake(_screenWidth * 0.6, _redLineView.frame.origin.y - 21.0, 42.0, 42.0);

		[_redLineGlassView remakeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(@-1);
			make.centerY.equalTo(self->_redLineView.centerY);
			make.width.equalTo(@(self->_screenWidth + 2.0));
			make.height.equalTo(@(self->_centimeterAsPoints));
		}];
	} else {
		_topValueLabel.transform = CGAffineTransformIdentity;
		_bottomValueLabel.transform = CGAffineTransformIdentity;
		_fingerDragView.transform = CGAffineTransformIdentity;

		if (_redLineView.frame.origin.x <= _screenWidth / 2.0) {
			CGFloat x = 5;
			_topValueLabel.frame = CGRectMake(x, _screenHeight / 2 - 25, 240, 24);
			_topValueLabel.textAlignment = NSTextAlignmentLeft;

			_bottomValueLabel.frame = CGRectMake(x, _screenHeight / 2, 240, 24);
			_bottomValueLabel.textAlignment = NSTextAlignmentLeft;
		} else {
			CGFloat x = -240 - 5;
			_topValueLabel.frame = CGRectMake(x, _screenHeight / 2 - 25, 240, 24);
			_topValueLabel.textAlignment = NSTextAlignmentRight;

			_bottomValueLabel.frame = CGRectMake(x, _screenHeight / 2, 240, 24);
			_bottomValueLabel.textAlignment = NSTextAlignmentRight;
		}
		_fingerDragView.frame = CGRectMake(_redLineView.frame.origin.x - 21.0, _screenHeight * 0.6, 42, 42);

		[_redLineGlassView remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self->_redLineView.centerX);
			make.top.equalTo(@(-1));
			make.width.equalTo(@(self->_centimeterAsPoints));
			make.height.equalTo(@(self->_screenHeight + 2.0));
		}];
	}
}

- (void)layoutMarkingsToInterfaceOrientation:(BOOL)toPortrait {
	if (_centimeterPositionRightBottom) {
		[self layoutMarkingsCentimeterRightBottomToPortrait:toPortrait];
	} else {
		[self layoutMarkingsCentimeterLeftTopToPortrait:toPortrait];
	}
}

- (void)layoutMarkingsCentimeterRightBottomToPortrait:(BOOL)toPortrait {
	NSInteger centimeterStartIndex;
	if (toPortrait) {
		if (_rulerScrollDirectionReverse) {
			centimeterStartIndex = floor(_rulerScrollView.contentOffset.y / _centimeterAsPoints);
		} else {
			centimeterStartIndex = floor((_rulerScrollView.contentSize.height - (_rulerScrollView.contentOffset.y + _screenHeight)) / _centimeterAsPoints);
		}
	} else {
		if (_rulerScrollDirectionReverse) {
			centimeterStartIndex = floor((_rulerScrollView.contentSize.width - (_rulerScrollView.contentOffset.x + _screenWidth)) / _centimeterAsPoints);
		} else {
			centimeterStartIndex = floor(_rulerScrollView.contentOffset.x / _centimeterAsPoints);
		}
	}

	if (centimeterStartIndex == _oldMarkingsStartIndex) {
		return;
	}

	_oldMarkingsStartIndex = centimeterStartIndex;

	[_centimetersMarkingViews enumerateObjectsUsingBlock:^(A3MarkingsView *markingsView, NSUInteger idx, BOOL *stop) {
		markingsView.drawPortrait = toPortrait;
		markingsView.horizontalDirection = A3MarkingsDirectionRight;
		markingsView.verticalDirection = _rulerScrollDirectionReverse ? A3MarkingsVerticalDirectionDown : A3MarkingsVerticalDirectionUp;
		if (toPortrait) {
			if (_rulerScrollDirectionReverse) {
				markingsView.frame = CGRectMake(_screenWidth - _centimeterAsPoints, (idx + centimeterStartIndex) * _centimeterAsPoints - 1, _markingsWidth, _centimeterAsPoints);
			} else {
				markingsView.frame = CGRectMake(_screenWidth - _centimeterAsPoints, _rulerScrollView.contentSize.height - (idx + centimeterStartIndex) * _centimeterAsPoints - _centimeterAsPoints + 1, _markingsWidth, _centimeterAsPoints);
			}
		} else {
			if (_rulerScrollDirectionReverse) {
				markingsView.frame = CGRectMake(_rulerScrollView.contentSize.width - _centimeterAsPoints * (idx + centimeterStartIndex) - _centimeterAsPoints + 1, _screenHeight - _markingsWidth, _centimeterAsPoints, _markingsWidth);
			} else {
				markingsView.frame = CGRectMake(_centimeterAsPoints * (idx + centimeterStartIndex) - 2, _screenHeight - _markingsWidth, _centimeterAsPoints, _markingsWidth);
			}
		}
#ifdef DEBUG
		if (idx + centimeterStartIndex == 0) {
			FNLOG(@"*******************");
			FNLOGRECT(markingsView.frame);
			FNLOG(@"*******************");
		}
#endif
	}];

	[_centimeterLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
		if (toPortrait) {
			if (_rulerScrollDirectionReverse) {
				[label remakeConstraints:^(MASConstraintMaker *make) {
					make.bottom.equalTo(label.superview.bottom);
					make.left.equalTo(label.superview.left);
				}];
			} else {
				[label remakeConstraints:^(MASConstraintMaker *make) {
					make.top.equalTo(label.superview.top);
					make.left.equalTo(label.superview.left);
				}];
			}
		} else {
			if (_rulerScrollDirectionReverse) {
				[label remakeConstraints:^(MASConstraintMaker *make) {
					make.top.equalTo(label.superview.top).with.offset(-1);
					make.left.equalTo(label.superview.left).with.offset(1);
				}];
			} else {
				[label remakeConstraints:^(MASConstraintMaker *make) {
					make.top.equalTo(label.superview.top).with.offset(-2);
					make.right.equalTo(label.superview.right).with.offset(-3);
				}];
			}
		}
		label.text = [NSString stringWithFormat:@"%ld", (long)(idx + centimeterStartIndex + 1)];
		label.transform = !toPortrait ? CGAffineTransformIdentity : CGAffineTransformMakeRotation(-M_PI / 2);
	}];

	NSInteger inchStartIndex;
	if (toPortrait) {
		if (_rulerScrollDirectionReverse) {
			inchStartIndex = floor(_rulerScrollView.contentOffset.y / _inchAsPoints);
		} else {
			inchStartIndex = floor((_rulerScrollView.contentSize.height - (_rulerScrollView.contentOffset.y + _screenHeight)) / _inchAsPoints);
		}
	} else {
		if (_rulerScrollDirectionReverse) {
			inchStartIndex = floor((_rulerScrollView.contentSize.width - (_rulerScrollView.contentOffset.x + _screenWidth)) / _inchAsPoints);
		} else {
			inchStartIndex = floor(_rulerScrollView.contentOffset.x / _inchAsPoints);
		}
	}
	[_inchesMarkingViews enumerateObjectsUsingBlock:^(A3MarkingsView *markingsView, NSUInteger idx, BOOL *stop) {
		markingsView.drawPortrait = toPortrait;
		markingsView.horizontalDirection = A3MarkingsDirectionLeft;
		markingsView.verticalDirection = _rulerScrollDirectionReverse ? A3MarkingsVerticalDirectionDown : A3MarkingsVerticalDirectionUp;
		if (toPortrait) {
			if (_rulerScrollDirectionReverse) {
				markingsView.frame = CGRectMake(0, (idx + inchStartIndex) * _inchAsPoints - 1, _markingsWidth, _inchAsPoints);
			} else {
				markingsView.frame = CGRectMake(0, _rulerScrollView.contentSize.height - (idx + inchStartIndex) * _inchAsPoints - _inchAsPoints + 2, _markingsWidth, _inchAsPoints);
			}
		} else {
			if (_rulerScrollDirectionReverse) {
				markingsView.frame = CGRectMake(_rulerScrollView.contentSize.width - (idx + inchStartIndex) * _inchAsPoints - _inchAsPoints + 1, 0, _inchAsPoints, _markingsWidth);
			} else {
				markingsView.frame = CGRectMake((idx + inchStartIndex) * _inchAsPoints - 2, 0, _inchAsPoints, _markingsWidth);
			}
		}
#ifdef DEBUG
		if (idx + centimeterStartIndex == 0) {
			FNLOG(@"*******************");
			FNLOGRECT(markingsView.frame);
			FNLOG(@"*******************");
		}
#endif
	}];

	[_inchLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
		if (toPortrait) {
			if (_rulerScrollDirectionReverse) {
				[label remakeConstraints:^(MASConstraintMaker *make) {
					make.right.equalTo(label.superview.right);
					make.bottom.equalTo(label.superview.bottom);
				}];
			} else {
				[label remakeConstraints:^(MASConstraintMaker *make) {
					make.right.equalTo(label.superview.right);
					make.top.equalTo(label.superview.top);
				}];
			}
		} else {
			if (_rulerScrollDirectionReverse) {
				[label remakeConstraints:^(MASConstraintMaker *make) {
					make.left.equalTo(label.superview.left).with.offset(3);
					make.bottom.equalTo(label.superview.bottom).with.offset(2);
				}];
			} else {
				[label remakeConstraints:^(MASConstraintMaker *make) {
					make.right.equalTo(label.superview.right).with.offset(-4);
					make.bottom.equalTo(label.superview.bottom).with.offset(2);
				}];
			}
		}
		label.text = [NSString stringWithFormat:@"%ld", (long)(idx + inchStartIndex + 1)];
		label.transform = !toPortrait ? CGAffineTransformIdentity : CGAffineTransformMakeRotation(-M_PI / 2);
	}];
}

- (void)layoutMarkingsCentimeterLeftTopToPortrait:(BOOL)toPortrait {
	NSInteger centimeterStartIndex;
	if (toPortrait) {
		if (_rulerScrollDirectionReverse) {
			centimeterStartIndex = floor(_rulerScrollView.contentOffset.y / _centimeterAsPoints);
		} else {
			centimeterStartIndex = floor((_rulerScrollView.contentSize.height - (_rulerScrollView.contentOffset.y + _screenHeight)) / _centimeterAsPoints);
		}
	} else {
		if (_rulerScrollDirectionReverse) {
			centimeterStartIndex = floor((_rulerScrollView.contentSize.width - (_rulerScrollView.contentOffset.x + _screenWidth)) / _centimeterAsPoints);
		} else {
			centimeterStartIndex = floor(_rulerScrollView.contentOffset.x / _centimeterAsPoints);
		}
	}

	if (centimeterStartIndex == _oldMarkingsStartIndex) {
		return;
	}

	_oldMarkingsStartIndex = centimeterStartIndex;

	[_centimetersMarkingViews enumerateObjectsUsingBlock:^(A3MarkingsView *markingsView, NSUInteger idx, BOOL *stop) {
		markingsView.drawPortrait = toPortrait;
		markingsView.horizontalDirection = A3MarkingsDirectionLeft;
		markingsView.verticalDirection = _rulerScrollDirectionReverse ? A3MarkingsVerticalDirectionDown : A3MarkingsVerticalDirectionUp;
		if (toPortrait) {
			if (_rulerScrollDirectionReverse) {
				markingsView.frame = CGRectMake(0, (idx + centimeterStartIndex) * _centimeterAsPoints - 1, _markingsWidth, _centimeterAsPoints);
			} else {
				markingsView.frame = CGRectMake(0, _rulerScrollView.contentSize.height - (idx + centimeterStartIndex) * _centimeterAsPoints - _centimeterAsPoints + 1, _markingsWidth, _centimeterAsPoints);
			}
		} else {
			if (_rulerScrollDirectionReverse) {
				markingsView.frame = CGRectMake(_rulerScrollView.contentSize.width - _centimeterAsPoints * (idx + centimeterStartIndex) - _centimeterAsPoints + 1, 0, _centimeterAsPoints, _markingsWidth);
			} else {
				markingsView.frame = CGRectMake(_centimeterAsPoints * (idx + centimeterStartIndex) - 1, 0, _centimeterAsPoints, _markingsWidth);
			}
		}
#ifdef DEBUG
		if (idx + centimeterStartIndex == 0) {
			FNLOG(@"*******************");
			FNLOGRECT(markingsView.frame);
			FNLOG(@"*******************");
		}
#endif
	}];

	[_centimeterLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
		if (toPortrait) {
			if (_rulerScrollDirectionReverse) {
				[label remakeConstraints:^(MASConstraintMaker *make) {
					make.bottom.equalTo(label.superview.bottom).with.offset(-1);
					make.right.equalTo(label.superview.right);
				}];
			} else {
				[label remakeConstraints:^(MASConstraintMaker *make) {
					make.top.equalTo(label.superview.top).with.offset(1);
					make.right.equalTo(label.superview.right).with.offset(-1);
				}];
			}
		} else {
			if (_rulerScrollDirectionReverse) {
				[label remakeConstraints:^(MASConstraintMaker *make) {
					make.bottom.equalTo(label.superview.bottom).with.offset(2);
					make.left.equalTo(label.superview.left).with.offset(1);
				}];
			} else {
				[label remakeConstraints:^(MASConstraintMaker *make) {
					make.bottom.equalTo(label.superview.bottom).with.offset(0);
					make.right.equalTo(label.superview.right).with.offset(-1);
				}];
			}
		}
		label.text = [NSString stringWithFormat:@"%ld", (long)(idx + centimeterStartIndex + 1)];
		label.transform = !toPortrait ? CGAffineTransformIdentity : CGAffineTransformMakeRotation(-M_PI / 2);
	}];

	NSInteger inchStartIndex;
	if (toPortrait) {
		if (_rulerScrollDirectionReverse) {
			inchStartIndex = floor(_rulerScrollView.contentOffset.y / _inchAsPoints);
		} else {
			inchStartIndex = floor((_rulerScrollView.contentSize.height - (_rulerScrollView.contentOffset.y + _screenHeight)) / _inchAsPoints);
		}
	} else {
		if (_rulerScrollDirectionReverse) {
			inchStartIndex = floor((_rulerScrollView.contentSize.width - (_rulerScrollView.contentOffset.x + _screenWidth)) / _inchAsPoints);
		} else {
			inchStartIndex = floor(_rulerScrollView.contentOffset.x / _inchAsPoints);
		}
	}
	[_inchesMarkingViews enumerateObjectsUsingBlock:^(A3MarkingsView *markingsView, NSUInteger idx, BOOL *stop) {
		markingsView.drawPortrait = toPortrait;
		markingsView.horizontalDirection = A3MarkingsDirectionRight;
		markingsView.verticalDirection = _rulerScrollDirectionReverse ? A3MarkingsVerticalDirectionDown : A3MarkingsVerticalDirectionUp;
		if (toPortrait) {
			if (_rulerScrollDirectionReverse) {
				markingsView.frame = CGRectMake(_screenWidth - _markingsWidth, (idx + inchStartIndex) * _inchAsPoints - 1, _markingsWidth, _inchAsPoints);
			} else {
				markingsView.frame = CGRectMake(_screenWidth - _markingsWidth, _rulerScrollView.contentSize.height - (idx + inchStartIndex) * _inchAsPoints - _inchAsPoints + 2, _markingsWidth, _inchAsPoints);
			}
		} else {
			if (_rulerScrollDirectionReverse) {
				markingsView.frame = CGRectMake(_rulerScrollView.contentSize.width  - (idx + inchStartIndex) * _inchAsPoints - _inchAsPoints + 1, _screenHeight - _markingsWidth, _inchAsPoints, _markingsWidth);
			} else {
				markingsView.frame = CGRectMake((idx + inchStartIndex) * _inchAsPoints - 1, _screenHeight - _markingsWidth, _inchAsPoints, _markingsWidth);
			}
		}
#ifdef DEBUG
		if (idx + centimeterStartIndex == 0) {
			FNLOG(@"*******************");
			FNLOGRECT(markingsView.frame);
			FNLOG(@"*******************");
		}
#endif
	}];

	[_inchLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
		if (toPortrait) {
			if (_rulerScrollDirectionReverse) {
				[label remakeConstraints:^(MASConstraintMaker *make) {
					make.bottom.equalTo(label.superview.bottom);
					make.left.equalTo(label.superview.left);
				}];
			} else {
				[label remakeConstraints:^(MASConstraintMaker *make) {
					make.top.equalTo(label.superview.top);
					make.left.equalTo(label.superview.left);
				}];
			}
		} else {
			if (_rulerScrollDirectionReverse) {
				[label remakeConstraints:^(MASConstraintMaker *make) {
					make.top.equalTo(label.superview.top).with.offset(-2);
					make.left.equalTo(label.superview.left).with.offset(3);
				}];
			} else {
				[label remakeConstraints:^(MASConstraintMaker *make) {
					make.top.equalTo(label.superview.top).with.offset(-2);
					make.right.equalTo(label.superview.right).with.offset(-4);
				}];
			}
		}
		label.text = [NSString stringWithFormat:@"%ld", (long)(idx + inchStartIndex + 1)];
		label.transform = !toPortrait ? CGAffineTransformIdentity : CGAffineTransformMakeRotation(-M_PI / 2);
	}];
}

#pragma mark -- UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self layoutMarkingsToInterfaceOrientation:[UIWindow interfaceOrientationIsPortrait]];
	[self updateLabelsForInterfaceOrientation:[UIWindow interfaceOrientationIsPortrait]];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	BOOL isPortrait = [UIWindow interfaceOrientationIsPortrait];
	if (_needsSnapToGrid) {
		_needsSnapToGrid = NO;
		CGFloat currentPosition;
		currentPosition = [self currentPositionForInterfaceOrientation:isPortrait];
		currentPosition = roundf(currentPosition * 10.0) / 10.0;
		FNLOG(@"%f", currentPosition);
		[self moveRedLineToPosition:currentPosition interfaceOrientation:isPortrait];
		[self updateLabelsForInterfaceOrientation:isPortrait];
	} else if (_needsResetRedLinePosition) {
		_needsResetRedLinePosition = NO;
		[self resetRedLinePositionForInterfaceOrientation:isPortrait];
		[self updateLabelsForInterfaceOrientation:isPortrait];
	}
}

- (NSString *)fractionForInches:(double)fraction {
	NSArray *results = @[@"", @"1/16", @"1/8", @"3/16", @"1/4", @"5/16", @"3/8", @"7/16", @"1/2", @"9/16", @"5/8", @"11/16", @"3/4", @"13/16", @"7/8", @"15/16"];

	NSInteger idx = floor(fraction * 100 / (100.0 / 16.0) );
	return results[idx];
}

- (void)addButtons {
	// Apps, Accumulate, Reset
	_advanceButton = [self buttonWithTitle:@"d"];
	_advanceButton.titleLabel.font = [UIFont fontWithName:@"appbox" size:20.0];
	[_advanceButton addTarget:self action:@selector(advanceButtonAction) forControlEvents:UIControlEventTouchUpInside];

	_flipUnitButton = [self buttonWithTitle:@"q"];
	_flipUnitButton.titleLabel.font = [UIFont fontWithName:@"appbox" size:20.0];
	_flipUnitButton.titleLabel.transform = CGAffineTransformMakeRotation(-M_PI / 2);
	[_flipUnitButton addTarget:self action:@selector(flipUnitButtonAction) forControlEvents:UIControlEventTouchUpInside];

	_flipScrollDirectionButton = [self buttonWithTitle:@"q"];
	_flipScrollDirectionButton.titleLabel.font = [UIFont fontWithName:@"appbox" size:20.0];
	[_flipScrollDirectionButton addTarget:self action:@selector(flipScrollDirectionButtonAction) forControlEvents:UIControlEventTouchUpInside];

	_resetButton = [self buttonWithTitle:@"C"];
	_resetButton.titleLabel.font = [UIFont systemFontOfSize:20.0];
	[_resetButton addTarget:self action:@selector(resetButtonAction) forControlEvents:UIControlEventTouchUpInside];

	_appsButton = [self buttonWithTitle:@"Apps"];
	[_appsButton addTarget:self action:@selector(appsButtonAction:) forControlEvents:UIControlEventTouchUpInside];

	[self layoutButtonsToInterfaceOrientation:[UIWindow interfaceOrientationIsPortrait]];
}

- (UIButton *)buttonWithTitle:(NSString *)title {
    UIColor *themeColor = [[A3UserDefaults standardUserDefaults] themeColor];
	UIButton *button = [UIButton new];
	button.layer.borderWidth = 1.0;
	button.layer.cornerRadius = IS_IPAD ? 40.0 : 30.0;
	button.layer.borderColor = themeColor.CGColor;
	[button setTitle:title forState:UIControlStateNormal];
	[button setTitleColor:themeColor forState:UIControlStateNormal];

	[self.view addSubview:button];

	return button;
}

- (void)layoutRulerDragViewToInterfaceOrientation:(BOOL)toPortrait {
	if (toPortrait) {
		_rulerDragView.transform = CGAffineTransformMakeRotation(-M_PI/2.0);
		CGFloat positionStartFrom;
		if (IS_IPHONE) {
			if (_rulerScrollDirectionReverse) {
				positionStartFrom = _screenHeight * 0.3 - 64.0;
			} else {
				positionStartFrom = _rulerScrollView.contentSize.height - _screenHeight * 0.3 - 64.0;
			}
		} else {
			if (_rulerScrollDirectionReverse) {
				positionStartFrom = _screenHeight / 2.0 - 64.0;
			} else {
				positionStartFrom = _rulerScrollView.contentSize.height - _screenHeight / 2.0 - 64.0;
			}
		}
		_rulerDragView.frame = CGRectMake(_screenWidth * 0.7 - 64.0, positionStartFrom, 128, 128);
	} else {
		// iPhone은 Landscape를 지원하지 않는다.
		_rulerDragView.transform = CGAffineTransformIdentity;
		CGFloat positionFromStart;
		if (_rulerScrollDirectionReverse) {
			positionFromStart = _rulerScrollView.contentSize.width - _screenWidth / 2.0 - 64.0;
		} else {
			positionFromStart = _screenWidth / 2.0 - 64.0;
		}
		_rulerDragView.frame = CGRectMake(positionFromStart, _screenHeight * 0.7 - 64.0, 128, 128);
	}
}

- (void)layoutButtonsToInterfaceOrientation:(BOOL)toPortrait {
	[self applyTransformToButtons:CGAffineTransformIdentity];
	if (IS_IPHONE35) {
		CGFloat buttonSize = 60.0;
		CGFloat leftOffset = 75.0;

		CGFloat y;
		if (_rulerScrollDirectionReverse) {
			y = 320.0;
		} else {
			y = 380.0;
		}
		_advanceButton.frame = CGRectMake(leftOffset, y, buttonSize, buttonSize);
		y -= 70.0;
		_flipUnitButton.frame = CGRectMake(leftOffset, y, buttonSize, buttonSize);
		y -= 70.0;
		_flipScrollDirectionButton.frame = CGRectMake(leftOffset, y, buttonSize, buttonSize);
		y -= 70.0;
		_resetButton.frame = CGRectMake(leftOffset, y, buttonSize, buttonSize);
		y -= 70.0;
		_appsButton.frame = CGRectMake(leftOffset, y, buttonSize, buttonSize);
		
		[self applyTransformToButtons:CGAffineTransformMakeRotation(-M_PI / 2)];
	} else if (IS_IPHONE) {
		CGFloat leftOffset = 75.0;
		CGFloat buttonSize = 60.0;

		_appsButton.frame = CGRectMake(leftOffset, 110.0, buttonSize, buttonSize);
		_resetButton.frame = CGRectMake(leftOffset, 188, buttonSize, buttonSize);
		_flipScrollDirectionButton.frame = CGRectMake(leftOffset, 258.0, buttonSize, buttonSize);
		_flipUnitButton.frame = CGRectMake(leftOffset, 328, buttonSize, buttonSize);
		_advanceButton.frame = CGRectMake(leftOffset, 398, buttonSize, buttonSize);

		[self applyTransformToButtons:CGAffineTransformMakeRotation(-M_PI / 2)];
	} else {	// IS_IPAD
		CGFloat buttonWidth = 80.0;
		CGFloat buttonHeight = 80.0;
		if (toPortrait) {
			CGFloat leftOffset = 140.0;
			_appsButton.frame = CGRectMake(140.0, 250.0, buttonWidth, buttonHeight);
			_resetButton.frame = CGRectMake(leftOffset, _screenHeight - 250.0 - buttonHeight - 300.0, buttonWidth, buttonHeight);
			_flipScrollDirectionButton.frame = CGRectMake(leftOffset, _screenHeight - 250.0 - buttonHeight - 200.0, buttonWidth, buttonHeight);
			_flipUnitButton.frame = CGRectMake(leftOffset, _screenHeight - 250.0 - buttonHeight - 100.0, buttonWidth, buttonHeight);
			_advanceButton.frame = CGRectMake(leftOffset, _screenHeight - 250.0 - buttonHeight, buttonWidth, buttonHeight);

			[self applyTransformToButtons:CGAffineTransformMakeRotation(-M_PI / 2)];
		} else {
			CGFloat topOffset = 140.0;

			_advanceButton.frame = CGRectMake(250.0, topOffset, buttonWidth, buttonHeight);
			_flipUnitButton.frame = CGRectMake(350.0, topOffset, buttonWidth, buttonHeight);
			_flipScrollDirectionButton.frame = CGRectMake(450.0, topOffset, buttonWidth, buttonHeight);
			_resetButton.frame = CGRectMake(550.0, topOffset, buttonWidth, buttonHeight);
			_appsButton.frame = CGRectMake(1024.0 - 250.0 - buttonWidth, topOffset, buttonWidth, buttonHeight);

			[self applyTransformToButtons:CGAffineTransformIdentity];
		}
	}
	if (_rulerScrollDirectionReverse) {
		_advanceButton.titleLabel.transform = CGAffineTransformMakeRotation(M_PI);
	} else {
		_advanceButton.titleLabel.transform = CGAffineTransformIdentity;
	}
}

- (void)applyTransformToButtons:(CGAffineTransform)transform {
	_advanceButton.transform = transform;
	_flipUnitButton.transform = transform;
	_flipScrollDirectionButton.transform = transform;
	_resetButton.transform = transform;
	_appsButton.transform = transform;
}

- (void)resetButtonAction {
	BOOL isPortrait = [UIWindow interfaceOrientationIsPortrait];
	if (isPortrait) {
		if (_rulerScrollDirectionReverse) {
			[_rulerScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
			if (_rulerScrollView.contentOffset.y == 0) {
				[self resetRedLinePositionForInterfaceOrientation:isPortrait];
				[self updateLabelsForInterfaceOrientation:isPortrait];
			} else {
				_needsResetRedLinePosition = YES;
			}
		} else {
			[_rulerScrollView setContentOffset:CGPointMake(0, _rulerScrollView.contentSize.height - _screenHeight) animated:YES];
			if (_rulerScrollView.contentOffset.y == _rulerScrollView.contentSize.height - _screenHeight) {
				[self resetRedLinePositionForInterfaceOrientation:isPortrait];
				[self updateLabelsForInterfaceOrientation:isPortrait];
			} else {
				_needsResetRedLinePosition = YES;
			}
		}
	} else {
		if (_rulerScrollDirectionReverse) {
			[_rulerScrollView setContentOffset:CGPointMake(_rulerScrollView.contentSize.width - _screenWidth, 0) animated:YES];
			if (_rulerScrollView.contentOffset.x == _rulerScrollView.contentSize.width - _screenWidth) {
				// 이미 animation 이 필요없는 경우에는 animation 끝난후에 didEndScrollingAnimation 이 호출되지 않는다.
				[self resetRedLinePositionForInterfaceOrientation:isPortrait];
				[self updateLabelsForInterfaceOrientation:isPortrait];
			} else {
				// animation 필요한 경우에는 animation 이 종료된 후에야 contentOffset 의 값이 변하므로 그 이후에 처리한다.
				_needsResetRedLinePosition = YES;
			}
		} else {
			[_rulerScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
			if (_rulerScrollView.contentOffset.x == 0) {
				// 이미 animation 이 필요없는 경우에는 animation 끝난후에 didEndScrollingAnimation 이 호출되지 않는다.
				[self resetRedLinePositionForInterfaceOrientation:isPortrait];
				[self updateLabelsForInterfaceOrientation:isPortrait];
			} else {
				// animation 필요한 경우에는 animation 이 종료된 후에야 contentOffset 의 값이 변하므로 그 이후에 처리한다.
				_needsResetRedLinePosition = YES;
			}
		}
	}
}

- (void)advanceButtonAction {
	_needsSnapToGrid = YES;
	if ([UIWindow interfaceOrientationIsPortrait]) {
		if (_rulerScrollDirectionReverse) {
			[_rulerScrollView setContentOffset:CGPointMake(0, _rulerScrollView.contentOffset.y + _redLineView.frame.origin.y) animated:YES];
		} else {
			[_rulerScrollView setContentOffset:CGPointMake(0, _rulerScrollView.contentOffset.y - (_screenHeight - _redLineView.frame.origin.y)) animated:YES];
		}
	} else {
		if (_rulerScrollDirectionReverse) {
			[_rulerScrollView setContentOffset:CGPointMake(_rulerScrollView.contentOffset.x - (_screenWidth - _redLineView.frame.origin.x), 0) animated:YES];
		} else {
			[_rulerScrollView setContentOffset:CGPointMake(_rulerScrollView.contentOffset.x + _redLineView.frame.origin.x, 0) animated:YES];
		}
	}
}

- (void)setRedrawMarkingsViews {
	[_centimetersMarkingViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
		[view setNeedsDisplay];
	}];
	[_inchesMarkingViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
		[view setNeedsDisplay];
	}];
}

- (void)flipUnitButtonAction {
	BOOL isPortrait = [UIWindow interfaceOrientationIsPortrait];
	CGFloat currentPosition = [self currentPositionForInterfaceOrientation:[UIWindow interfaceOrientationIsPortrait]];
	_needsResetRedLinePosition = round(currentPosition * 100.0) == _resetPosition * 100.0;
	
	_centimeterPositionRightBottom = !_centimeterPositionRightBottom;
	[[NSUserDefaults standardUserDefaults] setBool:_centimeterPositionRightBottom forKey:A3RulerCentimeterPositionRightBottom];
	[[NSUserDefaults standardUserDefaults] synchronize];

	[self setRedrawMarkingsViews];
	[self reloadAllViewsFromOrientation:isPortrait toOrientation:isPortrait hiddenSpace:CGFLOAT_MAX position:CGFLOAT_MAX];
	if (_needsResetRedLinePosition) {
		[self resetRedLinePositionForInterfaceOrientation:isPortrait];
	}
}

- (void)flipScrollDirectionButtonAction {
	CGFloat hiddenSpace = [self hiddenSpace];
	CGFloat currentPosition;
	if (_centimeterPositionRightBottom) {
		currentPosition = [self currentCentimeterForInterfaceOrientation:[UIWindow interfaceOrientationIsPortrait]];
	} else {
		currentPosition = [self currentInchesForInterfaceOrientation:[UIWindow interfaceOrientationIsPortrait]];
	}

	_rulerScrollDirectionReverse = !_rulerScrollDirectionReverse;
	[[NSUserDefaults standardUserDefaults] setBool:_rulerScrollDirectionReverse forKey:A3RulerScrollDirectionReverse];
	[[NSUserDefaults standardUserDefaults] synchronize];

	[self setRedrawMarkingsViews];
	[self reloadAllViewsFromOrientation:[UIWindow interfaceOrientationIsPortrait] toOrientation:[UIWindow interfaceOrientationIsPortrait] hiddenSpace:hiddenSpace position:currentPosition];

	[self resetButtonAction];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[UIView setAnimationsEnabled:NO];
	
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

	[self reloadAllViewsFromOrientation:[UIWindow interfaceOrientationIsPortrait] toOrientation:UIInterfaceOrientationIsPortrait(toInterfaceOrientation) hiddenSpace:CGFLOAT_MAX position:CGFLOAT_MAX];
}

- (void)reloadAllViewsFromOrientation:(BOOL)fromIsPortrait toOrientation:(BOOL)toPortrait hiddenSpace:(CGFloat)hiddenSpaceParameter position:(CGFloat)positionParameter {
	CGFloat hiddenSpace = hiddenSpaceParameter != CGFLOAT_MAX ? hiddenSpaceParameter : [self hiddenSpace];

	// currentCentimeter는 현재 오리엔테이션 기준으로 측정해야 함
	CGFloat currentPosition;
	if (positionParameter != CGFLOAT_MAX) {
		currentPosition = positionParameter;
	} else {
		currentPosition = [self currentPositionForInterfaceOrientation:fromIsPortrait];
	}

	FNLOG(@"hidden space = %f, currentPosition = %f, %ld", hiddenSpace, currentPosition, (long) fromIsPortrait);

	[self setupBasicMeasureForInterfaceOrientation:toPortrait];

	[self setupScrollViewContentSizeToInterfaceOrientation:toPortrait];
	[self setHiddenSpace:hiddenSpace interfaceOrientation:toPortrait];

	_oldMarkingsStartIndex = NSNotFound;
	[self layoutMarkingsToInterfaceOrientation:toPortrait];
	[self layoutRulerDragViewToInterfaceOrientation:toPortrait];
	[self layoutButtonsToInterfaceOrientation:toPortrait];

	[_inchesMarkingViews enumerateObjectsUsingBlock:^(A3MarkingsView *view, NSUInteger idx, BOOL *stop) {
		view.drawPortrait = toPortrait;
		[view setNeedsDisplay];
	}];
	[_centimetersMarkingViews enumerateObjectsUsingBlock:^(A3MarkingsView *view, NSUInteger idx, BOOL *stop) {
		view.drawPortrait = toPortrait;
		[view setNeedsDisplay];
	}];

	[self moveRedLineToPosition:currentPosition interfaceOrientation:toPortrait];
	[self updateLabelsForInterfaceOrientation:toPortrait];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

	[UIView setAnimationsEnabled:YES];
}

@end
