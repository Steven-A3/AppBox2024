//
//  A3UserDefaults+A3Addition.h
//  AppBox3
//
//  Created by A3 on 12/6/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <AppBoxKit/A3UserDefaults.h>

@interface A3UserDefaults (A3Addition)

- (NSString *)stringForRecentToKeep;
- (NSArray *)themeColors;
- (UIColor *)themeColor;

@end
