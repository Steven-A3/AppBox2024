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

@property (nonatomic, weak) IBOutlet UIButton *button1, *button2, *button3, *button4, *button5;
@property (nonatomic, weak) IBOutlet UILabel *label1, *label2, *label3, *label4, *label5;
@property (nonatomic, weak)	id<A3ActionMenuViewControllerDelegate>	delegate;

- (void)setImage:(NSString *)name selector:(SEL)selector atIndex:(NSUInteger)index1;

- (void)setText:(NSString *)text atIndex:(NSUInteger)index1;
@end
