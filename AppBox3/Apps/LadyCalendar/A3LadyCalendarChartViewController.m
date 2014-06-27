//
//  A3LadyCalendarChartViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LadyCalendarChartViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3LadyCalendarModelManager.h"
#import "A3DateHelper.h"
#import "LadyCalendarAccount.h"
#import "LadyCalendarPeriod.h"
#import "A3LineChartView.h"
#import "UIColor+A3Addition.h"
#import "NSDateFormatter+A3Addition.h"

@interface A3LadyCalendarChartViewController ()

@property (strong, nonatomic) NSArray *itemArray;
@property (strong, nonatomic) NSArray *cycleLengthArray;
@property (strong, nonatomic) NSArray *menstrualPeriodArray;
@property (strong, nonatomic) NSMutableArray *cycleYLabelArray;
@property (strong, nonatomic) NSMutableArray *cycleXLabelArray;
@property (strong, nonatomic) NSMutableArray *menstrualXLabelArray;
@property (strong, nonatomic) NSMutableArray *menstrualYLabelArray;

- (NSInteger)monthsFromCurrentSegment;
- (void)makeChartDataWithArray:(NSArray*)array;
@end

@implementation A3LadyCalendarChartViewController {
	NSInteger _minCycleLength;
	NSInteger _maxCycleLength;
	NSInteger _minMenstrualPeriod;
	NSInteger _maxMenstrualPeriod;
	NSInteger _xLabelDisplayInterval;
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
    self.title = NSLocalizedString(@"Chart", @"Chart");

    [self makeBackButtonEmptyArrow];
    _periodSegmentCtrl.selectedSegmentIndex = 0;
    _segmentLeftConst.constant = (IS_IPHONE ? 15.0 : 28.0);
    _segmentRightConst.constant = (IS_IPHONE ? 15.0 : 28.0);
    _separatorHeightConst.constant = 1.0 / [[UIScreen mainScreen] scale];
    NSArray *titleArray = @[
			(IS_IPHONE ? NSLocalizedString(@"6 Mos", @"6 Mos") : NSLocalizedString(@"6 Months", @"6 Months")),
			(IS_IPHONE ? NSLocalizedString(@"9 Mos", @"9 Mos") : NSLocalizedString(@"9 Months", @"9 Months")), NSLocalizedString(@"1 Year", @"1 Year"), NSLocalizedString(@"2 Years", @"2 Years")];
    _xLabelDisplayInterval = 1;
    for (NSInteger i=0; i < [_periodSegmentCtrl numberOfSegments];i++) {
        [_periodSegmentCtrl setTitle:[titleArray objectAtIndex:i] forSegmentAtIndex:i];
    }
	[self registerContentSizeCategoryDidChangeNotification];
}

- (void)removeObserver {
	[self removeContentSizeCategoryDidChangeNotification];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
}

- (void)dealloc {
	[self removeObserver];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES];
    [self periodChangedAction:_periodSegmentCtrl];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)contentSizeDidChange:(NSNotification *)notification {
	[self.tableView reloadData];
}

- (NSInteger)monthsFromCurrentSegment
{
	NSInteger retMonth = 0;

	switch ( _periodSegmentCtrl.selectedSegmentIndex ) {
		case 0:
			retMonth = 6;
			break;
		case 1:
			retMonth = 9;
			break;
		case 2:
			retMonth = 12;
			break;
		case 3:
			retMonth = 24;
			break;
	}

	return retMonth;
}

- (void)makeChartDataWithArray:(NSArray*)array
{
	NSMutableArray *cycleArray = [NSMutableArray array];
	NSMutableArray *periodArray = [NSMutableArray array];
	self.cycleXLabelArray = [NSMutableArray array];
	self.cycleYLabelArray = [NSMutableArray array];
	self.menstrualXLabelArray = [NSMutableArray array];
	self.menstrualYLabelArray = [NSMutableArray array];


	_minCycleLength = 0;
	_maxCycleLength = 0;
	_minMenstrualPeriod = -1;
	_maxMenstrualPeriod = -1;

    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    NSString *dateFormat = [dateFormatter formatStringByRemovingMediumYearComponent:[dateFormatter dateFormat]];
    
	for (NSInteger idx=0; idx < [array count]; idx++) {
		LadyCalendarPeriod *period = [array objectAtIndex:idx];
		LadyCalendarPeriod *nextPeriod = ( idx + 1 < [array count] ? [array objectAtIndex:idx + 1] : nil);
		NSInteger mensPeriod = [A3DateHelper diffDaysFromDate:period.startDate toDate:period.endDate];
		[periodArray addObject:[NSValue valueWithCGPoint:CGPointMake(idx, mensPeriod)]];
		_minMenstrualPeriod = ( _minMenstrualPeriod < 0 ? mensPeriod : MIN(_minMenstrualPeriod, mensPeriod) );
		_maxMenstrualPeriod = (_maxMenstrualPeriod < 0 ? mensPeriod : MAX(_maxMenstrualPeriod,mensPeriod));
		[_cycleXLabelArray addObject:[A3DateHelper dateStringFromDate:period.startDate withFormat:dateFormat]];

		NSInteger diffDays = 0;
		if ( nextPeriod == nil ) {
			diffDays = [period.cycleLength integerValue];
		}
		else {
			diffDays = [A3DateHelper diffDaysFromDate:period.startDate toDate:nextPeriod.startDate];
		}
		[cycleArray addObject:[NSValue valueWithCGPoint:CGPointMake(idx, diffDays)]];
		_minCycleLength = ( _minCycleLength == 0 ? diffDays : MIN(_minCycleLength,diffDays));
		_maxCycleLength = ( _maxCycleLength == 0 ? diffDays : MAX(_maxCycleLength, diffDays));

		[_menstrualXLabelArray addObject:[A3DateHelper dateStringFromDate:period.startDate withFormat:dateFormat]];
	}

	for (NSInteger i = _minCycleLength; i <= _maxCycleLength; i++) {
		[_cycleYLabelArray addObject:[NSString stringWithFormat:@"%ld", (long)i]];
    }
    
    NSMutableOrderedSet *filteredYLabelSet = [[NSMutableOrderedSet alloc] initWithArray:_cycleYLabelArray];
    if ([filteredYLabelSet count] <= 6) {
        _cycleYLabelArray = [NSMutableArray arrayWithArray:[filteredYLabelSet objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [filteredYLabelSet count])]]];
    }
    else {
        _cycleYLabelArray = [NSMutableArray arrayWithArray:[filteredYLabelSet objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [filteredYLabelSet count])]]];
        NSMutableArray *filteredYLabels = [NSMutableArray new];
        [filteredYLabels addObject:[_cycleYLabelArray firstObject]];
        for (NSInteger idx = 0; idx < 4; idx++) {
            NSString *mestrualY = [_cycleYLabelArray objectAtIndex:(([_cycleYLabelArray count] - 2) / 4) * (idx + 1)];
            if (mestrualY) {
                [filteredYLabels addObject:mestrualY];
            }
        }
        [filteredYLabels addObject:[_cycleYLabelArray lastObject]];
        self.cycleYLabelArray = filteredYLabels;
    }
    
	for (NSInteger i = _minMenstrualPeriod; i <= _maxMenstrualPeriod; i++) {
		[_menstrualYLabelArray addObject:[NSString stringWithFormat:@"%ld", (long) i]];
	}
    if ([_menstrualYLabelArray count] > 6) {
        NSMutableArray *filteredYLabels = [NSMutableArray new];
        [filteredYLabels addObject:[_menstrualYLabelArray firstObject]];
        for (NSInteger idx = 0; idx < 4; idx++) {
            NSString *mestrualY = [_menstrualYLabelArray objectAtIndex:(([_menstrualYLabelArray count] - 2) / 4) * (idx + 1)];
            if (mestrualY) {
                [filteredYLabels addObject:mestrualY];
            }
        }
        [filteredYLabels addObject:[_menstrualYLabelArray lastObject]];
        self.menstrualYLabelArray = filteredYLabels;
    }

	self.cycleLengthArray = [NSArray arrayWithArray:cycleArray];
	self.menstrualPeriodArray = [NSArray arrayWithArray:periodArray];

}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"chartCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if ( cell == nil ) {
        NSArray *cellArray = [[NSBundle mainBundle] loadNibNamed:@"A3LadyCalendarChartCell" owner:nil options:nil];
        cell = [cellArray objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *leftView = [cell viewWithTag:10];
        UIView *bottomView = [cell viewWithTag:11];
        for (NSLayoutConstraint *layout in cell.contentView.constraints) {
            if ( layout.firstAttribute == NSLayoutAttributeLeading && layout.firstItem == leftView )
                layout.constant = (IS_IPHONE ? 15.0 : 28.0);
            else if ( layout.firstAttribute == NSLayoutAttributeLeading && layout.firstItem == bottomView )
                layout.constant = (IS_IPHONE ? 15.0 : 28.0);
            else if ( layout.firstAttribute == NSLayoutAttributeTrailing && layout.secondItem ==  bottomView )
                layout.constant = (IS_IPHONE ? 18.0 : 28.0);
            else if ( layout.firstAttribute == NSLayoutAttributeTop && layout.firstItem == leftView )
                layout.constant = (indexPath.row == 0 ? (IS_IPHONE ? 11.0 : 26.0) :(IS_IPHONE ? 14.0 : 45.0));
            else if ( layout.firstAttribute == NSLayoutAttributeTop && layout.firstItem == bottomView )
                layout.constant = (IS_IPHONE ? 26.0 : 36.0);
        }
    }
    
    UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
    A3LineChartView *chartView = (A3LineChartView*)[cell viewWithTag:11];
    
    if ( indexPath.row == 0 ) {
        textLabel.text = NSLocalizedString(@"CYCLE LENGTH", @"CYCLE LENGTH");
        chartView.averageColor = [UIColor colorWithRGBRed:76 green:217 blue:100 alpha:255];
        chartView.xLabelItems = _cycleXLabelArray;
        chartView.yLabelItems = _cycleYLabelArray;
        chartView.showXLabel = NO;
        chartView.showYLabel = YES;
        chartView.minXValue = 0;
        chartView.minYValue = _minCycleLength;
        chartView.maxXValue = [_cycleXLabelArray count];
        chartView.maxYValue = _maxCycleLength;
        chartView.xLabelDisplayInterval = _xLabelDisplayInterval;
        chartView.valueArray = _cycleLengthArray;
    }
    else if ( indexPath.row == 1 ) {
        textLabel.text = NSLocalizedString(@"MENSTRUAL PERIOD", @"MENSTRUAL PERIOD");
        chartView.averageColor = [UIColor colorWithRGBRed:255 green:45 blue:85 alpha:255];
        chartView.xLabelItems = _menstrualXLabelArray;
        chartView.yLabelItems = _menstrualYLabelArray;
        chartView.showXLabel = YES;
        chartView.showYLabel = YES;
        chartView.minXValue = 0;
        chartView.minYValue = _minMenstrualPeriod;
        chartView.maxXValue = [_menstrualXLabelArray count];
        chartView.maxYValue = _maxMenstrualPeriod;
        chartView.xLabelDisplayInterval = _xLabelDisplayInterval;
        chartView.valueArray = _menstrualPeriodArray;
    }

    [chartView setNeedsDisplay];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row == 0 ? 236.0 : (IS_IPHONE ? 236 : 270));
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - action method

- (IBAction)periodChangedAction:(id)sender {
    NSInteger periodMonth = [self monthsFromCurrentSegment];
    if ( IS_IPAD ) {
        if ( periodMonth == 24 )
            _xLabelDisplayInterval = 2;
        else
            _xLabelDisplayInterval = 1;
    }
    else {
        switch (periodMonth) {
            case 9:
                _xLabelDisplayInterval = 2;
                break;
            case 12:
                _xLabelDisplayInterval = 3;
                break;
            case 24:
                _xLabelDisplayInterval = 4;
                break;
                
            default:
                _xLabelDisplayInterval = 1;
                break;
        }
    }
    NSDate *currentMonth = [A3DateHelper dateMakeMonthFirstDayAtDate:[NSDate date]];
    NSDate *fromMonth = [A3DateHelper dateByAddingMonth:1 fromDate:currentMonth];
    LadyCalendarAccount *account = [_dataManager currentAccount];
    self.itemArray = [_dataManager periodListWithMonth:fromMonth period:periodMonth accountID:account.uniqueID];
    if ( [self.itemArray count] > 0 ) {
        [self makeChartDataWithArray:_itemArray];
    }
    [self.tableView reloadData];
}

@end
