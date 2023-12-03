//
//  A3KeychainUtils.h
//  AppBox3
//
//  Created by A3 on 12/30/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const A3RemoveSecurityCoverViewNotification;

@interface A3KeychainUtils : NSObject

+ (BOOL)storePassword:(NSString *)password hint:(NSString *)hint;
+ (NSString *)getPassword;
+ (NSString *)getHint;
+ (void)removePassword;

+ (double)passcodeTime;

+ (NSString *)passcodeTimeString;

+ (void)migrateV1Passcode;
+ (void)saveTimerStartTime;

@end
