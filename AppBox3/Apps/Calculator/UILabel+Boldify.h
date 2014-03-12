//
//  UILabel+Boldify.h
//  A3TeamWork
//
//  Created by Soon Gyu Kim on 12/25/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Boldify)
- (void) boldSubstring: (NSString*) substring;
- (void) boldRange: (NSRange) range;
@end
