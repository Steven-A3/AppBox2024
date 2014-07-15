//
//  DaysCounterCalendar+Extension.m
//  AppBox3
//
//  Created by dotnetguy83 on 5/13/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "DaysCounterCalendar+Extension.h"

@implementation DaysCounterCalendar (Extension)

- (UIColor*)color
{
    return (self.calendarColor ? [NSKeyedUnarchiver unarchiveObjectWithData:self.calendarColor] : nil);
}

@end
