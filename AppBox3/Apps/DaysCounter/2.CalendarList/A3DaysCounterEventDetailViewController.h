//
//  A3DaysCounterEventDetailViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DaysCounterEvent;
@class A3DaysCounterModelManager;
@protocol A3DaysCounterEventDetailViewControllerDelegate;

@interface A3DaysCounterEventDetailViewController : UITableViewController
@property (strong, nonatomic) A3DaysCounterModelManager *sharedManager;
@property (strong, nonatomic) DaysCounterEvent *eventItem;
@property (weak, nonatomic) id<A3DaysCounterEventDetailViewControllerDelegate> delegate;
@property (assign, nonatomic) BOOL isNotificationPopup;

- (IBAction)deleteEventAction:(id)sender;
- (void)removeBackAndEditButton;

@end

@protocol A3DaysCounterEventDetailViewControllerDelegate <NSObject>
@optional
- (void)willDeleteEvent:(DaysCounterEvent*)event daysCounterEventDetailViewController:(A3DaysCounterEventDetailViewController*)ctrl;
- (void)willChangeEventDetailViewController:(A3DaysCounterEventDetailViewController*)ctrl;
- (void)didChangedCalendarEventDetailViewController:(A3DaysCounterEventDetailViewController*)ctrl;

@end
