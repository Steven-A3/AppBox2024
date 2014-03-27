//
//  A3TableViewElement.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/22/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//


@protocol A3SelectTableViewControllerProtocol;
@class A3TableViewExpandableElement;
@class A3TableViewSection;

@interface A3TableViewElement : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) id value;
@property (nonatomic) NSInteger identifier;
@property (nonatomic, copy) void (^onSelected)(A3TableViewElement *);
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) NSNumber *cellHeight;
@property (nonatomic, weak) A3TableViewExpandableElement *expandableElement;

@property (nonatomic, weak) A3TableViewSection *section;

- (UITableViewCell *)cellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;
- (void)didSelectCellInViewController:(UIViewController<A3SelectTableViewControllerProtocol> *)viewController tableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;

@end
