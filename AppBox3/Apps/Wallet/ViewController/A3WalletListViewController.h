//
//  A3WalletListViewController
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/29/14 10:57 AM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMMoveTableView.h"

@class WalletItem;

@interface A3WalletListViewController : UIViewController <FMMoveTableViewDelegate, FMMoveTableViewDataSource>

@property (nonatomic, strong) FMMoveTableView *tableView;
@property (nonatomic, strong) NSDictionary *category;
@property (nonatomic, assign) BOOL isFromMoreTableViewController;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, assign) BOOL showCategoryInDetailViewController;

- (void)initializeViews;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath walletItem:(WalletItem *)item;
- (void)showLeftNavigationBarItems;
- (void)addButtonConstraints;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath withItem:(WalletItem *)item;

@end

extern NSString *const A3WalletTextCellID1;
extern NSString *const A3WalletBigVideoCellID1;
extern NSString *const A3WalletBigPhotoCellID1;
extern NSString *const A3WalletTextCellID;
extern NSString *const A3WalletPhotoCellID;
extern NSString *const A3WalletVideoCellID;
extern NSString *const A3WalletAllTopCellID;
extern NSString *const A3WalletNormalCellID;

