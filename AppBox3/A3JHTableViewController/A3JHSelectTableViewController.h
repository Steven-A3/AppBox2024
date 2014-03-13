//
//  A3JHSelectTableViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/23/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A3JHSelectTableViewController;

@protocol A3JHSelectTableViewControllerProtocol <NSObject>
- (void)selectTableViewController:(A3JHSelectTableViewController *)viewController selectedItemIndex:(NSInteger)index indexPathOrigin:(NSIndexPath *)indexPathOrigin;
@end

@class A3JHTableViewSelectElement;

@interface A3JHSelectTableViewController : UITableViewController

@property (nonatomic, strong) A3JHTableViewSelectElement *root;
@property (nonatomic, weak) id<A3JHSelectTableViewControllerProtocol> delegate;
@property (nonatomic, strong) NSIndexPath *indexPathOfOrigin;

@end
