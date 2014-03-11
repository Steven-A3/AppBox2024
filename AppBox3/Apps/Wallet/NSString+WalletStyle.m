//
//  NSString+WalletStyle.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 27..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "NSString+WalletStyle.h"
#import "WalletData.h"

@implementation NSString (WalletStyle)

- (NSString *)stringForStyle:(NSString *)style
{
    if (self.length == 0) {
        return @"";
    }
    
    if ([style isEqualToString:WalletFieldStyleNormal]) {
        return self;
    }
    else if ([style isEqualToString:WalletFieldStylePassword]) {
        return [NSString stringWithFormat:@"%@****", [self substringToIndex:1]];
    }
    else if ([style isEqualToString:WalletFieldStyleAccount]) {
        
        if ([self length] < 2) {
            return [NSString stringWithFormat:@"****%@", self];
        } else {
            return [NSString stringWithFormat:@"****%@", [self substringFromIndex:[self length] - 2]];
        }
    }
    else if ([style isEqualToString:WalletFieldStyleHidden]) {
        return @"********";
    }
    else {
        return self;
    }
}

@end
