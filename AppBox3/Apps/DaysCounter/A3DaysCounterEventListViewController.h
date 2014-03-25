//
//  A3DaysCounterEventListViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3DaysCounterEventDetailViewController.h"

@class DaysCounterCalendar;
@interface A3DaysCounterEventListViewController : UIViewController<UISearchDisplayDelegate,UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,A3DaysCounterEventDetailViewControllerDelegate>{
    NSInteger sortType;
    BOOL isAscending;
}

@property (strong, nonatomic) DaysCounterCalendar *calendarItem;
@property (strong, nonatomic) IBOutlet UIView *rightButtonsView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *sortTypeSegmentCtrl;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;
@property (strong, nonatomic) IBOutlet UIButton *editButton;
@property (strong, nonatomic) IBOutlet UIToolbar *bottomToolbar;
@property (strong, nonatomic) IBOutlet UIButton *addEventButton;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentControlWidthConst;
@property (strong, nonatomic) IBOutlet UIView *headerSeperatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewTopConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewSeparatorHeightConst;

- (IBAction)changeSortAction:(id)sender;
- (IBAction)searchAction:(id)sender;
- (IBAction)editAction:(id)sender;

- (IBAction)photoViewAction:(id)sender;
- (IBAction)reminderAction:(id)sender;
- (IBAction)favoriteAction:(id)sender;
- (IBAction)addEventAction:(id)sender;
@end
