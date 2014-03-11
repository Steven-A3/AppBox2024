//
//  A3UnitConverterAddViewController.h
//  A3TeamWork
//
//  Created by kihyunkim on 13. 10. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3UnitConverterAddViewControllerDelegate <NSObject>
- (void)addViewController:(UIViewController *)viewController itemsAdded:(NSArray *)addedItems itemsRemoved:(NSArray *)removedItems;

@optional
- (void)willDismissAddViewController;

@end

@interface A3UnitConverterAddViewController : UITableViewController

@property (nonatomic, weak) id<A3UnitConverterAddViewControllerDelegate> delegate;
@property (nonatomic) BOOL shouldPopViewController;
@property (nonatomic, strong) NSMutableArray *allData;
@property (nonatomic, strong) NSArray *filteredResults;

@end
