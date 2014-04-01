//
//  UITableView+utility.m
//  AppBox3
//
//  Created by A3 on 3/31/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "UITableView+utility.h"

@implementation UITableView (utility)

- (NSIndexPath *)indexPathForCellSubview:(UIView *)view {
	UIView *parentView = view.superview;
	while (parentView != nil && ![parentView isKindOfClass:[UITableViewCell class]]) {
		parentView = parentView.superview;
	}
	if ([parentView isKindOfClass:[UITableViewCell class]]) {
		return [self indexPathForCell:(UITableViewCell *) parentView];
	}
	return nil;
}

@end
