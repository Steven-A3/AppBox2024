//
//  A3HolidaysViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/22/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3HolidaysViewController.h"
#import "UIViewController+navigation.h"
#import "SFKImage.h"
#import "A3UIDevice.h"
#import "common.h"
#import "HolidayData.h"
#import "HolidayData+Country.h"
#import "A3HolidaysCell.h"
#import "FXPageControl.h"
#import "NSDate+daysleft.h"
#import "A3HolidaysCountryViewController.h"
#import "A3HolidaysEditViewController.h"
#import "A3GradientView.h"
#import "UIView+Screenshot.h"
#import "NSDate-Utilities.h"
#import "FXLabel.h"
#import "UIViewController+A3AppCategory.h"
#import "A3FSegmentedControl.h"

static NSString *const kHolidayViewComponentBorderView = @"borderView";		// bounds equals to self.view.bounds
static NSString *const kHolidayViewComponentImageView = @"imageView";		// bounds equals to alledgeInsets -50
static NSString *const kHolidayViewComponentTableView = @"tableView";		// bounds eqauls to bottom inset 54 from self.view.bounds

typedef NS_ENUM(NSInteger, HolidaysTableHeaderViewComponent) {
	HolidaysHeaderViewSegmentedControl = 1000,
	HolidaysHeaderViewYearLabel,
	HolidaysHeaderViewNameLabel,
	HolidaysHeaderViewDaysLeftLabel,
	HolidaysHeaderViewCountryLabel
};

@interface A3HolidaysViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, CLLocationManagerDelegate, FXPageControlDelegate, A3HolidaysCountryViewControllerDelegate, A3HolidaysEditViewControllerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *viewComponents;
@property (nonatomic, strong) UILabel *photoLabel1;
@property (nonatomic, strong) UILabel *photoLabel2;
@property (nonatomic, strong) FXPageControl *pageControl;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) NSArray *countries;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSString *countryCodeOfCurrentLocation;
@property (nonatomic, strong) NSMutableArray *holidayDataArray;
@property (nonatomic, strong) MASConstraint *pageControlWidth;
@property (nonatomic, strong) A3GradientView *topGradientView;
@property (nonatomic, strong) NSTimer *dayChangedTimer;

@end

@implementation A3HolidaysViewController {
	NSUInteger _indexForImageUpdatingPage;
	BOOL	_stopUpdateImage;
	NSInteger _thisYear;
	UIInterfaceOrientation _previousOrientation;
	CGFloat _lastKnownOffset;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	_thisYear = [HolidayData thisYear];
	_indexForImageUpdatingPage = 0;

	self.automaticallyAdjustsScrollViewInsets = NO;
	UIImage *image = [[UIImage alloc] init];
	[self.navigationController.navigationBar setBackgroundImage:image forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
	[self.navigationController.navigationBar setShadowImage:image];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	[self.navigationController setNavigationBarHidden:YES];

	[self loadContents];

	[self leftBarButtonAppsButton];
	self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
	[self setupRightBarButtonItems];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];

	if (self.isMovingToParentViewController) {
		A3FlickrImageView *imageView = self.viewComponents[0][kHolidayViewComponentImageView];
		[imageView displayImageWithCountryCode:self.countries[0] orientation:CURRENT_ORIENTATION];
	} else {
		if (_previousOrientation != CURRENT_ORIENTATION) {
			[self reloadTableHeaderViews:CURRENT_ORIENTATION];
			[self reloadImages:CURRENT_ORIENTATION];
			[self jumpToPage:self.pageControl.currentPage];
		}
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if (self.isMovingToParentViewController) {
		[self startAskLocation];

		[self reloadDataForCurrentPageWithYear:_thisYear];

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

		[self registerContentSizeCategoryDidChangeNotification];

		double delayInSeconds = 1.0;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			[self displayImagesInImageView];

			[self startUpdateImage];
		});
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if (self.isMovingFromParentViewController) {
		FNLOG();

		// Remove keyValue observer
		for (NSInteger index = 0; index < [_viewComponents count]; index++) {
			NSDictionary *component = _viewComponents[index];
			A3FlickrImageView *imageView = component[kHolidayViewComponentImageView];
			[imageView setScrollView:nil];
		}
		[_dayChangedTimer invalidate];
		_dayChangedTimer = nil;

		[self removeObserver];
	} else {
		_previousOrientation = CURRENT_ORIENTATION;
		if (!self.navigationController.navigationBarHidden) {
			[self tapOnScrollView];
		}
	}
}

- (void)contentSizeDidChange:(NSNotification *)notification {
	[self refreshViewContentsWithResetImage:NO ];
}

- (void)dayChanged:(NSTimer *)timer {
	[_dayChangedTimer invalidate];
	_dayChangedTimer = nil;

	[self refreshViewContentsWithResetImage:NO ];
}

- (void)displayImagesInImageView {
	[self.viewComponents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		A3FlickrImageView *imageView = obj[kHolidayViewComponentImageView];
		[imageView displayImageWithCountryCode:self.countries[idx] orientation:CURRENT_ORIENTATION];
	}];

	[self setPhotoLabelText];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Right bar button items
- (void)setupRightBarButtonItems {
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonAction)];
	self.navigationItem.rightBarButtonItem = editButton;
	self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void)editButtonAction {
	A3HolidaysEditViewController *viewController = [[A3HolidaysEditViewController alloc] initWithStyle:UITableViewStyleGrouped];
	viewController.delegate = self;
	viewController.countryCode = _countries[_pageControl.currentPage];

	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	[self presentViewController:navigationController animated:YES completion:nil];
}

// Edit View dismissed
- (void)viewController:(UIViewController *)viewController willDismissViewControllerWithDataUpdated:(BOOL)updated {
	if (updated) {
		[self reloadEverything];
	}
}

- (void)reloadEverything {
	_holidayDataArray = nil;
	NSUInteger currentPage = (NSUInteger) _pageControl.currentPage;
	UITableView *tableView = _viewComponents[currentPage][kHolidayViewComponentTableView];
	[self updateTableHeaderView:tableView.tableHeaderView atPage:currentPage];
	tableView.tableFooterView = [self tableFooterViewAtPage:currentPage tableView:tableView];
	[tableView reloadData];
	A3FlickrImageView *imageView = _viewComponents[currentPage][kHolidayViewComponentImageView];
	[imageView displayImageWithCountryCode:_countries[currentPage] orientation:CURRENT_ORIENTATION];
	[self setPhotoLabelText];
}

#pragma mark - Settings

- (NSArray *)countries {
	if (!_countries) {
		_countries = [HolidayData userSelectedCountries];
	}
	return _countries;
}

- (void)startAskLocation {
	_locationManager = [[CLLocationManager alloc] init];
	[_locationManager setDesiredAccuracy:kCLLocationAccuracyKilometer];
	[_locationManager setDelegate:self];
	[_locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	[manager stopUpdatingLocation];

	CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
	[geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placeMarks, NSError *error) {
		for (CLPlacemark *placeMark in placeMarks) {
//			FNLOG(@"%@", [placeMarks description]);
//			FNLOG(@"address Dictionary: %@", placeMark.addressDictionary);
//			FNLOG(@"Administrative Area: %@", placeMark.administrativeArea);
//			FNLOG(@"areas of Interest: %@", placeMark.areasOfInterest);
//			FNLOG(@"locality: %@", placeMark.locality);
//			FNLOG(@"name: %@", placeMark.name);
//			FNLOG(@"subLocality: %@", placeMark.subLocality);

			self.countryCodeOfCurrentLocation = [placeMark.addressDictionary[@"CountryCode"] lowercaseString];
            FNLOG(@"%@", _countryCodeOfCurrentLocation);
		}
        
        if ([self.countryCodeOfCurrentLocation length]) {
            if (![self.countries[0] isEqualToString:_countryCodeOfCurrentLocation]) {
                NSMutableArray *tempArray = [_countries mutableCopy];
                if ([tempArray containsObject:_countryCodeOfCurrentLocation]) {
                    NSInteger idx = [tempArray indexOfObject:_countryCodeOfCurrentLocation];
                    [tempArray removeObjectAtIndex:idx];
                }
                
                [tempArray insertObject:_countryCodeOfCurrentLocation atIndex:0];
                _countries = tempArray;
                
                [HolidayData setUserSelectedCountries:_countries];
                
                [self updatePages];
                [self refreshViewContentsWithResetImage:YES ];
            }
        }
        _stopUpdateImage = NO;
        [self startUpdateImage];

	}];
}

- (void)startUpdateImage {
	if (_stopUpdateImage) {
		return;
	}
	FNLOG(@"%d, %d", _indexForImageUpdatingPage, [self.viewComponents count]);
	if (_indexForImageUpdatingPage < [self.viewComponents count]) {
		dispatch_async(dispatch_get_main_queue(), ^{
			do {
				if (_indexForImageUpdatingPage >= [_viewComponents count])
					return;

				A3FlickrImageView *imageView = self.viewComponents[_indexForImageUpdatingPage][kHolidayViewComponentImageView];
				_indexForImageUpdatingPage++;

				if ([imageView startUpdate]) {
					break;
				}
			} while (1);
		});
	}
}

- (void)loadContents {
	self.view.backgroundColor = [UIColor blackColor];
	[self setupScrollView];
	[self setupFooterView];

	[self.view layoutIfNeeded];
}

#pragma mark - Layout

- (BOOL)useFullScreenInLandscape {
	return YES;
}

- (void)viewWillLayoutSubviews{
	[super viewWillLayoutSubviews];

	CGSize size = [_pageControl sizeForNumberOfPages:_pageControl.numberOfPages];
	_pageControlWidth.offset(size.width);

	FNLOGRECT(self.navigationController.view.bounds);
	FNLOGRECT(self.view.bounds);

	_scrollView.contentSize = CGSizeMake(self.view.bounds.size.width * _pageControl.numberOfPages, self.view.bounds.size.height);
	[self.viewComponents enumerateObjectsUsingBlock:^(NSDictionary *viewComponent, NSUInteger idx, BOOL *stop) {
		UIView *borderView = viewComponent[kHolidayViewComponentBorderView];
		[self setupBorderView:borderView atIndex:idx];
	}];
	FNLOG(@"contentSize %f", _scrollView.contentSize.width);
	FNLOG(@"contentOffset %f", _scrollView.contentOffset.x);
}

- (void)setupBorderView:(UIView *)borderView atIndex:(NSUInteger)idx {
	[borderView setFrame:CGRectMake(self.view.bounds.size.width * idx, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
	if (borderView.frame.origin.x == _scrollView.contentOffset.x) {
		[_scrollView bringSubviewToFront:borderView];
		borderView.clipsToBounds = NO;
	}
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

    FNLOG();
	[self reloadTableHeaderViews:toInterfaceOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

    FNLOG();
	[self reloadImages:toInterfaceOrientation];
	[self jumpToPage:_pageControl.currentPage];
}

- (void)reloadTableHeaderViews:(UIInterfaceOrientation)orientation {
	[_viewComponents enumerateObjectsUsingBlock:^(NSDictionary *component, NSUInteger idx, BOOL *stop) {
		UITableView *tableView = component[kHolidayViewComponentTableView];
		tableView.tableHeaderView = [self tableHeaderViewAtPage:idx interfaceOrientation:orientation];
		[tableView.tableHeaderView layoutIfNeeded];
	}];
}

- (void)reloadImages:(UIInterfaceOrientation)orientation {
	[_viewComponents enumerateObjectsUsingBlock:^(NSDictionary *component, NSUInteger idx, BOOL *stop) {
		A3FlickrImageView *imageView = component[kHolidayViewComponentImageView];
		[imageView displayImageWithCountryCode:_countries[idx] orientation:orientation];
	}];
}

#pragma mark - Footer View / similar but white border color, clearColored background

- (void)setupFooterView {
	_footerView = [UIView new];
	[self.view addSubview:_footerView];

	[_footerView makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left);
		make.right.equalTo(self.view.right);
		make.bottom.equalTo(self.view.bottom);
		make.height.equalTo(@44);
	}];

	UIView *line = [UIView new];
	line.backgroundColor = [UIColor clearColor];
	line.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.4].CGColor;
	line.layer.borderWidth = IS_RETINA ? 0.25 : 0.5;
	[self.view addSubview:line];

	[line makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left).with.offset(-1);
		make.right.equalTo(self.view.right);
		make.bottom.equalTo(self.view.bottom).with.offset(-44);
		make.height.equalTo(@1);
	}];

	[self pageControl];

	[self photoLabel1];

	UIButton *listButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[listButton setImage:[[UIImage imageNamed:@"list"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	[listButton addTarget:self action:@selector(listButtonAction) forControlEvents:UIControlEventTouchUpInside];
	[listButton setTintColor:[UIColor colorWithWhite:1.0 alpha:0.6]];
	[self.view addSubview:listButton];

	[listButton makeConstraints:^(MASConstraintMaker *make) {
		make.width.equalTo(@44);
		make.height.equalTo(@44);
		make.right.equalTo(_footerView.right).with.offset(IS_IPAD ? -28 : -15);
		make.centerY.equalTo(_footerView.centerY);
	}];
}

- (FXPageControl *)pageControl {
	if (!_pageControl) {
		_pageControl = [FXPageControl new];
		_pageControl.backgroundColor = [UIColor clearColor];
		_pageControl.tintColor = [UIColor colorWithWhite:1.0 alpha:0.6];
		_pageControl.numberOfPages = [self.viewComponents count];
		_pageControl.dotColor = [UIColor colorWithRed:77.0 / 255.0 green:77.0 / 255.0 blue:77.0 / 255.0 alpha:1.0];
		_pageControl.selectedDotColor = [UIColor whiteColor];
		_pageControl.delegate = self;
		[_pageControl addTarget:self action:@selector(pageControlValuedChanged:) forControlEvents:UIControlEventValueChanged];
		[_footerView addSubview:_pageControl];

		CGSize size = [_pageControl sizeForNumberOfPages:_pageControl.numberOfPages];
		[_pageControl makeConstraints:^(MASConstraintMaker *make) {
			_pageControlWidth = make.width.equalTo(@(size.width));
			make.height.equalTo(@30);
			make.centerX.equalTo(_footerView.centerX);
			make.centerY.equalTo(_footerView.centerY);
		}];

		[_pageControl setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
	}
	return _pageControl;
}

- (UILabel *)photoLabel1 {
	if (!_photoLabel1) {
		_photoLabel1 = [UILabel new];
		_photoLabel1.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
		_photoLabel1.textColor = [UIColor colorWithWhite:1.0 alpha:0.6];
		_photoLabel1.userInteractionEnabled = YES;
		[_footerView addSubview:_photoLabel1];

		[_photoLabel1 makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(_footerView.left).with.offset(IS_IPAD ? 28 : 15);
			make.right.lessThanOrEqualTo(_pageControl.left).with.offset(-5);
			make.centerY.equalTo(_footerView.centerY).with.offset(-7);
		}];

		[_photoLabel1 setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];

		UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openURL)];
		[_photoLabel1 addGestureRecognizer:tapGestureRecognizer1];

		_photoLabel2 = [UILabel new];
		_photoLabel2.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
		_photoLabel2.textColor = [UIColor colorWithWhite:1.0 alpha:0.6];
		_photoLabel2.text = @"on flickr";
		_photoLabel2.userInteractionEnabled = YES;
		[_footerView addSubview:_photoLabel2];

		[_photoLabel2 makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(_footerView.left).with.offset(IS_IPAD ? 28 : 15);
			make.right.lessThanOrEqualTo(_pageControl.left).with.offset(-5);
			make.centerY.equalTo(_footerView.centerY).with.offset(7);
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
	[self jumpToPage:pageControl.currentPage];
}

- (void)jumpToPage:(NSInteger)page {
	CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
	CGFloat width = screenBounds.size.width;
    _scrollView.contentSize = CGSizeMake(width * _pageControl.numberOfPages, screenBounds.size.height);
	[_scrollView setContentOffset:CGPointMake(width * page, 0) animated:YES];
	self.pageControl.currentPage = page;
	[self setFocusToPage:page];
}

- (UIImage *)pageControl:(FXPageControl *)pageControl imageForDotAtIndex:(NSInteger)index1 {
	if (index1 == 0) {
		[SFKImage setDefaultFont:[UIFont fontWithName:@"appbox" size:10]];
		[SFKImage setDefaultColor:[UIColor colorWithWhite:1.0 alpha:0.2]];
		return [SFKImage imageNamed:@"p"];
	} else {
		UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,0,6,6)];
		view.layer.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2].CGColor;
		view.layer.cornerRadius = 3;
		return [view imageByRenderingView];
    }
	return nil;
}

- (UIImage *)pageControl:(FXPageControl *)pageControl selectedImageForDotAtIndex:(NSInteger)index1 {
	if (index1 == 0) {
		[SFKImage setDefaultFont:[UIFont fontWithName:@"appbox" size:10]];
		[SFKImage setDefaultColor:[UIColor colorWithWhite:1.0 alpha:0.6]];

		return [SFKImage imageNamed:@"p"];
	} else {
		UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,0,6,6)];
		view.layer.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6].CGColor;
		view.layer.cornerRadius = 3;
		return [view imageByRenderingView];
    }
	return nil;
}

- (void)setPhotoLabelText {
	A3FlickrImageView *view = _viewComponents[_pageControl.currentPage][kHolidayViewComponentImageView];
	NSString *owner = view.ownerString;
	if ([owner length]) {
		[self.photoLabel1 setHidden:NO];
		[self.photoLabel2 setHidden:NO];
		self.photoLabel1.text = [NSString stringWithFormat:@"by %@", view.ownerString];
		self.photoLabel2.text = @"on flickr";
	} else {
		[self.photoLabel1 setHidden:YES];
		[self.photoLabel2 setHidden:YES];
		self.photoLabel1.text = @"";
		self.photoLabel2.text = @"";
	}
}

- (void)flickrImageViewImageUpdated:(A3FlickrImageView *)view {
	if (view == _viewComponents[_pageControl.currentPage][kHolidayViewComponentImageView]) {
		[self setPhotoLabelText];
	}

	[self startUpdateImage];
}

- (void)openURL {
	A3FlickrImageView *view = _viewComponents[_pageControl.currentPage][kHolidayViewComponentImageView];

	NSURL *url = [NSURL URLWithString:view.urlString];
	UIApplication *application = [UIApplication sharedApplication];
	if (url && [application canOpenURL:url]) {
		[application openURL:url];
	}
}

- (void)listButtonAction {
	A3HolidaysCountryViewController *viewController = [[A3HolidaysCountryViewController alloc] initWithNibName:nil bundle:nil];
	viewController.delegate = self;

	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)viewController:(UIViewController *)viewController didFinishPickingCountry:(NSString *)countryCode dataChanged:(BOOL)dataChanged {
	if (dataChanged) {
        _countries = nil;
		[self updatePages];

		[self refreshViewContentsWithResetImage:YES ];

		_stopUpdateImage = NO;
		[self startUpdateImage];
	}

	NSInteger page = [self.countries indexOfObject:countryCode];
    [self jumpToPage:page];
}

- (void)updatePages {
	_stopUpdateImage = YES;
	_indexForImageUpdatingPage = 0;

	_countries = nil;
	_holidayDataArray = nil;

	if ([self.countries count] != [_viewComponents count]) {
		if ([_countries count] > [_viewComponents count]) {
			// Add pages
			for (NSInteger index = [_viewComponents count]; index < [_countries count]; index++) {
				[self addNewPage:index];
			}
		} else {
			for (NSInteger index = [_countries count]; index < [_viewComponents count]; index++) {
				NSDictionary *component = _viewComponents[index];
				A3FlickrImageView *imageView = component[kHolidayViewComponentImageView];
				[imageView setScrollView:nil];
				UIView *borderView = component[kHolidayViewComponentBorderView];
				[borderView removeFromSuperview];
			}
			NSUInteger numToDelete = [_viewComponents count] - [_countries count];
			[_viewComponents removeObjectsInRange:NSMakeRange([_countries count], numToDelete)];
		}
		_pageControl.numberOfPages = [_countries count];
	}
}

- (void)refreshViewContentsWithResetImage:(BOOL)resetImage {
	_scrollView.contentSize = CGSizeMake(self.view.bounds.size.width * _pageControl.numberOfPages, self.view.bounds.size.height);
	[_viewComponents enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        UIView *borderView = obj[kHolidayViewComponentBorderView];
		[self setupBorderView:borderView atIndex:idx];
        [borderView layoutIfNeeded];

		if (resetImage) {
			double delayInSeconds = 0.1;
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				A3FlickrImageView *imageView = obj[kHolidayViewComponentImageView];
				[imageView displayImageWithCountryCode:_countries[idx] orientation:CURRENT_ORIENTATION];

				double delayInSeconds2 = 0.2;
				dispatch_time_t popTime2 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds2 * NSEC_PER_SEC));
				dispatch_after(popTime2, dispatch_get_main_queue(), ^(void){
					UITableView *tableView = obj[kHolidayViewComponentTableView];
					[tableView setContentOffset:tableView.contentOffset];
				});
			});
		}

		UITableView *tableView = obj[kHolidayViewComponentTableView];
		[self updateTableHeaderView:tableView.tableHeaderView atPage:idx];
		tableView.tableFooterView = [self tableFooterViewAtPage:_pageControl.currentPage tableView:tableView];
		[tableView reloadData];
		FNLOG(@"%d, %d", idx, tableView.tag);
	}];
}

#pragma mark - Setup ScrollView

- (void)setupScrollView {
	_scrollView = [UIScrollView new];
	_scrollView.backgroundColor = [UIColor clearColor];
	_scrollView.pagingEnabled = YES;
	_scrollView.delegate = self;
	_scrollView.directionalLockEnabled = YES;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.showsVerticalScrollIndicator = NO;
	[self.view addSubview:_scrollView];

	[_scrollView makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.view);
	}];

	[self setupScrollViewContents];

	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnScrollView)];
	[_scrollView addGestureRecognizer:gestureRecognizer];

	_topGradientView = [A3GradientView new];
	_topGradientView.gradientColors = @[(id)[UIColor colorWithWhite:0.0 alpha:0.5].CGColor, (id)[UIColor colorWithWhite:0.0 alpha:0.0].CGColor];
	[self.view insertSubview:_topGradientView aboveSubview:_scrollView];

	[_topGradientView makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(self.view.top);
		make.left.equalTo(self.view.left);
		make.right.equalTo(self.view.right);
		make.height.equalTo(@64);
	}];

	[_topGradientView setHidden:YES];
}

- (void)tapOnScrollView {
	FNLOG();

	BOOL navigationBarHidden = self.navigationController.navigationBarHidden;
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	[[UIApplication sharedApplication] setStatusBarHidden:!navigationBarHidden];
	[self.navigationController setNavigationBarHidden:!navigationBarHidden];
	[_topGradientView setHidden:!navigationBarHidden];

	if (navigationBarHidden) {
		UITableView *tableView = _viewComponents[_pageControl.currentPage][kHolidayViewComponentTableView];

		[self scrollToRightPosition:tableView enforceToMiddle:NO animated:YES];
	}
}

- (void)setupScrollViewContents {
	_viewComponents = [NSMutableArray new];

	for (NSUInteger page = 0;page < [self.countries count]; page++) {
		[self addNewPage:page];
	}
}

- (void)addNewPage:(NSInteger)page {
	CGFloat viewWidth = self.view.bounds.size.width;
	CGFloat viewHeight = self.view.bounds.size.height;
	CGFloat interpolationFactor = 10;

	// Border view
	UIView *borderView = [UIView new];
	borderView.frame = CGRectMake(page * viewWidth, 0, viewWidth, viewHeight);
	borderView.tag = page;
	borderView.backgroundColor = [UIColor clearColor];
	borderView.clipsToBounds = YES;
	[_scrollView addSubview:borderView];

	A3FlickrImageView *imageView = [A3FlickrImageView new];
	imageView.delegate = self;
	imageView.tag = page;
	imageView.countryCode = self.countries[page];
	[borderView addSubview:imageView];

	[imageView makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(borderView).insets(UIEdgeInsetsMake(-interpolationFactor, -interpolationFactor, -interpolationFactor, -interpolationFactor));
	}];

	A3GradientView *gradientView = [A3GradientView new];
	gradientView.gradientColors = @[
			(id)[UIColor colorWithWhite:0.0 alpha:0.0].CGColor,
			(id)[UIColor colorWithWhite:0.0 alpha:1.0].CGColor
	];

	[borderView addSubview:gradientView];

	[gradientView makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(borderView.bottom).with.offset(-150);
		make.left.equalTo(borderView.left);
		make.right.equalTo(borderView.right);
		make.bottom.equalTo(borderView.bottom);
	}];

	UIInterpolatingMotionEffect *interpolationHorizontal = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
	interpolationHorizontal.minimumRelativeValue = @(-interpolationFactor);
	interpolationHorizontal.maximumRelativeValue = @(interpolationFactor);

	UIInterpolatingMotionEffect *interpolationVertical = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
	interpolationVertical.minimumRelativeValue = @(-interpolationFactor);
	interpolationVertical.maximumRelativeValue = @(interpolationFactor);

	[imageView addMotionEffect:interpolationHorizontal];
	[imageView addMotionEffect:interpolationVertical];

	UITableView *tableView = [self tableViewAtPage:page];
	tableView.tag = page;
	[borderView addSubview:tableView];

	[tableView makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(borderView).insets(UIEdgeInsetsMake(0, 0, 54, 0));
	}];

	[self.viewComponents addObject:@{
			kHolidayViewComponentBorderView : borderView,
			kHolidayViewComponentImageView : imageView,
			kHolidayViewComponentTableView : tableView
	}];

	imageView.scrollView = tableView;
	imageView.glassColor = [UIColor colorWithWhite:0.0 alpha:0.9];
	imageView.isGlassEffectOn = YES;
}

#pragma mark - Setup TableView

static NSString *const CellIdentifier = @"holidaysCell";

- (UITableView *)tableViewAtPage:(NSUInteger)page {
	UIView *tableHeaderView = [self tableHeaderViewAtPage:page interfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation] ];

	UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.tag = page;
	tableView.dataSource = self;
	tableView.delegate = self;
	tableView.backgroundView = nil;
	tableView.backgroundColor = [UIColor clearColor];
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:[A3HolidaysCell class] forCellReuseIdentifier:CellIdentifier];
	tableView.tableHeaderView = tableHeaderView;
	tableView.showsVerticalScrollIndicator = NO;
	tableView.tableFooterView = [self tableFooterViewAtPage:page tableView:tableView];
	return tableView;
}

/*! This calculates footer height. Table header view must be set before this.
 * \param page
 * \param tableView
 * \returns tableFooterView
 */
- (UIView *)tableFooterViewAtPage:(NSUInteger)page tableView:(UITableView *)tableView {
	CGFloat tableRowsHeight = 0;
	for (NSUInteger index = 0; index < [self tableView:tableView numberOfRowsInSection:0]; index++) {
		tableRowsHeight += [self tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
	}
	CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
	screenBounds.size.height -= 54.0 + 252.0 + (IS_IPAD ? 62 : 0);

	CGFloat footerViewHeight = screenBounds.size.height - tableRowsHeight;
    FNLOG(@"%d page, %d, %f, %f", page, tableView.tag, footerViewHeight, screenBounds.size.height);
	if (footerViewHeight > 0) {
		UIView *tableFooterView = [UIView new];
		tableFooterView.frame = CGRectMake(0, 0, tableView.bounds.size.width, footerViewHeight);
		return tableFooterView;
	}
	return nil;
}

- (UIView *)tableHeaderViewAtPage:(NSUInteger)page interfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	UIView *headerView = [UIView new];

	CGRect screenBounds = [[UIScreen mainScreen] bounds];

	CGFloat viewHeight = UIInterfaceOrientationIsPortrait(interfaceOrientation) ? screenBounds.size.height : screenBounds.size.width;
	viewHeight += 97.0;
	viewHeight -= 54.0;
	if (IS_IPAD) {
		viewHeight += 62.0;
	}

	[headerView setFrame:CGRectMake(0, 0, UIInterfaceOrientationIsPortrait(interfaceOrientation) ? screenBounds.size.width : screenBounds.size.height, viewHeight)];

	UIView *bottomLine = [UIView new];
	bottomLine.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.7].CGColor;
	bottomLine.layer.borderWidth = IS_RETINA ? 0.25 : 0.5;
	[headerView addSubview:bottomLine];

	[bottomLine makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(headerView.left).with.offset(-1);
		make.right.equalTo(headerView.right);
		make.bottom.equalTo(headerView.bottom);
		make.height.equalTo(@1);
	}];

	A3FSegmentedControl *segmentedControl = [A3FSegmentedControl new];
	segmentedControl.tag = HolidaysHeaderViewSegmentedControl;
	[segmentedControl addTarget:self action:@selector(upcomingPastChanged:) forControlEvents:UIControlEventValueChanged];
	[headerView addSubview:segmentedControl];

	segmentedControl.selectedSegmentIndex = 0;

	[segmentedControl makeConstraints:^(MASConstraintMaker *make) {
		if (IS_IPHONE) {
			make.left.equalTo(headerView.left).with.offset(5);
			make.bottom.equalTo(headerView.bottom).with.offset(-6);
			make.width.equalTo(@192);
			make.height.equalTo(@30);
		} else {
			make.width.equalTo(@300);
			make.left.equalTo(headerView.left).with.offset(28);
			make.bottom.equalTo(headerView.bottom).with.offset(-6);
			make.height.equalTo(@30);
		}
	}];

	UIView *yearBorderView = [UIView new];
	yearBorderView.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.7].CGColor;
	yearBorderView.layer.borderWidth = IS_RETINA ? 1.0 : 0.5;
	yearBorderView.layer.cornerRadius = 4;
	[headerView addSubview:yearBorderView];

	[yearBorderView makeConstraints:^(MASConstraintMaker *make) {
		if (IS_IPHONE) {
			make.width.equalTo(@108);
			make.height.equalTo(@30);
			make.right.equalTo(headerView.right).with.offset(-5);
			make.bottom.equalTo(headerView.bottom).with.offset(-6);
		} else {
			make.width.equalTo(@150);
			make.height.equalTo(@30);
			make.right.equalTo(headerView.right).with.offset(-28);
			make.bottom.equalTo(headerView.bottom).with.offset(-6);
		}
	}];

	UIButton *prevYearButton = [UIButton buttonWithType:UIButtonTypeCustom];
	prevYearButton.frame = CGRectMake(0,0,40,40);
	[SFKImage setDefaultFont:[UIFont fontWithName:@"appbox" size:22]];
	[SFKImage setDefaultColor:[UIColor whiteColor]];
	UIImage *image = [SFKImage imageNamed:@"e"];
	[prevYearButton setImage:image forState:UIControlStateNormal];
	[prevYearButton addTarget:self action:@selector(prevYearButtonAction) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:prevYearButton];

	[prevYearButton makeConstraints:^(MASConstraintMaker *make) {
		make.width.equalTo(@40);
		make.height.equalTo(@40);
		make.centerY.equalTo(yearBorderView.centerY);
		make.centerX.equalTo(yearBorderView.centerX).with.offset(IS_IPHONE ? -33 : -45);
	}];

	UIButton *nextYearButton = [UIButton buttonWithType:UIButtonTypeCustom];
	image = [SFKImage imageNamed:@"f"];
	[nextYearButton setImage:image forState:UIControlStateNormal];
	[nextYearButton addTarget:self action:@selector(nextYearButtonAction) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:nextYearButton];

	[nextYearButton makeConstraints:^(MASConstraintMaker *make) {
		make.width.equalTo(@40);
		make.height.equalTo(@40);
		make.centerX.equalTo(yearBorderView.centerX).with.offset(IS_IPHONE ? 33 : 45);
		make.centerY.equalTo(yearBorderView.centerY);
	}];

	UILabel *yearLabel = [UILabel new];
	yearLabel.tag = HolidaysHeaderViewYearLabel;
	yearLabel.textColor = [UIColor whiteColor];
	yearLabel.textAlignment = NSTextAlignmentCenter;
	[yearBorderView addSubview:yearLabel];

	[yearLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(yearBorderView.centerX);
		make.centerY.equalTo(yearBorderView.centerY);
	}];

	FXLabel *nameLabel = [FXLabel new];
	nameLabel.tag = HolidaysHeaderViewNameLabel;
	nameLabel.textColor = [UIColor whiteColor];
	nameLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:26];
	nameLabel.textAlignment = NSTextAlignmentCenter;
	nameLabel.adjustsFontSizeToFitWidth = YES;
	nameLabel.minimumScaleFactor = 0.5;
	[self setupShadow:nameLabel];
	[headerView addSubview:nameLabel];

	[nameLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(headerView.centerX);
		make.width.equalTo(headerView).with.offset(IS_IPHONE ? -20 : -(28 * 2));
		make.bottom.equalTo(yearBorderView.top).with.offset(IS_IPHONE ? -62 : -124);
	}];

	FXLabel *daysLeftLabel = [FXLabel new];
	daysLeftLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-M3" size:17];
	daysLeftLabel.tag = HolidaysHeaderViewDaysLeftLabel;
	daysLeftLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.6];
	daysLeftLabel.textAlignment = NSTextAlignmentCenter;
	daysLeftLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.25];
	daysLeftLabel.shadowOffset = CGSizeMake(0, 2);
    daysLeftLabel.shadowBlur = 5;
	[self setupShadow:daysLeftLabel];
	[headerView addSubview:daysLeftLabel];

	[daysLeftLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(headerView.centerX);
		make.width.equalTo(headerView).with.offset(IS_IPHONE ? -20 : -(28 * 2));
		make.bottom.equalTo(nameLabel.top).with.offset(4);
	}];

	FXLabel *countryNameLabel = [FXLabel new];
	countryNameLabel.tag = HolidaysHeaderViewCountryLabel;
	countryNameLabel.textColor = [UIColor whiteColor];
	countryNameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:30];
	countryNameLabel.textAlignment = NSTextAlignmentCenter;
	countryNameLabel.adjustsFontSizeToFitWidth = YES;
	countryNameLabel.minimumScaleFactor = 0.5;
	[self setupShadow:countryNameLabel];
	[headerView addSubview:countryNameLabel];

	[countryNameLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(headerView.centerX);
		make.width.equalTo(headerView).with.offset(IS_IPHONE ? -20 : -(28 * 2));
		make.bottom.equalTo(daysLeftLabel.top).with.offset(-9);
	}];

	[self updateTableHeaderView:headerView atPage:page];

	return headerView;
}

- (void)setupShadow:(FXLabel *)label {
	label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.25];
	label.shadowOffset = CGSizeMake(0, 2);
	label.shadowBlur = 5;
}

- (void)updateTableHeaderView:(UIView *)tableHeaderView atPage:(NSUInteger)page {
	UILabel *yearLabel = (UILabel *) [tableHeaderView viewWithTag:HolidaysHeaderViewYearLabel];
	yearLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
	yearLabel.text = [NSString stringWithFormat:@"%d", _thisYear];

	UILabel *countryNameLabel = (UILabel *) [tableHeaderView viewWithTag:HolidaysHeaderViewCountryLabel];
	countryNameLabel.text = [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:self.countries[page]];

	NSUInteger myPosition = [self upcomingFirstHolidayInPage:page];
    
	if (myPosition != NSNotFound) {
		NSArray *holidaysInPage = self.holidayDataArray[page];
		NSDictionary *upcomingHoliday = holidaysInPage[myPosition];
        UILabel *nameLabel = (UILabel *)[tableHeaderView viewWithTag:HolidaysHeaderViewNameLabel];
		nameLabel.text = upcomingHoliday[kHolidayName];
        
        UILabel *daysLeftLabel = (UILabel *)[tableHeaderView viewWithTag:HolidaysHeaderViewDaysLeftLabel];
		daysLeftLabel.text = [upcomingHoliday[kHolidayDate] daysLeft];
        
        A3FSegmentedControl *segmentedControl = (A3FSegmentedControl *) [tableHeaderView viewWithTag:HolidaysHeaderViewSegmentedControl];
		segmentedControl.items = @[
				[NSString stringWithFormat:@"Upcoming %d", [holidaysInPage count] - myPosition],
				[NSString stringWithFormat:@"Past %d", myPosition]
		];
		FNLOG(@"%d + %d = %d : %d", [holidaysInPage count] - myPosition, myPosition, myPosition + [holidaysInPage count] - myPosition + 1, [holidaysInPage count]);
	}
}

- (UITableView *)tableViewAtCurrentPage {
	return _viewComponents[_pageControl.currentPage][kHolidayViewComponentTableView];
}

- (void)reloadDataForCurrentPageWithYear:(NSUInteger)year {
	NSUInteger currentPage = _pageControl.currentPage;
	NSArray *holidays = [self holidaysForCountryCode:_countries[currentPage] year:year];
	[_holidayDataArray replaceObjectAtIndex:currentPage withObject:holidays];

	UITableView *tableView = [self tableViewAtCurrentPage];
	A3FSegmentedControl *segmentedControl = (A3FSegmentedControl *) [tableView.tableHeaderView viewWithTag:HolidaysHeaderViewSegmentedControl];
	NSInteger upcoming, past;
	if (_thisYear == year) {
		NSUInteger myPosition = [self upcomingFirstHolidayInPage:currentPage];
		upcoming = [holidays count] - myPosition;
		past = myPosition;
		segmentedControl.states = @[@YES, @YES];
		[segmentedControl setSelectedSegmentIndex:0];
	} else if (year > _thisYear) {
		upcoming = [holidays count];
		past = 0;
		segmentedControl.states = @[@YES, @NO];
		[segmentedControl setSelectedSegmentIndex:0];
	} else {
		upcoming = 0;
		past = [holidays count];
		segmentedControl.states = @[@NO, @YES];
		[segmentedControl setSelectedSegmentIndex:1];
	}
	segmentedControl.items = @[
			[NSString stringWithFormat:@"Upcoming %d", upcoming],
			[NSString stringWithFormat:@"Past %d", past]
	];
	tableView.tableFooterView = [self tableFooterViewAtPage:currentPage tableView:tableView];
	[tableView reloadData];
}

- (void)prevYearButtonAction {
	UITableView *tableView = [self tableViewAtCurrentPage];

	UILabel *yearLabel = (UILabel *) [tableView.tableHeaderView viewWithTag:HolidaysHeaderViewYearLabel];
	NSUInteger year = [yearLabel.text integerValue] - 1;
	HolidayData *data = [[HolidayData alloc] init];
	NSArray *array = [data holidaysForCountry:_countries[_pageControl.currentPage] year:year fullSet:YES];
	if (array) {
		yearLabel.text = [NSString stringWithFormat:@"%d", year];
		[self reloadDataForCurrentPageWithYear:year];
		[self scrollToRightPosition:tableView enforceToMiddle:YES animated:NO];
	} else {
		[self alertNotAvailableYear:year];
	}
}

- (void)alertNotAvailableYear:(NSUInteger)year {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"Holidays for year %d is not available.", year] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
}

- (void)nextYearButtonAction {
	UITableView *tableView = [self tableViewAtCurrentPage];

	UILabel *yearLabel = (UILabel *) [tableView.tableHeaderView viewWithTag:HolidaysHeaderViewYearLabel];
	NSUInteger year = [yearLabel.text integerValue] + 1;
	HolidayData *data = [[HolidayData alloc] init];
	NSArray *array = [data holidaysForCountry:_countries[_pageControl.currentPage] year:year fullSet:YES];
	if (array) {
		yearLabel.text = [NSString stringWithFormat:@"%d", year];
		[self reloadDataForCurrentPageWithYear:year];
		[self scrollToRightPosition:tableView enforceToMiddle:YES animated:NO];
	} else {
		[self alertNotAvailableYear:year];
	}
}

- (void)upcomingPastChanged:(A3FSegmentedControl *)segmentedControl {
	UITableView *tableView = _viewComponents[_pageControl.currentPage][kHolidayViewComponentTableView];
	tableView.tableFooterView = [self tableFooterViewAtPage:_pageControl.currentPage tableView:tableView];
	[tableView reloadData];
    
	[self scrollToRightPosition:tableView enforceToMiddle:YES animated:NO ];
}

- (NSUInteger)upcomingFirstHolidayInPage:(NSUInteger)page {
	NSArray *holidaysInPage = self.holidayDataArray[page];
	return [holidaysInPage indexOfObjectPassingTest:^BOOL(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
		return [[NSDate date] compare:obj[kHolidayDate]] == NSOrderedAscending;
	}];
}

#pragma mark - Table view data source

- (NSInteger)yearForTableView:(UITableView *)tableView {
	UILabel *label = (UILabel *) [tableView.tableHeaderView viewWithTag:HolidaysHeaderViewYearLabel];
	return [label.text integerValue];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([HolidayData needToShowLunarDatesForCountryCode:_countries[tableView.tag]]) {
		return 62;
	}

	if (IS_IPHONE) {
		NSDictionary *holidayData = [self holidayDataForTableView:tableView row:indexPath.row];
		if ([self needDoubleLineCellWithData:holidayData]) {
			return 62;
		}
	}

	return 36;
}

- (BOOL)needDoubleLineCellWithData:(NSDictionary *)data {
	if (IS_IPHONE) {
		CGSize size = [data[kHolidayName] sizeWithAttributes:@{NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]}];

//		NSDateFormatter *df = [self dateFormatter];
//
//		NSString *dateString = [df stringFromDate:data[kHolidayDate]];
//		CGSize dateSize = [dateString sizeWithAttributes:@{NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]}];
//		CGFloat publicMarkSize = [data[kHolidayIsPublic] boolValue] ? 20 : 2;
		if (size.width > (320 - 113 - 15)) {
			return YES;
		}
	}
	return NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSArray *holidaysInPage = self.holidayDataArray[tableView.tag];

	if (_thisYear == [self yearForTableView:tableView]) {
		A3FSegmentedControl *segmentedControl = (A3FSegmentedControl *) [tableView.tableHeaderView viewWithTag:HolidaysHeaderViewSegmentedControl];
		NSUInteger upcomingIndex = [self upcomingFirstHolidayInPage:tableView.tag];
		// Return the number of rows in the section.
		return !segmentedControl.selectedSegmentIndex ? [holidaysInPage count] - upcomingIndex : upcomingIndex;
	} else {
		return [holidaysInPage count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;

	A3HolidaysCell *holidayCell;
	{
		holidayCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

		if (!holidayCell) {
			holidayCell = [[A3HolidaysCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
		}

		NSDictionary *cellData = [self holidayDataForTableView:tableView row:indexPath.row];

		BOOL longName = [self needDoubleLineCellWithData:cellData];
		BOOL showLunar = [HolidayData needToShowLunarDatesForCountryCode:_countries[tableView.tag]];

		A3HolidayCellType cellType;
		if (longName && showLunar) {
			cellType = A3HolidayCellTypeLunar2;
		} else if (!longName && showLunar) {
			cellType = A3HolidayCellTypeLunar1;
		} else if (longName && !showLunar) {
			cellType = A3HolidayCellTypeDoubleLine;
		} else {
			cellType = A3HolidayCellTypeSingleLine;
		}
		[holidayCell setCellType:cellType];

		if ([self yearForTableView:tableView] == _thisYear) {
			A3FSegmentedControl *segmentedControl = (A3FSegmentedControl *) [tableView.tableHeaderView viewWithTag:HolidaysHeaderViewSegmentedControl];
			if (!segmentedControl.selectedSegmentIndex && !indexPath.row) {
				holidayCell.titleLabel.textColor = self.view.tintColor;
				holidayCell.dateLabel.textColor = self.view.tintColor;
				holidayCell.lunarImageView.tintColor = self.view.tintColor;
				holidayCell.lunarDateLabel.textColor = self.view.tintColor;
				holidayCell.publicMarkView.layer.borderColor = self.view.tintColor.CGColor;
				holidayCell.publicLabel.textColor = self.view.tintColor;
			}
		}

		NSDateFormatter *df = [self dateFormatter];
		holidayCell.titleLabel.text = cellData[kHolidayName];
		holidayCell.dateLabel.text = [df stringFromDate: cellData[kHolidayDate] ];
		[holidayCell.publicMarkView setHidden:![cellData[kHolidayIsPublic] boolValue]];
		[holidayCell.publicLabel setHidden:![cellData[kHolidayIsPublic] boolValue]];

		if (showLunar) {
			BOOL isKorean = [_countries[tableView.tag] isEqualToString:@"kr"];
			NSDate *lunarDate;
			if (isKorean) {
				lunarDate = [HolidayData koreaLunarDateWithGregorianDate:cellData[kHolidayDate]];
			} else {
				lunarDate = [HolidayData lunarDateWithGregorianDate:cellData[kHolidayDate]];
			}
			holidayCell.lunarDateLabel.text = [df stringFromDate:lunarDate];

			[holidayCell.lunarImageView setHidden:NO];
			[holidayCell.lunarDateLabel setHidden:NO];
		}

		cell = holidayCell;
	}

    return cell;
}

- (NSDateFormatter *)dateFormatter {
	NSDateFormatter *df = [NSDateFormatter new];
	if (IS_IPHONE) {
		[df setDateFormat:@"EEE, MMM d"];
	} else {
		[df setDateStyle:NSDateFormatterFullStyle];

		NSString *formatString = [df dateFormat];
		formatString = [formatString stringByReplacingOccurrencesOfString:@"y" withString:@""];
		formatString = [formatString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@", "]];
		[df setDateFormat:formatString];
	}
	return df;
}

- (NSDictionary *)holidayDataForTableView:(UITableView *)tableView row:(NSUInteger)row {
	NSDictionary *holidayData;
	NSArray *holidays = self.holidayDataArray[tableView.tag];
	if (_thisYear == [self yearForTableView:tableView]) {
		A3FSegmentedControl *segmentedControl = (A3FSegmentedControl *) [tableView.tableHeaderView viewWithTag:HolidaysHeaderViewSegmentedControl];
		NSUInteger upcomingIndex = [self upcomingFirstHolidayInPage:tableView.tag];

		holidayData = holidays[!segmentedControl.selectedSegmentIndex ?
				row + upcomingIndex : row];
	} else {
		holidayData = holidays[row];
	}
	return holidayData;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    FNLOG(@"%f", scrollView.contentOffset.y);
	if (scrollView == _scrollView) {
		NSInteger currentPage = (NSInteger) (scrollView.contentOffset.x / self.view.bounds.size.width);
		[self setFocusToPage:currentPage];
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (!self.navigationController.navigationBarHidden) {
        [self tapOnScrollView];
    }
	if (scrollView == _scrollView) {
		[_viewComponents enumerateObjectsUsingBlock:^(NSDictionary *viewComponent, NSUInteger idx, BOOL *stop) {
			UIView *borderView = viewComponent[kHolidayViewComponentBorderView];
			borderView.clipsToBounds = YES;
		}];
	} else if ([scrollView isKindOfClass:[UITableView class]]) {
		_lastKnownOffset = scrollView.contentOffset.y;
	}
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
	if ([scrollView isKindOfClass:[UITableView class]]) {
		[self scrollToRightPosition:scrollView enforceToMiddle:NO animated:YES ];
		FNLOG(@"%f, %f", scrollView.contentOffset.y, _lastKnownOffset);
	}
}

- (void)scrollToRightPosition:(UIScrollView *)scrollView enforceToMiddle:(BOOL)enforceToMiddle animated:(BOOL)animated {
	CGFloat middleTarget;
	if (IS_IPHONE) {
        CGRect screenBoudns = [self screenBoundsAdjustedWithOrientation];
        if (screenBoudns.size.height == 480) {
            middleTarget = 280;
        } else {
            middleTarget = 359;
        }
	} else {
        if (IS_PORTRAIT) {
            middleTarget = 815;
        } else {
            middleTarget = 559;
        }
	}

	BOOL scrollToBottom = scrollView.contentOffset.y > _lastKnownOffset;
	if (scrollView.decelerationRate == UIScrollViewDecelerationRateNormal) {
		if (	enforceToMiddle ||
				(scrollToBottom && (scrollView.contentOffset.y < middleTarget)) ||
				(!scrollToBottom && (scrollView.contentOffset.y > middleTarget))	) {
			[scrollView setContentOffset:CGPointMake(0, middleTarget) animated:animated];
		}
	}
}

- (void)setFocusToPage:(NSInteger)page {
	UIView *borderView = _viewComponents[page][kHolidayViewComponentBorderView];
	[_scrollView bringSubviewToFront:borderView];
	borderView.clipsToBounds = NO;
	[_pageControl setCurrentPage:page];

	[self setPhotoLabelText];

	UITableView *tableView = [self tableViewAtCurrentPage];
	UILabel *yearLabel = (UILabel *) [tableView.tableHeaderView viewWithTag:HolidaysHeaderViewYearLabel];
	NSUInteger year = [yearLabel.text integerValue];
	[self reloadDataForCurrentPageWithYear:year];
}

#pragma mark - Holidays data

- (NSMutableArray *)holidayDataArray {
	if (!_holidayDataArray) {
		_holidayDataArray = [NSMutableArray new];
		HolidayData *theData = [HolidayData new];
		for (NSString *countryCode in self.countries) {
			NSArray *holidays = [theData holidaysForCountry:countryCode year:2013 fullSet:NO ];
			[_holidayDataArray addObject:holidays];
		}
	}
	return _holidayDataArray;
}

- (NSArray *)holidaysForCountryCode:(NSString *)countryCode year:(NSUInteger)year {
	HolidayData *theData = [HolidayData new];
	return [theData holidaysForCountry:countryCode year:year fullSet:NO ];
}


@end
