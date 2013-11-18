//
//  A3TableViewSelectElement.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/22/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TableViewSelectElement.h"
#import "NSArray+validation.h"
#import "A3SelectTableViewController.h"
#import "A3TableViewCell.h"

@implementation A3TableViewSelectElement

- (UITableViewCell *)cellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
	NSString *reuseIdentifier = @"A3TableViewSelectElementCell";
	A3TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (!cell) {
		cell = [[A3TableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
	}
	cell.textLabel.text = self.title;
	cell.textLabel.textColor = [UIColor blackColor];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	if ([self.items isIndexValid:self.selectedIndex]) {
		cell.detailTextLabel.text = self.items[self.selectedIndex];
	}

	return cell;
}

- (void)didSelectCellInViewController:(UIViewController<A3SelectTableViewControllerProtocol> *)viewController tableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	A3SelectTableViewController *selectTableViewController = [A3SelectTableViewController new];
	selectTableViewController.root = self;
	selectTableViewController.delegate = viewController;
	selectTableViewController.indexPathOfOrigin = indexPath;
	[viewController.navigationController pushViewController:selectTableViewController animated:YES];
}

@end
