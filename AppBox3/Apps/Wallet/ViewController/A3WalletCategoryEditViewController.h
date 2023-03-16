//
//  A3WalletCategoryEditViewController.h
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

@interface A3WalletCategoryEditViewController : UITableViewController

@property (nonatomic, weak) id<WalletCategoryEditDelegate> delegate;
@property (nonatomic, strong) NSString *categoryID;
@property (nonatomic, assign) BOOL isAddingCategory;

@end
