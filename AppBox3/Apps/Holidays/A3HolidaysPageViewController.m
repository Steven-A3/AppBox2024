//
//  A3HolidaysPageViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/15/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "A3HolidaysPageViewController.h"
#import "HolidayData.h"
#import "HolidayData+Country.h"
#import "A3HolidaysPageContentViewController.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3HolidaysEditViewController.h"
#import "FXPageControl.h"
#import "A3GradientView.h"
#import "SFKImage.h"
#import "UIView+Screenshot.h"
#import "A3HolidaysCountryViewController.h"
#import "NSDate-Utilities.h"
#import "A3CenterViewDelegate.h"
#import "UIViewController+A3Addition.h"
#import "NSDateFormatter+A3Addition.h"
#import "NSDate+LunarConverter.h"
#import "A3UserDefaults+A3Addition.h"
#import "NSDateFormatter+LunarDate.h"
#import "A3HolidaysFlickrDownloadManager.h"
#import "A3InstructionViewController.h"
#import "A3UserDefaults.h"
#import "A3NavigationController.h"
#import "UIViewController+extension.h"
#import "A3SyncManager.h"
#import "A3AppDelegate.h"
#import "A3UIDevice.h"

@interface A3HolidaysPageViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource,
		A3HolidaysEditViewControllerDelegate, FXPageControlDelegate, A3HolidaysCountryViewControllerDelegate,
		A3HolidaysPageViewControllerProtocol, A3CenterViewDelegate, UIAlertViewDelegate, A3InstructionViewControllerDelegate, GADBannerViewDelegate>

@property (nonatomic, strong) NSArray *countries;
@property (nonatomic, strong) FXPageControl *pageControl;
@property (nonatomic, strong) UILabel *photoLabel1;
@property (nonatomic, strong) UILabel *photoLabel2;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) MASConstraint *pageControlWidth;
@property (nonatomic, strong) A3GradientView *coverGradientView;
@property (nonatomic, strong) NSTimer *dayChangedTimer;
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (atomic, strong) NSMutableDictionary *viewControllerCache;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSString *dateFormat;
@property (nonatomic, strong) A3InstructionViewController *instructionViewController;
@property (nonatomic, strong) UIAlertView *disclaimerAlertView;
@end

@implementation A3HolidaysPageViewController {
	NSInteger _lastPageIndex, _currentPageIndex;
	BOOL _isClosing;
	BOOL _didRunViewWillAppear;
    CGFloat _verticalOffset;
}

- (void)cleanUp {
	FNLOG();
	[self dismissInstructionViewController:nil];
	[self removeObserver];

	[_pageViewController.viewControllers enumerateObjectsUsingBlock:^(id<A3CenterViewDelegate> obj, NSUInteger idx, BOOL *stop) {
		if ([obj respondsToSelector:@selector(cleanUp)]) {
			[obj cleanUp];
		}
	}];
	_pageViewController = nil;
	_countries = nil;
	_pageControl = nil;
	_photoLabel1 = nil;
	_photoLabel2 = nil;
	_footerView = nil;
	_coverGradientView = nil;
	[_dayChangedTimer invalidate];
	_dayChangedTimer = nil;
	_viewControllerCache = nil;
}

- (void)prepareClose {
	_isClosing = YES;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

    UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets];
    if (safeAreaInsets.top > 20) {
        _verticalOffset = -safeAreaInsets.bottom;
    }
    
	[self prepareDateFormat];

	_viewControllerCache = [NSMutableDictionary new];

    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
	_pageViewController.delegate = self;
	_pageViewController.dataSource = self;
	_pageViewController.view.backgroundColor = [UIColor blackColor];
	[self addChildViewController:_pageViewController];
	[self.view addSubview:_pageViewController.view];

	[self setupNavigationBar];

	[self setupFooterView];
	[self coverGradientView];

	[self.view layoutIfNeeded];
	[self registerContentSizeCategoryDidChangeNotification];
    [self setupInstructionView];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
	_lastPageIndex = NSNotFound;
	_currentPageIndex = NSNotFound;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(countryListChanged) name:A3NotificationHolidaysCountryListChanged object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)applicationDidEnterBackground {
	[self dismissInstructionViewController:nil];
}

- (void)countryListChanged {
	_countries = nil;
	_pageControl.numberOfPages = [self.countries count];

	NSInteger page = self.pageControl.currentPage;
	if (page >= _pageControl.numberOfPages) {
		page = _pageControl.numberOfPages - 1;
	}
	[self jumpToPage:page direction:UIPageViewControllerNavigationDirectionForward animated:NO ];
	_pageControl.currentPage = page;

	dispatch_async(dispatch_get_main_queue(), ^{
		NSArray *allKeys = [self.viewControllerCache allKeys];
		for (NSString *key in allKeys) {
			if (![self.countries containsObject:key]) {
				[self.viewControllerCache removeObjectForKey:key];
			}
		}
	});
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if (!_didRunViewWillAppear) {
		_didRunViewWillAppear = YES;
		[self jumpToPage:0 direction:UIPageViewControllerNavigationDirectionForward animated:NO];
	} else {
		if (!_isClosing) {
			[self setNavigationBarHidden:YES];
		}
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([self isMovingToParentViewController] || [self isBeingPresented]) {
		NSDate *fireDate = [[NSDate dateTomorrow] dateAtStartOfDay];
		FNLOG(@"%@, %f", fireDate, [fireDate timeIntervalSinceNow]/(60 * 60));
		_dayChangedTimer = [[NSTimer alloc] initWithFireDate:fireDate
													interval:0
													  target:self
													selector:@selector(dayChanged:)
													userInfo:nil
													 repeats:YES];

		NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
		[runLoop addTimer:_dayChangedTimer forMode:NSDefaultRunLoopMode];

		[self prepareViewControllerAtPage:1];

		[self alertDisclaimer];

		[self setupBannerViewForAdUnitID:AdMobAdUnitIDHolidays keywords:@[@"holidays"] delegate:self];
	}
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
	[self removeContentSizeCategoryDidChangeNotification];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
		[_dayChangedTimer invalidate];
		_dayChangedTimer = nil;
	}
}

- (void)dealloc {
	[self removeObserver];
}

- (BOOL)resignFirstResponder {
	NSString *startingAppName = [[A3UserDefaults standardUserDefaults] objectForKey:kA3AppsStartingAppName];
	if ([startingAppName length] && ![startingAppName isEqualToString:A3AppName_Holidays]) {
		if (_disclaimerAlertView) {
			[_disclaimerAlertView dismissWithClickedButtonIndex:_disclaimerAlertView.cancelButtonIndex animated:NO];
		}
		[self.instructionViewController.view removeFromSuperview];
		self.instructionViewController = nil;
	}
	return [super resignFirstResponder];
}

- (void)alertDisclaimer {
	if (![[A3UserDefaults standardUserDefaults] boolForKey:A3HolidaysDoesNotNeedsShowDisclaimer]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Disclaimer", nil)
															message:NSLocalizedString(@"DISCLAIMER_MESSAGE", @"DISCLAIMER_MESSAGE")
														   delegate:self
												  cancelButtonTitle:NSLocalizedString(@"I Agree", @"I Agree")
												  otherButtonTitles:nil];
		alertView.tag = 82093;
		[alertView show];
		_disclaimerAlertView = alertView;
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 82093) {
		[[A3UserDefaults standardUserDefaults] setBool:YES forKey:A3HolidaysDoesNotNeedsShowDisclaimer];
		[[A3UserDefaults standardUserDefaults] synchronize];
	}
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	FNLOG();
	if (alertView == _disclaimerAlertView) {
		_disclaimerAlertView = nil;
	}
}

- (void)contentSizeDidChange:(NSNotification *)notification {
	[self.currentContentViewController reloadDataRedrawImage:NO];
}

- (void)dayChanged:(NSTimer *)timer {
	[_dayChangedTimer invalidate];
	_dayChangedTimer = nil;

	[self.currentContentViewController updateTableHeaderView];
}

#pragma mark Instruction Related

static NSString *const A3V3InstructionDidShowForHoliday = @"A3V3InstructionDidShowForHoliday";

- (void)setupInstructionView
{
    if (![[A3UserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForHoliday]) {
        [self showInstructionView];
    }
}

- (void)showInstructionView
{
	[[A3UserDefaults standardUserDefaults] setBool:YES forKey:A3V3InstructionDidShowForHoliday];
	[[A3UserDefaults standardUserDefaults] synchronize];

    UIStoryboard *instructionStoryBoard = [UIStoryboard storyboardWithName:IS_IPHONE ? A3StoryboardInstruction_iPhone : A3StoryboardInstruction_iPad bundle:nil];
    _instructionViewController = [instructionStoryBoard instantiateViewControllerWithIdentifier:@"Holidays_1"];
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

#pragma mark - Find location and udpate country list

- (void)viewWillLayoutSubviews{
	[super viewWillLayoutSubviews];

	CGSize size = [_pageControl sizeForNumberOfPages:_pageControl.numberOfPages];
	_pageControlWidth.offset(size.width);
}

- (void)setupNavigationBar {
	UIImage *image = [[UIImage alloc] init];
	[self.navigationController.navigationBar setBackgroundImage:image forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
	[self.navigationController.navigationBar setShadowImage:image];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	[self.navigationController setNavigationBarHidden:YES];

	[self leftBarButtonAppsButton];
	self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
	[self setupRightBarButtonItems];

	[self setupGestureRecognizer];
    
    [self makeNavigationBarAppearanceTransparent];
}

- (void)setupGestureRecognizer {
	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnScrollView)];
	[self.view addGestureRecognizer:gestureRecognizer];
}

- (void)tapOnScrollView {
	if (IS_IPAD || [UIWindow interfaceOrientationIsPortrait]) {
		BOOL navigationBarHidden = self.navigationController.navigationBarHidden;
		[self setNavigationBarHidden:!navigationBarHidden];
	}
}

- (void)setNavigationBarHidden:(BOOL)hidden {
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	[[UIApplication sharedApplication] setStatusBarHidden:hidden];
	[self.navigationController setNavigationBarHidden:hidden];
	[self setupCoverGradientOnTappedStatus:!hidden];
}

- (A3GradientView *)coverGradientView {
	if (!_coverGradientView) {
		_coverGradientView = [A3GradientView new];
		_coverGradientView.locations = @[@0, @0.5, @0.85, @1.0];
		_coverGradientView.gradientColors = @[
				(id) [UIColor colorWithWhite:0.0 alpha:0.0].CGColor,
				(id) [UIColor colorWithWhite:0.0 alpha:0.0].CGColor,
				(id) [UIColor colorWithWhite:0.0 alpha:0.17].CGColor,
				(id) [UIColor colorWithWhite:0.0 alpha:0.17].CGColor
		];
		[self.view addSubview:_coverGradientView];

		[_coverGradientView makeConstraints:^(MASConstraintMaker *make) {
			make.top.equalTo(self.view.top);
			make.left.equalTo(self.view.left);
			make.right.equalTo(self.view.right);
			make.bottom.equalTo(self.view.bottom);
		}];
	}

	return _coverGradientView;
}

- (void)setupCoverGradientOnTappedStatus:(BOOL)tapped {
	if (tapped) {
		self.coverGradientView.gradientColors = @[
				(id) [UIColor colorWithWhite:0.0 alpha:0.17].CGColor,
				(id) [UIColor colorWithWhite:0.0 alpha:0.0].CGColor,
				(id) [UIColor colorWithWhite:0.0 alpha:0.17].CGColor,
				(id) [UIColor colorWithWhite:0.0 alpha:0.17].CGColor
		];
	} else {
		self.coverGradientView.gradientColors = @[
				(id) [UIColor colorWithWhite:0.0 alpha:0.0].CGColor,
				(id) [UIColor colorWithWhite:0.0 alpha:0.0].CGColor,
				(id) [UIColor colorWithWhite:0.0 alpha:0.17].CGColor,
				(id) [UIColor colorWithWhite:0.0 alpha:0.17].CGColor
		];
	}
	[self.coverGradientView setNeedsDisplay];
}

- (void)setupRightBarButtonItems {
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonAction)];
    editButton.tintColor = [UIColor whiteColor];
    UIBarButtonItem *helpButton = [self instructionHelpBarButton];
    helpButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItems = @[editButton, helpButton];
}

- (void)editButtonAction {
	A3HolidaysEditViewController *viewController = [[A3HolidaysEditViewController alloc] initWithStyle:UITableViewStyleGrouped];
	viewController.delegate = self;
	viewController.pageViewController = self;
	viewController.countryCode = _countries[_pageControl.currentPage];
    
    if (IS_IPAD) {
        A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController_iPad];
        [rootViewController presentCenterViewController:[[A3NavigationController alloc] initWithRootViewController:viewController]
                                     fromViewController:self
                                         withCompletion:^{
                                         }];
    }
    else {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        [self presentViewController:navigationController animated:YES completion:nil];

    }
}

- (NSArray *)countries {
	if (!_countries) {
		_countries = [HolidayData userSelectedCountries];
	}
	return _countries;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (NSUInteger)currentPage {
	A3HolidaysPageContentViewController *contentViewController = (A3HolidaysPageContentViewController *)_pageViewController.viewControllers[0];
	return [self.countries indexOfObject:contentViewController.countryCode];
}

- (void)prepareViewControllerAtPage:(NSUInteger)page {
	if ([_countries count] > page) {
		A3HolidaysPageContentViewController *viewController = [[A3HolidaysPageContentViewController alloc] initWithCountryCode:_countries[page]];
		viewController.pageViewController = self;
		[viewController view];
		[_viewControllerCache setObject:viewController forKey:_countries[page]];
	}
}

- (A3HolidaysPageContentViewController *)contentViewControllerAtPage:(NSUInteger)page {
	if (page >= [_countries count]) {
		page = [_countries count] - 1;
	}
	A3HolidaysPageContentViewController *viewController;
	viewController = _viewControllerCache[_countries[page]];
	if (!viewController) {
		viewController = [[A3HolidaysPageContentViewController alloc] initWithCountryCode:_countries[page]];
		[viewController view];
		viewController.pageViewController = self;
		[_viewControllerCache setObject:viewController forKey:_countries[page]];
	} else {
		FNLOG(@"Cache hit for %@, %lu", _countries[page], (unsigned long)page);
	}

	return viewController;
}

- (A3HolidaysPageContentViewController *)currentContentViewController {
	return _pageViewController.viewControllers[0];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
	NSUInteger page = [self currentPage];
	if (page == 0) {
		return nil;
	}
	return [self contentViewControllerAtPage:page - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
	NSUInteger page = [self currentPage];
	if (page == [_countries count] - 1) {
		return nil;
	}

	[self prepareViewControllerAtPage:page + 2];
	return [self contentViewControllerAtPage:page + 1];
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {

}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
	_lastPageIndex = _currentPageIndex;
	_currentPageIndex = [self currentPage];
	_pageControl.currentPage = _currentPageIndex;
	[self updatePhotoLabelText];

	if (_lastPageIndex != NSNotFound) {
		A3HolidaysPageContentViewController *lastViewController = [self contentViewControllerAtPage:_lastPageIndex];
		[lastViewController startDownloadWallpaperFromFlickr];
	}
}

- (BOOL)usesFullScreenInLandscape {
	return YES;
}

- (BOOL)hidesNavigationBar {
	return YES;
}

- (void)editViewController:(UIViewController *)viewController willDismissViewControllerWithDataUpdated:(BOOL)updated {
	if (updated) {
		[[self currentContentViewController] reloadDataRedrawImage:YES];
		[self updatePhotoLabelText];
	}
}

- (UIView *)footerView {
	if (!_footerView) {
		_footerView = [UIView new];
		[self.view addSubview:_footerView];

		[_footerView makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.view.left);
			make.right.equalTo(self.view.right);
			make.bottom.equalTo(self.view.bottom);
			make.height.equalTo(@44);
		}];
	}
	return _footerView;
}

- (void)setupFooterView {
	UIView *line = [UIView new];
	line.backgroundColor = [UIColor clearColor];
	line.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.4].CGColor;
	line.layer.borderWidth = IS_RETINA ? 0.25 : 0.5;
	[self.view addSubview:line];

	[line makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left).with.offset(-1);
		make.right.equalTo(self.view.right);
		make.bottom.equalTo(self.view.bottom).with.offset(-44 + _verticalOffset);
		make.height.equalTo(@1);
	}];

	[self pageControl];

	[self photoLabel1];

	UIButton *listButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[listButton setImage:[[UIImage imageNamed:@"list"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	[listButton addTarget:self action:@selector(listButtonAction) forControlEvents:UIControlEventTouchUpInside];
	[listButton setTintColor:[UIColor colorWithWhite:1.0 alpha:0.6]];
	[self.view addSubview:listButton];

	CGFloat leading = IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28;
	[listButton makeConstraints:^(MASConstraintMaker *make) {
		make.width.equalTo(@44);
		make.height.equalTo(@44);
		make.right.equalTo(self.footerView.right).with.offset(-leading);
		make.centerY.equalTo(_footerView.centerY).with.offset(_verticalOffset);
	}];
}

- (FXPageControl *)pageControl {
	if (!_pageControl) {
		_pageControl = [FXPageControl new];
		_pageControl.backgroundColor = [UIColor clearColor];
		_pageControl.tintColor = [UIColor colorWithWhite:1.0 alpha:0.6];
		_pageControl.numberOfPages = [self.countries count];
		_pageControl.dotColor = [UIColor colorWithRed:77.0 / 255.0 green:77.0 / 255.0 blue:77.0 / 255.0 alpha:1.0];
		_pageControl.selectedDotColor = [UIColor whiteColor];
		_pageControl.delegate = self;
		[_pageControl addTarget:self action:@selector(pageControlValuedChanged:) forControlEvents:UIControlEventValueChanged];
		[self.footerView addSubview:_pageControl];

		CGSize size = [_pageControl sizeForNumberOfPages:_pageControl.numberOfPages];
		[_pageControl makeConstraints:^(MASConstraintMaker *make) {
			_pageControlWidth = make.width.equalTo(@(size.width));
			make.height.equalTo(@30);
			make.centerX.equalTo(_footerView.centerX);
			make.centerY.equalTo(_footerView.centerY).with.offset(_verticalOffset);
		}];

		[_pageControl setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
	}
	return _pageControl;
}

- (UILabel *)photoLabel1 {
	if (!_photoLabel1) {
		FNLOG();
		_photoLabel1 = [UILabel new];
		_photoLabel1.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:11];
		_photoLabel1.textColor = [UIColor colorWithWhite:1.0 alpha:0.6];
		_photoLabel1.userInteractionEnabled = YES;
		[self.footerView addSubview:_photoLabel1];

		CGFloat leading = IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28;
		[_photoLabel1 makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(_footerView.left).with.offset(leading);
			make.right.lessThanOrEqualTo(self.pageControl.left).with.offset(-5);
			make.centerY.equalTo(_footerView.centerY).with.offset(-7 + _verticalOffset);
		}];

		[_photoLabel1 setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];

		UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openURL)];
		[_photoLabel1 addGestureRecognizer:tapGestureRecognizer1];

		_photoLabel2 = [UILabel new];
		_photoLabel2.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:11];
		_photoLabel2.textColor = [UIColor colorWithWhite:1.0 alpha:0.6];
		_photoLabel2.text = NSLocalizedString(@"on flickr", @"on flickr");
		_photoLabel2.userInteractionEnabled = YES;
		[_footerView addSubview:_photoLabel2];

		[_photoLabel2 makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(_footerView.left).with.offset(leading);
			make.right.lessThanOrEqualTo(_pageControl.left).with.offset(-5);
			make.centerY.equalTo(_footerView.centerY).with.offset(7 + _verticalOffset);
		}];
		[_photoLabel2 setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];

		UITapGestureRecognizer *tapGestureRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openURL)];
		[_photoLabel2 addGestureRecognizer:tapGestureRecognizer2];

		[_photoLabel1 setHidden:YES];
		[_photoLabel2 setHidden:YES];
	}
	return _photoLabel1;
}

- (void)pageControlValuedChanged:(FXPageControl *)pageControl {
	A3HolidaysPageContentViewController *contentViewController = _pageViewController.viewControllers[0];
	NSInteger oldPage = [self.countries indexOfObject:contentViewController.countryCode];

	if (oldPage != pageControl.currentPage) {
		[self jumpToPage:pageControl.currentPage direction:oldPage < pageControl.currentPage ?
				UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse
				animated:YES];
	}
}

- (void)jumpToPage:(NSUInteger)page direction:(UIPageViewControllerNavigationDirection)direction animated:(BOOL)animated {
	[_pageViewController setViewControllers:@[[self contentViewControllerAtPage:page]] direction:direction animated:animated completion:NULL];
	[self updatePhotoLabelText];
}

- (UIImage *)pageControl:(FXPageControl *)pageControl imageForDotAtIndex:(NSInteger)index1 {
	if (index1 == 0) {
		[SFKImage setDefaultFont:[UIFont fontWithName:@"appbox" size:10]];
		[SFKImage setDefaultColor:[UIColor colorWithWhite:1.0 alpha:0.2]];
		return [SFKImage imageNamed:@"k"];
	} else {
		UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,0,6,6)];
		view.layer.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2].CGColor;
		view.layer.cornerRadius = 3;
		view.opaque = NO;
		return [view imageByRenderingView];
	}
	return nil;
}

- (UIImage *)pageControl:(FXPageControl *)pageControl selectedImageForDotAtIndex:(NSInteger)index1 {
	if (index1 == 0) {
		[SFKImage setDefaultFont:[UIFont fontWithName:@"appbox" size:10]];
		[SFKImage setDefaultColor:[UIColor colorWithWhite:1.0 alpha:0.6]];

		return [SFKImage imageNamed:@"k"];
	} else {
		UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,0,6,6)];
		view.layer.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6].CGColor;
		view.layer.cornerRadius = 3;
		view.opaque = NO;
		return [view imageByRenderingView];
	}
	return nil;
}

extern NSString *const kA3HolidayScreenImageOwner;		// USE key + country code
extern NSString *const kA3HolidayScreenImageURL;		// USE key + country code

- (void)updatePhotoLabelText {
	NSString *license = [[A3UserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@", kA3HolidayScreenImageLicense, self.countryCode]];
	NSString *owner = [[A3UserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@", kA3HolidayScreenImageOwner, self.countryCode]];

	if ([owner length]) {
		NSMutableAttributedString *licenseString;
		if ([license isEqualToString:@"cc"]) {
			licenseString = [[NSMutableAttributedString alloc] initWithString:@"a" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"appbox" size:10],NSForegroundColorAttributeName:[UIColor colorWithWhite:1.0 alpha:0.6]}];
		} else {
			licenseString = [[NSMutableAttributedString alloc] initWithString:@"©" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Medium" size:12],NSForegroundColorAttributeName:[UIColor colorWithWhite:1.0 alpha:0.6]}];
		}
		NSAttributedString *text = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@" by %@", @" by %@"), owner] attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Medium" size:11], NSForegroundColorAttributeName:[UIColor colorWithWhite:1.0 alpha:0.6]}];
		[licenseString appendAttributedString:text];

		[self.photoLabel1 setHidden:NO];
		[self.photoLabel2 setHidden:NO];
		self.photoLabel1.attributedText = licenseString;
		self.photoLabel2.text = NSLocalizedString(@"on flickr", @"on flickr");
	} else {
		[self.photoLabel1 setHidden:YES];
		[self.photoLabel2 setHidden:YES];
		self.photoLabel1.text = @"";
		self.photoLabel2.text = @"";
	}
}

/*! countryCode for current page
 * \returns
 */
- (NSString *)countryCode {
	A3HolidaysPageContentViewController *contentViewController = _pageViewController.viewControllers[0];
	return contentViewController.countryCode;
}

- (void)openURL {
	NSString *urlString = [[A3UserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@", kA3HolidayScreenImageURL, self.countryCode]];
	if ([urlString length]) {
		NSURL *url = [NSURL URLWithString:urlString];
		UIApplication *application = [UIApplication sharedApplication];
		if (url && [application canOpenURL:url]) {
			[application openURL:url];
		}
	}
}

- (void)listButtonAction {
	A3HolidaysCountryViewController *viewController = [[A3HolidaysCountryViewController alloc] initWithNibName:nil bundle:nil];
	viewController.pageViewController = self;
	viewController.delegate = self;

	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)viewController:(UIViewController *)viewController didFinishPickingCountry:(NSString *)countryCode dataChanged:(BOOL)dataChanged {
	_countries = nil;
	_pageControl.numberOfPages = [self.countries count];

	NSInteger page = [self.countries indexOfObject:countryCode];
	[self jumpToPage:page direction:UIPageViewControllerNavigationDirectionForward animated:NO ];
	_pageControl.currentPage = page;

	dispatch_async(dispatch_get_main_queue(), ^{
		NSArray *allKeys = [_viewControllerCache allKeys];
		for (NSString *key in allKeys) {
			if (![self.countries containsObject:key]) {
				[_viewControllerCache removeObjectForKey:key];
			}
		}
	});
}

- (UIInterfaceOrientationMask)pageViewControllerSupportedInterfaceOrientations:(UIPageViewController *)pageViewController {
	if (IS_IPHONE) {
		return UIInterfaceOrientationMaskPortrait;
	}
	return UIInterfaceOrientationMaskAll;
}

- (NSDateFormatter *)dateFormatter {
	if (!_dateFormatter) {
		_dateFormatter = [[NSDateFormatter alloc] init];
	}
	return _dateFormatter;
}

- (void)prepareDateFormat {
	[self.dateFormatter setDateStyle:NSDateFormatterFullStyle];
	_dateFormat = [self.dateFormatter formatStringByRemovingYearComponent:_dateFormatter.dateFormat];
	if (IS_IPHONE) {
		_dateFormat = [_dateFormat stringByReplacingOccurrencesOfString:@"MMMM" withString:@"MMM"];
		_dateFormat = [_dateFormat stringByReplacingOccurrencesOfString:@"EEEE" withString:@"EEE"];
	}
}

- (NSString *)stringFromDate:(NSDate *)date {
	[self.dateFormatter setDateFormat:_dateFormat];
	return [_dateFormatter stringFromDate:date];
}

- (NSString *)lunarStringFromDate:(NSDate *)date isKorean:(BOOL)isKorean {
	NSDateComponents *dateComponents = [[A3AppDelegate instance].calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:date];
	NSDateComponents *lunarComponents = [NSDate lunarCalcWithComponents:dateComponents
													   gregorianToLunar:YES
															  leapMonth:NO
																 korean:isKorean
														resultLeapMonth:NULL];
	[self.dateFormatter setDateFormat:_dateFormat];
	return [_dateFormatter stringFromDateComponents:lunarComponents];
}

@end
