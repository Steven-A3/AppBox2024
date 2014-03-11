//
//  A3WalletCategorySelectViewController.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 17..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WalletCategory;

@protocol WalletCatogerySelectDelegate <NSObject>

@required
- (void)walletCategorySelected:(WalletCategory *) category;

@end

@interface A3WalletCategorySelectViewController : UITableViewController

@property (assign) id<WalletCatogerySelectDelegate> delegate;
@property (nonatomic, strong) WalletCategory *selectedCategory;

@end
