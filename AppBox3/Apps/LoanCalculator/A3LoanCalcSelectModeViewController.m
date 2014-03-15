//
//  A3LoanCalcSelectModeViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 9..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcSelectModeViewController.h"
#import "LoanCalcString.h"
#import "LoanCalcPreference.h"

#import "A3AppDelegate.h"
#import "A3NumberKeyboardViewController.h"
#import "UIViewController+A3AppCategory.h"
#import "UIViewController+A3Addition.h"

@interface A3LoanCalcSelectModeViewController ()

@property (nonatomic, strong) NSArray *calForItems;

@end

@implementation A3LoanCalcSelectModeViewController

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
    
    self.navigationItem.title = @"Calculation";
    
    self.tableView.separatorColor = [self tableViewSeparatorColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)calForItems
{
    if (!_calForItems) {
        _calForItems = [LoanCalcMode calculationModes];
    }
    
    return _calForItems;
}

- (void)doneButtonAction:(id)button {
	@autoreleasepool {
		[self.A3RootViewController dismissRightSideViewController];
	}
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *modeNumb = _calForItems[indexPath.row];
    A3LoanCalcCalculationMode calMode = modeNumb.integerValue;
    
    if ((calMode == A3LC_CalculationForDownPayment) && ![LoanCalcPreference new].showDownPayment) {
        return;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectCalculationFor:)]) {
        [_delegate didSelectCalculationFor:calMode];
    }
    
    if (IS_IPHONE) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self.A3RootViewController dismissRightSideViewController];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.calForItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:17];
    }
    
    // Configure the cell...
    NSNumber *modeNumb = _calForItems[indexPath.row];
    A3LoanCalcCalculationMode calMode = modeNumb.integerValue;
    cell.textLabel.text = [LoanCalcString titleOfCalFor:calMode];
    
    if (calMode == A3LC_CalculationForDownPayment) {
        if ([LoanCalcPreference new].showDownPayment) {
            cell.textLabel.textColor = [UIColor blackColor];
        }
        else {
            cell.textLabel.textColor = [UIColor colorWithRed:201.0/255.0 green:201.0/255.0 blue:201.0/255.0 alpha:1.0];
        }
    }
    else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    if (_currentCalcFor == calMode) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
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
