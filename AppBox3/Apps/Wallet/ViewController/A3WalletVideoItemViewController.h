//
//  A3WalletVideoItemViewController.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 1..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WalletItem;

@interface A3WalletVideoItemViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) WalletItem *item;

@end
