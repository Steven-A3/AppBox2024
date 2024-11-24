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
#import "A3SyncManager.h"
#import "A3UIDevice.h"

@interface A3LoanCalcSettingViewController ()

@property (nonatomic, strong) void (^settingChangedBlock)(void);
@property (nonatomic, strong) void (^settingDismissBlock)(void);
@property (nonatomic, strong) UISwitch *downPaymentSwitch;
@property (nonatomic, strong) UISwitch *extraPaymentSwitch;

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
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}

	if (IS_IPHONE) {
        [self rightBarButtonDoneButton];
    }

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudKeyValueStoreDidImport object:nil];
}

- (void)cloudStoreDidImport {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Code here is executed on the main thread.
        // You can safely update UI components.
        [self.tableView reloadData];
    });
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([self.navigationController.navigationBar isHidden]) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
	}
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
		[[[A3AppDelegate instance] rootViewController_iPad] dismissRightSideViewController];
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

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 1) {
		return NSLocalizedString(@"For monthly payment.", @"For monthly payment.");
	}
	return nil;
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
			cell.textLabel.text = NSLocalizedString(@"Down Payment", @"Down Payment");
			cell.accessoryView = self.downPaymentSwitch;
			break;
		case 1:
			cell.textLabel.text = NSLocalizedString(@"Extra Payment", @"Extra Payment");
			cell.accessoryView = self.extraPaymentSwitch;
			break;
	}
}

- (UISwitch *)downPaymentSwitch {
	if (!_downPaymentSwitch) {
		_downPaymentSwitch = [UISwitch new];
		_downPaymentSwitch.on = [LoanCalcPreference showDownPayment];
		[_downPaymentSwitch addTarget:self action:@selector(downPaymentSwitchAction:) forControlEvents:UIControlEventValueChanged];
	}
	return _downPaymentSwitch;
}

- (UISwitch *)extraPaymentSwitch {
	if (!_extraPaymentSwitch) {
		_extraPaymentSwitch = [UISwitch new];
		_extraPaymentSwitch.on = [LoanCalcPreference showExtraPayment];
		[_extraPaymentSwitch addTarget:self action:@selector(extraPaymentSwitchAction:) forControlEvents:UIControlEventValueChanged];
	}
	return _extraPaymentSwitch;
}

@end
