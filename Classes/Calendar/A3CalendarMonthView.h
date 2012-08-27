//
//  A3CalendarMonthView.h
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 7/31/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3CalendarMonthView : UIView

@property (assign, nonatomic) NSInteger year;			// Default 2012
@property (assign, nonatomic) NSInteger month;			// Default July
@property (assign, nonatomic) BOOL weekStartSunday;		// Default YES

@end
