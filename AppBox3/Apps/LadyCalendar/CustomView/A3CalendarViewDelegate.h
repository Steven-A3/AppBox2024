//
//  A3CalendarViewDelegate.h
//  A3TeamWork
//
//  Created by coanyaa on 2014. 2. 25..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

@class A3LadyCalendarCalendarView;

@protocol A3CalendarViewDelegate <NSObject>
@optional
- (void)calendarView:(A3LadyCalendarCalendarView *)calendarView didSelectDay:(NSInteger)day;
@end
