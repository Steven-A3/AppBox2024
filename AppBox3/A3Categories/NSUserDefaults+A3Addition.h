//
//  NSUserDefaults+A3Addition.h
//  AppBox3
//
//  Created by A3 on 12/6/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const A3SettingsUsePasscodeLock;
extern NSString *const A3SettingsNumberOfItemsRecentToKeep;
extern NSString *const A3SettingsUseKoreanCalendarForLunarConversion;

@interface NSUserDefaults (A3Addition)

- (NSString *)stringForSyncMethod;
- (NSString *)stringForRecentToKeep;

- (BOOL)useKoreanLunarCalendarForConversion;

- (void)setDateComponents:(NSDateComponents *)dateComponents forKey:(NSString *)key;

- (NSDateComponents *)dateComponentsForKey:(NSString *)key;
@end
