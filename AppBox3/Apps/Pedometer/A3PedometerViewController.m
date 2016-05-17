//
//  A3PedometerViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/10/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import "A3PedometerViewController.h"
#import "A3DashLineView.h"
#import "A3AppDelegate.h"
#import "Pedometer.h"
#import "A3PedometerCollectionViewCell.h"
#import "A3PedometerCollectionViewFlowLayout.h"
#import "A3PedometerHandler.h"
#import "UIViewController+A3Addition.h"
#import "A3PedometerSettingsTableViewController.h"

@interface A3PedometerViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

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

@end

@implementation A3PedometerViewController {
	BOOL _collectionViewBackgroundDidSet;
	BOOL _viewWillAppearDidRun;
}

- (void)viewDidLoad {
    [super viewDidLoad];

#if TARGET_IPHONE_SIMULATOR
	[self setupTestData];
	[self fillMissingDates];
#else
	[self refreshPedometerData];
#endif
	[[NSUserDefaults standardUserDefaults] registerDefaults:@{A3PedometerSettingsNumberOfGoalSteps:@10000}];

	[self makeBackButtonEmptyArrow];

	[_settingsButton setImage:[[UIImage imageNamed:@"general"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
					 forState:UIControlStateNormal];
	_settingsButton.tintColor = [UIColor whiteColor];
	
	_collectionView.backgroundColor = [UIColor whiteColor];
	[self updateToday];
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

	FNLOGRECT(_collectionView.bounds);
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

	[dashLineView makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(collectionViewBackgroundView.left);
		make.right.equalTo(collectionViewBackgroundView.right);

		CGRect bounds = _collectionView.bounds;
		make.top.equalTo(collectionViewBackgroundView.top).with.offset(bounds.size.height - (bounds.size.height - 35) / 1.3 - 35);
		make.height.equalTo(@2);
	}];
	_collectionView.backgroundView = collectionViewBackgroundView;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)appsButtonAction:(UIButton *)button {
	if (IS_IPHONE) {
		if ([[A3AppDelegate instance] isMainMenuStyleList]) {
			[[A3AppDelegate instance].drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
		} else {
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
	CGFloat coordinateInScreen = cell.frame.origin.x - _collectionView.contentOffset.x;
	if ((coordinateInScreen >= -10.0) && (coordinateInScreen < (flowLayout.itemSize.width + flowLayout.minimumInteritemSpacing - 5))) {
		showMonth = YES;
	}
	self.dateFormatterForCell.dateFormat = @"yyyy-MM-dd";
	NSDate *date = [self.dateFormatterForCell dateFromString:pedometerCell.pedometerData.date];
	if ([[NSCalendar currentCalendar] ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date] == 1) {
		showMonth = YES;
	}
	if (showMonth) {
		_dateFormatterForCell.dateFormat = self.monthDateFormat;
	} else {
		_dateFormatterForCell.dateFormat = @"d";
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
			
			[self startUpdatePedometer];
			dispatch_async(dispatch_get_main_queue(), ^{
				[self fillMissingDates];
			});
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
			NSManagedObjectContext *savingContext = [NSManagedObjectContext MR_rootSavingContext];
			
			Pedometer *pedometerItem = [Pedometer MR_findFirstByAttribute:@"date" withValue:[self.searchDateFormatter stringFromDate:pedometerData.startDate] inContext:savingContext];
			if (!pedometerItem) {
				pedometerItem = [Pedometer MR_createEntityInContext:savingContext];
				pedometerItem.uniqueID = [[NSUUID UUID] UUIDString];
			}
			pedometerItem.date = [self.searchDateFormatter stringFromDate:pedometerData.startDate];
			pedometerItem.distance = pedometerData.distance;
			pedometerItem.numberOfSteps = pedometerData.numberOfSteps;
			pedometerItem.floorsAscended = pedometerData.floorsAscended;
			pedometerItem.floorsDescended = pedometerData.floorsDescended;

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
			FNLOG(@"%@", dateString);
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
				pedometerItem.numberOfSteps = pedometerData.numberOfSteps;
				pedometerItem.distance = pedometerData.distance;
				pedometerItem.floorsAscended = pedometerData.floorsAscended;
				pedometerItem.floorsDescended = pedometerItem.floorsDescended;
				
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
						  @[@"2016-04-27", @2550, @10, @1800],
						  @[@"2016-04-28", @10000, @0, @1000],
						  @[@"2016-04-29", @3869, @15, @2600],
						  @[@"2016-04-30", @26522, @31, @40300],
						  @[@"2016-05-01", @5782, @18, @3700],
						  @[@"2016-05-02", @6360, @19, @4300],
						  @[@"2016-05-03", @503, @0, @0],
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
		_stepsLabel.text = [self.pedometerHandler.numberFormatter stringFromNumber:pedometerData.numberOfSteps];
		floorsAscended = [self.pedometerHandler.numberFormatter stringFromNumber:pedometerData.floorsAscended];
		distanceInfo = [self.pedometerHandler distanceValueForMeasurementSystemFromDistance:pedometerData.distance];
	} else {
		UIColor *color = [self.pedometerHandler colorForPercent:0];
		_stepsBackgroundView.backgroundColor = color;
		_stepsLabel.text = [self.pedometerHandler.numberFormatter stringFromNumber:@0];
		floorsAscended = [self.pedometerHandler.numberFormatter stringFromNumber:@0];
		distanceInfo = [self.pedometerHandler distanceValueForMeasurementSystemFromDistance:@0];
	}
	NSDictionary *valueAttribute = @{NSFontAttributeName:[UIFont fontWithName:@".SFUIDisplay-SemiBold" size:24],
			NSForegroundColorAttributeName:[UIColor whiteColor]};
	NSDictionary *unitAttribute = @{NSFontAttributeName:[UIFont fontWithName:@".SFUIDisplay-SemiBold" size:15],
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

	A3PedometerSettingsTableViewController *viewController = [segue destinationViewController];
	viewController.title = @"Settings";
	viewController.pedometerHandler = self.pedometerHandler;
}

@end
