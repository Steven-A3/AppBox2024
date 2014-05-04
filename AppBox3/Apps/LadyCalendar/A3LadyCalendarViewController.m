//
//  A3LadyCalendarViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LadyCalendarViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
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
#import "A3CalendarView.h"
#import "A3UserDefaults.h"
#import "A3LadyCalendarAccountEditViewController.h"

@interface A3LadyCalendarViewController ()

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

@end

@implementation A3LadyCalendarViewController {
	NSInteger _startYear, _startMonth, _endYear, _endMonth;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
	self.title = @"Lady Calendar";

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
	[self setupCalendarRange];

	[_collectionView registerNib:[UINib nibWithNibName:@"CalendarViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"fullCalendarCell"];

	numberOfMonthInPage = 1;
	self.topSeperatorViewConst.constant = 1.0 / [[UIScreen mainScreen] scale];
	isFirst = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setToolbarHidden:NO];
	[self showCalendarHeaderView];
	currentAccount = [self.dataManager currentAccount];
	if( [self.dataManager numberOfAccount] == 1 && [currentAccount.name isEqualToString:DefaultAccountName] ){
		self.navigationItem.title = @"Lady Calendar";
	}
	else{
		self.navigationItem.title = currentAccount.name;
	}

	if( isFirst ) {
		isFirst = NO;

		NSDate *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:A3LadyCalendarLastViewMonth];
		_currentMonth = (lastDate == nil ? [A3DateHelper dateMakeMonthFirstDayAtDate:[NSDate date]] : lastDate);
		[self moveToCurrentMonth];
	}
	[_collectionView reloadData];
	[self updateCurrentMonthLabel];
	_chartBarButton.enabled = ([self.dataManager numberOfPeriodsWithAccountID:currentAccount.uniqueID] > 0);

	[self updateAddButton];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self updateAddButton];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[self hideCalendarHeaderView];
	[self dismissMoreMenuView:self.moreMenuView scrollView:self.collectionView];
	if( self.currentMonth ){
		[[NSUserDefaults standardUserDefaults] setObject:self.currentMonth forKey:A3LadyCalendarLastViewMonth];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	_addButton.hidden = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	if( UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ){
		_topNaviView.frame = CGRectMake(_topNaviView.frame.origin.x, _topNaviView.frame.origin.y, self.view.frame.size.width, _topNaviView.frame.size.height);
	}
	else{
		_topNaviView.frame = CGRectMake(_topNaviView.frame.origin.x, _topNaviView.frame.origin.y, self.view.frame.size.width, _topNaviView.frame.size.height);
	}
	[_collectionView reloadData];
	[self updateAddButton];
	_addButton.hidden = NO;
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
    if( isShowMoreMenu )
		[self dismissMoreMenuView:self.moreMenuView scrollView:_collectionView];
    if( ![_topNaviView isDescendantOfView:self.navigationController.view]){
        _topNaviView.frame = CGRectMake(0, 20.0+44.0, self.navigationController.navigationBar.frame.size.width, _topNaviView.frame.size.height);
        [self.navigationController.view insertSubview:_topNaviView belowSubview:self.view];

        UIEdgeInsets insets = _collectionView.contentInset;
        _collectionView.contentInset = UIEdgeInsetsMake(_topNaviView.frame.size.height+20+44.0,insets.left,insets.bottom,insets.right);
    }
}

- (void)hideCalendarHeaderView
{
    [_topNaviView removeFromSuperview];
    [self.view setNeedsDisplay];
}

- (void)updateCurrentMonthLabel
{
	FNLOG(@"%@", _currentMonth);
    self.currentMonthLabel.text = [A3DateHelper dateStringFromDate:_currentMonth withFormat:([A3DateHelper isCurrentLocaleIsKorea] ? @"yyyy년 MMMM" : @"MMMM yyyy")];
    NSDate *todayMonth = [A3DateHelper dateMakeMonthFirstDayAtDate:[NSDate date]];

    if( [self.currentMonth isEqualToDate:todayMonth] )
        _currentMonthLabel.textColor = [UIColor colorWithRGBRed:0 green:122 blue:255 alpha:255];
    else
        _currentMonthLabel.textColor = [UIColor blackColor];
}

- (void)moveToCurrentMonth
{
    NSInteger year = [A3DateHelper yearFromDate:self.currentMonth];
	NSInteger month = [A3DateHelper monthFromDate:self.currentMonth];
	NSInteger row;
	if (year == _startYear) {
		month = MAX(month, _startMonth);
	}
	if (year - _endYear == 0) {
		month = MIN(_endMonth, month);
	}
	row = month - (year - _startYear == 0 ? _startMonth : 1);
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:year - _startYear] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
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
    _addButton.frame = CGRectMake(self.view.frame.size.width*0.5 - _addButton.frame.size.width*0.5, self.view.frame.size.height - self.bottomToolbar.frame.size.height - 20.0 - _addButton.frame.size.height, _addButton.frame.size.width, _addButton.frame.size.height);
    if( ![_addButton isDescendantOfView:self.view] ){
        [self.view addSubview:_addButton];
    }
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

    A3CalendarView *calendarView = (A3CalendarView*)[cell viewWithTag:10];
	calendarView.dataManager = self.dataManager;
    calendarView.delegate = self;
    calendarView.cellSize = CGSizeMake(floor(self.view.frame.size.width / 7), (IS_IPHONE ? 73.0 : 109.0)/numberOfMonthInPage);
    calendarView.isSmallCell = (numberOfMonthInPage > 1);
	NSInteger month;
	if (indexPath.section == 0) {
		month = indexPath.row + _startMonth;
	} else {
		month = indexPath.row;
	}
    calendarView.dateMonth = [A3DateHelper dateFromYear:indexPath.section + _startYear month:month day:1 hour:12 minute:0 second:0];
    NSLog(@"%s %@ / %@, %ld/%ld",__FUNCTION__,calendarView.dateMonth,_currentMonth, (long)indexPath.section, (long)indexPath.row);
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *yearMonth = [self dateFromIndexPath:indexPath];
	NSInteger numberOfWeeks = [A3DateHelper numberOfWeeksOfMonth:yearMonth];
    CGSize size = CGSizeMake(collectionView.frame.size.width,(numberOfWeeks * (IS_IPHONE ? 73.0 : 109.0) / numberOfMonthInPage)+(numberOfWeeks*(1.0/[[UIScreen mainScreen] scale])));
    
    return size;
}

- (void)calculateCurrentMonthWithScrollView:(UIScrollView*)scrollView
{
    CGPoint pos = CGPointMake(scrollView.contentOffset.x + scrollView.contentInset.left, scrollView.contentOffset.y+scrollView.contentInset.top);
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
    if( !decelerate){
        [self calculateCurrentMonthWithScrollView:scrollView];
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
- (void)calendarView:(A3CalendarView *)calendarView didSelectDay:(NSInteger)day
{
    NSArray *periods = [self.dataManager periodListWithMonth:calendarView.dateMonth accountID:currentAccount.uniqueID containPredict:YES];
    if( [periods count] < 1 )
        return;
    LadyCalendarPeriod *period = [periods objectAtIndex:0];
    A3LadyCalendarDetailViewController *viewCtrl = [[A3LadyCalendarDetailViewController alloc] initWithNibName:@"A3LadyCalendarDetailViewController" bundle:nil];
	viewCtrl.dataManager = self.dataManager;
    viewCtrl.month = period.startDate;
    viewCtrl.periodItems = [NSMutableArray arrayWithArray:periods];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[A3DateHelper dateStringFromDate:calendarView.dateMonth withFormat:@"MMMM"] style:UIBarButtonItemStyleBordered target:nil action:nil];
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

#pragma mark - action method
- (void)moreMenuDismissAction:(UITapGestureRecognizer *)gestureRecognizer
{
    [self doneButtonAction:nil];
}

- (void)moreButtonAction:(UIBarButtonItem *)button
{
    [self hideCalendarHeaderView];
    self.moreMenuView = [self presentMoreMenuWithButtons:@[_chartButton,_accountButton,_settingButton] tableView:nil];
    [self rightBarButtonDoneButton];
    _chartButton.enabled = ([self.dataManager numberOfPeriodsWithAccountID:currentAccount.uniqueID] > 0);
    isShowMoreMenu = YES;
}

- (void)doneButtonAction:(UIBarButtonItem *)button
{
	[self dismissMoreMenuView:self.moreMenuView scrollView:self.collectionView];
    [self.view removeGestureRecognizer:[self.view.gestureRecognizers lastObject]];
    [UIView animateWithDuration:0.3 animations:^{
        [self showCalendarHeaderView];
    }];
    [self rightButtonMoreButton];
    isShowMoreMenu = NO;
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
    A3LadyCalendarAccountEditViewController *viewCtrl = [[A3LadyCalendarAccountEditViewController alloc] initWithNibName:@"A3LadyCalendarAccountEditViewController" bundle:nil];
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
	A3LadyCalendarSettingViewController *viewCtrl = [[A3LadyCalendarSettingViewController alloc] initWithNibName:@"A3LadyCalendarSettingViewController" bundle:nil];
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
    A3LadyCalendarAddPeriodViewController *viewCtrl = [[A3LadyCalendarAddPeriodViewController alloc] initWithNibName:@"A3LadyCalendarAddPeriodViewController" bundle:nil];
	viewCtrl.dataManager = self.dataManager;
    viewCtrl.isEditMode = NO;
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
    navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:navCtrl animated:YES completion:nil];
}

@end
