//
//  A3LadyCalendarAccountViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3LadyCalendarAccountViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    NSInteger numberOfCellInPage;
}

@property (strong, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)addAccountAction;
@end
