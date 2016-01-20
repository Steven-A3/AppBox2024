//
//  A3StandardDetailTableViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 11/11/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3StandardDetailTableViewController.h"
#import "A3StandardTableViewCell.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "UIViewController+A3Addition.h"
#import "A3DefaultColorDefines.h"

@interface A3StandardDetailTableViewController ()

@property (nonatomic, strong) NSArray *titlesArray;		// Contains array of titles. Each array has titles in that section.
@property (nonatomic, strong) NSArray *detailsArray;	// Contains array of details.

@end

@implementation A3StandardDetailTableViewController

- (instancetype)initWithTitles:(NSArray *)titles details:(NSArray *)details {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {
		_titlesArray = [titles copy];
		_detailsArray = [details copy];
	}
	return self;
}

NSString *const A3StandardDetailViewCellReuseID = @"A3StandardDetailViewCellID";

- (void)viewDidLoad {
    [super viewDidLoad];

	[self rightBarButtonDoneButton];

	self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.separatorInset = A3UITableViewSeparatorInset;
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
	[self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [_titlesArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	NSArray *sectionArray = _titlesArray[section];
    return [sectionArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    A3StandardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:A3StandardDetailViewCellReuseID];
	if (!cell) {
		cell = [[A3StandardTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:A3StandardDetailViewCellReuseID];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}

	cell.textLabel.font = [UIFont systemFontOfSize:15];
	cell.textLabel.text = _titlesArray[indexPath.section][indexPath.row];

	cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
	cell.detailTextLabel.textColor = COLOR_DEFAULT_TEXT_GRAY;
	cell.detailTextLabel.text = _detailsArray[indexPath.section][indexPath.row];

    return cell;
}

@end
