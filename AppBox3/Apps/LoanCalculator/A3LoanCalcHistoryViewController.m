//
//  A3LoanCalcHistoryViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 14..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcHistoryViewController.h"
#import "A3LoanCalcLoanHistoryCell.h"
#import "A3LoanCalcComparisonHistoryCell.h"
#import "LoanCalcString.h"
#import "LoanCalcHistory.h"
#import "NSDate+TimeAgo.h"
#import "LoanCalcComparisonHistory.h"
#import "A3AppDelegate.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"

@interface A3LoanCalcHistoryViewController () <UIActionSheetDelegate>
{
    BOOL _isComparisonMode;
}

@property (nonatomic, strong)	NSFetchedResultsController *fetchedResultsController;

@end

@implementation A3LoanCalcHistoryViewController

NSString *const A3LoanCalcLoanHistoryCellID = @"A3LoanCalcLoanHistoryCell";
NSString *const A3LoanCalcComparisonHistoryCellID = @"A3LoanCalcComparisonHistoryCell";

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.titleView = self.selectSegment;
    
    [self rightBarButtonDoneButton];
    
	self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorColor = [self tableViewSeparatorColor];
    
    [self registerContentSizeCategoryDidChangeNotification];
}

- (void)contentSizeDidChange:(NSNotification *) notification
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UISegmentedControl *)selectSegment
{
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:@[@"Loan", @"Comparison"]];
    
    [segment setWidth:85 forSegmentAtIndex:0];
    [segment setWidth:85 forSegmentAtIndex:1];

    segment.selectedSegmentIndex = _isComparisonMode ? 1:0;
    [segment addTarget:self action:@selector(selectSegmentChanged:) forControlEvents:UIControlEventValueChanged];
    
    return segment;
}

- (void)selectSegmentChanged:(UISegmentedControl*) segment
{
    switch (segment.selectedSegmentIndex) {
        case 0:
        {
            // Loan
            _isComparisonMode = NO;
            _fetchedResultsController = nil;
            [self.tableView reloadData];
            
            break;
        }
        case 1:
        {
            // Comparison
            _isComparisonMode = YES;
            _fetchedResultsController = nil;
            [self.tableView reloadData];
            
            break;
        }
        default:
            break;
    }
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
	if (IS_IPAD) {
		[self.A3RootViewController dismissRightSideViewController];
	} else {
		[self dismissViewControllerAnimated:YES completion:nil];
	}

    if ([_delegate respondsToSelector:@selector(historyViewControllerDismissed:)]) {
        [_delegate historyViewControllerDismissed:self];
    }
}

- (void)dealloc {
	[self removeObserver];
}

- (void)clearButtonAction:(id)button {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:@"Clear History"
													otherButtonTitles:nil];
	[actionSheet showInView:self.view];
}

- (NSFetchedResultsController *)fetchedResultsController {
    
	if (!_fetchedResultsController) {
        if (_isComparisonMode) {
            _fetchedResultsController = [LoanCalcComparisonHistory MR_fetchAllSortedBy:@"calculateDate" ascending:NO withPredicate:nil groupBy:nil delegate:nil];
        }
        else {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"compareWith = nil"];
            _fetchedResultsController = [LoanCalcHistory MR_fetchAllSortedBy:@"created" ascending:NO withPredicate:predicate groupBy:nil delegate:nil];
        }
        
		if ([_fetchedResultsController.fetchedObjects count] == 0) {
			self.navigationItem.leftBarButtonItem = nil;
		}
        else {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(clearButtonAction:)];
        }
	}
	return _fetchedResultsController;
}

- (void)deleteLoanHistory:(LoanCalcHistory *)history
{
    [history MR_deleteEntity];
	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
}

- (void)deleteComparisonHistory:(LoanCalcComparisonHistory *)history
{
	for (LoanCalcHistory *detail in history.details) {
		[detail MR_deleteEntity];
	}

    [history MR_deleteEntity];

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
}

- (void)configureLoanCell:(A3LoanCalcLoanHistoryCell *)loanCell withHistory:(LoanCalcHistory *) history
{
    if (history) {
        /*
        NSDateFormatter *df = [NSDateFormatter new];
        [df setDateFormat:@"MM/dd/yy HH:mm a"];
        loanCell.upRightLb.text = [df stringFromDate:history.created];
         */
        loanCell.upRightLb.text = [history.created timeAgo];
        loanCell.upRightLb.font = [UIFont systemFontOfSize:12];
        loanCell.upRightLb.textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0];
        
        // history 표시 안함.
        loanCell.lowRightLb.text = @"";
        /*
        if (history.notes) {
            loanCell.lowRightLb.text = history.notes;
        }
        else {
            loanCell.lowRightLb.text = @"";
        }
         */
        
        A3LoanCalcFrequencyType freqType = (A3LoanCalcFrequencyType) history.frequency.integerValue;
        NSNumber *repayNum = @(history.monthlyPayment.doubleValue);
        NSString *repayment = [self.currencyFormatter stringFromNumber:repayNum];
        NSString *shortTerm = [LoanCalcString shortTitleOfFrequency:freqType];
        loanCell.upLeftLb.text = [NSString stringWithFormat:@"%@/%@", repayment, shortTerm];
        loanCell.upLeftLb.textColor = [UIColor colorWithRed:255.0/255.0 green:45.0/255.0 blue:85.0/255.0 alpha:1.0];
        loanCell.upLeftLb.font = [UIFont systemFontOfSize:15];
        
        
        NSString *principal = [self.currencyFormatter stringFromNumber:@(history.principal.doubleValue)];
        NSString *percent = [self.percentFormatter stringFromNumber:@(history.interestRate.floatValue)];
        float months = history.term.floatValue;
        int yearCount = months/12;
        int monthCount = (int)(months - yearCount*12);
        NSString *yearText = @"";
        if (yearCount>0) {
            yearText = [NSString stringWithFormat:@"%dyrs",yearCount];
        }
        NSString *monthText = @"";
        if (monthCount>0) {
            monthText = [NSString stringWithFormat:@"%dmos",monthCount];
        }
        loanCell.lowLeftLb.text = [NSString stringWithFormat:@"%@ %@ %@%@", principal, percent, yearText, monthText];
        loanCell.lowLeftLb.textColor = [UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0];
        loanCell.lowLeftLb.font = [UIFont systemFontOfSize:13];
        
        [loanCell.upLeftLb sizeToFit];
        [loanCell.upRightLb sizeToFit];
        [loanCell.lowLeftLb sizeToFit];
        
        // from bottom to label bottom : 41/13
        float gap1 = 41;
        float gap2 = 13;
        float fromTopToA = loanCell.bounds.size.height - gap1;
        float fromTopToB = loanCell.bounds.size.height - gap2;
        loanCell.upLeftLb.layer.anchorPoint = CGPointMake(0.5, 1.0);
        loanCell.upRightLb.layer.anchorPoint = CGPointMake(1, 1.0);
        loanCell.lowLeftLb.layer.anchorPoint = CGPointMake(0.5, 1.0);
        
        CGPoint lbCenter;
        
        lbCenter = loanCell.upLeftLb.center;
        lbCenter.y = fromTopToA;
        loanCell.upLeftLb.center = lbCenter;
        
        lbCenter = loanCell.upRightLb.center;
        lbCenter.x = 320-15;
        lbCenter.y = fromTopToA;
        loanCell.upRightLb.center = lbCenter;
        
        lbCenter = loanCell.lowLeftLb.center;
        lbCenter.y = fromTopToB;
        loanCell.lowLeftLb.center = lbCenter;
        
        // label baseline adjustment with font
        [self baseLineAdjustment:loanCell.upLeftLb];
        [self baseLineAdjustment:loanCell.upRightLb];
        [self baseLineAdjustment:loanCell.lowLeftLb];
    }
}

- (void) baseLineAdjustment:(UILabel *)label
{
    CGRect newFrame = label.frame;
    newFrame.origin.y -= floor(label.font.descender);
    label.frame = newFrame;
}

- (void)configureComparisonCell:(A3LoanCalcComparisonHistoryCell *)comparisonCell withHistory:(LoanCalcComparisonHistory *) history
{
    if (history) {
        /*
        NSDateFormatter *df = [NSDateFormatter new];
        [df setDateFormat:@"MM/dd/yy HH:mm a"];
        comparisonCell.dateLb.text = [df stringFromDate:history.calculateDate];
        */
        comparisonCell.dateLb.text = [history.calculateDate timeAgo];
        comparisonCell.dateLb.font = [UIFont systemFontOfSize:12];
        comparisonCell.dateLb.textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0];
        
        NSDictionary *textAttributes1 = @{
                                          NSFontAttributeName : [UIFont systemFontOfSize:15.0],
                                          NSForegroundColorAttributeName:[UIColor colorWithRed:255.0/255.0 green:45.0/255.0 blue:85.0/255.0 alpha:1.0]
                                          };
        
        NSDictionary *textAttributes2 = @{
                                          NSFontAttributeName : [UIFont systemFontOfSize:13.0],
                                          NSForegroundColorAttributeName:[UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0]
                                          };
        NSMutableAttributedString *upAttrString = [[NSMutableAttributedString alloc] init];
        NSMutableAttributedString *upText1 = [[NSMutableAttributedString alloc] initWithString:[self.currencyFormatter stringFromNumber:@(history.totalInterestA.floatValue)] attributes:textAttributes1];
        NSMutableAttributedString *midText = [[NSMutableAttributedString alloc] initWithString:@" of " attributes:textAttributes2];
        NSMutableAttributedString *upText2 = [[NSMutableAttributedString alloc] initWithString:[self.currencyFormatter stringFromNumber:@(history.totalAmountA.floatValue)] attributes:textAttributes2];
        [upAttrString appendAttributedString:upText1];
        [upAttrString appendAttributedString:midText];
        [upAttrString appendAttributedString:upText2];
        comparisonCell.infoA_Lb.attributedText = upAttrString;
        
        NSMutableAttributedString *lowAttrString = [[NSMutableAttributedString alloc] init];
        NSMutableAttributedString *lowText1 = [[NSMutableAttributedString alloc] initWithString:[self.currencyFormatter stringFromNumber:@(history.totalInterestB.floatValue)] attributes:textAttributes1];
        NSMutableAttributedString *lowText2 = [[NSMutableAttributedString alloc] initWithString:[self.currencyFormatter stringFromNumber:@(history.totalAmountB.floatValue)] attributes:textAttributes2];
        [lowAttrString appendAttributedString:lowText1];
        [lowAttrString appendAttributedString:midText];
        [lowAttrString appendAttributedString:lowText2];
        comparisonCell.infoB_Lb.attributedText = lowAttrString;
    }
}

#pragma mark - Action Sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
        
        NSUInteger section = [self.tableView numberOfSections];
        for (int i=0; i<section; i++) {
            NSUInteger row = [self.tableView numberOfRowsInSection:i];
            for (int j=0; j<row; j++) {
                NSIndexPath *ip = [NSIndexPath indexPathForRow:j inSection:i];
                if (_isComparisonMode) {
                    LoanCalcComparisonHistory *comparisonHistory = [_fetchedResultsController objectAtIndexPath:ip];
                    [comparisonHistory MR_deleteEntity];
                }
                else {
                    LoanCalcHistory *loanHistory = [_fetchedResultsController objectAtIndexPath:ip];
                    [loanHistory MR_deleteEntity];
                }
            }
        }
		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
        _fetchedResultsController = nil;
        [self.tableView reloadData];
	}
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_isComparisonMode) {
        if (_delegate && [_delegate respondsToSelector:@selector(historyViewController:selectLoanCalcComparisonHistory:)]) {
            
            LoanCalcComparisonHistory *comparisonHistory = [_fetchedResultsController objectAtIndexPath:indexPath];
            [_delegate historyViewController:self selectLoanCalcComparisonHistory:comparisonHistory];
        }
    }
    else {
        if (_delegate && [_delegate respondsToSelector:@selector(historyViewController:selectLoanCalcHistory:)]) {
            
            LoanCalcHistory *loanHistory = [_fetchedResultsController objectAtIndexPath:indexPath];
            [_delegate historyViewController:self selectLoanCalcHistory:loanHistory];
        }
    }
    
    [self doneButtonAction:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=nil;
	@autoreleasepool {
		cell = nil;
        
        if (_isComparisonMode) {
            
            A3LoanCalcComparisonHistoryCell *compareCell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcComparisonHistoryCellID forIndexPath:indexPath];
            
            LoanCalcComparisonHistory *comparisonHistory = [_fetchedResultsController objectAtIndexPath:indexPath];
            [self configureComparisonCell:compareCell withHistory:comparisonHistory];
            cell = compareCell;
        }
        else {
            A3LoanCalcLoanHistoryCell *loanCell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcLoanHistoryCellID forIndexPath:indexPath];
            
            LoanCalcHistory *loanHistory = [_fetchedResultsController objectAtIndexPath:indexPath];
            [self configureLoanCell:loanCell withHistory:loanHistory];
            
            cell = loanCell;
        }
	}
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_isComparisonMode) {
        return 84;
    }
    else {
        return 62;
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        if (_isComparisonMode) {
            LoanCalcComparisonHistory *history = [_fetchedResultsController objectAtIndexPath:indexPath];
            [self deleteComparisonHistory:history];
        }
        else {
            LoanCalcHistory *history = [_fetchedResultsController objectAtIndexPath:indexPath];
            [self deleteLoanHistory:history];
        }
        
		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
        _fetchedResultsController = nil;
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
