//
//  UITableViewController+standardDimension.h
//  AppBox3
//
//  Created by A3 on 1/18/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#include "A3UIDevice.h"

#define A3UITableViewCellLeftOffset_iPHONE		15
#define A3UITableViewCellLeftOffset_iPAD_28     28
#define A3UITableViewSeparatorColor				[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0]
#define A3UITableViewTextLabelFont				[UIFont systemFontOfSize:17]
#define A3UITableViewSeparatorInset				UIEdgeInsetsMake(0, IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28, 0, 0)

@interface UIViewController (tableViewStandardDimension)

- (CGFloat)standardHeightForHeaderInSection:(NSInteger)section;
- (CGFloat)standardHeightForFooterIsLastSection:(BOOL)isLastSection;
+ (CGFloat)noteCellHeight;

@end
