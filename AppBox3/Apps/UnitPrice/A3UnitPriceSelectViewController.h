//
//  A3UnitPriceSelectViewController.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 3..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

@class A3UnitDataManager;

@protocol A3UnitSelectViewControllerDelegate <NSObject>

- (void)selectViewController:(UIViewController *)viewController didSelectCategoryID:(NSUInteger)categoryID unitID:(NSUInteger)unitID;

@end

@protocol A3UnitConverterFavoriteEditDelegate <NSObject>

- (void) favoritesEdited;

@end

@interface A3UnitPriceSelectViewController : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) NSUInteger categoryID;

@property (nonatomic, weak) id<A3UnitSelectViewControllerDelegate> delegate;
@property (nonatomic, weak) id<A3UnitConverterFavoriteEditDelegate> editingDelegate;
@property (nonatomic)		BOOL shouldPopViewController;
@property (nonatomic, copy) NSString *placeHolder;
@property (nonatomic, assign) NSUInteger currentUnitID;
@property (nonatomic, assign) BOOL isFavoriteMode;
@property (nonatomic, weak) A3UnitDataManager *dataManager;

@end
