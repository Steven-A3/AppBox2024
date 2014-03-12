//
//  NSAttributedString+Append.h
//  A3TeamWork
//
//  Created by Soon Gyu Kim on 1/1/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (Append)
- (NSAttributedString *) appendWith:(NSAttributedString *)string;

- (NSAttributedString *) appendWithString:(NSString *) string;

@end
