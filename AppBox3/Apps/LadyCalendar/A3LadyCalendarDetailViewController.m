//
//  A3LadyCalendarDetailViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LadyCalendarDetailViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "A3LadyCalendarDefine.h"
#import "A3LadyCalendarModelManager.h"
#import "LadyCalendarAccount.h"
#import "LadyCalendarPeriod.h"
#import "A3DateHelper.h"
#import "A3LadyCalendarAddPeriodViewController.h"
#import "UIColor+A3Addition.h"

#define CELLID_TITLE    @"titleAndFirstCell"
#define CELLID_SUBITEM  @"detailSubCell"

@interface A3LadyCalendarDetailViewController ()
@property (strong, nonatomic) NSArray *sectionsArray;

- (void)editAction:(id)sender;
- (void)setupSectionsWithItems:(NSArray*)array;
- (void)editDetailItem:(id)sender;

@end

@implementation A3LadyCalendarDetailViewController {
	LadyCalendarAccount *currentAccount;
	BOOL isEditNavigationBar;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.title = @"";
	self.tableView.separatorInset = UIEdgeInsetsMake(0, (IS_IPHONE ? 15.0 : 28.0), 0, 0);

	[self registerContentSizeCategoryDidChangeNotification];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setToolbarHidden:YES];

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

- (NSArray*)templateForItemIsPredict:(BOOL)isPredict startDate:(NSDate*)startDate endDate:(NSDate*)endDate notes:(NSString*)notes
{
    NSDate *currentDate = [A3DateHelper dateMake12PM:[NSDate date]];
    BOOL isCurrent = ([startDate timeIntervalSince1970] >= [currentDate timeIntervalSince1970] );

    NSMutableArray *retArray = [NSMutableArray array];
    if( isPredict ){
        [retArray addObject:@{ItemKey_Title : @"Expected Period(+/-2 days)",ItemKey_Type : @(DetailCellType_Title)}];
        [retArray addObject:@{ItemKey_Title : @"Ovulation - Highest Probability",ItemKey_Type : @(DetailCellType_Ovulation)}];
        [retArray addObject:@{ItemKey_Title : @"Menstrual Period",ItemKey_Type : @(DetailCellType_MenstrualPeriod)}];
    }
    else{
        [retArray addObject:@{ItemKey_Title : [NSString stringWithFormat:@"%@Menstrual Period",(isCurrent ? @"Current " : @"")],ItemKey_Type : @(DetailCellType_Title)}];
        [retArray addObject:@{ItemKey_Title : @"End Date",ItemKey_Type : @(DetailCellType_EndDate)}];
        [retArray addObject:@{ItemKey_Title : @"Cycle Length",ItemKey_Type : @(DetailCellType_CycleLength)}];
        if( [notes length] > 0)
            [retArray addObject:@{ItemKey_Title : @"Notes",ItemKey_Type : @(DetailCellType_Notes)}];
    }
    
    return retArray;
}

- (void)setupSectionsWithItems:(NSArray*)array
{
    NSMutableArray *sectionsArray = [NSMutableArray array];
    NSDate *today = [NSDate date];
    NSDate *monthFirstDay = [A3DateHelper dateFromYear:[A3DateHelper yearFromDate:_month] month:[A3DateHelper monthFromDate:_month] day:1 hour:0 minute:0 second:0];
    NSDate *nextMonth = [A3DateHelper dateByAddingMonth:1 fromDate:monthFirstDay];
    NSInteger editableCount = 0;
    for( LadyCalendarPeriod *item in array ){
        NSArray *tmpArray = [self templateForItemIsPredict:[item.isPredict boolValue] startDate:item.startDate endDate:item.endDate notes:item.notes];
        [sectionsArray addObject:tmpArray];
        if( ![item.isPredict boolValue] || [item.startDate timeIntervalSince1970] < [today timeIntervalSince1970] )
            editableCount++;
        
        if( item == [array lastObject] ){
            LadyCalendarPeriod *nextPeriod = [_dataManager nextPeriodFromDate:item.startDate accountID:_dataManager.currentAccount.uniqueID];

            NSDate *nextStartDate = ( nextPeriod ? nextPeriod.startDate : [A3DateHelper dateByAddingDays:[item.cycleLength integerValue] fromDate:item.startDate] );
            NSDate *nextEndDate = ( nextPeriod ? nextPeriod.endDate : [A3DateHelper dateByAddingDays:4 fromDate:nextStartDate] );
            NSDate *ovulationDate = [A3DateHelper dateByAddingDays:-14 fromDate:nextStartDate];
            
            NSDate *pregStDate = [A3DateHelper dateByAddingDays:-4 fromDate:ovulationDate];
            if( [pregStDate timeIntervalSince1970] < [nextMonth timeIntervalSince1970] ){
                tmpArray = [self templateForItemIsPredict:YES startDate:nextStartDate endDate:nextEndDate notes:nil];
                [sectionsArray addObject:tmpArray];
				[_periodItems addObject:nextPeriod];

                if( nextPeriod && (![nextPeriod.isPredict boolValue] || [nextStartDate timeIntervalSince1970] < [today timeIntervalSince1970]))
                    editableCount++;
			}
        }
    }
    
    isEditNavigationBar = ( editableCount == 1 );
    if( isEditNavigationBar ){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction:)];
        self.navigationItem.rightBarButtonItem.width = 44.0;
    }
    else
        self.navigationItem.rightBarButtonItem = nil;
    
    self.sectionsArray = [NSArray arrayWithArray:sectionsArray];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_sectionsArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *items = [_sectionsArray objectAtIndex:section];
    return [items count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *items = [_sectionsArray objectAtIndex:indexPath.section];
    NSDictionary *dict = [items objectAtIndex:indexPath.row];
    NSInteger cellType = [[dict objectForKey:ItemKey_Type] integerValue];
	LadyCalendarPeriod *periodItem = _periodItems[indexPath.section];

    NSString *CellIdentifier = ( cellType == DetailCellType_Title ? CELLID_TITLE : CELLID_SUBITEM);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        NSArray *cellArray = [[NSBundle mainBundle] loadNibNamed:@"A3LadyCalendarListCell" owner:nil options:nil];
        
        if( [CellIdentifier isEqualToString:CELLID_TITLE] ){
            cell = [cellArray objectAtIndex:4];
            
            UIView *topView = [cell viewWithTag:10];
            UIButton *editButton = (UIButton*)[topView viewWithTag:22];
            [editButton addTarget:self action:@selector(editDetailItem:) forControlEvents:UIControlEventTouchUpInside];
        }
        else{
            cell = [cellArray objectAtIndex:3];
        }
        UIView *leftView1 = [cell viewWithTag:10];
        UIView *leftView2 = [cell viewWithTag:11];
        for(NSLayoutConstraint *layout in cell.contentView.constraints){
            if( layout.firstAttribute == NSLayoutAttributeLeading && (layout.firstItem == leftView1 || layout.firstItem == leftView2) ){
                layout.constant = (IS_IPHONE ? 15.0 : 28.0);
            }
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDate *startDate = periodItem.startDate;
    NSDate *endDate = periodItem.endDate;
    BOOL isPredict = [periodItem.isPredict boolValue];
    if( cellType == DetailCellType_Title ){
        UIView *topView = [cell viewWithTag:10];
        UIView *bottomView = [cell viewWithTag:11];
        
        UILabel *sectionTitleLabel = (UILabel*)[topView viewWithTag:20];
		sectionTitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];

        UILabel *sectionDetailLabel = (UILabel*)[topView viewWithTag:21];
		sectionDetailLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];

        UIButton *editButton = (UIButton*)[topView viewWithTag:22];
        
        UILabel *textLabel = (UILabel*)[bottomView viewWithTag:20];
        UILabel *detailTextLabel = (UILabel*)[bottomView viewWithTag:21];
        
        NSDate *today = [NSDate date];
        BOOL showButton = NO;
        if(!isEditNavigationBar && [startDate timeIntervalSince1970] <= [today timeIntervalSince1970] )
            showButton = YES;
        
        editButton.hidden = !showButton;
        
        sectionTitleLabel.text = [dict objectForKey:ItemKey_Title];
        if( !isPredict ){
            sectionDetailLabel.text = [NSString stringWithFormat:@"Updated %@",[_dataManager dateStringForDate:periodItem.modificationDate]];
        }
        else{
            sectionDetailLabel.text = @"";
        }
        
        textLabel.text = (isPredict ? @"Increased Probability of Pregnancy" : @"Start Date");
        if( isPredict ){
            NSDate *ovulationDate = [A3DateHelper dateByAddingDays:-14 fromDate:startDate];
            NSDate *pregStDate = [A3DateHelper dateByAddingDays:-4 fromDate:ovulationDate];
            NSDate *pregEdDate = [A3DateHelper dateByAddingDays:5 fromDate:ovulationDate];
            
            detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",[_dataManager dateStringForDate:pregStDate],[_dataManager dateStringForDate:pregEdDate]];
        }
        else{
            detailTextLabel.text = [_dataManager dateStringForDate:startDate];
        }
    }
    else{
        UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
        UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:11];

        textLabel.text = [dict objectForKey:ItemKey_Title];
        
        switch (cellType) {
            case DetailCellType_EndDate:
                detailTextLabel.text = [_dataManager dateStringForDate:endDate];
                break;
            case DetailCellType_CycleLength:{
                NSInteger cycleLength = [periodItem.cycleLength integerValue];
                if( indexPath.section + 1 < [_periodItems count] ){
					LadyCalendarPeriod *nextPeriod = _periodItems[indexPath.section + 1];
                    NSDate *nextStartDate = nextPeriod.startDate;
                    cycleLength = [A3DateHelper diffDaysFromDate:startDate toDate:nextStartDate];
                }
                detailTextLabel.text = [NSString stringWithFormat:@"%ld days",(long)cycleLength];
            }
                break;
            case DetailCellType_Notes:{
                NSString *notes = periodItem.notes;
                textLabel.text = ([notes length] > 0 ? @"" : @"Notes");
                detailTextLabel.text = notes;
            }
                break;
            case DetailCellType_Ovulation:{
                NSDate *ovulationDate = [A3DateHelper dateByAddingDays:-14 fromDate:startDate];
                detailTextLabel.text = [_dataManager dateStringForDate:ovulationDate];
            }
                break;
            case DetailCellType_MenstrualPeriod:{
                detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",[_dataManager dateStringForDate:startDate],[_dataManager dateStringForDate:endDate]];
            }
                break;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat retHeight = 74.0;
    
    NSArray *items = [_sectionsArray objectAtIndex:indexPath.section];
    NSDictionary *dict = [items objectAtIndex:indexPath.row];
    NSInteger cellType = [[dict objectForKey:ItemKey_Type] integerValue];
    if( cellType == DetailCellType_Title ){
        retHeight = 154.0;
    }
    else if( cellType == DetailCellType_Notes ){
		LadyCalendarPeriod *periodItem = _periodItems[indexPath.section];
        NSString *str = ( [periodItem.notes length] > 0 ? periodItem.notes : @"" );
        CGRect strBounds = [str boundingRectWithSize:CGSizeMake(tableView.frame.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17.0]} context:nil];
        retHeight = (strBounds.size.height + 36.0);
    }
    else if( (indexPath.section+1 >= [_sectionsArray count]) && (indexPath.row+1 >= [items count]) ){
        retHeight += 17.0;
    }
    else if( indexPath.row+1 >= [items count] && (indexPath.section+1 < [_sectionsArray count]))
        retHeight = 64.0;
    
    return retHeight;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *items = [_sectionsArray objectAtIndex:indexPath.section];
    NSDictionary *dict = [items objectAtIndex:indexPath.row];
    NSInteger cellType = [[dict objectForKey:ItemKey_Type] integerValue];
    LadyCalendarPeriod *periodItem = [_periodItems objectAtIndex:indexPath.section];

    if( cellType == DetailCellType_Title ){
        UIView *topView = [cell viewWithTag:10];
        UIView *bottomView = [cell viewWithTag:11];
        
        UILabel *sectionTitleLabel = (UILabel*)[topView viewWithTag:20];
        UILabel *sectionDetailLabel = (UILabel*)[topView viewWithTag:21];
        
        if( [periodItem.isPredict boolValue] ){
            sectionTitleLabel.font = [UIFont boldSystemFontOfSize:17.0];
            sectionDetailLabel.numberOfLines = 1;
        }
        
        UILabel *textLabel = (UILabel*)[bottomView viewWithTag:20];
        UILabel *detailTextLabel = (UILabel*)[bottomView viewWithTag:21];
        
        if( [periodItem.isPredict boolValue] ){
            textLabel.font = [UIFont systemFontOfSize:14.0];
            textLabel.textColor = [UIColor colorWithRGBRed:44 green:201 blue:144 alpha:255];
            detailTextLabel.font = [UIFont systemFontOfSize:17.0];
            detailTextLabel.textColor = [UIColor colorWithRGBRed:159 green:159 blue:159 alpha:255];
            detailTextLabel.numberOfLines = 1;
            detailTextLabel.adjustsFontSizeToFitWidth = YES;
            detailTextLabel.minimumScaleFactor = 0.5;
        }
        else{
            textLabel.font = [UIFont systemFontOfSize:14.0];
            textLabel.textColor = [UIColor blackColor];
            detailTextLabel.font =[UIFont systemFontOfSize:17.0];
            detailTextLabel.textColor = [UIColor colorWithRGBRed:159 green:159 blue:159 alpha:255];
            
            detailTextLabel.numberOfLines = 1;
            detailTextLabel.adjustsFontSizeToFitWidth = YES;
            detailTextLabel.minimumScaleFactor = 0.5;
        }
    }
    else{
        UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
        UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:11];
        switch (cellType) {
            case DetailCellType_EndDate:
            case DetailCellType_CycleLength:
                textLabel.font = [UIFont systemFontOfSize:14.0];
                textLabel.textColor = [UIColor blackColor];
                detailTextLabel.font =[UIFont systemFontOfSize:17.0];
                detailTextLabel.textColor = [UIColor colorWithRGBRed:159 green:159 blue:159 alpha:255];
                
                detailTextLabel.numberOfLines = 1;
                detailTextLabel.adjustsFontSizeToFitWidth = YES;
                detailTextLabel.minimumScaleFactor = 0.5;
                break;
            case DetailCellType_Notes:
                textLabel.font = [UIFont systemFontOfSize:17.0];
                textLabel.textColor = [UIColor colorWithRGBRed:159 green:159 blue:159 alpha:255];
                detailTextLabel.font = [UIFont systemFontOfSize:17.0];
                detailTextLabel.textColor = [UIColor colorWithRGBRed:159 green:159 blue:159 alpha:255];
                detailTextLabel.numberOfLines = 0;
                detailTextLabel.adjustsFontSizeToFitWidth = NO;
                detailTextLabel.minimumScaleFactor = 1.0;
                break;
            case DetailCellType_Ovulation:
                textLabel.font = [UIFont systemFontOfSize:14.0];
                textLabel.textColor = [UIColor colorWithRGBRed:238 green:230 blue:87 alpha:255];
                detailTextLabel.font = [UIFont systemFontOfSize:17.0];
                detailTextLabel.textColor = [UIColor colorWithRGBRed:159 green:159 blue:159 alpha:255];
                detailTextLabel.numberOfLines = 1;
                detailTextLabel.adjustsFontSizeToFitWidth = YES;
                detailTextLabel.minimumScaleFactor = 0.5;
                break;
            case DetailCellType_MenstrualPeriod:
                textLabel.font = [UIFont systemFontOfSize:14.0];
                textLabel.textColor = [UIColor colorWithRGBRed:252 green:96 blue:66 alpha:255];
                detailTextLabel.font = [UIFont systemFontOfSize:17.0];
                detailTextLabel.textColor = [UIColor colorWithRGBRed:159 green:159 blue:159 alpha:255];
                detailTextLabel.numberOfLines = 1;
                detailTextLabel.adjustsFontSizeToFitWidth = YES;
                detailTextLabel.minimumScaleFactor = 0.5;
                break;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - action method
- (void)editAction:(id)sender
{
    A3LadyCalendarAddPeriodViewController *viewCtrl = [[A3LadyCalendarAddPeriodViewController alloc] initWithNibName:@"A3LadyCalendarAddPeriodViewController" bundle:nil];
	viewCtrl.dataManager = _dataManager;
    viewCtrl.isEditMode = YES;
    viewCtrl.periodItem = [_periodItems objectAtIndex:0];
    viewCtrl.items = _periodItems;
    viewCtrl.parentNavigationCtrl = self.navigationController;
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
    navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:navCtrl animated:YES completion:nil];
}

- (void)editDetailItem:(id)sender
{
    UIButton *button = (UIButton*)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[button.superview superview] superview]];
    
    LadyCalendarPeriod *item = [_periodItems objectAtIndex:indexPath.section];

    A3LadyCalendarAddPeriodViewController *viewCtrl = [[A3LadyCalendarAddPeriodViewController alloc] initWithNibName:@"A3LadyCalendarAddPeriodViewController" bundle:nil];
	viewCtrl.dataManager = _dataManager;
    viewCtrl.isEditMode = YES;
    viewCtrl.periodItem = item;
    viewCtrl.items = _periodItems;
    viewCtrl.parentNavigationCtrl = self.navigationController;
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
    navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:navCtrl animated:YES completion:nil];
}

@end
