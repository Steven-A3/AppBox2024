//
//  NSDateFormatter+LunarDate.h
//  AppBox3
//
//  Created by A3 on 2/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (LunarDate)

- (NSString *)stringFromDateComponents:(NSDateComponents *)dateComponents;
@end
