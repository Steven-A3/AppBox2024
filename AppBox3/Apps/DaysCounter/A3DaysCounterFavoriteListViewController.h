//
//  A3DaysCounterFavoriteListViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
@class A3DaysCounterModelManager;
@interface A3DaysCounterFavoriteListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) A3DaysCounterModelManager *sharedManager;
@property (strong, nonatomic) IBOutlet UIToolbar *bottomToolbar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *addEventButton;

- (IBAction)photoViewAction:(id)sender;
- (IBAction)calendarViewAction:(id)sender;
- (IBAction)addEventAction:(id)sender;
- (IBAction)reminderAction:(id)sender;

@end
