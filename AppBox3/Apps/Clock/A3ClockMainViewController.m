//
//  A3ClockMainViewController.m
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 20..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ClockDataManager.h"
#import "A3ClockMainViewController.h"
#import "A3ClockWaveViewController.h"
#import "A3ClockFlipViewController.h"
#import "A3ClockLEDViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3ClockSettingsViewController.h"
#import "A3UserDefaultsKeys.h"
#import "A3ClockInfo.h"
#import "A3UserDefaults+A3Defaults.h"
#import "UIViewController+MMDrawerController.h"
#import "A3ChooseColorView.h"
#import "A3InstructionViewController.h"
#import "UIViewController+iPad_rightSideView.h"
#import "UIViewController+extension.h"
#import "A3SyncManager.h"
#import "A3AppDelegate.h"
#import "A3UIDevice.h"

#define kCntPage 4.0

NSString *const A3V3InstructionDidShowForClock1 = @"A3V3InstructionDidShowForClock1";
NSString *const A3V3InstructionDidShowForClock2 = @"A3V3InstructionDidShowForClock2";

@interface A3ClockMainViewController () <A3ClockDataManagerDelegate, A3ChooseColorDelegate, A3InstructionViewControllerDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, GADBannerViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIButton *clockAppsButton;
@property (nonatomic, strong) UIButton *settingsButton;
@property (nonatomic, strong) UIButton *helpButton;
@property (nonatomic, strong) UIButton *yahooButton;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) A3ClockWaveViewController *clockWaveViewController;
@property (nonatomic, strong) A3ClockFlipViewController *clockFlipDarkViewController;
@property (nonatomic, strong) A3ClockFlipViewController *clockFlipBrightViewController;
@property (nonatomic, strong) A3ClockLEDViewController *clockLEDViewController;
@property (nonatomic, strong) A3ClockDataManager *clockDataManager;
@property (nonatomic, strong) A3ClockViewController *currentClockViewController;
@property (nonatomic, strong) UIButton *chooseColorButton;
@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, strong) UIView *chooseColorView;
@property (nonatomic, strong) MASConstraint *appsButtonTop;
@property (nonatomic, strong) NSTimer *buttonsTimer;
@property (nonatomic, strong) UINavigationController *modalNavigationController;
@property (nonatomic, strong) A3InstructionViewController *instructionViewController;
@property (nonatomic, assign) BOOL useInstruction;
@property (nonatomic, strong) NSTimer *autoDimTimer;

@end

@implementation A3ClockMainViewController {
    CGFloat _originalBrightness;
	BOOL _isAutoDimActivated;
	BOOL _isClosing;
}

- (A3ClockDataManager *)clockDataManager {
	if (!_clockDataManager) {
		_clockDataManager = [A3ClockDataManager new];
		_clockDataManager.delegate = self;
	}
	return _clockDataManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.automaticallyAdjustsScrollViewInsets = NO;

	UIImage *image = [[UIImage alloc] init];
	[self.navigationController.navigationBar setBackgroundImage:image forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
	[self.navigationController.navigationBar setShadowImage:image];
	[self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor clearColor]}];

	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	[self.navigationController setNavigationBarHidden:YES];

    [self.view addSubview:self.scrollView];

	[self clockAppsButton];
	[self settingsButton];
    [self helpButton];
	[self yahooButton];

	[self.view addSubview:self.pageControl];

	[self setButtonTintColor];

    CGFloat verticalOffset = 0;
    UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets];
    verticalOffset = -safeAreaInsets.bottom;

    CGRect bounds = [self screenBoundsAdjustedWithOrientation];
    [_pageControl makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.view.centerX);
		if (IS_IPHONE) {
			make.bottom.equalTo(self.view.bottom).with.offset(bounds.size.height == 480 ? 5 : verticalOffset);
		} else {
			make.bottom.equalTo(self.view.bottom).with.offset(0);
		}
	}];
    [self setNeedsStatusBarAppearanceUpdate];
	[self addChooseColorButton];

	_currentClockViewController = _clockWaveViewController;

    [self.view setBackgroundColor:_currentClockViewController.view.backgroundColor];

	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapMainView)];
	[self.scrollView addGestureRecognizer:tapGestureRecognizer];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(drawerStateChanged) name:A3DrawerStateChanged object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsChanged) name:A3NotificationClockSettingsChanged object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationRightSideViewDidDismiss object:nil];
	}
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)applicationDidEnterBackground {
	[self dismissInstructionViewController:nil];
}

- (void)applicationDidBecomeActive {
    [self resetAndStartAutoDimTimer];
}

- (void)applicationWillResignActive {
    [self turnOffAutoDim];
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3DrawerStateChanged object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidHide object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationClockSettingsChanged object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationRightSideViewDidDismiss object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		[self removeObserver];
	}
}

- (void)prepareClose {
	FNLOG();
	_isClosing = YES;
	[self dismissInstructionViewController:nil];

	[self turnOffAutoDim];

	[_autoDimTimer invalidate];
	_autoDimTimer = nil;

	[self removeObserver];
	[_clockDataManager cleanUp];
	[_buttonsTimer invalidate];
	_buttonsTimer = nil;

	FNLOG(@"[[UIApplication sharedApplication] setIdleTimerDisabled:NO];");
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (BOOL)resignFirstResponder {
	NSString *startingAppName = [[A3UserDefaults standardUserDefaults] objectForKey:kA3AppsStartingAppName];
	if ([startingAppName length] && ![startingAppName isEqualToString:A3AppName_Clock]) {
		if (self.instructionViewController) {
			[[A3UserDefaults standardUserDefaults] setBool:YES forKey:A3V3InstructionDidShowForClock1];
			[[A3UserDefaults standardUserDefaults] setBool:YES forKey:A3V3InstructionDidShowForClock2];
			[[A3UserDefaults standardUserDefaults] synchronize];
			[self.instructionViewController.view removeFromSuperview];
			self.instructionViewController = nil;
		}
	}
	return [super resignFirstResponder];
}

- (void)cleanUp {
	[self removeObserver];
}

- (void)dealloc {
	[self removeObserver];
}

- (void)drawerStateChanged {
    [self resetAndStartAutoDimTimer];
	[self.scrollView setScrollEnabled:self.mm_drawerController.openSide == MMDrawerSideNone];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if (_isClosing) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO];
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
		return;
	}
	
	[self layoutSubviews];
	[self.clockDataManager startTimer];
	_pageControl.currentPage = [[A3UserDefaults standardUserDefaults] integerForKey:A3ClockUserDefaultsCurrentPage];
	[self scrollToPage:_pageControl.currentPage];
	[self gotoPage:_pageControl.currentPage];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];

	if (![[A3UserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForClock1] && ![[A3UserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForClock2]) {
		[self showMenus:NO];
	}
	else {
		[self showMenus:YES];
	}
    [self resetAndStartAutoDimTimer];
	if ([self isMovingToParentViewController] || [self isBeingPresented]) {
        [self setupBannerViewForAdUnitID:AdMobAdUnitIDClock keywords:@[@"clock"] delegate:self];
	}
	[self setupInstructionView];
	if (self.instructionViewController) {
		[self adjustInstructionFingerPositionForPortrait:[UIWindow interfaceOrientationIsPortrait]];
	}
}

- (void)turnOffAutoDim {
	if (_isAutoDimActivated) {
		[[UIScreen mainScreen] setBrightness:_originalBrightness];
	}
	_isAutoDimActivated = NO;
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

    [_autoDimTimer invalidate];
    _autoDimTimer = nil;
}

- (void)resetAndStartAutoDimTimer {
    [self turnOffAutoDim];

    if (![[A3UserDefaults standardUserDefaults] clockUseAutoLock]) {
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
    NSInteger autoDimMinutes = [[A3UserDefaults standardUserDefaults] integerForKey:A3ClockAutoDim];
    if (autoDimMinutes) {
        _autoDimTimer = [NSTimer scheduledTimerWithTimeInterval:autoDimMinutes * 60
                                                         target:self
                                                       selector:@selector(activateAutoDim)
                                                       userInfo:nil
                                                        repeats:NO];
    }
}

- (void)activateAutoDim {
	_isAutoDimActivated = YES;
	_originalBrightness = [[UIScreen mainScreen] brightness];

    [_autoDimTimer invalidate];
    _autoDimTimer = nil;
    [[UIScreen mainScreen] setBrightness:0.0];
}

- (UIButton *)clockAppsButton {
	if (!_clockAppsButton) {
		_clockAppsButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[_clockAppsButton setTitle:NSLocalizedString(@"Apps", @"Apps") forState:UIControlStateNormal];
		_clockAppsButton.titleLabel.font = [UIFont systemFontOfSize:17];
		[_clockAppsButton sizeToFit];
		[_clockAppsButton addTarget:self action:@selector(appsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
		[_clockAppsButton setHidden:YES];
		[self.view addSubview:_clockAppsButton];

        CGFloat verticalOffset = 0;
        UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets];
        verticalOffset = safeAreaInsets.top;
        
		[_clockAppsButton makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.view).with.offset(8);
            // Top Offset은 변수로 저장해 두었다가, 매번 새로 설정합니다.
			self.appsButtonTop = make.top.equalTo(self.view.top).with.offset(26 + verticalOffset);
            make.width.equalTo(@44);
            make.height.equalTo(@44);
		}];
	}
	return _clockAppsButton;
}

- (UIButton *)settingsButton {
	if (!_settingsButton) {
		_settingsButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[_settingsButton setImage:[UIImage imageNamed:@"general"] forState:UIControlStateNormal];
		[_settingsButton addTarget:self action:@selector(settingsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
		_settingsButton.tintColor = [UIColor whiteColor];
		[_settingsButton setHidden:YES];
		[_settingsButton sizeToFit];
		[self.view addSubview:_settingsButton];

		[_settingsButton makeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(self.view.right).with.offset(-28);
			make.centerY.equalTo(self.clockAppsButton.centerY);
			make.width.equalTo(@44);
			make.height.equalTo(@44);
		}];
        
	}
	return _settingsButton;
}

- (UIButton *)helpButton {
    if (!_helpButton) {
        _helpButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_helpButton setImage:[UIImage imageNamed:@"help"] forState:UIControlStateNormal];
        [_helpButton addTarget:self action:@selector(helpButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _helpButton.tintColor = [UIColor whiteColor];
        [_helpButton setHidden:YES];
        [_helpButton sizeToFit];
        [self.view addSubview:_helpButton];
        
        [_helpButton makeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(self.view.right).with.offset(-78);
			make.centerY.equalTo(self.clockAppsButton.centerY);
			make.width.equalTo(@44);
			make.height.equalTo(@44);
        }];
    }
    
    return _helpButton;
}

- (UIButton *)yahooButton {
	if (!_yahooButton) {
		_yahooButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[_yahooButton setImage:[UIImage imageNamed:@"yahoo"] forState:UIControlStateNormal];
		[_yahooButton addTarget:self action:@selector(yahooButtonAction) forControlEvents:UIControlEventTouchUpInside];
		[_yahooButton setHidden:YES];
		[_yahooButton sizeToFit];
		[self.view addSubview:_yahooButton];

        CGFloat verticalOffset = 0;
        UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets];
        verticalOffset = -safeAreaInsets.bottom;

		[_yahooButton makeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(self.view.right).offset(IS_IPHONE ? -40 : -56);
			make.centerY.equalTo(self.view.bottom).offset((IS_IPHONE ? -18 : -36) + verticalOffset);
			make.height.equalTo(@40);
		}];
	}
	return _yahooButton;
}

- (void)yahooButtonAction {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://weather.yahoo.com"]
                                       options:@{}
                             completionHandler:nil];
}

- (void)settingsChanged {
	[_currentClockViewController updateLayout];

	if ([[A3UserDefaults standardUserDefaults] clockShowWeather]) {
		[_clockDataManager updateWeather];
	}
}

- (void)addChooseColorButton {
	_chooseColorButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_chooseColorButton setImage:[UIImage imageNamed:@"m_color_on"] forState:UIControlStateNormal];
	[_chooseColorButton sizeToFit];
	[_chooseColorButton addTarget:self action:@selector(chooseColorButtonAction) forControlEvents:UIControlEventTouchUpInside];
	[_chooseColorButton setHidden:YES];
	[self.view addSubview:_chooseColorButton];

    CGFloat verticalOffset = 0;
    UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets];
    verticalOffset = -safeAreaInsets.bottom;

	[_chooseColorButton makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.view.right).offset(-28);
		make.centerY.equalTo(self.view.bottom).offset(-28 + verticalOffset);
		make.width.equalTo(@40);
		make.height.equalTo(@40);
	}];
}

- (UIScrollView *)scrollView {
	if (!_scrollView) {
		_scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
		_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[_scrollView setContentSize:CGSizeMake(_scrollView.bounds.size.width*kCntPage, self.view.bounds.size.height)];
		_scrollView.pagingEnabled=YES;
		_scrollView.delegate = self;
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.showsVerticalScrollIndicator = NO;

		[_scrollView addSubview:self.clockWaveViewController.view];
		[self addChildViewController:self.clockWaveViewController];

		[_scrollView addSubview:self.clockFlipDarkViewController.view];
		[self addChildViewController:self.clockFlipDarkViewController];

		[_scrollView addSubview:self.clockFlipBrightViewController.view];
		[self addChildViewController:self.clockFlipBrightViewController];

		[_scrollView addSubview:self.clockLEDViewController.view];
		[self addChildViewController:self.clockLEDViewController];

		self.viewControllers = @[_clockWaveViewController, _clockFlipDarkViewController, _clockFlipBrightViewController, _clockLEDViewController];
	}
	return _scrollView;
}

- (UIPageControl *)pageControl {
	if (!_pageControl) {
		_pageControl = [[UIPageControl alloc] init];
		_pageControl.currentPage = 0;
		_pageControl.numberOfPages = kCntPage;
		[_pageControl setHidden:YES];
		[_pageControl addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];
		[_pageControl sizeToFit];
	}
	return _pageControl;
}

- (A3ClockWaveViewController *)clockWaveViewController {
	if (!_clockWaveViewController) {
		_clockWaveViewController = [[A3ClockWaveViewController alloc] initWithClockDataManager:self.clockDataManager];
		_clockWaveViewController.clockDataManager = self.clockDataManager;
	}
	return _clockWaveViewController;
}

- (A3ClockFlipViewController *)clockFlipDarkViewController {
	if (!_clockFlipDarkViewController) {
		_clockFlipDarkViewController = [[A3ClockFlipViewController alloc] initWithClockDataManager:self.clockDataManager style:A3ClockFlipViewStyleDark];
	}
	return _clockFlipDarkViewController;
}

- (A3ClockFlipViewController *)clockFlipBrightViewController {
	if (!_clockFlipBrightViewController) {
		_clockFlipBrightViewController = [[A3ClockFlipViewController alloc] initWithClockDataManager:self.clockDataManager style:A3ClockFlipViewStyleLight];
	}
	return _clockFlipBrightViewController;
}

- (A3ClockLEDViewController *)clockLEDViewController {
	if (!_clockLEDViewController) {
		_clockLEDViewController = [[A3ClockLEDViewController alloc] initWithClockDataManager:self.clockDataManager];
	}
	return _clockLEDViewController;
}

- (BOOL)prefersStatusBarHidden {
    return [_clockAppsButton isHidden] || ![[A3AppDelegate instance] rootViewController_iPad].showLeftView;
}

- (void)appsButtonAction:(UIBarButtonItem *)barButtonItem {
    [self turnOffAutoDim];

	if (IS_IPHONE) {
		if ([[A3AppDelegate instance] isMainMenuStyleList]) {
			[[self mm_drawerController] toggleDrawerSide:MMDrawerSideLeft animated:YES completion:^(BOOL finished) {
				[self.scrollView setScrollEnabled:self.mm_drawerController.openSide == MMDrawerSideNone];
                [self setNeedsStatusBarAppearanceUpdate];
			}];
		} else {
			UINavigationController *navigationController = [A3AppDelegate instance].currentMainNavigationController;
			[navigationController setNavigationBarHidden:YES];
			[navigationController popViewControllerAnimated:YES];
			[navigationController setToolbarHidden:YES];
			[A3AppDelegate instance].homeStyleMainMenuViewController.activeAppName = nil;
		}
	} else {
		[[[A3AppDelegate instance] rootViewController_iPad] toggleLeftMenuViewOnOff];
        [self setNeedsStatusBarAppearanceUpdate];
	}
	if (_buttonsTimer) {
		FNLOG(@"Timer disabled");
		[_buttonsTimer invalidate];
		_buttonsTimer = nil;
	}
	[[A3AppDelegate instance] presentInterstitialAds];
}

- (void)mainMenuDidHide {
	[self showMenus:NO];
    if (IS_IPAD) {
        [self setupInstructionView];
    }
    [self resetAndStartAutoDimTimer];
}

- (void)onTapMainView {
    [self resetAndStartAutoDimTimer];

	if (_chooseColorView) {
		[self chooseColorDidCancel];
	}
	[self showMenus:_chooseColorButton.isHidden];
}

- (void)showMenus:(BOOL)show {
	if (_buttonsTimer) {
		[_buttonsTimer invalidate];
		_buttonsTimer = nil;
	}
	_clockAppsButton.hidden = !show || (IS_IPHONE && [UIWindow interfaceOrientationIsLandscape]);
	_settingsButton.hidden = !show || (IS_IPHONE && [UIWindow interfaceOrientationIsLandscape]);
    _helpButton.hidden = !show || (IS_IPHONE && [UIWindow interfaceOrientationIsLandscape]);
	_pageControl.hidden = !show;
	_chooseColorButton.hidden = !show;
	if (show) {
		_yahooButton.hidden = YES;
	}
    else {
		_yahooButton.hidden = (_clockDataManager.clockInfo.currentWeather == nil) || ![[A3UserDefaults standardUserDefaults] clockShowWeather];
	}

    if (_useInstruction) {
        if (show) {
            if (![[A3UserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForClock2]) {
                [self showInstructionView];
            }
        }
        else {
            if (![[A3UserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForClock1]) {
                [self showInstructionView];
            }
        }
    }
    
	if (!(show && IS_IPHONE && [UIWindow interfaceOrientationIsLandscape])) {
        [self setNeedsStatusBarAppearanceUpdate];
	}

	if (show) {
		NSTimeInterval timeInterval = 10;
		_buttonsTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(hideButtons) userInfo:nil repeats:NO];
	}
}

- (void)hideButtons {
	[self showMenus:NO];
	_buttonsTimer = nil;
}

#pragma mark Instruction Related

- (void)setupInstructionView
{
    _useInstruction = YES;
    
    if (![[A3UserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForClock1]) {
        [self showInstructionView];
	}
}

- (void)showInstructionView
{
    if (_instructionViewController) {
        return;
    }
    if (IS_IPHONE && [UIWindow interfaceOrientationIsLandscape]) {
        return;
    }

    UIStoryboard *instructionStoryBoard = [UIStoryboard storyboardWithName:IS_IPHONE ? A3StoryboardInstruction_iPhone : A3StoryboardInstruction_iPad bundle:nil];
    _instructionViewController = [instructionStoryBoard instantiateViewControllerWithIdentifier:(_chooseColorButton.isHidden || !_chooseColorButton) ? @"Clock1" : @"Clock2"];
    self.instructionViewController.delegate = self;
    [self.navigationController.view addSubview:self.instructionViewController.view];
    self.instructionViewController.view.frame = self.navigationController.view.frame;
    self.instructionViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
    
    
    if (![[A3UserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForClock1] && ![[A3UserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForClock2]) {
        self.instructionViewController.disableAnimation = YES;
    }
    else {
        self.instructionViewController.disableAnimation = NO;
    }
	[[A3UserDefaults standardUserDefaults] setBool:YES forKey:(_chooseColorButton.isHidden || !_chooseColorButton) ? A3V3InstructionDidShowForClock1 : A3V3InstructionDidShowForClock2];
	[[A3UserDefaults standardUserDefaults] synchronize];
 
    [self adjustInstructionFingerPositionForPortrait:[UIWindow interfaceOrientationIsPortrait]];
}

- (void)dismissInstructionViewController:(UIView *)view
{
    [self.instructionViewController.view removeFromSuperview];
    self.instructionViewController = nil;
    
    if (![[A3UserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForClock1]) {
        [self showMenus:NO];
        [self showInstructionView];
    }
    else if (![[A3UserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForClock2]) {
        [self showMenus:YES];
        [self showInstructionView];
    } else {
        [self resetAndStartAutoDimTimer];
    }
}

- (void)adjustInstructionFingerPositionForPortrait:(BOOL)isPortrait
{
    if (IS_IPHONE && !isPortrait && _instructionViewController) {
        [self dismissInstructionViewController:nil];
        return;
    }
    
    if (IS_IPHONE) {
        if (_chooseColorButton.isHidden && _instructionViewController) {
            if (isPortrait) {
                _instructionViewController.clock1_finger2RightConst.constant = 200;
                _instructionViewController.clock1_finger3RightConst.constant = 100;
            }
            else {
                _instructionViewController.clock1_finger2RightConst.constant = 36;
                _instructionViewController.clock1_finger3RightConst.constant = 363;
            }
        }
    }
    else {
        if (_chooseColorButton.isHidden && _instructionViewController) {
            if (isPortrait) {
                _instructionViewController.clock1_finger2RightConst.constant = 125;
                _instructionViewController.clock1_finger3RightConst.constant = 358;
                UILabel *bottomLabel = (UILabel *)[_instructionViewController.view viewWithTag:13];
                if (bottomLabel) {
                    bottomLabel.textAlignment = NSTextAlignmentCenter;
                }
            }
            else {
                _instructionViewController.clock1_finger2RightConst.constant = 315;
                _instructionViewController.clock1_finger3RightConst.constant = 195;
                UILabel *bottomLabel = (UILabel *)[_instructionViewController.view viewWithTag:13];
                if (bottomLabel) {
                    bottomLabel.textAlignment = NSTextAlignmentRight;
                }
            }
        }
    }
}

#pragma mark - A3ChooseColorDelegate

- (void)chooseColorDidSelect:(UIColor *)aColor selectedIndex:(NSUInteger)selectedIndex {
	switch (self.pageControl.currentPage) {
		case 0:{
			NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:aColor];
			A3UserDefaults *userDefaults = [A3UserDefaults standardUserDefaults];
			[userDefaults setObject:colorData forKey:A3ClockWaveClockColor];
			[userDefaults setObject:@(selectedIndex) forKey:A3ClockWaveClockColorIndex];
			[userDefaults synchronize];
			break;
		}
		case 1: {
			NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:aColor];
			A3UserDefaults *userDefaults = [A3UserDefaults standardUserDefaults];
			[userDefaults setObject:colorData forKey:A3ClockFlipDarkColor];
			[userDefaults setObject:@(selectedIndex) forKey:A3ClockFlipDarkColorIndex];
			[userDefaults synchronize];
			break;
		}
		case 2: {
			NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:aColor];
			A3UserDefaults *userDefaults = [A3UserDefaults standardUserDefaults];
			[userDefaults setObject:colorData forKey:A3ClockFlipLightColor];
			[userDefaults setObject:@(selectedIndex) forKey:A3ClockFlipLightColorIndex];
			[userDefaults synchronize];
			break;
		}
		case 3: {
			NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:aColor];
			A3UserDefaults *userDefaults = [A3UserDefaults standardUserDefaults];
			[userDefaults setObject:colorData forKey:A3ClockLEDColor];
			[userDefaults setObject:@(selectedIndex) forKey:A3ClockLEDColorIndex];
			[userDefaults synchronize];
			break;
		}
	}

	[_currentClockViewController changeColor:aColor];
	[self setButtonTintColor];

	[self hideChooseColorView];
}

- (void)chooseColorDidCancel {
	[self hideChooseColorView];
}

- (void)hideChooseColorView {
	[UIView animateWithDuration:0.3
					 animations:^{
						 CGFloat height = _chooseColorView.bounds.size.height;
						 [_chooseColorView mas_remakeConstraints:^(MASConstraintMaker *make) {
							 make.left.equalTo(self.view.left);
							 make.right.equalTo(self.view.right);
							 make.top.equalTo(self.view.bottom);
							 make.height.equalTo(@(height));
						 }];
						[self.view layoutIfNeeded];
					 }
					 completion:^(BOOL finished) {
						 [_chooseColorView removeFromSuperview];
						 _chooseColorView = nil;

                         [self resetAndStartAutoDimTimer];
					 }];
}

#pragma mark - Button Action

- (void)chooseColorButtonAction
{
    [self turnOffAutoDim];
	[self showMenus:NO];

	NSArray *colors = nil;
	NSUInteger selectedColorIndex = 0;
	switch (_pageControl.currentPage) {
		case 0:
			selectedColorIndex = [[A3UserDefaults standardUserDefaults] clockWaveColorIndex];
			colors = [self.clockDataManager waveColors];
			break;
		case 1:{
			selectedColorIndex = [[A3UserDefaults standardUserDefaults] clockFlipDarkColorIndex];
			colors = [self.clockDataManager flipColors];
			break;
		}
		case 2:{
			selectedColorIndex = [[A3UserDefaults standardUserDefaults] clockFlipLightColorIndex];
			colors = [self.clockDataManager flipColors];
			break;
		}
		case 3:
			selectedColorIndex = [[A3UserDefaults standardUserDefaults] clockLEDColorIndex];
			colors = [self.clockDataManager ledColors];
			break;
	}
	_chooseColorView = [A3ChooseColorView chooseColorWaveInViewController:self
																   inView:self.view
																   colors:colors
															selectedIndex:selectedColorIndex];
}

- (void)settingsButtonAction:(id)aSender
{
    [self turnOffAutoDim];
	[self showMenus:NO];

	A3ClockSettingsViewController *viewController = [[A3ClockSettingsViewController alloc] init];
	viewController.clockDataManager = self.clockDataManager;
	if (IS_IPHONE) {
		_modalNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
		[self presentViewController:_modalNavigationController animated:YES completion:NULL];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsViewControllerDidDismiss) name:A3NotificationChildViewControllerDidDismiss object:viewController];
	} else {
		[[[A3AppDelegate instance] rootViewController_iPad] presentRightSideViewController:viewController toViewController:nil];
	}
}

- (void)helpButtonAction:(id)aSende
{
    [self turnOffAutoDim];
    [self showMenus:NO];
    [[A3UserDefaults standardUserDefaults] setBool:NO forKey:A3V3InstructionDidShowForClock1];
    [[A3UserDefaults standardUserDefaults] setBool:NO forKey:A3V3InstructionDidShowForClock2];
	[[A3UserDefaults standardUserDefaults] synchronize];
    [self showInstructionView];
}

- (void)settingsViewControllerDidDismiss {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationChildViewControllerDidDismiss object:_modalNavigationController.childViewControllers[0]];
	_modalNavigationController = nil;
}

#pragma mark - datetime event

- (void)refreshSecond:(A3ClockInfo *)clockInfo {
	UIViewController<A3ClockDataManagerDelegate> *targetViewController = self.viewControllers[(NSUInteger) self.pageControl.currentPage];
	if ([targetViewController respondsToSelector:@selector(refreshSecond:)]) {
		[targetViewController refreshSecond:clockInfo];
	}
}

- (void)refreshWholeClock:(A3ClockInfo *)clockInfo {
	if ([_currentClockViewController respondsToSelector:@selector(refreshWholeClock:)]) {
		[_currentClockViewController refreshWholeClock:clockInfo];
	}
	double delayInSeconds = 0.4;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		for (id <A3ClockDataManagerDelegate> viewController in _viewControllers) {
			if (viewController != _currentClockViewController && [viewController respondsToSelector:@selector(refreshWholeClock:)]) {
				[viewController refreshWholeClock:clockInfo];
			}
		}
	});
}

- (void)refreshWeather:(A3ClockInfo *)clockInfo {
	if (_chooseColorButton.hidden) {
		_yahooButton.hidden = NO;
	}

	for (id<A3ClockDataManagerDelegate> viewController in self.viewControllers) {
		if ([viewController respondsToSelector:@selector(refreshWeather:)]) {
			[viewController refreshWeather:clockInfo];
		}
	}
}

#pragma mark - scrollView & pageControl event

- (void)pageControlValueChanged:(id)sender {
    UIPageControl *pControl = (UIPageControl *) sender;
    [self scrollToPage:pControl.currentPage];
	[self gotoPage:pControl.currentPage];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[self showMenus:NO];
	[self hideChooseColorView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
	CGFloat pageWidth = screenBounds.size.width;
	_pageControl.currentPage = (NSInteger) floorf(_scrollView.contentOffset.x / pageWidth);
	[self gotoPage:_pageControl.currentPage];
}

- (void)gotoPage:(NSInteger)page {
	[[A3UserDefaults standardUserDefaults] setInteger:_pageControl.currentPage forKey:A3ClockUserDefaultsCurrentPage];
	[[A3UserDefaults standardUserDefaults] synchronize];

	_currentClockViewController = self.viewControllers[(NSUInteger) _pageControl.currentPage];
	[self.view setBackgroundColor:_currentClockViewController.view.backgroundColor];

	[_currentClockViewController updateLayout];

	[self setButtonTintColor];
}

- (void)scrollToPage:(NSInteger)page {
	[_scrollView setContentOffset:CGPointMake(page * self.view.bounds.size.width, 0)];
}

- (void)setButtonTintColor {
	UIColor *tintColor;
	switch (_pageControl.currentPage) {
		case 0:
			tintColor = [UIColor whiteColor];
			break;
		case 1:
			if ([[A3UserDefaults standardUserDefaults] clockFlipDarkColorIndex] == 12) {
				tintColor = [UIColor whiteColor];
			} else {
				tintColor = [[A3UserDefaults standardUserDefaults] clockFlipDarkColor];
			}
			break;
		case 2:
			if ([[A3UserDefaults standardUserDefaults] clockFlipLightColorIndex] == 13) {
				tintColor = [UIColor blackColor];
			} else {
				tintColor = [[A3UserDefaults standardUserDefaults] clockFlipLightColor];
			}
			break;
		case 3:
			tintColor = [[A3UserDefaults standardUserDefaults] clockLEDColor];
			break;
	}
	_clockAppsButton.tintColor = tintColor;
	_settingsButton.tintColor = tintColor;
    _helpButton.tintColor = tintColor;
	_pageControl.tintColor = tintColor;
	_yahooButton.tintColor = tintColor;
}

- (NSUInteger)a3SupportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAll;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

	if (IS_IPHONE && UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
		[self.mm_drawerController closeDrawerAnimated:MMDrawerSideLeft completion:NULL];
		[self showMenus:NO];
	}
    
	[self layoutSubviews];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self adjustInstructionFingerPositionForPortrait:UIInterfaceOrientationIsPortrait(toInterfaceOrientation)];
}

- (void)layoutSubviews {
	self.view.frame = [self screenBoundsAdjustedWithOrientation];
	CGRect bounds = self.view.bounds;

	[self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger idx, BOOL *stop) {
		CGRect frame = CGRectMake(bounds.size.width * idx, 0, bounds.size.width, bounds.size.height);
		viewController.view.frame = frame;
	}];
	_scrollView.contentOffset = CGPointMake(bounds.size.width * _pageControl.currentPage, 0);
	_scrollView.contentSize = CGSizeMake(bounds.size.width * 4, bounds.size.height);

    CGFloat verticalOffset = 0;
    UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets];
    verticalOffset = safeAreaInsets.top - 26;

    if (IS_IPHONE && [UIWindow interfaceOrientationIsLandscape]) {
		_appsButtonTop.with.offset(5);
	} else {
		_appsButtonTop.with.offset(26 + verticalOffset);
	}
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    BOOL useDefault = (IS_IPAD && [[A3AppDelegate instance] rootViewController_iPad].showLeftView) || _pageControl.currentPage == 2 || (IS_IPHONE && self.mm_drawerController.openSide == MMDrawerSideLeft);
    return useDefault ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
}

- (BOOL)usesFullScreenInLandscape {
	return YES;
}

@end
