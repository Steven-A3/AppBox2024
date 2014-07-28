//
//  A3UnitConverterSelectViewController.h
//  A3TeamWork
//
//  Created by kihyunkim on 13. 10. 20..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A3UnitDataManager;

@protocol A3UnitSelectViewControllerDelegate <NSObject>

- (void)selectViewController:(UIViewController *)viewController didSelectCategoryID:(NSUInteger)categoryID unitID:(NSUInteger)unitID;
- (void)didCancelUnitSelect;

@end

@protocol A3UnitConverterFavoriteEditDelegate <NSObject>

- (void) favoritesEdited;

@end

@interface A3UnitConverterSelectViewController : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id<A3UnitSelectViewControllerDelegate> delegate;
@property (nonatomic, weak) id<A3UnitConverterFavoriteEditDelegate> editingDelegate;
@property (nonatomic, copy) NSString *placeHolder;
@property (nonatomic)		BOOL shouldPopViewController;
@property (nonatomic, assign) NSUInteger categoryID;
@property (nonatomic, assign) NSUInteger currentUnitID;
@property (nonatomic, weak) A3UnitDataManager *dataManager;

@end
