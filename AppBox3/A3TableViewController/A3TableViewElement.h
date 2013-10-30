//
//  A3TableViewElement.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/22/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//


@protocol A3SelectTableViewControllerProtocol;

@interface A3TableViewElement : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) id value;
@property (nonatomic) NSInteger identifier;

- (UITableViewCell *)cellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;

- (void)didSelectCellInViewController:(UIViewController<A3SelectTableViewControllerProtocol> *)viewController tableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;
@end
