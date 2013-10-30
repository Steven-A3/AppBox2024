//
//  A3SelectTableViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/23/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A3SelectTableViewController;

@protocol A3SelectTableViewControllerProtocol <NSObject>
- (void)selectTableViewController:(A3SelectTableViewController *)viewController selectedItemIndex:(NSInteger)index indexPathOrigin:(NSIndexPath *)indexPathOrigin;
@end

@class A3TableViewSelectElement;

@interface A3SelectTableViewController : UITableViewController

@property (nonatomic, strong) A3TableViewSelectElement *root;
@property (nonatomic, weak) id<A3SelectTableViewControllerProtocol> delegate;
@property (nonatomic, strong) NSIndexPath *indexPathOfOrigin;

@end
