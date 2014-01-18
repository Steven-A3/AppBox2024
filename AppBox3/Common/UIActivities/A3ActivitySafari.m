//
//  A3ActivitySafari.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 12/10/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3ActivitySafari.h"

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
    return [UIImage imageNamed:@"general"];
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
    BOOL completed = [[UIApplication sharedApplication] openURL:_URL];
    
    [self activityDidFinish:completed];
}

@end