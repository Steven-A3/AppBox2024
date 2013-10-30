//
//  A3TableViewExpandableElement.m
//  AppBox3
//
//  Created by A3 on 10/29/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TableViewExpandableElement.h"
#import "A3TableViewExpandableHeaderCell.h"

@interface A3TableViewExpandableElement () <A3TableViewExpandableHeaderCellProtocol>
@end

@implementation A3TableViewExpandableElement

- (UITableViewCell *)cellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
	NSString *reuseIdentifier = @"A3TableViewExpandableElementCell";
	A3TableViewExpandableHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (!cell) {
		cell = [[A3TableViewExpandableHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	}
	cell.titleLabel.text = self.title;
	[cell.titleLabel sizeToFit];

	[cell.expandButton setTitle:self.isCollapsed ? @"n":@"o" forState:UIControlStateNormal];
	cell.delegate = self;
	self.tableView = tableView;
	self.indexPath = indexPath;
	self.titleLabel = cell.titleLabel;

	return cell;
}

- (void)expandButtonPressed:(UIButton *)expandButton {
	@autoreleasepool {
		_collapsed = !_collapsed;

		NSMutableArray *indexPaths = [NSMutableArray new];
		for (NSInteger idx = 0; idx < [self.elements count]; idx++) {
			[indexPaths addObject:[NSIndexPath indexPathForRow:idx + self.indexPath.row + 1 inSection:self.indexPath.section]];
		}
		if (_collapsed) {
			[_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
			[expandButton setTitle:@"n" forState:UIControlStateNormal];
			self.titleLabel.textColor = [UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0];
		} else {
			[_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
			[_tableView scrollToRowAtIndexPath:indexPaths[0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
			[expandButton setTitle:@"o" forState:UIControlStateNormal];
			self.titleLabel.textColor = _tableView.tintColor;
		}
	}
}

@end
