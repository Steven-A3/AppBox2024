//
//  A3AppsViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/13/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3ActionMenuViewControllerDelegate.h"

@interface A3AppsViewController : UIViewController

- (void)presentActionMenuWithDelegate:(id <A3ActionMenuViewControllerDelegate>)delegate;

- (void)closeActionMenuView;

- (void)addToolsButtonWithAction:(SEL)action;
@end
