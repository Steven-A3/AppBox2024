//
//  A3WalletItemEditViewController.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 2..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WalletItem;
@class WalletCategory;

extern NSString *const A3WalletNotificationItemCategoryMoved;

@protocol WalletItemEditDelegate <NSObject>

@required
- (void)walletItemEdited:(WalletItem *)item;
- (void)WalletItemDeleted;

@end

@interface A3WalletItemEditViewController : UITableViewController

/*! isAddNewItem == YES, item will be created. WalletCategory must have data.
 *  isAddNewItem == NO, item must have data, walletCategory must be nil.
 */
@property (nonatomic, assign) BOOL isAddNewItem;
@property (nonatomic, strong) WalletItem *item;
@property (nonatomic, strong) WalletCategory *walletCategory;
@property (nonatomic, assign) id<WalletItemEditDelegate> delegate;
@property (nonatomic, assign) BOOL alwaysReturnToOriginalCategory;

@end
