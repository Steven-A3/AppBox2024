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
#import "A3ChooseColor.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "A3ClockSettingsViewController.h"
#import "A3UserDefaults.h"
#import "A3ClockInfo.h"

#define kCntPage 4.0

@interface A3ClockMainViewController () <A3ClockDataManagerDelegate, A3ChooseColorDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIButton *appsButton;
@property (nonatomic, strong) UIButton *settingsButton;
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
@property (nonatomic, strong) id<MASConstraint> appsButtonTop;

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

    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    [self.view addSubview:self.scrollView];

	_appsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_appsButton setTitle:@"Apps" forState:UIControlStateNormal];
	FNLOG(@"%0.f", _appsButton.titleLabel.font.pointSize);
	_appsButton.titleLabel.font = [UIFont systemFontOfSize:17];
	[_appsButton sizeToFit];
	[_appsButton addTarget:self action:@selector(appsButtonAction) forControlEvents:UIControlEventTouchUpInside];
	[_appsButton setHidden:YES];
	[self.view addSubview:_appsButton];

	[_appsButton makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view).with.offset(8);
		_appsButtonTop = make.top.equalTo(self.view).with.offset(35);
	}];

	_settingsButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[_settingsButton setImage:[UIImage imageNamed:@"general"] forState:UIControlStateNormal];
	[_settingsButton addTarget:self action:@selector(settingsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	_settingsButton.tintColor = [UIColor whiteColor];
	[_settingsButton setHidden:YES];
	[_settingsButton sizeToFit];
	[self.view addSubview:_settingsButton];

	[_settingsButton makeConstraints:^(MASConstraintMaker *make) {
		make.right.equalTo(self.view.right).with.offset(-15);
		make.centerY.equalTo(_appsButton.centerY);
	}];

	[self.view addSubview:self.pageControl];

	CGRect bounds = [self screenBoundsAdjustedWithOrientation];
    [_pageControl makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.view.centerX);
		if (IS_IPHONE) {
			make.bottom.equalTo(self.view.bottom).with.offset(bounds.size.height == 480 ? 5 : 0);
		} else {
			make.bottom.equalTo(self.view.bottom).with.offset(0);
		}
	}];
    
	[self addChooseColorButton];

	_currentClockViewController = _clockWaveViewController;
    
    [self.view setBackgroundColor:_currentClockViewController.view.backgroundColor];

	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapMainView)];
	[self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self layoutSubview];

	if ([self isMovingToParentViewController]) {
		[_clockWaveViewController setupSubviews];
		[_clockFlipBrightViewController setupSubviews];
		[_clockFlipDarkViewController setupSubviews];
		[_clockLEDViewController setupSubviews];
	}

	[self.clockDataManager startTimer];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsChanged) name:A3NotificationClockSettingsChanged object:nil];
	}

	FNLOGRECT(self.view.frame);
}

- (void)settingsChanged {
	switch (_pageControl.currentPage) {
		case 0:
			[_clockWaveViewController updateLayout];
			break;
	}
}

- (void)addChooseColorButton {
	_chooseColorButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_chooseColorButton setBackgroundImage:[UIImage imageNamed:@"m_color_on"] forState:UIControlStateNormal];
	[_chooseColorButton addTarget:self action:@selector(chooseColorButtonAction) forControlEvents:UIControlEventTouchUpInside];
	[_chooseColorButton setHidden:YES];
	[_chooseColorButton sizeToFit];
	[self.view addSubview:_chooseColorButton];

	[_chooseColorButton makeConstraints:^(MASConstraintMaker *make) {
		make.right.equalTo(self.view.right).offset(-15);
		make.bottom.equalTo(self.view.bottom).offset(-15);
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
		_clockWaveViewController.view.frame = _scrollView.bounds;
	}
	return _clockWaveViewController;
}

- (A3ClockFlipViewController *)clockFlipDarkViewController {
	if (!_clockFlipDarkViewController) {
		_clockFlipDarkViewController = [[A3ClockFlipViewController alloc] initWithClockDataManager:self.clockDataManager];
		[_clockFlipDarkViewController.view setCenter:CGPointMake(self.clockWaveViewController.view.center.x + self.scrollView.frame.size.width, self.clockWaveViewController.view.center.y)];
		[_clockFlipDarkViewController.view setBackgroundColor:[UIColor colorWithRed:23.f / 255.f green:23.f / 255.f blue:24.f / 255.f alpha:1.f]];
	}
	return _clockFlipDarkViewController;
}

- (A3ClockFlipViewController *)clockFlipBrightViewController {
	if (!_clockFlipBrightViewController) {
		_clockFlipBrightViewController = [[A3ClockFlipViewController alloc] initWithClockDataManager:self.clockDataManager];
		[_clockFlipBrightViewController.view setCenter:CGPointMake(self.clockFlipDarkViewController.view.center.x + self.scrollView.frame.size.width, self.clockWaveViewController.view.center.y)];
		[_clockFlipBrightViewController.view setBackgroundColor:[UIColor colorWithRed:239.f / 255.f green:239.f / 255.f blue:244.f / 255.f alpha:1.f]];
	}
	return _clockFlipBrightViewController;
}

- (A3ClockLEDViewController *)clockLEDViewController {
	if (!_clockLEDViewController) {
		_clockLEDViewController = [[A3ClockLEDViewController alloc] initWithClockDataManager:self.clockDataManager];
		[_clockLEDViewController.view setCenter:CGPointMake(self.clockFlipBrightViewController.view.center.x + self.scrollView.frame.size.width, self.clockWaveViewController.view.center.y)];
	}
	return _clockLEDViewController;
}

- (void)onTapMainView {
	if (_chooseColorView) {
		[self chooseColorDidCancel];
	}
	[self showMenus:_appsButton.isHidden];
}

#pragma mark - private

- (void)showMenus:(BOOL)show
{
	_appsButton.hidden = !show;
	_settingsButton.hidden = !show;
    _pageControl.hidden = !show;
    _chooseColorButton.hidden = !show;

	if (!(show && IS_IPHONE && IS_LANDSCAPE)) {
		[[UIApplication sharedApplication] setStatusBarHidden:!show withAnimation:UIStatusBarAnimationNone];
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	}
}

- (BOOL)prefersStatusBarHidden {
    return self.navigationController.navigationBarHidden;
}

#pragma mark - A3ChooseColorDelegate

- (void)chooseColorDidSelect:(UIColor *)aColor selectedIndex:(NSUInteger)selectedIndex {
	[_currentClockViewController changeColor:aColor];

	switch (self.pageControl.currentPage) {
		case 0:{
			NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:aColor];
			NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
			[userDefaults setObject:colorData forKey:A3ClockWaveClockColor];
			[userDefaults setObject:@(selectedIndex) forKey:A3ClockWaveClockColorIndex];
			[userDefaults synchronize];
			break;
		}
	}

	[UIView animateWithDuration:0.3 animations:^{
		CGRect frame = _chooseColorView.frame;
		frame.origin.y += frame.size.height;
		_chooseColorView.frame = frame;
	} completion:^(BOOL finished) {
		[_chooseColorView removeFromSuperview];
		_chooseColorView = nil;
	}];
}

- (void)chooseColorDidCancel {
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

#pragma mark - btn event
- (void)chooseColorButtonAction
{
	NSArray *colors = nil;
	switch (_pageControl.currentPage) {
		case 0:
			colors = [self.clockDataManager waveColors];
			_chooseColorView = [A3ChooseColor chooseColorWaveInViewController:self
																	   colors:colors
																selectedIndex:(NSUInteger) [[NSUserDefaults standardUserDefaults] integerForKey:A3ClockWaveClockColorIndex]];
			break;
		case 1:
		case 2:
			colors = [self.clockDataManager flipColors];
			[A3ChooseColor chooseColorFlipInViewController:self colors:colors];
			break;
		case 3:
			colors = [self.clockDataManager ledColors];
			[A3ChooseColor chooseColorLED:self colors:colors];
			break;
	}
}

- (void)settingsButtonAction:(id)aSender
{
    @autoreleasepool {
		A3ClockSettingsViewController *viewController = [[A3ClockSettingsViewController alloc] init];
		viewController.clockDataManager = self.clockDataManager;
		[self presentSubViewController:viewController];
	}
}

#pragma mark - datetime event

- (void)refreshSecond:(A3ClockInfo *)clockInfo {
	UIViewController<A3ClockDataManagerDelegate> *targetViewController = self.viewControllers[(NSUInteger) self.pageControl.currentPage];
	if ([targetViewController respondsToSelector:@selector(refreshSecond:)]) {
		[targetViewController refreshSecond:clockInfo];
	}
}

- (void)refreshWholeClock:(A3ClockInfo *)clockInfo {
	UIViewController<A3ClockDataManagerDelegate> *targetViewController = self.viewControllers[(NSUInteger) self.pageControl.currentPage];
	if ([targetViewController respondsToSelector:@selector(refreshWholeClock:)]) {
		[targetViewController refreshWholeClock:clockInfo];
	}
}

- (void)refreshWeather:(A3ClockInfo *)clockInfo {
	UIViewController<A3ClockDataManagerDelegate> *targetViewController = self.viewControllers[(NSUInteger) self.pageControl.currentPage];
	if ([targetViewController respondsToSelector:@selector(refreshWeather:)]) {
		[targetViewController refreshWeather:clockInfo];
	}
}

#pragma mark - scrollView & pageControl event

- (void) pageChangeValue:(id)sender {
    UIPageControl *pControl = (UIPageControl *) sender;
    [_scrollView setContentOffset:CGPointMake(pControl.currentPage*self.view.bounds.size.width, 0) animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	for (UIViewController <A3ClockDataManagerDelegate> *viewController in self.viewControllers) {
		[viewController refreshWholeClock:self.clockDataManager.clockInfo];
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat pageWidth = _scrollView.frame.size.width;
    _pageControl.currentPage = (NSInteger) (((_scrollView.contentOffset.x - pageWidth / kCntPage) / pageWidth) + 1);
    
    [self showMenus:NO];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float offsetDV = _scrollView.contentOffset.x / 320.f;
    
    if(offsetDV == 0)
        _currentClockViewController = _clockWaveViewController;
    else
    {
        _currentClockViewController = _clockFlipDarkViewController;
    }
    
    [self.view setBackgroundColor:_currentClockViewController.view.backgroundColor];
}

- (NSUInteger)a3SupportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAll;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

	[self layoutSubview];
}

- (void)layoutSubview {
	CGRect bounds = self.view.bounds;
	FNLOGRECT(bounds);

	_scrollView.contentSize = CGSizeMake(bounds.size.width * 4, bounds.size.height);
	[self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger idx, BOOL *stop) {
		CGRect frame = CGRectMake(bounds.size.width * idx, 0, bounds.size.width, bounds.size.height);
		viewController.view.frame = frame;
	}];
	if (IS_IPHONE && IS_LANDSCAPE) {
		_appsButtonTop.with.offset(5);
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
	} else {
		_appsButtonTop.with.offset(35);
		[[UIApplication sharedApplication] setStatusBarHidden:_appsButton.isHidden withAnimation:UIStatusBarAnimationNone];
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	}
}

- (BOOL)usesFullScreenInLandscape {
	return YES;
}

@end
