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
#import "A3UserDefaults.h"
#import "A3ClockInfo.h"
#import "NSUserDefaults+A3Defaults.h"
#import "UIViewController+MMDrawerController.h"
#import "A3ChooseColorView.h"
#import "A3InstructionViewController.h"
#import "UIViewController+iPad_rightSideView.h"

#define kCntPage 4.0

@interface A3ClockMainViewController () <A3ClockDataManagerDelegate, A3ChooseColorDelegate, A3InstructionViewControllerDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIButton *clockAppsButton;
@property (nonatomic, strong) UIButton *settingsButton;
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
@property (nonatomic, strong) UITapGestureRecognizer *instructionTwoFingerTapGesture;
@property (nonatomic, assign) BOOL useInstruction;
@end

@implementation A3ClockMainViewController

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
	[self yahooButton];

	[self.view addSubview:self.pageControl];

	[self setButtonTintColor];

	CGRect bounds = [self screenBoundsAdjustedWithOrientation];
    [_pageControl makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.view.centerX);
		if (IS_IPHONE) {
			make.bottom.equalTo(self.view.bottom).with.offset(bounds.size.height == 480 ? 5 : 0);
		} else {
			make.bottom.equalTo(self.view.bottom).with.offset(0);
		}
	}];
	[self determineStatusBarStyle];
	[self addChooseColorButton];
//    [self setupInstructionView];

	_currentClockViewController = _clockWaveViewController;

    [self.view setBackgroundColor:_currentClockViewController.view.backgroundColor];

	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapMainView)];
	[self.scrollView addGestureRecognizer:tapGestureRecognizer];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(drawerStateChanged) name:A3DrawerStateChanged object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsChanged) name:A3NotificationClockSettingsChanged object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
}

- (void)removeObserver {
	FNLOG();
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3DrawerStateChanged object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidHide object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationClockSettingsChanged object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
}

- (void)cleanUp {
	[self removeObserver];
	[_clockDataManager cleanUp];
	[_buttonsTimer invalidate];
	_buttonsTimer = nil;
}

- (void)dealloc {
	[self removeObserver];
}

- (void)drawerStateChanged {
    [self setupInstructionView];
	[self.scrollView setScrollEnabled:self.mm_drawerController.openSide == MMDrawerSideNone];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if ([self isMovingToParentViewController]) {
		[self layoutSubviews];
		[self.clockDataManager startTimer];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];

	if ([self isMovingToParentViewController]) {
		[self showMenus:YES];
	}
}

- (UIButton *)clockAppsButton {
	if (!_clockAppsButton) {
		_clockAppsButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[_clockAppsButton setTitle:@"Apps" forState:UIControlStateNormal];
		_clockAppsButton.titleLabel.font = [UIFont systemFontOfSize:17];
		[_clockAppsButton sizeToFit];
		[_clockAppsButton addTarget:self action:@selector(appsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
		[_clockAppsButton setHidden:YES];
		[self.view addSubview:_clockAppsButton];

		[_clockAppsButton makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.view).with.offset(8);
			_appsButtonTop = make.top.equalTo(self.view.top).with.offset(26);
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
			make.centerY.equalTo(_clockAppsButton.centerY);
			make.width.equalTo(@40);
			make.height.equalTo(@40);
		}];
	}
	return _settingsButton;
}

- (UIButton *)yahooButton {
	if (!_yahooButton) {
		_yahooButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[_yahooButton setImage:[UIImage imageNamed:@"yahoo"] forState:UIControlStateNormal];
		[_yahooButton addTarget:self action:@selector(yahooButtonAction) forControlEvents:UIControlEventTouchUpInside];
		[_yahooButton setHidden:YES];
		[_yahooButton sizeToFit];
		[self.view addSubview:_yahooButton];

		[_yahooButton makeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(self.view.right).offset(IS_IPHONE ? -40 : -56);
			make.centerY.equalTo(self.view.bottom).offset(IS_IPHONE ? -18 : -36);
			make.height.equalTo(@40);
		}];
	}
	return _yahooButton;
}

- (void)yahooButtonAction {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://weather.yahoo.com"]];
}

- (void)settingsChanged {
	[_currentClockViewController updateLayout];

	if ([[NSUserDefaults standardUserDefaults] clockShowWeather]) {
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

	[_chooseColorButton makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.view.right).offset(-28);
		make.centerY.equalTo(self.view.bottom).offset(-28);
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
		[_pageControl addTarget:self action:@selector(pageChangeValue:) forControlEvents:UIControlEventValueChanged];
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

- (void)appsButtonAction:(UIBarButtonItem *)barButtonItem {
	if (IS_IPHONE) {
		[[self mm_drawerController] toggleDrawerSide:MMDrawerSideLeft animated:YES completion:^(BOOL finished) {
			[self.scrollView setScrollEnabled:self.mm_drawerController.openSide == MMDrawerSideNone];
			[[UIApplication sharedApplication] setStatusBarHidden:NO];
			[self determineStatusBarStyle];
		}];
	} else {
		[[[A3AppDelegate instance] rootViewController] toggleLeftMenuViewOnOff];
		[[UIApplication sharedApplication] setStatusBarHidden:NO];
		[self determineStatusBarStyle];
	}
}

- (void)mainMenuDidHide {
	[self showMenus:NO];
    if (IS_IPAD) {
        [self setupInstructionView];
    }
}

- (void)onTapMainView {
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
	_clockAppsButton.hidden = !show || (IS_IPHONE && IS_LANDSCAPE);
	_settingsButton.hidden = !show || (IS_IPHONE && IS_LANDSCAPE);
	_pageControl.hidden = !show;
	_chooseColorButton.hidden = !show;
	if (show) {
		_yahooButton.hidden = YES;
	}
    else {
		_yahooButton.hidden = _clockDataManager.clockInfo.currentWeather == nil;
	}

    if (_useInstruction) {
        if (show) {
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"Clock2"]) {
                [self showInstructionView];
            }
        }
        else {
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"Clock1"]) {
                [self showInstructionView];
            }
        }
    }
    
	if (!(show && IS_IPHONE && IS_LANDSCAPE)) {
		if (self.mm_drawerController.openSide != MMDrawerSideLeft) {
			[[UIApplication sharedApplication] setStatusBarHidden:!show withAnimation:UIStatusBarAnimationNone];
		}
		[self determineStatusBarStyle];
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

- (BOOL)prefersStatusBarHidden {
    return self.navigationController.navigationBarHidden;
}

#pragma mark Instruction Related
- (void)setupInstructionView
{
    _useInstruction = YES;
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"Clock1"]) {
        [self showInstructionView];
    }

    if (!_instructionTwoFingerTapGesture) {
        _instructionTwoFingerTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showInstructionView)];
        [_instructionTwoFingerTapGesture setNumberOfTouchesRequired:2];
        [_instructionTwoFingerTapGesture setNumberOfTapsRequired:2];
        [self.view addGestureRecognizer:_instructionTwoFingerTapGesture];
    }
}

- (void)showInstructionView
{
    if (_instructionViewController) {
        return;
    }
    if (IS_IPHONE && IS_LANDSCAPE) {
        return;
    }
    
    UIStoryboard *instructionStoryBoard = [UIStoryboard storyboardWithName:IS_IPHONE ? @"Instruction_iPhone" : @"Instruction_iPad" bundle:nil];
    _instructionViewController = [instructionStoryBoard instantiateViewControllerWithIdentifier:_chooseColorButton.isHidden ? @"Clock1" : @"Clock2"];
    self.instructionViewController.delegate = self;
    [self.navigationController.view addSubview:self.instructionViewController.view];
    self.instructionViewController.view.frame = self.navigationController.view.frame;
    self.instructionViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
 
    [self adjustInstructionFingerPositionForPortrait:IS_PORTRAIT];
}

- (void)dismissInstructionViewController:(UIView *)view
{
    [self.instructionViewController.view removeFromSuperview];
    self.instructionViewController = nil;
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
            }
            else {
                _instructionViewController.clock1_finger2RightConst.constant = 315;
                _instructionViewController.clock1_finger3RightConst.constant = 195;
            }
        }
    }
}

#pragma mark - A3ChooseColorDelegate

- (void)chooseColorDidSelect:(UIColor *)aColor selectedIndex:(NSUInteger)selectedIndex {
	switch (self.pageControl.currentPage) {
		case 0:{
			NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:aColor];
			NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
			[userDefaults setObject:colorData forKey:A3ClockWaveClockColor];
			[userDefaults setObject:@(selectedIndex) forKey:A3ClockWaveClockColorIndex];
			[userDefaults synchronize];
			break;
		}
		case 1: {
			NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:aColor];
			NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
			[userDefaults setObject:colorData forKey:A3ClockFlipDarkColor];
			[userDefaults setObject:@(selectedIndex) forKey:A3ClockFlipDarkColorIndex];
			[userDefaults synchronize];
			break;
		}
		case 2: {
			NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:aColor];
			NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
			[userDefaults setObject:colorData forKey:A3ClockFlipLightColor];
			[userDefaults setObject:@(selectedIndex) forKey:A3ClockFlipLightColorIndex];
			[userDefaults synchronize];
			break;
		}
		case 3: {
			NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:aColor];
			NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
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
						 CGRect frame = _chooseColorView.frame;
						 frame.origin.y += frame.size.height;
						 _chooseColorView.frame = frame;
					 }
					 completion:^(BOOL finished) {
						 [_chooseColorView removeFromSuperview];
						 _chooseColorView = nil;
					 }];
}

#pragma mark - Button Action

- (void)chooseColorButtonAction
{
	[self showMenus:NO];

	NSArray *colors = nil;
	NSUInteger selectedColorIndex = 0;
	switch (_pageControl.currentPage) {
		case 0:
			selectedColorIndex = [[NSUserDefaults standardUserDefaults] clockWaveColorIndex];
			colors = [self.clockDataManager waveColors];
			break;
		case 1:{
			selectedColorIndex = [[NSUserDefaults standardUserDefaults] clockFlipDarkColorIndex];
			colors = [self.clockDataManager flipColors];
			break;
		}
		case 2:{
			selectedColorIndex = [[NSUserDefaults standardUserDefaults] clockFlipLightColorIndex];
			colors = [self.clockDataManager flipColors];
			break;
		}
		case 3:
			selectedColorIndex = [[NSUserDefaults standardUserDefaults] clockLEDColorIndex];
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
	[self showMenus:NO];

	A3ClockSettingsViewController *viewController = [[A3ClockSettingsViewController alloc] init];
	viewController.clockDataManager = self.clockDataManager;
	if (IS_IPHONE) {
		_modalNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
		[self presentViewController:_modalNavigationController animated:YES completion:NULL];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsViewControllerDidDismiss) name:A3NotificationChildViewControllerDidDismiss object:viewController];
	} else {
		[self.A3RootViewController presentRightSideViewController:viewController];
	}
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

- (void)pageChangeValue:(id)sender {
    UIPageControl *pControl = (UIPageControl *) sender;
    [_scrollView setContentOffset:CGPointMake(pControl.currentPage*self.view.bounds.size.width, 0) animated:YES];
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
    
    _currentClockViewController = self.viewControllers[(NSUInteger) _pageControl.currentPage];
    [self.view setBackgroundColor:_currentClockViewController.view.backgroundColor];

	[_currentClockViewController updateLayout];

	[self setButtonTintColor];
}

- (void)setButtonTintColor {
	UIColor *tintColor;
	switch (_pageControl.currentPage) {
		case 0:
			tintColor = [UIColor whiteColor];
			break;
		case 1:
			if ([[NSUserDefaults standardUserDefaults] clockFlipDarkColorIndex] == 12) {
				tintColor = [UIColor whiteColor];
			} else {
				tintColor = [[NSUserDefaults standardUserDefaults] clockFlipDarkColor];
			}
			break;
		case 2:
			if ([[NSUserDefaults standardUserDefaults] clockFlipLightColorIndex] == 13) {
				tintColor = [UIColor blackColor];
			} else {
				tintColor = [[NSUserDefaults standardUserDefaults] clockFlipLightColor];
			}
			break;
		case 3:
			tintColor = [[NSUserDefaults standardUserDefaults] clockLEDColor];
			break;
	}
	_clockAppsButton.tintColor = tintColor;
	_settingsButton.tintColor = tintColor;
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
	FNLOGRECT(bounds);

	[self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger idx, BOOL *stop) {
		CGRect frame = CGRectMake(bounds.size.width * idx, 0, bounds.size.width, bounds.size.height);
		viewController.view.frame = frame;
	}];
	_scrollView.contentOffset = CGPointMake(bounds.size.width * _pageControl.currentPage, 0);
	_scrollView.contentSize = CGSizeMake(bounds.size.width * 4, bounds.size.height);

	if (IS_IPHONE && IS_LANDSCAPE) {
		_appsButtonTop.with.offset(5);
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
	} else {
		BOOL hideStatusBar = [_clockAppsButton isHidden] || !self.A3RootViewController.showLeftView;
		FNLOG(@"%ld, %ld", (long)hideStatusBar, (long)self.A3RootViewController.showLeftView);
		_appsButtonTop.with.offset(26);
		FNLOG(@"setStatusBarHidden:%ld", (long)hideStatusBar);
		[[UIApplication sharedApplication] setStatusBarHidden:hideStatusBar withAnimation:UIStatusBarAnimationNone];
		[self determineStatusBarStyle];
	}
}

- (void)determineStatusBarStyle {
	BOOL useDefault = (IS_IPAD && self.A3RootViewController.showLeftView) || _pageControl.currentPage == 2 || (IS_IPHONE && self.mm_drawerController.openSide == MMDrawerSideLeft);
	if (useDefault) {
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	} else {
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	}
}

- (BOOL)usesFullScreenInLandscape {
	return YES;
}

@end
