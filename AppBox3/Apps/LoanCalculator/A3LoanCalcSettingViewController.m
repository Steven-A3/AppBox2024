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
#import "UIViewController+NumberKeyboard.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+iPad_rightSideView.h"

@interface A3LoanCalcSettingViewController ()

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

    self.navigationItem.title = NSLocalizedString(A3AppName_Settings, nil);
    
    self.tableView.separatorColor = [self tableViewSeparatorColor];
    self.tableView.contentInset = UIEdgeInsetsMake(-1, 0, 0, 0);
    
    if (IS_IPHONE) {
        [self rightBarButtonDoneButton];
    }

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudKeyValueStoreDidImport object:nil];
}

- (void)cloudStoreDidImport {
	[self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isBeingDismissed]) {
		[self removeObserver];
	}
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudKeyValueStoreDidImport object:nil];
}

- (void)dealloc {
	[self removeObserver];
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
		[[[A3AppDelegate instance] rootViewController] dismissRightSideViewController];
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

- (void)downPaymentSwitchAction:(UISwitch *)switchControl
{
	[LoanCalcPreference setShowDownPayment:switchControl.on];
    
    if (switchControl.on) {
        [[NSNotificationCenter defaultCenter] postNotificationName:A3LoanCalcNotificationDownPaymentEnabled object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:A3LoanCalcNotificationDownPaymentDisabled object:nil];
    }
    
    if (_settingChangedBlock) {
        _settingChangedBlock();
    }
}

- (void)extraPaymentSwitchAction:(UISwitch *)switchControl
{
	[LoanCalcPreference setShowExtraPayment:switchControl.on];
    
    if (switchControl.on) {
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

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 1) {
		return NSLocalizedString(@"For monthly payment.", @"For monthly payment.");
	}
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;

	if (indexPath.section == 0) {
		A3LoanCalcSettingSwitchCell *switchCell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcSettingSwitchCellID forIndexPath:indexPath];
		switchCell.selectionStyle = UITableViewCellSelectionStyleNone;
		switchCell.titleLabel.text = NSLocalizedString(@"Down Payment", @"Down Payment");
		switchCell.onoffSwitch.on = [LoanCalcPreference showDownPayment];
		[switchCell.onoffSwitch addTarget:self action:@selector(downPaymentSwitchAction:) forControlEvents:UIControlEventValueChanged];

		cell = switchCell;
	}
	else if (indexPath.section == 1) {
		A3LoanCalcSettingSwitchCell *switchCell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcSettingSwitchCellID forIndexPath:indexPath];
		switchCell.selectionStyle = UITableViewCellSelectionStyleNone;
		switchCell.titleLabel.text = NSLocalizedString(@"Extra Payment", @"Extra Payment");
		switchCell.onoffSwitch.on = [LoanCalcPreference showExtraPayment];
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
    if (section == 1) return UITableViewAutomaticDimension;
	return 1;
}

@end
