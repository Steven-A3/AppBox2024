//
//  A3CenterViewProtocol.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/7/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol A3CenterViewProtocol <NSObject>

- (BOOL)usesFullScreenInLandscape;
- (BOOL)hidesNavigationBar;
- (void)cleanUp;

@end

@protocol A3ChildViewControllerDelegate <NSObject>

- (void)childViewControllerWillDismiss;

@end
