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
#import "UIViewController+NumberKeyboard.h"

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

    self.navigationItem.title = NSLocalizedString(@"Calculation", @"Calculation");
    
    self.tableView.separatorColor = [self tableViewSeparatorColor];
    if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
        self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if ([self.navigationController.navigationBar isHidden]) {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
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
	[[[A3AppDelegate instance] rootViewController_iPad] dismissRightSideViewController];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *modeNumb = _calForItems[indexPath.row];
    A3LoanCalcCalculationMode calMode = modeNumb.integerValue;
    
    if ((calMode == A3LC_CalculationForDownPayment) && ![LoanCalcPreference showDownPayment]) {
        return;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectCalculationForMode:)]) {
        [_delegate didSelectCalculationForMode:calMode];
    }
    
    if (IS_IPHONE) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [[[A3AppDelegate instance] rootViewController_iPad] dismissRightSideViewController];
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
        if ([LoanCalcPreference showDownPayment]) {
            cell.textLabel.textColor = [UIColor blackColor];
        }
        else {
            cell.textLabel.textColor = [UIColor colorWithRed:201.0/255.0 green:201.0/255.0 blue:201.0/255.0 alpha:1.0];
        }
    }
    else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    if (_currentCalcMode == calMode) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

@end
