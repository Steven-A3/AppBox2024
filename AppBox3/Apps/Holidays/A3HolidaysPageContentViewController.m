//
//  A3HolidaysPageContentViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/15/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3HolidaysPageContentViewController.h"
#import "HolidayData.h"
#import "HolidayData+Country.h"
#import "SFKImage.h"
#import "A3FSegmentedControl.h"
#import "A3HolidaysCell.h"
#import "NSDate+daysleft.h"
#import "A3HolidaysFlickrDownloadManager.h"
#import "UIViewController+A3Addition.h"
#import "A3BackgroundWithPatternView.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3UserDefaults.h"
#import "A3GradientView.h"
#import "ALDBlurImageProcessor.h"
#import "NTRMath.h"
#import "A3AppDelegate.h"
#import "A3UIDevice.h"

typedef NS_ENUM(NSInteger, HolidaysTableHeaderViewComponent) {
	HolidaysHeaderViewSegmentedControl = 1000,
	HolidaysHeaderViewYearLabel,
	HolidaysHeaderViewNameLabel,
	HolidaysHeaderViewDateLabel,
	HolidaysHeaderViewDaysLeftLabel,
	HolidaysHeaderViewCountryLabel
};

@interface A3HolidaysPageContentViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, A3ViewControllerProtocol, ALDBlurImageProcessorDelegate>

@property (nonatomic, strong) NSArray *holidays;
@property (nonatomic, strong) ALDBlurImageProcessor *blurImageProcessor;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) A3BackgroundWithPatternView *backgroundView;
@property (nonatomic, strong) UIView *coverViewOnBlur;
@property (nonatomic, strong) UIAlertView *acknowledgementAlertView;
@property (nonatomic, strong) A3GradientView *bottomGradientView;

@end

@implementation A3HolidaysPageContentViewController {
	NSInteger _thisYear, _currentYear;
	CGFloat _lastKnownOffset;
	UIInterfaceOrientation _previousOrientation;
}

- (instancetype)initWithCountryCode:(NSString *)countryCode {
	self = [super init];
	if (self) {
		// Custom initialization
		self.countryCode = countryCode;
		[self setupThisYear];
	}
	return self;
}

- (void)cleanUp {
	[self removeObserver];
}

- (void)setupThisYear {
	_thisYear = [HolidayData thisYear];
	_holidays = nil;
	NSUInteger index = [self upcomingFirstHoliday];
	if (index == NSNotFound) {
		_thisYear++;
		_holidays = nil;
	}
	_currentYear = _thisYear;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.view.clipsToBounds = YES;
	self.view.backgroundColor = [UIColor whiteColor];
	self.automaticallyAdjustsScrollViewInsets = NO;

	[self setupBackgroundView];
	[self setupTableView];
	[self setupImageView];
	[self setupBottomGradient];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageDownloaded:) name:A3HolidaysFlickrDownloadManagerDownloadComplete object:[A3HolidaysFlickrDownloadManager sharedInstance]];
	[self registerContentSizeCategoryDidChangeNotification];
}

- (void)removeObserver {
	[self removeContentSizeCategoryDidChangeNotification];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3HolidaysFlickrDownloadManagerDownloadComplete object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)prepareClose {
	self.tableView.delegate = nil;
	self.tableView.dataSource = nil;
	[self removeObserver];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	_previousOrientation = CURRENT_ORIENTATION;
}

- (void)dealloc {
	[self removeObserver];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if (!self.isMovingToParentViewController) {
		if (_previousOrientation != CURRENT_ORIENTATION) {
			UIInterfaceOrientation orientation = CURRENT_ORIENTATION;
			self.tableView.tableHeaderView = [self tableHeaderViewForInterfaceOrientation:orientation];
		}
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([self isMovingToParentViewController] || [self isBeingPresented]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
	}
}

- (void)applicationWillResignActive {
	if (_acknowledgementAlertView) {
		[_acknowledgementAlertView dismissWithClickedButtonIndex:_acknowledgementAlertView.cancelButtonIndex animated:NO];
	}
}

- (void)startDownloadWallpaperFromFlickr {
	[[A3HolidaysFlickrDownloadManager sharedInstance] addDownloadTaskForCountryCode:_countryCode];
}

- (void)contentSizeDidChange:(NSNotification *)notification {
	[self updateTableHeaderView:_tableView.tableHeaderView];
	[self.tableView reloadData];
}

#pragma mark - Image Processing

- (ALDBlurImageProcessor *)blurImageProcessor {
	if (!_blurImageProcessor) {
		_blurImageProcessor = [[ALDBlurImageProcessor alloc] init];
		_blurImageProcessor.delegate = self;
	}
	return _blurImageProcessor;
}

- (void)onALDBlurImageProcessor:(ALDBlurImageProcessor *)blurImageProcessor newBlurrredImage:(UIImage *)image {
	self.imageView.image = image;
}

- (void)imageDownloaded:(NSNotification *)notification {
	NSString *downloadedCountryCode = notification.userInfo[@"CountryCode"];
	if ([_countryCode isEqualToString:@"jewish"] && [downloadedCountryCode isEqualToString:@"il"]) {
		downloadedCountryCode = @"jewish";
	}
	if ([downloadedCountryCode isEqualToString:_countryCode]) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.pageViewController updatePhotoLabelText];
			self.imageView.image = [[A3HolidaysFlickrDownloadManager sharedInstance] imageForCountryCode:self.countryCode];
            if (self.imageView.image) {
                self.blurImageProcessor.imageToProcess = self.imageView.image;
                uint32_t radius = self.tableView.contentOffset.y < 100 ? 0 : lerp(self.tableView.contentOffset.y / self.tableView.contentSize.height, 20, 30);
                [self.blurImageProcessor asyncBlurWithRadius:radius iterations:5 cancelingLastOperation:YES];
                [self alertAcknowledgment];
            }
		});
	}
}

- (void)alertAcknowledgment {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		if (![[A3UserDefaults standardUserDefaults] boolForKey:A3HolidaysDoesNotNeedsShowAcknowledgement]) {
            [self presentAlertWithTitle:NSLocalizedString(@"Acknowledgement", @"Acknowledgement")
                                message:NSLocalizedString(@"HOLIDAYS_ACKNOWLEDGEMENT", @"HOLIDAYS_ACKNOWLEDGEMENT")];
            [[A3UserDefaults standardUserDefaults] setBool:YES forKey:A3HolidaysDoesNotNeedsShowAcknowledgement];
            [[A3UserDefaults standardUserDefaults] synchronize];
		}
	});
}

- (void)reloadDataRedrawImage:(BOOL)redrawImage {
	[self setupThisYear];
	[self updateTableHeaderView:_tableView.tableHeaderView];
	[self.tableView reloadData];
	if (redrawImage) {
		[_pageViewController updatePhotoLabelText];
		_imageView.image = [[A3HolidaysFlickrDownloadManager sharedInstance] imageForCountryCode:_countryCode];
		self.blurImageProcessor.imageToProcess = _imageView.image;
	}
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        UIInterfaceOrientation interfaceOrientation = size.width > size.height ? UIInterfaceOrientationLandscapeLeft : UIInterfaceOrientationPortrait;
        self.tableView.tableHeaderView = [self tableHeaderViewForInterfaceOrientation:interfaceOrientation];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    }];
}

- (void)setupBackgroundView {
	A3BackgroundPatternStyle style = [[A3HolidaysFlickrDownloadManager sharedInstance] isDayForCountryCode:self.countryCode] ? A3BackgroundPatternStyleLight : A3BackgroundPatternStyleDark;
	_backgroundView = [[A3BackgroundWithPatternView alloc] initWithStyle:style];
	_backgroundView.frame = self.view.bounds;
	_backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[self.view insertSubview:_backgroundView atIndex:0];
}

- (void)setupImageView {
	_imageView = [UIImageView new];
	_imageView.contentMode = UIViewContentModeScaleAspectFill;
	_imageView.userInteractionEnabled = NO;
	[self.view insertSubview:_imageView aboveSubview:_backgroundView];

	CGFloat interpolationFactor = 10;

	[_imageView makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(-interpolationFactor, -interpolationFactor, -interpolationFactor, -interpolationFactor));
	}];

	UIInterpolatingMotionEffect *interpolationHorizontal = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
	interpolationHorizontal.minimumRelativeValue = @(-interpolationFactor);
	interpolationHorizontal.maximumRelativeValue = @(interpolationFactor);

	UIInterpolatingMotionEffect *interpolationVertical = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
	interpolationVertical.minimumRelativeValue = @(-interpolationFactor);
	interpolationVertical.maximumRelativeValue = @(interpolationFactor);

	[_imageView addMotionEffect:interpolationHorizontal];
	[_imageView addMotionEffect:interpolationVertical];

	A3HolidaysFlickrDownloadManager *downloadManager = [A3HolidaysFlickrDownloadManager sharedInstance];
	UIImage *image = [downloadManager imageForCountryCode:_countryCode];
	if (image) {
		_imageView.image = image;
		self.blurImageProcessor.imageToProcess = _imageView.image;
	}
}

- (UIView *)coverViewOnBlur {
	if (!_coverViewOnBlur) {
		_coverViewOnBlur = [UIView new];
		_coverViewOnBlur.userInteractionEnabled = NO;
		_coverViewOnBlur.backgroundColor = [UIColor colorWithWhite:0 alpha:0.17];
		_coverViewOnBlur.alpha = 0.0;
		[_imageView addSubview:_coverViewOnBlur];

		[_coverViewOnBlur makeConstraints:^(MASConstraintMaker *make) {
			make.top.equalTo(self.view.top);
			make.left.equalTo(self.view.left);
			make.right.equalTo(self.view.right);
			make.bottom.equalTo(self.view.bottom);
		}];
	}
	return _coverViewOnBlur;
}

- (A3GradientView *)bottomGradientView {
	if (!_bottomGradientView) {
		_bottomGradientView = [A3GradientView new];
		_bottomGradientView.locations = @[@0, @0.5, @0.85, @1.0];
		_bottomGradientView.gradientColors = @[
											  (id) [UIColor colorWithWhite:0.0 alpha:0.0].CGColor,
											  (id) [UIColor colorWithWhite:0.0 alpha:0.0].CGColor,
											  (id) [UIColor colorWithWhite:0.0 alpha:0.3].CGColor,
											  (id) [UIColor colorWithWhite:0.0 alpha:0.6].CGColor
											  ];
		[self.view addSubview:_bottomGradientView];
		
	}
	
	return _bottomGradientView;
}

- (void)setupBottomGradient {
	[self.view insertSubview:self.bottomGradientView belowSubview:self.tableView];
	
	[_bottomGradientView makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.view);
	}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

static NSString *const CellIdentifier = @"holidaysCell";

- (void)setupTableView {
	[self.view addSubview:self.tableView];

    CGFloat verticalOffset = 0;
    UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets];
    if (safeAreaInsets.top > 20) {
        verticalOffset = safeAreaInsets.bottom;
    }
	[_tableView makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 54 + verticalOffset, 0));
	}];

	[self updateTableHeaderView:_tableView.tableHeaderView];
}

- (UITableView *)tableView {
	if (!_tableView) {
		UIView *tableHeaderView = [self tableHeaderViewForInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];

		_tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
		_tableView.dataSource = self;
		_tableView.delegate = self;
		_tableView.backgroundView = nil;
		_tableView.backgroundColor = [UIColor clearColor];
		_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		[_tableView registerClass:[A3HolidaysCell class] forCellReuseIdentifier:CellIdentifier];
		_tableView.tableHeaderView = tableHeaderView;
		_tableView.showsVerticalScrollIndicator = NO;
		_tableView.tableFooterView = [self tableFooterView];
	}
	return _tableView;
}

/*! This calculates footer height. Table header view must be set before this.
 * \param page
 * \param tableView
 * \returns tableFooterView
 */
- (UIView *)tableFooterView {
	CGFloat tableRowsHeight = 0;
	for (NSUInteger index = 0; index < [self tableView:_tableView numberOfRowsInSection:0]; index++) {
		tableRowsHeight += [self tableView:_tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
	}
	CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
	screenBounds.size.height -= 54.0 + 252.0 + (IS_IPAD ? 62 : 0);

	CGFloat footerViewHeight = screenBounds.size.height - tableRowsHeight;
	FNLOG(@"%ld, %f, %f", (long)_tableView.tag, footerViewHeight, screenBounds.size.height);
	if (footerViewHeight > 0) {
		UIView *tableFooterView = [UIView new];
		tableFooterView.frame = CGRectMake(0, 0, _tableView.bounds.size.width, footerViewHeight);
		return tableFooterView;
	}
	return nil;
}

- (UIView *)tableHeaderViewForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	UIView *headerView = [UIView new];
	headerView.autoresizingMask = UIViewAutoresizingNone;

	CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
	FNLOGRECT(screenBounds);

    CGFloat verticalOffset = 0;
    UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets];
    if (safeAreaInsets.top > 20) {
        verticalOffset = -(50 + safeAreaInsets.bottom);
    }
	CGFloat viewHeight = screenBounds.size.height;
	CGFloat viewWidth = screenBounds.size.width;
	viewHeight += 97.0 + verticalOffset;
	viewHeight -= 54.0;
	if (IS_IPAD) {
		viewHeight += 62.0;
	}

	[headerView setFrame:CGRectMake(0, 0, screenBounds.size.width, viewHeight)];

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

	CGFloat leading = IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28;
	[segmentedControl makeConstraints:^(MASConstraintMaker *make) {
		if (IS_IPHONE) {
			make.left.equalTo(headerView.left).with.offset(leading);
			make.bottom.equalTo(headerView.bottom).with.offset(-6);
			make.width.equalTo(@171);
			make.height.equalTo(@30);
		} else {
			make.width.equalTo(@301);
			make.left.equalTo(headerView.left).with.offset(leading);
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
			make.width.equalTo(@86);
			make.height.equalTo(@30);
			make.right.equalTo(headerView.right).with.offset(-leading);
			make.bottom.equalTo(headerView.bottom).with.offset(-6);
		} else {
			make.width.equalTo(@151);
			make.height.equalTo(@30);
			make.right.equalTo(headerView.right).with.offset(-leading);
			make.bottom.equalTo(headerView.bottom).with.offset(-6);
		}
	}];

	UIButton *prevYearButton = [UIButton buttonWithType:UIButtonTypeCustom];
	prevYearButton.frame = CGRectMake(0,0,40,40);
	[SFKImage setDefaultFont:[UIFont fontWithName:@"appbox" size:22]];
	[SFKImage setDefaultColor:[UIColor whiteColor]];
	UIImage *image = [SFKImage imageNamed:@"g"];
	[prevYearButton setImage:image forState:UIControlStateNormal];
	[prevYearButton addTarget:self action:@selector(prevYearButtonAction) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:prevYearButton];

	[prevYearButton makeConstraints:^(MASConstraintMaker *make) {
		make.width.equalTo(@40);
		make.height.equalTo(@40);
		make.centerY.equalTo(yearBorderView.centerY);
		make.centerX.equalTo(yearBorderView.centerX).with.offset(IS_IPHONE ? -27 : -45);
	}];

	UIButton *nextYearButton = [UIButton buttonWithType:UIButtonTypeCustom];
	image = [SFKImage imageNamed:@"h"];
	[nextYearButton setImage:image forState:UIControlStateNormal];
	[nextYearButton addTarget:self action:@selector(nextYearButtonAction) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:nextYearButton];

	[nextYearButton makeConstraints:^(MASConstraintMaker *make) {
		make.width.equalTo(@40);
		make.height.equalTo(@40);
		make.centerX.equalTo(yearBorderView.centerX).with.offset(IS_IPHONE ? 27 : 45);
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

	UILabel *nameLabel = [UILabel new];
	nameLabel.tag = HolidaysHeaderViewNameLabel;
	nameLabel.textColor = [UIColor whiteColor];
	nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:26];
	nameLabel.textAlignment = NSTextAlignmentCenter;
	nameLabel.lineBreakMode = NSLineBreakByClipping;
	nameLabel.adjustsFontSizeToFitWidth = YES;
	nameLabel.minimumScaleFactor = 0.1;
	[headerView addSubview:nameLabel];

	[nameLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(headerView.centerX);
		make.width.equalTo(@(viewWidth - (IS_IPHONE ? 20 : 28 * 2)));
		make.bottom.equalTo(yearBorderView.top).with.offset(IS_IPHONE ? -62 : -124);
	}];

	UILabel *dateLabel = [UILabel new];
	dateLabel.tag = HolidaysHeaderViewDateLabel;
	dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:19];
	dateLabel.textColor = [UIColor whiteColor];
	dateLabel.textAlignment = NSTextAlignmentCenter;
	[headerView addSubview:dateLabel];
	
	[dateLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(headerView.centerX);
		make.bottom.equalTo(nameLabel.top).with.offset(-4);
	}];
	
	UILabel *daysLeftLabel = [UILabel new];
	daysLeftLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17];
	daysLeftLabel.tag = HolidaysHeaderViewDaysLeftLabel;
	daysLeftLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
	daysLeftLabel.textAlignment = NSTextAlignmentCenter;
	daysLeftLabel.lineBreakMode = NSLineBreakByClipping;
	[headerView addSubview:daysLeftLabel];

	[daysLeftLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(headerView.centerX);
		make.bottom.equalTo(dateLabel.top).with.offset(-4);
	}];

	UILabel *countryNameLabel = [UILabel new];
	countryNameLabel.tag = HolidaysHeaderViewCountryLabel;
	countryNameLabel.textColor = [UIColor whiteColor];
	countryNameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:30];
	countryNameLabel.textAlignment = NSTextAlignmentCenter;
	countryNameLabel.adjustsFontSizeToFitWidth = YES;
	countryNameLabel.minimumScaleFactor = 0.5;
	[headerView addSubview:countryNameLabel];

	[countryNameLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(headerView.centerX);
		make.width.equalTo(@(viewWidth - (IS_IPHONE ? 20 : 28 * 2)));
		make.bottom.equalTo(daysLeftLabel.top).with.offset(-9);
	}];

	[self updateTableHeaderView:headerView];
	[headerView layoutIfNeeded];

	return headerView;
}

- (void)updateTableHeaderView {
	[self updateTableHeaderView:_tableView.tableHeaderView];
}

- (void)updateTableHeaderView:(UIView *)headerView {
	UILabel *yearLabel = (UILabel *) [headerView viewWithTag:HolidaysHeaderViewYearLabel];
	yearLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
	yearLabel.text = [NSString stringWithFormat:@"%ld", (long)_currentYear];

	UILabel *countryNameLabel = (UILabel *) [headerView viewWithTag:HolidaysHeaderViewCountryLabel];
	countryNameLabel.text = [HolidayData displayNameForCountryCode:self.countryCode];

	NSUInteger myPosition = [self upcomingFirstHoliday];

	if (myPosition != NSNotFound) {
		NSArray *holidaysInPage = self.holidays;
		NSDictionary *upcomingHoliday = holidaysInPage[myPosition];
		UILabel *nameLabel = (UILabel *)[headerView viewWithTag:HolidaysHeaderViewNameLabel];
		nameLabel.text = upcomingHoliday[kHolidayName];
		FNLOG(@"%@", nameLabel.text);

		UILabel *daysLeftLabel = (UILabel *)[headerView viewWithTag:HolidaysHeaderViewDaysLeftLabel];
		daysLeftLabel.text = [upcomingHoliday[kHolidayDate] daysLeft];

		UILabel *dateLabel = (UILabel *)[headerView viewWithTag:HolidaysHeaderViewDateLabel];
		dateLabel.text = [self.pageViewController stringFromDate: upcomingHoliday[kHolidayDate]];

		A3FSegmentedControl *segmentedControl = (A3FSegmentedControl *) [headerView viewWithTag:HolidaysHeaderViewSegmentedControl];
		segmentedControl.items = @[
				[NSString stringWithFormat:@"%@ %ld", NSLocalizedString(@"Upcoming", @"Upcoming"), (long) ([holidaysInPage count] - myPosition)],
				[NSString stringWithFormat:@"%@ %ld", NSLocalizedString(@"Past", @"Past"), (long) myPosition]
		];
		FNLOG(@"%lu + %lu = %lu : %lu", (unsigned long)([holidaysInPage count] - myPosition), (unsigned long)myPosition, (unsigned long)(myPosition + [holidaysInPage count] - myPosition + 1), (unsigned long)[holidaysInPage count]);
	}
}

- (NSArray *)holidays {
	if (!_holidays) {
		HolidayData *data = [HolidayData new];
		_holidays = [data holidaysForCountry:_countryCode year:_thisYear fullSet:NO];
	}
	return _holidays;
}

- (void)reloadDataWithYear:(NSUInteger)year {
	_holidays = nil;
	HolidayData *data = [HolidayData new];
	_holidays = [data holidaysForCountry:self.countryCode year:year fullSet:NO];

	A3FSegmentedControl *segmentedControl = (A3FSegmentedControl *) [self.tableView.tableHeaderView viewWithTag:HolidaysHeaderViewSegmentedControl];
	NSInteger upcoming, past;
	if (_thisYear == year) {
		NSUInteger myPosition = [self upcomingFirstHoliday];
		upcoming = [self.holidays count] - myPosition;
		past = myPosition;
		segmentedControl.states = @[@YES, @YES];
		[segmentedControl setSelectedSegmentIndex:0];
	} else if (year > _thisYear) {
		upcoming = [self.holidays count];
		past = 0;
		segmentedControl.states = @[@YES, @NO];
		[segmentedControl setSelectedSegmentIndex:0];
	} else {
		upcoming = 0;
		past = [self.holidays count];
		segmentedControl.states = @[@NO, @YES];
		[segmentedControl setSelectedSegmentIndex:1];
	}
	segmentedControl.items = @[
			[NSString stringWithFormat:@"%@ %ld", NSLocalizedString(@"Upcoming", @"Upcoming"), (long) upcoming],
			[NSString stringWithFormat:@"%@ %ld", NSLocalizedString(@"Past", @"Past"), (long) past]
	];
	self.tableView.tableFooterView = [self tableFooterView];
	[self.tableView reloadData];
}

- (void)prevYearButtonAction {
	UILabel *yearLabel = (UILabel *) [self.tableView.tableHeaderView viewWithTag:HolidaysHeaderViewYearLabel];
	NSInteger year = [yearLabel.text integerValue] - 1;
	HolidayData *data = [[HolidayData alloc] init];
	NSArray *array = [data holidaysForCountry:self.countryCode year:year fullSet:YES];
	if (array) {
		_currentYear = year;
		yearLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long) year];
		[self reloadDataWithYear:year];
		[self scrollToRightPosition:_tableView enforceToMiddle:YES animated:NO];
	} else {
		[self alertNotAvailableYear:year];
	}
}

- (void)alertNotAvailableYear:(NSUInteger)year {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
														message:[NSString stringWithFormat:NSLocalizedString(@"Holidays for the year %lu is not available.", @"Holidays for year %lu is not available."), (unsigned long) year]
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
											  otherButtonTitles:nil];
	[alertView show];
}

- (void)nextYearButtonAction {
	UILabel *yearLabel = (UILabel *) [self.tableView.tableHeaderView viewWithTag:HolidaysHeaderViewYearLabel];
	NSInteger year = [yearLabel.text integerValue] + 1;
	HolidayData *data = [HolidayData new];
	NSArray *array = [data holidaysForCountry:self.countryCode year:year fullSet:YES];
	if (array) {
		_currentYear = year;
		yearLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)year];
		[self reloadDataWithYear:year];
		[self scrollToRightPosition:self.tableView enforceToMiddle:YES animated:NO];
	} else {
		[self alertNotAvailableYear:year];
	}
}

- (void)upcomingPastChanged:(A3FSegmentedControl *)segmentedControl {
	self.tableView.tableFooterView = [self tableFooterView];
	[self.tableView reloadData];

	[self scrollToRightPosition:self.tableView enforceToMiddle:YES animated:NO ];
}

- (NSUInteger)upcomingFirstHoliday {
	return [self.holidays indexOfObjectPassingTest:^BOOL(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
		return [[NSDate date] compare:obj[kHolidayDate]] == NSOrderedAscending;
	}];
}

#pragma mark - Table view data source

- (NSInteger)yearForTableView:(UITableView *)tableView {
	UILabel *label = (UILabel *) [tableView.tableHeaderView viewWithTag:HolidaysHeaderViewYearLabel];
	return [label.text integerValue];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([HolidayData needToShowLunarDatesForCountryCode:self.countryCode]) {
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
	if (_thisYear == [self yearForTableView:tableView]) {
		A3FSegmentedControl *segmentedControl = (A3FSegmentedControl *) [tableView.tableHeaderView viewWithTag:HolidaysHeaderViewSegmentedControl];
		NSUInteger upcomingIndex = [self upcomingFirstHoliday];
		if (upcomingIndex == NSNotFound) {
			return !segmentedControl.selectedSegmentIndex ? [self.holidays count] : 0;
		}
		// Return the number of rows in the section.
		return !segmentedControl.selectedSegmentIndex ? [self.holidays count] - upcomingIndex : upcomingIndex;
	} else {
		return [self.holidays count];
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
			FNLOG(@"Cell Not found?");
		}
		[holidayCell assignFontsToLabels];

		NSDictionary *cellData = [self holidayDataForTableView:tableView row:indexPath.row];

		BOOL longName = [self needDoubleLineCellWithData:cellData];
		BOOL showLunar = [HolidayData needToShowLunarDatesForCountryCode:self.countryCode];

		holidayCell.showPublic = [cellData[kHolidayIsPublic] boolValue];
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

		holidayCell.titleLabel.text = cellData[kHolidayName];
		holidayCell.dateLabel.text = [self.pageViewController stringFromDate: cellData[kHolidayDate] ];

		if (showLunar) {
			holidayCell.lunarDateLabel.text = [self.pageViewController lunarStringFromDate:cellData[kHolidayDate] isKorean:[self.countryCode isEqualToString:@"kr"] ];
		}

		cell = holidayCell;
	}

	return cell;
}

- (NSDictionary *)holidayDataForTableView:(UITableView *)tableView row:(NSUInteger)row {
	NSDictionary *holidayData;
	if (_thisYear == [self yearForTableView:tableView]) {
		A3FSegmentedControl *segmentedControl = (A3FSegmentedControl *) [tableView.tableHeaderView viewWithTag:HolidaysHeaderViewSegmentedControl];
		NSUInteger upcomingIndex = [self upcomingFirstHoliday];

		if (upcomingIndex == NSNotFound) {
			return nil;
		} else {
			holidayData = self.holidays[!segmentedControl.selectedSegmentIndex ? row + upcomingIndex : row];
		}
	} else {
		holidayData = self.holidays[row];
	}
	return holidayData;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (self.imageView.image && self.blurImageProcessor.imageToProcess) {
		uint32_t radius = scrollView.contentOffset.y < 100 ? 0 : lerp(scrollView.contentOffset.y / scrollView.contentSize.height, 20, 30);
		[self.blurImageProcessor asyncBlurWithRadius:radius iterations:5 cancelingLastOperation:YES];
	}
	[self.bottomGradientView setAlpha: scrollView.contentOffset.y < 100 ? 1.0 : 0];
	
	if (scrollView.contentOffset.y == 0) {
		[UIView animateWithDuration:1.0 animations:^{
			[self.coverViewOnBlur setAlpha:0.0];
		}];
	} else {
		[self.coverViewOnBlur setAlpha:1.0];
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[_pageViewController setNavigationBarHidden:YES];
	_lastKnownOffset = scrollView.contentOffset.y;
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
		CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
		if (screenBounds.size.height == 480) {
			middleTarget = 280;
		} else {
			middleTarget = 359;
		}
	} else {
		if ([UIWindow interfaceOrientationIsPortrait]) {
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

@end
