//
//  A3JHTableViewExpandableElement.h
//  AppBox3
//
//  Created by A3 on 10/29/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3JHTableViewElement.h"

@class A3JHTableViewExpandableElement;
typedef void (^CellExpandedBlock)(A3JHTableViewExpandableElement *);

@interface A3JHTableViewExpandableElement : A3JHTableViewElement

@property (nonatomic, copy) NSString *title;
@property (assign, getter=isCollapsed) BOOL collapsed;
@property (nonatomic, strong) NSArray *elements;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) UILabel *titleLabel;
//kjh
@property (nonatomic, copy) CellExpandedBlock onExpandCompletion;

- (void)didSelectCellInViewController:(UIViewController *)viewController tableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;

@end
