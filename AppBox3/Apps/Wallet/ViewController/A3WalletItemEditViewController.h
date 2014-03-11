//
//  A3WalletItemEditViewController.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 2..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WalletItem;

@protocol WalletItemEditDelegate <NSObject>

@required
- (void)walletItemEdited:(WalletItem *)item;
- (void)WalletItemDeleted;

@end

@interface A3WalletItemEditViewController : UITableViewController

@property (nonatomic, strong) WalletItem *item;
@property (nonatomic, assign) id<WalletItemEditDelegate> delegate;

@end
