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
@class A3WalletSegmentedControl;
@interface A3DaysCounterEventListViewController : UIViewController
{
    NSInteger _sortType;
    BOOL _isDateAscending;
    BOOL _isNameAscending;
}

@property (strong, nonatomic) DaysCounterCalendar *calendarItem;
@property (weak, nonatomic) IBOutlet A3WalletSegmentedControl *sortTypeSegmentCtrl;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolbar;
@property (weak, nonatomic) IBOutlet UIButton *addEventButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headerSeperatorView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentControlWidthConst;
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
