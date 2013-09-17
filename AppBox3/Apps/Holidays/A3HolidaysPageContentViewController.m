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
#import "A3UIDevice.h"
#import "A3GradientView.h"
#import "FXLabel.h"
#import "SFKImage.h"
#import "A3FSegmentedControl.h"
#import "common.h"
#import "A3HolidaysCell.h"
#import "UIViewController+navigation.h"
#import "NSDate+daysleft.h"
#import "A3HolidaysFlickrDownloadManager.h"
#import "DKLiveBlurView.h"

typedef NS_ENUM(NSInteger, HolidaysTableHeaderViewComponent) {
	HolidaysHeaderViewSegmentedControl = 1000,
	HolidaysHeaderViewYearLabel,
	HolidaysHeaderViewNameLabel,
	HolidaysHeaderViewDaysLeftLabel,
	HolidaysHeaderViewCountryLabel
};


@interface A3HolidaysPageContentViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *holidays;
@property (nonatomic, strong) DKLiveBlurView *imageView;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation A3HolidaysPageContentViewController {
	NSInteger _thisYear;
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

- (void)setupThisYear {
	_thisYear = [HolidayData thisYear];
    _holidays = nil;
	NSUInteger index = [self upcomingFirstHoliday];
	if (index == NSNotFound) {
		_thisYear++;
		_holidays = nil;
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.view.clipsToBounds = YES;
	self.automaticallyAdjustsScrollViewInsets = NO;

	[self setupImageView];
	[self setupBottomGradientView];
	[self setupTableView];
    
    FNLOG();
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

	[[A3HolidaysFlickrDownloadManager sharedInstance] addDownloadTaskForCountryCode:_countryCode];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageDownloaded:) name:A3HolidaysFlickrDownloadManagerDownloadComplete object:[A3HolidaysFlickrDownloadManager sharedInstance]];
}

- (void)imageDownloaded:(NSNotification *)notification {
	if ([notification.userInfo[@"CountryCode"] isEqualToString:_countryCode]) {
		_imageView.originalImage = [[A3HolidaysFlickrDownloadManager sharedInstance] imageForCountryCode:_countryCode orientation:CURRENT_ORIENTATION forList:NO];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if (self.isMovingFromParentViewController) {
		[self.imageView setScrollView:nil];
	} else {
		_previousOrientation = CURRENT_ORIENTATION;
	}
}

- (void)dealloc {
	[_imageView setScrollView:nil];
}

- (void)reloadDataRedrawImage:(BOOL)redrawImage {
	[self setupThisYear];
	[self updateTableHeaderView:_tableView.tableHeaderView];
	[self.tableView reloadData];
	if (redrawImage) {
		_imageView.originalImage = [[A3HolidaysFlickrDownloadManager sharedInstance] imageForCountryCode:_countryCode orientation:CURRENT_ORIENTATION forList:NO];
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

	self.tableView.tableHeaderView = [self tableHeaderViewForInterfaceOrientation:toInterfaceOrientation];

	_imageView.originalImage = [[A3HolidaysFlickrDownloadManager sharedInstance] imageForCountryCode:_countryCode orientation:toInterfaceOrientation forList:NO];
}

- (void)setupBottomGradientView {
	A3GradientView *gradientView = [A3GradientView new];
	gradientView.gradientColors = @[
			(id)[UIColor colorWithWhite:0.0 alpha:0.0].CGColor,
			(id)[UIColor colorWithWhite:0.0 alpha:1.0].CGColor
	];

	[self.view addSubview:gradientView];

	[gradientView makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(self.view.bottom).with.offset(-150);
		make.left.equalTo(self.view.left);
		make.right.equalTo(self.view.right);
		make.bottom.equalTo(self.view.bottom);
	}];
}

- (void)setupImageView {
	_imageView = [DKLiveBlurView new];
	_imageView.userInteractionEnabled = NO;
	[self.view addSubview:_imageView];

	CGFloat interpolationFactor = 10;

	[_imageView makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(-interpolationFactor, -interpolationFactor, -interpolationFactor, -interpolationFactor));
	}];

	_imageView.image = [[A3HolidaysFlickrDownloadManager sharedInstance] imageForCountryCode:_countryCode orientation:CURRENT_ORIENTATION forList:NO];

	UIInterpolatingMotionEffect *interpolationHorizontal = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
	interpolationHorizontal.minimumRelativeValue = @(-interpolationFactor);
	interpolationHorizontal.maximumRelativeValue = @(interpolationFactor);

	UIInterpolatingMotionEffect *interpolationVertical = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
	interpolationVertical.minimumRelativeValue = @(-interpolationFactor);
	interpolationVertical.maximumRelativeValue = @(interpolationFactor);

	[_imageView addMotionEffect:interpolationHorizontal];
	[_imageView addMotionEffect:interpolationVertical];
    _imageView.originalImage = [[A3HolidaysFlickrDownloadManager sharedInstance] imageForCountryCode:_countryCode orientation:CURRENT_ORIENTATION forList:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

static NSString *const CellIdentifier = @"holidaysCell";

- (void)setupTableView {
	[self.view addSubview:self.tableView];

	[_tableView makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 54, 0));
	}];
    
    [self updateTableHeaderView:_tableView.tableHeaderView];

	[self.imageView setScrollView:_tableView];
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
	FNLOG(@"%d, %f, %f", _tableView.tag, footerViewHeight, screenBounds.size.height);
	if (footerViewHeight > 0) {
		UIView *tableFooterView = [UIView new];
		tableFooterView.frame = CGRectMake(0, 0, _tableView.bounds.size.width, footerViewHeight);
		return tableFooterView;
	}
	return nil;
}

- (UIView *)tableHeaderViewForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	UIView *headerView = [UIView new];

	CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];

	CGFloat viewHeight = screenBounds.size.height;
	viewHeight += 97.0;
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
		make.left.equalTo(headerView.left).with.offset(IS_IPHONE ? 10 : 28);
		make.right.equalTo(headerView.right).with.offset(IS_IPHONE ? -10 : -28);
		make.bottom.equalTo(yearBorderView.top).with.offset(IS_IPHONE ? -62 : -124);
	}];

	FXLabel *daysLeftLabel = [FXLabel new];
	daysLeftLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-M3" size:17];
	daysLeftLabel.tag = HolidaysHeaderViewDaysLeftLabel;
	daysLeftLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.6];
	daysLeftLabel.textAlignment = NSTextAlignmentCenter;
	[self setupShadow:daysLeftLabel];
	[headerView addSubview:daysLeftLabel];

	[daysLeftLabel makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(headerView.left).with.offset(IS_IPHONE ? 10 : 28);
		make.right.equalTo(headerView.right).with.offset(IS_IPHONE ? -10 : -28);
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
		make.left.equalTo(headerView.left).with.offset(IS_IPHONE ? 10 : 28);
		make.right.equalTo(headerView.right).with.offset(IS_IPHONE ? -10 : -28);
		make.bottom.equalTo(daysLeftLabel.top).with.offset(-9);
	}];

	[self updateTableHeaderView:headerView];
	[headerView layoutIfNeeded];

	return headerView;
}

- (void)setupShadow:(FXLabel *)label {
	label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.25];
	label.shadowOffset = CGSizeMake(0, 2);
	label.shadowBlur = 5;
}

- (void)updateTableHeaderView {
	[self updateTableHeaderView:_tableView.tableHeaderView];
}

- (void)updateTableHeaderView:(UIView *)headerView {
	UILabel *yearLabel = (UILabel *) [headerView viewWithTag:HolidaysHeaderViewYearLabel];
	yearLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
	yearLabel.text = [NSString stringWithFormat:@"%d", _thisYear];

	UILabel *countryNameLabel = (UILabel *) [headerView viewWithTag:HolidaysHeaderViewCountryLabel];
	countryNameLabel.text = [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:self.countryCode];

	NSUInteger myPosition = [self upcomingFirstHoliday];

	if (myPosition != NSNotFound) {
		NSArray *holidaysInPage = self.holidays;
		NSDictionary *upcomingHoliday = holidaysInPage[myPosition];
		UILabel *nameLabel = (UILabel *)[headerView viewWithTag:HolidaysHeaderViewNameLabel];
		nameLabel.text = upcomingHoliday[kHolidayName];

		UILabel *daysLeftLabel = (UILabel *)[headerView viewWithTag:HolidaysHeaderViewDaysLeftLabel];
		daysLeftLabel.text = [upcomingHoliday[kHolidayDate] daysLeft];

		A3FSegmentedControl *segmentedControl = (A3FSegmentedControl *) [headerView viewWithTag:HolidaysHeaderViewSegmentedControl];
		segmentedControl.items = @[
				[NSString stringWithFormat:@"Upcoming %d", [holidaysInPage count] - myPosition],
				[NSString stringWithFormat:@"Past %d", myPosition]
		];
		FNLOG(@"%d + %d = %d : %d", [holidaysInPage count] - myPosition, myPosition, myPosition + [holidaysInPage count] - myPosition + 1, [holidaysInPage count]);
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
			[NSString stringWithFormat:@"Upcoming %d", upcoming],
			[NSString stringWithFormat:@"Past %d", past]
	];
	self.tableView.tableFooterView = [self tableFooterView];
	[self.tableView reloadData];
}

- (void)prevYearButtonAction {
	UILabel *yearLabel = (UILabel *) [self.tableView.tableHeaderView viewWithTag:HolidaysHeaderViewYearLabel];
	NSUInteger year = [yearLabel.text integerValue] - 1;
	HolidayData *data = [[HolidayData alloc] init];
	NSArray *array = [data holidaysForCountry:self.countryCode year:year fullSet:YES];
	if (array) {
		yearLabel.text = [NSString stringWithFormat:@"%d", year];
		[self reloadDataWithYear:year];
		[self scrollToRightPosition:_tableView enforceToMiddle:YES animated:NO];
	} else {
		[self alertNotAvailableYear:year];
	}
}

- (void)alertNotAvailableYear:(NSUInteger)year {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"Holidays for year %d is not available.", year] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
}

- (void)nextYearButtonAction {
	UILabel *yearLabel = (UILabel *) [self.tableView.tableHeaderView viewWithTag:HolidaysHeaderViewYearLabel];
	NSUInteger year = [yearLabel.text integerValue] + 1;
	HolidayData *data = [HolidayData new];
	NSArray *array = [data holidaysForCountry:self.countryCode year:year fullSet:YES];
	if (array) {
		yearLabel.text = [NSString stringWithFormat:@"%d", year];
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
		}

		NSDictionary *cellData = [self holidayDataForTableView:tableView row:indexPath.row];

		BOOL longName = [self needDoubleLineCellWithData:cellData];
		BOOL showLunar = [HolidayData needToShowLunarDatesForCountryCode:self.countryCode];

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

		NSDateFormatter *df = [HolidayData dateFormatter];
		holidayCell.titleLabel.text = cellData[kHolidayName];
		holidayCell.dateLabel.text = [df stringFromDate: cellData[kHolidayDate] ];
		[holidayCell.publicMarkView setHidden:![cellData[kHolidayIsPublic] boolValue]];
		[holidayCell.publicLabel setHidden:![cellData[kHolidayIsPublic] boolValue]];

		if (showLunar) {
			BOOL isKorean = [self.countryCode isEqualToString:@"kr"];
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	FNLOG(@"%f", scrollView.contentOffset.y);
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

@end
