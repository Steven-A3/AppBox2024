//
//  UITableView+utility.h
//  AppBox3
//
//  Created by A3 on 3/31/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (utility)

- (NSIndexPath *)indexPathForCellSubview:(UIView *)view;
- (UITableViewCell *)cellForCellSubview:(UIView *)view;

@end
