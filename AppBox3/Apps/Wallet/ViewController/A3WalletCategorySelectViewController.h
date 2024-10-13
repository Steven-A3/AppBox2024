//
//  A3WalletCategorySelectViewController.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 17..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WalletCategory;

@protocol WalletCategorySelectDelegate <NSObject>

@required
- (void)walletCategorySelected:(WalletCategory_ *) category;

@end

@interface A3WalletCategorySelectViewController : UITableViewController

@property (nonatomic, weak) id<WalletCategorySelectDelegate> delegate;
@property (nonatomic, strong) WalletCategory_ *selectedCategory;

@end
