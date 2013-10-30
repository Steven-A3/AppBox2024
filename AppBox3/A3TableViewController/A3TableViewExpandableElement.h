//
//  A3TableViewExpandableElement.h
//  AppBox3
//
//  Created by A3 on 10/29/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TableViewElement.h"

@interface A3TableViewExpandableElement : A3TableViewElement

@property (nonatomic, copy) NSString *title;
@property (assign, getter=isCollapsed) BOOL collapsed;
@property (nonatomic, strong) NSArray *elements;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) UILabel *titleLabel;

@end
