//
//  A3AppViewController
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/19/13 9:06 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3AppViewController.h"
#import "UIViewController+A3AppCategory.h"
#import "common.h"
#import "A3UIDevice.h"
#import "CommonUIDefinitions.h"


@implementation A3AppViewController {

}

- (void)viewWillDisappear:(BOOL)animated {
	FNLOG(@"check");
	[super viewWillDisappear:animated];

	[self closeActionMenuViewWithAnimation:NO];
}

- (UIFont *)fontForCellLabel {
	CGFloat fontSize = DEVICE_IPAD ? 25.0 : 17.0;
	return [UIFont boldSystemFontOfSize:fontSize];
}

- (UIFont *)fontForEntryCellLabel {
	CGFloat fontSize = DEVICE_IPAD ? 25.0 : 17.0;
	return [UIFont systemFontOfSize:fontSize];
}

- (UIFont *)fontForEntryCellTextField {
	CGFloat fontSize = DEVICE_IPAD ? 25.0 : 17.0;
	return [UIFont boldSystemFontOfSize:fontSize];
}

- (UIColor *)tableViewBackgroundColor {
	return [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:249.0/255.0 alpha:1.0];
}

- (UIColor *)cellBackgroundColor {
	return [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:249.0/255.0 alpha:1.0];
}

- (UIColor *)colorForCellLabelNormal {
	return [UIColor colorWithRed:115.0f/255.0f green:115.0f/255.0f blue:115.0f/255.0f alpha:1.0f];
}

- (UIColor *)colorForCellLabelSelected {
	return [UIColor colorWithRed:40.0f/255.0f green:72.0f/255.0f blue:114.0f/255.0f alpha:1.0f];
}

- (UIColor *)colorForCellButton {
	FNLOG();
	return [UIColor colorWithRed:40.0f / 255.0f green:72.0f / 255.0f blue:114.0f / 255.0f alpha:1.0f];
}

- (CGFloat)heightForElement:(QElement *)element {
	FNLOG();
	return DEVICE_IPAD ? A3_TABLE_VIEW_ROW_HEIGHT_IPAD : A3_TABLE_VIEW_ROW_HEIGHT_IPHONE;
}

- (UIColor *)colorForEntryCellTextField {
	return [UIColor colorWithRed:115.0f/255.0f green:115.0f/255.0f blue:115.0f/255.0f alpha:1.0f];
}

@end