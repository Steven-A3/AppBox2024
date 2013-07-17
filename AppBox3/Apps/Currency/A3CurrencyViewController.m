//
//  A3CurrencyViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/5/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CurrencyViewController.h"
#import "CurrencyFavorite.h"
#import "NSManagedObject+MagicalFinders.h"
#import "A3CurrencyTVActionCell.h"
#import "A3CurrencyTableViewCell.h"
#import "CurrencyHistory.h"
#import "CurrencyHistory+handler.h"
#import "CurrencyItem.h"

@interface A3CurrencyViewController ()

@property (nonatomic, strong) NSArray *favorites;
@property (nonatomic, strong) CurrencyHistory *history;

@end

@implementation A3CurrencyViewController

static NSString *const A3CurrencyCellID = @"A3CurrencyTableViewCell";
static NSString *const A3CurrencyActionCellID = @"A3CurrencyActionCell";

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

	self.tableView.rowHeight = 84.0;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

	[self.tableView registerNib:[UINib nibWithNibName:@"A3CurrencyTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:A3CurrencyCellID];
	[self.tableView registerNib:[UINib nibWithNibName:@"A3CurrencyTVActionCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:A3CurrencyActionCellID];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)favorites {
	if (nil == _favorites) {
		_favorites = [CurrencyFavorite MR_findAll];
	}
	return _favorites;
}

- (CurrencyHistory *)currencyHistory {
	if (nil == _history) {
		_history = [CurrencyHistory firstObject];
	}
    return _history;
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
    return [self.favorites count] + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;
	if (indexPath.row == 1) {
		// Second row is for equal sign
		A3CurrencyTVActionCell *actionCell = [self reusableActionCellForTableView:tableView];
		actionCell.centerLabel.textColor = [UIColor blackColor];
		actionCell.centerLabel.font = [UIFont fontWithName:@"HiraMinProN-W3" size:60.0];
		actionCell.centerLabel.text = @"=";
		actionCell.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];

		cell = actionCell;
	} else if (indexPath.row == ([_favorites count] + 1)) {
		// Bottom row is reserved for "plus" action.
		A3CurrencyTVActionCell *actionCell = [self reusableActionCellForTableView:tableView];
		actionCell.centerLabel.textColor = [UIColor colorWithRed:16.0/255.0 green:92.0/255.0 blue:254.0/255.0 alpha:1.0];
		actionCell.centerLabel.font = [UIFont fontWithName:@"FontAwesome" size:25.0];
		actionCell.centerLabel.text = @"";
		actionCell.backgroundColor = [UIColor whiteColor];

		cell = actionCell;
	} else {
		NSInteger dataIndex = (indexPath.row > 1) ? indexPath.row  - 1 : indexPath.row;

		A3CurrencyTableViewCell *dataCell;
		dataCell = [tableView dequeueReusableCellWithIdentifier:A3CurrencyCellID forIndexPath:indexPath];
		if (nil == dataCell) {
			dataCell = [[A3CurrencyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:A3CurrencyCellID];
		}

		CurrencyFavorite *favorite = self.favorites[dataIndex];
		NSNumber *value;
		if (dataIndex == 0) {
			value = self.currencyHistory.value;
		} else {
			CurrencyFavorite *favoriteZero = self.favorites[0];
			float rate = favoriteZero.currencyItem.rateToUSD.floatValue / favorite.currencyItem.rateToUSD.floatValue;
			value = @(self.currencyHistory.value.floatValue * rate);
			dataCell.rateLabel.text = [NSString stringWithFormat:@"Rate = %.2f", rate];
		}
		dataCell.valueField.text = [self currencyFormattedStringForCurrency:favorite.currencyItem.currencyCode value:value];
		dataCell.codeLabel.text = favorite.currencyItem.currencyCode;

		if (dataIndex > 0) {
			dataCell.separatorLineView.backgroundColor = [UIColor colorWithRed:200.0 / 255.0 green:200.0 / 255.0 blue:200.0 / 255.0 alpha:1.0];
		} else {
			dataCell.separatorLineView.backgroundColor = [UIColor clearColor];
		}
		cell = dataCell;
	}

    return cell;
}

- (NSString *)currencyFormattedStringForCurrency:(NSString *)code value:(NSNumber *)value {
	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	[nf setCurrencyCode:code];
	[nf setNumberStyle:NSNumberFormatterCurrencyStyle];
	return [nf stringFromNumber:value];
}

- (A3CurrencyTVActionCell *)reusableActionCellForTableView:(UITableView *)tableView {
	A3CurrencyTVActionCell *cell;
	cell = [tableView dequeueReusableCellWithIdentifier:A3CurrencyActionCellID];
	if (nil == cell) {
		cell = [[A3CurrencyTVActionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:A3CurrencyActionCellID];
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
