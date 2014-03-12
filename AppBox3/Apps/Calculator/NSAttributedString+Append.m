//
//  NSAttributedString+Append.m
//  A3TeamWork
//
//  Created by Soon Gyu Kim on 1/1/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "NSAttributedString+Append.h"

@implementation NSAttributedString (Append)

- (NSAttributedString *) appendWith:(NSAttributedString *)string  {
    NSMutableAttributedString   *temp = [self mutableCopy];
    [temp appendAttributedString:string];
    return temp;
}
- (NSAttributedString *)  appendWithString:(NSString *) string {
    return [self appendWith:[[NSAttributedString alloc] initWithString:string]];
}

@end
