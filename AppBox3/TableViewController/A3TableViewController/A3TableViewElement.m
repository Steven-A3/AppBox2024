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
#import "A3TableViewExpandableElement.h"
#import "A3UIDevice.h"
#import "A3TableViewSection.h"

@implementation A3TableViewElement

- (UITableViewCell *)cellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
 	NSString *reuseIdentifier = @"A3TableViewElementCell";
	A3TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (!cell) {
		cell = [[A3TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	}
	cell.textLabel.text = self.title;
	cell.textLabel.textColor = [UIColor blackColor];
	if ([self.imageName length]) {
		cell.imageView.image = [UIImage imageNamed:self.imageName];
	}

	NSInteger index = [self.expandableElement.elements indexOfObject:self];
	if (self.expandableElement) {
		if (index == [self.expandableElement.elements count] - 1) {
			if ([tableView numberOfRowsInSection:indexPath.section] - 1 == indexPath.row) {
				[cell setBottomSeparatorForBottomRow];
			} else {
				[cell setBottomSeparatorForExpandableBottom];
			}
		} else {
			[cell setBottomSeparatorForMiddleRow];
		}
	} else {
		if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
			[cell setBottomSeparatorForBottomRow];
		} else {
			[cell setBottomSeparatorForMiddleRow];
		}
	}
	if (indexPath.row == 0) {
		[cell showTopSeparator];
	}
	return cell;
}

- (void)didSelectCellInViewController:(UIViewController *)viewController tableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if (self.onSelected) {
		self.onSelected(self, YES);
	}
}

@end
