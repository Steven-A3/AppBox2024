//
//  A3DaysCounterAddEventViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class DaysCounterEvent;
@class A3DaysCounterModelManager;

@interface A3DaysCounterAddEventViewController : UITableViewController 
{
    BOOL isFirstAppear;
}
@property (weak, nonatomic) A3DaysCounterModelManager *sharedManager;
@property (strong, nonatomic) DaysCounterEvent *eventItem;
@property (assign, nonatomic) BOOL landscapeFullScreen;
@property (strong, nonatomic) NSString *calendarId;

- (void)showKeyboard;

@end
