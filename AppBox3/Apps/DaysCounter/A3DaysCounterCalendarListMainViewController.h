//
//  A3DaysCounterCalendarListViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3DaysCounterCalendarListMainViewController : UIViewController<UISearchBarDelegate,UISearchDisplayDelegate,UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIToolbar *bottomToolbar;
@property (strong, nonatomic) IBOutlet UIView *rightTopButtonView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UILabel *numberOfCalendarLabel;
@property (strong, nonatomic) IBOutlet UILabel *numberOfEventsLabel;
@property (strong, nonatomic) IBOutlet UILabel *updateDateLabel;
@property (strong, nonatomic) IBOutlet UIButton *editButton;
@property (strong, nonatomic) IBOutlet UIView *iPadheaderView;
@property (strong, nonatomic) IBOutlet UILabel *numberOfCalendarLabeliPad;
@property (strong, nonatomic) IBOutlet UILabel *numberOfEventsLabeliPad;
@property (strong, nonatomic) IBOutlet UILabel *updateDateLabeliPad;
@property (strong, nonatomic) IBOutlet UIButton *addEventButton;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;
@property (strong, nonatomic) IBOutlet UILabel *headerEventLabel;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *verticalSeperators;

- (IBAction)photoViewAction:(id)sender;
- (IBAction)addEventAction:(id)sender;
- (IBAction)reminderAction:(id)sender;
- (IBAction)favoriteAction:(id)sender;
- (IBAction)searchAction:(id)sender;
- (IBAction)editAction:(id)sender;
- (IBAction)addCalendarAction:(id)sender;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerSeparator1_TopConst_iPhone;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerSeparator2_TopConst_iPhone;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerSeparator1_TopConst_iPad;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerSeparator2_TopConst_iPad;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerView_view1_widthConst_iPad;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerView_view2_widthConst_iPad;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerView_view3_widthConst_iPad;
@end
