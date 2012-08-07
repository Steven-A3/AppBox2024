//
//  A3CalendarWeekView.h
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 8/3/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3CalendarWeekContentsView.h"

#define A3_CALENDAR_WEEKVIEW_HEADER_HEIGHT			20.0f
#define A3_CALENDAR_WEEKVIEW_ROW_HEIGHT				44.0f
#define A3_CALENDAR_WEEKVIEW_ALLDAY_EVENT_HEIGHT	30.0f
#define A3_CALENDAR_WEEKVIEW_HEIGHT					(A3_CALENDAR_WEEKVIEW_HEADER_HEIGHT + \
													A3_CALENDAR_WEEKVIEW_ALLDAY_EVENT_HEIGHT +	\
													A3_CALENDAR_WEEKVIEW_ROW_HEIGHT * 24)

@interface A3CalendarWeekView : UIScrollView

@property (nonatomic, strong)	A3CalendarWeekContentsView *contentsView;

@end
