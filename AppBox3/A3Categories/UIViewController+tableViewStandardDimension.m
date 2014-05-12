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

- (CGFloat)noteCellHeight {
	CGFloat keyboardHeight;
	CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];

	if (IS_IPHONE) {
		keyboardHeight = 216.0;
	} else {
		if (IS_PORTRAIT) {
			keyboardHeight = 264;
		} else {
			keyboardHeight = 352;
		}
	}
	return screenBounds.size.height - keyboardHeight - 64 - 30; // StatusBar + NavigationBar = 64, Bottom margin = 30
}

@end
