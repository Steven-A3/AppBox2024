//
//  A3BatteryStatusMainViewController.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 12/4/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3BatteryStatusMainViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "UIViewController+iPad_rightSideView.h"
#import "A3BatteryStatusManager.h"
#import "A3BatterStatusBatteryPanelView.h"
#import "A3BatteryStatusListPageSectionView.h"
#import "A3BatteryStatusSettingViewController.h"
#import "A3BasicWebViewController.h"
#import "A3DefaultColorDefines.h"
#import "A3RootViewController_iPad.h"
#import "A3AppDelegate.h"
#import "UIColor+A3Addition.h"

@interface A3BatteryStatusMainViewController ()
@property (nonatomic, strong) A3BatteryStatusSettingViewController * settingViewController;
@property (nonatomic, strong) A3BatteryStatusListPageSectionView *sectionHeaderView;
@end

@implementation A3BatteryStatusMainViewController
{
    NSArray * _tableDataSourceArray;
    A3BatterStatusBatteryPanelView *_headerView;
    UIView *_topWhitePaddingView;
}

- (id)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {

	}

	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	[self makeBackButtonEmptyArrow];
	[self leftBarButtonAppsButton];
    [self rightBarButton];
    
    if (IS_IPAD) {
        self.navigationItem.hidesBackButton = YES;
    }
    
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;

    self.title = @"Battery Status";
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorColor = COLOR_TABLE_SEPARATOR;
    self.tableView.tableFooterView = nil;

    self.tableView.tableHeaderView = self.headerView;
    if (IS_IPAD) {
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 28.0, 0, 0);
    }
    
    [self setupTopWhitePaddingView];
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidShow) name:A3NotificationMainMenuDidShow object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewDidAppear) name:A3NotificationRightSideViewDidAppear object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewWillDismiss) name:A3NotificationRightSideViewWillDismiss object:nil];
	}
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
	[self refreshHeaderView];
	[self reloadTableViewDataSource];
	[self.tableView reloadData];
}

- (void)enableControls:(BOOL)enable {
	if (!IS_IPAD) return;
	[self.navigationItem.leftBarButtonItem setEnabled:enable];
	[self.navigationItem.rightBarButtonItem setEnabled:enable];
	[self.sectionHeaderView.tableSegmentButton setTintColor:enable ? nil : SEGMENTED_CONTROL_DISABLED_TINT_COLOR2];
	[self.sectionHeaderView.tableSegmentButton setEnabled:enable];
}

- (void)dealloc {
	[self removeObserver];
}

- (void)setupTopWhitePaddingView
{
    _topWhitePaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.0)];
    _topWhitePaddingView.backgroundColor = [UIColor whiteColor];
    _topWhitePaddingView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    [self.tableView addSubview:_topWhitePaddingView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

	[self refreshHeaderView];
    [self reloadTableViewDataSource];
    [self.tableView reloadData];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(batteryLevelDidChangeNotification:)
												 name:UIDeviceBatteryLevelDidChangeNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(batteryStateDidChangeNotification:)
												 name:UIDeviceBatteryStateDidChangeNotification
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(batteryThemeChanged)
												 name:A3BatteryStatusThemeColorChanged
											   object:nil];
}

#pragma mark -
- (void)reloadTableViewDataSource
{
    if (self.sectionHeaderView.tableSegmentButton.selectedSegmentIndex == 0) {
        _tableDataSourceArray = [A3BatteryStatusManager deviceInfoDataArray];
    } else {
        _tableDataSourceArray = [A3BatteryStatusManager remainTimeDataArray];
        NSArray * adjustedIndex = [A3BatteryStatusManager adjustedIndex];
        if (adjustedIndex) {
            NSMutableArray * array = [NSMutableArray arrayWithCapacity:_tableDataSourceArray.count];
            for (NSDictionary *rowDic in adjustedIndex) {
                NSNumber *index = [rowDic objectForKey:@"index"];
                NSNumber *checked = [rowDic objectForKey:@"checked"];
                
                if ([checked isEqualToNumber:@1] && (index.integerValue < _tableDataSourceArray.count) ) {
                    [array addObject:[_tableDataSourceArray objectAtIndex:index.integerValue]];
                }
            }
            
            _tableDataSourceArray = array;
        }
    }
}

- (void)batteryThemeChanged {
	[self refreshHeaderView];
}

- (A3BatteryStatusListPageSectionView *)sectionHeaderView {
	if (!_sectionHeaderView) {
		_sectionHeaderView = [[A3BatteryStatusListPageSectionView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 56.0)];
		[_sectionHeaderView.tableSegmentButton addTarget:self action:@selector(sectionSegmentControlChanged:) forControlEvents:UIControlEventValueChanged];
		_sectionHeaderView.tableSegmentButton.selectedSegmentIndex = 0;
	}
	return _sectionHeaderView;
}

- (void)cleanUp {
	[self removeObserver];
	[UIDevice currentDevice].batteryMonitoringEnabled = NO;
}

-(void)rightBarButton {
    UIImage *image = [UIImage imageNamed:@"general"];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(generalButtonAction:)];
    
    self.navigationItem.rightBarButtonItem = buttonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(A3BatterStatusBatteryPanelView *)headerView {
	if (!_headerView) {
		CGFloat height;
		if (IS_IPHONE) {
			height = 219.0;
		}
        else {
			if (IS_LANDSCAPE) {
				height = 275.0;
			} else {
				height = 321.0;
			}
		}

		_headerView = [[A3BatterStatusBatteryPanelView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, height)];
	}
	return _headerView;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    CGRect rect = self.headerView.frame;
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        rect.size.height = 275.0;
    }
    else {
        rect.size.height = 321.0;
    }
    _headerView.frame = rect;
    [UIView animateWithDuration:duration animations:^{
        [self.tableView setTableHeaderView:_headerView];
    }];

	[self refreshHeaderView];
}

#pragma mark - Actions

- (void)generalButtonAction:(id)sender {
	self.settingViewController = [[A3BatteryStatusSettingViewController alloc] initWithStyle:UITableViewStyleGrouped];
	[self presentSubViewController:self.settingViewController];
}

#pragma mark - Battery Notifications

- (void)batteryLevelDidChangeNotification:(NSNotification *)notification {
	[self refreshHeaderView];
}

- (void)batteryStateDidChangeNotification:(NSNotification *)notification {
	[self refreshHeaderView];
}

- (void)refreshHeaderView {
	_headerView.batteryColor = [A3BatteryStatusManager chosenTheme];
	[_headerView setBatteryRemainingPercent:abs([[UIDevice currentDevice] batteryLevel] * 100) state:[[UIDevice currentDevice] batteryState]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tableDataSourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_sectionHeaderView.tableSegmentButton.selectedSegmentIndex==0) {
        NSString *chips = [_tableDataSourceArray[indexPath.row] objectForKey:@"value"];
        if ([chips rangeOfString:@"\n"].location==NSNotFound) {
            return 44.0;
        } else {
            return 62.0;
        }
    }
    
    return 44.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.sectionHeaderView;
}

static NSString *CellIdentifier = @"Cell";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        ///cell.textLabel.font = IS_IPHONE ? [UIFont fontWithName:cell.textLabel.font.fontName size:15] : [UIFont fontWithName:cell.textLabel.font.fontName size:17];
        //cell.detailTextLabel.font = IS_IPHONE ? [UIFont fontWithName:cell.textLabel.font.fontName size:15] : [UIFont fontWithName:cell.textLabel.font.fontName size:17];
        cell.textLabel.font = IS_IPHONE ? [UIFont systemFontOfSize:15] : [UIFont systemFontOfSize:17];
        cell.detailTextLabel.font = IS_IPHONE ? [UIFont systemFontOfSize:15] : [UIFont systemFontOfSize:17];

        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
        
        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.detailTextLabel.numberOfLines = 0;
        
        [cell.textLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(cell.centerY);
        }];
    }
    
    // Configure the cell...
    NSDictionary *rowData = [_tableDataSourceArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [rowData objectForKey:@"title"];

    if (_sectionHeaderView.tableSegmentButton.selectedSegmentIndex==0) {
        cell.detailTextLabel.text = [rowData objectForKey:@"value"];
    } else {
        NSInteger maxTime = [[rowData objectForKey:@"value"] integerValue];
        NSInteger remainingMinute = (maxTime*60) * [[UIDevice currentDevice] batteryLevel];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld hours, %ld Minutes", labs(remainingMinute/60), labs(remainingMinute%60)];
    }
    
    return cell;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_topWhitePaddingView) {
        if (scrollView.contentOffset.y < -scrollView.contentInset.top ) {
            CGRect rect = _topWhitePaddingView.frame;
            rect.origin.y = -(fabs(scrollView.contentOffset.y) - scrollView.contentInset.top);
            rect.size.height = fabs(scrollView.contentOffset.y) - scrollView.contentInset.top;
            _topWhitePaddingView.frame = rect;
        } else {
            CGRect rect = _topWhitePaddingView.frame;
            rect.origin.y = 0.0;
            rect.size.height = 0.0;
            _topWhitePaddingView.frame = rect;
        }
    }
}

#pragma mark - List Page Section
-(void)sectionSegmentControlChanged:(id)sender {
    UISegmentedControl *sectionSegment = (UISegmentedControl *)sender;
    
    if (sectionSegment.selectedSegmentIndex==0) {
        _tableDataSourceArray = [A3BatteryStatusManager deviceInfoDataArray];
    } else {
        _tableDataSourceArray = [A3BatteryStatusManager remainTimeDataArray];
        NSArray * adjustedIndex = [A3BatteryStatusManager adjustedIndex];
        if (adjustedIndex) {
            //NSAssert(_tableDataSourceArray.count == adjustedIndex.count, @"둘이 같아야 합니다.");
            
            NSMutableArray * array = [NSMutableArray arrayWithCapacity:_tableDataSourceArray.count];
            for (NSDictionary *rowDic in adjustedIndex) {
                NSNumber *index = [rowDic objectForKey:@"index"];
                NSNumber *checked = [rowDic objectForKey:@"checked"];
                
                if ([checked isEqualToNumber:@1] && (index.integerValue < _tableDataSourceArray.count)) {
                    [array addObject:[_tableDataSourceArray objectAtIndex:index.integerValue]];
                }
            }
            
            _tableDataSourceArray = array;
        }
    }
    
    [self.tableView reloadData];
}

@end
