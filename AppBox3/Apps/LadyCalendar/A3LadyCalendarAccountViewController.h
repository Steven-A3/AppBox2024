//
//  A3LadyCalendarAccountViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A3LadyCalendarModelManager;

@interface A3LadyCalendarAccountViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic, weak) A3LadyCalendarModelManager *dataManager;

@end
