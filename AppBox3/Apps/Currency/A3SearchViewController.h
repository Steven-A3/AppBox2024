//
//  A3SearchViewController
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/31/13 12:12 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol A3SearchViewControllerDelegate <NSObject>
- (void)searchViewController:(UIViewController *)viewController itemSelectedWithItem:(NSString *)selectedItem;

@optional
- (void)willDismissSearchViewController;

@end

@interface A3SearchViewController : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) id<A3SearchViewControllerDelegate> delegate;
@property (nonatomic, copy) NSString *placeHolder;
@property (nonatomic)		BOOL allowChooseFavorite;
@property (nonatomic)		BOOL shouldPopViewController;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *mySearchDisplayController;
@property (nonatomic, strong) NSMutableArray *allData;
@property (nonatomic, strong) NSArray *filteredResults;
@property (nonatomic) NSMutableArray *sectionsArray;
@property (nonatomic) UILocalizedIndexedCollation *collation;

- (void)callDelegate:(NSString *)selectedItem;
- (void)filterContentForSearchText:(NSString *)searchText;

@end

@interface A3SearchTargetItem : NSObject
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *displayName;
@end

