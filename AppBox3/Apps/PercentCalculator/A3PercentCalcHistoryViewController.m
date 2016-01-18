//
//  A3PercentCalcHistoryViewController.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 10. 26..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3PercentCalcHistoryViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3PercentCalcData.h"
#import "A3PercentCalculator.h"
#import "A3PercentCalcHistoryCell.h"
#import "A3PercentCalcHistoryCompareCell.h"
#import "PercentCalcHistory.h"
#import "A3DefaultColorDefines.h"
#import "NSDate+TimeAgo.h"
#import "UIViewController+iPad_rightSideView.h"
#import "UIViewController+tableViewStandardDimension.h"

NSString *const A3PercentCalcHistoryCellID = @"cell1";
NSString *const A3PercentCalcHistoryCompareCellID = @"cell2";

//#define kPositiveColor [UIColor colorWithRed:0.0 green:230.0/255.0 blue:101.0/255.0 alpha:1.0]
//#define kNegativeColor [UIColor colorWithRed:1.0 green:0.0 blue:69.0/255.0 alpha:1.0]

@interface A3PercentCalcHistoryViewController () <UIActionSheetDelegate>
@property (nonatomic, strong)	NSFetchedResultsController *fetchedResultsController;
@end

@implementation A3PercentCalcHistoryViewController

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

    
    self.title = NSLocalizedString(@"History", @"History");
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear", @"Clear") style:UIBarButtonItemStylePlain target:self action:@selector(clearButtonAction)];

    if (IS_IPHONE) {
		[self rightBarButtonDoneButton];
	}

    self.tableView.separatorInset = A3UITableViewSeparatorInset;
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorColor = A3UITableViewSeparatorColor;
    
	[self.tableView registerClass:[A3PercentCalcHistoryCell class] forCellReuseIdentifier:A3PercentCalcHistoryCellID];
	[self.tableView registerClass:[A3PercentCalcHistoryCompareCell class] forCellReuseIdentifier:A3PercentCalcHistoryCompareCellID];
    
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

- (void)didMoveToParentViewController:(UIViewController *)parent {
	[super didMoveToParentViewController:parent];

	FNLOG(@"%@", parent);
	if (!parent) {
		[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationChildViewControllerDidDismiss object:self];
	}
}

- (void)dealloc {
	[self removeObserver];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSFetchedResultsController *)fetchedResultsController {
	if (!_fetchedResultsController) {
        _fetchedResultsController = [PercentCalcHistory MR_fetchAllSortedBy:@"updateDate" ascending:NO withPredicate:nil groupBy:nil delegate:nil];
		if (![_fetchedResultsController.fetchedObjects count]) {
			self.navigationItem.leftBarButtonItem = nil;
		}
	}
	return _fetchedResultsController;
}

-(void)contentSizeDidChange:(NSNotification *)notification {
    [self.tableView reloadData];
}

#pragma mark - Actions
-(void)clearButtonAction
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
											   destructiveButtonTitle:NSLocalizedString(@"Clear History", @"Clear History")
													otherButtonTitles:nil];
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [PercentCalcHistory MR_truncateAll];
        _fetchedResultsController = nil;
		[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

        [self.tableView reloadData];
        if ([_delegate respondsToSelector:@selector(didDeleteHistory)]) {
            [_delegate didDeleteHistory];
        }
	}
}

- (void)doneButtonAction:(id)sender
{
	if (IS_IPAD) {
		[[[A3AppDelegate instance] rootViewController] dismissRightSideViewController];
		if ([_delegate respondsToSelector:@selector(dismissHistoryViewController)]) {
			[_delegate performSelector:@selector(dismissHistoryViewController)];
		}

	} else {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PercentCalcHistory *aData = [_fetchedResultsController objectAtIndexPath:indexPath];
    A3PercentCalcData *historyData = [NSKeyedUnarchiver unarchiveObjectWithData:aData.historyItem];
    NSArray *results = [A3PercentCalculator percentCalculateFor:historyData];
    if (results==nil) {
        FNLOG(@"no");
        A3PercentCalcHistoryCompareCell *cell = [tableView dequeueReusableCellWithIdentifier:A3PercentCalcHistoryCompareCellID forIndexPath:indexPath];
        return cell;
    }
    NSArray *formattedValues = [historyData formattedStringValuesByCalcType];

    NSMutableString *resultStringA = [[NSMutableString alloc] init];
    NSMutableString *resultStringB = [[NSMutableString alloc] init];
    NSRange resultLocationA;
    NSRange resultLocationB = NSMakeRange(0, 0);
    NSNumberFormatter *numFormatter = [NSNumberFormatter new];
    [numFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    BOOL isAPositive, isBPositive = YES;
    
    switch (historyData.dataType) {
        case PercentCalcType_1:
        {
            // X is Y% of What
            [resultStringA appendString:formattedValues[ValueIdx_X1]];
            [resultStringA appendString:@" = "];
            NSString *sResult = [numFormatter stringFromNumber:results[0]];
            [resultStringA appendString:sResult];
            resultLocationA = NSMakeRange(resultStringA.length-sResult.length, sResult.length);
            [resultStringA appendString:@" × "];
            [resultStringA appendString:formattedValues[ValueIdx_Y1]];
            isAPositive = [results[0] floatValue] > 0.0 ? YES : NO;
        }
            break;
            
        case PercentCalcType_2:
        {
            // What is X% of Y
            NSString *sResult = [numFormatter stringFromNumber:results[0]];
            [resultStringA appendString:sResult];
            resultLocationA = NSMakeRange(resultStringA.length-sResult.length, sResult.length);
            [resultStringA appendString:@" = "];
            [resultStringA appendString:formattedValues[ValueIdx_Y1]];
            [resultStringA appendString:@" × "];
            [resultStringA appendString:formattedValues[ValueIdx_X1]];
            isAPositive = [results[0] floatValue] > 0.0 ? YES : NO;
        }
            break;
        case PercentCalcType_3:
        {
            // X is What % of Y, (X = Y x ANSWER)
            [resultStringA appendString:formattedValues[ValueIdx_X1]];
            [resultStringA appendString:@" = "];
            [resultStringA appendString:formattedValues[ValueIdx_Y1]];
            [resultStringA appendString:@" × "];
            NSString *sResult = [numFormatter stringFromNumber:results[0]];
            sResult = [self formattedResultString:sResult withType:historyData.dataType];
            [resultStringA appendString:sResult];
            resultLocationA = NSMakeRange(resultStringA.length-sResult.length, sResult.length);
            isAPositive = [results[0] floatValue] > 0.0 ? YES : NO;
        }
            break;
        case PercentCalcType_4:
        {
            // % Change from X to Y
            NSString *sResult = [numFormatter stringFromNumber:results[0]];
            sResult = [self formattedResultString:sResult withType:historyData.dataType];
            [resultStringA appendString:sResult];
            resultLocationA = NSMakeRange(resultStringA.length-sResult.length, sResult.length);
            [resultStringA appendString:@" = "];
            [resultStringA appendString:@"( "];
            [resultStringA appendString:formattedValues[ValueIdx_Y1]];
            [resultStringA appendString:@" − "];
            [resultStringA appendString:formattedValues[ValueIdx_X1]];
            [resultStringA appendString:@" )"];
            [resultStringA appendString:@" ÷ "];
            [resultStringA appendString:formattedValues[ValueIdx_X1]];
            [resultStringA appendString:@" × "];
            [resultStringA appendString:@"100"];
            isAPositive = [results[0] floatValue] > 0.0 ? YES : NO;
        }
            break;
        case PercentCalcType_5:
        {
            // Compare % Change from X to Y
            NSString *sResult = [numFormatter stringFromNumber:results[0]];
            sResult = [self formattedResultString:sResult withType:historyData.dataType];
            [resultStringA appendString:sResult];
            resultLocationA = NSMakeRange(resultStringA.length-sResult.length, sResult.length);
            [resultStringA appendString:@" = "];
            [resultStringA appendString:@"( "];
            [resultStringA appendString:formattedValues[ValueIdx_Y1]];
            [resultStringA appendString:@" − "];
            [resultStringA appendString:formattedValues[ValueIdx_X1]];
            [resultStringA appendString:@" )"];
            [resultStringA appendString:@" ÷ "];
            [resultStringA appendString:formattedValues[ValueIdx_X1]];
            [resultStringA appendString:@" × "];
            [resultStringA appendString:@"100"];
            isAPositive = [results[0] floatValue] > 0.0 ? YES : NO;
            
            sResult = [numFormatter stringFromNumber:results[1]];
            sResult = [self formattedResultString:sResult withType:historyData.dataType];
            [resultStringB appendString:sResult];
            resultLocationB = NSMakeRange(resultStringB.length-sResult.length, sResult.length);
            [resultStringB appendString:@" = "];
            [resultStringB appendString:@"( "];
            [resultStringB appendString:formattedValues[ValueIdx_Y2]];
            [resultStringB appendString:@" − "];
            [resultStringB appendString:formattedValues[ValueIdx_X2]];
            [resultStringB appendString:@" )"];
            [resultStringB appendString:@" ÷ "];
            [resultStringB appendString:formattedValues[ValueIdx_X2]];
            [resultStringB appendString:@" × "];
            [resultStringB appendString:@"100"];
            isBPositive = [results[1] floatValue] > 0.0 ? YES : NO;
        }
            break;
            
        default:
            break;
    }


    if (historyData.dataType == PercentCalcType_5) {
        A3PercentCalcHistoryCompareCell *cell = [tableView dequeueReusableCellWithIdentifier:A3PercentCalcHistoryCompareCellID forIndexPath:indexPath];
        cell.dateLabel.text = [aData.updateDate timeAgo];

        cell.factorALabel.text = resultStringA;
        cell.factorBLabel.text = resultStringB;
        cell.factorALabel.font = [UIFont systemFontOfSize:13];
        cell.factorBLabel.font = [UIFont systemFontOfSize:13];
        NSMutableAttributedString *textA = [[NSMutableAttributedString alloc] initWithAttributedString:cell.factorALabel.attributedText];
        NSMutableAttributedString *textB = [[NSMutableAttributedString alloc] initWithAttributedString:cell.factorBLabel.attributedText];
        [textA addAttribute:NSForegroundColorAttributeName
                      value: isAPositive ? A3DefaultColorHistoryPositiveText : COLOR_NEGATIVE
                      range:resultLocationA];
        [textB addAttribute:NSForegroundColorAttributeName
                      value: isBPositive ? A3DefaultColorHistoryPositiveText : COLOR_NEGATIVE
                      range:resultLocationB];
        
        [textA addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:resultLocationA];
        [textB addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:resultLocationB];
        cell.factorALabel.attributedText = textA;
        cell.factorBLabel.attributedText = textB;
        
        [cell.dateLabel sizeToFit];
        [cell.factorALabel sizeToFit];
        [cell.factorBLabel sizeToFit];

        return cell;
        
    } else {
        A3PercentCalcHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:A3PercentCalcHistoryCellID forIndexPath:indexPath];
        cell.dateLabel.text = [aData.updateDate timeAgo];
        
        cell.factorLabel.text = [NSString stringWithFormat:@"%@", resultStringA];
        cell.factorLabel.font = [UIFont systemFontOfSize:13];
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString:cell.factorLabel.attributedText];
        [text addAttribute: NSForegroundColorAttributeName
                     value: isAPositive ? A3DefaultColorHistoryPositiveText : COLOR_NEGATIVE
                     range:resultLocationA];
        [text addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:resultLocationA];
        cell.factorLabel.attributedText = text;
        
        [cell.dateLabel sizeToFit];
        [cell.factorLabel sizeToFit];
        
        return cell;
    }
}

-(NSString *)formattedResultString:(NSString *)resultString withType:(PercentCalcType)calcType
{
    NSString *result;
    
    switch (calcType) {

        case PercentCalcType_3:
        case PercentCalcType_4:
        case PercentCalcType_5:
        {
            result = [NSString stringWithFormat:@"%@%%", resultString];
        }
            break;
        default:
        {
            result = resultString;
        }
    }
    return result;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PercentCalcHistory *aData = [_fetchedResultsController objectAtIndexPath:indexPath];
    A3PercentCalcData *historyData = [NSKeyedUnarchiver unarchiveObjectWithData:aData.historyItem];
    
    return historyData.dataType==PercentCalcType_5 ? 84.0 : 62.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    PercentCalcHistory *aData = [_fetchedResultsController objectAtIndexPath:indexPath];
    if (!aData) {
        return;
    }
    
    if ([_delegate respondsToSelector:@selector(setHistoryData:)]) {
        A3PercentCalcData *history = [NSKeyedUnarchiver unarchiveObjectWithData:aData.historyItem];
        
        if (!history) {
            return;
        }
        
        [_delegate setHistoryData:history];
        
        [self doneButtonAction:nil];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PercentCalcHistory *aData = [_fetchedResultsController objectAtIndexPath:indexPath];
        [aData MR_deleteEntity];
		[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        _fetchedResultsController = nil;
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if ([_delegate respondsToSelector:@selector(didDeleteHistory)]) {
            [_delegate didDeleteHistory];
        }
    }
}

@end
