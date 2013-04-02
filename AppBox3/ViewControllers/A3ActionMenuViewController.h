//
//  A3ActionMenuViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/8/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3ActionMenuDelegate <NSObject>
- (void)settingsAction;
- (void)emailAction;
- (void)messageAction;
- (void)twitterAction;
- (void)facebookAction;

@end

@interface A3ActionMenuViewController : UIViewController
@property (nonatomic, weak)	id<A3ActionMenuDelegate>	delegate;

@end
