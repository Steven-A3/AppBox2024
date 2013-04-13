//
//  A3ActionMenuViewControllerDelegate.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/13/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol A3ActionMenuViewControllerDelegate <NSObject>
@optional
- (void)settingsAction;
- (void)emailAction;
- (void)messageAction;
- (void)twitterAction;
- (void)facebookAction;
- (void)newListAction;
- (void)showHistoryAction;
- (void)shareAction;

@end
