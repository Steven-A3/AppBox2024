//
//  A3LadyCalendarChartViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A3LadyCalendarModelManager;

@interface A3LadyCalendarChartViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UISegmentedControl *periodSegmentCtrl;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentLeftConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentRightConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorHeightConst;
@property(nonatomic, weak) A3LadyCalendarModelManager *dataManager;

- (IBAction)periodChangedAction:(id)sender;

@end
