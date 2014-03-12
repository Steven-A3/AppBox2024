//
//  A3JHTableViewElement.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/22/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3JHTableViewElement.h"
#import "A3JHSelectTableViewController.h"
#import "A3JHTableViewCell.h"

@implementation A3JHTableViewElement

- (UITableViewCell *)cellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
 	NSString *reuseIdentifier = @"A3TableViewElementCell";
	A3JHTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (!cell) {
		cell = [[A3JHTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        cell.textLabel.font = [UIFont fontWithName:cell.textLabel.font.fontName size:17.0]; // KJH
	}
	cell.textLabel.text = self.title;
	cell.textLabel.textColor = [UIColor blackColor];

	return cell;
}

- (void)didSelectCellInViewController:(UIViewController *)viewController tableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
