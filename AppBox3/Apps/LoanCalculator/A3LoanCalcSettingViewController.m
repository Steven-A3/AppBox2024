//
//  A3LoanCalcSettingViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 6..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcSettingViewController.h"
#import "A3LoanCalcSettingSwitchCell.h"
#import "LoanCalcPreference.h"
#import "A3AppDelegate.h"
#import "UIViewController+A3AppCategory.h"
#import "UIViewController+A3Addition.h"

@interface A3LoanCalcSettingViewController ()

@property (nonatomic, strong) LoanCalcPreference *preference;
@property (nonatomic, strong) void (^settingChangedBlock)(void);
@property (nonatomic, strong) void (^settingDismissBlock)(void);

@end

@implementation A3LoanCalcSettingViewController

NSString *const A3LoanCalcSettingSwitchCellID = @"A3LoanCalcSettingSwitchCell";
NSString *const A3LoanCalcSettingSelectCellID = @"A3LoanCalcSettingSelectCell";

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
    
    self.navigationItem.title = @"Settings";
    
    self.tableView.separatorColor = [self tableViewSeparatorColor];
    self.tableView.contentInset = UIEdgeInsetsMake(-1, 0, 0, 0);
    
    if (IS_IPHONE) {
        [self rightBarButtonDoneButton];
    }
}

- (LoanCalcPreference *)preference
{
    if (!_preference) {
        _preference = [LoanCalcPreference new];
    }
    
    return _preference;
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
	if (IS_IPAD) {
		[self.A3RootViewController dismissRightSideViewController];
	} else {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
    
    if (_settingDismissBlock) {
        _settingDismissBlock();
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)downPaymentSwitchAction:(UISwitch *)onoff
{
    self.preference.showDownPayment = onoff.on;
    
    if (onoff.on) {
        [[NSNotificationCenter defaultCenter] postNotificationName:A3LoanCalcNotificationDownPaymentEnabled object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:A3LoanCalcNotificationDownPaymentDisabled object:nil];
    }
    
    if (_settingChangedBlock) {
        _settingChangedBlock();
    }
}

- (void)extraPaymentSwitchAction:(UISwitch *)onoff
{
    self.preference.showExtraPayment = onoff.on;
    
    if (onoff.on) {
        [[NSNotificationCenter defaultCenter] postNotificationName:A3LoanCalcNotificationExtraPaymentEnabled object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:A3LoanCalcNotificationExtraPaymentDisabled object:nil];
    }

    if (_settingChangedBlock) {
        _settingChangedBlock();
    }
}

#pragma mark - 
- (void)setSettingChangedCompletionBlock:(void (^)(void))changedBlock {
    self.settingChangedBlock = changedBlock;
}

- (void)setSettingDismissCompletionBlock:(void (^)(void))dismissBlock {
    self.settingDismissBlock = dismissBlock;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;

	if (indexPath.section == 0) {
		A3LoanCalcSettingSwitchCell *switchCell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcSettingSwitchCellID forIndexPath:indexPath];
		switchCell.selectionStyle = UITableViewCellSelectionStyleNone;
		switchCell.titleLabel.text = @"Down Payment";
		switchCell.onoffSwitch.on = self.preference.showDownPayment;
		[switchCell.onoffSwitch addTarget:self action:@selector(downPaymentSwitchAction:) forControlEvents:UIControlEventValueChanged];

		cell = switchCell;
	}
	else if (indexPath.section == 1) {
		A3LoanCalcSettingSwitchCell *switchCell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcSettingSwitchCellID forIndexPath:indexPath];
		switchCell.selectionStyle = UITableViewCellSelectionStyleNone;
		switchCell.titleLabel.text = @"Extra Payment";
		switchCell.onoffSwitch.on = self.preference.showExtraPayment;
		[switchCell.onoffSwitch addTarget:self action:@selector(extraPaymentSwitchAction:) forControlEvents:UIControlEventValueChanged];

		cell = switchCell;
	}

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 36;
    }
    else {
        return 36-2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
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
