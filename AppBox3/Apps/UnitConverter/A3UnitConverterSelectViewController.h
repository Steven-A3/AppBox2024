//
//  A3UnitConverterSelectViewController.h
//  A3TeamWork
//
//  Created by kihyunkim on 13. 10. 20..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UnitFavorite;
@class UnitConvertItem;
@class UnitItem;

@protocol A3UnitSelectViewControllerDelegate <NSObject>

- (void)selectViewController:(UIViewController *)viewController unitSelectedWithItem:(UnitItem *)selectedItem;
- (void)didUnitSelectCancled;

@end

@protocol A3UnitConverterFavoriteEditDelegate <NSObject>

- (void) favoritesEdited;

@end

@interface A3UnitConverterSelectViewController : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) id<A3UnitSelectViewControllerDelegate> delegate;
@property (nonatomic, weak) id<A3UnitConverterFavoriteEditDelegate> editingDelegate;
@property (nonatomic, copy) NSString *placeHolder;
@property (nonatomic)		BOOL shouldPopViewController;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *mySearchDisplayController;
@property (nonatomic, strong) NSArray *filteredResults;
@property (nonatomic) NSMutableArray *sectionsArray;
@property (nonatomic) UILocalizedIndexedCollation *collation;

// Sub class should implement this member
@property (nonatomic, strong) NSMutableArray *allData;
@property (nonatomic, strong) NSMutableArray *favorites;
@property (nonatomic, strong) UnitConvertItem *selectedItem;
@property (nonatomic, strong) NSMutableArray *convertItems;

- (void)callDelegate:(UnitItem *)selectedItem;
- (void)filterContentForSearchText:(NSString *)searchText;

@end
