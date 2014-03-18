//
//  A3LadyCalendarChartViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3LadyCalendarChartViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    NSInteger minCycleLength;
    NSInteger maxCycleLength;
    NSInteger minMensPeriod;
    NSInteger maxMensPeriod;
    NSInteger xLabelDisplayInterval;
}

@property (strong, nonatomic) IBOutlet UISegmentedControl *periodSegmentCtrl;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentLeftConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentRightConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *seperatorHeightConst;

- (IBAction)periodChangedAction:(id)sender;
@end
