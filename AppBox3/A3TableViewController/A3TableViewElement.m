//
//  A3TableViewElement.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/22/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TableViewElement.h"
#import "A3SelectTableViewController.h"
#import "A3TableViewCell.h"

@implementation A3TableViewElement

- (UITableViewCell *)cellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
 	NSString *reuseIdentifier = @"A3TableViewElementCell";
	A3TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (!cell) {
		cell = [[A3TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	}
	cell.textLabel.text = self.title;
	cell.textLabel.textColor = [UIColor blackColor];

	return cell;
}

- (void)didSelectCellInViewController:(UIViewController *)viewController tableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
