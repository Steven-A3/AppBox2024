//
//  A3JHTableViewSections.m
//  AppBox3
//
//  Created by A3 on 10/29/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3JHTableViewSections.h"
#import "A3JHTableViewElement.h"
#import "A3JHTableViewExpandableElement.h"
#import "common.h"

@implementation A3JHTableViewSections

- (NSInteger)numberOfSections {
	return [self.sectionsArray count];
}

- (NSInteger)indexOfExpandableElementInSection:(NSInteger)section {
	NSInteger indexOfExpandable = -1;
	NSArray *elements = self.sectionsArray[(NSUInteger) section];

	// Constraint: each section must have 0 or 1 expandable element and it must be last object of belonging section.
	NSInteger idx = 0;
	for (id obj in elements) {
		if ([obj isKindOfClass:[A3JHTableViewExpandableElement class]]) {
			indexOfExpandable = idx;
			break;
		}
		idx++;
	}
	return indexOfExpandable;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
	NSInteger indexOfExpandable = [self indexOfExpandableElementInSection:section];
	NSArray *elements = self.sectionsArray[(NSUInteger) section];
	if (indexOfExpandable >= 0) {
		A3JHTableViewExpandableElement *expandableElement = elements[(NSUInteger) indexOfExpandable];
		if (expandableElement.isCollapsed) {
			return [elements count];
		} else {
			return [elements count] + [expandableElement.elements count];
		}
	} else {
		return [elements count];
	}
}

- (A3JHTableViewElement *)elementForIndexPath:(NSIndexPath *)indexPath {
	NSArray *elements = self.sectionsArray[(NSUInteger) indexPath.section];
	NSInteger indexOfExpandable = [self indexOfExpandableElementInSection:indexPath.section];

	if (indexOfExpandable >= 0 && indexPath.row >= indexOfExpandable) {
		A3JHTableViewExpandableElement *expandableElement = elements[(NSUInteger) indexOfExpandable];
		if (indexPath.row == indexOfExpandable) {
			return expandableElement;
		} else {
			return expandableElement.elements[(NSUInteger) (indexPath.row - indexOfExpandable - 1)];
		}
	} else {
		return elements[(NSUInteger) indexPath.row];
	}
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	A3JHTableViewElement *element = [self elementForIndexPath:indexPath];
	[element didSelectCellInViewController:self.viewController tableView:self.tableView atIndexPath:indexPath];
}

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	A3JHTableViewElement *element = [self elementForIndexPath:indexPath];
	UITableViewCell *cell = [element cellForTableView:self.tableView atIndexPath:indexPath];
	NSInteger indexOfExpandableElement = [self indexOfExpandableElementInSection:indexPath.section];

	if ((indexOfExpandableElement >= 0) && (indexPath.row == indexOfExpandableElement - 1)) {
		cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
	}
	return cell;
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	A3JHTableViewElement *element = [self elementForIndexPath:indexPath];
	if ([element isKindOfClass:[A3JHTableViewExpandableElement class]]) {
		return 56;
	} else {
		return 44;
	}
}

@end
