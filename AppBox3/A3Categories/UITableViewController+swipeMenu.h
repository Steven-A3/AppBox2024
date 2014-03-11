//
//  UITableViewController+swipeMenu.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/22/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3TableViewSwipeCellDelegate <NSObject>
@optional
- (BOOL)cellShouldShowMenu;
- (void)addMenuView:(BOOL)showDelete;
- (void)removeMenuView;
- (CGFloat)menuWidth:(BOOL)showDelete;
@end

@interface UITableViewController (swipeMenu)

- (void)setupSwipeRecognizers;

- (void)shiftRight:(NSMutableSet *)cells;

- (void)shiftLeft:(UITableViewCell <A3TableViewSwipeCellDelegate> *)cell;

- (void)unSwipeAll;

- (NSMutableSet *)swipedCells;

- (void)setSwipedCells:(NSMutableSet *)swipedCells;
@end
