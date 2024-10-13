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
- (void)walletItemEdited:(WalletItem_ *)item;
- (void)WalletItemDeleted;

@end

@interface A3WalletItemEditViewController : UITableViewController

/*! isAddNewItem == YES, item will be created. WalletCategory_ must have data.
 *  isAddNewItem == NO, item must have data, WalletCategory_ must be nil.
 */
@property (nonatomic, assign) BOOL isAddNewItem;
@property (nonatomic, strong) WalletItem_ *item;
@property (nonatomic, strong) WalletCategory_ *category;
@property (nonatomic, weak) id<WalletItemEditDelegate> delegate;
@property (nonatomic, assign) BOOL alwaysReturnToOriginalCategory;

@end
