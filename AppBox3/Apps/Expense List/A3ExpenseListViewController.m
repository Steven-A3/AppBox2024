//
//  A3ExpenseListViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/5/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "A3ExpenseListViewController.h"
#import "A3VerticalLinesView.h"
#import "A3UIKit.h"
#import "A3SalesCalcHistoryTableViewCell.h"
#import "A3ExpenseListTableViewCell.h"

@interface A3ExpenseListViewController ()

@property (nonatomic, strong) IBOutlet UITableView *myTableView;

@end

@implementation A3ExpenseListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.title = @"Expense List";
        [A3UIKit addTopGradientLayerToView:self.view];
	}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(onActionButton)];
	self.navigationItem.rightBarButtonItem = rightButtonItem;

	// Do any additional setup after loading the view.
	A3VerticalLinesView *tableViewBackground = [[A3VerticalLinesView alloc] initWithFrame:CGRectZero];
	tableViewBackground.positions = @[@51.0, @54.0, @302.0, @412.0, @473.0];
	tableViewBackground.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1.0];
	_myTableView.backgroundView = tableViewBackground;
	_myTableView.rowHeight = 56.0;
}

- (void)onActionButton {

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"ExpenseListTableViewCell";
	A3ExpenseListTableViewCell *cell = (A3ExpenseListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	// Configure the cell...
	if (cell == nil) {
		cell = [[A3ExpenseListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}

	cell.item.text = @"Lamb Cutlets";
	cell.price.text = @"$15.60";
	cell.qty.text = @"6";
	cell.subtotal.text = @"$93.60";

	return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Return NO if you do not want the specified item to be editable.
	return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	// If none of the above are returned, then return \"none\".
	return UITableViewCellEditingStyleDelete;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		// Delete the row from the data source
	}
}

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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
