//
//  A3LadyCalendarViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3CalendarViewDelegate.h"

@class LadyCalendarAccount;

@interface A3LadyCalendarViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,A3CalendarViewDelegate>{
    BOOL isShowMoreMenu;
    NSInteger numberOfMonthInPage;
    LadyCalendarAccount *currentAccount;
    BOOL isFirst;
}

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIToolbar *bottomToolbar;
@property (strong, nonatomic) IBOutlet UIView *rightButtons;
@property (strong, nonatomic) IBOutlet UIView *topNaviView;
@property (strong, nonatomic) IBOutlet UILabel *currentMonthLabel;
@property (strong, nonatomic) IBOutlet UIButton *addButton;
@property (strong, nonatomic) IBOutlet UIImageView *topSeperatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSeperatorViewConst;
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
