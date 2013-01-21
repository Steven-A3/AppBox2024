//
//  A3Categories.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 1/19/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3Categories.h"

@implementation NSString (FetchedGroupByString)

- (NSString *)stringGroupByFirstInitial {
    NSString *temp = [self uppercaseString];
    
    if (!temp.length || temp.length == 1)
        return temp;
    return [temp substringToIndex:1];
}

@end
