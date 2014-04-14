//
//  A3WalletMoreTableViewController.h
//  AppBox3
//
//  Created by A3 on 4/13/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A3WalletMainTabBarController;

@interface A3WalletMoreTableViewController : UITableViewController

@property (nonatomic) BOOL isEditing;
@property (nonatomic, weak) A3WalletMainTabBarController *mainTabBarController;

@end
