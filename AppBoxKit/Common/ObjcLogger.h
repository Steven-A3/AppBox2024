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
                file:(const char *)file
            function:(const char *)function
                line:(NSInteger)line;

/// Convert log level to string (for internal use)
- (NSString *)stringForLogLevel:(ObjcLoggerLevel)level;

@end

/// Logging macros
#define Log(level, message) \
    [[ObjcLogger shared] logWithLevel:(level) \
                              message:(message) \
                                 file:__FILE__ \
                             function:__FUNCTION__ \
                                 line:__LINE__]

#define LogDebug(message) Log(ObjcLoggerLevelDebug, (message))
#define LogInfo(message) Log(ObjcLoggerLevelInfo, (message))
#define LogWarning(message) Log(ObjcLoggerLevelWarning, (message))
#define LogError(message) Log(ObjcLoggerLevelError, (message))

NS_ASSUME_NONNULL_END
