//
//  A3AppSelectTableViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 3/11/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3AppSelectTableViewController.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3AppDelegate.h"
#import "UIViewController+A3Addition.h"

NSString *const A3AppSelectVCDefaultCell = @"defaultCell";

@interface A3AppSelectTableViewController ()

@property (nonatomic, strong) NSArray *availableAppArray;

@end

@implementation A3AppSelectTableViewController

- (id)initWithArray:(NSArray *)availableAppArray {
	self = [super initWithStyle:UITableViewStylePlain];
	if (self) {
		_availableAppArray = availableAppArray;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	self.title = @"Select App";

	self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.separatorInset = UIEdgeInsetsMake(0, 57, 0, 0);
	
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:A3AppSelectVCDefaultCell];
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}

	[self leftBarButtonCancelButton];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancelButtonAction:(UIBarButtonItem *)barButtonItem {
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_availableAppArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:A3AppSelectVCDefaultCell forIndexPath:indexPath];
	
	cell.textLabel.font = [UIFont systemFontOfSize:17];

	NSDictionary *menuItem = _availableAppArray[indexPath.row];
	cell.textLabel.text = NSLocalizedString(menuItem[kA3AppsMenuName], nil);
	NSDictionary *appInfoDictionary = [[A3AppDelegate instance] appInfoDictionary][menuItem[kA3AppsMenuName]];
	cell.imageView.image = [UIImage imageNamed:appInfoDictionary[kA3AppsMenuImageName]];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *menuItem = _availableAppArray[indexPath.row];
	if ([_delegate respondsToSelector:@selector(viewController:didSelectAppNamed:)]) {
		[_delegate viewController:self didSelectAppNamed:menuItem[kA3AppsMenuName]];
	}
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
