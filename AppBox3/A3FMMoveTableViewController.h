//
//  A3FMMoveTableViewController.h
//  AppBox3
//
//  Created by A3 on 6/12/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "FMMoveTableView.h"

@protocol A3FMMoveTableViewSwipeCellDelegate <NSObject>
@optional
- (BOOL)cellShouldShowMenu;
- (void)addMenuView:(BOOL)showDelete;
- (void)removeMenuView;
- (CGFloat)menuWidth:(BOOL)showDelete;
@end

@interface A3FMMoveTableViewController : UIViewController

@property (nonatomic, strong) FMMoveTableView *tableView;
@property (nonatomic, strong) NSMutableSet *swipedCells;

- (void)setupSwipeRecognizers;
- (void)shiftRight:(NSMutableSet *)cells;
- (void)shiftLeft:(UITableViewCell <A3FMMoveTableViewSwipeCellDelegate> *)cell;
- (void)unSwipeAll;

@end
