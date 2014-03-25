//
//  UITableViewController+standardDimension.m
//  AppBox3
//
//  Created by A3 on 1/18/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "UITableViewController+standardDimension.h"
#import "A3UIDevice.h"

@implementation UITableViewController (standardDimension)

- (CGFloat)standardHeightForHeaderInSection:(NSInteger)section {
	if (section == 0) return 35.0;
	return 18;
}

- (CGFloat)standardHeightForFooterInSection:(NSInteger)section {
	NSInteger numberOfSection = [self.tableView numberOfSections];
	if (section == numberOfSection - 1) return 38.0;
	return 17.0;
}

@end
