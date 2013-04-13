//
//  A3ActionMenuViewController_iPad.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/8/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3ActionMenuViewControllerDelegate;

@interface A3ActionMenuViewController_iPad : UIViewController
@property (nonatomic, weak)	id<A3ActionMenuViewControllerDelegate>	delegate;

@end
