//
//  A3UIStyle.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/13/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3UIStyle.h"

@implementation A3UIStyle

+ (UIColor *)contentsBackgroundColor {
	return [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:249.0/255.0 alpha:1.0];
}

+ (UIColor *)colorForTableViewCellLabelNormal {
	return [UIColor colorWithRed:115.0f/255.0f green:115.0f/255.0f blue:115.0f/255.0f alpha:1.0f];
}

+ (UIColor *)colorForTableViewCellLabelSelected {
	return [UIColor colorWithRed:40.0f/255.0f green:72.0f/255.0f blue:114.0f/255.0f alpha:1.0f];
}

+ (UIFont *)fontForTableViewCellLabel {
	return [UIFont boldSystemFontOfSize:25.0];
}

+ (UIFont *)fontForTableViewEntryCellLabel {
	return [UIFont systemFontOfSize:25.0];
}

+ (UIFont *)fontForTableViewEntryCellTextField {
	return [UIFont boldSystemFontOfSize:25.0];
}

@end
