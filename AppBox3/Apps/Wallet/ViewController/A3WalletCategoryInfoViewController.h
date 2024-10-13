//
//  A3WalletCategoryInfoViewController.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 15..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletCategoryEditViewController.h"

@class WalletCategory;

@interface A3WalletCategoryInfoViewController : UITableViewController <WalletCategoryEditDelegate>

@property (nonatomic, strong) WalletCategory_ *category;

@end
