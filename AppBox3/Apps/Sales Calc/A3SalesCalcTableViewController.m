//
//  A3SalesCalcTableViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/12/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3SalesCalcTableViewController.h"

@interface A3SalesCalcTableViewController ()

@property (nonatomic, strong) UIView *advancedHeaderView;
@property (nonatomic) BOOL showAdvanced;

@end

@implementation A3SalesCalcTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

NSString *CellIdentifier = @"CellIdentifier";

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];

	if (!_showAdvanced) {
		self.tableView.tableFooterView = [self advancedHeaderView];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Return the number of section
	return _showAdvanced ? 3 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case 2:
			return 3;
		default:
			return 2;
	}
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"KNOWN VALUE";
	}
	return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if (section == 2) {

	}
	return [super tableView:tableView viewForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 56;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];



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

- (UIView *)advancedHeaderView {
	if (_advancedHeaderView) {
		_advancedHeaderView = [UIView new];
		_advancedHeaderView.frame = CGRectMake(0,0,self.view.bounds.size.width, 56);
		UILabel *headerLabel = [UILabel new];
		headerLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-M3" size:14];
		headerLabel.textColor = [UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0];
		headerLabel.text = @"ADVANCED";
		headerLabel.tag = 9876;
		[_advancedHeaderView addSubview:headerLabel];

		UIButton *openCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
		openCloseButton.titleLabel.font = [UIFont fontWithName:@"appbox" size:15];
		[openCloseButton setTitleColor:[UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:204.0/255.0 alpha:1.0] forState:UIControlStateNormal];
		[openCloseButton setTitle:@"n" forState:UIControlStateNormal];
		[openCloseButton addTarget:self action:@selector(toggleAdvanced:) forControlEvents:UIControlEventTouchUpInside];
	}
	return _advancedHeaderView;
}

- (void)toggleAdvanced:(UIButton *)button {
	UILabel *headerLabel = (UILabel *) [button.superview viewWithTag:9876];

	if ([[button titleForState:UIControlStateNormal] isEqualToString:@"n"]) {
		// Current closed, add advaned rows.
		[button setTitle:@"o" forState:UIControlStateNormal];
		headerLabel.textColor = self.view.tintColor;
		_showAdvanced = YES;
		self.tableView.tableFooterView = nil;

		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationBottom];
	} else {
		[button setTitle:@"n" forState:UIControlStateNormal];
		headerLabel.textColor = [UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0];
		_showAdvanced = NO;
		self.tableView.tableFooterView = [self advancedHeaderView];
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationBottom];
	}
}

@end
