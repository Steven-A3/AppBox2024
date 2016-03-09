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
#import "UIViewController+NumberKeyboard.h"
#import "UIViewController+iPad_rightSideView.h"
#import "UIViewController+tableViewStandardDimension.h"

@interface A3TipCalcSettingViewController ()

@end

@implementation A3TipCalcSettingViewController

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

	self.title = NSLocalizedString(A3AppName_Settings, nil);
	self.tableView.separatorColor = A3UITableViewSeparatorColor;
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}

    if (IS_IPHONE) {
        [self rightBarButtonDoneButton];
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
	[super didMoveToParentViewController:parent];

	FNLOG(@"%@", parent);
	if (!parent) {
		[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationChildViewControllerDidDismiss object:self];
	}
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
	if (IS_IPAD) {
		[[[A3AppDelegate instance] rootViewController_iPad] dismissRightSideViewController];
	} else {
		[self dismissViewControllerAnimated:YES completion:nil];
	}

	if ([_delegate respondsToSelector:@selector(dismissTipCalcSettingsViewController)]) {
		[_delegate dismissTipCalcSettingsViewController];
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
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        cell.accessoryView = [[UISwitch alloc] initWithFrame:CGRectZero];
        [((UISwitch *)cell.accessoryView) addTarget:self action:@selector(switchButtonFliped:) forControlEvents:UIControlEventValueChanged];
        
    }
    
    // Configure the cell...
    switch ([indexPath section]) {
        case 0:
            cell.textLabel.text = NSLocalizedString(@"Tax", @"Tax");
            [((UISwitch *)cell.accessoryView) setOn:[self.dataManager.tipCalcData.showTax boolValue]];
            break;
        case 1:
            cell.textLabel.text = NSLocalizedString(@"Split", @"Split");
            [((UISwitch *)cell.accessoryView) setOn:[self.dataManager.tipCalcData.showSplit boolValue]];
            break;
        case 2:
            cell.textLabel.text = NSLocalizedString(@"Rounding", @"Rounding");
            [((UISwitch *)cell.accessoryView) setOn:[self.dataManager.tipCalcData.showRounding boolValue]];
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
			self.dataManager.taxOption = [sender isOn];
            if ([sender isOn]) {
                self.dataManager.knownValue = TCKnownValue_CostsBeforeTax;
                //if (![self.dataManager hasCalcData] && [self.dataManager isTaxByLocation] || ![self.dataManager defaultTax]) {
                if ([self.dataManager.taxPercent isEqualToNumber:@0]) {
                    [self.dataManager getUSTaxRateByLocation];
                }
            }
        }
            break;
        case 1:
        {
			self.dataManager.splitOption = [sender isOn];
        }
            break;
        case 2:
        {
			self.dataManager.RoundingOption = [sender isOn];
            if ([sender isOn]) {
                //self.dataManager.roundingMethodOption = TCRoundingMethodOption_Exact;
            }
        }
            break;
            
        default:
            break;
    }
    
    if ([_delegate respondsToSelector:@selector(tipCalcSettingsChanged)]) {
        [_delegate tipCalcSettingsChanged];
    }
}

@end
