//
//  ObjcLogger.m
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 12/22/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//

#import "ObjcLogger.h"

@interface ObjcLogger ()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation ObjcLogger

/// Shared instance
+ (ObjcLogger *)shared {
    static ObjcLogger *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ObjcLogger alloc] init];
    });
    return sharedInstance;
}

/// Initialize logger
- (instancetype)init {
    self = [super init];
    if (self) {
        _isLoggingEnabled = YES;
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    }
    return self;
}

/// Log a message with a specific level
- (void)logWithLevel:(ObjcLoggerLevel)level
             message:(NSString *)message
                file:(NSString *)file
            function:(NSString *)function
                line:(NSInteger)line {
    if (!self.isLoggingEnabled) return;

    NSString *timestamp = [self.dateFormatter stringFromDate:[NSDate date]];
    NSString *fileName = [file lastPathComponent];
    NSString *levelString = [self stringForLogLevel:level];
    NSString *logMessage = [NSString stringWithFormat:@"[%@] [%@] [%@:%ld] %@ - %@",
                            timestamp, levelString, fileName, (long)line, function, message];
    NSLog(@"%@", logMessage);
}

/// Convert log level to string
- (NSString *)stringForLogLevel:(ObjcLoggerLevel)level {
    switch (level) {
        case ObjcLoggerLevelDebug: return @"DEBUG";
        case ObjcLoggerLevelInfo: return @"INFO";
        case ObjcLoggerLevelWarning: return @"WARNING";
        case ObjcLoggerLevelError: return @"ERROR";
    }
    return @"UNKNOWN";
}

@end
