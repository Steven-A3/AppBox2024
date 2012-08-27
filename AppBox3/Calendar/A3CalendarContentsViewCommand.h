//
//  A3CalendarContentsViewCommand.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/7/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol A3CalendarContentsViewCommand <NSObject>
@required
- (void)jumpToDate:(NSDate *)date;

@end
