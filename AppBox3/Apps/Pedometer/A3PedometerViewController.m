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

NSString *const A3PedometerSettingsDidSearchHealthStore = @"A3PedometerSettingsDidSearchHealthStore";

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
}

- (void)viewDidLoad {
    [super viewDidLoad];

#if TARGET_IPHONE_SIMULATOR
	[self setupTestData];
	[self fillMissingDates];
    [self updateToday];
#else
	[self refreshPedometerData];
#endif
	[[NSUserDefaults standardUserDefaults] registerDefaults:@{A3PedometerSettingsNumberOfGoalSteps:@10000}];

	[self makeBackButtonEmptyArrow];

	[_settingsButton setImage:[[UIImage imageNamed:@"general"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
					 forState:UIControlStateNormal];
	_settingsButton.tintColor = [UIColor whiteColor];
	
	_collectionView.backgroundColor = [UIColor whiteColor];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
	_remainingNumbersScrollAnimation = 2;
}

- (void)applicationDidBecomeActive {
	[self refreshPedometerData];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.navigationController setNavigationBarHidden:YES];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	if (!_viewWillAppearDidRun) {
		_viewWillAppearDidRun = YES;
	} else {
		[self setupCollectionViewBackgroundView];
		[_collectionView reloadData];
		[self updateToday];
	}
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];

	if (!_collectionViewBackgroundDidSet) {
		
		_collectionViewBackgroundDidSet = YES;
		[self setupCollectionViewBackgroundView];

		if ([self.pedometerItems count]) {
			[_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[self.pedometerItems count] - 1 inSection:0]
									atScrollPosition:UICollectionViewScrollPositionRight
											animated:NO];
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
		make.height.equalTo(@0.5);
	}];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	for (A3PedometerCollectionViewCell *cell in _collectionView.visibleCells) {
		[cell animateBarCompletion:nil];
	}
	if (!_viewDidAppearDidRun) {
		_viewDidAppearDidRun = YES;
		if (!_scrollHelperTimer) {
			_scrollHelperTimer = [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(animateScroll) userInfo:nil repeats:YES];
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
		_monthDateFormat = [_dateFormatterForCell.dateFormat stringByReplacingOccurrencesOfString:@"y" withString:@""];
		_monthDateFormat = [_monthDateFormat stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		_monthDateFormat = [_monthDateFormat stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@",-/."]];
	}
	return _monthDateFormat;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[_collectionView reloadData];
	
	_descriptionLabel.hidden = (_collectionView.contentOffset.x + _collectionView.bounds.size.width + 30) < _collectionView.contentSize.width;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	if (_scrollHelperTimer) {
		[_scrollHelperTimer invalidate];
		_scrollHelperTimer = nil;
	}
}

#pragma mark - Data Gathering

- (void)refreshPedometerData {
	if ([CMPedometer isStepCountingAvailable]) {
		NSCalendar *calendar = [NSCalendar currentCalendar];
		NSDate *date = [NSDate date];
		NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
		NSMutableArray<NSDate *> *datesArray = [NSMutableArray new];
		for (NSInteger idx = 0; idx < 7; idx++) {
			date = [calendar dateFromComponents:dateComponents];
			[datesArray addObject:date];
			dateComponents.day--;
		}

		[self updatePedometerForDateArray:datesArray completion:^{
			_pedometerItems = nil;
			[self.collectionView reloadData];
			[self updateToday];
			
			[_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[self.pedometerItems count] - 1 inSection:0]
									atScrollPosition:UICollectionViewScrollPositionRight
											animated:YES];
			
			[self startUpdatePedometer];
			dispatch_async(dispatch_get_main_queue(), ^{
				[self fillMissingDates];
			});
			[self refreshStepsFromHealthStore];
		}];
	}
}

- (void)updatePedometerForDateArray:(NSMutableArray *)dateArray completion:(void(^)(void))completion {
	if (![dateArray count]) return;

	NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[dateArray lastObject]];
	components.hour = 23;
	components.minute = 59;
	components.second = 59;
	NSDate *toDate = [[NSCalendar currentCalendar] dateFromComponents:components];

	[self.pedometer queryPedometerDataFromDate:[dateArray lastObject] toDate:toDate withHandler:^(CMPedometerData *pedometerData, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (error) {
				if (error.code == CMErrorMotionActivityNotAuthorized) {
					[self alertMotionActivityNotAuthorized];
				}
				return;
			}
			NSManagedObjectContext *savingContext = [NSManagedObjectContext MR_rootSavingContext];
			
			Pedometer *pedometerItem = [Pedometer MR_findFirstByAttribute:@"date" withValue:[self.searchDateFormatter stringFromDate:pedometerData.startDate] inContext:savingContext];
			if (!pedometerItem) {
				pedometerItem = [Pedometer MR_createEntityInContext:savingContext];
				pedometerItem.uniqueID = [[NSUUID UUID] UUIDString];
			}
			pedometerItem.date = [self.searchDateFormatter stringFromDate:pedometerData.startDate];
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
										   message:NSLocalizedString(@"In order for AppBox Pro to collect step counts it needs to be given permission in the device Settings app", @"In order for AppBox Pro to collect step counts it needs to be given permission in the device Settings app")
										  delegate:self
								 cancelButtonTitle:NSLocalizedString(@"Open Settings", @"Open Settings")
								 otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
	[alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 1000) {
		[self requestAuthorizationForHealthStore];
		return;
	}
	if (buttonIndex == alertView.cancelButtonIndex) {
		NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
		[[UIApplication sharedApplication] openURL:url];
		_userLeftToVisitSettings = YES;
	}
}

- (void)fillMissingDates {
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
		[_collectionView reloadData];
	}
}

- (void)startUpdatePedometer {
	NSDate *today = [NSDate date];
	NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:today];
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
				
				[_collectionView reloadData];
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

- (void)setupTestData {
	NSArray *testData = @[
						  @[@"2016-05-17", @2550, @10, @1800],
						  @[@"2016-05-18", @10000, @0, @1000],
						  @[@"2016-05-19", @3869, @15, @2600],
						  @[@"2016-05-20", @26522, @31, @40300],
						  @[@"2016-05-21", @5782, @18, @3700],
						  @[@"2016-05-22", @6360, @19, @4300],
						  @[@"2016-05-23", @503, @0, @0],
						  ];

	NSManagedObjectContext *savingContext = [NSManagedObjectContext MR_rootSavingContext];
	for (NSArray *item in testData) {
		Pedometer *pedometer = [Pedometer MR_findFirstByAttribute:@"date" withValue:item[0] inContext:savingContext];
		if (!pedometer) {
			pedometer = [Pedometer MR_createEntityInContext:savingContext];
			pedometer.uniqueID = [[NSUUID UUID] UUIDString];
		}
		pedometer.date = item[0];
		pedometer.numberOfSteps = item[1];
		pedometer.floorsAscended = item[2];
		pedometer.distance = item[3];
	}
	[savingContext MR_saveOnlySelfAndWait];
}

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
		_stepsLabel.text = [self.pedometerHandler.numberFormatter stringFromNumber:pedometerData.numberOfSteps ?: @0];
		floorsAscended = [self.pedometerHandler.numberFormatter stringFromNumber:pedometerData.floorsAscended ?: @0];
		distanceInfo = [self.pedometerHandler distanceValueForMeasurementSystemFromDistance:pedometerData.distance ?: @0];
	} else {
		UIColor *color = [self.pedometerHandler colorForPercent:0];
		_stepsBackgroundView.backgroundColor = color;
		_stepsLabel.text = [self.pedometerHandler.numberFormatter stringFromNumber:@0];
		floorsAscended = [self.pedometerHandler.numberFormatter stringFromNumber:@0];
		distanceInfo = [self.pedometerHandler distanceValueForMeasurementSystemFromDistance:@0];
	}
	NSDictionary *valueAttribute = @{NSFontAttributeName:IS_IOS9 ? [UIFont fontWithName:@".SFUIDisplay-SemiBold" size:24] : [UIFont boldSystemFontOfSize:24],
			NSForegroundColorAttributeName:[UIColor whiteColor]};
	NSDictionary *unitAttribute = @{NSFontAttributeName:IS_IOS9 ? [UIFont fontWithName:@".SFUIDisplay-SemiBold" size:15] : [UIFont boldSystemFontOfSize:15],
			NSForegroundColorAttributeName:[UIColor whiteColor]};
	NSMutableAttributedString *floorsAscendedAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", floorsAscended]
																									   attributes:valueAttribute];
	NSAttributedString *floorUnitAttributedString = [[NSAttributedString alloc] initWithString:@"floors" attributes:unitAttribute];
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

	NSInteger fractionDigitsBefore = self.pedometerHandler.numberFormatter.maximumFractionDigits;
	self.pedometerHandler.numberFormatter.maximumFractionDigits = 0;
	_descriptionLabel.text = [NSString stringWithFormat:@"Daily Average %@steps  %@  %@floors",
					[self.pedometerHandler.numberFormatter stringFromNumber:@(averageSteps)],
					[[self.pedometerHandler stringFromDistance:@(averageDistance)] stringByReplacingOccurrencesOfString:@" " withString:@""],
					[self.pedometerHandler.numberFormatter stringFromNumber:@(averageFloorsAscended)]
	];
	self.pedometerHandler.numberFormatter.maximumFractionDigits = fractionDigitsBefore;
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
														[self refreshStepsFromHealthStore];
													}
												});
											}];
}

- (void)alertAppWillRequestAuthorization {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Info"
														message:@"AppBox Pro reads Floors ascended, Steps, and Walking + Running Distance from Apple HealthKit data.\n"
																"\n"
																"Data collected from HealthKit will not be used for marketing and advertising purposes."
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
											  otherButtonTitles:nil];
	alertView.tag = 1000;
	[alertView show];
}

- (void)refreshStepsFromHealthStore {
	if (IS_IOS7 || ![HKHealthStore isHealthDataAvailable]) return;

	HKQuantityType *stepsType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];

	HKAuthorizationStatus authorizationStatus =	[self.healthStore authorizationStatusForType:stepsType];
	
	if (authorizationStatus == HKAuthorizationStatusNotDetermined) {
		[self alertAppWillRequestAuthorization];
		return;
	}

	NSInteger length;
	BOOL showAlert = NO;
	if (![[NSUserDefaults standardUserDefaults] boolForKey:A3PedometerSettingsDidSearchHealthStore]) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:A3PedometerSettingsDidSearchHealthStore];
		length = 1000;
		showAlert = YES;
	} else {
		length = 3;
	}
	[self executeQueryFromHealthStoreForType:A3PedometerQueryTypeStepCount length:length completion:^{
		[self executeQueryFromHealthStoreForType:A3PedometerQueryTypeDistance length:length completion:^{
			[self executeQueryFromHealthStoreForType:A3PedometerQueryTypeFlightsClimbed length:length completion:^{
				dispatch_async(dispatch_get_main_queue(), ^{
					_pedometerItems = nil;
					[_collectionView reloadData];
					[self updateToday];
					if ([self.pedometerItems count]) {
						[_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[self.pedometerItems count] - 1 inSection:0]
												atScrollPosition:UICollectionViewScrollPositionRight
														animated:NO];
					}

					if (showAlert) {
						[self alertImportResults];
					}
				});
			}];
		}];
	}];
}

- (void)executeQueryFromHealthStoreForType:(A3PedometerQueryType)type length:(NSInteger)length completion:(void(^)(void))completion {
	NSDate *anchorDate = [[[NSDate date] dateAtStartOfDay] dateByAddingDays:length];
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
	query.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *result, NSError *error) {
		if (error) {
			FNLOG(@"*** An error occurred while calculating the statistics: %@ ***",
					error.localizedDescription);
			return;
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			NSDate *endDate = [NSDate date];
			NSDate *startDate = [[endDate dateAtStartOfDay] dateByAddingDays:-1000];
			NSManagedObjectContext *savingContext = [NSManagedObjectContext MR_rootSavingContext];

			[result enumerateStatisticsFromDate:startDate toDate:endDate withBlock:^(HKStatistics *result, BOOL *stop) {
				HKQuantity *quantity = result.sumQuantity;
				if (quantity) {
					NSString *dateString = [self.searchDateFormatter stringFromDate:result.startDate];
					Pedometer *pedometerItem = [Pedometer MR_findFirstByAttribute:@"date" withValue:dateString inContext:[NSManagedObjectContext MR_rootSavingContext]];
					if (!pedometerItem) {
						pedometerItem = [Pedometer MR_createEntityInContext:savingContext];
						pedometerItem.uniqueID = [[NSUUID UUID] UUIDString];
						pedometerItem.date = dateString;
					}
					switch (type) {
						case A3PedometerQueryTypeStepCount:{
							double stepsFromHealthStore = [quantity doubleValueForUnit:[HKUnit countUnit]];
							if (stepsFromHealthStore > [pedometerItem.numberOfSteps doubleValue]) {
								pedometerItem.numberOfSteps = @(stepsFromHealthStore);
							}
							break;
						}
						case A3PedometerQueryTypeDistance: {
							double distance = [quantity doubleValueForUnit:[HKUnit meterUnit]];
							if (distance > [pedometerItem.distance doubleValue]) {
								pedometerItem.distance = @(distance);
							}
							break;
						}
						case A3PedometerQueryTypeFlightsClimbed:{
							double floorsAscended = [quantity doubleValueForUnit:[HKUnit countUnit]];
							if (floorsAscended > [pedometerItem.floorsAscended doubleValue]) {
								pedometerItem.floorsAscended = @(floorsAscended);
							}
							break;
						}
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
						 NSLocalizedString(@"Total", @"Total"),
						 [self.pedometerHandler.numberFormatter stringFromNumber:@(numberOfEntities)],
						 NSLocalizedString(@"days", @"days"),
						 [self.pedometerHandler.numberFormatter stringFromNumber:totalSteps ?: @0],
						 NSLocalizedString(@"steps", @"steps"),
						 [self.pedometerHandler stringFromDistance:totalDistance],
						 [self.pedometerHandler.numberFormatter stringFromNumber:totalFloorsAscended],
						 NSLocalizedString(@"floors", @"floors"),
						 NSLocalizedString(@"Since", @"Since"),
						 [self.dateFormatterForCell stringFromDate:firstDate]
						 ];
	[self.dateFormatterForCell setDateFormat:dateFormatBefore];

	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Data Imported"
														message:message
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
											  otherButtonTitles:nil];
	[alertView show];
}

@end