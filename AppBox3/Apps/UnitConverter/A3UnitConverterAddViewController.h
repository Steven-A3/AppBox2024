//
//  A3UnitConverterAddViewController.h
//  A3TeamWork
//
//  Created by kihyunkim on 13. 10. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A3UnitDataManager;

@protocol A3UnitConverterAddViewControllerDelegate <NSObject>
- (void)favoritesUpdatedInAddViewController;

@end

@interface A3UnitConverterAddViewController : UITableViewController

@property (nonatomic, weak) id<A3UnitConverterAddViewControllerDelegate> delegate;
@property (nonatomic) BOOL shouldPopViewController;
@property (nonatomic, assign) NSUInteger categoryID;
@property (nonatomic, strong) NSMutableArray *allData;
@property (nonatomic, weak) A3UnitDataManager *dataManager;

@end
