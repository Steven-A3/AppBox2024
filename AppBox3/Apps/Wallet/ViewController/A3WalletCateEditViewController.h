//
//  A3WalletCateEditViewController.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 15..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WalletCategory;

@protocol WalletCategoryEditDelegate <NSObject>

@required
- (void)walletCategoryEdited:(WalletCategory *)category;

@optional
- (void)walletCateEditCanceled;

@end

@interface A3WalletCateEditViewController : UITableViewController

@property (nonatomic, assign) id<WalletCategoryEditDelegate> delegate;
@property (nonatomic, strong) WalletCategory *category;

@end
