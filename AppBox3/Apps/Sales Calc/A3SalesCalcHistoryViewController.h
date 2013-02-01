//
//  A3SalesCalcHistoryViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 1/29/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A3SalesCalcQuickDialogViewController;

@interface A3SalesCalcHistoryViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>
@property (nonatomic, weak) A3SalesCalcQuickDialogViewController *salesCalcQuickDialogViewController;

@end
