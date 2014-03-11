//
//  A3WalletCateInfoViewController.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 15..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3WalletCateEditViewController.h"

@class WalletCategory;

@interface A3WalletCateInfoViewController : UITableViewController <WalletCategoryEditDelegate>

@property (nonatomic, strong) WalletCategory *category;

@end
