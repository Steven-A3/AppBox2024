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
#import "LadyCalendarAccount.h"
#import "LadyCalendarPeriod.h"
#import "UIColor+A3Addition.h"
#import "A3LadyCalendarCalendarView.h"
#import "A3UserDefaults.h"
#import "A3LadyCalendarAccountListViewController.h"
#import "A3AppDelegate+appearance.h"
#import "UIViewController+iPad_rightSideView.h"
#import "A3InstructionViewController.h"
#import "NSDateFormatter+A3Addition.h"

@interface A3LadyCalendarViewController () <A3InstructionViewControllerDelegate>

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

@end

@implementation A3LadyCalendarViewController {
	NSInteger _startYear, _startMonth, _endYear, _endMonth;
	BOOL isShowMoreMenu;
	NSInteger numberOfMonthInPage;
	BOOL isFirst;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
	self.title = NSLocalizedString(@"Lady Calendar", @"Lady Calendar");

	[self leftBarButtonAppsButton];

	if( IS_IPHONE ){
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
	else{
		self.navigationItem.rightBarButtonItems = @[_settingBarButton,_accountBarButton,_chartBarButton];
	}
	self.toolbarItems = _bottomToolbar.items;

	[self makeBackButtonEmptyArrow];
	[self.dataManager prepare];
	[self.dataManager currentAccount];
	[self setupCalendarRange];
	numberOfMonthInPage = 1;
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
    [self setupInstructionView];
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationLadyCalendarPeriodDataChanged object:nil];
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidShow object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidHide object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationRightSideViewDidAppear object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationRightSideViewWillDismiss object:nil];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
	// TODO: 아래 코드 검증
	[self doneButtonAction:nil];

	if ([self isMovingFromParentViewController]) {
		[_calendarHeaderView removeFromSuperview];

		[[NSUserDefaults standardUserDefaults] setObject:self.currentMonth forKey:A3LadyCalendarLastViewMonth];
		[[NSUserDefaults standardUserDefaults] synchronize];

	} else {
		[_calendarHeaderView setHidden:YES];
	}
}

- (void)dealloc {
	[self removeObserver];
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
		[_chartBarButton setEnabled:[self.dataManager numberOfPeriodsWithAccountID:[[self.dataManager currentAccount] uniqueID] ] > 0];
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
	self.currentMonth = [notification.userInfo objectForKey:A3LadyCalendarChangedDateKey];
	[[NSUserDefaults standardUserDefaults] setObject:self.currentMonth forKey:A3LadyCalendarLastViewMonth];
	[[NSUserDefaults standardUserDefaults] synchronize];

	[self moveToCurrentMonth];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	if( [self.dataManager numberOfAccountInContext:[[MagicalRecordStack defaultStack] context] ] == 1 && [[[self.dataManager currentAccount] name] isEqualToString:DefaultAccountName] ){
		self.navigationItem.title = NSLocalizedString(@"Lady Calendar", @"Lady Calendar");
	}
	else{
		self.navigationItem.title = [[self.dataManager currentAccount] name];
	}

	[self.navigationController setToolbarHidden:NO];

	if( isFirst ) {
		isFirst = NO;

		[self showCalendarHeaderView];
		[self updateAddButton];

		[_collectionView reloadData];
	} else {
		[_calendarHeaderView setHidden:NO];

		[self setupCalendarRange];

		[self.collectionView reloadData];
	}

	_chartBarButton.enabled = ([self.dataManager numberOfPeriodsWithAccountID:[[self.dataManager currentAccount] uniqueID]] > 0);

	double delayInSeconds = 0.1;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		NSDate *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:A3LadyCalendarLastViewMonth];
		self.currentMonth = (lastDate == nil ? [A3DateHelper dateMakeMonthFirstDayAtDate:[NSDate date]] : lastDate);
		FNLOG(@"%@", self.currentMonth);
		[self moveToCurrentMonth];
		[self updateCurrentMonthLabel];
	});

}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	if( UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ){
		_calendarHeaderView.frame = CGRectMake(_calendarHeaderView.frame.origin.x, _calendarHeaderView.frame.origin.y, self.view.frame.size.width, _calendarHeaderView.frame.size.height);
	}
	else{
		_calendarHeaderView.frame = CGRectMake(_calendarHeaderView.frame.origin.x, _calendarHeaderView.frame.origin.y, self.view.frame.size.width, _calendarHeaderView.frame.size.height);
	}
	[_collectionView reloadData];
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
	return [A3DateHelper dateFromYear:indexPath.section + _startYear month:month day:1 hour:12 minute:0 second:0];
}

- (void)setupCalendarRange {
	NSCalendar *defaultCalendar = [[A3AppDelegate instance] calendar];
	NSDateComponents *startComponents = [defaultCalendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:[self.dataManager startDateForCurrentAccount]];
	_startYear = startComponents.year;
	_startMonth = startComponents.month;
	NSDateComponents *endComponents = [defaultCalendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:[self.dataManager endDateForCurrentAccount]];
	_endYear = endComponents.year;
	_endMonth = endComponents.month;
	if (_startYear == _endYear && ((_endMonth - _startMonth) < 2)) {
		_endMonth = _startMonth + 2;
		if (_endMonth > 12) {
			_endYear++;
			_endMonth = _endMonth / 12;
		}
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
	_calendarHeaderView.frame = CGRectMake(0, 20.0+44.0, self.navigationController.navigationBar.frame.size.width, _calendarHeaderView.frame.size.height);
	[self.navigationController.view insertSubview:_calendarHeaderView belowSubview:self.view];

	UIEdgeInsets insets = _collectionView.contentInset;
	_collectionView.contentInset = UIEdgeInsetsMake(_calendarHeaderView.frame.size.height+20+44.0,insets.left,insets.bottom,insets.right);
}

- (void)updateCurrentMonthLabel
{
	[self calculateCurrentMonthWithScrollView:_collectionView];
	FNLOG(@"%@", _currentMonth);

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
	NSString *dateFormat = [dateFormatter formatStringByRemovingDayComponent:dateFormatter.dateFormat];
	[dateFormatter setDateFormat:dateFormat];
	self.currentMonthLabel.text = [dateFormatter stringFromDate:_currentMonth];

    NSDate *todayMonth = [A3DateHelper dateMakeMonthFirstDayAtDate:[NSDate date]];

    if( [self.currentMonth isEqualToDate:todayMonth] )
        _currentMonthLabel.textColor = [[A3AppDelegate instance] themeColor];
    else
        _currentMonthLabel.textColor = [UIColor blackColor];
}

- (void)moveToCurrentMonth
{
    NSInteger year = [A3DateHelper yearFromDate:self.currentMonth];
	NSInteger month = [A3DateHelper monthFromDate:self.currentMonth];
	NSInteger section = year - _startYear;
	NSInteger row;
	if (year == _startYear) {
		month = MAX(month, _startMonth);
	}
	if (year - _endYear == 0) {
		month = MIN(_endMonth, month);
	}
	row = month - (section == 0 ? _startMonth : 1);
	NSInteger numberOfRows = [self collectionView:_collectionView numberOfItemsInSection:section];
	if (row >= numberOfRows) {
		row = numberOfRows - 1;
	}
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
}

- (LadyCalendarPeriod*)previousPeriodFromIndexPath:(NSIndexPath*)indexPath
{
    if( indexPath.section == 0 )
        return nil;

    NSInteger prevSection = indexPath.section-1;
    NSDictionary *prevDict = [_sectionArray objectAtIndex:prevSection];
    NSArray *items = [prevDict objectForKey:ItemKey_Items];

    return [items lastObject];
}

- (void)updateAddButton
{
    if( ![_addButton isDescendantOfView:self.view] ){
        [self.view addSubview:_addButton];
		[_addButton makeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(self.view.centerX);
			make.bottom.equalTo(self.view.bottom).with.offset(-55);
			make.width.equalTo(@44);
			make.height.equalTo(@44);
		}];
    }
}

#pragma mark Instruction Related
- (void)setupInstructionView
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"LadyCalendar"]) {
        [self showInstructionView];
    }
    [self setupTwoFingerDoubleTapGestureToShowInstruction];
}

- (void)showInstructionView
{
    UIStoryboard *instructionStoryBoard = [UIStoryboard storyboardWithName:IS_IPHONE ? @"Instruction_iPhone" : @"Instruction_iPad" bundle:nil];
    _instructionViewController = [instructionStoryBoard instantiateViewControllerWithIdentifier:@"LadyCalendar"];
    self.instructionViewController.delegate = self;
    [self.navigationController.view.superview addSubview:self.instructionViewController.view];
    self.instructionViewController.view.frame = self.navigationController.view.frame;
    self.instructionViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
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
	FNLOG(@"%@", calendarView);

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
	FNLOG(@"%@ / %@, %ld/%ld",calendarView.dateMonth,_currentMonth, (long)indexPath.section, (long)indexPath.row);

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
    CGPoint pos = CGPointMake(scrollView.contentOffset.x + scrollView.contentInset.left, scrollView.contentOffset.y+scrollView.contentInset.top + (IS_IPHONE ? 185 : 275)/numberOfMonthInPage );
    self.currentIndexPath = [_collectionView indexPathForItemAtPoint:pos];
    if( self.currentIndexPath == nil ){
        self.currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    NSDate *month = [self dateFromIndexPath:_currentIndexPath];
    if( ![self.currentMonth isEqual:month] ){
        self.currentMonth = month;
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
    if( !decelerate) {
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
    NSArray *periods = [self.dataManager periodListWithMonth:calendarView.dateMonth accountID:[[self.dataManager currentAccount] uniqueID] containPredict:YES];
    if( [periods count] < 1 )
        return;
    LadyCalendarPeriod *period = [periods objectAtIndex:0];
    A3LadyCalendarDetailViewController *viewController = [[A3LadyCalendarDetailViewController alloc] initWithNibName:nil bundle:nil];
    viewController.month = period.startDate;
    viewController.periodItems = [NSMutableArray arrayWithArray:periods];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[A3DateHelper dateStringFromDate:calendarView.dateMonth withFormat:@"MMMM"] style:UIBarButtonItemStyleBordered target:nil action:nil];
	[self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - action method

- (UIView *)moreMenuView {
	if (!_moreMenuView) {
		_moreMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
		_moreMenuView.backgroundColor = [UIColor colorWithRed:247.0 / 255.0 green:247.0 / 255.0 blue:247.0 / 255.0 alpha:1.0];
		[self addThreeButtons:@[_chartButton, _accountButton, _settingButton] toView:_moreMenuView];
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
	[_calendarHeaderView addSubview:_moreMenuView];

	[UIView animateWithDuration:0.3 animations:^{
		_moreMenuView.alpha = 1.0;
	}];
	[self rightBarButtonDoneButton];
    _chartButton.enabled = ([self.dataManager numberOfPeriodsWithAccountID:[[self.dataManager currentAccount] uniqueID] ] > 0);

	_tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moreMenuDismissAction:)];
	[self.view addGestureRecognizer:_tapGestureRecognizer];

	isShowMoreMenu = YES;
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
	if (isShowMoreMenu) {
		[UIView animateWithDuration:0.3 animations:^{
			_moreMenuView.alpha = 0.0;
		}
						 completion:^(BOOL finished) {
							 [_moreMenuView removeFromSuperview];
							 _moreMenuView = nil;

							 [self.view removeGestureRecognizer:_tapGestureRecognizer];
							 [self rightButtonMoreButton];
							 [self.navigationItem.leftBarButtonItem setEnabled:YES];
						 }];
		isShowMoreMenu = NO;
	}
}

- (IBAction)moveToTodayAction:(id)sender {
	_currentMonth = [NSDate date];
	[self moveToCurrentMonth];
}

- (IBAction)changeListTypeAction:(id)sender {
    UIBarButtonItem *button = (UIBarButtonItem*)sender;
    
    if( numberOfMonthInPage == 1 )
        numberOfMonthInPage = 2;
    else if( numberOfMonthInPage == 2 )
        numberOfMonthInPage = 1;
    [_collectionView reloadData];
	[self updateCurrentMonthLabel];
    
    if( numberOfMonthInPage == 1 )
        button.image = [UIImage imageNamed:@"calendar02"];
    else
        button.image = [UIImage imageNamed:@"calendar"];
}

- (IBAction)moveToListAction:(id)sender {
    if( IS_IPHONE )
        [self doneButtonAction:nil];
    A3LadyCalendarListViewController *viewCtrl = [[A3LadyCalendarListViewController alloc] initWithNibName:@"A3LadyCalendarListViewController" bundle:nil];
	viewCtrl.dataManager = _dataManager;
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
    navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:navCtrl animated:YES completion:nil];
}

- (IBAction)moveToChartAction:(id)sender {
    if( IS_IPHONE )
        [self doneButtonAction:nil];
    A3LadyCalendarChartViewController *viewCtrl = [[A3LadyCalendarChartViewController alloc] initWithNibName:@"A3LadyCalendarChartViewController" bundle:nil];
	viewCtrl.dataManager = _dataManager;
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

- (IBAction)moveToAccountAction:(id)sender {
    if( IS_IPHONE )
        [self doneButtonAction:nil];
    A3LadyCalendarAccountListViewController *viewCtrl = [[A3LadyCalendarAccountListViewController alloc] initWithNibName:nil bundle:nil];
	viewCtrl.dataManager = self.dataManager;
    if( IS_IPHONE ){
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
        [self presentViewController:navCtrl animated:YES completion:nil];
    }
    else{
        [self.A3RootViewController presentRightSideViewController:viewCtrl];
    }
}

- (IBAction)settingAction:(id)sender {
    if( IS_IPHONE )
        [self doneButtonAction:nil];
	A3LadyCalendarSettingViewController *viewCtrl = [[A3LadyCalendarSettingViewController alloc] initWithNibName:nil bundle:nil];
	viewCtrl.dataManager = _dataManager;
    if( IS_IPHONE ){
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
        [self presentViewController:navCtrl animated:YES completion:nil];
    }
    else {
        [self.A3RootViewController presentRightSideViewController:viewCtrl];
    }
}

- (IBAction)addPeriodAction:(id)sender {
    A3LadyCalendarAddPeriodViewController *viewCtrl = [[A3LadyCalendarAddPeriodViewController alloc] initWithNibName:nil bundle:nil];
	viewCtrl.dataManager = self.dataManager;
    viewCtrl.isEditMode = NO;
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
    navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:navCtrl animated:YES completion:nil];
}

@end
