//
//  A3LoanCalcSelectFrequencyViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 9..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcSelectFrequencyViewController.h"
#import "LoanCalcString.h"

#import "A3AppDelegate.h"
#import "UIViewController+NumberKeyboard.h"

@interface A3LoanCalcSelectFrequencyViewController ()

@property (nonatomic, strong) NSArray *frequencyItems;

@end

@implementation A3LoanCalcSelectFrequencyViewController

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

    self.navigationItem.title = NSLocalizedString(@"Frequency", @"Frequency");
    
    self.tableView.separatorColor = [self tableViewSeparatorColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)frequencyItems
{
    if (!_frequencyItems) {
        _frequencyItems = [LoanCalcMode frequencyTypes];
    }
    
    return _frequencyItems;
}

- (void)doneButtonAction:(id)button {
	[[[A3AppDelegate instance] rootViewController] dismissRightSideViewController];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *freqNumb = _frequencyItems[indexPath.row];
    A3LoanCalcFrequencyType freqType = freqNumb.integerValue;
    
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectLoanCalcFrequency:)]) {
        [_delegate didSelectLoanCalcFrequency:freqType];
    }
    
    if (IS_IPHONE) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [[[A3AppDelegate instance] rootViewController] dismissRightSideViewController];
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
    return self.frequencyItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.textLabel.font = [UIFont systemFontOfSize:17];
    }
    
    // Configure the cell...
    NSNumber *freqNumb = _frequencyItems[indexPath.row];
    A3LoanCalcFrequencyType freqType = freqNumb.integerValue;
    cell.textLabel.text = [LoanCalcString titleOfFrequency:freqType];
    
    if (_currentFrequency == freqType) {
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
