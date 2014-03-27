//
//  A3TableViewRootElement.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/22/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TableViewRootElement.h"
#import "A3TableViewExpandableElement.h"
#import "A3TableViewSection.h"
#import "NSNumberExtensions.h"

@implementation A3TableViewRootElement

- (NSInteger)numberOfSections {
	return [self.sectionsArray count];
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
	A3TableViewSection *sectionObject = self.sectionsArray[(NSUInteger) section];
	return [sectionObject numberOfRows];
}

- (A3TableViewElement *)elementForIndexPath:(NSIndexPath *)indexPath {
	A3TableViewSection *sectionObject = self.sectionsArray[(NSUInteger) indexPath.section];

	return sectionObject.elementsMatchingTableView[indexPath.row];
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	A3TableViewElement *element = [self elementForIndexPath:indexPath];
	[element didSelectCellInViewController:self.viewController tableView:self.tableView atIndexPath:indexPath];
}

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	A3TableViewElement *element = [self elementForIndexPath:indexPath];
	UITableViewCell *cell = [element cellForTableView:self.tableView atIndexPath:indexPath];

	if (element.backgroundColor) {
		cell.backgroundColor = self.backgroundColor;
	}
	return cell;
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	A3TableViewElement *element = [self elementForIndexPath:indexPath];
	if (element.cellHeight) {
		return [element.cellHeight cgFloatValue];
	} else {
		return 44;
	}
}

@end
