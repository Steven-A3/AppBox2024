//
//  A3LadyCalendarViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3CalendarViewDelegate.h"

@class LadyCalendarAccount;

@interface A3LadyCalendarViewController : UIViewController

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIToolbar *bottomToolbar;
@property (strong, nonatomic) IBOutlet UIView *rightButtons;
@property (strong, nonatomic) IBOutlet UIView *calendarHeaderView;	// Attached to navigation bar
@property (strong, nonatomic) IBOutlet UILabel *currentMonthLabel;
@property (strong, nonatomic) IBOutlet UIButton *addButton;
@property (strong, nonatomic) IBOutlet UIImageView *topSeparatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSeparatorViewConst;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *helpBarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *chartBarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *accountBarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingBarButton;


- (IBAction)moveToTodayAction:(id)sender;
- (IBAction)changeListTypeAction:(id)sender;
- (IBAction)moveToListAction:(id)sender;
- (IBAction)moveToChartAction:(id)sender;
- (IBAction)moveToAccountAction:(id)sender;
- (IBAction)settingAction:(id)sender;
- (IBAction)addPeriodAction:(id)sender;

@end
