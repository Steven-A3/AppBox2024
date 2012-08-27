//
//  A3CalendarWeekContentsView.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/3/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3CalendarWeekContentsView : UIView

@property (nonatomic, strong) NSDate *startDate;

- (void)updateTimeMark;


@end
