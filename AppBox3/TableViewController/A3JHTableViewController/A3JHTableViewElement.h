//
//  A3JHTableViewElement.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/22/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

@class A3JHTableViewElement;
@protocol A3JHSelectTableViewControllerProtocol;
typedef void (^CellValueChangedBlock)(A3JHTableViewElement *);

@interface A3JHTableViewElement : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) id coreDataObject;
@property (nonatomic, copy) NSString *coreDataKey;
@property (nonatomic, copy) NSString* value;
@property (nonatomic) NSInteger identifier;
@property (nonatomic, copy) void (^onSelected)(A3JHTableViewElement *);

- (UITableViewCell *)cellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;
- (void)didSelectCellInViewController:(UIViewController<A3JHSelectTableViewControllerProtocol> *)viewController tableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;

@end
