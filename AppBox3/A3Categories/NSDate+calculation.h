//
//  NSDate(calculation)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/8/14 11:56 AM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (calculation)

- (NSDate *)firstDateOfMonth;

- (NSDate *)dateByAddingCalendarMonth:(NSInteger)monthDifference;
@end
