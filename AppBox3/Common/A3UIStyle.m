//
//  A3UIStyle.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/13/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3UIStyle.h"
#import "A3UIDevice.h"

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
	CGFloat fontSize = DEVICE_IPAD ? 25.0 : 17.0;
	return [UIFont boldSystemFontOfSize:fontSize];
}

+ (UIFont *)fontForTableViewEntryCellLabel {
	CGFloat fontSize = DEVICE_IPAD ? 25.0 : 17.0;
	return [UIFont systemFontOfSize:fontSize];
}

+ (UIFont *)fontForTableViewEntryCellTextField {
	CGFloat fontSize = DEVICE_IPAD ? 25.0 : 17.0;
	return [UIFont boldSystemFontOfSize:fontSize];
}

@end
