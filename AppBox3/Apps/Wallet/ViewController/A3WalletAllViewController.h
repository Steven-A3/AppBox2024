//
//  A3WalletAllViewController.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WalletCategory;

@interface A3WalletAllViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) WalletCategory *category;
@property (nonatomic, assign) BOOL isFromMoreTableViewController;

@end
