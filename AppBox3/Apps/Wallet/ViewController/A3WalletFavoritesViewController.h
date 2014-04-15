//
//  A3WalletFavoritesViewController.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WalletCategory;

@interface A3WalletFavoritesViewController : UITableViewController

@property (nonatomic, strong) WalletCategory *category;
@property (nonatomic, assign) BOOL isFromMoreTableViewController;

@end
