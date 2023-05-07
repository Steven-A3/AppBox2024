//
//  A3JHTableViewExpandableElement.m
//  AppBox3
//
//  Created by A3 on 10/29/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3JHTableViewExpandableElement.h"
#import "A3JHTableViewExpandableHeaderCell.h"
#import "A3UserDefaults+A3Addition.h"

@interface A3JHTableViewExpandableElement () <A3TableViewExpandableHeaderCellProtocol>
@end

@implementation A3JHTableViewExpandableElement

@dynamic title;

- (UITableViewCell *)cellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
	NSString *reuseIdentifier = @"A3TableViewExpandableElementCell";
	A3JHTableViewExpandableHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (!cell) {
		cell = [[A3JHTableViewExpandableHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        cell.expandButton.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DegreesToRadians((self.isCollapsed ? 0 : -179.9)));
	}
	cell.titleLabel.text = self.title;
	[cell.titleLabel sizeToFit];

    [cell.expandButton setTitle:@"j" forState:UIControlStateNormal];
	cell.delegate = self;
	self.tableView = tableView;
	self.indexPath = indexPath;
	self.titleLabel = cell.titleLabel;
    self.titleLabel.textColor = [UIColor colorWithRed:109.0/255.0 green:109.0/255.0 blue:114.0/255.0 alpha:1.0];

	return cell;
}

- (void)expandButtonPressed:(UIButton *)expandButton {
	_collapsed = !_collapsed;

	// KJH - 2013.11.20
	[UIView animateWithDuration:0.35 animations:^{
		expandButton.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DegreesToRadians((self.isCollapsed ? 0 : -179.9)));
	}];

	[CATransaction begin];
	[CATransaction setCompletionBlock:^{
		if (_onExpandCompletion) {
			_onExpandCompletion(self);
		}
		if (!self.isCollapsed) {
			[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.indexPath.row + 1 inSection:self.indexPath.section] atScrollPosition:UITableViewScrollPositionTop animated:YES];
		}
	}];

	[_tableView beginUpdates];
	[_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.indexPath.row  inSection:self.indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
	NSMutableArray *indexPaths = [NSMutableArray new];
	for (NSInteger idx = 0; idx < [self.elements count]; idx++) {
		[indexPaths addObject:[NSIndexPath indexPathForRow:idx + self.indexPath.row + 1 inSection:self.indexPath.section]];
	}

	if (self.isCollapsed) {
		[_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationMiddle];
		self.titleLabel.textColor = [UIColor colorWithRed:109.0/255.0 green:109.0/255.0 blue:114.0/255.0 alpha:1.0];
	} else {
		[_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationMiddle];
        self.titleLabel.textColor = [[A3UserDefaults standardUserDefaults] themeColor];
	}

	[_tableView endUpdates];
	[CATransaction commit];
}

// kjh
- (void)didSelectCellInViewController:(UIViewController *)viewController tableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    A3JHTableViewExpandableHeaderCell *cell = (A3JHTableViewExpandableHeaderCell *)[tableView cellForRowAtIndexPath:indexPath];
	[self expandButtonPressed:cell.expandButton];
}

@end
