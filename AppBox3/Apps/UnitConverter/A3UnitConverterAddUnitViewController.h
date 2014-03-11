//
//  A3UnitConverterAddUnitViewController.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 17..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UnitFavorite;
@class UnitItem;

@protocol A3UnitConverterFavoriteEditDelegate <NSObject>

- (void) favoritesEdited;

@end

@interface A3UnitConverterAddUnitViewController : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) id<A3UnitConverterFavoriteEditDelegate> editingDelegate;
@property (nonatomic, copy) NSString *placeHolder;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *mySearchDisplayController;
@property (nonatomic, strong) NSArray *filteredResults;
@property (nonatomic) NSMutableArray *sectionsArray;
@property (nonatomic) UILocalizedIndexedCollation *collation;

// Sub class should implement this member
@property (nonatomic, strong) NSMutableArray *allData;
@property (nonatomic, strong) NSMutableArray *favorites;

- (void)filterContentForSearchText:(NSString *)searchText;

@end
