//
//  A3AppSelectTableViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 3/11/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3AppSelectViewControllerDelegate <NSObject>

- (void)viewController:(UIViewController *)viewController didSelectAppNamed:(NSString *)appName;

@end

@interface A3AppSelectTableViewController : UITableViewController

@property (nonatomic, weak) id<A3AppSelectViewControllerDelegate> delegate;

- (id)initWithArray:(NSArray *)availableAppArray;
@end
