//
//  UITableViewController+standardDimension.h
//  AppBox3
//
//  Created by A3 on 1/18/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

#define A3UITableViewCellLeftOffset_iPHONE		15
#define A3UITableViewCellLeftOffset_iPAD_28     28
#define A3UITableViewSeparatorColor				[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0]
#define A3UITableViewTextLabelFont				[UIFont systemFontOfSize:17]
#define A3UITableViewSeparatorInset				UIEdgeInsetsMake(0, IS_IPHONE ? 15 : 28, 0, 0)

@interface UITableViewController (standardDimension)

- (CGFloat)standardHeightForHeaderInSection:(NSInteger)section;

- (CGFloat)standardHeightForFooterInSection:(NSInteger)section;
@end
