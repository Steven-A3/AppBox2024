//
//  A3DaysCounterAddEventViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol A3DaysCounterAddEventViewControllerDelegate <NSObject>
- (void)viewControllerWillDismissByDeletingEvent;
@end

@class DaysCounterEvent_;
@class A3DaysCounterModelManager;

@interface A3DaysCounterAddEventViewController : UITableViewController 
{
    BOOL isFirstAppear;
}
@property (weak, nonatomic) A3DaysCounterModelManager *sharedManager;
@property (strong, nonatomic) DaysCounterEvent_ *eventItem;
@property (assign, nonatomic) BOOL landscapeFullScreen;
@property (strong, nonatomic) NSString *calendarID;
@property (weak, nonatomic) id<A3DaysCounterAddEventViewControllerDelegate> delegate;

- (void)showKeyboard;

@end
