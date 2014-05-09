//
//  A3DaysCounterAddEventViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "A3PhotoSelectViewController.h"

@class DaysCounterEvent;
@interface A3DaysCounterAddEventViewController : UITableViewController 
{
    BOOL isFirstAppear;
}

@property (strong, nonatomic) DaysCounterEvent *eventItem;
@property (assign, nonatomic) BOOL landscapeFullScreen;
@property (strong, nonatomic) NSString *calendarId;

- (void)showKeyboard;

@end
