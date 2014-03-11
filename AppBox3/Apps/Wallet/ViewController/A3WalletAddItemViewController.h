//
//  A3WalletAddItemViewController.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 16..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

/*
#import <UIKit/UIKit.h>

@class WalletItem;
@class WalletCategory;

@protocol WalletItemAddDelegate <NSObject>

@required
- (void)walletItemAddCompleted:(WalletItem *)addedItem;

@optional
- (void)walletITemAddCanceled;

@end

@interface A3WalletAddItemViewController : UITableViewController

@property (nonatomic, strong) WalletCategory *selectedCategory;
@property (assign) id<WalletItemAddDelegate> delegate;

@end
*/

#import <UIKit/UIKit.h>

@class WalletItem;
@class WalletCategory;

@protocol WalletItemAddDelegate <NSObject>

@required
- (void)walletItemAddCompleted:(WalletItem *)addedItem;

@optional
- (void)walletITemAddCanceled;

@end

@interface A3WalletAddItemViewController : UITableViewController

@property (nonatomic, strong) WalletCategory *selectedCategory;
@property (assign) id<WalletItemAddDelegate> delegate;

@end