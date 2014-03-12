//
//  A3TipCalcSettingViewController.m
//  A3TeamWork
//
//  Created by dotnetguy83 on 3/7/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3TipCalcSettingViewController.h"
#import "A3DefaultColorDefines.h"
#import "A3TipCalcDataManager.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"


@interface A3TipCalcSettingViewController ()

@end

@implementation A3TipCalcSettingViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Settings";
        self.tableView.separatorColor = COLOR_TABLE_SEPARATOR;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (IS_IPHONE) {
        [self rightBarButtonDoneButton];
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
	@autoreleasepool {
		if (IS_IPAD) {
			[self.A3RootViewController dismissRightSideViewController];
		} else {
			[self dismissViewControllerAnimated:YES completion:nil];
		}
        
        if ([_delegate respondsToSelector:@selector(dismissTipCalcSettingsViewController)]) {
            [_delegate dismissTipCalcSettingsViewController];
        }
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:18];
        cell.accessoryView = [[UISwitch alloc] initWithFrame:CGRectZero];
        [((UISwitch *)cell.accessoryView) addTarget:self action:@selector(switchButtonFliped:) forControlEvents:UIControlEventValueChanged];
    }
    
    // Configure the cell...
    switch ([indexPath section]) {
        case 0:
            cell.textLabel.text = @"Tax";
            [((UISwitch *)cell.accessoryView) setOn:[[A3TipCalcDataManager sharedInstance].tipCalcData.showTax boolValue]];
            break;
        case 1:
            cell.textLabel.text = @"Split";
            [((UISwitch *)cell.accessoryView) setOn:[[A3TipCalcDataManager sharedInstance].tipCalcData.showSplit boolValue]];
            break;
        case 2:
            cell.textLabel.text = @"Rounding Method";
            [((UISwitch *)cell.accessoryView) setOn:[[A3TipCalcDataManager sharedInstance].tipCalcData.showRounding boolValue]];
            break;
            
        default:
            break;
    }
    cell.accessoryView.tag = indexPath.section;
    
    return cell;
}

- (void)switchButtonFliped:(UISwitch *)sender {
    switch ([sender tag]) {
        case 0:
        {
            [A3TipCalcDataManager sharedInstance].taxOption = [sender isOn];
            if ([sender isOn]) {
                //[A3TipCalcDataManager sharedInstance].knownValue = TCKnownValue_CostsBeforeTax;
                //if (![[A3TipCalcDataManager sharedInstance] hasCalcData] && [[A3TipCalcDataManager sharedInstance] isTaxByLocation] || ![[A3TipCalcDataManager sharedInstance] defaultTax]) {
                if ([[A3TipCalcDataManager sharedInstance].taxPercent isEqualToNumber:@0]) {
                    [[A3TipCalcDataManager sharedInstance] getUSTaxRateByLocation];
                }
            }
            
            if ([_delegate respondsToSelector:@selector(tipCalcSettingsChanged)]) {
                [_delegate tipCalcSettingsChanged];
            }
        }
            break;
        case 1:
        {
            [A3TipCalcDataManager sharedInstance].splitOption = [sender isOn];
            
            if ([_delegate respondsToSelector:@selector(tipCalcSettingsChanged)]) {
                [_delegate tipCalcSettingsChanged];
            }
        }
            break;
        case 2:
        {
            [A3TipCalcDataManager sharedInstance].RoundingOption = [sender isOn];
            if ([sender isOn]) {
                //[A3TipCalcDataManager sharedInstance].roundingMethodOption = TCRoundingMethodOption_Exact;
            }
            
            if ([_delegate respondsToSelector:@selector(tipCalcSettingsChanged)]) {
                [_delegate tipCalcSettingsChanged];
            }
        }
            break;
            
        default:
            break;
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
