//
//  A3SettingsAddFavoritesViewController.h
//  AppBox3
//
//  Created by A3 on 1/13/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3ChildViewControllerDelegate;

@interface A3SettingsAddFavoritesViewController : UITableViewController

@property (nonatomic, weak) id<A3ChildViewControllerDelegate> delegate;

@end
