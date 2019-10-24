//
//  A3PedometerViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/10/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import <HealthKit/HealthKit.h>
#import "A3PedometerViewController.h"
#import "A3DashLineView.h"
#import "A3AppDelegate.h"
#import "Pedometer.h"
#import "A3PedometerCollectionViewCell.h"
#import "A3PedometerHandler.h"
#import "UIViewController+A3Addition.h"
#import "A3PedometerSettingsTableViewController.h"
#import "NSDate-Utilities.h"
#import "NSDateFormatter+A3Addition.h"

NSString *const A3PedometerSettingsDidSearchHealthStore = @"A3PedometerSettingsDidSearchHealthStore";
NSString *const A3PedometerNumberOfTimesDidShowScrollHelp = @"A3PedometerNumberOfTimesDidShowScrollHelp";

typedef NS_ENUM(NSInteger, A3PedometerQueryType) {
	A3PedometerQueryTypeStepCount,
	A3PedometerQueryTypeDistance,
	A3PedometerQueryTypeFlightsClimbed
};

@interface A3PedometerViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UIView *stepsBackgroundView;
@property (nonatomic, weak) IBOutlet UILabel *stepsLabel;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *floorsAscended;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UIButton *settingsButton;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *distanceLabelCenterYConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *floorsAscendedLabelCenterYConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *customNavigationBarHeightConstraint;

@property (nonatomic, strong) CMPedometer *pedometer;
@property (nonatomic, strong) NSDateFormatter *searchDateFormatter;
@property (nonatomic, strong) NSArray *pedometerItems;
@property (nonatomic, strong) NSDateFormatter *dateFormatterForCell;
@property (nonatomic, strong) NSString *monthDateFormat;
@property (nonatomic, strong) A3PedometerHandler *pedometerHandler;
@property (nonatomic, strong) HKHealthStore *healthStore;
@property (nonatomic, strong) NSTimer *scrollHelperTimer;

@end

@implementation A3PedometerViewController {
	BOOL _collectionViewBackgroundDidSet;
	BOOL _viewWillAppearDidRun;
	NSInteger _numberOfCellsDidAnimate;
	BOOL _viewDidAppearDidRun;
	BOOL _userLeftToVisitSettings;
	NSInteger _remainingNumbersScrollAnimation;
	BOOL _healthStoreAuthorizationAlertDone;
	BOOL _healthStoreUpdateInProgress;
	BOOL _didRefreshAfterSignificantTimeChange;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self purgeInvalidData];
    
	[[NSUserDefaults standardUserDefaults] registerDefaults:@{A3PedometerSettingsNumberOfGoalSteps:@10000}];

	[self makeBackButtonEmptyArrow];

	[_settingsButton setImage:[[UIImage imageNamed:@"general"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
					 forState:UIControlStateNormal];
	_settingsButton.tintColor = [UIColor whiteColor];
	
	_collectionView.backgroundColor = [UIColor whiteColor];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
	_remainingNumbersScrollAnimation = 2;

	CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	if (!IS_IOS9) {
		if (screenBounds.size.width == 320.0) {
			_stepsLabel.font = [UIFont boldSystemFontOfSize:60];
		} else {
			_stepsLabel.font = [UIFont boldSystemFontOfSize:70];
		}
		_distanceLabelCenterYConstraint.constant = -12;
		_floorsAscendedLabelCenterYConstraint.constant = 12;
	} else {
		if (screenBounds.size.width == 320.0) {
			_stepsLabel.font = [UIFont boldSystemFontOfSize:60];
			_distanceLabelCenterYConstraint.constant = -12;
			_floorsAscendedLabelCenterYConstraint.constant = 12;
		}
	}
	
    if (screenBounds.size.height == 812 || screenBounds.size.height == 896) {
        _customNavigationBarHeightConstraint.constant = 84;
    }
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartPedometerUpdate) name:UIApplicationSignificantTimeChangeNotification object:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)applicationDidBecomeActive {
}

- (void)restartPedometerUpdate {
	_didRefreshAfterSignificantTimeChange = NO;
	[self.pedometer stopPedometerUpdates];
	[self startUpdatePedometer];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

#if TARGET_IPHONE_SIMULATOR
	[self setupTestData];
	[self fillMissingDatesCompletion:NULL];
#endif
	
	[self setupCollectionViewBackgroundView];
	[self updateToday];
	if ([self.pedometerItems count]) {
		[self scrollToTodayAnimated:NO];
	}

	[self.navigationController setNavigationBarHidden:YES];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	
	if (!_viewWillAppearDidRun) {
		_viewWillAppearDidRun = YES;

		FNLOG();
		[self refreshPedometerData:^{
			dispatch_async(dispatch_get_main_queue(), ^{
				[self refreshStepsFromHealthStoreCompletion:NULL];
			});
		}];
	}
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];

	if (!_collectionViewBackgroundDidSet) {
		
		_collectionViewBackgroundDidSet = YES;
		[self setupCollectionViewBackgroundView];

		if ([self.pedometerItems count]) {
			[self scrollToTodayAnimated:NO];
		}
	}
}

- (void)setupCollectionViewBackgroundView {
	UIView *collectionViewBackgroundView = [[UIView alloc] initWithFrame:_collectionView.bounds];
	collectionViewBackgroundView.backgroundColor = [UIColor whiteColor];
	A3DashLineView *dashLineView = [[A3DashLineView alloc] initWithFrame:CGRectZero];
	[collectionViewBackgroundView addSubview:dashLineView];

	CGRect bounds = _collectionView.bounds;
	CGFloat goalSize = (bounds.size.height - 35)/1.2;
	CGFloat dashPosition = bounds.size.height - goalSize - 35;
	[dashLineView makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(collectionViewBackgroundView.left);
		make.right.equalTo(collectionViewBackgroundView.right);
		make.top.equalTo(collectionViewBackgroundView.top).with.offset(dashPosition);
		make.height.equalTo(@2);
	}];

	CGFloat separatorSpace = goalSize / 4;
	[self addSeparatorToView:collectionViewBackgroundView atPosition:dashPosition + separatorSpace];
	[self addSeparatorToView:collectionViewBackgroundView atPosition:dashPosition + separatorSpace * 2];
	[self addSeparatorToView:collectionViewBackgroundView atPosition:dashPosition + separatorSpace * 3];

	_collectionView.backgroundView = collectionViewBackgroundView;
}

- (void)addSeparatorToView:(UIView *)view atPosition:(CGFloat)position {
	A3DashLineView *separator = [A3DashLineView new];
	separator.lineColor = [UIColor lightGrayColor];
	[view addSubview:separator];

	[separator makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(view.left);
		make.right.equalTo(view.right);
		make.top.equalTo(view.top).with.offset(position);
		make.height.equalTo(@(1.0 / [[UIScreen mainScreen] scale]));
	}];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	for (A3PedometerCollectionViewCell *cell in _collectionView.visibleCells) {
		[cell animateBarCompletion:nil];
	}

	if (!_viewDidAppearDidRun) {
		_viewDidAppearDidRun = YES;

		NSInteger numberOfTimes = [[NSUserDefaults standardUserDefaults] integerForKey:A3PedometerNumberOfTimesDidShowScrollHelp];
		if (numberOfTimes < 3) {
			[[NSUserDefaults standardUserDefaults] setInteger:numberOfTimes + 1 forKey:A3PedometerNumberOfTimesDidShowScrollHelp];
			
			if (!_scrollHelperTimer) {
				_scrollHelperTimer = [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(animateScroll) userInfo:nil repeats:YES];
			}
		}
	}
}

- (void)animateScroll {
	if (_remainingNumbersScrollAnimation <= 0) {
		[_scrollHelperTimer invalidate];
		_scrollHelperTimer = nil;
		return;
	}
	
	CGPoint originalOffset = _collectionView.contentOffset;
	[UIView animateWithDuration:0.4 animations:^{
		[_collectionView setContentOffset:CGPointMake(originalOffset.x - 35, originalOffset.y)];
	} completion:^(BOOL finished) {
		double delayInSeconds = 0.3;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			[_collectionView setContentOffset:originalOffset animated:YES];
		});
	}];
	_remainingNumbersScrollAnimation--;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareClose {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationSignificantTimeChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
	[self.pedometer stopPedometerUpdates];
	self.pedometer = nil;
}

- (void)dealloc {
	[self prepareClose];
}

- (IBAction)appsButtonAction:(UIButton *)button {
	if (IS_IPHONE) {
		if ([[A3AppDelegate instance] isMainMenuStyleList]) {
			[[A3AppDelegate instance].drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
		} else {
			[self prepareClose];
			
			UINavigationController *navigationController = [A3AppDelegate instance].currentMainNavigationController;
			[navigationController popViewControllerAnimated:YES];
			[navigationController setToolbarHidden:YES];
		}
	} else {
		[[[A3AppDelegate instance] rootViewController_iPad] toggleLeftMenuViewOnOff];
	}
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [self.pedometerItems count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	Pedometer *pedometerItem = self.pedometerItems[indexPath.row];
	A3PedometerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"pedometerCell" forIndexPath:indexPath];
	cell.pedometerHandler = self.pedometerHandler;
	cell.collectionView = self.collectionView;
	[cell setPedometerData:pedometerItem];
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
	A3PedometerCollectionViewCell *pedometerCell = (A3PedometerCollectionViewCell *) cell;
	UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *) collectionView.collectionViewLayout;
	BOOL showMonth = NO;
	NSDate *date = [self.searchDateFormatter dateFromString:pedometerCell.pedometerData.date];
	if (indexPath.row >= [self.pedometerItems count] - 7) {
		self.dateFormatterForCell.dateFormat = @"EEE";
		if (!_viewDidAppearDidRun) {
			[pedometerCell prepareAnimate];
		}
	} else {
		CGFloat coordinateInScreen = cell.frame.origin.x - _collectionView.contentOffset.x;
		if ((coordinateInScreen >= -10.0) && (coordinateInScreen < (flowLayout.itemSize.width + flowLayout.minimumInteritemSpacing - 5))) {
			showMonth = YES;
		}
		if ([[NSCalendar currentCalendar] ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date] == 1) {
			showMonth = YES;
		}
		if (showMonth) {
			self.dateFormatterForCell.dateFormat = self.monthDateFormat;
		} else {
			self.dateFormatterForCell.dateFormat = @"d";
		}
	}
	pedometerCell.dateLabel.text = [_dateFormatterForCell stringFromDate:date];
}

- (NSString *)monthDateFormat {
	if (!_monthDateFormat) {
		[self.dateFormatterForCell setDateStyle:NSDateFormatterMediumStyle];
		_monthDateFormat = [_dateFormatterForCell formatStringByRemovingYearComponent:_dateFormatterForCell.dateFormat];
		_monthDateFormat = [_monthDateFormat stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		_monthDateFormat = [_monthDateFormat stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@",-/."]];
	}
	return _monthDateFormat;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//	[_collectionView reloadData];
//	
	_descriptionLabel.hidden = (_collectionView.contentOffset.x + _collectionView.bounds.size.width + 30) < _collectionView.contentSize.width;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	if (_scrollHelperTimer) {
		[_scrollHelperTimer invalidate];
		_scrollHelperTimer = nil;
	}
}

- (void)scrollToTodayAnimated:(BOOL)animated {
	[_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[self.pedometerItems count] - 1 inSection:0]
							atScrollPosition:UICollectionViewScrollPositionRight
									animated:animated];
}

#pragma mark - Data Gathering

- (void)refreshPedometerData:(void (^)(void))completion {
	FNLOG();
	
	if ([CMPedometer isStepCountingAvailable]) {
		NSCalendar *calendar = [NSCalendar currentCalendar];
		NSDate *date = [NSDate date];
		NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
		// TODO: Daylight Saving 관련 수정해야 할 부분
		dateComponents.hour = 12;
		NSMutableArray<NSDate *> *datesArray = [NSMutableArray new];
		for (NSInteger idx = 0; idx < 7; idx++) {
			date = [calendar dateFromComponents:dateComponents];
			[datesArray addObject:date];
			dateComponents.day--;
		}

		[self updatePedometerForDateArray:datesArray completion:^{
			_pedometerItems = nil;
			
			FNLOG(@"[self.collectionView reloadData];");
			[_collectionView reloadData];
			[self updateToday];
			
			[self scrollToTodayAnimated:YES];
			
			[self startUpdatePedometer];
			
			[self fillMissingDatesCompletion:^{
				if (completion) {
					completion();
				}
			}];
		}];
	}
}

- (void)updatePedometerForDateArray:(NSMutableArray *)dateArray completion:(void(^)(void))completion {
	if (![dateArray count]) return;

	NSDate *queryDate = [dateArray lastObject];

	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:queryDate];
	components.hour = 0;
	NSDate *fromDate = [calendar dateFromComponents:components];

	NSDate *toDate = [fromDate dateByAddingDays:1];

	[self.pedometer queryPedometerDataFromDate:fromDate toDate:toDate withHandler:^(CMPedometerData *pedometerData, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (error) {
				if (error.code == CMErrorMotionActivityNotAuthorized) {
					[self alertMotionActivityNotAuthorized];
				}
				return;
			}
			NSManagedObjectContext *savingContext = [NSManagedObjectContext MR_rootSavingContext];
			
			Pedometer *pedometerItem = [Pedometer MR_findFirstByAttribute:@"date" withValue:[self.searchDateFormatter stringFromDate:queryDate] inContext:savingContext];
			if (!pedometerItem) {
				pedometerItem = [Pedometer MR_createEntityInContext:savingContext];
				pedometerItem.uniqueID = [[NSUUID UUID] UUIDString];
			}
			
			pedometerItem.date = [self.searchDateFormatter stringFromDate:queryDate];
			
			[self mergeValuesFromCoreMotion:pedometerData to:pedometerItem];
			
			[dateArray removeLastObject];
			if ([dateArray count]) {
				[self updatePedometerForDateArray:dateArray completion:completion];
			} else {
				[savingContext MR_saveOnlySelfAndWait];
				if (completion) {
					completion();
				}
			}
		});
	}];
}

- (void)mergeValuesFromCoreMotion:(CMPedometerData *)pedometerData to:(Pedometer *)pedometerItem {
	if ([pedometerData.distance doubleValue] > [pedometerItem.distance doubleValue]) {
		pedometerItem.distance = pedometerData.distance;
	}
	if ([pedometerData.numberOfSteps doubleValue] > [pedometerItem.numberOfSteps doubleValue]) {
		pedometerItem.numberOfSteps = pedometerData.numberOfSteps;
	}
	if ([pedometerData.floorsAscended doubleValue] > [pedometerItem.floorsAscended doubleValue]) {
		pedometerItem.floorsAscended = pedometerData.floorsAscended;
	}
	if ([pedometerData.floorsDescended doubleValue] > [pedometerItem.floorsDescended doubleValue]) {
		pedometerItem.floorsDescended = pedometerData.floorsDescended;
	}
}

- (void)alertMotionActivityNotAuthorized {
	if (_userLeftToVisitSettings) {
		_userLeftToVisitSettings = NO;
		return;
	}
	UIAlertView *alertView;
	alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
										   message:NSLocalizedString(@"In order for AppBox Pro to collect step counts, it needs to be given permission in the device Settings app.", @"In order for AppBox Pro to collect step counts, it needs to be given permission in the device Settings app.")
										  delegate:self
								 cancelButtonTitle:NSLocalizedString(@"Open Settings", @"Open Settings")
								 otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
	alertView.tag = 3000;
	[alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 1000) {
		[self requestAuthorizationForHealthStore];
		return;
	}
	if (alertView.tag == 3000) {
		if (buttonIndex == alertView.cancelButtonIndex) {
			NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
			[[UIApplication sharedApplication] openURL:url];
			_userLeftToVisitSettings = YES;
		}
	}
}

- (void)fillMissingDatesCompletion:(void (^)(void))completion {
	NSManagedObjectContext *savingContext = [NSManagedObjectContext MR_rootSavingContext];
	Pedometer *pedometerItem = [Pedometer MR_findFirstOrderedByAttribute:@"date" ascending:YES inContext:savingContext];
	NSString *todayDate = [self.searchDateFormatter stringFromDate:[NSDate date]];
	NSCalendar *calendar = [NSCalendar currentCalendar];
	while ([pedometerItem.date compare:todayDate] == NSOrderedAscending) {
		@autoreleasepool {
			NSDate *date = [_searchDateFormatter dateFromString:pedometerItem.date];
			NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
			components.day += 1;
			date = [calendar dateFromComponents:components];
			NSString *dateString = [_searchDateFormatter stringFromDate:date];
			if (![dateString isEqualToString:todayDate]) {
				pedometerItem = [Pedometer MR_findFirstByAttribute:@"date" withValue:dateString inContext:savingContext];
				if (!pedometerItem) {
					pedometerItem = [Pedometer MR_createEntityInContext:savingContext];
					pedometerItem.uniqueID = [[NSUUID UUID] UUIDString];
					pedometerItem.date = dateString;
				}
			} else {
				break;
			}
		}
	}
	if ([savingContext hasChanges]) {
		[savingContext MR_saveOnlySelfAndWait];
		_pedometerItems = nil;
		[_collectionView reloadData];
	}
	if (completion) {
		completion();
	}
}

- (void)startUpdatePedometer {
	NSDate *today = [NSDate date];
	NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:today];
	components.hour = 0;
	today = [[NSCalendar currentCalendar] dateFromComponents:components];
	[self.pedometer startPedometerUpdatesFromDate:today withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
		if (!error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				NSString *todayString = [self.searchDateFormatter stringFromDate:today];
				NSManagedObjectContext *savingContext = [NSManagedObjectContext MR_rootSavingContext];
				Pedometer *pedometerItem = [Pedometer MR_findFirstByAttribute:@"date" withValue:todayString inContext:savingContext];
				if (!pedometerItem) {
					pedometerItem = [Pedometer MR_createEntityInContext:savingContext];
					pedometerItem.uniqueID = [[NSUUID UUID] UUIDString];
				}
				pedometerItem.date = todayString;
				[self mergeValuesFromCoreMotion:pedometerData to:pedometerItem];
				
				[savingContext MR_saveOnlySelfAndWait];
				
				_pedometerItems = nil;
				[_collectionView reloadData];
				
				if (!_didRefreshAfterSignificantTimeChange) {
					_didRefreshAfterSignificantTimeChange = YES;
					
					[self scrollToTodayAnimated:YES];
				}
				
				[self updateToday];
			});
		} else {
			FNLOG(@"%@", error.localizedDescription);
		}
	}];
}

- (CMPedometer *)pedometer {
	if (!_pedometer) {
		_pedometer = [CMPedometer new];
	}
	return _pedometer;
}

- (NSDateFormatter *)searchDateFormatter {
	if (!_searchDateFormatter) {
		_searchDateFormatter = [NSDateFormatter new];
		[_searchDateFormatter setDateFormat:@"yyyy-MM-dd"];
	}
	return _searchDateFormatter;
}

- (NSArray *)pedometerItems {
	if (!_pedometerItems) {
		_pedometerItems = [Pedometer MR_findAllSortedBy:@"date" ascending:YES];
	}
	return _pedometerItems;
}

- (NSDateFormatter *)dateFormatterForCell {
	if (!_dateFormatterForCell) {
		_dateFormatterForCell = [NSDateFormatter new];
	}
	return _dateFormatterForCell;
}

#if TARGET_IPHONE_SIMULATOR
- (void)setupTestData {
	NSArray *testData = @[
						  @[@"2016-05-20", @2453, @4, @1900],
                          @[@"2016-05-21", @886000, @9, @6200],
                          @[@"2016-05-22", @3841, @8, @2800],
                          @[@"2016-05-23", @26522, @11, @19700],
                          @[@"2016-05-24", @455400, @13, @3300],
                          @[@"2016-05-25", @6858, @4, @4300],
                          @[@"2016-05-26", @104960, @99, @7100],
						  ];

    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    components.day -= 7;
    
	NSManagedObjectContext *savingContext = [NSManagedObjectContext MR_rootSavingContext];
	for (NSArray *item in testData) {
        NSDate *date = [calendar dateFromComponents:components];
        components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
        NSString *dateString = [NSString stringWithFormat:@"%ld-%02ld-%02ld", components.year, components.month, components.day];
		Pedometer *pedometer = [Pedometer MR_findFirstByAttribute:@"date" withValue:dateString inContext:savingContext];
		if (!pedometer) {
			pedometer = [Pedometer MR_createEntityInContext:savingContext];
			pedometer.uniqueID = [[NSUUID UUID] UUIDString];
            pedometer.date = dateString;
            pedometer.numberOfSteps = item[1];
            pedometer.floorsAscended = item[2];
            pedometer.distance = item[3];
		}
        components.day += 1;
	}
	[savingContext MR_saveOnlySelfAndWait];
}
#endif

- (void)updateToday {
	NSString *today = [self.searchDateFormatter stringFromDate:[NSDate date]];
	Pedometer *pedometerData = [Pedometer MR_findFirstByAttribute:@"date" withValue:today];
	NSDictionary *distanceInfo;
	NSString *floorsAscended;
	if (pedometerData) {
		CGFloat goalSteps = [[NSUserDefaults standardUserDefaults] floatForKey:A3PedometerSettingsNumberOfGoalSteps];
		CGFloat percent = MIN(1.2,[pedometerData.numberOfSteps floatValue] / goalSteps);
		UIColor *color = [self.pedometerHandler colorForPercent:percent];
		_stepsBackgroundView.backgroundColor = color;
		_stepsLabel.text = [self.pedometerHandler.integerFormatter stringFromNumber:pedometerData.numberOfSteps ?: @0];
		floorsAscended = [self.pedometerHandler.integerFormatter stringFromNumber:pedometerData.floorsAscended ?: @0];
		distanceInfo = [self.pedometerHandler distanceValueForMeasurementSystemFromDistance:pedometerData.distance ?: @0];
	} else {
		UIColor *color = [self.pedometerHandler colorForPercent:0];
		_stepsBackgroundView.backgroundColor = color;
		_stepsLabel.text = [self.pedometerHandler.integerFormatter stringFromNumber:@0];
		floorsAscended = [self.pedometerHandler.integerFormatter stringFromNumber:@0];
		distanceInfo = [self.pedometerHandler distanceValueForMeasurementSystemFromDistance:@0];
	}
	NSDictionary *valueAttribute;
	NSDictionary *unitAttribute;
	CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	if (screenBounds.size.width == 320) {
		valueAttribute = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:21],
				NSForegroundColorAttributeName:[UIColor whiteColor]};
		unitAttribute = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:12],
				NSForegroundColorAttributeName:[UIColor whiteColor]};
	} else {
		valueAttribute = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:24],
				NSForegroundColorAttributeName:[UIColor whiteColor]};
		unitAttribute = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:15],
				NSForegroundColorAttributeName:[UIColor whiteColor]};
	}

	NSMutableAttributedString *floorsAscendedAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", floorsAscended]
																									   attributes:valueAttribute];
	NSAttributedString *floorUnitAttributedString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"floors", @"floors") attributes:unitAttribute];
	[floorsAscendedAttributedString appendAttributedString:floorUnitAttributedString];
	_floorsAscended.attributedText = floorsAscendedAttributedString;

	NSMutableAttributedString *distanceAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", distanceInfo[@"value"]]
																						 attributes:valueAttribute];
	NSAttributedString *unitString = [[NSAttributedString alloc] initWithString:distanceInfo[@"unit"]
																	 attributes:unitAttribute];
	[distanceAttributedString appendAttributedString:unitString];
	_distanceLabel.attributedText = distanceAttributedString;
	[self updateAverage];
}

- (A3PedometerHandler *)pedometerHandler {
	if (!_pedometerHandler) {
		_pedometerHandler = [A3PedometerHandler new];
	}
	return _pedometerHandler;
}

- (void)updateAverage {
	NSArray *array = [Pedometer MR_findAllSortedBy:@"date" ascending:NO];
	double averageSteps = 0;
	double averageDistance = 0;
	double averageFloorsAscended = 0;

	for (NSInteger idx = 0; idx < MIN(7, [array count]); idx++) {
		Pedometer *data = array[idx];
		averageSteps += [data.numberOfSteps doubleValue];
		averageDistance += [data.distance doubleValue];
		averageFloorsAscended += [data.floorsAscended doubleValue];
	}

	averageSteps /= 7.0;
	averageDistance /= 7.0;
	averageFloorsAscended /= 7.0;

	_descriptionLabel.text = [NSString stringWithFormat:@"%@ %@%@  %@  %@%@",
					NSLocalizedString(@"Daily Average", @"Daily Average"),
														[self.pedometerHandler.integerFormatter stringFromNumber:@(averageSteps)],
					NSLocalizedString(@"steps", @"steps"),
														[[self.pedometerHandler stringFromDistance:@(averageDistance)] stringByReplacingOccurrencesOfString:@" " withString:@""],
														[self.pedometerHandler.integerFormatter stringFromNumber:@(averageFloorsAscended)],
					NSLocalizedString(@"floors", @"floors")
	];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	[super prepareForSegue:segue sender:sender];

	UINavigationController *navigationController = [segue destinationViewController];
	A3PedometerSettingsTableViewController *viewController = navigationController.viewControllers[0];
	viewController.title = @"Settings";
	viewController.pedometerHandler = self.pedometerHandler;
}

#pragma mark - HKHealthStore

- (HKHealthStore *)healthStore {
	if (!_healthStore) {
		_healthStore = [HKHealthStore new];
	}
	return _healthStore;
}

- (void)requestAuthorizationForHealthStore {
	HKQuantityType *stepsType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
	HKQuantityType *distanceType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
	HKQuantityType *flightAscended = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed];
	
	NSSet *readDataSet = [NSSet setWithObjects:stepsType, distanceType, flightAscended, nil];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

	[self.healthStore requestAuthorizationToShareTypes:nil
											 readTypes:readDataSet
											completion:^(BOOL success, NSError *error) {
												dispatch_async(dispatch_get_main_queue(), ^{
													[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
													if (success) {
														[self refreshStepsFromHealthStoreCompletion:NULL];
													}
												});
											}];
}

- (void)alertAppWillRequestAuthorization {
	double delayInSeconds = 0.3;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", nil)
															message:NSLocalizedString(@"HealthKitAlert", nil)
														   delegate:self
												  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
												  otherButtonTitles:nil];
		alertView.tag = 1000;
		[alertView show];
	});
}

- (void)refreshStepsFromHealthStoreCompletion:(void (^)(void))completion {
	FNLOG();
	if (_healthStoreUpdateInProgress) {
		return;
	}
	if (IS_IOS7 || ![HKHealthStore isHealthDataAvailable]) {
		if (completion) {
			completion();
		}
		return;
	}

	HKQuantityType *stepsType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];

	HKAuthorizationStatus authorizationStatus =	[self.healthStore authorizationStatusForType:stepsType];
	
	if (authorizationStatus == HKAuthorizationStatusNotDetermined) {
		if (!_healthStoreAuthorizationAlertDone) {
			_healthStoreAuthorizationAlertDone = YES;
			[self alertAppWillRequestAuthorization];
		}
		
		return;
	}
	_healthStoreUpdateInProgress = YES;

	BOOL showAlert = NO;
	if (![[NSUserDefaults standardUserDefaults] boolForKey:A3PedometerSettingsDidSearchHealthStore]) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:A3PedometerSettingsDidSearchHealthStore];
		showAlert = YES;
	}
	FNLOG(@"time log start");
	[self executeQueryFromHealthStoreForType:A3PedometerQueryTypeStepCount completion:^{
		[self executeQueryFromHealthStoreForType:A3PedometerQueryTypeDistance completion:^{
			[self executeQueryFromHealthStoreForType:A3PedometerQueryTypeFlightsClimbed completion:^{
				dispatch_async(dispatch_get_main_queue(), ^{
					FNLOG(@"time log end");

					_pedometerItems = nil;
					[_collectionView reloadData];
					[self updateToday];

					[self scrollToTodayAnimated:YES];

					if (showAlert) {
						[self alertImportResults];
					}
					if (completion) {
						completion();
					}
					_healthStoreUpdateInProgress = NO;
				});
			}];
		}];
	}];
}

- (void)executeQueryFromHealthStoreForType:(A3PedometerQueryType)type completion:(void (^)(void))completion {
	// TODO: Daylight Saving 관련 수정해야 할 부분
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
	dateComponents.hour = 0;
	NSDate *anchorDate = [calendar dateFromComponents:dateComponents];
	
	NSDateComponents *interval = [NSDateComponents new];
	interval.day = 1;

	HKQuantityType *quantityType;
	switch(type) {
		case A3PedometerQueryTypeStepCount:
			quantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
			break;
		case A3PedometerQueryTypeDistance:
			quantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
			break;
		case A3PedometerQueryTypeFlightsClimbed:
			quantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed];
			break;
	}

	HKStatisticsCollectionQuery *query =
			[[HKStatisticsCollectionQuery alloc]
					initWithQuantityType:quantityType
				 quantitySamplePredicate:nil
								 options:HKStatisticsOptionCumulativeSum
							  anchorDate:anchorDate
					  intervalComponents:interval];
	query.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *results, NSError *error) {
		if (error) {
			FNLOG(@"*** An error occurred while calculating the statistics: %@ ***",
					error.localizedDescription);
			return;
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			NSDate *endDate = [NSDate date];
			// TODO: Daylight saving 관련 수정해야 할 부분
			NSDate *startDate = [[endDate dateAtStartOfDay] dateByAddingDays:-1000];
			NSManagedObjectContext *savingContext = [NSManagedObjectContext MR_rootSavingContext];

			static BOOL dataFound;
			dataFound = NO;
			[results enumerateStatisticsFromDate:startDate toDate:endDate withBlock:^(HKStatistics *result, BOOL *stop) {
				HKQuantity *quantity = result.sumQuantity;
				double quantityValue;
				switch (type) {
					case A3PedometerQueryTypeStepCount:
						quantityValue = [quantity doubleValueForUnit:[HKUnit countUnit]];
						break;
					case A3PedometerQueryTypeDistance:
						quantityValue = [quantity doubleValueForUnit:[HKUnit meterUnit]];
						break;
					case A3PedometerQueryTypeFlightsClimbed:
						quantityValue = [quantity doubleValueForUnit:[HKUnit countUnit]];
						break;
				}
				
				if (!dataFound && quantityValue == 0) {
					return;
				}
				dataFound = YES;
				
				NSString *dateString = [self.searchDateFormatter stringFromDate:result.startDate];
				Pedometer *pedometerItem = [Pedometer MR_findFirstByAttribute:@"date" withValue:dateString inContext:[NSManagedObjectContext MR_rootSavingContext]];
				if (!pedometerItem) {
					pedometerItem = [Pedometer MR_createEntityInContext:savingContext];
					pedometerItem.uniqueID = [[NSUUID UUID] UUIDString];
					pedometerItem.date = dateString;
				}
				switch (type) {
					case A3PedometerQueryTypeStepCount:{
						pedometerItem.numberOfSteps = @(MIN(MAX(quantityValue, [pedometerItem.numberOfSteps doubleValue]),100000));
						break;
					}
					case A3PedometerQueryTypeDistance: {
						pedometerItem.distance = @(MIN(MAX(quantityValue, [pedometerItem.distance doubleValue]), 100000));
						break;
					}
					case A3PedometerQueryTypeFlightsClimbed:{
						pedometerItem.floorsAscended = @(MIN(MAX(quantityValue, [pedometerItem.floorsAscended doubleValue]), 100000));
						break;
					}
				}
			}];
			if ([savingContext hasChanges]) {
				[savingContext MR_saveOnlySelfAndWait];
			}
			if (completion) {
				completion();
			}
		});
	};
	[self.healthStore executeQuery:query];
}

- (void)alertImportResults {
	NSUInteger numberOfEntities = [Pedometer MR_countOfEntities];
	NSNumber *totalSteps = [Pedometer MR_aggregateOperation:@"sum:" onAttribute:@"numberOfSteps" withPredicate:nil];
	NSNumber *totalDistance = [Pedometer MR_aggregateOperation:@"sum:" onAttribute:@"distance" withPredicate:nil];
	NSNumber *totalFloorsAscended = [Pedometer MR_aggregateOperation:@"sum:" onAttribute:@"floorsAscended" withPredicate:nil];
	Pedometer *firstItem = [Pedometer MR_findFirstOrderedByAttribute:@"date" ascending:YES];

	NSDate *firstDate = [self.searchDateFormatter dateFromString:firstItem.date];
	NSString *dateFormatBefore = self.dateFormatterForCell.dateFormat;
	[self.dateFormatterForCell setDateStyle:NSDateFormatterMediumStyle];
	NSString *message = [NSString stringWithFormat:@"%@ %@ %@\n%@ %@\n%@\n%@ %@\n%@ %@",
						 NSLocalizedString(@"Total_Pedometer", @"Total_Pedometer"),
						 [self.pedometerHandler.integerFormatter stringFromNumber:@(numberOfEntities)],
						 NSLocalizedString(@"days", @"days"),
						 [self.pedometerHandler.integerFormatter stringFromNumber:totalSteps ?: @0],
						 NSLocalizedString(@"steps", @"steps"),
						 [self.pedometerHandler stringFromDistance:totalDistance],
						 [self.pedometerHandler.integerFormatter stringFromNumber:totalFloorsAscended],
						 NSLocalizedString(@"floors", @"floors"),
						 NSLocalizedString(@"Since_Pedometer", @"Since_Pedometer"),
						 [self.dateFormatterForCell stringFromDate:firstDate]
						 ];
	[self.dateFormatterForCell setDateFormat:dateFormatBefore];

	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Data Imported", @"Data Imported")
														message:message
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
											  otherButtonTitles:nil];
	[alertView show];
}

- (void)purgeInvalidData {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"numberOfSteps >= 100000"];
    NSManagedObjectContext *savingContext = [NSManagedObjectContext MR_rootSavingContext];
    NSArray *invalidItems = [Pedometer MR_findAllWithPredicate:predicate inContext:savingContext];
    if ([invalidItems count]) {
        for (Pedometer *item in invalidItems) {
            item.numberOfSteps = @0;
        }
        if ([savingContext hasChanges]) {
            [savingContext MR_saveOnlySelfAndWait];
        }
    }
}

@end
