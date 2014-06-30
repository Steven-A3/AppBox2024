//
//  A3CalculatorHistoryViewController.m
//  A3TeamWork
//
//  Created by Soon Gyu Kim on 12/30/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CalculatorHistoryViewController.h"
#import "A3CalculatorHistoryCell.h"
#import "UIViewController+NumberKeyboard.h"
#import "NSDate+TimeAgo.h"
#import "UIViewController+A3Addition.h"
#import "Calculation.h"

NSString *const A3CalculatorHistoryRowCellID = @"CcellRow";

@interface A3CalculatorHistoryViewController () <UIActionSheetDelegate>
@property (nonatomic, strong)	NSFetchedResultsController *fetchedResultsController;
@end

@implementation A3CalculatorHistoryViewController {
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
    
	self.title = NSLocalizedString(@"History", @"History");

	if (IS_IPHONE) {
		[self rightBarButtonDoneButton];
	}
    
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear", @"Clear") style:UIBarButtonItemStylePlain target:self action:@selector(clearButtonAction:)];
    
	self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorColor  = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0];
    
    /*
	UILabel *notice = [[UILabel alloc] init];
	notice.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
	notice.textColor = [UIColor blackColor];
	notice.text = @"Each history keeps max 4 currencies.";
	notice.textAlignment = NSTextAlignmentCenter;
    
	CGRect frame = CGRectMake(0.0, 0.0, 320.0, 40.0);
	UIView *footerView = [[UIView alloc] initWithFrame:frame];
    footerView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];
	notice.frame = footerView.bounds;
	[footerView addSubview:notice];
    
	self.tableView.tableFooterView = footerView;
    */
	[self.tableView registerClass:[A3CalculatorHistoryCell class] forCellReuseIdentifier:A3CalculatorHistoryRowCellID];
	[self registerContentSizeCategoryDidChangeNotification];
}

- (void)removeObserver {
	[self removeContentSizeCategoryDidChangeNotification];
}

- (void)dealloc {
	[self removeObserver];
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
	[self dismissViewControllerAnimated:YES completion:nil];
	[self removeObserver];
}

- (void)contentSizeDidChange:(NSNotification *)notification {
	[self.tableView reloadData];
}

- (void)clearButtonAction:(id)button {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
											   destructiveButtonTitle:NSLocalizedString(@"Clear History", @"Clear History")
													otherButtonTitles:nil];
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
		_fetchedResultsController = nil;
		[Calculation MR_truncateAll];
		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];

		[self.tableView reloadData];
        if(IS_IPAD) {
            [self.iPadViewController checkRightButtonDisable];
        }
	}
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSFetchedResultsController *)fetchedResultsController {
	if (!_fetchedResultsController) {
        _fetchedResultsController = [Calculation MR_fetchAllSortedBy:@"updateDate" ascending:NO withPredicate:nil groupBy:nil delegate:nil];
		if (![_fetchedResultsController.fetchedObjects count]) {
			self.navigationItem.leftBarButtonItem = nil;
		}
	}
	return _fetchedResultsController;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	// Calculation *calcualtion= [self.fetchedResultsController objectAtIndexPath:indexPath];
	return 50.0 + 12.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	Calculation *calculation = [_fetchedResultsController objectAtIndexPath:indexPath];
    
	//NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	//[nf setNumberStyle:NSNumberFormatterDecimalStyle];
    
	A3CalculatorHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:A3CalculatorHistoryRowCellID forIndexPath:indexPath];
	if (!cell) {
		cell = [[A3CalculatorHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:A3CalculatorHistoryRowCellID];
	}
    
    
	//NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    
    
	//((UILabel *) cell.L1).text = calculation.expression;
    FNLOG("expression = %@", calculation.expression);
    ((UILabel *) cell.L1).text = calculation.result;
    ((UILabel *) cell.R1).text = [calculation.updateDate timeAgo];
    ((UILabel *) cell.L2).attributedText =  [self.calculator getExpressionWith:calculation.expression];
    
	return cell;
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
        
        Calculation *calculation = [_fetchedResultsController objectAtIndexPath:indexPath];
        [calculation MR_deleteEntity];
		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
		_fetchedResultsController = nil;
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Calculation *calculation = [_fetchedResultsController objectAtIndexPath:indexPath];
    [self.calculator setMathExpression:calculation.expression];
    if (IS_IPAD) {
		[self.A3RootViewController dismissRightSideViewController];
	} else {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}
@end
