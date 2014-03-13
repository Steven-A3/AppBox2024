//
//  A3JHTableViewSelectElement.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/22/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3JHTableViewSelectElement.h"
#import "NSArray+validation.h"
#import "A3JHSelectTableViewController.h"
#import "A3JHTableViewCell.h"

@implementation A3JHTableViewSelectElement

- (UITableViewCell *)cellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
	NSString *reuseIdentifier = @"A3TableViewSelectElementCell";
	A3JHTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (!cell) {
		cell = [[A3JHTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
        cell.textLabel.font = [UIFont fontWithName:cell.textLabel.font.fontName size:17.0]; // KJH
	}
	cell.textLabel.text = self.title;
	cell.textLabel.textColor = [UIColor blackColor];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	if ([self.items isIndexValid:self.selectedIndex]) {
		cell.detailTextLabel.text = self.items[self.selectedIndex];
	}

	return cell;
}

- (void)didSelectCellInViewController:(UIViewController<A3JHSelectTableViewControllerProtocol> *)viewController tableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	A3JHSelectTableViewController *selectTableViewController = [A3JHSelectTableViewController new];
	selectTableViewController.root = self;
	selectTableViewController.delegate = viewController;
	selectTableViewController.indexPathOfOrigin = indexPath;
	[viewController.navigationController pushViewController:selectTableViewController animated:YES];
}

@end
