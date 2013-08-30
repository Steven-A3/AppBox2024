//
//  A3HolidaysViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/22/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3HolidaysViewController.h"
#import "A3FlickrImageView.h"
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

@interface A3HolidaysViewController () <A3FlickrImageViewDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, CLLocationManagerDelegate, FXPageControlDelegate>

@property (nonatomic, strong) A3FlickrImageView *backgroundImageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *viewComponents;
@property (nonatomic, strong) UILabel *photoLabel;
@property (nonatomic, strong) FXPageControl *pageControl;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) NSArray *countries;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSString *countryCodeOfCurrentLocation;
@property (nonatomic, strong) NSMutableArray *holidayDataArray;

@end

@implementation A3HolidaysViewController {
	NSUInteger _indexForImageUpdatingPage;
	NSInteger _thisYear;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [gregorian components:NSYearCalendarUnit fromDate:[NSDate date]];
	_thisYear = [components year];

	_indexForImageUpdatingPage = 0;

	self.automaticallyAdjustsScrollViewInsets = NO;
	UIImage *image = [[UIImage alloc] init];
	[self.navigationController.navigationBar setBackgroundImage:image forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
	[self.navigationController.navigationBar setShadowImage:image];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
	[self.navigationController setNavigationBarHidden:YES];

	[self countries];

	[self setupScrollView];
	[self setupFooterView];		// Page Control must be setup first, left refers its numberOfPages

	[self leftBarButtonAppsButton];
	[self setupRightBarButotnItems];

	[self.view layoutIfNeeded];

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if (self.isMovingToParentViewController) {
		[self.viewComponents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			A3FlickrImageView *imageView = obj[kHolidayViewComponentImageView];
			[imageView displayImageWithCountryCode:self.countries[idx]];
		}];
        
        [self setPhotoLabelText];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if (self.isMovingToParentViewController) {
		[self startAskLocation];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if (self.isMovingFromParentViewController) {
		[self.navigationController setNavigationBarHidden:NO];
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];

		[self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
		[self.navigationController.navigationBar setShadowImage:nil];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Right bar button items
- (void)setupRightBarButotnItems {
	UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonAction)];
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonAction)];
	self.navigationItem.rightBarButtonItems = @[editButton, searchButton];
}

- (void)searchButtonAction {

}

- (void)editButtonAction {

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
		}
	}];
	if ([self.countryCodeOfCurrentLocation length]) {
		if (![self.countries[0] isEqualToString:_countryCodeOfCurrentLocation]) {
			NSMutableArray *tempArray = [_countries mutableCopy];
			[tempArray insertObject:_countryCodeOfCurrentLocation atIndex:0];
			_countries = tempArray;

			[HolidayData setUserSelectedCountries:_countries];

			[_footerView removeFromSuperview];
			[_scrollView removeFromSuperview];
			_scrollView = nil;
			_footerView = nil;
			_viewComponents = nil;

			[self setupScrollView];
			[self setupFooterView];

			[self.view layoutIfNeeded];
		}
	}
	[self startUpdateImage];
}

- (void)startUpdateImage {
	if (_indexForImageUpdatingPage < [self.countries count]) {
		A3FlickrImageView *imageView = self.viewComponents[_indexForImageUpdatingPage][kHolidayViewComponentImageView];
		[imageView startUpdate];
		_indexForImageUpdatingPage++;
	}
}

#pragma mark - Layout
- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];

	CGFloat viewHeight = self.view.bounds.size.height;
	_scrollView.contentSize = CGSizeMake(self.view.bounds.size.width * _pageControl.numberOfPages, viewHeight);
	[self.viewComponents enumerateObjectsUsingBlock:^(NSDictionary *viewComponent, NSUInteger idx, BOOL *stop) {
		UIView *borderView = viewComponent[kHolidayViewComponentBorderView];
		[borderView setFrame:CGRectMake(self.view.bounds.size.width * idx, 0, self.view.bounds.size.width, viewHeight)];
		if (borderView.frame.origin.x == _scrollView.contentOffset.x) {
			[_scrollView bringSubviewToFront:borderView];
			borderView.clipsToBounds = NO;
		}
	}];
	FNLOG(@"contentSize %f", _scrollView.contentSize.width);
	FNLOG(@"contentOffset %f", _scrollView.contentOffset.x);
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
	line.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.8].CGColor;
	line.layer.borderWidth = IS_RETINA ? 0.25 : 0.5;
	[self.view addSubview:line];

	[line makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left);
		make.right.equalTo(self.view.right);
		make.bottom.equalTo(self.view.bottom).with.offset(-44);
		make.height.equalTo(@1);
	}];

	[self photoLabel];
	[self pageControl];

	UIButton *listButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[listButton setImage:[[UIImage imageNamed:@"list"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	[listButton addTarget:self action:@selector(listButtonAction) forControlEvents:UIControlEventTouchUpInside];
	[listButton setTintColor:[UIColor whiteColor]];
	[self.view addSubview:listButton];

	[listButton makeConstraints:^(MASConstraintMaker *make) {
		make.right.equalTo(_footerView.right).with.offset(IS_IPAD ? -28 : -15);
		make.centerY.equalTo(_footerView.centerY);
	}];
}

- (FXPageControl *)pageControl {
	if (!_pageControl) {
		_pageControl = [[FXPageControl alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 30)];
		_pageControl.backgroundColor = [UIColor clearColor];
		_pageControl.numberOfPages = [self.viewComponents count];
		_pageControl.dotColor = [UIColor colorWithRed:77.0 / 255.0 green:77.0 / 255.0 blue:77.0 / 255.0 alpha:1.0];
		_pageControl.selectedDotColor = [UIColor whiteColor];
		_pageControl.delegate = self;
		[_pageControl addTarget:self action:@selector(pageControlValuedChanged:) forControlEvents:UIControlEventValueChanged];
		[_footerView addSubview:_pageControl];

		[_pageControl makeConstraints:^(MASConstraintMaker *make) {
			make.width.equalTo(@200);
			make.height.equalTo(@30);
			make.centerX.equalTo(_footerView.centerX);
			make.centerY.equalTo(_footerView.centerY);
		}];
	}
	return _pageControl;
}

- (void)pageControlValuedChanged:(FXPageControl *)pageControl {
	CGFloat width = self.view.bounds.size.width;
	[_scrollView setContentOffset:CGPointMake(width * pageControl.currentPage, 0) animated:YES];
	[self setFocusToPage:pageControl.currentPage];
}

- (UIImage *)pageControl:(FXPageControl *)pageControl imageForDotAtIndex:(NSInteger)index1 {
	if (index1 == 0) {
		[SFKImage setDefaultFont:[UIFont fontWithName:@"appbox" size:10]];
		[SFKImage setDefaultColor:[UIColor colorWithRed:77.0 / 255.0 green:77.0 / 255.0 blue:77.0 / 255.0 alpha:1.0]];
		return [SFKImage imageNamed:@"p"];
	}
	return nil;
}

- (UIImage *)pageControl:(FXPageControl *)pageControl selectedImageForDotAtIndex:(NSInteger)index1 {
	if (index1 == 0) {
		[SFKImage setDefaultFont:[UIFont fontWithName:@"appbox" size:10]];
		[SFKImage setDefaultColor:[UIColor whiteColor]];

		return [SFKImage imageNamed:@"p"];
	}
	return nil;
}

- (UILabel *)photoLabel {
	if (!_photoLabel) {
		_photoLabel = [UILabel new];
		_photoLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
		_photoLabel.textColor = [UIColor whiteColor];
		_photoLabel.numberOfLines = 2;
		_photoLabel.userInteractionEnabled = YES;
		[_footerView addSubview:_photoLabel];

		[_photoLabel makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(_footerView.left).with.offset(IS_IPAD ? 28 : 15);
			make.centerY.equalTo(_footerView.centerY);
		}];

		UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openURL)];
		[_photoLabel addGestureRecognizer:tapGestureRecognizer];
	}
	return _photoLabel;
}

- (void)setPhotoLabelText {
	A3FlickrImageView *view = _viewComponents[_pageControl.currentPage][kHolidayViewComponentImageView];
	NSString *owner = view.ownerString;
	if ([owner length]) {
		self.photoLabel.text = [NSString stringWithFormat:@"by %@\non flickr", view.ownerString];
	} else {
		self.photoLabel.text = @"";
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
	[self presentSubViewController:viewController];
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
}

- (void)tapOnScrollView {
	FNLOG();

	BOOL navigationBarHidden = self.navigationController.navigationBarHidden;
	[[UIApplication sharedApplication] setStatusBarHidden:!navigationBarHidden];
	[self.navigationController setNavigationBarHidden:!navigationBarHidden];
}

- (void)setupScrollViewContents {
	_viewComponents = [NSMutableArray new];

	CGFloat viewWidth = self.view.bounds.size.width;
	CGFloat viewHeight = self.view.bounds.size.height;
	NSUInteger idx = 0;
	for (NSString *countryCode in self.countries) {
		// Border view
		UIView *borderView = [UIView new];
		borderView.frame = CGRectMake(idx * viewWidth, 0, viewWidth, viewHeight);
		borderView.tag = idx;
		borderView.backgroundColor = [UIColor clearColor];
		borderView.clipsToBounds = YES;
		[_scrollView addSubview:borderView];

		A3FlickrImageView *imageView = [A3FlickrImageView new];
		imageView.delegate = self;
		imageView.tag = idx;
		[borderView addSubview:imageView];

		[imageView makeConstraints:^(MASConstraintMaker *make) {
			make.edges.equalTo(borderView).insets(UIEdgeInsetsMake(-50, -50, -50, -50));
		}];

		UIInterpolatingMotionEffect *interpolationHorizontal = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
		interpolationHorizontal.minimumRelativeValue = @-50.0;
		interpolationHorizontal.maximumRelativeValue = @50.0;

		UIInterpolatingMotionEffect *interpolationVertical = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
		interpolationVertical.minimumRelativeValue = @-50.0;
		interpolationVertical.maximumRelativeValue = @50.0;

		[imageView addMotionEffect:interpolationHorizontal];
		[imageView addMotionEffect:interpolationVertical];

		UITableView *tableView = [self tableViewAtPage:idx];
		tableView.tag = idx;
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

		idx++;
	}
}

#pragma mark - Setup TableView

static NSString *const CellIdentifier = @"holidaysCell";

- (UITableView *)tableViewAtPage:(NSUInteger)page {
	UIView *tableHeaderView = [self tableHeaderViewAtPage:page];

	UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
	tableView.dataSource = self;
	tableView.delegate = self;
	tableView.backgroundView = nil;
	tableView.backgroundColor = [UIColor clearColor];
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	tableView.rowHeight = 94;
    [tableView registerClass:[A3HolidaysCell class] forCellReuseIdentifier:CellIdentifier];
	tableView.tableHeaderView = tableHeaderView;
	tableView.showsVerticalScrollIndicator = NO;
	return tableView;
}

- (UIView *)tableHeaderViewAtPage:(NSUInteger)page {
	UIView *headerView = [UIView new];

	CGRect screenBounds = [[UIScreen mainScreen] bounds];
	CGFloat viewHeight = IS_PORTRAIT ? screenBounds.size.height : screenBounds.size.width;
	FNLOG(@"UIScreen mainScreen height : %f", viewHeight);
	viewHeight += 118.0;
	viewHeight -= 54.0;
	[headerView setFrame:CGRectMake(0, 0, IS_PORTRAIT ? screenBounds.size.width : screenBounds.size.height, viewHeight)];

	UIView *bottomLine = [UIView new];
	bottomLine.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.7].CGColor;
	bottomLine.layer.borderWidth = IS_RETINA ? 0.25 : 0.5;
	[headerView addSubview:bottomLine];

	[bottomLine makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(headerView.left);
		make.right.equalTo(headerView.right);
		make.bottom.equalTo(headerView.bottom);
		make.height.equalTo(@1);
	}];

	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Upcoming", @"Past"]];
	segmentedControl.tag = HolidaysHeaderViewSegmentedControl;
	segmentedControl.tintColor = [UIColor colorWithWhite:1.0 alpha:0.7];
	segmentedControl.selectedSegmentIndex = 0;
	[segmentedControl addTarget:self action:@selector(upcomingPastChanged:) forControlEvents:UIControlEventValueChanged];

	[segmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]} forState:UIControlStateSelected];
	[headerView addSubview:segmentedControl];

	[segmentedControl makeConstraints:^(MASConstraintMaker *make) {
		if (IS_IPHONE) {
			make.width.equalTo(@192);
			make.height.equalTo(@30);
			make.left.equalTo(headerView.left).with.offset(5);
			make.bottom.equalTo(headerView.bottom).with.offset(-6);
		} else {
			make.width.equalTo(@300);
			make.height.equalTo(@30);
			make.centerX.equalTo(headerView.centerX).with.offset(-107);
			make.bottom.equalTo(headerView.bottom).with.offset(-6);
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
			make.centerX.equalTo(headerView.centerX).with.offset(180);
			make.bottom.equalTo(headerView.bottom).with.offset(-6);
		}
	}];

	UIButton *prevYearButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[SFKImage setDefaultFont:[UIFont fontWithName:@"appbox" size:22]];
	[SFKImage setDefaultColor:[UIColor whiteColor]];
	UIImage *image = [SFKImage imageNamed:@"e"];
	[prevYearButton setImage:image forState:UIControlStateNormal];
	[prevYearButton addTarget:self action:@selector(prevYearButtonAction) forControlEvents:UIControlEventTouchUpInside];
	[yearBorderView addSubview:prevYearButton];

	[prevYearButton makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(yearBorderView.centerY);
		make.centerX.equalTo(yearBorderView.centerX).with.offset(-33);
	}];

	UIButton *nextYearButton = [UIButton buttonWithType:UIButtonTypeCustom];
	image = [SFKImage imageNamed:@"f"];
	[nextYearButton setImage:image forState:UIControlStateNormal];
	[nextYearButton addTarget:self action:@selector(nextYearButtonAction) forControlEvents:UIControlEventTouchUpInside];
	[yearBorderView addSubview:nextYearButton];

	[nextYearButton makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(yearBorderView.centerX).with.offset(33);
		make.centerY.equalTo(yearBorderView.centerY);
	}];

	UILabel *yearLabel = [UILabel new];
	yearLabel.tag = HolidaysHeaderViewYearLabel;
	yearLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
	yearLabel.text = @"2013";
	yearLabel.textColor = [UIColor whiteColor];
	yearLabel.textAlignment = NSTextAlignmentCenter;
	[yearBorderView addSubview:yearLabel];

	[yearLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(yearBorderView.centerX);
		make.centerY.equalTo(yearBorderView.centerY);
	}];

	UILabel *nameLabel = [UILabel new];
	nameLabel.tag = HolidaysHeaderViewNameLabel;
	nameLabel.textColor = [UIColor whiteColor];
	nameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:30];
	nameLabel.textAlignment = NSTextAlignmentCenter;
	nameLabel.text = @"Tax Day";
	[headerView addSubview:nameLabel];

	[nameLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(headerView.centerX);
		make.bottom.equalTo(headerView.bottom).with.offset(-126);
	}];

	UILabel *daysLeftLabel = [UILabel new];
	daysLeftLabel.tag = HolidaysHeaderViewDaysLeftLabel;
	daysLeftLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.6];
	daysLeftLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
	daysLeftLabel.textAlignment = NSTextAlignmentCenter;
	daysLeftLabel.text = @"123 Days Left";
	[headerView addSubview:daysLeftLabel];

	[daysLeftLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(headerView.centerX);
		make.bottom.equalTo(nameLabel.top).with.offset(-3);
	}];

	UILabel *countryNameLabel = [UILabel new];
	countryNameLabel.tag = HolidaysHeaderViewCountryLabel;
	countryNameLabel.textColor = [UIColor whiteColor];
	countryNameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:30];
	countryNameLabel.textAlignment = NSTextAlignmentCenter;
	countryNameLabel.text = [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:self.countries[page]];
	[headerView addSubview:countryNameLabel];

	[countryNameLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(headerView.centerX);
		make.bottom.equalTo(daysLeftLabel.top).with.offset(-12);
	}];

	NSUInteger myPosition = [self upcomingFirstHolidayInPage:page];

	if (myPosition != NSNotFound) {
		NSArray *holidaysInPage = self.holidayDataArray[page];
		NSDictionary *upcomingHoliday = holidaysInPage[myPosition];
		nameLabel.text = upcomingHoliday[kHolidayName];

		daysLeftLabel.text = [upcomingHoliday[kHolidayDate] daysLeft];

		[segmentedControl setTitle:[NSString stringWithFormat:@"Upcoming %d", [holidaysInPage count] - myPosition]
				 forSegmentAtIndex:0];
		[segmentedControl setTitle:[NSString stringWithFormat:@"Past %d", myPosition]
				 forSegmentAtIndex:1];

		FNLOG(@"%d + %d = %d : %d", [holidaysInPage count] - myPosition, myPosition, myPosition + [holidaysInPage count] - myPosition + 1, [holidaysInPage count]);
	} else {

	}

	return headerView;
}

- (UITableView *)tableViewAtCurrentPage {
	return _viewComponents[_pageControl.currentPage][kHolidayViewComponentTableView];
}

- (void)reloadDataForCurrentPageWithYear:(NSUInteger)year {
	NSUInteger currentPage = _pageControl.currentPage;
	NSArray *holidays = [self holidaysForCountryCode:_countries[currentPage] year:year];
	[_holidayDataArray replaceObjectAtIndex:currentPage withObject:holidays];

	UITableView *tableView = [self tableViewAtCurrentPage];
	UISegmentedControl *segmentedControl = (UISegmentedControl *) [tableView.tableHeaderView viewWithTag:HolidaysHeaderViewSegmentedControl];
	NSInteger upcoming, past;
	if (_thisYear == year) {
		NSUInteger myPosition = [self upcomingFirstHolidayInPage:currentPage];
		upcoming = [holidays count] - myPosition;
		past = myPosition;
		[segmentedControl setEnabled:YES forSegmentAtIndex:0];
		[segmentedControl setEnabled:YES forSegmentAtIndex:1];
		[segmentedControl setSelectedSegmentIndex:0];
	} else if (year > _thisYear) {
		upcoming = [holidays count];
		past = 0;
		[segmentedControl setEnabled:YES forSegmentAtIndex:0];
		[segmentedControl setEnabled:NO forSegmentAtIndex:1];
		[segmentedControl setSelectedSegmentIndex:0];
	} else {
		upcoming = 0;
		past = [holidays count];
		[segmentedControl setEnabled:NO forSegmentAtIndex:0];
		[segmentedControl setEnabled:YES forSegmentAtIndex:1];
		[segmentedControl setSelectedSegmentIndex:1];
	}
	[segmentedControl setTitle:[NSString stringWithFormat:@"Upcoming %d", upcoming]
			 forSegmentAtIndex:0];
	[segmentedControl setTitle:[NSString stringWithFormat:@"Past %d", past]
			 forSegmentAtIndex:1];
	[tableView reloadData];
}

- (void)prevYearButtonAction {
	UITableView *tableView = [self tableViewAtCurrentPage];

	UILabel *yearLabel = (UILabel *) [tableView.tableHeaderView viewWithTag:HolidaysHeaderViewYearLabel];
	NSUInteger year = [yearLabel.text integerValue] - 1;
	yearLabel.text = [NSString stringWithFormat:@"%d", year];

	[self reloadDataForCurrentPageWithYear:year];
}

- (void)nextYearButtonAction {
	UITableView *tableView = [self tableViewAtCurrentPage];

	UILabel *yearLabel = (UILabel *) [tableView.tableHeaderView viewWithTag:HolidaysHeaderViewYearLabel];
	NSUInteger year = [yearLabel.text integerValue] + 1;
	yearLabel.text = [NSString stringWithFormat:@"%d", year];

	[self reloadDataForCurrentPageWithYear:year];
}

- (void)upcomingPastChanged:(UISegmentedControl *)segmentedControl {
	UITableView *tableView = _viewComponents[_pageControl.currentPage][kHolidayViewComponentTableView];
	[tableView reloadData];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSArray *holidaysInPage = self.holidayDataArray[tableView.tag];

	if (_thisYear == [self yearForTableView:tableView]) {
		UISegmentedControl *segmentedControl = (UISegmentedControl *) [tableView.tableHeaderView viewWithTag:HolidaysHeaderViewSegmentedControl];
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

		NSArray *holidays = self.holidayDataArray[tableView.tag];

		NSDictionary *cellData;

		if (_thisYear == [self yearForTableView:tableView]) {
			UISegmentedControl *segmentedControl = (UISegmentedControl *) [tableView.tableHeaderView viewWithTag:HolidaysHeaderViewSegmentedControl];
			NSUInteger upcomingIndex = [self upcomingFirstHolidayInPage:tableView.tag];

			cellData = holidays[!segmentedControl.selectedSegmentIndex ?
					indexPath.row + upcomingIndex : indexPath.row];

			if (!segmentedControl.selectedSegmentIndex && !indexPath.row) {
				holidayCell.titleLabel.textColor = self.view.tintColor;
				holidayCell.dateLabel.textColor = self.view.tintColor;
			}
		} else {
			cellData = holidays[indexPath.row];
		}

		NSDateFormatter *df = [NSDateFormatter new];
		[df setDateFormat:@"EEE, MMM d"];

		holidayCell.titleLabel.text = cellData[kHolidayName];
		holidayCell.dateLabel.text = [df stringFromDate: cellData[kHolidayDate] ];
		[holidayCell.publicMark setHidden:![cellData[kHolidayIsPublic] boolValue]];

		holidayCell.lunarDateLabel.text = [df stringFromDate: cellData[kHolidayDate] ];

		cell = holidayCell;
	}

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if (scrollView == _scrollView) {
        FNLOG(@"%f, %f", scrollView.contentSize.height, scrollView.bounds.size.height);

		NSInteger currentPage = (NSInteger) (scrollView.contentOffset.x / self.view.bounds.size.width);
		[self setFocusToPage:currentPage];
	}
}

- (void)setFocusToPage:(NSInteger)page {
	UIView *borderView = _viewComponents[page][kHolidayViewComponentBorderView];
	[_scrollView bringSubviewToFront:borderView];
	borderView.clipsToBounds = NO;
	[_pageControl setCurrentPage:page];
    
	[self setPhotoLabelText];
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
	}
}

#pragma mark - Holidays data

- (NSMutableArray *)holidayDataArray {
	if (!_holidayDataArray) {
		_holidayDataArray = [NSMutableArray new];
		HolidayData *theData = [HolidayData new];
		for (NSString *countryCode in self.countries) {
			NSArray *holidays = [theData holidaysForCountry:countryCode year:2013];
			[_holidayDataArray addObject:holidays];
		}
	}
	return _holidayDataArray;
}

- (NSArray *)holidaysForCountryCode:(NSString *)countryCode year:(NSUInteger)year {
	HolidayData *theData = [HolidayData new];
	return [theData holidaysForCountry:countryCode year:year];
}

@end
