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
@property (strong, nonatomic) NSArray *templateArray;
@property (strong, nonatomic) NSMutableArray *dataArray;

- (void)editAction:(id)sender;
- (void)setupTemplateWithItems:(NSArray*)array;
- (void)editDetailItem:(id)sender;

@end

@implementation A3LadyCalendarDetailViewController

- (NSArray*)templateForItemIsPredict:(BOOL)isPredict startDate:(NSDate*)startDate endDate:(NSDate*)endDate notes:(NSString*)notes
{
    NSDate *currentDate = [A3DateHelper dateMake12PM:[NSDate date]];
//    NSString *currentYearMonth = [A3DateHelper dateStringFromDate:currentDate withFormat:@"yyyyMM"];
//    NSString *itemYearMonth = [A3DateHelper dateStringFromDate:item.startDate withFormat:@"yyyyMM"];
//    BOOL isCurrent = [currentYearMonth isEqualToString:itemYearMonth];
    BOOL isCurrent = ([startDate timeIntervalSince1970] >= [currentDate timeIntervalSince1970] );

    NSMutableArray *retArray = [NSMutableArray array];
    if( isPredict ){
        [retArray addObject:@{ItemKey_Title : @"Expected Period(+/-2 days)",ItemKey_Type : @(DetailCellType_Title)}];
//        [retArray addObject:@{ItemKey_Title : @"Increased Probability of Pregnancy",ItemKey_Type : @(DetailCellType_Pregnancy)}];
        [retArray addObject:@{ItemKey_Title : @"Ovulation - Highest Probability",ItemKey_Type : @(DetailCellType_Ovulation)}];
        [retArray addObject:@{ItemKey_Title : @"Menstrual Period",ItemKey_Type : @(DetailCellType_MenstrualPeriod)}];
    }
    else{
        [retArray addObject:@{ItemKey_Title : [NSString stringWithFormat:@"%@Menstrual Period",(isCurrent ? @"Current " : @"")],ItemKey_Type : @(DetailCellType_Title)}];
//        [retArray addObject:@{ItemKey_Title : @"Start Date",ItemKey_Type : @(DetailCellType_StartDate)}];
        [retArray addObject:@{ItemKey_Title : @"End Date",ItemKey_Type : @(DetailCellType_EndDate)}];
        [retArray addObject:@{ItemKey_Title : @"Cycle Length",ItemKey_Type : @(DetailCellType_CycleLength)}];
        if( [notes length] > 0)
            [retArray addObject:@{ItemKey_Title : @"Notes",ItemKey_Type : @(DetailCellType_Notes)}];
    }
    
    return retArray;
}

- (void)setupTemplateWithItems:(NSArray*)array
{
    NSMutableArray *retArray = [NSMutableArray array];
    NSDate *today = [NSDate date];
    NSDate *monthFirstday = [A3DateHelper dateFromYear:[A3DateHelper yearFromDate:_month] month:[A3DateHelper monthFromDate:_month] day:1 hour:0 minute:0 second:0];
    NSDate *nextMonth = [A3DateHelper dateByAddingMonth:1 fromDate:monthFirstday];
    self.dataArray = [NSMutableArray array];
    NSInteger editableCount = 0;
    for( LadyCalendarPeriod *item in array ){
        NSArray *tmpArray = [self templateForItemIsPredict:[item.isPredict boolValue] startDate:item.startDate endDate:item.endDate notes:item.periodNotes];
        [retArray addObject:tmpArray];
        [_dataArray addObject:@{PeriodItem_CycleLength: item.cycleLength,PeriodItem_StartDate : item.startDate, PeriodItem_EndDate : item.endDate,PeriodItem_IsPerdict : item.isPredict,PeriodItem_RegDate : item.regDate,PeriodItem_Notes : (item.periodNotes ? item.periodNotes : @""), PeriodItem_ID : item.periodID}];
        if( ![item.isPredict boolValue] || [item.startDate timeIntervalSince1970] < [today timeIntervalSince1970] )
            editableCount++;
        
        if( item == [array lastObject] ){
            LadyCalendarPeriod *nextPeriod = [[A3LadyCalendarModelManager sharedManager] nextPeriodFromDate:item.startDate accountID:currentAccount.accountID];

            NSDate *nextStartDate = ( nextPeriod ? nextPeriod.startDate : [A3DateHelper dateByAddingDays:[item.cycleLength integerValue] fromDate:item.startDate] );
            NSDate *nextEndDate = ( nextPeriod ? nextPeriod.endDate : [A3DateHelper dateByAddingDays:4 fromDate:nextStartDate] );
            NSDate *ovulationDate = [A3DateHelper dateByAddingDays:-14 fromDate:nextStartDate];
            
            NSDate *pregStDate = [A3DateHelper dateByAddingDays:-4 fromDate:ovulationDate];
            if( [pregStDate timeIntervalSince1970] < [nextMonth timeIntervalSince1970] ){
                tmpArray = [self templateForItemIsPredict:YES startDate:nextStartDate endDate:nextEndDate notes:nil];
                [retArray addObject:tmpArray];
                [_dataArray addObject:@{PeriodItem_CycleLength: item.cycleLength,PeriodItem_StartDate : nextStartDate, PeriodItem_EndDate : nextEndDate,PeriodItem_IsPerdict : (nextPeriod ? nextPeriod.isPredict : @(YES))}];
                
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
    
    self.templateArray = [NSArray arrayWithArray:retArray];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"";
    self.tableView.separatorInset = UIEdgeInsetsMake(0, (IS_IPHONE ? 15.0 : 28.0), 0, 0);
//    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
//    UIView *removeView = [[UIView alloc] initWithFrame:CGRectMake(0, 73.5+self.tableView.contentInset.top, appFrame.size.width, 1.0 / [[UIScreen mainScreen] scale])];
//    removeView.backgroundColor = [UIColor whiteColor];
//    [self.tableView addSubview:removeView];
    
    currentAccount = [[A3LadyCalendarModelManager sharedManager] currentAccount];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES];

//    LadyCalendarPeriod *period = [_periodItems objectAtIndex:0];
//    if( ![period.isPredict boolValue] && ([_periodItems count] == 1)){
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction:)];
//        self.navigationItem.rightBarButtonItem.width = 44.0;
//    }
    [self setupTemplateWithItems:_periodItems];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_templateArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *items = [_templateArray objectAtIndex:section];
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
    NSArray *items = [_templateArray objectAtIndex:indexPath.section];
    NSDictionary *dict = [items objectAtIndex:indexPath.row];
    NSInteger cellType = [[dict objectForKey:ItemKey_Type] integerValue];
//    LadyCalendarPeriod *periodItem = [_periodItems objectAtIndex:indexPath.section];
    NSDictionary *item = [_dataArray objectAtIndex:indexPath.section];
    
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
//                if( [CellIdentifier isEqualToString:CELLID_TITLE] )
//                    layout.constant = (IS_IPHONE ? 15.0 : 28.0);
//                else {
//                    layout.constant = (IS_IPHONE ? 15.0 : 28.0);
//                }
            }
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDate *startDate = [item objectForKey:PeriodItem_StartDate];
    NSDate *endDate = [item objectForKey:PeriodItem_EndDate];
    BOOL isPredict = [[item objectForKey:PeriodItem_IsPerdict] boolValue];
    if( cellType == DetailCellType_Title ){
        UIView *topView = [cell viewWithTag:10];
        UIView *bottomView = [cell viewWithTag:11];
        
        UILabel *sectionTitleLabel = (UILabel*)[topView viewWithTag:20];
        UILabel *sectionDetailLabel = (UILabel*)[topView viewWithTag:21];
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
            sectionDetailLabel.text = [NSString stringWithFormat:@"Updated %@",[[A3LadyCalendarModelManager sharedManager] dateStringForDate:[item objectForKey:PeriodItem_RegDate]]];
        }
        else{
            sectionDetailLabel.text = @"";
        }
        
        textLabel.text = (isPredict ? @"Increased Probability of Pregnancy" : @"Start Date");
        if( isPredict ){
            NSDate *ovulationDate = [A3DateHelper dateByAddingDays:-14 fromDate:startDate];
            NSDate *pregStDate = [A3DateHelper dateByAddingDays:-4 fromDate:ovulationDate];
            NSDate *pregEdDate = [A3DateHelper dateByAddingDays:5 fromDate:ovulationDate];
            
            detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",[[A3LadyCalendarModelManager sharedManager] dateStringForDate:pregStDate],[[A3LadyCalendarModelManager sharedManager] dateStringForDate:pregEdDate]];
        }
        else{
            detailTextLabel.text = [[A3LadyCalendarModelManager sharedManager] dateStringForDate:startDate];
        }
    }
    else{
        UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
        UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:11];

        textLabel.text = [dict objectForKey:ItemKey_Title];
        
        switch (cellType) {
//            case DetailCellType_DescTitle:
//                detailTextLabel.text = @"";
//                break;
//            case DetailCellType_StartDate:
//                detailTextLabel.text = [[A3LadyCalendarModelManager sharedManager] dateStringForDate:startDate];
//                break;
            case DetailCellType_EndDate:
                detailTextLabel.text = [[A3LadyCalendarModelManager sharedManager] dateStringForDate:endDate];
                break;
            case DetailCellType_CycleLength:{
                NSInteger cycleLength = [[item objectForKey:PeriodItem_CycleLength] integerValue];
                if( indexPath.section + 1 < [_dataArray count] ){
                    NSDictionary *nextItem = [_dataArray objectAtIndex:indexPath.section+1];
                    NSDate *nextStartDate = [nextItem objectForKey:PeriodItem_StartDate];
                    cycleLength = [A3DateHelper diffDaysFromDate:startDate toDate:nextStartDate];
                }
                detailTextLabel.text = [NSString stringWithFormat:@"%ld days",(long)cycleLength];
            }
                break;
            case DetailCellType_Notes:{
                NSString *notes = [item objectForKey:PeriodItem_Notes];
                textLabel.text = ([notes length] > 0 ? @"" : @"Notes");
                detailTextLabel.text = notes;
            }
                break;
//            case DetailCellType_Pregnancy:{
//                NSDate *ovulationDate = [A3DateHelper dateByAddingDays:-14 fromDate:startDate];
//                NSDate *pregStDate = [A3DateHelper dateByAddingDays:-4 fromDate:ovulationDate];
//                NSDate *pregEdDate = [A3DateHelper dateByAddingDays:5 fromDate:ovulationDate];
//                
//                detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",[[A3LadyCalendarModelManager sharedManager] dateStringForDate:pregStDate],[[A3LadyCalendarModelManager sharedManager] dateStringForDate:pregEdDate]];
//
//            }
//                break;
            case DetailCellType_Ovulation:{
                NSDate *ovulationDate = [A3DateHelper dateByAddingDays:-14 fromDate:startDate];
                detailTextLabel.text = [[A3LadyCalendarModelManager sharedManager] dateStringForDate:ovulationDate];
            }
                break;
            case DetailCellType_MenstrualPeriod:{
                detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",[[A3LadyCalendarModelManager sharedManager] dateStringForDate:startDate],[[A3LadyCalendarModelManager sharedManager] dateStringForDate:endDate]];
            }
                break;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat retHeight = 74.0;
    
    NSArray *items = [_templateArray objectAtIndex:indexPath.section];
    NSDictionary *dict = [items objectAtIndex:indexPath.row];
    NSInteger cellType = [[dict objectForKey:ItemKey_Type] integerValue];
    if( cellType == DetailCellType_Title ){
        retHeight = 154.0;
    }
//    else if( cellType == DetailCellType_DescTitle ){
//        retHeight = 44.0;
//    }
    else if( cellType == DetailCellType_Notes ){
//        LadyCalendarPeriod *periodItem = [_periodItems objectAtIndex:indexPath.section];
        NSDictionary *item = [_dataArray objectAtIndex:indexPath.section];
        NSString *str = ( [[item objectForKey:PeriodItem_Notes] length] > 0 ? [item objectForKey:PeriodItem_Notes] : @"" );
        CGRect strBounds = [str boundingRectWithSize:CGSizeMake(tableView.frame.size.width, 99999.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17.0]} context:nil];
        retHeight = (strBounds.size.height + 36.0);
    }
    else if( (indexPath.section+1 >= [_templateArray count]) && (indexPath.row+1 >= [items count]) ){
        retHeight += 17.0;
    }
    else if( indexPath.row+1 >= [items count] && (indexPath.section+1 < [_templateArray count]))
        retHeight = 64.0;
    
    return retHeight;
}

//- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if( indexPath.row > 0 )
//        return 2;
//    
//    return 0;
//}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *items = [_templateArray objectAtIndex:indexPath.section];
    NSDictionary *dict = [items objectAtIndex:indexPath.row];
    NSInteger cellType = [[dict objectForKey:ItemKey_Type] integerValue];
//    LadyCalendarPeriod *periodItem = [_periodItems objectAtIndex:indexPath.section];
    NSDictionary *item = [_dataArray objectAtIndex:indexPath.section];
    
    if( cellType == DetailCellType_Title ){
        UIView *topView = [cell viewWithTag:10];
        UIView *bottomView = [cell viewWithTag:11];
        
        UILabel *sectionTitleLabel = (UILabel*)[topView viewWithTag:20];
        UILabel *sectionDetailLabel = (UILabel*)[topView viewWithTag:21];
        
        if( [[item objectForKey:PeriodItem_IsPerdict] boolValue] ){
            sectionTitleLabel.font = [UIFont boldSystemFontOfSize:17.0];
            sectionDetailLabel.numberOfLines = 1;
        }
        
        UILabel *textLabel = (UILabel*)[bottomView viewWithTag:20];
        UILabel *detailTextLabel = (UILabel*)[bottomView viewWithTag:21];
        
        if( [[item objectForKey:PeriodItem_IsPerdict] boolValue] ){
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
//            case DetailCellType_Pregnancy:
//                textLabel.font = [UIFont systemFontOfSize:14.0];
//                textLabel.textColor = [UIColor colorWithRGBRed:44 green:201 blue:144 alpha:255];
//                detailTextLabel.font = [UIFont systemFontOfSize:17.0];
//                detailTextLabel.textColor = [UIColor colorWithRGBRed:159 green:159 blue:159 alpha:255];
//                detailTextLabel.numberOfLines = 1;
//                detailTextLabel.adjustsFontSizeToFitWidth = YES;
//                detailTextLabel.minimumScaleFactor = 0.5;
//                break;
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
//            case DetailCellType_DescTitle:
//                textLabel.font = [UIFont boldSystemFontOfSize:17.0];
//                detailTextLabel.numberOfLines = 1;
//                break;
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
    
//    LadyCalendarPeriod *item = [_periodItems objectAtIndex:indexPath.section];
    NSDictionary *dict = [_dataArray objectAtIndex:indexPath.section];
    if( [[dict objectForKey:PeriodItem_ID] length] < 1 )
        return;
    
    LadyCalendarPeriod *item = [[A3LadyCalendarModelManager sharedManager] periodForID:[dict objectForKey:PeriodItem_ID]];
    if( item == nil )
        return;
    
    A3LadyCalendarAddPeriodViewController *viewCtrl = [[A3LadyCalendarAddPeriodViewController alloc] initWithNibName:@"A3LadyCalendarAddPeriodViewController" bundle:nil];
    viewCtrl.isEditMode = YES;
    viewCtrl.periodItem = item;
    viewCtrl.items = _periodItems;
    viewCtrl.parentNavigationCtrl = self.navigationController;
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
    navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:navCtrl animated:YES completion:nil];
}

@end
