//
//  A3SalesCalcHistoryViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 1/29/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3SalesCalcQuickDialogViewController.h"

@class SalesCalcHistory;

@protocol A3SalesCalcQuickDialogDelegate <NSObject>
- (void)reloadContentsWithObject:(SalesCalcHistory *)object;
@end

@class A3SalesCalcQuickDialogViewController;

@interface A3SalesCalcHistoryViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>
@property (nonatomic, weak) id<A3SalesCalcQuickDialogDelegate> delegate;

@end
