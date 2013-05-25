//
//  A3HistoryViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/25/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3HistoryViewControllerDelegate <NSObject>
- (void)historySelected:(id)object;
@end

@interface A3HistoryViewController : UIViewController
<NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) id<A3HistoryViewControllerDelegate> delegate;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UITableView *myTableView;

@end
