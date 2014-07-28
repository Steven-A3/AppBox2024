//
//  A3UnitPriceAddViewController.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 4..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A3UnitDataManager;

@protocol A3UnitPriceAddViewControllerDelegate <NSObject>
- (void)addViewControllerDidUpdateData;

@end

@interface A3UnitPriceAddViewController : UITableViewController

@property (nonatomic, weak) id<A3UnitPriceAddViewControllerDelegate> delegate;
@property (nonatomic, assign) NSUInteger categoryID;
@property (nonatomic, weak) A3UnitDataManager *dataManager;
@property (nonatomic, assign) BOOL shouldPopViewController;

@end
