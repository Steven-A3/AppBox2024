//
//  A3SyncManager(NSUbiquitousKeyValueStore)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/3/14 6:14 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppBoxKit/A3SyncManager.h>
#import <AppBoxKit/A3UserDefaultsKeys.h>

extern NSString *const A3SyncManagerEmptyObject;

@interface A3SyncManager (NSUbiquitousKeyValueStore)

- (void)keyValueStoreDidChangeExternally:(NSNotification *)notification;
- (NSInteger)integerForKey:(NSString *)key;
- (void)setInteger:(NSInteger)value forKey:(NSString *)key state:(A3DataObjectStateValue)state;
- (void)setBool:(BOOL)value forKey:(NSString *)key state:(A3DataObjectStateValue)state;
- (BOOL)boolForKey:(NSString *)key;
- (id)objectForKey:(NSString *)key;

- (void)setObject:(id)object forKey:(NSString *)key state:(A3DataObjectStateValue)state;
- (void)setDateComponents:(NSDateComponents *)dateComponents forKey:(NSString *)key state:(A3DataObjectStateValue)state;
- (NSDateComponents *)dateComponentsForKey:(NSString *)key;

@end
