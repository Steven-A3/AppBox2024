//
//  A3WalletItemViewController.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 22..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WalletItem;

@interface A3WalletItemViewController : UITableViewController

@property (nonatomic, strong) WalletItem_ *item;
@property (nonatomic, readwrite) BOOL showCategory;
@property (nonatomic, assign) BOOL alwaysReturnToOriginalCategory;

@end
