//
//  A3ExpenseListDetailsViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/13/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "ATSDragToReorderTableViewController.h"

@class A3HorizontalBarContainerView;

@interface A3ExpenseListDetailsViewController : ATSDragToReorderTableViewController

@property (nonatomic, weak) A3HorizontalBarContainerView *chartContainerView;

- (void)addNewItemButtonAction;

- (void)calculate;
@end
