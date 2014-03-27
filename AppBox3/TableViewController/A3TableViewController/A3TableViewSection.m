//
//  A3TableViewSection
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 11/22/13 3:36 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3TableViewSection.h"
#import "A3TableViewElement.h"
#import "A3TableViewExpandableElement.h"


@implementation A3TableViewSection {

}

- (void)setElements:(NSArray *)elements {
	_elements = elements;

	_elementsMatchingTableView = [NSMutableArray new];
	for (A3TableViewElement *element in elements) {
		element.section = self;
		[_elementsMatchingTableView addObject:element];
		if ([element isKindOfClass:[A3TableViewExpandableElement class]]) {
			A3TableViewExpandableElement *expandableElement = (A3TableViewExpandableElement *) element;
			if (!expandableElement.isCollapsed) {
				for (id subElement in expandableElement.elements) {
					[_elementsMatchingTableView addObject:subElement];
				}
			}
		}
	}
}

- (NSInteger)numberOfRows {
	return [_elementsMatchingTableView count];
}

- (void)toggleExpandableElementAtIndexPath:(NSIndexPath *)indexPath {
	NSAssert(indexPath.row < [_elementsMatchingTableView count], @"Row number is bigger than number of existing rows.");
	A3TableViewExpandableElement *expandableElement = _elementsMatchingTableView[indexPath.row];
	if ([expandableElement isKindOfClass:[A3TableViewExpandableElement class]]) {
		if (expandableElement.isCollapsed) {
			NSUInteger index = (NSUInteger) indexPath.row + 1;
			for (id subElement in expandableElement.elements) {
				[_elementsMatchingTableView insertObject:subElement atIndex:index];
				index++;
			}
			expandableElement.collapsed = NO;
		} else {
			[_elementsMatchingTableView removeObjectsInRange:NSMakeRange(indexPath.row + 1, [expandableElement.elements count])];
			expandableElement.collapsed = YES;
		}
	}
}

@end
