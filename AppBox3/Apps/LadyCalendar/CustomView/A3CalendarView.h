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
@class A3LadyCalendarModelManager;

@interface A3CalendarView : UIView

@property (assign, nonatomic) id<A3CalendarViewDelegate> delegate;
@property (strong, nonatomic) NSDate *dateMonth;
@property (assign, nonatomic) CGSize cellSize;
@property (assign, nonatomic) BOOL isSmallCell;
@property (weak, nonatomic) A3LadyCalendarModelManager *dataManager;

- (void)reload;

@end
