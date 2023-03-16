//
//  A3LadyCalendarViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LadyCalendarViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3LadyCalendarListViewController.h"
#import "A3LadyCalendarChartViewController.h"
#import "A3LadyCalendarSettingViewController.h"
#import "A3LadyCalendarDefine.h"
#import "A3LadyCalendarModelManager.h"
#import "A3DateHelper.h"
#import "A3LadyCalendarDetailViewController.h"
#import "A3LadyCalendarAddPeriodViewController.h"
#import "LadyCalendarPeriod.h"
#import "A3LadyCalendarCalendarView.h"
#import "A3LadyCalendarAccountListViewController.h"
#import "UIViewController+iPad_rightSideView.h"
#import "A3InstructionViewController.h"
#import "NSDateFormatter+A3Addition.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "A3UserDefaults.h"
#import "LadyCalendarAccount.h"
#import "HolidayData.h"
#import "CGColor+Additions.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"

@interface A3LadyCalendarViewController ()
<A3InstructionViewControllerDelegate,
A3ViewControllerProtocol,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
A3CalendarViewDelegate, GADBannerViewDelegate>

@property (strong, nonatomic) A3LadyCalendarModelManager *dataManager;
@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) NSDate *currentMonth;
@property (strong, nonatomic) NSMutableArray *sectionArray;
@property (strong, nonatomic) NSMutableDictionary *monthDict;

@property (strong ,nonatomic) UIButton *chartButton;
@property (strong, nonatomic) UIButton *accountButton;
@property (strong, nonatomic) UIButton *settingButton;
@property (strong, nonatomic) UIView *moreMenuView;
@property (strong, nonatomic) NSIndexPath *currentIndexPath;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) A3InstructionViewController *instructionViewController;
@property (weak, nonatomic) IBOutlet UILabel *weekdayColumn0, *weekdayColumn1, *weekdayColumn2, *weekdayColumn3, *weekdayColumn4, *weekdayColumn5, *weekdayColumn6;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *todayButtonInToolbar;

@end

@implementation A3LadyCalendarViewController {
	NSInteger _startYear, _startMonth, _endYear, _endMonth;
	BOOL isShowMoreMenu;
	NSInteger numberOfMonthInPage;
	BOOL isFirst;
	BOOL _isBeingClose;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
	
	self.collectionView.frame = [[[A3AppDelegate instance] window] bounds];
	
	self.title = NSLocalizedString(A3AppName_LadiesCalendar, nil);

	if (IS_IPAD || IS_PORTRAIT) {
		[self leftBarButtonAppsButton];
	} else {
		self.navigationItem.leftBarButtonItem = nil;
		self.navigationItem.hidesBackButton = YES;
	}

    [self makeNavigationBarAppearanceDefault];
	if ( IS_IPHONE ) {
		[self rightButtonMoreButton];

		self.chartButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[_chartButton setImage:[UIImage imageNamed:@"chart"] forState:UIControlStateNormal];
		[_chartButton setBackgroundColor:[UIColor clearColor]];
		[_chartButton addTarget:self action:@selector(moveToChartAction:) forControlEvents:UIControlEventTouchUpInside];

		self.accountButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[_accountButton setImage:[UIImage imageNamed:@"account"] forState:UIControlStateNormal];
		[_accountButton setBackgroundColor:[UIColor clearColor]];
		[_accountButton addTarget:self action:@selector(moveToAccountAction:) forControlEvents:UIControlEventTouchUpInside];

		self.settingButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[_settingButton setImage:[UIImage imageNamed:@"general"] forState:UIControlStateNormal];
		[_settingButton setBackgroundColor:[UIColor clearColor]];
		[_settingButton addTarget:self action:@selector(settingAction:) forControlEvents:UIControlEventTouchUpInside];
	}
	else {
        _helpBarButton = [self instructionHelpBarButton];
		self.navigationItem.rightBarButtonItems = @[_settingBarButton, _accountBarButton, _chartBarButton, _helpBarButton];
	}
	self.toolbarItems = _bottomToolbar.items;
	[self.todayButtonInToolbar setTitle:NSLocalizedString(@"Today", nil)];
	[self setupWeekdayLabels];

	[self makeBackButtonEmptyArrow];
	
	[self.dataManager prepare];
	[self.dataManager prepareAccount];
	[self.dataManager currentAccount];
	
	[self setupCalendarRange];
	numberOfMonthInPage = 2;
	self.topSeparatorViewConst.constant = 1.0 / [[UIScreen mainScreen] scale];
	isFirst = YES;

	[_collectionView registerNib:[UINib nibWithNibName:@"CalendarViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"fullCalendarCell"];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(periodDataChanged:) name:A3NotificationLadyCalendarPeriodDataChanged object:nil];
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidShow) name:A3NotificationMainMenuDidShow object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewDidAppear) name:A3NotificationRightSideViewDidAppear object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewWillDismiss) name:A3NotificationRightSideViewWillDismiss object:nil];
	}
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudDidImportChanges) name:A3NotificationCloudCoreDataStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudDidImportChanges) name:A3NotificationCloudKeyValueStoreDidImport object:nil];
    // TODO
//  스크롤중에 종료되는 버그로 인해서 일단 제거.
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsDidChange) name:A3UserDefaultsDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)applicationDidEnterBackground {
	[self dismissInstructionViewController:nil];
}

//
- (void)userDefaultsDidChange {
	self.dataManager.currentAccount = nil;
	[self.dataManager currentAccount];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self rightSideViewWillDismiss];
    });
}

- (void)cloudDidImportChanges {
	self.dataManager.currentAccount = nil;
	[self.dataManager currentAccount];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self rightSideViewWillDismiss];
    });
}

- (void)setupWeekdayLabels {
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	NSArray *weekdaySymbols = [dateFormatter shortWeekdaySymbols];
	FNLOG(@"%@", weekdaySymbols);

	NSArray *labels;
	if ([[NSCalendar currentCalendar] firstWeekday] != Monday) {
		labels = @[_weekdayColumn0, _weekdayColumn1, _weekdayColumn2, _weekdayColumn3, _weekdayColumn4, _weekdayColumn5, _weekdayColumn6];
		_weekdayColumn0.textColor = [UIColor colorWithRGBHexString:@"8E8E93"];
		_weekdayColumn6.textColor = [UIColor colorWithRGBHexString:@"8E8E93"];
	} else {
		labels = @[_weekdayColumn6, _weekdayColumn0, _weekdayColumn1, _weekdayColumn2, _weekdayColumn3, _weekdayColumn4, _weekdayColumn5];
		_weekdayColumn0.textColor = [UIColor blackColor];
		_weekdayColumn5.textColor = [UIColor colorWithRGBHexString:@"8E8E93"];
		_weekdayColumn6.textColor = [UIColor colorWithRGBHexString:@"8E8E93"];
	}
	[labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
		label.text = weekdaySymbols[idx];
	}];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	if (_isBeingClose) return;

	[self setupNavigationTitle];
	[self setupCalendarHeaderViewFrame];

	[self.navigationController setToolbarHidden:NO];
	_collectionView.delegate = self;

	if ( isFirst ) {
		isFirst = NO;

		[self showCalendarHeaderView];
		[self updateAddButton];
	} else {
		[_calendarHeaderView setHidden:NO];
		[self setupCalendarRange];
	}

	_chartBarButton.enabled = ([self.dataManager numberOfPeriodsWithAccountID:[self.dataManager currentAccount].uniqueID] > 0);

	dispatch_async(dispatch_get_main_queue(), ^{
		if (_isBeingClose) return;
		
		[self setupNavigationTitle];
		[self.collectionView reloadData];
		
		[self reloadWatchingDateAndMove];
	});
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

	static NSString *const A3DisclaimerSigned = @"kDefaultPCalendarWarningMessageSigned";
	if (![[A3UserDefaults standardUserDefaults] boolForKey:A3DisclaimerSigned]) {
		[[A3UserDefaults standardUserDefaults] setBool:YES forKey:A3DisclaimerSigned];

		UIAlertView *disclaimer = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Disclaimer", @"Disclaimer")
															 message:NSLocalizedString(@"LadyCalendarDisclaimerMsg", nil)
															delegate:nil
												   cancelButtonTitle:NSLocalizedString(@"I Agree", @"I Agree")
												   otherButtonTitles:nil];
		[disclaimer show];
	}
	if (IS_IPHONE && IS_PORTRAIT) {
		[self leftBarButtonAppsButton];
	}

	[self updateCurrentMonthLabel];

	if ([self isMovingToParentViewController] || [self isBeingPresented]) {
		[self setupBannerViewForAdUnitID:AdMobAdUnitIDLadiesCalendar keywords:@[@"menstruation", @"ladies"] adSize:IS_IPHONE ? GADAdSizeFluid : GADAdSizeLeaderboard delegate:self];
	}
	if ([self.navigationController.navigationBar isHidden]) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
		[self showCalendarHeaderView];
	}
	[self setupInstructionView];
	dispatch_async(dispatch_get_main_queue(), ^{
		if (_isBeingClose) return;
		
		[self setupNavigationTitle];
		[self.collectionView reloadData];
		
		[self reloadWatchingDateAndMove];
	});
}

- (void)reloadWatchingDateAndMove {
	NSDate *currentWatchingDate = [self.dataManager currentAccount].watchingDate;
	if (!currentWatchingDate) {
		LadyCalendarPeriod *lastPeriod = [[_dataManager periodListSortedByStartDateIsAscending:YES] lastObject];
		if (!lastPeriod) {
			currentWatchingDate = [A3DateHelper dateMakeMonthFirstDayAtDate:[NSDate date]];
		}
		else {
			currentWatchingDate = [A3DateHelper dateMakeMonthFirstDayAtDate:[lastPeriod startDate]];
		}
	}
	
	_currentMonth = currentWatchingDate;
	
	[self.dataManager setWatchingDateForCurrentAccount:currentWatchingDate];
	
	[self moveToCurrentWatchingDate];
	[self updateCurrentMonthLabel];
}

- (void)removeObserver {
//	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3UserDefaultsDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationLadyCalendarPeriodDataChanged object:nil];
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidShow object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidHide object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationRightSideViewDidAppear object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationRightSideViewWillDismiss object:nil];
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudCoreDataStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)prepareClose {
	FNLOG();
	_isBeingClose = YES;

	if (self.presentedViewController) {
		[self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
	}

	self.collectionView.delegate = nil;
	self.collectionView.dataSource = nil;
	[self removeObserver];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
	// TODO: 아래 코드 검증
	[self doneButtonAction:nil];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		[_calendarHeaderView removeFromSuperview];
        _collectionView.delegate = nil;
        
        NSManagedObjectContext *context = [[A3AppDelegate instance] managedObjectContext];
        [context saveContext];

		id watchDate = self.dataManager.currentAccount.watchingDate;
		if (watchDate) {
			[[A3SyncManager sharedSyncManager] setObject:watchDate forKey:A3LadyCalendarLastViewMonth state:A3DataObjectStateModified];
		}
	} else {
		[_calendarHeaderView setHidden:YES];
	}
}

- (void)cleanUp {
	_isBeingClose = YES;
	[self dismissInstructionViewController:nil];
    [_calendarHeaderView removeFromSuperview];
    _collectionView.delegate = nil;
}

- (void)dealloc {
	[self removeObserver];
}

- (BOOL)resignFirstResponder {
	NSString *startingAppName = [[A3UserDefaults standardUserDefaults] objectForKey:kA3AppsStartingAppName];
	if ([startingAppName length] && ![startingAppName isEqualToString:A3AppName_LadiesCalendar]) {
		[self.instructionViewController.view removeFromSuperview];
		self.instructionViewController = nil;
	}
	return [super resignFirstResponder];
}

- (void)mainMenuDidShow {
	[self enableControls:NO];
}

- (void)mainMenuDidHide {
	[self enableControls:YES];
}

- (void)rightSideViewDidAppear {
	[self enableControls:NO];
}

- (void)rightSideViewWillDismiss {
	[self setupNavigationTitle];
	[self enableControls:YES];
	[self setupCalendarRange];
	[self.collectionView reloadData];
	[self updateCurrentMonthLabel];
}

- (void)enableControls:(BOOL)enable {
	if (!IS_IPAD) return;
	[self.navigationItem.leftBarButtonItem setEnabled:enable];
	[self.addButton setEnabled:enable];
	if (enable) {
        [_helpBarButton setEnabled:YES];
		[_chartBarButton setEnabled:[self.dataManager numberOfPeriodsWithAccountID:[self.dataManager currentAccount].uniqueID ] > 0];
		[_accountBarButton setEnabled:YES];
		[_settingBarButton setEnabled:YES];
	} else {
		[self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *barButtonItem, NSUInteger idx, BOOL *stop) {
			[barButtonItem setEnabled:NO];
		}];
	}
	[self.toolbarItems[0] setEnabled:enable];
	[self.toolbarItems[2] setEnabled:enable];
	[self.toolbarItems[4] setEnabled:enable];
}

- (void)periodDataChanged:(NSNotification *)notification {
	[self setupCalendarRange];
	[_collectionView reloadData];

	[self.dataManager setWatchingDateForCurrentAccount:[notification.userInfo objectForKey:A3LadyCalendarChangedDateKey]];

	[self moveToCurrentWatchingDate];
}

- (void)setupNavigationTitle {
	self.dataManager.currentAccount = nil;
	if ([self.dataManager numberOfAccount] == 1 && [[self.dataManager currentAccount].name isEqualToString:[self.dataManager defaultAccountName]]) {
		self.navigationItem.title = NSLocalizedString(A3AppName_LadiesCalendar, nil);
	}
	else{
		FNLOG(@"%@", self.dataManager.currentAccount);
		self.navigationItem.title = [self.dataManager currentAccount].name;
	}
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

	if (IS_IPHONE && IS_PORTRAIT) {
		[self leftBarButtonAppsButton];
	}

	[self showCalendarHeaderView];
    [self setupCalendarHeaderViewFrame];
	[_collectionView reloadData];
}

- (void)setupCalendarHeaderViewFrame {
    if (IS_PORTRAIT) {
        _calendarHeaderView.frame = CGRectMake(_calendarHeaderView.frame.origin.x, _calendarHeaderView.frame.origin.y, self.view.frame.size.width, _calendarHeaderView.frame.size.height);
    }
    else{
        _calendarHeaderView.frame = CGRectMake(_calendarHeaderView.frame.origin.x, _calendarHeaderView.frame.origin.y, self.view.frame.size.width, _calendarHeaderView.frame.size.height);
    }
}

- (A3LadyCalendarModelManager *)dataManager {
	if (!_dataManager) {
		_dataManager = [A3LadyCalendarModelManager new];
	}
	return _dataManager;
}

- (NSDate *)dateFromIndexPath:(NSIndexPath *)indexPath {
	NSInteger month;
	if (indexPath.section == 0) {
		month = _startMonth + indexPath.row;
	} else {
		month = indexPath.row + 1;
	}
	return [A3DateHelper dateFromYear:(indexPath.section + _startYear) month:month day:1 hour:12 minute:0 second:0];
}

- (void)setupCalendarRange {
	NSCalendar *defaultCalendar = [[A3AppDelegate instance] calendar];
	NSDateComponents *startComponents = [defaultCalendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:[self.dataManager startDateForCurrentAccount]];
	_startYear = startComponents.year;
	_startMonth = startComponents.month;
	NSDateComponents *endComponents = [defaultCalendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:[self.dataManager endDateForCurrentAccount]];
	_endYear = endComponents.year;
	_endMonth = endComponents.month;
	NSDateComponents *difference =
	[defaultCalendar components:NSCalendarUnitMonth
					   fromDate:[self.dataManager startDateForCurrentAccount]
						 toDate:[self.dataManager endDateForCurrentAccount]
						options:0];
	if (difference.month < 3) {
		difference.month = 3;
		NSDate *updatedEndDate = [defaultCalendar dateByAddingComponents:difference
																  toDate:[self.dataManager startDateForCurrentAccount]
																 options:0];
		endComponents = [defaultCalendar components:NSCalendarUnitYear|NSCalendarUnitMonth
										   fromDate:updatedEndDate];
		_endYear = endComponents.year;
		_endMonth = endComponents.month;
	}
}

- (NSInteger)indexOfSectionArrayAtMonth:(NSDate*)month
{
    NSString *monthKey = [A3DateHelper dateStringFromDate:month withFormat:@"yyyyMM"];
    NSDictionary *dict = [_monthDict objectForKey:monthKey];
    return [_sectionArray indexOfObject:dict];
}

- (void)showCalendarHeaderView
{
	CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
	_calendarHeaderView.frame = CGRectMake(0, navigationBarHeight, self.navigationController.navigationBar.frame.size.width, _calendarHeaderView.frame.size.height);
	[self.navigationController.navigationBar addSubview:_calendarHeaderView];

	UIEdgeInsets insets = _collectionView.contentInset;
    CGFloat offset = 0;
    if SYSTEM_VERSION_LESS_THAN(@"11") {
        offset = 64;
    }
	_collectionView.contentInset = UIEdgeInsetsMake(_calendarHeaderView.frame.size.height + offset,insets.left,insets.bottom,insets.right);
}

- (void)updateCurrentMonthLabel
{
	[self calculateCurrentMonthWithScrollView:_collectionView];

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
	NSString *dateFormat = [dateFormatter formatStringByRemovingDayComponent:dateFormatter.dateFormat];
	[dateFormatter setDateFormat:dateFormat];
	//self.currentMonthLabel.text = [dateFormatter stringFromDate:[self.dataManager.currentAccount watchingDate]];
    self.currentMonthLabel.text = [dateFormatter stringFromDate:_currentMonth];

    NSDate *todayMonth = [A3DateHelper dateMakeMonthFirstDayAtDate:[NSDate date]];

    if ( [self.dataManager.currentAccount.watchingDate isEqualToDate:todayMonth] ) {
        _currentMonthLabel.textColor = [[A3AppDelegate instance] themeColor];
    }
    else {
        _currentMonthLabel.textColor = [UIColor blackColor];
    }
    
    [_currentMonthLabel sizeToFit];
}

- (void)moveToCurrentWatchingDate
{
    NSDate *currentWatchingDate = [self.dataManager currentAccount].watchingDate;
    
    if (!currentWatchingDate) {
        currentWatchingDate = [self.dataManager startDateForCurrentAccount];
    }

	[self scrollToDate:currentWatchingDate];
}

- (void)scrollToDate:(NSDate *)date {
	NSDateComponents *components = [[[A3AppDelegate instance] calendar] components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
	NSInteger year = components.year;
	NSInteger month = components.month;
	if (year < _startYear) {
        date = [self.dataManager startDateForCurrentAccount];
		components = [[[A3AppDelegate instance] calendar] components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
		year = components.year;
		month = components.month;
    }

	NSInteger section = year - _startYear;
	NSInteger row;
	if (year == _startYear) {
		month = MAX(month, _startMonth);
	}
	if (year - _endYear == 0) {
		month = MIN(_endMonth, month);
	}
	row = month - (section == 0 ? _startMonth : 1);

	if (_collectionView.numberOfSections > 0) {
		if (section >= _collectionView.numberOfSections) {
			section = MAX(_collectionView.numberOfSections - 1, 0);
		}
		
		NSInteger numberOfRows = [self collectionView:_collectionView numberOfItemsInSection:section];
		if (row >= numberOfRows) {
			row = numberOfRows - 1;
		}
		[_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
	}
}

- (LadyCalendarPeriod*)previousPeriodFromIndexPath:(NSIndexPath*)indexPath
{
    if ( indexPath.section == 0 )
        return nil;

    NSInteger prevSection = indexPath.section-1;
    NSDictionary *prevDict = [_sectionArray objectAtIndex:prevSection];
    NSArray *items = [prevDict objectForKey:ItemKey_Items];

    return [items lastObject];
}

- (void)updateAddButton
{
    if ( ![_addButton isDescendantOfView:self.view] ) {
        [self.view addSubview:_addButton];
		[_addButton makeConstraints:^(MASConstraintMaker *make) {
            CGFloat verticalOffset = 0;
            UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets];
            verticalOffset = -safeAreaInsets.bottom;
			make.centerX.equalTo(self.view.centerX);
			make.bottom.equalTo(self.view.bottom).with.offset(-55 + verticalOffset);
			make.width.equalTo(@44);
			make.height.equalTo(@44);
		}];
    }
}

#pragma mark Instruction Related

static NSString *const A3V3InstructionDidShowForLadyCalendar = @"A3V3InstructionDidShowForLadyCalendar";

- (void)setupInstructionView
{
    if (![[A3UserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForLadyCalendar]) {
        [self showInstructionView];
    }
}

- (void)showInstructionView
{
	[[A3UserDefaults standardUserDefaults] setBool:YES forKey:A3V3InstructionDidShowForLadyCalendar];
	[[A3UserDefaults standardUserDefaults] synchronize];

    UIStoryboard *instructionStoryBoard = [UIStoryboard storyboardWithName:IS_IPHONE ? A3StoryboardInstruction_iPhone : A3StoryboardInstruction_iPad bundle:nil];
    _instructionViewController = [instructionStoryBoard instantiateViewControllerWithIdentifier:@"LadyCalendar"];
    self.instructionViewController.delegate = self;
    [self.navigationController.view.superview addSubview:self.instructionViewController.view];
    self.instructionViewController.view.frame = self.navigationController.view.frame;
    self.instructionViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
    [self doneButtonAction:nil];
}

- (void)dismissInstructionViewController:(UIView *)view
{
    [self.instructionViewController.view removeFromSuperview];
    self.instructionViewController = nil;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return  (_endYear - _startYear) + 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	if (section == 0) {
		if (_startYear == _endYear) {
			return (_endMonth - _startMonth) + 1;
		} else {
			return 12 - _startMonth + 1;
		}
	} else if (section == [self numberOfSectionsInCollectionView:collectionView] - 1) {
		return _endMonth;
	}
    return 12;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = @"fullCalendarCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];

    A3LadyCalendarCalendarView *calendarView = (A3LadyCalendarCalendarView *)[cell viewWithTag:10];

	calendarView.dataManager = self.dataManager;
    calendarView.delegate = self;
	if (numberOfMonthInPage == 1) {
		calendarView.cellSize = CGSizeMake(floor(self.view.frame.size.width / 7), (IS_IPHONE ? 74.0 : 110.0 ));
	} else {
		calendarView.cellSize = CGSizeMake(floor(self.view.frame.size.width / 7), (IS_IPHONE ? 37.0 : 55.0 ));
	}
    calendarView.isSmallCell = (numberOfMonthInPage > 1);
	NSInteger month;
	if (indexPath.section == 0) {
		month = indexPath.row + _startMonth;
	} else {
		month = indexPath.row + 1;
	}
    calendarView.dateMonth = [A3DateHelper dateFromYear:indexPath.section + _startYear month:month day:1 hour:12 minute:0 second:0];
//	FNLOG(@"%@ / %@, %ld/%ld",calendarView.dateMonth,_currentMonth, (long)indexPath.section, (long)indexPath.row);

    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *yearMonth = [self dateFromIndexPath:indexPath];
	NSInteger numberOfWeeks = [A3DateHelper numberOfWeeksOfMonth:yearMonth];
    CGSize size = CGSizeMake(collectionView.frame.size.width, (numberOfWeeks * (IS_IPHONE ? 74.0 : 110.0 ) / numberOfMonthInPage) );

    return size;
}

- (void)calculateCurrentMonthWithScrollView:(UIScrollView*)scrollView
{
    CGPoint pos = CGPointMake(scrollView.contentOffset.x + scrollView.contentInset.left,
                              scrollView.contentOffset.y + scrollView.contentInset.top + (IS_IPHONE ? 185 : 275) / numberOfMonthInPage );
    self.currentIndexPath = [_collectionView indexPathForItemAtPoint:pos];
    if ( self.currentIndexPath == nil ) {
        self.currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }

    NSDate *currentWatchingDate = _currentMonth;
    NSDate *month = [self dateFromIndexPath:_currentIndexPath];

    if ( ![currentWatchingDate isEqual:month] ) {
        _currentMonth = month;
        if (currentWatchingDate) {
			[self.dataManager setWatchingDateForCurrentAccount:month];
        }
		[self updateCurrentMonthLabel];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self calculateCurrentMonthWithScrollView:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ( !decelerate) {
        [self calculateCurrentMonthWithScrollView:scrollView];
		[self.collectionView scrollToItemAtIndexPath:_currentIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self calculateCurrentMonthWithScrollView:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self calculateCurrentMonthWithScrollView:scrollView];
}

#pragma mark - A3CalendarViewDelegate

- (void)calendarView:(A3LadyCalendarCalendarView *)calendarView didSelectDay:(NSInteger)day
{
    NSArray *periods = [self.dataManager periodListWithMonth:calendarView.dateMonth accountID:[self.dataManager currentAccount].uniqueID containPredict:YES];
    if ( [periods count] < 1 )
        return;
    LadyCalendarPeriod *period = [periods objectAtIndex:0];
    A3LadyCalendarDetailViewController *viewController = [[A3LadyCalendarDetailViewController alloc] init];
    viewController.month = period.startDate;
    viewController.periodItems = [NSMutableArray arrayWithArray:periods];
    self.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:[A3DateHelper dateStringFromDate:calendarView.dateMonth withFormat:@"MMMM"]
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
	[self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - action method

- (UIView *)moreMenuView {
	if (!_moreMenuView) {
        CGFloat verticalOffset = 0;
        UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets];
        verticalOffset = safeAreaInsets.top - 20;

        _moreMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, 64 + verticalOffset, self.view.bounds.size.width, 44)];
		_moreMenuView.backgroundColor = [UIColor colorWithRed:247.0 / 255.0 green:247.0 / 255.0 blue:247.0 / 255.0 alpha:1.0];
        UIButton *helpButton = [self instructionHelpButton];
        [self addFourButtons:@[helpButton, _chartButton, _accountButton, _settingButton] toView:_moreMenuView];
	}
	return _moreMenuView;
}

- (void)moreMenuDismissAction:(UITapGestureRecognizer *)gestureRecognizer
{
    [self doneButtonAction:nil];
}

- (void)moreButtonAction:(UIBarButtonItem *)button
{
	[self.navigationItem.leftBarButtonItem setEnabled:NO];
	self.moreMenuView.alpha = 0.0;
	[self.navigationController.view addSubview:_moreMenuView];

	[UIView animateWithDuration:0.3 animations:^{
		self.moreMenuView.alpha = 1.0;
	}];
	[self rightBarButtonDoneButton];
    _chartButton.enabled = ([self.dataManager numberOfPeriodsWithAccountID:[self.dataManager currentAccount].uniqueID ] > 0);

	_tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moreMenuDismissAction:)];
	[self.view addGestureRecognizer:_tapGestureRecognizer];

	isShowMoreMenu = YES;
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
	if (isShowMoreMenu) {
		[UIView animateWithDuration:0.3 animations:^{
			self.moreMenuView.alpha = 0.0;
		}
						 completion:^(BOOL finished) {
							 [self.moreMenuView removeFromSuperview];
							 self.moreMenuView = nil;

							 [self.view removeGestureRecognizer:_tapGestureRecognizer];
							 [self rightButtonMoreButton];
							 [self.navigationItem.leftBarButtonItem setEnabled:YES];
						 }];
		isShowMoreMenu = NO;
	}
}

- (IBAction)moveToTodayAction:(id)sender {
	[self.dataManager setWatchingDateForCurrentAccount:[NSDate date]];

	[self moveToCurrentWatchingDate];
}

- (IBAction)changeListTypeAction:(id)sender {
    UIBarButtonItem *button = (UIBarButtonItem*)sender;
    
    if ( numberOfMonthInPage == 1 )
        numberOfMonthInPage = 2;
    else if ( numberOfMonthInPage == 2 )
        numberOfMonthInPage = 1;

	NSDate *oldCurrentMonth = _currentMonth;

    [_collectionView reloadData];

	[self scrollToDate:oldCurrentMonth];

	[self updateCurrentMonthLabel];
    
    if ( numberOfMonthInPage == 1 )
        button.image = [UIImage imageNamed:@"calendar02"];
    else
        button.image = [UIImage imageNamed:@"calendar"];
}

- (IBAction)moveToListAction:(id)sender {
    if ( IS_IPHONE )
        [self doneButtonAction:nil];
    A3LadyCalendarListViewController *viewCtrl = [[A3LadyCalendarListViewController alloc] initWithNibName:@"A3LadyCalendarListViewController" bundle:nil];
	viewCtrl.dataManager = _dataManager;
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
    if (@available(iOS 13.0, *)) {
        navCtrl.modalPresentationStyle = UIModalPresentationAutomatic;
    } else {
        navCtrl.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    [self presentViewController:navCtrl animated:YES completion:nil];
}

- (IBAction)moveToChartAction:(id)sender {
    if ( IS_IPHONE )
        [self doneButtonAction:nil];
    A3LadyCalendarChartViewController *viewCtrl = [[A3LadyCalendarChartViewController alloc] initWithNibName:@"A3LadyCalendarChartViewController" bundle:nil];
	viewCtrl.dataManager = _dataManager;
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

- (IBAction)moveToAccountAction:(id)sender {
    if ( IS_IPHONE ) {
        [self doneButtonAction:nil];
    }
    
    A3LadyCalendarAccountListViewController *viewCtrl = [[A3LadyCalendarAccountListViewController alloc] init];
	viewCtrl.dataManager = self.dataManager;
    
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
    if (@available(iOS 13.0, *)) {
        navCtrl.modalPresentationStyle = UIModalPresentationAutomatic;
    } else {
        navCtrl.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    [self presentViewController:navCtrl animated:YES completion:nil];
}

- (IBAction)settingAction:(id)sender {
    if ( IS_IPHONE )
        [self doneButtonAction:nil];
	A3LadyCalendarSettingViewController *viewCtrl = [[A3LadyCalendarSettingViewController alloc] init];
	viewCtrl.dataManager = _dataManager;
    if ( IS_IPHONE ) {
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
        if (@available(iOS 13.0, *)) {
            navCtrl.modalPresentationStyle = UIModalPresentationAutomatic;
        } else {
            navCtrl.modalPresentationStyle = UIModalPresentationFullScreen;
        }
        [self presentViewController:navCtrl animated:YES completion:nil];
    }
    else {
        [[[A3AppDelegate instance] rootViewController_iPad] presentRightSideViewController:viewCtrl toViewController:nil];
    }
}

- (IBAction)addPeriodAction:(id)sender {
    A3LadyCalendarAddPeriodViewController *viewCtrl = [[A3LadyCalendarAddPeriodViewController alloc] init];
	viewCtrl.dataManager = self.dataManager;
    viewCtrl.isEditMode = NO;
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
    if (@available(iOS 13.0, *)) {
        navCtrl.modalPresentationStyle = UIModalPresentationAutomatic;
    } else {
        navCtrl.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    [self presentViewController:navCtrl animated:YES completion:nil];
}

#pragma mark - AdMob

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
	[self.view addSubview:bannerView];
	
    CGFloat verticalOffset = 0;
    UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets];
    verticalOffset = -safeAreaInsets.bottom;

    UIView *superview = self.view;
	[bannerView remakeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(superview.left);
		make.right.equalTo(superview.right);
		make.bottom.equalTo(superview.bottom).with.offset(-44 + verticalOffset);
		make.height.equalTo(@(bannerView.bounds.size.height));
	}];

	[_addButton remakeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.view.centerX);
		make.bottom.equalTo(self.view.bottom).with.offset(-(55 + (IS_IPHONE ? 50 : 90)) + verticalOffset);
		make.width.equalTo(@44);
		make.height.equalTo(@44);
	}];

	UIEdgeInsets contentInset = self.collectionView.contentInset;
	contentInset.bottom = bannerView.bounds.size.height + 44;
	self.collectionView.contentInset = contentInset;

	[self.view layoutIfNeeded];
}

@end
