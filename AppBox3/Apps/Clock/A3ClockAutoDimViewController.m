//
//  A3ClockAutoDimViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/23/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3ClockAutoDimViewController.h"
#import "A3ClockDataManager.h"
#import "A3UserDefaults.h"
#import "A3UserDefaultsKeys.h"

@interface A3ClockAutoDimViewController ()
@property (nonatomic, strong) NSArray *items;
@end

@implementation A3ClockAutoDimViewController

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {

    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

static NSString *const reuseIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Auto Dim", @"Auto Dim");

    _items = @[ @0, @5, @10, @15, @20, @30, @60 ];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseIdentifier];
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
    return [_items count];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return NSLocalizedString(@"ExplainAutoDim", @"ExplainAutoDim");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];

    NSInteger cellValue = [_items[indexPath.row] integerValue];
    cell.textLabel.text = [_dataManager autoDimStringWithValue:cellValue];

    NSInteger value = [[A3UserDefaults standardUserDefaults] integerForKey:A3ClockAutoDim];
    if (cellValue == value) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[A3UserDefaults standardUserDefaults] setObject:_items[indexPath.row] forKey:A3ClockAutoDim];
    [[A3UserDefaults standardUserDefaults] synchronize];

    [self.navigationController popViewControllerAnimated:YES];
}

@end
