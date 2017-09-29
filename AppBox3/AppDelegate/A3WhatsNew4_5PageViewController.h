//
//  A3WhatsNew4_5PageViewController.h
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 3/15/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3WhatsNew4_5PageViewController : UIPageViewController

@property (nonatomic, copy) void(^dismissBlock)(void);

- (void)showNextPage;

@end
