//
//  A3UnitPriceHistoryViewController.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 6..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UnitPriceHistory;

@protocol UnitPriceHistoryViewControllerDelegate <NSObject>

@required
- (void)historyViewController:(UIViewController *)viewController selectHistory:(UnitPriceHistory *)history;
- (void)didHistoryDeletedHistoryViewController:(UIViewController *)viewController;

@end

@interface A3UnitPriceHistoryViewController : UITableViewController

@property (nonatomic, weak) id<UnitPriceHistoryViewControllerDelegate> delegate;

@end
