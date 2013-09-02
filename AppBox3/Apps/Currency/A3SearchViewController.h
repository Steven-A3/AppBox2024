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

@interface A3SearchViewController : UITableViewController <UISearchBarDelegate>
@property (nonatomic, weak) id<A3SearchViewControllerDelegate> delegate;
@property (nonatomic, copy) NSString *placeHolder;
@property (nonatomic)		BOOL allowChooseFavorite;
@property (nonatomic)		BOOL shouldPopViewController;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) UISearchDisplayController *mySearchDisplayController;

- (void)callDelegate:(NSString *)selectedItem;

- (void)filterContentForSearchText:(NSString *)searchText;
@end