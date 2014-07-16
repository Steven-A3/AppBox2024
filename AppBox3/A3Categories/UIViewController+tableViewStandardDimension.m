//
//  UITableViewController+standardDimension.m
//  AppBox3
//
//  Created by A3 on 1/18/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "UIViewController+tableViewStandardDimension.h"
#import "A3UIDevice.h"

@implementation UIViewController (tableViewStandardDimension)

- (CGFloat)standardHeightForHeaderInSection:(NSInteger)section {
	if (section == 0) return 35.0;
	return 18;
}

- (CGFloat)standardHeightForFooterIsLastSection:(BOOL)isLastSection {
	if (isLastSection) return 38.0;
	return 17.0;
}

+ (CGFloat)noteCellHeight {
	return IS_IPHONE35 ? 120.0 : 150.0;
}

@end
