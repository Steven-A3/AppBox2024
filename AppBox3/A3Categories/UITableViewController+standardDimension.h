//
//  UITableViewController+standardDimension.h
//  AppBox3
//
//  Created by A3 on 1/18/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewController (standardDimension)

- (CGFloat)standardHeightForHeaderInSection:(NSInteger)section;

- (CGFloat)standardHeightForFooterInSection:(NSInteger)section;
@end
