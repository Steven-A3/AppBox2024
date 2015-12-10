//
//  A3CurrencyPickerStyleViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 12/9/15.
//  Copyright © 2015 ALLABOUTAPPS. All rights reserved.
//

#import "A3CurrencyPickerStyleViewController.h"
#import "A3CurrencyTVDataCell.h"
#import "A3CurrencyTableViewController.h"

@interface A3CurrencyPickerStyleViewController ()
<UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *updateDateLabel;
@property (weak, nonatomic) IBOutlet UIView *lineAboveAdBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *adBackgroundView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adBackgroundViewHeightConstraint;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *sampleTitleLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *sampleValueLabels;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *termSelectSegmentedControl;
@property (weak, nonatomic) IBOutlet UIImageView *chartImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chartImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chartImageViewWidthConstraint;

@end

@implementation A3CurrencyPickerStyleViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView

- (void)setupTableView {
	[self.tableView registerClass:[A3CurrencyTVDataCell class] forCellReuseIdentifier:A3CurrencyDataCellID];
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    self.tableView.separatorColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    self.tableView.showsVerticalScrollIndicator = NO;
}

#pragma mark - Update Button

- (IBAction)updateButtonAction:(UIButton *)sender {
}

#pragma mark - Swap Button

- (IBAction)swapButtonAction:(UIButton *)sender {
}

#pragma mark - Term Segmented Control

- (void)setupSegmentedControlTitles {
    
}

- (IBAction)termSelectValueChanged:(UISegmentedControl *)sender {
}

@end
