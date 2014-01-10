//
//  A3TableViewController.h
//  AppBox3
//
//  Created by A3 on 11/25/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//



@class A3TableViewRootElement;
@class A3TableViewElement;

@interface A3TableViewController : UITableViewController

@property (nonatomic, strong) A3TableViewRootElement *rootElement;

- (A3TableViewElement *)elementAtIndexPath:(NSIndexPath *)indexPath;

@end
