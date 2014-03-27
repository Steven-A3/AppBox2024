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
@protocol A3TableViewExpandableElementDelegate;

@interface A3TableViewExpandableElement : A3TableViewElement

@property (nonatomic, assign, getter=isCollapsed) BOOL collapsed;
@property (nonatomic, assign) A3TableViewExpandableElementCellType cellType;
@property (nonatomic, strong) NSArray *elements;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) A3TableViewExpandableCell *cell;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) id<A3TableViewExpandableElementDelegate> delegate;

- (void)expandButtonPressed:(UIButton *)expandButton;
@end

@protocol A3TableViewExpandableElementDelegate <NSObject>
- (void)element:(A3TableViewExpandableElement *)element cellStateChangedAtIndexPath:(NSIndexPath *)indexPath;
@end
