//
//  A3UserDefaults.h
//  AppBox3
//
//  Created by A3 on 8/15/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

extern NSString *const A3UserDefaultsDidChangeNotification;
extern NSString *const A3UserDefaultsChangedKey;

@interface A3UserDefaults : NSObject

+ (instancetype)standardUserDefaults;

- (void)synchronize;

- (id)objectForKey:(id)key;
- (void)setObject:(id)object forKey:(id)key;
- (BOOL)boolForKey:(id)key;
- (void)setBool:(BOOL)boolValue forKey:(id)key;
- (NSInteger)integerForKey:(id)key;

- (void)setInteger:(NSInteger)integerValue forKey:(id)key;

- (double)doubleForKey:(id)key;

- (void)setDouble:(double)doubleValue forKey:(id)key;

- (void)setDateComponents:(NSDateComponents *)dateComponents forKey:(NSString *)key;
- (NSDateComponents *)dateComponentsForKey:(NSString *)key;
- (void)removeObjectForKey:(id)key;

@end
