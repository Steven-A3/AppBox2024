//
//  A3CalendarViewDelegate.h
//  A3TeamWork
//
//  Created by coanyaa on 2014. 2. 25..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#ifndef A3TeamWork_A3CalendarViewDelegate_h
#define A3TeamWork_A3CalendarViewDelegate_h

@class A3CalendarView;
@protocol A3CalendarViewDelegate <NSObject>
@optional
- (void)calendarView:(A3CalendarView*)calendarView didSelectDay:(NSInteger)day;
@end

#endif
