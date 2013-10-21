//
//  A3CalendarMonthView.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/31/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3CalendarMonthView : UIView

@property (assign, nonatomic) NSInteger year;			// Default this year
@property (assign, nonatomic) NSInteger month;			// Default this month
@property (assign, nonatomic) BOOL weekStartSunday;		// Default YES
@property (assign, nonatomic) BOOL bigCalendar;			// Default YES
@property (assign, nonatomic) BOOL drawWeekdayLabel;	// Default YES
@property (assign, nonatomic) BOOL doNotDrawTextOtherMonth;// Default NO
@property (strong, nonatomic) NSDate *currentDate;

- (void)gotoYearByOffset:(NSInteger)offset;
- (void)gotoPreviousYear;
- (void)gotoNextYear;
- (void)gotoMonthByOffset:(NSInteger)offset;
- (void)gotoPreviousMonth;
- (void)gotoNextMonth;

@end
