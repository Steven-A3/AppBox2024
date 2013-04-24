//
//  A3UIStyle.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/13/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface A3UIStyle : NSObject

+ (UIColor *)contentsBackgroundColor;
+ (UIColor *)colorForTableViewCellLabelNormal;
+ (UIColor *)colorForTableViewCellLabelSelected;

+ (UIColor *)colorForTableViewCellButton;

+ (UIFont *)fontForTableViewCellLabel;
+ (UIFont *)fontForTableViewEntryCellLabel;
+ (UIFont *)fontForTableViewEntryCellTextField;

@end
