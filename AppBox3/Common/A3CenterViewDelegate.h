//
//  A3CenterViewDelegate.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/7/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol A3CenterViewDelegate <NSObject>
@required
- (void)cleanUp;

@optional
- (BOOL)usesFullScreenInLandscape;
- (BOOL)hidesNavigationBar;

@end

@protocol A3ChildViewControllerDelegate <NSObject>

- (void)childViewControllerWillDismiss;

@end
