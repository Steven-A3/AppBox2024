//
//  NSDateFormatter(A3Addition)
//  AppBox3
//
//  Created by A3 on 2/8/14 3:40 PM.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (A3Addition)

- (NSString *)localizedLongStyleYearMonthFromDate:(NSDate *)date;
- (NSString *)localizedMediumStyleYearMonthFromDate:(NSDate *)date;
- (NSString *)formatStringByRemovingYearComponent:(NSString *)originalFormat;
- (NSString *)formatStringByRemovingDayComponent:(NSString *)originalFormat;

- (NSString *)customFullStyleFormat;
@end
