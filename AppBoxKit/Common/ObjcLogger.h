//
//  ObjcLogger.h
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 12/22/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Log levels
typedef NS_ENUM(NSInteger, ObjcLoggerLevel) {
    ObjcLoggerLevelDebug,
    ObjcLoggerLevelInfo,
    ObjcLoggerLevelWarning,
    ObjcLoggerLevelError
};

/// Logger utility for Objective-C
@interface ObjcLogger : NSObject

/// Shared instance for global access
@property (class, nonatomic, readonly) ObjcLogger *shared;

/// Enable or disable logging
@property (nonatomic, assign) BOOL isLoggingEnabled;

/// Log a message with a specific level
- (void)logWithLevel:(ObjcLoggerLevel)level
             message:(NSString *)message
                file:(NSString *)file
            function:(NSString *)function
                line:(NSInteger)line;

/// Convert log level to string (for internal use)
- (NSString *)stringForLogLevel:(ObjcLoggerLevel)level;

@end

/// Logging macros
#define LogDebug(message) [[ObjcLogger shared] logWithLevel:ObjcLoggerLevelDebug message:(message) file:[NSString stringWithUTF8String:__FILE__] function:[NSString stringWithUTF8String:__FUNCTION__] line:__LINE__]
#define LogInfo(message) [[ObjcLogger shared] logWithLevel:ObjcLoggerLevelInfo message:(message) file:[NSString stringWithUTF8String:__FILE__] function:[NSString stringWithUTF8String:__FUNCTION__] line:__LINE__]
#define LogWarning(message) [[ObjcLogger shared] logWithLevel:ObjcLoggerLevelWarning message:(message) file:[NSString stringWithUTF8String:__FILE__] function:[NSString stringWithUTF8String:__FUNCTION__] line:__LINE__]
#define LogError(message) [[ObjcLogger shared] logWithLevel:ObjcLoggerLevelError message:(message) file:[NSString stringWithUTF8String:__FILE__] function:[NSString stringWithUTF8String:__FUNCTION__] line:__LINE__]

NS_ASSUME_NONNULL_END
