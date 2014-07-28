//
//  A3UnitConverterMoreTableViewController.h
//  AppBox3
//
//  Created by A3 on 4/10/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
@class A3UnitConverterTabBarController;
@class A3UnitDataManager;

@interface A3UnitConverterMoreTableViewController : UITableViewController

@property (nonatomic) BOOL isEditing;
@property (nonatomic, weak) A3UnitConverterTabBarController *mainTabBarController;
@property (nonatomic, weak) A3UnitDataManager *dataManager;

@end
