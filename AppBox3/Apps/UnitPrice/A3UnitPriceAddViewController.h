//
//  A3UnitPriceAddViewController.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 4..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3UnitPriceAddViewControllerDelegate <NSObject>
- (void)addViewController:(UIViewController *)viewController itemsAdded:(NSArray *)addedItems itemsRemoved:(NSArray *)removedItems;

@optional
- (void)willDismissAddViewController;

@end

@interface A3UnitPriceAddViewController : UITableViewController

@property (nonatomic, weak) id<A3UnitPriceAddViewControllerDelegate> delegate;
@property (nonatomic)		BOOL shouldPopViewController;
@property (nonatomic, strong) NSMutableArray *allData;
@property (nonatomic, strong) NSArray *filteredResults;

@end
