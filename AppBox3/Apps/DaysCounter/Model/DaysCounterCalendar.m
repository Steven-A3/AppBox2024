//
//  DaysCounterCalendar.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 5..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "DaysCounterCalendar.h"
#import "DaysCounterEvent.h"


@implementation DaysCounterCalendar

@dynamic calendarId;
@dynamic calendarName;
@dynamic calendarColor;
@dynamic isShow;
@dynamic events;
@dynamic calendarType;
@dynamic order;
@dynamic isDefault;

- (UIColor*)color
{
    return (self.calendarColor ? [NSKeyedUnarchiver unarchiveObjectWithData:self.calendarColor] : nil);
}
@end
