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
#import "A3LadyCalendarAccountViewController.h"
#import "A3LadyCalendarChartViewController.h"
#import "A3LadyCalendarSettingViewController.h"
#import "A3LadyCalendarDefine.h"
#import "A3LadyCalendarModelManager.h"
#import "A3DateHelper.h"
#import "A3LadyCalendarDetailViewController.h"
#import "A3LadyCalendarAddPeriodViewController.h"
#import "A3ColoredCircleView.h"
#import "LadyCalendarAccount.h"
#import "LadyCalendarPeriod.h"
#import "UIColor+A3Addition.h"
#import "A3CalendarView.h"
#import "A3UserDefaults.h"
#import "A3LadyCalendarAccountEditViewController.h"

@interface A3LadyCalendarViewController ()


@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) NSDate *currentMonth;
@property (strong, nonatomic) NSArray *sourceArray;
@property (strong, nonatomic) NSArray *predictArray;
@property (strong, nonatomic) NSMutableArray *sectionArray;
@property (strong, nonatomic) NSMutableDictionary *monthDict;
@property (strong, nonatomic) NSMutableDictionary *dayEventTable;
//@property (strong, nonatomic) UIImage *ovulationImage;

@property (strong ,nonatomic) UIButton *chartButton;
@property (strong, nonatomic) UIButton *accountButton;
@property (strong, nonatomic) UIButton *settingButton;
@property (strong, nonatomic) UIView *moreMenuView;
@property (strong, nonatomic) NSIndexPath *currentIndexPath;

//- (void)setupMonthSectionWithArray:(NSArray*)array;
- (NSInteger)indexOfSectionArrayAtMonth:(NSDate*)month;
- (void)showCalendarHeaderView;
- (void)hideCalendarHeaderView;
- (void)updateCurrentMonth;
- (void)updateStatus;
- (LadyCalendarPeriod*)previousPeriodFromIndexPath:(NSIndexPath*)indexPath;
@end

@implementation A3LadyCalendarViewController

/*
- (void)setupMonthSectionWithArray:(NSArray*)array
{
    self.sectionArray = [NSMutableArray array];
    self.monthDict = [NSMutableDictionary dictionary];
    self.dayEventTable = [NSMutableDictionary dictionary];
    
    for(LadyCalendarPeriod *item in array){
        NSString *monthKey = [A3DateHelper dateStringFromDate:item.startDate withFormat:@"yyyyMM"];
        NSDictionary *dict = [_monthDict objectForKey:monthKey];
        if( dict == nil ){
            dict = @{CalendarItem_Month : [A3DateHelper dateMakeMonthFirstDayAtDate:item.startDate],CalendarItem_FirstDayPosition : @([A3DateHelper firstDayPositionOfMonth:item.startDate]),CalendarItem_LastDay : @([A3DateHelper lastDaysOfMonth:item.startDate]),ItemKey_Items : [NSMutableArray array]};
            [_monthDict setObject:dict forKey:monthKey];
            [_sectionArray addObject:dict];
        }
        
        NSMutableArray *items = [dict objectForKey:ItemKey_Items];
        if( items )
            [items addObject:item];
        
        NSDate *pregStDate = [A3DateHelper dateByAddingDays:-4 fromDate:item.ovulation];
        NSDate *pregEdDate = [A3DateHelper dateByAddingDays:5 fromDate:item.ovulation];
        
        NSInteger diffDays = [A3DateHelper diffDaysFromDate:pregStDate toDate:pregEdDate];
        for(NSInteger i=0; i <= diffDays; i++){
            NSDate *date = [A3DateHelper dateByAddingDays:i fromDate:pregStDate];
            NSString *dateKey = [A3DateHelper dateStringFromDate:date withFormat:@"yyyyMMdd"];
            [_dayEventTable setObject:@{ItemKey_Type : @(DetailCellType_Pregnancy),CalendarItem_Period : item, CalendarItem_IsPeriodStart : (i==0 ? @(YES) : @(NO)),CalendarItem_IsPeriodEnd : (i==diffDays ? @(YES) : @(NO)) } forKey:dateKey];
        }
        NSString *dateKey = [A3DateHelper dateStringFromDate:item.ovulation withFormat:@"yyyyMMdd"];
        [_dayEventTable setObject:@{ItemKey_Type : @(DetailCellType_Ovulation),CalendarItem_Period : item} forKey:dateKey];
        
        diffDays = [A3DateHelper diffDaysFromDate:item.startDate toDate:item.endDate];
        for(NSInteger i=0; i <= diffDays; i++){
            NSDate *date = [A3DateHelper dateByAddingDays:i fromDate:item.startDate];
            NSString *dateKey = [A3DateHelper dateStringFromDate:date withFormat:@"yyyyMMdd"];
            [_dayEventTable setObject:@{ItemKey_Type : @(DetailCellType_MenstrualPeriod),CalendarItem_Period : item, CalendarItem_IsPeriodStart : (i==0 ? @(YES) : @(NO)),CalendarItem_IsPeriodEnd : (i==diffDays ? @(YES) : @(NO))} forKey:dateKey];
        }
    }
}
*/
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
//        [self.navigationController.view addConstraint:[NSLayoutConstraint constraintWithItem:_topNaviView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.navigationController.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
//        [self.navigationController.view addConstraint:[NSLayoutConstraint constraintWithItem:_topNaviView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.navigationController.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
//        [self.navigationController.view addConstraint:[NSLayoutConstraint constraintWithItem:_topNaviView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.navigationController.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:_topNaviView.frame.origin.y]];
//        [self.navigationController.view addConstraint:[NSLayoutConstraint constraintWithItem:_topNaviView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:_topNaviView.frame.size.height]];
//        [self.navigationController.view layoutIfNeeded];
        
        UIEdgeInsets insets = _collectionView.contentInset;
        _collectionView.contentInset = UIEdgeInsetsMake(_topNaviView.frame.size.height+20+44.0,insets.left,insets.bottom,insets.right);
    }
}

- (void)hideCalendarHeaderView
{
    [_topNaviView removeFromSuperview];
    [self.view setNeedsDisplay];
}

- (void)updateCurrentMonth
{
    self.currentMonthLabel.text = [A3DateHelper dateStringFromDate:_currentMonth withFormat:([A3DateHelper isCurrentLocaleIsKorea] ? @"yyyy년 MMMM" : @"MMMM yyyy")];
    NSDate *todayMonth = [A3DateHelper dateMakeMonthFirstDayAtDate:[NSDate date]];

    if( [self.currentMonth isEqualToDate:todayMonth] )
        _currentMonthLabel.textColor = [UIColor colorWithRGBRed:0 green:122 blue:255 alpha:255];
    else
        _currentMonthLabel.textColor = [UIColor blackColor];
}

- (void)updateStatus
{
//    if( [_collectionView.visibleCells count] < 1 )
//        return;
//    if( [self.sourceArray count] < 1 ){
//        _addButton.hidden = NO;
//        return;
//    }
//    UICollectionViewCell *cell = [_collectionView.visibleCells objectAtIndex:0];
//    NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
//    NSDictionary *dict = [_sectionArray objectAtIndex:indexPath.section];
//    NSDate *month = [dict objectForKey:CalendarItem_Month];
    
//    NSLog(@"%s %d/%d, %@",__FUNCTION__,indexPath.row,indexPath.section, month);
//    NSDate *month = [A3DateHelper dateFromYear:self.currentIndexPath.section month:self.currentIndexPath.row+1 day:1 hour:12 minute:0 second:0];
//    if( ![self.currentMonth isEqualToDate:month] ){
//        self.currentMonth = month;
//        [self updateCurrentMonth];
//    }

    [self updateCurrentMonth];
//    NSArray *periods = [[A3LadyCalendarModelManager sharedManager] periodListWithMonth:self.currentMonth accountID:currentAccount.accountID containPredict:NO];
//    if( [periods count] < 1 ){
//        _addButton.hidden = NO;
//    }
//    else{
//        BOOL isAllPredict = YES;
//        for(LadyCalendarPeriod *period in periods){
//            if( [period.isPredict boolValue] )  continue;
//            isAllPredict = NO;
//        }
//        if( isAllPredict )
//            _addButton.hidden = NO;
//        else
//            _addButton.hidden = YES;
//    }
    
/*
    if( [[dict objectForKey:ItemKey_Items] count] < 1 )
        _addButton.hidden = NO;
    else{
        BOOL isAllPredict = YES;
        for(LadyCalendarPeriod *period in [dict objectForKey:ItemKey_Items]){
            if( [period.isPredict boolValue] )  continue;
            isAllPredict = NO;
        }
        if( isAllPredict )
            _addButton.hidden = NO;
        else
            _addButton.hidden = YES;
    }
*/
}

- (void)moveToCurrentMonth
{
    NSInteger year = [A3DateHelper yearFromDate:self.currentMonth];
    NSInteger month = [A3DateHelper monthFromDate:self.currentMonth];
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:month-1 inSection:year-1970] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Lady Calendar";
    
    if( IS_IPHONE ){
        [self leftBarButtonAppsButton];
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
        if( UIInterfaceOrientationIsPortrait(self.interfaceOrientation) )
            [self leftBarButtonAppsButton];
        else
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightButtons];
        self.navigationItem.rightBarButtonItems = @[_settingBarButton,_accountBarButton,_chartBarButton];
        
    }
    self.toolbarItems = _bottomToolbar.items;
    
    [self makeBackButtonEmptyArrow];
    [[A3LadyCalendarModelManager sharedManager] prepare];
//    [_collectionView registerNib:[UINib nibWithNibName:@"CalendarCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"calendarDayCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"CalendarViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"fullCalendarCell"];
//    self.ovulationImage = [A3LadyCalendarModelManager createTripleCircleImageSize:CGSizeMake(31.0, 31.0) lineColor:[UIColor colorWithRGBRed:200 green:200 blue:200 alpha:255] centerColor:[UIColor colorWithRGBRed:238 green:230 blue:87 alpha:255] outCircleColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.05]];

    numberOfMonthInPage = 1;
    self.topSeperatorViewConst.constant = 1.0 / [[UIScreen mainScreen] scale];
    isFirst = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO];
    [self showCalendarHeaderView];
    currentAccount = [[A3LadyCalendarModelManager sharedManager] currentAccount];
    if( [[A3LadyCalendarModelManager sharedManager] numberOfAccount] == 1 && [currentAccount.accountName isEqualToString:DefaultAccountName] ){
        self.navigationItem.title = @"Lady Calendar";
    }
    else{
        self.navigationItem.title = currentAccount.accountName;
    }
    
    if( isFirst ){
        NSDate *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:A3LadyCalendarLastViewMonth];
        self.currentMonth = (lastDate == nil ? [A3DateHelper dateMakeMonthFirstDayAtDate:[NSDate date]] : lastDate);
        [self moveToCurrentMonth];
        isFirst = NO;
    }
    [_collectionView reloadData];
    [self updateStatus];
//    if( IS_IPAD )
        _chartBarButton.enabled = ([[A3LadyCalendarModelManager sharedManager] numberOfPeriodsWithAccountID:currentAccount.accountID] > 0);
//    self.sourceArray = [[A3LadyCalendarModelManager sharedManager] periodListSortedByStartDateIsAscending:YES accountID:account.accountID];
//    self.predictArray = [[A3LadyCalendarModelManager sharedManager] predictPeriodListSortedByStartDateIsAscending:YES accountID:account.accountID];
//    [self setupMonthSectionWithArray:[_sourceArray arrayByAddingObjectsFromArray:_predictArray]];

//    [_collectionView reloadData];

//    NSInteger currentMonthSection = [self indexOfSectionArrayAtMonth:_currentMonth];
//    if( currentMonthSection != NSNotFound ){
//        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:currentMonthSection] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
//        
//    }
//    [self updateStatus];
//    [self updateCurrentMonth];
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
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
        _topNaviView.frame = CGRectMake(_topNaviView.frame.origin.x, _topNaviView.frame.origin.y, self.view.frame.size.width, _topNaviView.frame.size.height);
    }
    else{
        [self leftBarButtonAppsButton];
        _topNaviView.frame = CGRectMake(_topNaviView.frame.origin.x, _topNaviView.frame.origin.y, self.view.frame.size.width, _topNaviView.frame.size.height);
    }
    [_collectionView reloadData];
    [self updateAddButton];
    _addButton.hidden = NO;
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return  100;//([_sectionArray count] < 1 ? 1 : [_sectionArray count] );
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
/*
    NSInteger firstDayPosition;
    NSInteger lastDayOfMonth;
    
    if( [_sectionArray count] < 1 ){
        NSDate *date = [NSDate date];
        firstDayPosition = [A3DateHelper firstDayPositionOfMonth:date];
        lastDayOfMonth = [A3DateHelper lastDaysOfMonth:date];
    }
    else{
        NSDictionary *item = [_sectionArray objectAtIndex:section];
        firstDayPosition = [[item objectForKey:CalendarItem_FirstDayPosition] integerValue];
        lastDayOfMonth = [[item objectForKey:CalendarItem_LastDay] integerValue];
    }
    
    return (firstDayPosition + lastDayOfMonth);
*/
    return 12;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = @"fullCalendarCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];

/*
    UIImageView *seperatorView = (UIImageView*)[cell viewWithTag:12];
    for(NSLayoutConstraint *layout in seperatorView.constraints){
        if( layout.firstAttribute == NSLayoutAttributeHeight )
            layout.constant = 1.0 / [[UIScreen mainScreen] scale];
    }
    UILabel *dateLabel = (UILabel*)[cell viewWithTag:10];
    UIView *bottomView = (UIView*)[cell viewWithTag:11];
    UIImageView *bottomLineView = (UIImageView*)[cell viewWithTag:12];
    UIImageView *lineImageView = (UIImageView*)[bottomView viewWithTag:20];
    A3ColoredCircleView *startCircle = (A3ColoredCircleView*)[bottomView viewWithTag:21];
    UIImageView *centerImageView = (UIImageView*)[bottomView viewWithTag:22];
    A3ColoredCircleView *endCircle = (A3ColoredCircleView*)[bottomView viewWithTag:23];
//    UIView *selectedBGView = [[UIView alloc] initWithFrame:cell.bounds];
//    selectedBGView.backgroundColor = [UIColor whiteColor];//[UIColor colorWithRGBRed:0 green:124 blue:247 alpha:255];
//    cell.selectedBackgroundView = selectedBGView;

    
    NSDictionary *dict = ( [_sectionArray count] > 0 ? [_sectionArray objectAtIndex:indexPath.section] : nil);
    NSInteger firstDayPosition = ([_sectionArray count] > 0 ? [[dict objectForKey:CalendarItem_FirstDayPosition] integerValue] : [A3DateHelper firstDayPositionOfMonth:[NSDate date]]);;
    
    if( indexPath.row < firstDayPosition ){
        dateLabel.text = @"";
        bottomView.hidden = YES;
        bottomLineView.hidden = YES;
    }
    else{
        NSInteger day = indexPath.row - firstDayPosition;
        NSDate *month = (dict ? [dict objectForKey:CalendarItem_Month] : [NSDate date]);
        NSDate *today = [A3DateHelper dateByAddingDays:day fromDate:month];
        NSString *dateKey = [A3DateHelper dateStringFromDate:today withFormat:@"yyyyMMdd"];
        NSInteger weekday = [A3DateHelper weekdayFromDate:today];
        
        dateLabel.text = [NSString stringWithFormat:@"%@%d",(day==0 ? ([_currentMonth isEqualToDate:month] ? @"" : [A3DateHelper dateStringFromDate:month withFormat:@"MMM"]) : @""),day + 1];
        dateLabel.font = [UIFont systemFontOfSize:( IS_IPHONE ? 14.0 : 18.0)];
        if( weekday == 1 || weekday == 7)
            dateLabel.textColor = [UIColor colorWithRGBRed:142 green:142 blue:147 alpha:255];
        else
            dateLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
        NSDictionary *eventDict = [_dayEventTable objectForKey:dateKey];
        
        if( [dateKey isEqualToString:[A3DateHelper dateStringFromDate:[NSDate date] withFormat:@"yyyyMMdd"]] ){
            cell.contentView.backgroundColor = [UIColor colorWithRGBRed:0 green:122 blue:255 alpha:255];
            dateLabel.textColor = [UIColor whiteColor];
        }
        else{
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
        
        bottomView.hidden = NO;
        bottomLineView.hidden = NO;
        if( eventDict == nil ){
            bottomView.alpha = 1.0;
            lineImageView.hidden = YES;
            startCircle.hidden = YES;
            endCircle.hidden = YES;
            centerImageView.hidden = YES;
        }
        else{
            
            lineImageView.hidden = NO;
            NSInteger eventType = [[eventDict objectForKey:ItemKey_Type] integerValue];
            LadyCalendarPeriod *periodItem = [eventDict objectForKey:CalendarItem_Period];
            
            bottomView.alpha = ( [periodItem.isPredict boolValue] ? 0.4 : 1.0 );
            
            if( eventType == DetailCellType_MenstrualPeriod ){
                lineImageView.backgroundColor = [UIColor colorWithRGBRed:252 green:96 blue:66 alpha:255];
                centerImageView.hidden = YES;
                startCircle.centerCircleColor = lineImageView.backgroundColor;
                endCircle.centerCircleColor = lineImageView.backgroundColor;
                startCircle.hidden = ![[eventDict objectForKey:CalendarItem_IsPeriodStart] boolValue];
                endCircle.hidden = ![[eventDict objectForKey:CalendarItem_IsPeriodEnd] boolValue];
            }
            else if( eventType == DetailCellType_Ovulation ){
                lineImageView.backgroundColor = [UIColor colorWithRGBRed:238 green:230 blue:87 alpha:255];
                centerImageView.image =self.ovulationImage;
                centerImageView.hidden = NO;
                startCircle.hidden = YES;
                endCircle.hidden = YES;
            }
            else if( eventType == DetailCellType_Pregnancy ){
                lineImageView.backgroundColor = [UIColor colorWithRGBRed:44 green:201 blue:144 alpha:255];
                centerImageView.hidden = YES;
                startCircle.centerCircleColor = lineImageView.backgroundColor;
                endCircle.centerCircleColor = lineImageView.backgroundColor;
                startCircle.hidden = ![[eventDict objectForKey:CalendarItem_IsPeriodStart] boolValue];
                endCircle.hidden = ![[eventDict objectForKey:CalendarItem_IsPeriodEnd] boolValue];
            }
        }
    }
*/
    A3CalendarView *calendarView = (A3CalendarView*)[cell viewWithTag:10];
    calendarView.delegate = self;
    calendarView.account = currentAccount;
    calendarView.cellSize = CGSizeMake(floor(self.view.frame.size.width / 7), (IS_IPHONE ? 73.0 : 109.0)/numberOfMonthInPage);
    calendarView.isSmallCell = (numberOfMonthInPage > 1);
    calendarView.dateMonth = [A3DateHelper dateFromYear:indexPath.section+1970 month:indexPath.row+1 day:1 hour:12 minute:0 second:0];
    NSLog(@"%s %@ / %@, %ld/%ld",__FUNCTION__,calendarView.dateMonth,_currentMonth, (long)indexPath.section, (long)indexPath.row);
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
/*
    if( [self.sourceArray count] < 1 )
        return;
    NSDictionary *dict = [_sectionArray objectAtIndex:indexPath.section];
    NSInteger firstDayPosition = [[dict objectForKey:CalendarItem_FirstDayPosition] integerValue];
    NSInteger day = indexPath.row - firstDayPosition;
    NSDate *month = [dict objectForKey:CalendarItem_Month];
    NSDate *today = [A3DateHelper dateByAddingDays:day fromDate:month];
    NSString *dateKey = [A3DateHelper dateStringFromDate:today withFormat:@"yyyyMMdd"];
    
//    NSDictionary *eventDict = [_dayEventTable objectForKey:dateKey];
//    if( eventDict == nil )
//        return;
    
    A3LadyCalendarDetailViewController *viewCtrl = [[A3LadyCalendarDetailViewController alloc] initWithNibName:@"A3LadyCalendarDetailViewController" bundle:nil];
    viewCtrl.periodItems = [dict objectForKey:ItemKey_Items];
    viewCtrl.prevPeriod = [self previousPeriodFromIndexPath:indexPath];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[A3DateHelper dateStringFromDate:today withFormat:@"MMMM"] style:UIBarButtonItemStyleBordered target:nil action:nil];
    [self.navigationController pushViewController:viewCtrl animated:YES];
*/
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}
/*
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if( [self.sourceArray count] < 1 )
        return NO;
    NSDictionary *dict = [_sectionArray objectAtIndex:indexPath.section];
    NSInteger firstDayPosition = [[dict objectForKey:CalendarItem_FirstDayPosition] integerValue];
    
    return (indexPath.row >= firstDayPosition);
}
*/
#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *month = [A3DateHelper dateFromYear:indexPath.section+1970 month:indexPath.row+1 day:1 hour:12 minute:0 second:0];
    NSInteger numberOfWeeks = [A3DateHelper numberOfWeeksOfMonth:month];
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
    NSDate *month = [A3DateHelper dateFromYear:_currentIndexPath.section+1970 month:_currentIndexPath.row+1 day:1 hour:12 minute:0 second:0];
    if( ![self.currentMonth isEqual:month] ){
        self.currentMonth = month;
        [self updateStatus];
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
//        [self moveToCurrentMonth];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self calculateCurrentMonthWithScrollView:scrollView];
//    [self moveToCurrentMonth];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self calculateCurrentMonthWithScrollView:scrollView];
}

#pragma mark - A3CalendarViewDelegate
- (void)calendarView:(A3CalendarView *)calendarView didSelectDay:(NSInteger)day
{
    NSArray *periods = [[A3LadyCalendarModelManager sharedManager] periodListWithMonth:calendarView.dateMonth accountID:currentAccount.accountID containPredict:YES];
    if( [periods count] < 1 )
        return;
    LadyCalendarPeriod *period = [periods objectAtIndex:0];
    A3LadyCalendarDetailViewController *viewCtrl = [[A3LadyCalendarDetailViewController alloc] initWithNibName:@"A3LadyCalendarDetailViewController" bundle:nil];
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
    _chartButton.enabled = ([[A3LadyCalendarModelManager sharedManager] numberOfPeriodsWithAccountID:currentAccount.accountID] > 0);
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
//    [self performSelector:@selector(showCalendarHeaderView) withObject:nil afterDelay:0.3];
}

- (IBAction)moveToTodayAction:(id)sender {
    NSDate *month = [A3DateHelper dateMakeMonthFirstDayAtDate:[NSDate date]];
    NSInteger year = [A3DateHelper yearFromDate:month];
    NSInteger mon = [A3DateHelper monthFromDate:month];
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:mon-1 inSection:year-1970] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
//    NSInteger section = [self indexOfSectionArrayAtMonth:month];
//    if( section != NSNotFound )
//        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
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
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
    navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:navCtrl animated:YES completion:nil];
//    [self.navigationController pushViewController:viewCtrl animated:YES];
}

- (IBAction)moveToChartAction:(id)sender {
    if( IS_IPHONE )
        [self doneButtonAction:nil];
    A3LadyCalendarChartViewController *viewCtrl = [[A3LadyCalendarChartViewController alloc] initWithNibName:@"A3LadyCalendarChartViewController" bundle:nil];
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

- (IBAction)moveToAccountAction:(id)sender {
    if( IS_IPHONE )
        [self doneButtonAction:nil];
//    A3LadyCalendarAccountViewController *viewCtrl = [[A3LadyCalendarAccountViewController alloc] initWithNibName:@"A3LadyCalendarAccountViewController" bundle:nil];
    A3LadyCalendarAccountEditViewController *viewCtrl = [[A3LadyCalendarAccountEditViewController alloc] initWithNibName:@"A3LadyCalendarAccountEditViewController" bundle:nil];
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
    viewCtrl.isEditMode = NO;
    viewCtrl.periodItem = nil;
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
    navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:navCtrl animated:YES completion:nil];
}

@end
