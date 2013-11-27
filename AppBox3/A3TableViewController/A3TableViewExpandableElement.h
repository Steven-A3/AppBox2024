//
//  A3TableViewExpandableElement.h
//  AppBox3
//
//  Created by A3 on 10/29/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TableViewElement.h"

typedef NS_ENUM(NSUInteger, A3TableViewExpandableElementCellType) {
	A3TableViewExpandableElementCellTypeDefault = 0,
	A3TableViewExpandableElementCellTypeSectionHeader
};

@class A3TableViewSection;
@class A3TableViewExpandableCell;

@interface A3TableViewExpandableElement : A3TableViewElement

@property (nonatomic, assign, getter=isCollapsed) BOOL collapsed;
@property (nonatomic, assign) A3TableViewExpandableElementCellType cellType;
@property (nonatomic, strong) NSArray *elements;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) A3TableViewExpandableCell *cell;
@property (nonatomic, weak) UILabel *titleLabel;

@end
