//
//  A3LadyCalendarDetailViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LadyCalendarDetailViewController.h"
#import "UIViewController+A3AppCategory.h"
#import "A3LadyCalendarDefine.h"
#import "A3LadyCalendarModelManager.h"
#import "LadyCalendarPeriod.h"
#import "A3DateHelper.h"
#import "A3LadyCalendarAddPeriodViewController.h"
#import "UIColor+A3Addition.h"
#import "NSDate+calculation.h"
#import "A3LadyCalendarDetailViewCell.h"
#import "A3LadyCalendarDetailViewTitleCell.h"
#import "A3LadyCalendarDetailViewExpectedTitleCell.h"
#import "NSDate+formatting.h"
#import "A3WalletNoteCell.h"
#import "UIViewController+A3Addition.h"

extern NSString *A3TableViewCellDefaultCellID;
NSString *const A3LadyCalendarDetailViewTitleCellID = @"A3LadyCalendarDetailViewTitleCellID";
NSString *const A3LadyCalendarDetailViewExpectedTitleCellID = @"A3LadyCalendarDetailViewExpectedTitleCellID";
NSString *const A3LadyCalendarDetailViewCellID = @"A3LadyCalendarDetailViewCellID";
extern NSString *const A3WalletItemFieldNoteCellID;

@interface A3LadyCalendarDetailViewController ()

@property (strong, nonatomic) A3LadyCalendarModelManager *dataManager;
@property (strong, nonatomic) NSArray *rowDataArray;

@end

@implementation A3LadyCalendarDetailViewController {
	BOOL isEditNavigationBar;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.title = @"";

	if (_isFromNotification) {
		self.title = @"Lady Calendar";
		[self rightBarButtonDoneButton];
	}
	if (_periodID) {
		LadyCalendarPeriod *period = [LadyCalendarPeriod MR_findFirstByAttribute:@"uniqueID" withValue:_periodID];
		_periodItems = [NSMutableArray arrayWithArray:@[ period ] ];
		_month = period.startDate;
	}

	self.tableView.separatorInset = UIEdgeInsetsMake(0, (IS_IPHONE ? 15.0 : 28.0), 0, 0);
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:A3TableViewCellDefaultCellID];
	[self.tableView registerClass:[A3LadyCalendarDetailViewCell class] forCellReuseIdentifier:A3LadyCalendarDetailViewCellID];
	[self.tableView registerClass:[A3LadyCalendarDetailViewTitleCell class] forCellReuseIdentifier:A3LadyCalendarDetailViewTitleCellID];
	[self.tableView registerClass:[A3LadyCalendarDetailViewExpectedTitleCell class] forCellReuseIdentifier:A3LadyCalendarDetailViewExpectedTitleCellID];
	[self.tableView registerClass:[A3WalletNoteCell class] forCellReuseIdentifier:A3WalletItemFieldNoteCellID];

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

	if (![self isMovingToParentViewController]) {
		[self.dataManager recalculateDates];
		_periodItems = [NSMutableArray arrayWithArray:[_dataManager periodListStartsInMonth:[_month firstDateOfMonth]]];
		if ([_periodItems count] == 0) {
			[self.navigationController popViewControllerAnimated:YES];
			return;
		}
	}
	[self setupSectionsWithItems:_periodItems];
	[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)contentSizeDidChange:(NSNotification *)notification {
	[self.tableView reloadData];
}

- (A3LadyCalendarModelManager *)dataManager {
	if (!_dataManager) {
		_dataManager = [A3LadyCalendarModelManager new];
	}
	return _dataManager;
}

- (void)setupSectionsWithItems:(NSArray*)array
{
    NSMutableArray *rowDataArray = [NSMutableArray array];

	NSUInteger indexOfData = 0;
    for( LadyCalendarPeriod *period in array ){
		[rowDataArray addObjectsFromArray:[self rowDataForItemIsPredict:[period.isPredict boolValue] startDate:period.startDate notes:period.notes index:indexOfData]];

		indexOfData++;
    }

	if (!_isFromNotification) {
		isEditNavigationBar = ( [array count] == 1 );
		if( isEditNavigationBar ){
			self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction:)];
			self.navigationItem.rightBarButtonItem.width = 44.0;
		} else {
			self.navigationItem.rightBarButtonItem = nil;
		}
	}
    else {
		isEditNavigationBar = YES;
	}

	[rowDataArray addObject:@{ItemKey_Type:@(DetailCellType_Blank)}];

    self.rowDataArray = rowDataArray;
}

- (NSArray *)rowDataForItemIsPredict:(BOOL)isPredict startDate:(NSDate *)startDate notes:(NSString *)notes index:(NSUInteger)index {
	NSMutableArray *retArray = [NSMutableArray array];
	if( isPredict ){
		[retArray addObject:@{ItemKey_Title : @"Expected Period(+/-2 days)",ItemKey_Type : @(DetailCellType_Title), ItemKey_Index : @(index)}];
		[retArray addObject:@{ItemKey_Title : @"Increased Probability of Pregnancy", ItemKey_Type : @(DetailCellType_Pregnancy), ItemKey_Index : @(index)}];
		[retArray addObject:@{ItemKey_Title : @"Ovulation - Highest Probability",ItemKey_Type : @(DetailCellType_Ovulation), ItemKey_Index : @(index)}];
		[retArray addObject:@{ItemKey_Title : @"Menstrual Period",ItemKey_Type : @(DetailCellType_MenstrualPeriod), ItemKey_Index : @(index)}];
	}
	else{
		[retArray addObject:@{ItemKey_Title : @"Menstrual Period", ItemKey_Type : @(DetailCellType_Title), ItemKey_Index : @(index)}];
		[retArray addObject:@{ItemKey_Title : @"Start Date", ItemKey_Type: @(DetailCellType_StartDate), ItemKey_Index : @(index)}];
		[retArray addObject:@{ItemKey_Title : @"End Date",ItemKey_Type : @(DetailCellType_EndDate), ItemKey_Index : @(index)}];
		[retArray addObject:@{ItemKey_Title : @"Cycle Length",ItemKey_Type : @(DetailCellType_CycleLength), ItemKey_Index : @(index), ItemKey_RowHeight:(![notes length] ? @75 : @74)}];
		if( [notes length] > 0)
			[retArray addObject:@{ItemKey_Title : @"Notes",ItemKey_Type : @(DetailCellType_Notes), ItemKey_Index : @(index)}];
	}

	return retArray;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.rowDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *rowInfo = self.rowDataArray[(NSUInteger) indexPath.row];
	LadyCalendarPeriod *period = _periodItems[ [rowInfo[ItemKey_Index] integerValue] ];

	UITableViewCell *returnCell;
	switch ((A3LadyCalendarDetailCellType)[rowInfo[ItemKey_Type] integerValue]) {
		case DetailCellType_Title: {
			if (![period.isPredict boolValue]) {
				A3LadyCalendarDetailViewTitleCell *titleCell = [tableView dequeueReusableCellWithIdentifier:A3LadyCalendarDetailViewTitleCellID forIndexPath:indexPath];
				titleCell.titleLabel.text = rowInfo[ItemKey_Title];
				titleCell.subTitleLabel.text = [NSString stringWithFormat:@"Updated %@", [period.modificationDate a3FullStyleString]];
				[titleCell.editButton setHidden:isEditNavigationBar];
				[titleCell.editButton addTarget:self action:@selector(editDetailItem:) forControlEvents:UIControlEventTouchUpInside];
				titleCell.editButton.tag = indexPath.row;

				returnCell = titleCell;
			} else {
				A3LadyCalendarDetailViewExpectedTitleCell *titleCell = [tableView dequeueReusableCellWithIdentifier:A3LadyCalendarDetailViewExpectedTitleCellID forIndexPath:indexPath];
				titleCell.titleLabel.text = rowInfo[ItemKey_Title];
				[titleCell.editButton setHidden:isEditNavigationBar];
				[titleCell.editButton addTarget:self action:@selector(editDetailItem:) forControlEvents:UIControlEventTouchUpInside];
				titleCell.editButton.tag = indexPath.row;

				returnCell = titleCell;
			}
			break;
		}
		case DetailCellType_StartDate: {
			A3LadyCalendarDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:A3LadyCalendarDetailViewCellID forIndexPath:indexPath];
			cell.titleLabel.text = rowInfo[ItemKey_Title];
			cell.subTitleLabel.text = [period.startDate a3FullStyleString];

			returnCell = cell;
			break;
		}
		case DetailCellType_EndDate:{
			A3LadyCalendarDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:A3LadyCalendarDetailViewCellID forIndexPath:indexPath];
			cell.titleLabel.text = rowInfo[ItemKey_Title];
			cell.subTitleLabel.text = [period.endDate a3FullStyleString];

			returnCell = cell;
			break;
		}
		case DetailCellType_CycleLength:{
			A3LadyCalendarDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:A3LadyCalendarDetailViewCellID forIndexPath:indexPath];
			cell.titleLabel.text = rowInfo[ItemKey_Title];
			cell.subTitleLabel.text = [NSString stringWithFormat:@"%ld", (long)[period.cycleLength integerValue]];

			returnCell = cell;
			break;
		}
		case DetailCellType_Notes:{
			A3WalletNoteCell *cell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemFieldNoteCellID forIndexPath:indexPath];
			[cell setupTextView];
			[cell.textView setEditable:NO];
			[cell.textView setScrollEnabled:NO];
			[cell setNoteText:period.notes];

			returnCell = cell;
			break;
		}
		case DetailCellType_Pregnancy:{
			A3LadyCalendarDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:A3LadyCalendarDetailViewCellID forIndexPath:indexPath];
			cell.titleLabel.text = rowInfo[ItemKey_Title];
			cell.titleLabel.textColor = [UIColor colorWithRGBRed:44 green:201 blue:144 alpha:255];

			NSDate *ovulationDate = [A3DateHelper dateByAddingDays:-14 fromDate:period.startDate];
			NSDate *pregnantStartDate = [A3DateHelper dateByAddingDays:-4 fromDate:ovulationDate];
			NSDate *pregnantEndDate = [A3DateHelper dateByAddingDays:5 fromDate:ovulationDate];

			cell.subTitleLabel.text = [NSString stringWithFormat:@"%@ - %@", [pregnantStartDate a3FullStyleString], [pregnantEndDate a3FullStyleString]];

			returnCell = cell;
			break;
		}
		case DetailCellType_Ovulation:{
			A3LadyCalendarDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:A3LadyCalendarDetailViewCellID forIndexPath:indexPath];
			cell.titleLabel.text = rowInfo[ItemKey_Title];
			cell.titleLabel.textColor = [UIColor colorWithRGBRed:238 green:230 blue:87 alpha:255];

			NSDate *ovulationDate = [A3DateHelper dateByAddingDays:-14 fromDate:period.startDate];
			cell.subTitleLabel.text = [ovulationDate a3FullStyleString];

			returnCell = cell;
			break;
		}
		case DetailCellType_MenstrualPeriod:{
			A3LadyCalendarDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:A3LadyCalendarDetailViewCellID forIndexPath:indexPath];
			cell.titleLabel.text = rowInfo[ItemKey_Title];
			cell.titleLabel.textColor = [UIColor colorWithRGBRed:252 green:96 blue:66 alpha:255];
			cell.subTitleLabel.text = [NSString stringWithFormat:@"%@ - %@", [period.startDate a3FullStyleString], [period.endDate a3FullStyleString]];

			returnCell = cell;
			break;
		}
		case DetailCellType_DescTitle: {
			break;
		}
		case DetailCellType_Blank: {
			returnCell = [tableView dequeueReusableCellWithIdentifier:A3TableViewCellDefaultCellID forIndexPath:indexPath];
			break;
		}
	}
	returnCell.selectionStyle = UITableViewCellSelectionStyleNone;

	return returnCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat retHeight = 74.0;
    
    NSDictionary *rowInfo = [_rowDataArray objectAtIndex:indexPath.row];
    NSInteger cellType = [[rowInfo objectForKey:ItemKey_Type] integerValue];
	LadyCalendarPeriod *period = _periodItems[[rowInfo[ItemKey_Index] integerValue]];
    if( cellType == DetailCellType_Notes ){
        NSString *str = ( [period.notes length] > 0 ? period.notes : @"" );
        CGRect strBounds = [str boundingRectWithSize:CGSizeMake(tableView.frame.size.width - (IS_IPHONE ? 20.0 : 43.0), CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17.0]} context:nil];
        retHeight = MAX((strBounds.size.height + 31.0), 74.0);
    } else if (cellType == DetailCellType_Title && [period.isPredict boolValue]) {
		retHeight = 44.0;
	} else if (cellType == DetailCellType_Blank) {
		retHeight = 36;
	} else if (rowInfo[ItemKey_RowHeight]) {
		retHeight = (CGFloat)[rowInfo[ItemKey_RowHeight] doubleValue];
	}

	FNLOG(@"%ld, %ld, %f", (long)indexPath.section, (long)indexPath.row, retHeight);
    return retHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	return [UIView new];
}

#pragma mark - action method

- (void)editAction:(id)sender
{
    A3LadyCalendarAddPeriodViewController *viewCtrl = [[A3LadyCalendarAddPeriodViewController alloc] initWithNibName:@"A3LadyCalendarAddPeriodViewController" bundle:nil];
	viewCtrl.dataManager = self.dataManager;
    viewCtrl.isEditMode = YES;
    viewCtrl.periodItem = [_periodItems objectAtIndex:0];
	UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
    navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:navCtrl animated:YES completion:nil];
}

- (void)editDetailItem:(UIButton *)button
{
	NSDictionary *rowInfo = _rowDataArray[button.tag];
    
    LadyCalendarPeriod *item = _periodItems[(NSUInteger) [rowInfo[ItemKey_Index] integerValue]];

	A3LadyCalendarAddPeriodViewController *viewCtrl = [[A3LadyCalendarAddPeriodViewController alloc] initWithNibName:@"A3LadyCalendarAddPeriodViewController" bundle:nil];
	viewCtrl.dataManager = self.dataManager;
    viewCtrl.isEditMode = YES;
    viewCtrl.periodItem = item;
	UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
    navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:navCtrl animated:YES completion:nil];
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
	[self dismissViewControllerAnimated:YES completion:NULL];
}

@end
