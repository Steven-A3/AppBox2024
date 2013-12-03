//
//  A3TableViewExpandableElement.m
//  AppBox3
//
//  Created by A3 on 10/29/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TableViewExpandableElement.h"
#import "A3TableViewExpandableHeaderCell.h"
#import "A3TableViewSection.h"
#import "A3TableViewExpandableDefaultCell.h"
#import "A3UIDevice.h"
#import "A3TableViewExpandableCell.h"

@interface A3TableViewExpandableElement () <A3TableViewExpandableCellDelegate>
@end

@implementation A3TableViewExpandableElement

- (id)init {
	self = [super init];
	if (self) {
		self.collapsed = YES;
	}

	return self;
}

- (UITableViewCell *)cellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {

	A3TableViewExpandableCell *cell = nil;

	if (self.cellType == A3TableViewExpandableElementCellTypeSectionHeader) {
		NSString *reuseIdentifier = @"A3TableViewExpandableElementSectionHeaderTypeCell";

		A3TableViewExpandableHeaderCell *sectionHeaderTypeCell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
		if (!sectionHeaderTypeCell) {
			sectionHeaderTypeCell = [[A3TableViewExpandableHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
		}
		cell = sectionHeaderTypeCell;

		sectionHeaderTypeCell.titleLabel.text = self.title;
		[sectionHeaderTypeCell.titleLabel sizeToFit];

		self.titleLabel = sectionHeaderTypeCell.titleLabel;

	} else {
		NSString *reuseIdentifier = @"A3TableViewExpandableElementDefaultTypeCell";
		A3TableViewExpandableDefaultCell *defaultTypeCell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
		if (!defaultTypeCell) {
			defaultTypeCell = [[A3TableViewExpandableDefaultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
		}
		cell = defaultTypeCell;

		defaultTypeCell.textLabel.text = self.title;
	}

	if ([self.imageName length]) {
		cell.imageView.image = [UIImage imageNamed:self.imageName];
	}

	[cell.expandButton setTitle:self.isCollapsed ? @"j":@"i" forState:UIControlStateNormal];
	cell.delegate = self;

	NSInteger index = [self.section.elementsMatchingTableView indexOfObject:self];
	if (index == 0) {
		[cell showTopSeparator];
	}
	if (index == [self.section.elementsMatchingTableView count] - 1) {
		[cell setBottomSeparatorForBottomRow];
	} else {
		[cell setBottomSeparatorForMiddleRow];
	}

	self.tableView = tableView;
	self.cell = cell;

	return cell;
}

- (void)expandButtonPressed:(UIButton *)expandButton {
	@autoreleasepool {
		NSIndexPath *indexPath = [self.tableView indexPathForCell:self.cell];

		[self.section toggleExpandableElementAtIndexPath:indexPath];

		NSMutableArray *indexPaths = [NSMutableArray new];
		for (NSInteger idx = 0; idx < [self.elements count]; idx++) {
			[indexPaths addObject:[NSIndexPath indexPathForRow:idx + indexPath.row + 1 inSection:indexPath.section]];
		}
		if (_collapsed) {
			[_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
			[expandButton setTitle:@"j" forState:UIControlStateNormal];
			self.titleLabel.textColor = [UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0];
		} else {
			[_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
			[_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
			[expandButton setTitle:@"i" forState:UIControlStateNormal];
			self.titleLabel.textColor = _tableView.tintColor;
		}

		NSInteger index = [self.section.elementsMatchingTableView indexOfObject:self];
		if (index == [self.section.elementsMatchingTableView count] - 1) {
			[self.cell setBottomSeparatorForBottomRow];
		} else {
			[self.cell setBottomSeparatorForMiddleRow];
		}
	}
}

- (void)setElements:(NSArray *)elements {
	_elements = elements;
	[_elements enumerateObjectsUsingBlock:^(A3TableViewElement *child, NSUInteger idx, BOOL *stop) {
		child.expandableElement = self;
	}];
}

- (void)didSelectCellInViewController:(UIViewController <A3SelectTableViewControllerProtocol> *)viewController tableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
	[super didSelectCellInViewController:viewController tableView:tableView atIndexPath:indexPath];

	[self expandButtonPressed:self.cell.expandButton];
}

@end
