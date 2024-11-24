//
//  A3ActivitySafari.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 12/10/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3ActivitySafari.h"
#import <AppBoxKit/A3UIDevice.h>

@implementation A3ActivitySafari
{
    NSURL *_URL;
}

- (NSString *)activityType
{
    return NSStringFromClass([self class]);
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"Open in Safari", @"Open in Safari");
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed: IS_IPAD ? @"share_safari_iPad" : @"share_safari"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:[NSURL class]] && [[UIApplication sharedApplication] canOpenURL:activityItem]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:[NSURL class]]) {
            _URL = activityItem;
        }
    }
}

- (void)performActivity
{
    if ([[UIApplication sharedApplication] canOpenURL:_URL]) {
        [[UIApplication sharedApplication] openURL:_URL options:@{} completionHandler:^(BOOL success) {
            if (success) {
                NSLog(@"Opened URL successfully.");
            } else {
                NSLog(@"Failed to open URL.");
            }
            [self activityDidFinish:success];
        }];
    }
}

@end
