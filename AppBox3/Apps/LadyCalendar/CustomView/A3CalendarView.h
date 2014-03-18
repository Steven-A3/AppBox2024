//
//  A3CalendarView.h
//  A3TeamWork
//
//  Created by coanyaa on 2014. 2. 25..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3CalendarViewDelegate.h"

@interface LineDisplayModel : NSObject

@property (assign, nonatomic) CGRect lineRect;
@property (strong, nonatomic) UIColor *lineColor;
@end

@interface CircleDisplayModel : NSObject

@property (assign, nonatomic) CGRect circleRect;
@property (strong, nonatomic) UIColor *circleColor;
@property (assign, nonatomic) BOOL isAlphaCircleShow;

@end

@class LadyCalendarAccount;
@interface A3CalendarView : UIView{
    NSInteger numberOfWeeks;
    NSInteger firstDayStartIndex;
    NSInteger lastDayIndex;
    NSInteger lastWeekday;
    NSInteger lastDay;
    
    NSInteger dateBGHeight;
    NSArray *periods;
    __strong NSMutableArray *redLines;
    __strong NSMutableArray *greenLines;
    __strong NSMutableArray *yellowLines;
    __strong NSMutableArray *circleArray;
    __block dispatch_queue_t dQueue;
    BOOL isCurrentMonth;
    NSInteger today;
}

@property (assign, nonatomic) id<A3CalendarViewDelegate> delegate;
@property (strong, nonatomic) NSDate *dateMonth;
@property (assign, nonatomic) BOOL showVerticalSeperator;
@property (assign, nonatomic) BOOL showHorizontalSeperator;
@property (assign, nonatomic) BOOL showOutline;
@property (assign, nonatomic) CGSize seperatorSize;
@property (strong, nonatomic) UIColor *outlineColor;
@property (assign, nonatomic) UIFont *dateFont;
@property (strong, nonatomic) UIColor *dateTextColor;
@property (strong, nonatomic) UIColor *weekendTextColor;
@property (readonly, nonatomic) NSInteger year;
@property (readonly, nonatomic) NSInteger month;
@property (assign, nonatomic) CGSize cellSize;
@property (assign, nonatomic) BOOL isSmallCell;
@property (strong, nonatomic) LadyCalendarAccount *account;

- (void)reload;
@end
